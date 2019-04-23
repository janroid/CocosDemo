package com.boyaa.entity.pay.checkout;

import android.app.Activity;
import android.content.Intent;

import com.boyaa.entity.pay.PurchaseFinishedListener;
import com.boyaa.entity.pay.checkout.v3.GoogleCheckoutHelper;

/**
 *   Created by MaxizMa on 2015/11/27.
 */
public class CheckoutManager {
    public static CheckoutManager mCheckoutManager = null;
    public GoogleCheckoutHelper mGoogleCheckoutHelper;
    private PurchaseFinishedListener mPurchaseFinishedListener;

    private Activity mContext;

    public static CheckoutManager getInstance(Activity activity){
        if (null == mCheckoutManager) {
            synchronized (CheckoutManager.class) {
                if (mCheckoutManager == null) {
                    mCheckoutManager = new CheckoutManager(activity);
                }
            }
        }
        return mCheckoutManager;
    }

    public void setPurchaseFinishedListener(PurchaseFinishedListener purchaseFinishedListener) {
        this.mPurchaseFinishedListener = purchaseFinishedListener;
        if (mGoogleCheckoutHelper != null) {
            mGoogleCheckoutHelper.setPurchaseFinishedListener(mPurchaseFinishedListener);
        }
    }

    public CheckoutManager (Activity context) {
        mContext = context;
        initCheckoutPay();
    }

    /**
     *  初始化google checkout 支付
     */
    private void initCheckoutPay() {
        mGoogleCheckoutHelper = new GoogleCheckoutHelper(mContext);
        mGoogleCheckoutHelper.onCreate();

    }

    public void onDestroy() {
        if (null != mGoogleCheckoutHelper) {
            mGoogleCheckoutHelper.onDestroy();
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (null != mGoogleCheckoutHelper) {
            mGoogleCheckoutHelper.onActivityResult(requestCode, resultCode, data);
        }
    }

    /**
     *  获取 checkoutHelper类
     * @return checkoutHelper
     */
    public GoogleCheckoutHelper getCheckoutHelper(){
        if (null == mGoogleCheckoutHelper){
            initCheckoutPay();
        }
        return mGoogleCheckoutHelper;
    }

}
