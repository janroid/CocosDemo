package com.boyaa.entity.encry;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Hash {
    MessageDigest md;
    int bytecount = 0;
    byte[] buffer = new byte[512];
    String s = "不要破解我，我只是一个HASH, 测试";

    public Hash() {
        try {
            md = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException e) {

        }
    }

    public String abc(String s) {
        try {
            File f = new File(s);
            FileInputStream fs;
            fs = new FileInputStream(f);
            BufferedInputStream bis = new BufferedInputStream(fs);
            while ((bytecount = bis.read(buffer)) > 0) {
                md.update(buffer, 0, bytecount);
            }
        } catch (FileNotFoundException e) {

        } catch (IOException e) {

        }
        return new BigInteger(1, md.digest()).toString(16);
    }

    public String giveHash() {
        md.update(s.getBytes());
        return new BigInteger(1, md.digest()).toString(16);
    }

    public String hashMe(String str) {
        md.update(str.getBytes());
        return new BigInteger(1, md.digest()).toString(16);
    }
}
