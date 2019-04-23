/**
 * LuaCallManager.java
 * Boyaa Texas Poker For Android
 * <p>
 * Created by JanRoid on 2014-11-11.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.luaManager;


import android.util.Log;

import com.boyaa.entity.utils.LogUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * @author Janroid
 */
public class LuaCallManager {
	private static final String TAG = "LuaCallManager";
	
	private static LuaCallManager luaCallManager;
	
	// 获得key，此key代表需调用的方法名
	public final static String kluaCallEvent = "LuaCallEvent";
	
	public static LuaCallManager getInstance() {
		if (null == luaCallManager) {
			luaCallManager = new LuaCallManager();
		}
		return luaCallManager;
	}

	public static void callEvent(int nKey,String sJsonData)
	{
		LogUtil.d(TAG,"key:"+nKey+";data:"+sJsonData);

		try {
			JSONObject json = new JSONObject(sJsonData);
			String classPath = json.optString("_nativeClassPath");
			String methodName = json.optString("_nativeClassMethod");
			String params = json.optString("_params");
			runReflectObject(classPath, methodName, nKey, params);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 通过反射机制调用指定类的方法
	 * @param objName
	 * @param methodName
	 * @param param
	 */
	private static void runReflectObject(String objName, String methodName, int callbackId, String param) {
        try {
            Class<?> mclass = Class.forName(objName);
            Object mObject = mclass.newInstance();

            Method mMethod = mclass.getMethod(methodName, int.class, String.class);
            mMethod.invoke(mObject, callbackId, param);

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }

	/**
	 * java调用lua
	 * @param nKey
	 * @param result
	 */
	public static void callLua(int nKey, String result){
		systemCallLuaEvent(Integer.valueOf(nKey), result);
	}

	public static native void systemCallLuaEvent(int nKey, String sJsonData);
}
