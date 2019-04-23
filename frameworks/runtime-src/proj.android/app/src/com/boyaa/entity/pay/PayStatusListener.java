package com.boyaa.entity.pay;

/**
 * Created by XindroidChen on 2016/6/14.
 */
public interface PayStatusListener {
    public void onSuccess(String info);
    public void onSuccess();
    public void onFailed();
    public void onCancel();
}
