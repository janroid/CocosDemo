package com.boyaa.entity.encry;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;


public class Md5 {

    public static String hash(String str) {
        if(null == str || "".equals(str) ){
            return "";
        }

        MessageDigest md5;
        byte[] byteValues;
        try {
            md5 = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException e) {

            return "";
        }

        try {
            byteValues = md5.digest(str.getBytes("UTF-8"));
        } catch (UnsupportedEncodingException e) {

            return "";
        }
        return toHexString(byteValues);
    }

    public static String toHexString(byte[] bs) {
        StringBuilder sb = new StringBuilder();
        int i;
        char c;
        byte b;
        for (i = 0; i < bs.length; i++) {
            b = bs[i];
            c = Character.forDigit((b >>> 4) & 0x0F, 16);
            sb.append(c);
            c = Character.forDigit(b & 0x0F, 16);
            sb.append(c);
        }
        return sb.toString();
    }
}
