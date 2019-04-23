package com.boyaa.entity.pay.checkout.v3;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.android.vending.billing.IInAppBillingService;
import com.boyaa.entity.pay.PurchaseFinishedListener;
import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.entity.utils.LogUtil;
import com.boyaa.ipoker.R;

import org.json.JSONException;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by MaxizMa on 2015/5/12.
 * checkout官方文档地址：https://developer.android.com/google/play/billing/api.html
 */
public class GoogleCheckoutHelper {
    public static final int REQUEST_CODE = 5201314;
    private static final String TAG = "Checkout";
    public static String checkout_pay_order = "http://pay.boyaa.com/checkout_pay_order.php";// checkout发货地址
    public static final int Payment_getUserPayment_TIMEOUT = 15 * 1000;

    // Is an asynchronous operation in progress?
    // (only one at a time can be in progress)
    boolean mAsyncInProgress = false;

    // (for logging/debugging)
    // if mAsyncInProgress == true, what asynchronous operation is in progress?
    String mAsyncOperation = "";

    // Are subscriptions supported?
    boolean mSubscriptionsSupported = false;

    // Public key for verifying signature, in base64 encoding
    String mSignatureBase64 = null;

    // Billing response codes
    //0	成功
    public static final int BILLING_RESPONSE_RESULT_OK = 0;
    //	成功
    public static final int BILLING_RESPONSE_RESULT_SUCCESS = 1;
    //用户按下了“返回”或者取消了对话
    public static final int BILLING_RESPONSE_RESULT_USER_CANCELED = 2;
    //Billing API 版本不受所请求类型的支持
    public static final int BILLING_RESPONSE_RESULT_BILLING_UNAVAILABLE = 3;
    //请求的商品不可以购买
    public static final int BILLING_RESPONSE_RESULT_ITEM_UNAVAILABLE = 4;
    //向 API 提供的参数无效。此错误也可能说明应用未在 Google Play中针对应用内购买结算正确签署或设置，或者在清单中没有所需的权限
    public static final int BILLING_RESPONSE_RESULT_DEVELOPER_ERROR = 5;
    //API 操作期间发生致命错误
    public static final int BILLING_RESPONSE_RESULT_ERROR = 6;
    //由于已经拥有该商品，购买失败
    public static final int BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED = 7;
    //由于未拥有该商品，消耗失败
    public static final int BILLING_RESPONSE_RESULT_ITEM_NOT_OWNED = 8;
    public static final int BILLING_RESPONSE_RESULT_VERIFY_FAILED = 9;

    public static final int IABHELPER_ERROR_BASE = -1000;
    public static final int IABHELPER_REMOTE_EXCEPTION = -1001;
    public static final int IABHELPER_BAD_RESPONSE = -1002;
    public static final int IABHELPER_VERIFICATION_FAILED = -1003;
    public static final int IABHELPER_SEND_INTENT_FAILED = -1004;
    public static final int IABHELPER_USER_CANCELLED = -1005;
    public static final int IABHELPER_UNKNOWN_PURCHASE_RESPONSE = -1006;
    public static final int IABHELPER_MISSING_TOKEN = -1007;
    public static final int IABHELPER_UNKNOWN_ERROR = -1008;
    public static final int IABHELPER_SUBSCRIPTIONS_NOT_AVAILABLE = -1009;
    public static final int IABHELPER_INVALID_CONSUMPTION = -1010;

    //取舍字段
    private static final String RESPONSE_CODE = "RESPONSE_CODE";
    private static final String RESPONSE_INAPP_ITEM_LIST = "INAPP_PURCHASE_ITEM_LIST";
    private static final String RESPONSE_INAPP_PURCHASE_DATA_LIST = "INAPP_PURCHASE_DATA_LIST";
    private static final String RESPONSE_INAPP_SIGNATURE_LIST = "INAPP_DATA_SIGNATURE_LIST";
    private static final String INAPP_CONTINUATION_TOKEN = "INAPP_CONTINUATION_TOKEN";

    // Keys for the responses from InAppBillingService
    public static final String RESPONSE_GET_SKU_DETAILS_LIST = "DETAILS_LIST";
    public static final String RESPONSE_BUY_INTENT = "BUY_INTENT";
    public static final String RESPONSE_INAPP_PURCHASE_DATA = "INAPP_PURCHASE_DATA";
    public static final String RESPONSE_INAPP_SIGNATURE = "INAPP_DATA_SIGNATURE";
    public static final String GET_SKU_DETAILS_ITEM_LIST = "ITEM_ID_LIST";

    public static final String ITEM_TYPE_INAPP = "inapp";
    public static final String ITEM_TYPE_SUBS = "subs";

    private PurchaseFinishedListener mMyPurchaseFinishedListener;

    private Activity mContext;
    private IabResult iabResult;
    private Inventory inventory;

    public GoogleCheckoutHelper(Activity mContext) {
        this(mContext, null);
    }

    public GoogleCheckoutHelper(Activity mContext, PurchaseFinishedListener listener) {
        this.mContext = mContext;
        mMyPurchaseFinishedListener = listener;
    }

    public void setPurchaseFinishedListener(PurchaseFinishedListener listener) {
        mMyPurchaseFinishedListener = listener;
    }

    public void onCreate() {
        bindService();
    }

    public void onDestroy() {
        isConnected = false;
        if (mServiceConn != null) {
            if (mContext != null) mContext.unbindService(mServiceConn);
            mServiceConn = null;
            mService = null;
            mMyPurchaseFinishedListener = null;
        }
    }

    public boolean isBillingSupported() {
        return isConnected;
    }

    // Connection to the service
    private IInAppBillingService mService;
    private ServiceConnection mServiceConn;
    private boolean isConnected;

    private void bindService() {
        if (isConnected) return;
        mServiceConn = new ServiceConnection() {
            @Override
            public void onServiceDisconnected(ComponentName name) {
                Log.d(TAG, "Billing service disconnected.");
                mService = null;
            }

            @Override
            public void onServiceConnected(ComponentName name, IBinder service) {
                Log.d(TAG, "Billing service connected.");
                mService = IInAppBillingService.Stub.asInterface(service);
                String packageName = mContext.getPackageName();
                try {
                    Log.d(TAG, "Checking for in-app billing v3 support.");
                    int response = mService.isBillingSupported(3, packageName, ITEM_TYPE_INAPP);
                    if (response != BILLING_RESPONSE_RESULT_OK) {
                        Log.d(TAG, "Error checking for billing v3 support.");
                        return;
                    }
                    isConnected = true;
                    Log.d(TAG, "In-app billing v3 supported for " + packageName);
                    response = mService.isBillingSupported(3, packageName, ITEM_TYPE_SUBS);
                    if (response == BILLING_RESPONSE_RESULT_OK) {
                        LogUtil.d(TAG,"Subscriptions AVAILABLE.");
                        mSubscriptionsSupported = true;
                    }
                    else {
                        LogUtil.d(TAG,"Subscriptions NOT AVAILABLE. Response: " + response);
                    }
                    new Thread() {
                        public void run() {
                            consumeAll();//处理未消费订单
                        }
                    }.start();
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        };
        Intent intent = new Intent("com.android.vending.billing.InAppBillingService.BIND");
        intent.setPackage("com.android.vending");

        mContext.bindService(intent, mServiceConn, Context.BIND_AUTO_CREATE);

    }


    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult");
        if (requestCode != REQUEST_CODE) {
            Log.d(TAG, "Request Code is incorrect");
            return;
        }
        if (data == null) {
            Log.d(TAG, "Data intent is null");
            return;
        }

        int responseCode = getResponseCodeFromIntent(data);
        if (resultCode == Activity.RESULT_OK && responseCode == BILLING_RESPONSE_RESULT_OK) {
            final String purchaseData = data.getStringExtra("INAPP_PURCHASE_DATA");
            final String dataSignature = data.getStringExtra("INAPP_DATA_SIGNATURE");
            Log.d(TAG, "Purchase data: " + purchaseData);
            Log.d(TAG, "Data signature: " + dataSignature);
            if (purchaseData == null || dataSignature == null) {
                return;
            }
            ThreadTask.start(mContext, "requesting", false, new OnThreadTask() {

                @Override
                public void onThreadRun() {
                    final boolean result = Security.verifyPurchase(purchaseData, dataSignature);
                    if (result) {
                        Log.d(TAG, "Purchase successed: PHP verify purchase is OK");
                        try {
                            consume(new Purchase(ITEM_TYPE_INAPP,purchaseData, dataSignature));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    } else {
                        Log.d(TAG, "Purchase successed: PHP verify purchase failed");
                    }
                    if (mContext != null) {
                        mContext.runOnUiThread(new Runnable() {
                            public void run() {
                                if (result) {
                                    if (mMyPurchaseFinishedListener != null) {
                                        mMyPurchaseFinishedListener.onPurchaseFinished(BILLING_RESPONSE_RESULT_SUCCESS, mOrderId, mPayMoney, mCurrencyCode);
                                    }
                                } else {
                                    if (mMyPurchaseFinishedListener != null) {
                                        mMyPurchaseFinishedListener.onPurchaseFinished(BILLING_RESPONSE_RESULT_VERIFY_FAILED, mOrderId, mPayMoney, mCurrencyCode);
                                    }
                                }
                            }
                        });
                    }
                }

                @Override
                public void onAfterUIRun() {
//                    Log.i("result.code", "result.code:" + result.code + ", json = " + result.json);
                }

                @Override
                public void onUIBackPressed() {

                }
            });
        } else if (resultCode == Activity.RESULT_OK) {
            Log.d(TAG, "Purchase failed: Result code was OK but in-app billing response was not OK");
        } else if (resultCode == Activity.RESULT_CANCELED) {
            Log.d(TAG, "Purchase failed: User canceled");
            if (mMyPurchaseFinishedListener != null) {
                mMyPurchaseFinishedListener.onPurchaseFinished(BILLING_RESPONSE_RESULT_USER_CANCELED,mOrderId, mPayMoney, mCurrencyCode);
            }
        } else {
            Log.d(TAG, "Purchase failed: Unknown error");
        }
    }

    private String mProductId;
    private String mPayMoney;
    private String mCurrencyCode;
    private String mOrderId;

    @SuppressLint("NewApi")
    public void requestPurchase(String productId, String orderId, String payMoney, String currencyCode) {
        this.mProductId = productId;
        this.mPayMoney = payMoney;
        this.mCurrencyCode = currencyCode;
        this.mOrderId = orderId;
        if (!isConnected) {
            if (mMyPurchaseFinishedListener != null) {
                mMyPurchaseFinishedListener.onPurchaseFinished(BILLING_RESPONSE_RESULT_BILLING_UNAVAILABLE,mOrderId, mPayMoney, mCurrencyCode);
            }
            mContext.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(mContext, mContext.getString(R.string.sorry_checkoutpay), Toast.LENGTH_LONG).show();
                }
            });

            return;
        }
        if (TextUtils.isEmpty(productId) || TextUtils.isEmpty(orderId)) {
            Log.d(TAG, "Product id:" + productId + " Order id:" + orderId);
            if (mMyPurchaseFinishedListener != null) {
                mMyPurchaseFinishedListener.onPurchaseFinished(BILLING_RESPONSE_RESULT_DEVELOPER_ERROR,mOrderId, mPayMoney, mCurrencyCode);
            }
            return;
        }
        try {
            if (mService == null) {
                return;
            }
//            int apiVersion, java.lang.String packageName, java.lang.String sku, java.lang.String type, java.lang.String developerPayload)
            Bundle buyIntentBundle = mService.getBuyIntent(3, mContext.getPackageName(), productId, ITEM_TYPE_INAPP, orderId);
            int response = getResponseCodeFromBundle(buyIntentBundle);
            if (response != BILLING_RESPONSE_RESULT_OK) {
                new Thread() {
                    public void run() {
                        consumeAll();//处理未消费订单
                    }
                }.start();
                if (mMyPurchaseFinishedListener != null)
                    mMyPurchaseFinishedListener.onPurchaseFinished(BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED,mOrderId, mPayMoney, mCurrencyCode);
                mContext.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(mContext, mContext.getString(R.string.pay_checkout_hint), Toast.LENGTH_LONG).show();
                    }
                });
                return;
            }

            Log.d(TAG, "Request purchase with productId:" + productId + " orderId:" + orderId);
            PendingIntent pendingIntent = buyIntentBundle.getParcelable("BUY_INTENT");
            mContext.startIntentSenderForResult(pendingIntent.getIntentSender(),
                    REQUEST_CODE, new Intent(),
                    Integer.valueOf(0), Integer.valueOf(0),
                    Integer.valueOf(0));
        } catch (IntentSender.SendIntentException e) {
            e.printStackTrace();
            if (mMyPurchaseFinishedListener != null)
                mMyPurchaseFinishedListener.onPurchaseFinished(IABHELPER_SEND_INTENT_FAILED,mOrderId, mPayMoney, mCurrencyCode);
        } catch (RemoteException e1) {
            e1.printStackTrace();
            if (mMyPurchaseFinishedListener != null)
                mMyPurchaseFinishedListener.onPurchaseFinished(IABHELPER_REMOTE_EXCEPTION, mOrderId, mPayMoney, mCurrencyCode);
        }
    }

    /**
     * 消费订单
     * 目的：通知Google Play已经发货
     **/
    private void consume(Purchase purchase) {
        Log.d(TAG, "Consume");
        String token = purchase.getToken();
        String productId = purchase.getSku();
        if (TextUtils.isEmpty(token) || TextUtils.isEmpty(productId)) {
            Log.d(TAG, "Consume Failed: token and productId may be null");
            return;
        }
        try {
//			Thread.sleep(10000);//测试用
            if (mService != null && mContext != null) {
                int response = mService.consumePurchase(3, mContext.getPackageName(), token);
                if (response == BILLING_RESPONSE_RESULT_OK) {
                    Log.d(TAG, "Consume Successed with productId: " + productId);
                } else {
                    Log.d(TAG, "Consume Failed: " + productId);
                }
            } else {
                Log.d(TAG, "Consume Failed: BillingService is null");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private int getResponseCodeFromBundle(Bundle b) {
        Object o = b.get(RESPONSE_CODE);
        if (o == null) {
            Log.d(TAG, "Bundle with null response code, assuming OK (known issue)");
            return BILLING_RESPONSE_RESULT_OK;
        } else if (o instanceof Integer) return ((Integer) o).intValue();
        else if (o instanceof Long) return (int) ((Long) o).longValue();
        else {
            Log.d(TAG, "Unexpected type for bundle response code.");
            return BILLING_RESPONSE_RESULT_ERROR;
        }
    }

    private int getResponseCodeFromIntent(Intent i) {
        Object o = i.getExtras().get(RESPONSE_CODE);
        if (o == null) {
            Log.d(TAG, "Response code is null");
            return BILLING_RESPONSE_RESULT_OK;
        } else if (o instanceof Integer) return ((Integer) o).intValue();
        else if (o instanceof Long) return (int) ((Long) o).longValue();
        else {
            Log.d(TAG, "Unexpected type for intent response code.");
            return BILLING_RESPONSE_RESULT_ERROR;
        }
    }

    /**
     * 处理所有未消费商品（已付款且未发货）
     */
    private void consumeAll() {
        String continueToken = null;
        if (mService == null) {
            return;
        }
        do {
            Log.d(TAG, "Calling getPurchases with continuation token: " + continueToken);
            Bundle ownedItems = null;
            try {
                ownedItems = mService.getPurchases(3, mContext.getPackageName(), ITEM_TYPE_INAPP, continueToken);
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (ownedItems == null) return;

            int response = getResponseCodeFromBundle(ownedItems);
            Log.d(TAG, "Owned items response: " + String.valueOf(response));
            if (response != BILLING_RESPONSE_RESULT_OK) {
                Log.d(TAG, "getPurchases() failed");
                return;
            }
            if (!ownedItems.containsKey(RESPONSE_INAPP_ITEM_LIST)
                    || !ownedItems.containsKey(RESPONSE_INAPP_PURCHASE_DATA_LIST)
                    || !ownedItems.containsKey(RESPONSE_INAPP_SIGNATURE_LIST)) {
                Log.d(TAG, "Bundle returned from getPurchases() doesn't contain required fields.");
                return;
            }

            ArrayList<String> ownedSkus = ownedItems.getStringArrayList(RESPONSE_INAPP_ITEM_LIST);
            ArrayList<String> purchaseDataList = ownedItems.getStringArrayList(RESPONSE_INAPP_PURCHASE_DATA_LIST);
            ArrayList<String> signatureList = ownedItems.getStringArrayList(RESPONSE_INAPP_SIGNATURE_LIST);

            if (purchaseDataList != null) {
                for (int i = 0; i < purchaseDataList.size(); i++) {
                    String purchaseData = purchaseDataList.get(i);
                    String signature = null;
                    if (signatureList != null) {
                        signature = signatureList.get(i);
                    }
                    String sku = ownedSkus != null ? ownedSkus.get(i) : null;
                    if (Security.verifyPurchase(purchaseData, signature)) {
                        try {
                            consume(new Purchase(ITEM_TYPE_INAPP,purchaseData, signature));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    } else {
                        Log.d(TAG, "Purchase signature verification **FAILED**. with product id " + sku);
                        Log.d(TAG, "   Purchase data: " + purchaseData);
                        Log.d(TAG, "   Signature: " + signature);
                    }
                }
            }

            continueToken = ownedItems.getString(INAPP_CONTINUATION_TOKEN);
            Log.d(TAG, "Continuation token: " + continueToken);
        } while (!TextUtils.isEmpty(continueToken));
    }

    /**
     * Asynchronous wrapper for inventory query. This will perform an inventory
     * query as described in {@link #queryInventory}, but will do so asynchronously
     * and call back the specified listener upon completion. This method is safe to
     * call from a UI thread.
     *
     * @param querySkuDetails as in {@link #queryInventory}
     * @param moreItemSkus as in {@link #queryInventory} //pozirk
     * @param moreSubsSkus as in {@link #queryInventory} //pozirk
     * @param listener The listener to notify when the refresh operation completes.
     */
    public void queryInventoryAsync(final boolean querySkuDetails,
                                    final List<String> moreItemSkus, //pozirk: yeah, it was very hard to make the support of subscriptions
                                    final List<String> moreSubsSkus, //pozirk
                                    final QueryInventoryFinishedListener listener) {
        iabResult = null;
        inventory = null;
        if (!isConnected) {
            IabResult result = new IabResult(BILLING_RESPONSE_RESULT_DEVELOPER_ERROR, "Inventory refresh failer.");
            if (listener != null) {
                listener.onQueryInventoryFinished(result, inventory);
            }
            return;
        }
        flagStartAsync("refresh inventory");
        IabResult result = new IabResult(BILLING_RESPONSE_RESULT_OK, "Inventory refresh successful.");
        Inventory inv = null;
        try {
            inv = queryInventory(querySkuDetails, moreItemSkus, moreSubsSkus);  //pozirk
        }
        catch (IabException ex) {
            result = ex.getResult();
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        flagEndAsync();

        iabResult = result;
        inventory = inv;
        if (listener != null) {
            listener.onQueryInventoryFinished(iabResult, inventory);
        }
    }

    /**
     * Queries the inventory. This will query all owned items from the server, as well as
     * information on additional skus, if specified. This method may block or take long to execute.
     * Do not call from a UI thread. For that, use the non-blocking version {@link #refreshInventoryAsync}.
     *
     * @param querySkuDetails if true, SKU details (price, description, etc) will be queried as well
     *     as purchase information.
     * @param moreItemSkus additional PRODUCT skus to query information on, regardless of ownership.
     *     Ignored if null or if querySkuDetails is false.
     * @param moreSubsSkus additional SUBSCRIPTIONS skus to query information on, regardless of ownership.
     *     Ignored if null or if querySkuDetails is false.
     * @throws IabException if a problem occurs while refreshing the inventory.
     */
    public Inventory queryInventory(boolean querySkuDetails, List<String> moreItemSkus,
                                    List<String> moreSubsSkus) throws IabException {
//        checkNotDisposed();
//        checkSetupDone("queryInventory");
        if (!isConnected) return null;
        try {
            Inventory inv = new Inventory();
            int r = queryPurchases(inv, ITEM_TYPE_INAPP);
//            if (r != BILLING_RESPONSE_RESULT_OK) {
//                throw new IabException(r, "Error refreshing inventory (querying owned items).");
//            }

            if (querySkuDetails) {
                r = querySkuDetails(ITEM_TYPE_INAPP, inv, moreItemSkus);
                if (r != BILLING_RESPONSE_RESULT_OK) {
                    throw new IabException(r, "Error refreshing inventory (querying prices of items).");
                }
            }

            // if subscriptions are supported, then also query for subscriptions
            if (mSubscriptionsSupported) {
//                r = queryPurchases(inv, ITEM_TYPE_SUBS);
//                if (r != BILLING_RESPONSE_RESULT_OK) {
//                    throw new IabException(r, "Error refreshing inventory (querying owned subscriptions).");
//                }

                if (querySkuDetails) {
                    r = querySkuDetails(ITEM_TYPE_SUBS, inv, moreSubsSkus); //pozirk: was moreItemSkus before
                    if (r != BILLING_RESPONSE_RESULT_OK) {
                        throw new IabException(r, "Error refreshing inventory (querying prices of subscriptions).");
                    }
                }
            }

            return inv;
        }
        catch (RemoteException e) {
            throw new IabException(IABHELPER_REMOTE_EXCEPTION, "Remote exception while refreshing inventory.", e);
        }
        catch (JSONException e) {
            throw new IabException(IABHELPER_BAD_RESPONSE, "Error parsing JSON response while refreshing inventory.", e);
        }
    }

    int querySkuDetails(String itemType, Inventory inv, List<String> moreSkus)
            throws RemoteException, JSONException {
        LogUtil.d(TAG,"Querying SKU details.");
        ArrayList<String> skuList = new ArrayList<String>();
        skuList.addAll(inv.getAllOwnedSkus(itemType));
        if (moreSkus != null) {
            for (String sku : moreSkus) {
                if (!skuList.contains(sku)) {
                    skuList.add(sku);
                }
            }
        }

        if (skuList.size() == 0) {
            LogUtil.d(TAG,"queryPrices: nothing to do because there are no SKUs.");
            return BILLING_RESPONSE_RESULT_OK;
        }

        if(mContext == null)
        {
            return BILLING_RESPONSE_RESULT_ERROR;
        }

        //Split the sku list in blocks of no more than 20 elements.
        //see: http://stackoverflow.com/questions/18580412/android-queryinventoryasync-bug-or-not
        //     https://code.google.com/p/marketbilling/issues/detail?id=123
        ArrayList<ArrayList<String>> packs = new ArrayList<ArrayList<String>>();
        ArrayList<String> tempList = null;
        final int max = 20;
        int i;
        for(i = 0; i < skuList.size(); ++i)
        {
            if(i % max == 0)
            {
                tempList = new ArrayList<String>();
            }
            tempList.add(skuList.get(i));
            if((i+1) % max == 0)
            {
                packs.add(tempList);
            }
        }
        if(i % max != 0)
            packs.add(tempList);

        for(ArrayList<String> skuPartList : packs)
        {
            Log.d("test", "gwjgwj,pack,num=" + skuPartList.size());
            Bundle querySkus = new Bundle();
            querySkus.putStringArrayList(GET_SKU_DETAILS_ITEM_LIST, skuPartList);
            Bundle skuDetails = mService.getSkuDetails(3, mContext.getPackageName(),
                    itemType, querySkus);

            if (!skuDetails.containsKey(RESPONSE_GET_SKU_DETAILS_LIST)) {
                int response = getResponseCodeFromBundle(skuDetails);
                if (response != BILLING_RESPONSE_RESULT_OK) {
//                    LogUtil.d(TAG,"getSkuDetails() failed: " + getResponseDesc(response));
                    return response;
                }
                else {
                    LogUtil.e(TAG,"getSkuDetails() returned a bundle with neither an error nor a detail list.");
                    return IABHELPER_BAD_RESPONSE;
                }
            }

            ArrayList<String> responseList = skuDetails.getStringArrayList(
                    RESPONSE_GET_SKU_DETAILS_LIST);

            for (String thisResponse : responseList) {
                SkuDetails d = new SkuDetails(itemType, thisResponse);
                LogUtil.d(TAG,"Got sku details: " + d);
                inv.addSkuDetails(d);
            }
        }
        return BILLING_RESPONSE_RESULT_OK;
    }

    int queryPurchases(Inventory inv, String itemType) throws JSONException, RemoteException{
        if(mContext == null || mService == null)
            return IABHELPER_VERIFICATION_FAILED;
        boolean verificationFailed = false;
        String continueToken = null;
        do {

            Bundle ownedItems = mService.getPurchases(3, mContext.getPackageName(),
                    ITEM_TYPE_INAPP, continueToken);
//            LogUtil.d("Calling getPurchases with continuation token: " , continueToken);
            int response = getResponseCodeFromBundle(ownedItems);
            LogUtil.d("Owned items response: " , String.valueOf(response));
            if (response != BILLING_RESPONSE_RESULT_OK) {
                LogUtil.d("getPurchases() failed: " , getResponseDesc(response));
                return response;
            }
            if (!ownedItems.containsKey(RESPONSE_INAPP_ITEM_LIST)
                    || !ownedItems.containsKey(RESPONSE_INAPP_PURCHASE_DATA_LIST)
                    || !ownedItems.containsKey(RESPONSE_INAPP_SIGNATURE_LIST)) {
                LogUtil.e("","Bundle returned from getPurchases() doesn't contain required fields.");
                return IABHELPER_BAD_RESPONSE;
            }

            ArrayList<String> ownedSkus = ownedItems.getStringArrayList(
                    RESPONSE_INAPP_ITEM_LIST);
            ArrayList<String> purchaseDataList = ownedItems.getStringArrayList(
                    RESPONSE_INAPP_PURCHASE_DATA_LIST);
            ArrayList<String> signatureList = ownedItems.getStringArrayList(
                    RESPONSE_INAPP_SIGNATURE_LIST);

            for (int i = 0; i < purchaseDataList.size(); ++i) {
                String purchaseData = purchaseDataList.get(i);
                String signature = signatureList.get(i);
                String sku = ownedSkus.get(i);
                if (Security.verifyPurchase(mSignatureBase64, purchaseData, signature)) {
                    LogUtil.d("Sku is owned: " , sku);
                    Purchase purchase = new Purchase(ITEM_TYPE_INAPP,purchaseData, signature);

                    if (TextUtils.isEmpty(purchase.getToken())) {
                        LogUtil.w("","BUG: empty/null token!");
                        LogUtil.d("Purchase data: ", purchaseData);
                    }

                    // Record ownership and token
                    inv.addPurchase(purchase);
                }
                else {
                    LogUtil.w(TAG,"Purchase signature verification **FAILED**. Not adding item.");
                    LogUtil.d(TAG,"   Purchase data: " + purchaseData);
                    LogUtil.d(TAG,"   Signature: " + signature);
                    verificationFailed = true;
                }
            }

            continueToken = ownedItems.getString(INAPP_CONTINUATION_TOKEN);
            LogUtil.d(TAG,"Continuation token: " + continueToken);
        } while (!TextUtils.isEmpty(continueToken));
        return verificationFailed ? IABHELPER_VERIFICATION_FAILED : BILLING_RESPONSE_RESULT_OK;
    }

    /**
     * Returns a human-readable description for the given response code.
     *
     * @param code The response code
     * @return A human-readable string explaining the result code.
     *     It also includes the result code numerically.
     */
    public static String getResponseDesc(int code) {
        String[] iab_msgs = ("0:OK/1:User Canceled/2:Unknown/" +
                "3:Billing Unavailable/4:Item unavailable/" +
                "5:Developer Error/6:Error/7:Item Already Owned/" +
                "8:Item not owned").split("/");
        String[] iabhelper_msgs = ("0:OK/-1001:Remote exception during initialization/" +
                "-1002:Bad response received/" +
                "-1003:Purchase signature verification failed/" +
                "-1004:Send intent failed/" +
                "-1005:User cancelled/" +
                "-1006:Unknown purchase response/" +
                "-1007:Missing token/" +
                "-1008:Unknown error/" +
                "-1009:Subscriptions not available/" +
                "-1010:Invalid consumption attempt").split("/");

        if (code <= IABHELPER_ERROR_BASE) {
            int index = IABHELPER_ERROR_BASE - code;
            if (index >= 0 && index < iabhelper_msgs.length) return iabhelper_msgs[index];
            else return String.valueOf(code) + ":Unknown IAB Helper Error";
        }
        else if (code < 0 || code >= iab_msgs.length)
            return String.valueOf(code) + ":Unknown";
        else
            return iab_msgs[code];
    }

    void flagStartAsync(String operation) {
        if (mAsyncInProgress) throw new IllegalStateException("Can't start async operation (" +
                operation + ") because another async operation(" + mAsyncOperation + ") is in progress.");



        mAsyncOperation = operation;
        mAsyncInProgress = true;
        LogUtil.d(TAG,"Starting async operation: " + operation);
    }

    public void flagEndAsync() {
        LogUtil.d(TAG,"Ending async operation: " + mAsyncOperation);
        mAsyncOperation = "";
        mAsyncInProgress = false;
    }

    /**
     * Listener that notifies when an inventory query operation completes.
     */
    public interface QueryInventoryFinishedListener {
        /**
         * Called to notify that an inventory query operation completed.
         *
         * @param result The result of the operation.
         * @param inv The inventory.
         */
        void onQueryInventoryFinished(IabResult result, Inventory inv);
    }

    public void setPlayStorePublicKey(String playStorePublicKey) {
//     playStorePublicKey
        mSignatureBase64 = playStorePublicKey;
    }

    public Inventory getInventory(){
        return inventory;
    }




}
