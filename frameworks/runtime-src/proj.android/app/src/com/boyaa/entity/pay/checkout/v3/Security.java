package com.boyaa.entity.pay.checkout.v3;

import android.annotation.SuppressLint;
import android.content.pm.PackageInfo;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.entity.http.URLEncodedUtils;
import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.pay.checkout.PayConstants;
import com.boyaa.entity.php.PHPPost;
import com.boyaa.entity.php.PHPResult;
import com.boyaa.entity.utils.Base64;
import com.boyaa.entity.utils.Base64DecoderException;
import com.boyaa.entity.utils.JsonUtil;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.Signature;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.TreeMap;

/**
 * Created by MaxizMa on 2015/5/12.
 */
public class Security {
    private static final String TAG = "Checkout";
    private static final String KEY_FACTORY_ALGORITHM = "RSA";
    private static final String SIGNATURE_ALGORITHM = "SHA1withRSA";
    public static String[] price = {"",""};
    public static String paymentUrl = "https://pclpthik01-static.boyaagame.com/api/pay/androidpay.php?sid=11";
    public static String skey = "";
    public static String mtkey = "";
    public static String m_uid = "";
    public static String m_channel = "";

    @SuppressLint("NewApi")
    public static boolean verifyPurchase(String signedData, String signature) {
        try {
            Log.d(TAG, "PHP verifyPurchase");
            JSONObject jsParam = new JSONObject(signedData);
            String productId = jsParam.optString("productId", "");
            String developerPayload = jsParam.optString("developerPayload", "");

            PackageInfo pi= AppActivity.getContext().getPackageManager().getPackageInfo(AppActivity.getContext().getPackageName(), 0);
            String versionName = pi.versionName;
            PHPResult phpResult = new PHPResult();
            PHPPost post = new PHPPost();
            HashMap<String, String> params = new HashMap<String, String>();
            params.put("signature", signature);
            params.put("mod","pay");
            params.put("act","delivery");
            params.put("api","v3");
            params.put("uid",m_uid);
            params.put("channel",m_channel);
            params.put("mtkey",mtkey);
            params.put("skey",skey);
            params.put("receipt",signedData);
            params.put("version",versionName);
            params.put("orderData",developerPayload);
            Log.d("PHPResult","paymentUrl = "+paymentUrl+"param = "+params);
            post.postURL(
                    paymentUrl,
                    phpResult,
                    params,
                    GoogleCheckoutHelper.Payment_getUserPayment_TIMEOUT);
            Log.d(TAG,params.toString());
            if (phpResult.code == PHPResult.SUCCESS) {
                /** 解析发货信息 */
                Log.d(TAG, "PHP verifyPurchase json:" + phpResult.json);
                JSONObject jsonResult = new JSONObject(phpResult.json);
                int retId = jsonResult.getInt("ret");
                Log.d(TAG,"ret = "+retId);
                if (retId == 0) {
                    return true;
                }
            }
        }catch (Exception e){
            e.printStackTrace();
        }

        return false;
    }
    /**
     * Verifies that the data was signed with the given signature, and returns
     * the verified purchase. The data is in JSON format and signed
     * with a private key. The data also contains the {@link }
     * and product ID of the purchase.
     * @param base64PublicKey the base64-encoded public key to use for verifying.
     * @param signedData the signed JSON string (signed, not encrypted)
     * @param signature the signature for the data, signed with the private key
     */
    public static boolean verifyPurchase(String base64PublicKey, String signedData, String signature) {
        if (TextUtils.isEmpty(signedData) || TextUtils.isEmpty(base64PublicKey) ||
                TextUtils.isEmpty(signature)) {
            Log.e(TAG, "Purchase verification failed: missing data.");
            return false;
        }

        PublicKey key = Security.generatePublicKey(base64PublicKey);
        return Security.verify(key, signedData, signature);
    }

    /**
     * Generates a PublicKey instance from a string containing the
     * Base64-encoded public key.
     *
     * @param encodedPublicKey Base64-encoded public key
     * @throws IllegalArgumentException if encodedPublicKey is invalid
     */
    public static PublicKey generatePublicKey(String encodedPublicKey) {
        try {
            byte[] decodedKey = Base64.decode(encodedPublicKey);
            KeyFactory keyFactory = KeyFactory.getInstance(KEY_FACTORY_ALGORITHM);
            return keyFactory.generatePublic(new X509EncodedKeySpec(decodedKey));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        } catch (InvalidKeySpecException e) {
            Log.e(TAG, "Invalid key specification.");
            throw new IllegalArgumentException(e);
        } catch (Exception e) {
            Log.e(TAG, "Base64 decoding failed.");
            throw new IllegalArgumentException(e);
        }
    }

    /**
     * Verifies that the signature from the server matches the computed
     * signature on the data.  Returns true if the data is correctly signed.
     *
     * @param publicKey public key associated with the developer account
     * @param signedData signed data from server
     * @param signature server signature
     * @return true if the data and signature match
     */
    public static boolean verify(PublicKey publicKey, String signedData, String signature) {
        Signature sig;
        try {
            sig = Signature.getInstance(SIGNATURE_ALGORITHM);
            sig.initVerify(publicKey);
            sig.update(signedData.getBytes());
            if (!sig.verify(Base64.decode(signature))) {
                Log.e(TAG, "Signature verification failed.");
                return false;
            }
            return true;
        } catch (NoSuchAlgorithmException e) {
            Log.e(TAG, "NoSuchAlgorithmException.");
        } catch (InvalidKeyException e) {
            Log.e(TAG, "Invalid key specification.");
        } catch (SignatureException e) {
            Log.e(TAG, "Signature exception.");
        } catch (Base64DecoderException e) {
            Log.e(TAG, "Base64 decoding failed.");
        }
        return false;
    }

    public static void setPaymentUrl(String url){
        paymentUrl = url;
        Log.d(TAG, "setPaymentUrl: "+paymentUrl);
    }

    public static void setUid(String uid){
        m_uid = uid;
    }

    public static void setChannel(String channel){
        m_channel = channel;
    }

    public static void setmtkey(String mtkey) {
        Security.mtkey = mtkey;
    }

    public static void setskey(String skey) {
        Security.skey = skey;
    }
}
