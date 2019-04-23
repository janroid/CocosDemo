/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.facebook.FBManager;
import com.boyaa.entity.file.FileUtil;
import com.boyaa.entity.images.SaveImage;
import com.boyaa.entity.pay.checkout.CheckoutManager;
import com.boyaa.entity.pay.checkout.v3.GoogleCheckoutHelper;
import com.boyaa.entity.sysInfo.PermissionManager;
import com.boyaa.entity.umeng.Umeng;
import com.facebook.FacebookSdk;

import org.cocos2dx.lib.Cocos2dxActivity;

import java.io.File;

public class AppActivity extends Cocos2dxActivity{

    private static CheckoutManager mCheckOutManager = null;
    private AppStartDialog startDialog;//启动界面
    private static AppActivity mActivity;
    private String mImagePath = "";
    private SaveImage mSaveImage = null;
    private static Handler gameHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(this.getApplicationContext());
/*        try {
            PackageInfo info = getPackageManager().getPackageInfo(
                    "com.coalaa.itexaspro.cn",
                    PackageManager.GET_SIGNATURES);
            for (Signature signature : info.signatures) {
                MessageDigest md = MessageDigest.getInstance("SHA");
                md.update(signature.toByteArray());
                Log.d("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
            }
        } catch (PackageManager.NameNotFoundException e) {

        } catch (NoSuchAlgorithmException e) {

        }*/
        mActivity = this;
        // Workaround in https://stackoverflow.com/questions/16283079/re-launch-of-activity-on-home-button-but-only-the-first-time/16447508
        if (!isTaskRoot()) {
            // Android launched another instance of the root activity into an existing task
            //  so just quietly finish and go away, dropping the user back into the activity
            //  at the top of the stack (ie: the last state of this task)
            // Don't need to finish it again since it's finished in super.onCreate .
            return;
        }
        gameHandler = new GameHandler();
        // DO OTHER INITIALIZATION BELOW
        showStartScreen();
        PermissionManager.getInstance().checkStoPermission();
        setKeepScreenOn(true);
        Umeng.init(this);
        hideSystemNavigationBar();
    }

    private void hideSystemNavigationBar() {
        if (Build.VERSION.SDK_INT < 19) {
            View view = this.getWindow().getDecorView();
            view.setSystemUiVisibility(View.GONE);
        } else {
            View decorView = getWindow().getDecorView();
            int uiOptions = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
                    | View.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
                    | View.SYSTEM_UI_FLAG_IMMERSIVE;
            decorView.setSystemUiVisibility(uiOptions);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(null != FBManager.getFBCallbackManager()){
            FBManager.getFBCallbackManager().onActivityResult(requestCode, resultCode,data);
        }
        if (requestCode == GoogleCheckoutHelper.REQUEST_CODE) {
            if(mCheckOutManager !=null)
                mCheckOutManager.onActivityResult(requestCode, resultCode, data);
        }
        if (resultCode == RESULT_OK && requestCode == SaveImage.PHOTO_PICKED_WITH_DATA) {
            if (mSaveImage != null) {
                boolean isNeedCrop = mSaveImage.getIsNeedCrop();
                if (isNeedCrop) {
                    Log.d("SaveImage","isNeedCrop   getData()"+data.getData());
                    mSaveImage.cropPhoto(data.getData());
                }else{
                    mSaveImage.onCropped(data);
                }
            }
        } else if (resultCode == RESULT_OK && requestCode == SaveImage.CAMERA_PICKED_WITH_DATA) {
            if (mSaveImage != null) {
                mSaveImage.cropPhoto(null);
            }
        } else if (resultCode == RESULT_OK && requestCode == SaveImage.CAMERA_CORPED_WITH_DATA) {
            if (mSaveImage != null) {
                mSaveImage.onCropped(data);
            }
        }

        super.onActivityResult(requestCode, resultCode, data);
    }

    private void showStartScreen(){
        startDialog = new AppStartDialog(this,android.R.style.Theme_Black_NoTitleBar_Fullscreen);
        startDialog.show();
    }

    public void hideStartScreen(){
        if(null != startDialog) {
            startDialog.hidden();
        }
    }
    public String getImagePath() {
        if(mImagePath == ""){
            mImagePath = SDTools.getSDPath()+File.separator+"."+getPackageName()+File.separator+"image"+File.separator;
        }
        return mImagePath;
    }

    public static void initCheckoutManager(){
        mCheckOutManager = CheckoutManager.getInstance(mActivity);
    }

    public static AppActivity getActivity(){
        return mActivity;
    }
    public void createDir() {
        File imageFile = new File(Environment.getExternalStorageDirectory(), "." + getPackageName() + "/images");
        File dictFile = new File(Environment.getExternalStorageDirectory(), "." + getPackageName() + "/dict");
        File updateFile = new File(Environment.getExternalStorageDirectory(), "." + getPackageName() + "/update");
        if (!imageFile.exists())  imageFile.mkdirs();
        if (!dictFile.exists())   dictFile.mkdirs();
        if (!updateFile.exists()) {
            updateFile.mkdirs();
        }else {
            FileUtil.deleteDir(updateFile);
        }
    }

    public synchronized SaveImage getSaveImage(int key) {
        if (mSaveImage == null) {
            mSaveImage = new SaveImage(this, key);
        }
        return mSaveImage;
    }

    public synchronized SaveImage getSaveImage() {
        return mSaveImage;
    }

    public static Handler getGameHandler() {
        return gameHandler;
    }

    public class GameHandler extends Handler {
        /* (non-Javadoc)
         * @see android.os.Handler#handleMessage(android.os.Message)
         */
        @Override
        public void handleMessage(Message msg) {
            //对MX4Pro出现的onPause抛出异常的延时处理
            if (msg.what == SaveImage.CAMERA_CROP_MESSAGEID) {
                startActivityForResult((Intent) msg.obj, SaveImage.CAMERA_CORPED_WITH_DATA);
            } else {
                onHandleMessage(msg);
            }
        }
    }


    protected void onHandleMessage(Message msg) {
        Bundle data = msg.getData();
        String strObj = data.getString("object");
        String strMethod = data.getString("method");
        String param = data.getString("param");

        String groupKey = data.getString("groupKey");
//        LuaCallManager.getManager().runByUIThread(strObj, strMethod, groupKey, param);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        PermissionManager.getInstance().onRequestPermissionResult(requestCode, permissions, grantResults);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mCheckOutManager != null) {
            mCheckOutManager.onDestroy();
        }
        Umeng.onKillProcess();
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    @Override
    protected void onResume() {
        super.onResume();
        Umeng.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        Umeng.onPause();
    }

}
