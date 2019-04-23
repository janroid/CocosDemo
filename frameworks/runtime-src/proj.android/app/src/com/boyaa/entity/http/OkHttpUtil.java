package com.boyaa.entity.http;

import java.io.IOException;
import java.util.List;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 *  对okHttp 的一些常用用法进行封装的工具类
 * Created by MaxizMa on 2015/8/13.
 */
public class OkHttpUtil {

    public final static String TAG = "OkHttpUtil";

    private final static OkHttpClient mOkHttpClient = new OkHttpClient();
    private static final String CHARSET_NAME = "UTF-8";

    public static OkHttpClient getOkHttpClient() {
        return mOkHttpClient;
    }
    /**
     * 该不会开启异步线程。
     * @param request 请求类
     * @return 响应返回
     * @throws IOException
     */
    public static Response execute(Request request) throws IOException {
        return mOkHttpClient.newCall(request).execute();
    }

    /**
     * 开启异步线程访问网络
     * @param request 请求类（自定义操作）
     * @param responseCallback
     */
    public static void enqueue(Request request, Callback responseCallback){
        mOkHttpClient.newCall(request).enqueue(responseCallback);
    }

    /**
     * 开启异步线程访问网络, 且不在意返回结果（实现空callback）
     * @param request 请求类（自定义操作）
     */
    public static void enqueue(Request request){
        mOkHttpClient.newCall(request).enqueue(new Callback() {

            @Override
            public void onResponse(Call call, Response response) throws IOException {

            }

            @Override
            public void onFailure(Call call, IOException e) {

            }
        });
    }

    /**
     *  通过get方法请求 拿到网页内容
     * @param url 请求地址
     * @return 返回网页内容
     * @throws IOException
     */
    public static String getStringFromServer(String url) throws IOException {
        Request request = new Request.Builder().url(url).build();
        Response response = execute(request);
        if (response.isSuccessful()) {
            return response.body().string();
        } else {
            throw new IOException("Unexpected code " + response);
        }
    }

    /**
     * 这里使用了HttpClinet的API。只是为了方便
     * @param params
     * @return
     */
    public static String formatParams(List<NameValuePair> params){
        return URLEncodedUtils.format(params, CHARSET_NAME);
    }

    /**
     * 为HttpGet 的 url 方便的添加多个name value 参数。
     * @param url 访问的url 地址
     * @param params 需要添加的参数
     * @return
     */
    public static String attachHttpGetParams(String url, List<NameValuePair> params){
        return url + "?" + formatParams(params);
    }

    /**
     * 为HttpGet 的 url 方便的添加1个name value 参数。
     * @param url 访问的url 地址
     * @param name key值
     * @param value value值
     * @return 合并后的地址
     */
    public static String attachHttpGetParam(String url, String name, String value){
        return url + "?" + name + "=" + value;
    }
}
