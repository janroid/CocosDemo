package com.boyaa.entity.facebook;

import android.widget.Toast;

import com.boyaa.entity.luaManager.LuaCallManager;
import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.utils.LogUtil;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookAuthorizationException;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareOpenGraphAction;
import com.facebook.share.model.ShareOpenGraphContent;
import com.facebook.share.model.ShareOpenGraphObject;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.ShareDialog;
import com.facebook.share.Sharer.Result;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class FBManager {
    private static CallbackManager callbackManager;
    private int loginCallbackId;
    private int inviteCallbackId;
    private int shareCallbackId;
    private final static String TAG = "FBLoginManager";
    public void login(int callbackId, String params){
        loginCallbackId = callbackId;
        LoginManager.getInstance().logOut();
        init();
        LoginManager.getInstance().logInWithReadPermissions(AppActivity.getActivity(), Arrays.asList("public_profile"));
    }

    private void init(){
        if(null == callbackManager){
            callbackManager = CallbackManager.Factory.create();
        }
        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        if (null != loginResult){
                            AccessToken token = loginResult.getAccessToken();
                            if(null != token){
                                LogUtil.d(TAG, "onSuccess token:"+token.getToken());
                                HashMap<String, Object> map = new HashMap<>();
                                map.put("token", token.getToken());
                                map.put("expires", token.getExpires().getTime());
                                map.put("uid", token.getUserId());
                                map.put("result", 1);
                                onResult(loginCallbackId, new JsonUtil(map).toString());
                            }
                        }
                    }

                    @Override
                    public void onCancel() {
                        LogUtil.d(TAG, "onCancel");
                        HashMap<String, Object> map = new HashMap<>();
                        map.put("result", 0);
                        onResult(loginCallbackId, new JsonUtil(map).toString());
                    }

                    @Override
                    public void onError(FacebookException error) {
                        LogUtil.d(TAG, "onError:"+error.getMessage());
                        HashMap<String, Object> map = new HashMap<>();
                        map.put("error", error.toString());
                        map.put("result", -1);
                        onResult(loginCallbackId, new JsonUtil(map).toString());
                        if (error instanceof FacebookAuthorizationException) {
                            if (AccessToken.getCurrentAccessToken() != null) {
                                LoginManager.getInstance().logOut();
                            }
                        }
                    }
                });
    }

    public void invite(int key, String params){
        inviteCallbackId = key;
        String message = "";
        String data = "";
        try {
            JSONObject jo = new JSONObject(params);
            message = jo.optString("message");
            data = jo.optString("data");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if(null == callbackManager){
            callbackManager = CallbackManager.Factory.create();
        }
        GameRequestDialog requestDialog = new GameRequestDialog(AppActivity.getActivity());
        requestDialog.registerCallback(callbackManager, new FacebookCallback<GameRequestDialog.Result>() {

            @Override
            public void onSuccess(GameRequestDialog.Result result) {
                List<String> list = result.getRequestRecipients();
                StringBuilder value = new StringBuilder();
                int size = list.size();
                LogUtil.d("ReneYang", "invite onSuccess");
                if(size > 0 ){
                    value.append(list.get(0));
                    for(int i = 1; i < size; i++){
                        value.append(",").append(list.get(i));
                    }
                    HashMap<String, Object> map = new HashMap<>();
                    map.put("ids", value);
                    map.put("result", 1);
                    onResult(inviteCallbackId, new JsonUtil(map).toString());
//                    CallLuaUtil.call(HandMachine.kFBGameRequest, HandMachine.kCallSuccess, new String[]{"fbid","request"}, new Object[]{value,result.getRequestId()});
                }
                else{
                    HashMap<String, Object> map = new HashMap<>();
                    map.put("result", 2);
                    map.put("error", "failed");
                    onResult(inviteCallbackId, new JsonUtil(map).toString());
//                    CallLuaUtil.call(HandMachine.kFBGameRequest, HandMachine.kCallFailed, new String[]{"code"}, new Object[]{"failed"});
                }
            }

            @Override
            public void onCancel() {
                LogUtil.d("ReneYang", "invite cancel");
                HashMap<String, Object> map = new HashMap<>();
                map.put("result", 3);
                onResult(inviteCallbackId, new JsonUtil(map).toString());
//                CallLuaUtil.call(HandMachine.kFBGameRequest, HandMachine.kCallFailed, new String[]{"code"}, new Object[]{"cancel"});
            }

            @Override
            public void onError(FacebookException error) {
                LogUtil.d("ReneYang", "invite error");
                HashMap<String, Object> map = new HashMap<>();
                map.put("error", error.toString());
                map.put("result", 4);
                onResult(inviteCallbackId, new JsonUtil(map).toString());
//                CallLuaUtil.call(HandMachine.kFBGameRequest, HandMachine.kCallFailed, new String[]{"code"}, new Object[]{error.toString()});
            }

        });
        if (GameRequestDialog.canShow()) {
            GameRequestContent requestContent = new GameRequestContent.Builder()
                    .setMessage(message)
                    .setData(data)
                    .build();
            requestDialog.show(requestContent);
        }
        else{
            Toast.makeText(AppActivity.getActivity(), "fbGameRequest can not show", Toast.LENGTH_LONG).show();
        }
    }

    public static CallbackManager getFBCallbackManager(){
//        if(null == callbackManager){
//            callbackManager = CallbackManager.Factory.create();
//        }
        return callbackManager;
    }

    public void logout(int callbackId, String params){
        LoginManager.getInstance().logOut();
    }
    private void onResult(int callbackId, String result){
        LuaCallManager.callLua(callbackId, result);
    }

    private FacebookCallback<Result> shareCallback = new FacebookCallback<Result>() {

        @Override
        public void onSuccess(Result result) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("result", 1);
            onResult(shareCallbackId, new JsonUtil(map).toString());
        }

        @Override
        public void onCancel() {
            HashMap<String, Object> map = new HashMap<>();
            map.put("result", 3);
            onResult(shareCallbackId, new JsonUtil(map).toString());
        }

        @Override
        public void onError(FacebookException error) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("result", 4);
            map.put("error", error.getMessage());
            onResult(shareCallbackId, new JsonUtil(map).toString());
        }

    };

    /**
     * 显示分享对话框
     * */
    public void share(int callbackId, String params) {
        shareCallbackId = callbackId;
        if(null == callbackManager){
            callbackManager = CallbackManager.Factory.create();
        }
        String title = "";
        String message = "";
        String picture = "";
        String link = "";
        JSONObject jo = null;
        try {
            jo = new JSONObject(params);
            title = jo.optString("name");
            message = jo.optString("message");
            picture = jo.optString("picture");
            link = jo.optString("link");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        ShareDialog shareDialog = new ShareDialog(AppActivity.getActivity());
        shareDialog.registerCallback(callbackManager, shareCallback);

        ShareOpenGraphObject object = new ShareOpenGraphObject.Builder()
                .putString("og:type", "game")
                .putString("og:title", title)
                .putString("og:description", message)
                .putString("og:image", picture)
                .putString("og:url", link)
                .build();

        ShareOpenGraphAction action = new ShareOpenGraphAction.Builder()
                .setActionType("games.saves")
                .putObject("game", object)
                .build();

        ShareOpenGraphContent content = new ShareOpenGraphContent.Builder()
                .setPreviewPropertyName("game")
                .setAction(action)
                .build();

        ShareDialog.show(AppActivity.getActivity(), content);
    }

}
