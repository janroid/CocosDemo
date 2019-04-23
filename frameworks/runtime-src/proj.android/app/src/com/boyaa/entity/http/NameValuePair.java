package com.boyaa.entity.http;

/**
 * Created by MaxizMa on 2015/9/21.
 */
public class NameValuePair {

    private final String name;
    private final String value;

    public NameValuePair (String name, String value){
        this.name = name;
        this.value = value;
    }


    public String getName() {
        return name;
    }

    public String getValue() {
        return value;
    }

}
