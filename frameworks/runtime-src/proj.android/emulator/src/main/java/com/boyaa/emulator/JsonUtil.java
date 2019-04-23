package com.boyaa.emulator;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class JsonUtil {
    private Map<String, Object> map;
    private List list;
    private int type;

    public JsonUtil() {
        map = new HashMap<String, Object>();
    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    public JsonUtil(Map map) {
        this.map = map;
    }

    public JsonUtil(List list){

    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    public JsonUtil(Map map, int type) {
        this.map = map;
        this.type = type;
    }

    public void put(String key, Object value) {
        map.put(key, value);
    }

    @SuppressWarnings("rawtypes")
    public String toString() {
        if (this.map.isEmpty()) {
            return "{}";
        }
        String result = "{";
        Set<String> keys = map.keySet();
        for (String key : keys) {
            Object value = map.get(key);
            String valueString = "";
            if(value!=null) {
                valueString = value.toString();
            }
            result += "\"" + unicode(key) + "\":";
            if (value instanceof JsonUtil) {
                result += valueString;
            } else if (value instanceof Map) {
                result += (new JsonUtil((Map) value, type).toString());
            }else if(value instanceof List){
                result += "[";
                for (Object object : (List) value){
                    result += (new JsonUtil((Map) object, type).toString());
                    result += ",";
                }
                result = result.substring(0,result.length()-1);
                result += "]";

            } else if (value instanceof byte[]) {
                result += "\"\"";
            }else if(value instanceof List){
                result += "[";
                for (Object object : (List) value) {
                    result += (new JsonUtil((Map) value, type).toString());
                    result += ",";
                }
                result = result.substring(0,result.length());
                result += "]";
            } else {
                result += "\"" + unicode(valueString) + "\"";
            }
            result += ",";
        }
        result = result.substring(0, result.length() - 1);
        result += "}";

        return result;
    }

    public String unicode(String org) {
        if (org == null || org.length() == 0) return "";

        StringBuilder sb = new StringBuilder();
        for (char ch : org.toCharArray()) {
            switch (ch) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\b':
                    sb.append("\\b");
                    break;
                case '\f':
                    sb.append("\\f");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                case '/':
                    sb.append("\\/");
                    break;
                default:
                    if (ch <= '\u001F' || type == 1) {
                        String ss = Integer.toHexString(ch);
                        sb.append("\\u");
                        for (int k = 0; k < 4 - ss.length(); k++) {
                            sb.append('0');
                        }
                        sb.append(ss.toUpperCase());
                    } else {
                        sb.append(ch);
                    }
            }
        }
        return sb.toString();
    }

    // 中文 转 unicode
    public String getToUnicode(String zhStr) {
        StringBuilder unicode = new StringBuilder();

        for (int i = 0; i < zhStr.length(); i++) {
            char c = zhStr.charAt(i);

            if (c > 128) {
                unicode.append("\\u");
                unicode.append(Integer.toHexString(c));
            } else {
                unicode.append("\\");
                unicode.append(c);
            }
        }
        return unicode.toString();
    }


}
