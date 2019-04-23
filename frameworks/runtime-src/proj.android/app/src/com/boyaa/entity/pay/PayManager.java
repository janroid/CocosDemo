package com.boyaa.entity.pay;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.pay.checkout.CheckoutManager;
import com.boyaa.entity.pay.checkout.v3.GoogleCheckoutHelper;
import com.boyaa.entity.pay.checkout.v3.IabResult;
import com.boyaa.entity.pay.checkout.v3.Inventory;
import com.boyaa.entity.pay.checkout.v3.Security;
import com.boyaa.entity.pay.checkout.v3.SkuDetails;
import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.utils.LogUtil;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;

public class PayManager {
    private static final String TAG = "pay.PayManager";
    public static int mResponseKey = -1;
    public static int mPayViewIndex = 99;
    private int queryProductkey;
    //    private WebViewManager webViewmanager = new WebViewManager();
    /**
     *  lua 调用 唤起支付
     * @param key 关键字
     * @param param json参数
     */
    public void pay(int key, String param) {
        mResponseKey = key;
        Log.d(TAG, "pay: key = "+key+" param = " + param);
        Log.d(TAG,Thread.currentThread().getName());
        AppActivity context = (AppActivity) AppActivity.getContext();
        context.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG,Thread.currentThread().getName());
            }
        });
//        onPayResponse(param);
        try {
            JSONObject jsParam = new JSONObject(param);
            String order = jsParam.optString("order", "");
            String productID = jsParam.optString("productID", "");
            String payType = jsParam.optString("payType", "");
            String payMoney = jsParam.optString("payMoney", "");
            String currencyCode = jsParam.optString("currencyCode", "");
            checkoutPay(order, productID, payMoney, currencyCode);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    private void checkoutPay(String mOrder, String mProductId, String payMoney, String currencyCode) {
        CheckoutManager.getInstance((Activity) AppActivity.getContext())
                .setPurchaseFinishedListener(new PurchaseFinishedListener() {
                    @Override
                    public void onPurchaseFinished(int status, String orderId, String payMoney, String currencyCode) {
                        Log.d(TAG,"status = "+ status+" orderId = "+orderId+" payMoney = "+payMoney+" currencyCode = "+currencyCode);
                        TreeMap<String, Object> map = new TreeMap<String, Object>();
                        map.put("result", status);
                        map.put("payMoney", payMoney);
                        map.put("currencyCode", currencyCode);
                        map.put("payType", "checkout");
                        map.put("orderId", orderId);
                        JsonUtil json = new JsonUtil(map);
                        PayManager.onPayResponse(json.toString());
                    }
                });
        CheckoutManager.getInstance((Activity) AppActivity.getContext()).getCheckoutHelper().requestPurchase(mProductId, mOrder, payMoney, currencyCode);
    }

    // 设置发货地址
    public void setPayCGI(int key, String param) {
        try {
            JSONObject jsParam = new JSONObject(param);
            String uid = jsParam.optString("uid", "");
            String channel = jsParam.optString("channel", "");
            String mtkey = jsParam.optString("mtkey", "");
            String skey = jsParam.optString("skey", "");
            String payCGI = jsParam.optString("payCGI", "");
            Log.d(TAG, "setPayCGI: uid = "+uid+" channel = "+channel +" mtkey = "+mtkey+" skey = "+skey+" payCGI = "+payCGI);
            Security.setUid(uid);
            Security.setChannel(channel);
            Security.setmtkey(mtkey);
            Security.setskey(skey);
            Security.setPaymentUrl(payCGI);
//            初始化CheckoutManager,消费已发货订单
            AppActivity.initCheckoutManager();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void queryProduct(int key,String param){
        Log.d("StoreManager","public void queryProduct");
        queryProductkey = key;
        try {
            JSONObject jsParam = new JSONObject(param);
            JSONArray pids = jsParam.getJSONArray("pids");
            String playStorePublicKey = jsParam.optString("playStorePublicKey", "");
            List<String> items;
            items = new ArrayList<>();

            if (pids != null) {
                for (int i = 0; i < pids.length(); i++) {
                    items.add((String) pids.get(i));
                }
            }
            GoogleCheckoutHelper checkoutHelper = CheckoutManager.getInstance((Activity) AppActivity.getContext()).getCheckoutHelper();
            checkoutHelper.setPlayStorePublicKey(playStorePublicKey);
            checkoutHelper.queryInventoryAsync(true, items, null, queryInventoryFinishedListener);
        } catch (Exception e) {
            TreeMap<String, Object> map = new TreeMap<String, Object>();
            map.put("result", 0);
            JsonUtil json = new JsonUtil(map);
            LuaCallManager.callLua(queryProductkey, json.toString());
            e.printStackTrace();
        }

    }

    GoogleCheckoutHelper.QueryInventoryFinishedListener queryInventoryFinishedListener = new GoogleCheckoutHelper.QueryInventoryFinishedListener() {

        public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
            Log.d("test", "gwjgwj,onQueryInventoryFinished:" + result.isFailure() + "," + result.getResponse() + "," + result.getMessage());
            TreeMap<String, Object> map = new TreeMap<String, Object>();
            if (result.isFailure()) {
                map.put("result", 0);
                JsonUtil json = new JsonUtil(map);
                LuaCallManager.callLua(queryProductkey, json.toString());
            } else {
                map.put("result", 1);
                JsonUtil json = new JsonUtil(map);
                LuaCallManager.callLua(queryProductkey, json.toString());
            }
        }
    };

    public SkuDetails getSKuDetails(String sku) {
        GoogleCheckoutHelper checkoutHelper = CheckoutManager.getInstance((Activity) AppActivity.getContext()).getCheckoutHelper();
        Inventory inventory = checkoutHelper.getInventory();
        if(inventory !=null){
            return inventory.getSkuDetails(sku);
        }
        return null;
    }

    public void queryProductDetail(int key,String param) {
        try {
            JSONObject jsParam = new JSONObject(param);
            String pid = jsParam.optString("pid", "");
            SkuDetails skuDetails =getSKuDetails(pid);
            TreeMap<String, Object> map = new TreeMap<String, Object>();
//            LogUtil.d(TAG,"queryProductDetail "+skuDetails);
            if (skuDetails != null) {
                map.put("result", 1);
                map.put("_sku", skuDetails.getSku());
                map.put("_type", skuDetails.getType());
                map.put("_price", skuDetails.getPrice());
                map.put("_title", skuDetails.getTitle());
                map.put("_descr", skuDetails.getDescription());
//            map.toString()
            }else{
                map.put("result", 0);
            }
            JsonUtil json = new JsonUtil(map);
            LuaCallManager.callLua(key, json.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static void onPayResponse(String payStr) {
        LuaCallManager.callLua(mResponseKey, payStr);
    }
}
