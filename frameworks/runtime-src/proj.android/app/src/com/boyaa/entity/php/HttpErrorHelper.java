/**
 * httpErrorHelper.java
 * Boyaa Texas Poker For Android
 * <p/>
 * Created by JanRoid on 2014-11-19.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.php;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.utils.JsonUtil;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;

/**
 * @author Janroid
 *
 */
public class HttpErrorHelper {


    public void ping(int key, String param){
        JSONObject jsonObj = null;
        String url = null;
        try {
            jsonObj = new JSONObject(param);
            url = jsonObj.getString("url");

        }catch (Exception e){
            e.printStackTrace();
        }

        int result = 0;
        if(url != null){
            boolean bo = ping(url);
            if(bo){
                result = 1;
            }

        }else{
            result = 0;
        }
        HashMap<String,Integer> map = new HashMap<String,Integer>();
        map.put("result",result);

        LuaCallManager.callLua(key, new JsonUtil(map).toString());
    }

    /**
     * 对一个地址执行ping操作，检测是否有网络
     * @param url
     * @return
     */
    public boolean ping(String url) {
        if (url == null || "".equals(url.trim())) {
            return false;
        }

        try {
            Process process = Runtime.getRuntime().exec("/system/bin/ping -c 2 -w 5 " + url);
            int state = process.waitFor();
            InputStream is = process.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            StringBuffer sb = new StringBuffer();
            String line = "";
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            if (state == 0) {
                process.destroy();
                return true;
            }
            process.destroy();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return false;
    }

}
