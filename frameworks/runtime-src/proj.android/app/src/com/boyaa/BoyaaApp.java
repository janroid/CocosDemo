package com.boyaa;

import android.app.Application;
import android.content.Context;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.utils.JsonUtil;

import java.util.TreeMap;

public class BoyaaApp extends Application {
    private static BoyaaApp app = null;
    private int screenWidth = 0;
    private int screenHigh = 0;
    private LoginServerType loginServerType = LoginServerType.ONLINE; // 默认正式

    public static int versionCode = 0;
    public static String versionName = "";
    public static String phpVersionName = "";
    private  boolean isDebug = true;


    public enum LoginServerType {
        DEMO, ONLINE, GUANGZHOU
    }

    public static BoyaaApp getApplication() {
        return app;
    }

    private final String KEY_SHOW_TOPTOAST = "ShowTopToast";
    public void showToastTop(String msg) {
        TreeMap<String, Object> tmap = new TreeMap<String, Object>();
        tmap.put("message", msg);

        String strTree = new JsonUtil(tmap).toString();

//        LuaCallManager.callLua(KEY_SHOW_TOPTOAST, strTree);
    }

    @Override
    public void onCreate() {
        super.onCreate();

        app = this;
        initScreenInfo();
//        AppEventsLogger.activateApp(this);

    }

    public boolean isDebug(){
        return isDebug;
    }

    //由lua端传过来，保证和lua中一致
    public void setDebug(boolean isDebug){
        this.isDebug = isDebug;
    }

    /**
     *  返回当前的登录server状态
     * @return loginServerType 0 demo 1 正式 2 广州
     */
    public LoginServerType getLoginServerType() {
        return this.loginServerType;
    }

    public void initScreenInfo() {
        Display display = ((WindowManager) getApplicationContext()
                .getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
        DisplayMetrics dm = new DisplayMetrics();
        display.getMetrics(dm);
        if(dm.widthPixels < dm.heightPixels){
            this.screenWidth = dm.heightPixels;
            this.screenHigh = dm.widthPixels;
        } else {
            this.screenWidth = dm.widthPixels;
            this.screenHigh = dm.heightPixels;
        }
    }

    public int getScreenWidth() {
        return screenWidth;
    }

    public int getScreenHith() {
        return screenHigh;
    }

    static {
//        System.loadLibrary("poker");
    }

//    public native String encodeme();
//
//    public native String encode1(byte[] buffer, int code);
//
//    public native String encode2(byte[] buffer1, int version);
}
