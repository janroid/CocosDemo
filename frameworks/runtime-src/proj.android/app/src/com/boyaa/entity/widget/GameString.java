package com.boyaa.entity.widget;

import java.util.HashMap;

/**
 * Created by JanRoid on 2016/8/15.
 * 文本文件，所有Android中需要用的文本都需要从这里获取
 */
public class GameString {
    private static HashMap<String,String> strMap = null;

    public static void initString(String str){
        strMap = new HashMap<String,String>();

        if(null == str || "".equals(str.trim())){
            return;
        }

        String[] strArr = str.split("##");
        if(strArr.length > 0 ){
            for (int i = 1;i < strArr.length;i++){
                String s = strArr[i];
                String[] ss = s.split("#:");
                if (ss.length == 2){
                    strMap.put(ss[0],ss[1]);
                }
            }
        }
    }

    public static String getString(String str){
        if(null == strMap){
            return "";
        }

        if(null == strMap.get(str)){
            return "";
        }
        return strMap.get(str);

    }
}
