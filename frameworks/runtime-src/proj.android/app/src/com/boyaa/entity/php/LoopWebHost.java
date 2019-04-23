/**
 * LoopWebHost.java
 * Boyaa Texas Poker For Android
 * <p/>
 * Created by JanRoid on 2014-11-21.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.php;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.ThreadTask;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.IOException;
import java.util.TreeMap;

/**
 * @author Janroid
 *
 */
public class LoopWebHost {
    public static final int KEY_CHOOSE_BESTURL = 1;

    public Byte first = 0;

    public void loop(JSONArray urls) throws JSONException {
        if (null == urls || urls.length() < 1) {
            return;
        }

        for (int i = 0; i < urls.length(); i++) {

            final String httpUrl = urls.getString(i);
            ThreadTask.start(null, null, false, new OnThreadTask() {

                int code = -1;

                @Override
                public void onUIBackPressed() {
                }

                @Override
                public void onThreadRun() {
                    code = httpGet(httpUrl);
                }

                @Override
                public void onAfterUIRun() {
                    synchronized (first) {
                        if (code == 200 && first == 0) {
                            first = 1;

                            TreeMap<String, String> map = new TreeMap<String, String>();
                            map.put("bestUrl", httpUrl);
                            String strMap = new JsonUtil(map).toString();

                            LuaCallManager.callLua(KEY_CHOOSE_BESTURL, strMap);
                        }
                    }


                }
            });
        }
    }

    public int httpGet(String url) {
        int code = -1;
        HttpGet get = new HttpGet(url);
        HttpClient client = new DefaultHttpClient();
        try {
            HttpResponse response = client.execute(get);
            code = response.getStatusLine().getStatusCode();

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            client.getConnectionManager().shutdown();
        }

        return code;
    }
}
