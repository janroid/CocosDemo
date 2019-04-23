package com.boyaa.entity.umeng;

import android.content.Context;
import android.text.TextUtils;

import com.umeng.analytics.MobclickAgent;
import com.boyaa.ipoker.BuildConfig;

public class Umeng {
	public final static String TAG = "Umeng";
	private static Context mContext;

	public static void init(Context context) {
		mContext = context;
		// umeng输出调试日志
		MobclickAgent.setDebugMode(BuildConfig.DEBUG);
		// 超过n毫秒秒算新打开
		MobclickAgent.setSessionContinueMillis(60000);
	}

	public static void onKillProcess() {
		MobclickAgent.onKillProcess(mContext);
	}
	
	public static void onResume() {
		MobclickAgent.onResume(mContext);
	}
	
	public static void onPause() {
		MobclickAgent.onPause(mContext);
	}

	public static void event(String eventId) {
		if (!TextUtils.isEmpty(eventId)) {
			MobclickAgent.onEvent(mContext, eventId);
		}
	}

	public static void error(String errText, String errKey){
		String errContext = errKey + errText;
		if(errContext.length() > 1024*8){
//				上报数据超过8K，截断上报数据
			errContext = errContext.substring(1, 2048);
		}
		MobclickAgent.reportError(mContext, errContext);
	}

	public static void error(int callBackId, String errText) {
		error(errText, "lua crash:");
	}
	
}
