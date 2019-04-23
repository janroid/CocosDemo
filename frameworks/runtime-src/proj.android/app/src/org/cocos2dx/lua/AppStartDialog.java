package org.cocos2dx.lua;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.widget.ImageView;

import com.boyaa.ipoker.R;

public class AppStartDialog extends Dialog {
    private Context mContext;
    private boolean isAnimFinished= false;   //动画是否播放完，预留给动画使用
    private boolean isEngineLoaded = false;//引擎是否完成启动，预留给动画使用
    public AppStartDialog(Context context) {
        super(context);
        mContext = context;
    }

    public AppStartDialog(Context context, int themeResId) {
        super(context, themeResId);
        mContext = context;
    }

    protected AppStartDialog(Context context, boolean cancelable, OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
        mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initStartScreen();
    }

    private void initStartScreen(){
        ImageView mImg = new ImageView(mContext);
        mImg.setImageResource(R.drawable.start_screen);
        ViewGroup.LayoutParams mLayoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        setContentView(mImg, mLayoutParams);

        AlphaAnimation alphaAnim = new AlphaAnimation(0.0f, 1.0f);
        //执行三秒
        alphaAnim.setDuration(3000);
        mImg.startAnimation(alphaAnim);


        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                isAnimFinished = true;
                if (isEngineLoaded) {
                    dismiss();
                }
            }
        }, 1000);

    }


    public void hidden(){
        isEngineLoaded = true;
        if(isAnimFinished){
            this.dismiss();
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        AppActivity.getActivity().onWindowFocusChanged(hasFocus);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)
    {
        return keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0 || super.onKeyDown(keyCode, event);
    }
}
