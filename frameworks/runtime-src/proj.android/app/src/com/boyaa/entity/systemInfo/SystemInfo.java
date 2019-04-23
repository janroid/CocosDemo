package com.boyaa.entity.systemInfo;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import com.boyaa.emulator.EmulatorUtils;

import org.cocos2dx.lua.AppActivity;

import java.lang.reflect.Method;
import java.net.NetworkInterface;
import java.util.Enumeration;

public class SystemInfo {

    /**
     * 获取OS版本号
     */
    public static String getOsVersion() {
        return Build.VERSION.RELEASE;
    }


    /**
     * 获取设备id
     */
    public static String getDeviceId() {
        return Settings.Secure.getString(AppActivity.getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    /**
     * 获取设备名称
     */
    public static String getDeviceName() {
       return BluetoothAdapter.getDefaultAdapter().getName();
    }
    /**
     * 获取Mac地址
     */
    public static String getMacAddress() {
        Context context = AppActivity.getActivity();
        WifiManager wifi = (WifiManager) context.getApplicationContext().getSystemService(context.WIFI_SERVICE);
        String macAdd = null;
        if (wifi != null) {
            WifiInfo info = wifi.getConnectionInfo();
            macAdd = info.getMacAddress();
        }
        //android 6.0 上获取mac会得到02:00:00:00:00:00
        if (macAdd != null && macAdd.compareToIgnoreCase("02:00:00:00:00:00") == 0)
            macAdd = null;
        if (macAdd == null) {
            String mac = getMacAddr();
            if (mac != null)
                macAdd = mac;
        }
        return macAdd;
    }

    public static String getMacAddr() {
        String macAddr = null;
        String wifiName = null;
        Enumeration<NetworkInterface> interfaces = null;
        try {
            Class<?> cls = Class.forName("android.os.SystemProperties");
            Method mhd = cls.getMethod("get", String.class);
            wifiName = (String) mhd.invoke(cls, "wifi.interface");
            if (wifiName != null) {
                interfaces = NetworkInterface.getNetworkInterfaces();
                while (interfaces.hasMoreElements()) {
                    NetworkInterface iF = interfaces.nextElement();

                    byte[] addr = iF.getHardwareAddress();
                    if (addr == null || addr.length == 0) {
                        continue;
                    }

                    StringBuilder buf = new StringBuilder();
                    for (byte b : addr) {
                        buf.append(String.format("%02X:", b));
                    }
                    if (buf.length() > 0) {
                        buf.deleteCharAt(buf.length() - 1);
                    }
                    String mac = buf.toString();
                    Log.d("mac", "interfaceName=" + iF.getName() + ", mac=" + mac);
                    if (iF.getName().compareTo(wifiName) == 0) {
                        macAddr = mac;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.d("ttt", "wifi name=" + wifiName);
        return macAddr;
    }

    public static String getDeviceDetails() {
        String deviceDetails = EmulatorUtils.getDeviceDetails(AppActivity.getActivity());
        String replace = deviceDetails.replace("#", "");
        Log.d("deviceInfo", replace);
        return deviceDetails;
    }
}
