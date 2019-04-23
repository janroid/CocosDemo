/**
 * ConfigUtil.java
 * Boyaa Texas Poker For Android
 * <p/>
 * Created by JanRoid on 2015-3-12.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.utils;

import com.boyaa.BoyaaApp;

/**
 * @author Janroid
 *
 */
public class ConfigUtil {
    public static int getW(int pix) {
        return getX(pix);
    }

    public static int getH(int pix) {
        return getY(pix);
    }

    private static int getX(int x,int width){
        int int_widh = 0;
        if(x>=0){
            float temp=(float) BoyaaApp.getApplication().getScreenWidth() / width * x;
            int_widh = (int) (temp + 0.5);
        }else{
            float temp=(float)BoyaaApp.getApplication().getScreenWidth() / width * (-x);
            int_widh = -(int) (temp + 0.5);
        }
        return int_widh;
    }
    private static int getY(int y,int height){
        int int_height =0;
        if(y>=0){
            float temp=(float)BoyaaApp.getApplication().getScreenHith() / height * y;
            int_height = (int) (temp + 0.5);
        }else{
            float temp=(float)BoyaaApp.getApplication().getScreenHith() / height * (-y);
            int_height = -(int) (temp + 0.5);
        }
        return int_height;
    }
    public  static int getX(int x) {
        return getX(x,1280);
    }
    public static int getHDX(int x){
        return getX(x, 800);
    }
    public  static int getY(int y) {
        return getY(y,720);
    }
    public static int getHDY(int y){
        return getY(y,480);
    }

    /**
     * 试图将strToFloat字符串转换成float返回, 若无法转换, 则返回0f
     * @param strToFloat 需要转换成float的字符串
     * @return 如果转换成功则返回成功的值, 否则返回0
     */
    public static float getFloat(String strToFloat){
        return getFloat(strToFloat, 0f);
    }

    /**
     * 试图将strToFloat字符串转换成float返回, 若无法转换, 则返回指定的默认值defaultVal
     * @param strToFloat 需要转换成float的字符串
     * @param defaultVal 默认返回值
     * @return 如果转换成功则返回成功的值, 否则返回指定的默认值defaultVal
     */
    public static float getFloat(String strToFloat, float defaultVal) {
        try{
            return Float.parseFloat(strToFloat);
        }catch(Exception e){
            return defaultVal;
        }
    }
}
