package com.boyaa.entity.pay;

/**
 * Created by ReneYang on 2017/7/5.
 */

public interface PurchaseFinishedListener {
    void onPurchaseFinished(int status, String orderId, String price, String unit);
}
