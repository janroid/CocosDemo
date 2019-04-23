package com.boyaa.entity.encry;

import org.json.JSONObject;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Created by MaxizMa on 2015/12/1.
 */
public class Sha1 {
    private static MessageDigest md = null;

    public void encrypt(String key, String param) {
        JSONObject jsonParam = null;
        String keyStr;
        try {
            jsonParam = new JSONObject(param);
            keyStr = jsonParam.optString("key","");
            String encodeKey = encrypt(keyStr);
            if (null == encodeKey) {
                encodeKey = "";
            }
//            AppActivity.dict_set_string(key, key, encodeKey);

        } catch (Exception e) {
            e.printStackTrace();
        }



    }

    public static String encrypt(String code) {
        try {
            if (md == null) {
                md = MessageDigest.getInstance("SHA-1");
            }
            byte[] bt = code.getBytes();
            md.update(bt);
            return bytes2Hex(md.digest());
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }

    }

    private static String bytes2Hex(byte[] digest) {
        String des = "";
        String tmp;
        for (byte aDigest : digest) {
            tmp = (Integer.toHexString(aDigest & 0xFF));
            if (tmp.length() == 1) {
                des += "0";
            }
            des += tmp;
        }
        return des;
    }
}
