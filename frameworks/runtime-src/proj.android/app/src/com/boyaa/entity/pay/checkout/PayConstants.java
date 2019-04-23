package com.boyaa.entity.pay.checkout;

/**
 * Created by XindroidChen on 2016/6/14.
 */
public class PayConstants {

    public static String PAYMENT_URL_DEMO = "https://ipk-demo-1.boyaa.com/api/pay/androidpay.php?sid=11";//发货地址
    public static String PAYMENT_URL = "https://ipk-demo-1.boyaa.com/api/pay/androidpay.php?sid=11";//发货地址

    public void setPaymentUrl(String paymentUrl){
        PAYMENT_URL = paymentUrl;
    }
}
