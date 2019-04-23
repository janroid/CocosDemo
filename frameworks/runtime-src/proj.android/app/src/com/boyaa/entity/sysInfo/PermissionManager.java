package com.boyaa.entity.sysInfo;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.support.annotation.StringRes;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import com.boyaa.entity.widget.GameString;
import com.boyaa.ipoker.R;

import org.cocos2dx.lua.AppActivity;

import static org.cocos2dx.lib.Cocos2dxHelper.terminateProcess;


/**
 * Created by JanRoid on 2016/4/1.
 */
public class PermissionManager {
    /**
     * 申请权限回调使用常量
     */
    private final static int PERMISSIONS_REQUEST_READ_PHONE_STATE = 1001;
    private final static int PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE = 1002;
    private final static int PERMISSIONS_REQUEST_CAMERA = 1003;
    private final static int PERMISSIONS_REQUEST_RECORD_AUDIO = 1004;
    private final static int PERMISSIONS_REQUEST_READ_CONTACTS = 1005;
    private final static int PERMISSIONS_REQUEST_SEND_SMS = 1006;
    private final static int PERMISSIONS_REQUEST_CALL_PHONE_STATE = 1007;
    public final static int PERMISSIONS_REQUEST_CAMERA_QRCODE = 1009;//扫描二维码请求相机权限
    public final static int PERMISSIONS_REQUEST_CAMERA_SAVEIMG = 1010;//获取头像等请求相机权限
    private static volatile PermissionManager sPermissionManager;
    private AlertDialog permissionDialog;
    private AlertDialog tipsDialog;
    private final String mTitle;
    private final String mQuit;
    private final String mSetting;
    
    private PermissionManager() {
        mTitle = getText(R.string.help);
        mQuit = getText(R.string.quit);
        mSetting = getText(R.string.setting);
    }

    private String getText(@StringRes int id) {
        return String.valueOf(AppActivity.getActivity().getResources().getText(id));
    }
    
    public static PermissionManager getInstance() {
        if (sPermissionManager == null) {
            synchronized (PermissionManager.class) {
                if (sPermissionManager == null) {
                    sPermissionManager = new PermissionManager();
                }
            }
        }
        return sPermissionManager;
    }
    
    public boolean checkStoPermission(){
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED){
                ActivityCompat.requestPermissions(
                        AppActivity.getActivity(),
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                        PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE);
            return false;
        }
        return true;
    }
    
    public boolean checkPhonePermissions(){
//        Log.d("janroid","*******************************"+tag);
        
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.READ_PHONE_STATE)
                != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    AppActivity.getActivity(),
                    new String[]{Manifest.permission.READ_PHONE_STATE},
                    PERMISSIONS_REQUEST_READ_PHONE_STATE);
            return false;
        }
        return true;
    }
    
    
    public boolean checkCallPhonePermissions(){
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.CALL_PHONE)
                != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    AppActivity.getActivity(),
                    new String[]{Manifest.permission.CALL_PHONE},
                    PERMISSIONS_REQUEST_CALL_PHONE_STATE);
            return false;
        }
        return true;
    }

    public boolean checkCameraPermissions(int permissionReqCode){
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    AppActivity.getActivity(),
                    new String[]{Manifest.permission.CAMERA},
                    permissionReqCode);
            return false;
        }
        //ActivityCompat.shouldShowRequestPermissionRationale();
        return true;
    }

    public boolean checkAudioPermissions(){
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    AppActivity.getActivity(),
                    new String[]{Manifest.permission.RECORD_AUDIO},
                    PERMISSIONS_REQUEST_RECORD_AUDIO);
            return false;
        }

        return true;
    }

    public boolean checkContactsPermissions(){
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.READ_CONTACTS)
                != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    AppActivity.getActivity(),
                    new String[]{Manifest.permission.READ_CONTACTS, Manifest.permission.SEND_SMS},
                    PERMISSIONS_REQUEST_READ_CONTACTS);
            return false;
        }

        return true;
    }

    public boolean checkSmsPermissions(){
        if(ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.SEND_SMS)
                != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    AppActivity.getActivity(),
                    new String[]{Manifest.permission.SEND_SMS},
                    PERMISSIONS_REQUEST_READ_CONTACTS);
            return false;
        }

        return true;
    }
    
    private void showMissingPermissionDialog(String msg){
    	if (permissionDialog == null) {
            final AlertDialog.Builder builder =new AlertDialog.Builder(AppActivity.getActivity(), AlertDialog.THEME_DEVICE_DEFAULT_LIGHT);
            builder.setTitle(mTitle);
            builder.setCancelable(false);
            builder.setNegativeButton(mQuit, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    terminateProcess();
                }
            });
            builder.setPositiveButton(mSetting, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    PermissionManager.this.startAppSettings();
                    dialog.dismiss();
                }
            });
            permissionDialog = builder.create();
	    }
        permissionDialog.setMessage(msg);
    	permissionDialog.show();
    }
    
    private void showTipsDialog(String msg){
    	if (tipsDialog == null) {
            final AlertDialog.Builder builder =new AlertDialog.Builder(AppActivity.getActivity(), AlertDialog.THEME_DEVICE_DEFAULT_LIGHT);
            builder.setTitle(mTitle);
            builder.setCancelable(false);
            builder.setNegativeButton(mQuit, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
            builder.setPositiveButton(mSetting, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    PermissionManager.this.startAppSettings();
                    dialog.dismiss();
                }
            });
            tipsDialog = builder.create();
	    }
        tipsDialog.setMessage(msg);
    	tipsDialog.show();
    }

    private void startAppSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + AppActivity.getActivity().getPackageName()));
        AppActivity.getActivity().startActivity(intent);
    }
    
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode){
            case PermissionManager.PERMISSIONS_REQUEST_READ_PHONE_STATE:
                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
//                    new SystemInfo().initPhoneInfo();
//                    new SystemInfo().initSysMacAddress();
                }else{
                    showTipsDialog(getText(R.string.phone_permission_reject_desc));
                }
                break;
            case PermissionManager.PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE:
                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
                    AppActivity.getActivity().createDir();
                }else {
                    showMissingPermissionDialog(getText(R.string.storage_permission_reject_desc));
                }
                break;
            case PermissionManager.PERMISSIONS_REQUEST_CAMERA:
            case PermissionManager.PERMISSIONS_REQUEST_CAMERA_SAVEIMG:
                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
                    if(null != AppActivity.getActivity().getSaveImage()){
                        AppActivity.getActivity().getSaveImage().takePictures();
                    }
                }else{
                    showTipsDialog(getText(R.string.camera_permission_reject_desc));
                }
                break;
//            case PermissionManager.PERMISSIONS_REQUEST_CAMERA_QRCODE:
//                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                    Intent openCaptrueIntent = new Intent( AppActivity.getActivity(), CaptureActivity.class);
//                    AppActivity.getActivity().startActivityForResult(openCaptrueIntent, QrCodeProcess.QR_CODE_DATA);
//                }else{
//                    showTipsDialog(GameString.getString("permissions_msg3"));
//                }
//                break;
            case PermissionManager.PERMISSIONS_REQUEST_RECORD_AUDIO:
                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
                
                }else{
                    showTipsDialog(GameString.getString("permissions_msg4"));
                }
    
                break;
//            case PermissionManager.PERMISSIONS_REQUEST_READ_CONTACTS:
//                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
//                    new SmsUtil().getContactList("sms_get_contact",null);
//                }else{
//                    showTipsDialog(GameString.getString("permissions_msg5"));
//                }
//                break;
            case PermissionManager.PERMISSIONS_REQUEST_SEND_SMS:
                if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
                    showTipsDialog(GameString.getString("permissions_msg6"));
                }else{
                    showTipsDialog(GameString.getString("permissions_msg5"));
                }
                break;
        }
    }
}
