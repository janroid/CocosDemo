package com.boyaa.entity.utils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class UtilTool {

    public static boolean hasDigit(String content) {
        boolean flag = false;
        Pattern p = Pattern.compile(".*\\d+.*");
        Matcher m = p.matcher(content);
        if (m.matches()) {
            flag = true;
        }
        return flag;
    }
}
