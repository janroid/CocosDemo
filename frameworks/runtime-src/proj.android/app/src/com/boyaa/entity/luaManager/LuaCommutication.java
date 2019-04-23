package com.boyaa.entity.luaManager;

import android.os.Environment;

import com.boyaa.BoyaaApp;
import com.boyaa.entity.systemInfo.SystemInfo;
import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.utils.LogUtil;
import com.boyaa.entity.utils.UtilTool;
import com.boyaa.ipoker.BuildConfig;

import org.cocos2dx.lua.AppActivity;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;

import static com.boyaa.ipoker.BuildConfig.BUILD_TYPE;
import static com.boyaa.ipoker.BuildConfig.FLAVOR;

/**
 * Lua 调用原生
 * 由于使用反射会生成实例对象，故调用appActivity的类全部通过此类进行转发
 */
public class LuaCommutication {
    public void onEngineLoaded(int key, String requestData){
        LogUtil.d("ReneYang", "onEngineLoaded");
        AppActivity.getActivity().hideStartScreen();
    }

    public void guestBindedEmail(int key, String requestData){
        File file = new File(Environment.getExternalStorageDirectory(), "." + BoyaaApp.getApplication().getPackageName() + "/ipoker.cfg");
        HashMap<Object, Object> map;
        if (file.exists()) {
            try {
                ObjectInputStream oos = new ObjectInputStream(new FileInputStream(file));
                map = (HashMap<Object, Object>) oos.readObject();
            } catch (Exception e) {
                e.printStackTrace();
                map = new HashMap<>();
            }
        } else {
            map = new HashMap<>();
        }

        map.put("bindedEmail", 1);

        try {
            ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file));
            oos.writeObject(map);
            oos.flush();
            oos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 获取原生层相关信息
     * @param key
     * @param requestData
     */
    public void getDeviceInfo(int key, String requestData){
        File file = new File(Environment.getExternalStorageDirectory(), "." + BoyaaApp.getApplication().getPackageName() + "/ipoker.cfg");
        HashMap<Object, Object> map;
        if (file.exists()) {
            try {
                ObjectInputStream oos = new ObjectInputStream(new FileInputStream(file));
                map = (HashMap<Object, Object>) oos.readObject();
            } catch (Exception e) {
                e.printStackTrace();
                map = new HashMap<>();
            }
        } else {
            map = new HashMap<>();
        }

        Object bindedEmail =  map.get("bindedEmail");
        Integer bindEmail = 0;
        if (bindedEmail instanceof Integer) {
            bindEmail = (Integer) bindedEmail;
        }
        JsonUtil json = new JsonUtil();
        json.put("IS_DEMO","debug".equals(BUILD_TYPE) ? 1 : 0);
        json.put("IS_DEBUG", "debug".equals(BUILD_TYPE) ? 1 : 0);
        json.put("LANGUAGE", FLAVOR.replaceAll("\\d+", ""));
        json.put("SUB_VER",  UtilTool.hasDigit(FLAVOR) ? FLAVOR : "");
        json.put("VERSION_CODE", BuildConfig.VERSION_CODE);
        json.put("VERSION_NAME", BuildConfig.VERSION_NAME);
        json.put("OS_VERSION", SystemInfo.getOsVersion());
        json.put("DEVICE_ID", SystemInfo.getDeviceId());
        json.put("DEVICE_NAME", SystemInfo.getDeviceName());
        json.put("MAC_ADDRESS", SystemInfo.getMacAddress());
        json.put("DEVICE_DETAILS", SystemInfo.getDeviceDetails());
        json.put("LOGIN_VER",BuildConfig.LOGIN_VER);
        json.put("IS_BIND_EMAIL",bindEmail);
        LuaCallManager.callLua(key, json.toString());
    }
}
