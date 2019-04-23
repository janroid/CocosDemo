package com.boyaa.entity.widget;

import org.json.JSONObject;

/**
 * Created by JanRoid on 2016/8/15.
 */
public class GameStringManager {
    public void initString(String key, String value){
        JSONObject jsonData = null;
        String strs = "";
        try{
            jsonData = new JSONObject(value);
            strs = jsonData.getString("native_strs");
            GameString.initString(strs);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
