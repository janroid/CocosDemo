/**
 * zipUtil.java
 * Boyaa Texas Poker For Android
 * <p/>
 * Created by JanRoid on 2014-12-1.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.file;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.utils.JsonUtil;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.zip.DataFormatException;
import java.util.zip.Deflater;
import java.util.zip.Inflater;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * @author Janroid
 *
 */
public class ZipUtil {
    private String filePath = ""; //解压后文件名，带路径
    private String fileDir = ""; //需解压到的文件夹

    public String getFilePath() {
        return filePath;
    }

    public void unZipFile(int responseKey, String param) {
        String srcFile;
        String desFile;
        String name;
        final HashMap<String, Object> map = new HashMap<>();
        try {
            JSONObject jsParam = new JSONObject(param);
            srcFile = jsParam.optString("srcFile");
            desFile = jsParam.optString("desFile");
            name = jsParam.optString("name");
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }
        
        if (desFile.equals("")) {
            desFile = new File("data/data/" + AppActivity.getActivity().getPackageName() + "/files").getAbsolutePath();
        }
        if ("".equals(srcFile)) return;
        
        try {
            ZipFile zipFile = new ZipFile(srcFile);
            ZipInputStream zis = new ZipInputStream(new FileInputStream(srcFile));
            ZipEntry zentry;
            while ((zentry = zis.getNextEntry()) != null) {
                if (zentry.isDirectory()) {
                    new File(desFile, zentry.getName()).mkdirs();
                    continue;
                }
                
                String fileName = zentry.getName();
                int index = fileName.lastIndexOf("/") + 1;
                fileName = fileName.substring(0, index) + (fileName.endsWith(".png") ? "" : name) + fileName.substring(index);
                
                InputStream inputStream = zipFile.getInputStream(zentry);
                BufferedInputStream bis = new BufferedInputStream(inputStream);
                BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(new File(desFile, fileName)));
                int len;
                while ((len = bis.read()) != -1) {
                    bos.write(len);
                }
                bos.flush();
                bis.close();
                bos.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        map.put("result", 1);
        map.put("name", name);
        String jsonStr = new JsonUtil(map).toString();
        LuaCallManager.callLua(responseKey,jsonStr);
    }
    
    public boolean unZip(String zipPath) {
        int index = zipPath.lastIndexOf("/");
        if (index != 1) {
            fileDir = zipPath.substring(0, index) + File.separator;
        }

        return unZip(zipPath, fileDir);
    }

    /**
     *
     * @param zipPath 压缩文件地址
     * @param mfileDir 解压到的地址
     */
    public boolean unZip(String zipPath, String mfileDir) {
        fileDir = mfileDir;

        int BUFFER = 4096; // 缓冲区4KB，
        String strEntry; // 保存每个zip的条目名称

        BufferedOutputStream os = null;
        FileInputStream fis = null;

        try {
            fis = new FileInputStream(zipPath);
            ZipInputStream zis = new ZipInputStream(new BufferedInputStream(fis));
            ZipEntry zentry; // 每个zip条目的实例

            while ((zentry = zis.getNextEntry()) != null) {
                int count;
                byte data[] = new byte[BUFFER];
                strEntry = zentry.getName();

                filePath = fileDir + strEntry;
                File entryFile = new File(filePath);
                File entryDir = new File(entryFile.getParent());

                if (zentry.isDirectory())
                    continue;
                if (!entryDir.exists()) {
                    entryDir.mkdirs();
                }
                FileOutputStream fos = new FileOutputStream(entryFile);
                os = new BufferedOutputStream(fos, BUFFER);

                while ((count = zis.read(data, 0, BUFFER)) != -1) {
                    os.write(data, 0, count);
                }
                os.flush();
                os.close();
            }
            zis.close();

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    public String zipFile(String filePath, String zipFilePath) {
        File file = new File(filePath);
        FileInputStream fis;
        try {
            fis = new FileInputStream(file);
            BufferedInputStream bis = new BufferedInputStream(fis);
            byte[] buf = new byte[1024];
            int len;
            FileOutputStream fos = new FileOutputStream(zipFilePath);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            ZipOutputStream zos = new ZipOutputStream(bos);// 压缩包
            ZipEntry ze = new ZipEntry(file.getName());// 这是压缩包名里的文件名
            zos.putNextEntry(ze);// 写入新的 ZIP 文件条目并将流定位到条目数据的开始处
            while ((len = bis.read(buf)) != -1) {
                zos.write(buf, 0, len);
                zos.flush();
            }
            bis.close();
            zos.close();
        } catch (FileNotFoundException e) {
            return null;
        } catch (IOException e) {
            return null;
        }
        return zipFilePath;
    }

    public static byte[] encodeZip(byte[] buffer) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream(buffer.length);
        Deflater compressor = new Deflater();
        try{

            compressor.setLevel(Deflater.BEST_COMPRESSION);
            compressor.setInput(buffer);
            compressor.finish();
            byte[] buf = new byte[1024];
            while (!compressor.finished()) {
                int count = compressor.deflate(buf);
                bos.write(buf, 0, count);
            }
        }finally{
            compressor.end();
        }
        return bos.toByteArray();
    }

    public static byte[] decodeZip(byte[] buffer) {
        int position = 0;
        byte[] src = new byte[buffer.length];
        System.arraycopy(buffer, 0, src, 0, buffer.length);
        // Create the decompressor and give it the data to compress
        Inflater decompressor = new Inflater();
        decompressor.setInput(src);
        // Create an expandable byte array to hold the decompressed data

        // Decompress the data
        byte[] buf = new byte[1024];
        byte[] result = new byte[src.length];
        while (!decompressor.finished()) {
            try {
                int count = decompressor.inflate(buf);
                if (count > 0)
                    if ((position + count) > result.length) {
                        byte[] bytep1 = new byte[position + count];
                        System.arraycopy(result, 0, bytep1, 0, position);
                        result = bytep1;
                        bytep1 = null;
                    }
                System.arraycopy(buf, 0, result, position, count);
                position += count;

            } catch (DataFormatException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            }
        }
        return result;
    }

    public static byte[] decodeGZip(byte[] buffer) {
        int position = 0;
        byte[] src = new byte[buffer.length];
        System.arraycopy(buffer, 0, src, 0, buffer.length);
        // Create the decompressor and give it the data to compress
        Inflater decompressor = new Inflater();
        decompressor.setInput(src);
        // Create an expandable byte array to hold the decompressed data

        // Decompress the data
        byte[] buf = new byte[1024];
        byte[] result = new byte[src.length];
        while (!decompressor.finished()) {
            try {
                int count = decompressor.inflate(buf);
                if (count > 0)
                    if ((position + count) > result.length) {
                        byte[] bytep1 = new byte[position + count];
                        System.arraycopy(result, 0, bytep1, 0, position);
                        result = bytep1;
                        bytep1 = null;
                    }
                System.arraycopy(buf, 0, result, position, count);
                position += count;

            } catch (DataFormatException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            }
        }
        return result;
    }
}
