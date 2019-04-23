package com.boyaa.entity.file;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.common.SDTools;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigInteger;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;

/**
 * Created by MaxizMa on 2015/2/27.
 * 文件工具类
 */
public class FileUtil {

    private static String SDPath;
    private static String XML_DIR;

    public static String getSDPath() {
        if (isHasUseableSDCard()) {
            SDPath = SDTools.getSDPath() + "/";//获取跟目录
        }
        return SDPath;
    }

    //判断sd卡是否存在
    private static boolean isHasUseableSDCard() {
        return android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED);
    }


    public static String getXmlDir() {
        StringBuilder sb;
        if (XML_DIR == null) {
            sb = new StringBuilder();
            sb.append(getSDPath());
            sb.append(".");
            sb.append(AppActivity.getActivity().getPackageName());
            sb.append("/xml/");
            XML_DIR = sb.toString();
        }
        return XML_DIR;
    }

    /**
     * 获取单个文件的MD5值！
     *
     * @param file 传入的文件
     * @return
     */
    public static String getFileMD5(File file) {
        if (file == null) {
            return null;
        }
        if (!file.isFile()) {
            return null;
        }
        MessageDigest digest = null;
        FileInputStream in = null;
        byte buffer[] = new byte[1024];
        int len;
        try {
            digest = MessageDigest.getInstance("MD5");
            in = new FileInputStream(file);
            while ((len = in.read(buffer, 0, 1024)) != -1) {
                digest.update(buffer, 0, len);
            }
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        BigInteger bigInt = new BigInteger(1, digest.digest());
        return bigInt.toString(16);
    }

    /**
     * 获取单个文件的内容
     *
     * @param file 传入文件
     * @return 返回string
     */
    public static String getFile2Str(File file) {
        String content = "";
        if (file == null) {
            return content;
        }
        if (!file.isFile()) {
            return content;
        }

        InputStream is;

        try {
            is = new FileInputStream(file);
            //读取数据的包装流
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            //str用于读取一行数据
            String str = null;
            //StringBuffer用于存储所欲数据
            StringBuilder sb = new StringBuilder();

            while ((str = br.readLine()) != null) {
                sb.append(str);
            }
            content = sb.toString();
            is.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return content;
    }

    /**
     * 在SD卡上创建文件
     *
     * @throws IOException
     */
    public static File createSDFile(String fileName) throws IOException {
        File file = new File(fileName);
        file.createNewFile();
        return file;
    }

    /**
     * 在SD卡上创建目录
     *
     * @param dirName
     */
    public static File createSDDir(String dirName) {
        File dir = new File(dirName);
        dir.mkdirs();
        return dir;
    }

    /**
     * 判断SD卡上的文件夹是否存在
     */
    public static boolean isFileExist(String fileName) {
        File file = new File(fileName);
        return file.exists();
    }

    /**
     * 将一个InputStream里面的数据写入到SD卡中
     */
    public static File write2SDFromInput(String path, String fileName, InputStream input) {
        File file = null;
        OutputStream output = null;
        try {
            createSDDir(path);
            file = createSDFile(path + fileName);
            output = new FileOutputStream(file);
            int data = input.read();
            while (data != -1) {
                output.write(data);
                data = input.read();
            }
            output.flush();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                output.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return file;
    }

    /**
     * 删除单个文件
     *
     * @param delFilePath 被删除文件的文件名
     * @return 单个文件删除成功返回true，否则返回false
     */
    public static boolean deleteFile(String delFilePath) {
        boolean flag = false;
        File file = new File(delFilePath);
        // 路径为文件且不为空则进行删除
        if (file.isFile() && file.exists()) {
            file.delete();
            flag = true;
        }
        return flag;
    }

    /**
     * 对字符串进行压缩
     *
     * @param str
     * @return
     * @throws IOException
     */
    public static String gzipString(String str) throws IOException {
        if (null == str || "".equals(str.trim())) {
            return str;
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        GZIPOutputStream gzip = new GZIPOutputStream(out);
        gzip.write(str.getBytes());
        gzip.close();


        return out.toString("ISO-8859-1");
    }

    public static String unGzipString(String str) throws IOException {
        if (null == str || "".equals(str.trim())) {
            return str;
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ByteArrayInputStream in = new ByteArrayInputStream(str
                .getBytes("ISO-8859-1"));
        GZIPInputStream gunzip = new GZIPInputStream(in);
        byte[] buffer = new byte[256];
        int n;
        while ((n = gunzip.read(buffer)) >= 0) {
            out.write(buffer, 0, n);
        }
        // toString()使用平台默认编码，也可以显式的指定如toString("GBK")   
        return out.toString();
    }


    public static byte[] getByteFromFile(File file) throws IOException {
        InputStream im = new FileInputStream(file);
        long len = file.length();
        if (len > Integer.MAX_VALUE) {
            throw new IOException("文件太大" + file.getName());
        }
        byte[] bytes = new byte[(int)len];
        int offset = 0;
        int numRead;
        while (offset < bytes.length
                && (numRead = im.read(bytes, offset, bytes.length-offset)) >= 0){
            offset += numRead;
        }
        if (offset < bytes.length) {
            throw new IOException("文件没读取完整");
        }
        im.close();
        return bytes;
    }

    /**
     * 保存bitmap为png文件，保持位置为引擎下载图片所保存的地方
     * @param fileName 文件名，无后缀
     */
    public static String saveImage(Bitmap bmp, String fileName){
        String imgPath =AppActivity.getActivity().getImagePath();
        boolean success = SDTools.saveBitmap(AppActivity.getActivity(),imgPath,fileName,bmp);

        if(success){
            return fileName+".png";
        }

        return null;
    }

    /**
     *  保存bitmap为png
     * @param bitmap 图片bitmap
     * @param path 保存地址
     * @param fileName 文件名，无后缀
     * @return boolean 是否保存成功
     */
    public static boolean saveImage(Bitmap bitmap, String path, String fileName) {
        return SDTools.saveBitmap(AppActivity.getActivity(),path,fileName,bitmap);
    }

    /**
     * 根据Url获取bitmap对象
     * @param src
     * @return
     */
    public static Bitmap getBitmapFromURL(String src) {
        try {
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);
            return myBitmap;
        } catch (IOException e) {
            // Log exception
            return null;
        }
    }

    /**
     * 递归删除目录下的所有文件及子目录下所有文件 不会删除该目录
     * @param dir 将要删除的文件目录
     * @return boolean Returns "true" if all deletions were successful.
     *                 If a deletion fails, the method stops attempting to
     *                 delete and returns "false".
     */
    public static boolean deleteDir(File dir) {
        if (dir.isDirectory()) {
            String[] children = dir.list();
            //递归删除目录中的子目录下
            for (int i=0; i<children.length; i++) {
                boolean success = deleteDir(new File(dir, children[i]));
                if (!success) {
                    return false;
                }
            }
        } else {
            return dir.delete();
        }
//        删除目录
//        return dir.delete();
        return true;
    }

    public void deleteDir(int key, String param) {
        JSONObject jsParam = null;
        try {
            jsParam = new JSONObject(param);
            String path = jsParam.optString("path", "");
            HashMap<String, Object> map = new HashMap<String,Object>();
            if(!TextUtils.isEmpty(path)) {
                boolean result = deleteDir(new File(path));
                map.put("result", result);
            } else {
                map.put("result", false);
            }
            LuaCallManager.callLua(key, new JsonUtil(map).toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }


}
