package com.boyaa.entity.http;

import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.luaManager.LuaCallManager;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.TreeMap;

/**
 * Created by JanRoid on 2016/6/28.
 */
public class NetWorkUtil {

    private int key = -1;
    /**
     * 检测网络是否连通
     * @param key
     * @param value
     */
    public void checkNetWork(int key, String value){
        JSONObject jsonData = null;
        String url = null;
        this.key = key;
        try{
            jsonData = new JSONObject(value);
            url = jsonData.getString("url");
        }catch (Exception e){
            e.printStackTrace();
        }
        final String pingUrl = url;
        if(null != url){
            new Thread(){
                @Override
                public void run() {
                    pingUrl(pingUrl);
                }
            }.start();
        }
    }

    /**
     * 对url执行ping操作。
     * @param url
     */
    private void pingUrl(String url){
        int resault = 0;
        Process p;
        try {
            //ping -c 3 -w 100  中  ，-c 是指ping的次数 3是指ping 3次 ，-w 100  以秒为单位指定超时间隔，是指超时时间为100秒
            p = Runtime.getRuntime().exec("ping -c 2 -w 2 " + url);
            int status = p.waitFor();

            InputStream input = p.getInputStream();
            BufferedReader in = new BufferedReader(new InputStreamReader(input));
            StringBuffer buffer = new StringBuffer();
            String line = "";
            while ((line = in.readLine()) != null){
                buffer.append(line);
            }
            if (status == 0) {
                resault = 1;
            } else {
                resault = 0;
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        callLua(resault);
    }

    public void callLua(int status){
        TreeMap<String,Integer> map = new TreeMap<String, Integer>();
        map.put("result", status);
        String resultStr = new JsonUtil(map).toString();

        LuaCallManager.callLua(key,resultStr);
    }
}
