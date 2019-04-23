/**
 * RequestResult.java
 * Boyaa Texas Poker For Android
 * <p/>
 * Created by JanRoid on 2015-3-31.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.common;

/**
 * @author Janroid
 *
 */
public class RequestResult {
    public static final int REQUEST_SUCCESS = 1;
    public static final int REQUEST_TIMEOUT = 0;
    public static final int REQUEST_RESULT_ERROR = -1;

    public int code = REQUEST_SUCCESS;
    public String retStr = "";
}
