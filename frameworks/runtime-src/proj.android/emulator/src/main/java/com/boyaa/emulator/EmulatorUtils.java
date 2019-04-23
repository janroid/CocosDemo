package com.boyaa.emulator;

import android.content.Context;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by JohnsonZhang on 2017/6/14.
 */

public class EmulatorUtils {
    /**
     * 获取设备的详细信息 用于判断是否为模拟器
     */
    public static String getDeviceDetails(Context context) {
        String cpu = JniAnti.getCpuinfo();
        String cpuFreq = Util.convertSize(Check.getCpuMaxFrequency());
        String kernel = JniAnti.getKernelVersion();
        int temp = Check.getBatteryTemp(context);
        int volt = Check.getBatteryVoltInt(context);
        int check = JniAnti.checkAntiFile();
        Map<String, Object> infoMap = new HashMap<>();
        infoMap.put("cpu", cpu);
        infoMap.put("kernel", kernel);
        infoMap.put("batteryTemp", temp);
        infoMap.put("batteryVolt", volt);
        infoMap.put("emulatorFileNo", check);
        infoMap.put("cpuFreq", cpuFreq);
        String deviceDetails = new JsonUtil(infoMap).toString();
        Log.d("deviceInfo", deviceDetails);
//        AppActivity.dict_set_string(KEY_SYSTEM_INFO,KEY_DEVICE_DETAILS,deviceDetails);
        return deviceDetails;
    }
}
