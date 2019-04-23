package com.boyaa.entity.php;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.boyaa.BoyaaApp;
import com.boyaa.entity.utils.APNUtil;

import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.params.HttpProtocolParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.net.URLConnection;
import java.security.KeyStore;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

// 还需要加入超时、还需要加入exception的记录
public class PHPPost {

    /**
     * 向服务器发送PHP请求
     *
     * @param method
     * 方法名
     * @param param
     * 参数
     * @param timeout
     * 连接及数据读取超时间（单位：毫秒）
     * @return
     */

    private static int countTry502 = 0;
    private static int countTryOther = 0;
    private HttpGet getRequest;
    private HttpPost postRequest;
    private boolean bAbort;

    public static Bitmap loadPic(String uri) {
        countTry502 = 0;
        countTryOther = 0;
        return httpGetPic(uri, 1);
    }

    public static Bitmap httpGetPic(String uri, int try502) {
        if (uri == null || 0 == uri.length())
            return null;
        Bitmap bitmap = null;
        URL url = null;
        URLConnection connection = null;
        HttpURLConnection httpConnection = null;
        InputStream in = null;
        Context context = BoyaaApp.getApplication();
        boolean hasProxy = APNUtil.hasProxy(context);
        try {
            if (hasProxy) {
                String proxyIP = APNUtil.getApnProxy(context);
                String proxyPort = APNUtil.getApnPort(context);
                String host;
                String path;
                final int hostIndex = "http://".length();
                int pathIndex = uri.indexOf('/', hostIndex);
                if (pathIndex < 0) {
                    host = uri.substring(hostIndex);
                    path = "";
                } else {
                    host = uri.substring(hostIndex, pathIndex);
                    path = uri.substring(pathIndex);
                }
                String newUri = "http://" + proxyIP + ":" + proxyPort + path;
                url = new URL(newUri);
                connection = url.openConnection();
                connection.setRequestProperty("X-Online-Host", host);
                connection.setConnectTimeout(5000);

            } else {
                url = new URL(uri);
                connection = url.openConnection();
                connection.setConnectTimeout(5000);
            }
            httpConnection = (HttpURLConnection) connection;
            httpConnection.connect();

            int responseCode = httpConnection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                in = httpConnection.getInputStream();
                bitmap = BitmapFactory.decodeStream(in);
                in.close();
            } else {

                if (502 == responseCode && 1 == try502) {
                    return httpGetPic(uri, 0);
                }
                Log.e("PHPPost", "responseCode=" + responseCode);
            }
        } catch (Exception e) {
            Log.e("PHPPost", e.toString());
            Log.e("PHPPost", uri);
            return bitmap;
        } finally {
            if (null != httpConnection) {
                httpConnection.disconnect();
                httpConnection = null;
            }
        }
        return bitmap;
    }

    public void postURL(String url, PHPResult result, Map<String, String> param, int timeout) {
        if (null == result) {
            Log.e(this, "null PHPResult");
            return;
        }

        result.reset();
        HttpClient client = getClient(timeout);
        HttpPost post = new HttpPost(url);

        try {
            List<NameValuePair> postParams = new ArrayList<NameValuePair>();
            for (Map.Entry<String, String> entry : param.entrySet()) {
                postParams.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
            }
            UrlEncodedFormEntity formEntity = new UrlEncodedFormEntity(postParams, HTTP.UTF_8);
            post.setEntity(formEntity);
            HttpResponse response = client.execute(post);
            int responseCode = response.getStatusLine().getStatusCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                result.json = EntityUtils.toString(response.getEntity());
            } else {
                result.code = PHPResult.NETWORK_ERROR;
                result.setError("" + responseCode);
            }
        } catch (MalformedURLException e) {
            Log.e("PHPPost", e);
            // 抛出这一异常指示出现了错误的 URL。或者在规范字符串中找不到任何合法协议，或者无法分析字符串
            result.code = PHPResult.NETWORK_ERROR;
            result.setError("MalformedURLException");
        } catch (ProtocolException e) {
            Log.e("PHPPost", e);
            // 协议故障
            result.code = PHPResult.NETWORK_ERROR;
            result.setError("ProtocolException");

        } catch (ConnectTimeoutException e) {
            Log.e("PHPPost", e);
            result.code = PHPResult.NETWORK_ERROR;
            result.setError("ConnectTimeoutException");
        } catch (IOException e) {
            Log.e("PHPPost", e);
            result.code = PHPResult.NETWORK_ERROR;
            result.setError("IOException");
        } catch (Exception e) {
            Log.e("PHPPost", e);
            result.code = PHPResult.NETWORK_ERROR;
            result.setError("IOException");
        } finally {

        }

        if (PHPResult.SUCCESS == result.code) {
            result.obj = JSONUtil.parse(result.json);
            if (null == result.obj) {
                result.code = PHPResult.JSON_ERROR;
                result.setError("parse json error");
            } else {
                String strError = JSONUtil.checkErrorType(result.obj);
                if (null != strError && strError.trim().length() > 0) {
                    result.code = PHPResult.SERVER_ERROR;
                    result.setError(strError);
                } else {
                    // success
                }
            }
        }
    }
    /**
     *
     * @param result
     * @param uri
     * @param timeout
     * @param isNeedSSL      由于访问https时，安卓2.2及以下版本无法连接抛异常，需要使用经过处理的client
     */
    public void getURL(PHPResult result, String uri, int timeout, boolean isNeedSSL) {
        if (null == result) {
            Log.e("PHPResult", "null parameter");
            return;
        }
        if (null == getRequest) {
            Log.e(this, "null getRequest");
            return;
        }

        result.reset();
        HttpClient client = null;
        HttpResponse response = null;

        HttpParams httpParams = new BasicHttpParams(); // 创建HttpParams以用来设置HTTP参数（这一部分不是必需的）
        HttpConnectionParams.setConnectionTimeout(httpParams, 20 * 1000); // 设置连接超时
        HttpConnectionParams.setSoTimeout(httpParams, 20 * 1000); // 设置Socket超时
        HttpConnectionParams.setSocketBufferSize(httpParams, 8 * 1024); // Socket数据缓存默认8K
        HttpConnectionParams.setTcpNoDelay(httpParams, false);
        HttpConnectionParams.setStaleCheckingEnabled(httpParams, false);
        HttpClientParams.setRedirecting(httpParams, false);

        if (isNeedSSL)
        {
            client = getNewHttpClient();
        }
        else
        {
            client = new DefaultHttpClient(httpParams);
        }
        setProxy(client);


        try {
            // 根据PHP情况设置超时
            client.getParams().setParameter(
                    HttpConnectionParams.CONNECTION_TIMEOUT, timeout);
            client.getParams().setParameter(HttpConnectionParams.SO_TIMEOUT,
                    timeout);

            // 安全加头
            // getRequest.addHeader("X-TUNNEL-VERIFY", getHeader());
            response = client.execute(getRequest);
            int responseCode = response.getStatusLine().getStatusCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                result.json = EntityUtils.toString(response.getEntity());

            } else {
                result.code = PHPResult.NETWORK_ERROR;
                result.errorNumber = responseCode;
                result.setError("" + responseCode);
            }
        } catch (MalformedURLException e) {
            Log.e("PHPPost", e);
            // 抛出这一异常指示出现了错误的 URL。或者在规范字符串中找不到任何合法协议，或者无法分析字符串
            result.code = PHPResult.NETWORK_ERROR;
            result.errorNumber = PHPResult.ERROR_NUMBER_MalformedURLException;
            result.setError("MalformedURLException");
        } catch (ProtocolException e) {
            Log.e("PHPPost", e);
            // 协议故障
            result.code = PHPResult.NETWORK_ERROR;
            result.errorNumber = PHPResult.ERROR_NUMBER_ProtocolException;
            result.setError("ProtocolException");
        } catch (ConnectTimeoutException e) {
            Log.e("PHPPost", e);
            result.code = PHPResult.NETWORK_ERROR;
            result.errorNumber = PHPResult.ERROR_NUMBER_ConnectTimeoutException;
            result.setError("ConnectTimeoutException");
        } catch (IOException e) {
            Log.e("PHPPost", e);
            result.code = PHPResult.NETWORK_ERROR;
            result.errorNumber = PHPResult.ERROR_NUMBER_IOException;
            result.setError("IOException");
        } catch (Exception e) {
            Log.e("PHPPost", e);
            result.code = PHPResult.NETWORK_ERROR;
            result.errorNumber = PHPResult.ERROR_NUMBER_Exception;
            result.setError("Exception");
        } finally {
            if (bAbort) {
                if (BoyaaApp.getApplication().isDebug()) {
                    Log.e("PHPPost", "user abort");
                }
                result.code = PHPResult.USER_ABORT;
            }
        }
    }

    private static HttpClient getNewHttpClient() {
        try {
            KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
            trustStore.load(null, null);

            SSLSocketFactory sf = new BoyaaSSLSocketFactory(trustStore);
            sf.setHostnameVerifier(SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);

            HttpParams params = new BasicHttpParams();

            HttpConnectionParams.setConnectionTimeout(params, 10000);
            HttpConnectionParams.setSoTimeout(params, 10000);

            HttpProtocolParams.setVersion(params, HttpVersion.HTTP_1_1);
            HttpProtocolParams.setContentCharset(params, HTTP.UTF_8);

            SchemeRegistry registry = new SchemeRegistry();
            registry.register(new Scheme("http", PlainSocketFactory.getSocketFactory(), 80));
            registry.register(new Scheme("https", sf, 443));

            ClientConnectionManager ccm = new ThreadSafeClientConnManager(params, registry);

            HttpConnectionParams.setConnectionTimeout(params, 20 * 1000);
            HttpConnectionParams.setSoTimeout(params, 20 * 1000);
            HttpClient client = new DefaultHttpClient(ccm, params);
//			if (NetState.Mobile == NetStateManager.CUR_NETSTATE) {
//				// 获取当前正在使用的APN接入点
//				HttpHost proxy = NetStateManager.getAPN();
//				if (null != proxy) {
//					client.getParams().setParameter(ConnRouteParams.DEFAULT_PROXY, proxy);
//				}
//			}
            return client;
        } catch (Exception e) {
            return new DefaultHttpClient();
        }
    }
    private HttpClient getClient(int timeout) {
        HttpParams httpParams = new BasicHttpParams(); // 创建HttpParams以用来设置HTTP参数（这一部分不是必需的）
        HttpConnectionParams.setConnectionTimeout(httpParams, 20 * 1000); // 设置连接超时
        HttpConnectionParams.setSoTimeout(httpParams, 20 * 1000); // 设置Socket超时
        HttpConnectionParams.setSocketBufferSize(httpParams, 8 * 1024); // Socket数据缓存默认8K
        HttpConnectionParams.setTcpNoDelay(httpParams, false);
        HttpConnectionParams.setStaleCheckingEnabled(httpParams, false);
        HttpClientParams.setRedirecting(httpParams, false);
        HttpClient client = new DefaultHttpClient(httpParams);

        setProxy(client);
        if (timeout > 0) {
            client.getParams().setParameter(HttpConnectionParams.CONNECTION_TIMEOUT, timeout);
            client.getParams().setParameter(HttpConnectionParams.SO_TIMEOUT, timeout);
        }
        return client;
    }

    public void initGet(String uri){
        initAbort();
        getRequest = new HttpGet(uri);
    }

    private void initAbort() {
        bAbort = false;
        postRequest = null;
        getRequest = null;
    }



    private static void setProxy(HttpClient client) {
        Context context = BoyaaApp.getApplication().getApplicationContext();
        boolean useProxy = APNUtil.hasProxy(context);
        if (useProxy) {
            String proxyIP = APNUtil.getApnProxy(context);
            int proxyPort = APNUtil.getApnPortInt(context);
            HttpHost proxy = new HttpHost(proxyIP, proxyPort);
            client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY,
                    proxy);
        } else {
            client.getParams()
                    .setParameter(ConnRoutePNames.DEFAULT_PROXY, null);
        }
    }

    private static class Log {
        public static void e(Object tag, Object msg) {

        }
    }

}
