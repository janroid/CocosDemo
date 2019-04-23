package com.boyaa.entity.common;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import android.util.Log;

import com.boyaa.BoyaaApp;

import net.bither.util.NativeUtil;

import org.cocos2dx.lua.AppActivity;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class SDTools {

    public static String TAG = "SDTools";

	public static final String PNG = "PNG";
	public static final String JPG = "JPG";
    public static final String PNG_SUFFIX = ".png";
    public static final String JPG_SUFFIX = ".jpg";

    private static final String versionCode = "versionCode";
    private static final String versionName = "versionName";
    private static final String versionUG = "versionUG";
    private static final String ROOT_PATH = ".boyaa";
    /** 语音 **/
    public static final String DEFAULT_VOICE = "voice";
    private static final byte[] sync = new byte[0];

    public static boolean saveFile(String oldFile, String filePath, String fileName){
        try {
            int bytesum = 0;
            int byteread = 0;
            String newPath = filePath + fileName + PNG_SUFFIX;
            File file = new File(oldFile);
            if(file.exists()){
                InputStream inStream = new FileInputStream(oldFile);
                FileOutputStream fs = new FileOutputStream(newPath);
                byte[] buffer = new byte[1024];
                int length;
                while ( (byteread = inStream.read(buffer)) != -1) {
                    bytesum += byteread; //字节数 文件大小
                    fs.write(buffer, 0, byteread);
                }
                inStream.close();

                return true;
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return false;
    }

	public static boolean saveBitmap(Context context, String filePath, String fileName, Bitmap bmp) {
        return saveBitmap(context, filePath, fileName, bmp, SDTools.PNG);
    }
	
    //保存png 图片
    public static boolean saveBitmap(Context context, String filePath, String fileName, Bitmap bmp, String type) {

        synchronized (sync) {
            if (null == filePath || 0 == filePath.length())
                return false;
            if (null == fileName || 0 == fileName.length())
                return false;
            if (null == bmp)
                return false;
            if (bmp.isRecycled())
                return false;
            // 生成新的
            String fullPath = filePath + fileName + PNG_SUFFIX;
            deleteFile(fullPath);
            File file = new File(fullPath);
            try {
                file.createNewFile();
            } catch (IOException e) {
                Log.e(TAG, e.toString());
                return false;
            }
            FileOutputStream fOut = null;
            try {
                fOut = new FileOutputStream(file);
            } catch (FileNotFoundException e) {
                Log.e(TAG, e.toString());
                return false;
            }
			if(type == SDTools.PNG){
				bmp.compress(Bitmap.CompressFormat.PNG, 100, fOut);
			}
			else{
				bmp.compress(Bitmap.CompressFormat.JPEG, 60, fOut);
			}
            try {
                fOut.flush();
                fOut.close();
                fOut = null;
				/*
                FileInputStream fIn = new FileInputStream(file);
                int len = fIn.available() / 1024;
                Log.v(TAG, "image len = " + len + " KB");
                fIn.close();
                fIn = null;
				*/
            } catch (IOException e) {
                Log.e(TAG, e.toString());
                return false;
            } finally {
                try {
                    if (null != fOut)
                        fOut.close();
                } catch (Exception e) {
                    return false;
                }
            }
            return true;
        }
    }
    public static boolean saveBitmapNative(String filePath, String fileName, Bitmap bmp){
        synchronized (sync) {
            if (null == filePath || 0 == filePath.length())
                return false;
            if (null == fileName || 0 == fileName.length())
                return false;
            if (null == bmp)
                return false;
            if (bmp.isRecycled())
                return false;
            // 生成新的
            String fullPath = filePath + fileName + PNG_SUFFIX;
            deleteFile(fullPath);
            File file = new File(fullPath);
            try {
                file.createNewFile();
            } catch (IOException e) {
                Log.e(TAG, e.toString());
                return false;
            }
           NativeUtil.compressImageFile(bmp, fullPath, false, 1);
            return true;
        }
    }
    //删除文件
    private static boolean deleteFile(String name) {
        File file = new File(name);
        return file.exists() && file.delete();
    }

    private static boolean deleteFile(File file) {
        return file.exists() && file.delete();
    }

    public static boolean batchDeleteFile(String path) {
        File mfile = new File(path);
        if (mfile.exists()) {
            if (mfile.isFile()) {
                return deleteFile(mfile);
            }

            if (mfile.isDirectory()) {
                File[] files = mfile.listFiles();
                for (File f : files) {
                    deleteFile(f);
                }

                return true;
            }

        }

        return false;
    }

    //批量保存png 图片
    public static void batchSaveBmp(Context context, String path) {

        //判断当前版本 与 数据库中版本是否相等
        SharedPreferences pref = AppActivity.getActivity().getSharedPreferences(versionUG, -1);
        if (BoyaaApp.versionCode == pref.getInt(versionCode, -2)) {
            return;
        }
        Map<Integer, String> map = new HashMap<Integer, String>();

        Bitmap bitmap = null;
        for (Integer key : map.keySet()) {

            bitmap = BitmapFactory.decodeResource(context.getResources(), key);
            Bitmap output = Bitmap.createScaledBitmap(bitmap, 800, 480, true);

            saveBitmap(context, path, map.get(key), output);
        }
        SharedPreferences.Editor edit = AppActivity.getActivity().getSharedPreferences(versionUG, -1).edit();
        edit.putInt(versionCode, BoyaaApp.versionCode);
        edit.putString(versionName, BoyaaApp.versionName);
        edit.apply();
    }

    public static int isBitmapExist(String name) {
        String path = AppActivity.getActivity().getImagePath() + name;
        int ret = 0;
        Bitmap bitmap = BitmapFactory.decodeFile(path);
        if (null != bitmap) {
            ret = 1;
        }

        return ret;
    }

    /**
     * sd卡是否可写
     *
     * @return
     */
    public static boolean isExternalStorageWriteable() {

        return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
    }

    /**
     * 根据文件名获取byte数组
     * @param fileName
     * @return
     */
    public static byte[] getByteArray(String fileName){
        File f = new File(getTempPath() + File.separator + DEFAULT_VOICE + File.separator + fileName);
        if(!f.exists()){
            return null;
        }
        byte mbyte[] = new byte[(int)f.length()]; //创建合适文件大小的数组
        synchronized (sync) {
            try {
                InputStream in = new FileInputStream(f);
                in.read(mbyte); //读取文件中的内容到byte[]数组
                in.close();
            } catch (FileNotFoundException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
                return null;
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
                return null;
            }
        }
        return mbyte;
    }

    /**
     * 根据文件名存储byte数组
     * @param fileName
     * @param mByte
     * @return
     */
    public static boolean saveByteArray(String fileName, byte[] mByte){
        synchronized (sync) {
            try{
                File dir = new File(getTempPath() + File.separator + DEFAULT_VOICE);
                if(!dir.exists()){
                    dir.mkdir();
                }
                File f = new File(getTempPath() + File.separator + DEFAULT_VOICE + File.separator + fileName);
                if(!f.exists()){
                    f.createNewFile();
                }
                FileOutputStream fos = new FileOutputStream(f);
                fos.write(mByte);
                fos.close();
            }catch(Exception e){
                return false;
            }
            return true;
        }
    }

    public static String getTempPath() {
        String packageName=BoyaaApp.getApplication().getPackageName();
        return getSDPath()
                + File.separator + ROOT_PATH
                + File.separator + packageName;
    }

    /**
     * 检查文件 大小
     * @param file
     * @return 兆
     */
    public static double getDirSize(File file) {
        //判断文件是否存在
        if (file.exists()) {
            //如果是目录则递归计算其内容的总大小
            if (file.isDirectory()) {
                File[] children = file.listFiles();
                double size = 0;
                for (File f : children)
                    size += getDirSize(f);
                return size;
            } else {//如果是文件则直接返回其大小,以“兆”为单位
                double size = (double) file.length() / 1024 / 1024;
                return size;
            }
        } else {
            //"文件或者文件夹不存在
            return 0.0;
        }
    }

    /**
     * 递归删除目录下的所有文件及子目录下所有文件
     * @param
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
        }
        // 目录此时为空，可以删除
        return dir.delete();
    }

    public static String getSDPath(){
        String absPath = Environment.getExternalStorageDirectory().getAbsolutePath();

        return absPath;
    }


}
