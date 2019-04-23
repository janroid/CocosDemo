package com.boyaa.entity.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Vibrator;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;

import com.boyaa.BoyaaApp;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by ReneYang on 2016/9/2.
 */
public class Utils {

    public void installAPK(int key, String param) {
        Log.d("installApk", key+";"+param);
        String filePath = "";
        JSONObject jsonData = null;
        int gameID = 0;
        long ante = 0;
        int state = 0;
        try {
            jsonData = new JSONObject(param);
            filePath = jsonData.getString("filePath");
        }catch (Exception e){
            e.printStackTrace();
        }
        if(TextUtils.isEmpty(filePath)) {
            return;
        }
        File file = new File(filePath);
        if(!file.exists()) {
            return;
        }
        if(file!=null){
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(Uri.fromFile(file),
                    "application/vnd.android.package-archive");
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            AppActivity.getActivity().startActivity(intent);
        }
    }


    /**
     * 通过浏览器打开链接
     * @param key
     * @param param
     */
    public void openLink(int key, String param) {
        Log.d("openLink", key+";"+param);
        String content = "";
        try {
            JSONObject jsonData = new JSONObject(param);
            content = jsonData.optString("content");
            Log.d("openLink", "openLink: "+content);
            //正则匹配链接
            Pattern p = Pattern.compile("(http://|ftp://|https://|www){0,1}[^\u4e00-\u9fa5\\s]*?\\.(com|net|cn|me|tw|fr)[^\u4e00-\u9fa5\\s]*");
            Matcher m = p.matcher(content);
            if(m.find()){
                String url = m.group(0);
                Log.d("openLink", "url: "+url);
                Intent intent= new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(url);
                intent.setData(content_url);
                AppActivity.getActivity().startActivity(intent);
            }

        }catch (Exception e){
            e.printStackTrace();
        }
    }

    /**
     * 将dp转换成px
     * @param context
     * @param dip
     * @return
     */
    public static int formatDipToPx(Context context, int dip) {
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return (int) Math.ceil(dip * dm.density);
    }

    /**
     * 获取安卓系统属性值
     * @param key
     * @return
     */
    private String getAndroidSystemProperties(String key){
        String ret = "";
        try {
            Method method_get = Class.forName("android.os.SystemProperties").getMethod("get", String.class);
            ret = (String)method_get.invoke(null,key);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        return ret;
    }

    /**
    * @Description: 获取手机serialno
    * @author liuyue
    * @date 2017/6/1 18:29
    */

    public void getPhoneSerialNo(int key, String param){
        String serialNo = getAndroidSystemProperties("ro.serialno");
//        AppActivity.dict_set_string(key,key,serialNo);
    }

    public void jumpToGooglePlay(int key, String param) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("action", Intent.ACTION_VIEW);
            jsonObject.put("data", "market://details?id=" + AppActivity.getActivity().getPackageName());
            jumpTo(key, jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void jumpTo(int key, String param) {
        try {
            JSONObject jsonData = new JSONObject(param);
            String action = jsonData.optString("action");
            String data = jsonData.optString("data", null);
            String type = jsonData.optString("type", null);
            Intent intent = new Intent();
            intent.setAction(action);
            intent.setDataAndType(data != null ? Uri.parse(data) : null, type);

            if (intent.resolveActivity(AppActivity.getActivity().getPackageManager()) != null) {
                AppActivity.getActivity().startActivity(intent);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void shake(int key, String param) {
        final Vibrator vibrator = (Vibrator) BoyaaApp.getApplication().getSystemService(Context.VIBRATOR_SERVICE);
        long [] pattern = {100,400,100,400};
        if (vibrator != null) {
            vibrator.vibrate(pattern,-1);
            new Timer().schedule(new TimerTask() {
                @Override
                public void run() {
                    vibrator.cancel();
                }
            }, 1000);
        }
    }

}
