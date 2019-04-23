package com.boyaa.entity.http;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.util.Log;

import com.boyaa.entity.utils.JsonUtil;
import com.boyaa.entity.luaManager.LuaCallManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


/**
 *  httpRequest action
 *  more use look here https://github.com/square/okhttp/wiki/Recipes
 *  or 中文翻译 http://www.cnblogs.com/ct2011/p/3997368.html
 *  这个类 直接使用 okHttp 请求的，
 *
 * @author Amnon Ma
 *
 */
@SuppressWarnings("ResultOfMethodCallIgnored")
public class HttpRequest {

    public final static String TAG = "HttpRequest";
    private static final String CONTENT_TYPE = "application/octet-stream";
    
    public void downloadFile (final int responseKey, String param) {
        String url;
        String path;
        final HashMap<String, Object> map = new HashMap<>();
        try {
            JSONObject jsParam = new JSONObject(param);
            url = jsParam.optString("url");
            path = jsParam.optString("filePath");
        } catch (JSONException e) {
            e.printStackTrace();
            map.put("result", 0);
            map.put("url", "");
            String jsonStr = new JsonUtil(map).toString();
            LuaCallManager.callLua(responseKey,jsonStr);
            return;
        }
        
        if (url.length() == 0 || path.length() == 0) return;
        final File file = new File(path);
        map.put("url", url);
        map.put("path", path);
        
        Request request = new Request.Builder().url(url).build();
        OkHttpUtil.enqueue(request, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                file.delete();
                map.put("result", 0);
                String jsonStr = new JsonUtil(map).toString();
                LuaCallManager.callLua(responseKey,jsonStr);
            }
            
            @Override
            public void onResponse(Call call, Response response) {
                InputStream inputStream = response.body().byteStream();
                File fileParent = new File(file.getParent());
                if(!fileParent.exists()) fileParent.mkdirs();
                
                boolean isSuccess = false;
                try {
                    BufferedInputStream bis = new BufferedInputStream(inputStream);
                    BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(file));
                    int len;
                    while ((len =bis.read()) != -1) {
                        bos.write(len);
                    }
                    bos.flush();
                    bis.close();
                    bos.close();
                    isSuccess = true;
                } catch (Exception e) {
                    e.printStackTrace();
                    file.delete();
                }
                
                if (file.getName().endsWith(".jpg") || file.getName().endsWith(".png")) {
                    Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
                    if (bitmap == null) {
                        isSuccess = false;
                        file.delete();
                    } else {
                        bitmap.recycle();
                    }
                }
                
                map.put("result", isSuccess ? 1 : 0);
                String jsonStr = new JsonUtil(map).toString();
                LuaCallManager.callLua(responseKey,jsonStr);
            }
        });
        
    }

    /**
     *  上传图片到服务器
     * @param urlStr 服务器地址
     * @param filePath 文件地址
     * @param api api 由 lua端传过来
     * @return 结果字符串
     * @throws Exception
     */
    public static String uploadImage(String urlStr, String filePath, String api) throws Exception {
        File file = new File(filePath);
        final MediaType mediaType = MediaType.parse("image/*");
        Log.d(TAG, "uploadIcon --> url= " + urlStr + ", file = " + filePath + ", api = " + api);

        RequestBody requestBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("api",api)
                .addFormDataPart("icon","icon.jpg",RequestBody.create(mediaType,file))
                .build();

        Request request = new Request.Builder()
                .url(urlStr)
                .post(requestBody)
                .build();

        Response response = OkHttpUtil.execute(request);
        return response.body().string();
    }

    /**
     *  上传图片到服务器
     * @param urlStr 服务器地址
     * @param filePath 文件地址
     * @param api api 由 lua端传过来
     * @param callback 回调
     * @throws Exception
     */
    public static void uploadImage(String urlStr, String filePath, String api, Callback callback){
        File file = new File(filePath);
        final MediaType mediaType = MediaType.parse("image/*");
        Log.d(TAG, "uploadIcon --> url= " + urlStr + ", file = " + filePath + ", api = " + api);
        try {
            RequestBody requestBody = new MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart("api",api)
                    .addFormDataPart("icon","icon.jpg",RequestBody.create(mediaType,file))
                    .build();

            Request request = new Request.Builder()
                    .url(urlStr)
                    .post(requestBody)
                    .build();

            OkHttpUtil.enqueue(request, callback);

        } catch (Exception ex) {
            Log.w(TAG, "upload image error0000111");
        }

    }

    /**
     *  上传图片到服务器
     * @param urlStr 服务器地址
     * @param filePath 文件地址
     * @param api api 由 lua端传过来
     * @param callback 回调
     * @throws Exception
     */
    public static void uploadFeedBackImage(String urlStr, String filePath, String api, Callback callback) throws Exception {
        File file = new File(filePath);
        final MediaType mediaType = MediaType.parse("application/octet-stream");
        Log.d(TAG, "uploadIcon --> url= " + urlStr + ", file = " + filePath + ", api = " + api);
        RequestBody requestBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("api", api)
                .addFormDataPart("pfile", "feedBackImg.jpg", RequestBody.create(mediaType, file))
//                .addFormDataPart("icon","icon.jpg",RequestBody.create(mediaType,file))
                .build();

        Request request = new Request.Builder()
                .url(urlStr)
                .post(requestBody)
                .build();

        OkHttpUtil.enqueue(request, callback);
    }

    /**
     *  根据 地址下载xml
     * @param urlStr 下载地址
     *
     */
    public static void downloadXml(String urlStr, Callback callback) {
        Request request = new Request.Builder()
                .url(urlStr)
                .build();
        OkHttpUtil.enqueue(request, callback);
    }

    public static void  httpGet(String uri){
        Request request = new Request.Builder()
                            .url(uri)
                            .build();
        OkHttpUtil.enqueue(request);


    }

    public static String uploadVisitorIcon(String urlString,String filePath){
        Log.d("SaveImage", "uploadVisitorIcon --> url= "+urlString+", file = "+filePath);
        HttpURLConnection connection = null;
        DataOutputStream outStream = null;
        DataInputStream inStream = null;

        String lineEnd = "\r\n";
        String twoHyphens = "--";
        String boundary = "*****";

        int bytesRead, bytesAvailable, bufferSize;

        byte[] buffer;

        int maxBufferSize = 1*1024*1024;

        // String urlString = "http://www.yourwebserver.com/youruploadscript.php";

        try {
            FileInputStream fileInputStream = null;
            try {
                fileInputStream = new FileInputStream(new File(filePath));
            } catch(FileNotFoundException e) { }
            URL url = new URL(urlString);
            connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setUseCaches(false);

            connection.setRequestMethod("POST");
            connection.setRequestProperty("Connection", "Keep-Alive");
            connection.setRequestProperty("Content-Type", "multipart/form-data;boundary="+boundary);

            outStream = new DataOutputStream(connection.getOutputStream());
            outStream.writeBytes(twoHyphens + boundary + lineEnd);
            outStream.writeBytes("Content-Disposition: form-data; name=\"upload\";filename=\"icon.jpg" +"\"" + lineEnd + "Content-Type: " + CONTENT_TYPE + lineEnd + "Content-Transfer-Encoding: binary" + lineEnd);
            outStream.writeBytes(lineEnd);

            bytesAvailable = fileInputStream.available();
            bufferSize = Math.min(bytesAvailable, maxBufferSize);
            buffer = new byte[bufferSize];

            bytesRead = fileInputStream.read(buffer, 0, bufferSize);

            while (bytesRead > 0) {
                outStream.write(buffer, 0, bufferSize);
                bytesAvailable = fileInputStream.available();
                bufferSize = Math.min(bytesAvailable, maxBufferSize);
                bytesRead = fileInputStream.read(buffer, 0, bufferSize);
            }

            outStream.writeBytes(lineEnd);
            outStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

            fileInputStream.close();
            outStream.flush();
            outStream.close();
        } catch (MalformedURLException e) {
            Log.e("DEBUG", "[MalformedURLException while sending a picture]");
        } catch (IOException e) {
            Log.e("DEBUG", "[IOException while sending a picture]");
        }

        int responseCode;
        try {
            responseCode = connection.getResponseCode();
            StringBuilder response = new StringBuilder();
            if(responseCode == HttpURLConnection.HTTP_OK){
                String content = connection.getContent().toString();

                InputStream urlStream = connection.getInputStream();
                BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(urlStream));
                String sCurrentLine = "";
                while((sCurrentLine = bufferedReader.readLine()) != null){
                    response.append(sCurrentLine);
                }
                bufferedReader.close();

                return response.toString();

            }
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return null;


    }

    public void uploadFile(final int callbackId, final String params){
        new Thread(new Runnable() {
            @Override
            public void run() {
                HashMap<String, Object> map = new HashMap<>();
                HttpURLConnection connection = null;
                DataOutputStream outStream = null;

                String lineEnd = "\r\n";
                String twoHyphens = "--";
                String boundary = "*****";
                int bytesRead, bytesAvailable, bufferSize;

                byte[] buffer;

                int maxBufferSize = 1 * 1024 * 1024;
                String filePath = "";
                String urlString = "";
                String contents = "";
                try {
                    JSONObject jo = new JSONObject(params);
                    filePath = jo.optString("imgPath");
                    urlString = jo.optString("Url");
                    contents = jo.optString("content");
                    contents = URLEncoder.encode(contents, "UTF-8");
                    urlString = urlString + "&content=" + contents;
//            jsonData.getString("content");
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                try {
                    FileInputStream fileInputStream = null;
                    try {
                        fileInputStream = new FileInputStream(new File(filePath));
                    } catch (FileNotFoundException e) {
                        return;
                    }
                    URL url = new URL(urlString);
                    connection = (HttpURLConnection) url.openConnection();
                    connection.setDoInput(true);
                    connection.setDoOutput(true);
                    connection.setUseCaches(false);

                    connection.setRequestMethod("POST");
                    connection.setRequestProperty("Connection", "Keep-Alive");
                    connection.setRequestProperty("Content-Type",
                            "multipart/form-data;boundary=" + boundary);

                    outStream = new DataOutputStream(connection.getOutputStream());

                    outStream.writeBytes(twoHyphens + boundary + lineEnd);
                    outStream
                            .writeBytes("Content-Disposition: form-data; name=\"upload\";filename=\"feedback.jpg"
                                    + "\""
                                    + lineEnd
                                    + "Content-Type: "
                                    + "application/octet-stream"
                                    + lineEnd
                                    + "Content-Transfer-Encoding: binary" + lineEnd);
                    outStream.writeBytes(lineEnd);

                    bytesAvailable = fileInputStream.available();
                    bufferSize = Math.min(bytesAvailable, maxBufferSize);

                    Bitmap bitmap=BitmapFactory.decodeStream(fileInputStream);
                    double count = bitmap.getRowBytes() * bitmap.getHeight();
                    float scale = (float)count / (1024.0f * 1024.0f);
                    if(bufferSize == maxBufferSize || scale > 1.0f)
                    {
                        if(bitmap != null)
                        {
                            String fileName = "_123.png";
                            String name = getUrl(filePath);
                            zoomImage(bitmap,name,fileName);
                            fileInputStream = new FileInputStream(new File(name+fileName));
                            bytesAvailable = fileInputStream.available();
                            bufferSize = Math.min(bytesAvailable, maxBufferSize);
                        }
                    }
                    else
                    {
                        fileInputStream = null;
                        try {
                            fileInputStream = new FileInputStream(new File(filePath));
                        } catch (FileNotFoundException e) {
                            return;
                        }
                    }
                    buffer = new byte[bufferSize];

                    bytesRead = fileInputStream.read(buffer, 0, bufferSize);

                    //while (bytesRead > 0) {
                    outStream.write(buffer, 0, bufferSize);
                    //bytesAvailable = fileInputStream.available();
                    //bufferSize = Math.min(bytesAvailable, maxBufferSize);
                    //bytesRead = fileInputStream.read(buffer, 0, bufferSize);
                    //}

                    outStream.writeBytes(lineEnd);
                    outStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

                    fileInputStream.close();
                    outStream.flush();
                    outStream.close();
                } catch (MalformedURLException e) {
                    Log.e("DEBUG", "[MalformedURLException while sending a picture]");
                } catch (IOException e) {
                    Log.e("DEBUG", "[IOException while sending a picture]");
                }

                int responseCode;
                try {
                    responseCode = connection.getResponseCode();
                    StringBuilder response = new StringBuilder();
                    if (responseCode == HttpURLConnection.HTTP_OK) {
                        String content = connection.getContent().toString();

                        InputStream urlStream = connection.getInputStream();
                        BufferedReader bufferedReader = new BufferedReader(
                                new InputStreamReader(urlStream));
                        String sCurrentLine = "";
                        while ((sCurrentLine = bufferedReader.readLine()) != null) {
                            response.append(sCurrentLine);
                        }
                        bufferedReader.close();
                        try {
                            map.put("result", new JSONObject(response.toString()).optString("ret"));
                            LuaCallManager.callLua(callbackId, new JsonUtil(map).toString());
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                    }
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    map.put("result", 0);
                }
            }
        }).start();
    }

    public static String getUrl(String url)
    {
        int index = url.indexOf("/", 0);
        int in = 0;
        while(index != -1)
        {
            in = index;
            index = url.indexOf("/",index + 1);
        }
        return url.substring(0, in+1);
    }

    public static void zoomImage(Bitmap bgimage,String name,String picName) {
        // 获取这个图片的宽和高
        double count = bgimage.getRowBytes() * bgimage.getHeight();
        float scale = (float)count / (1024.0f * 1024.0f);
        float width = bgimage.getWidth();
        float height = bgimage.getHeight();
        double newWidth = width/scale;
        double newHeight = height/scale;
        // 创建操作图片用的matrix对象
        Matrix matrix = new Matrix();
        // 计算宽高缩放率
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        // 缩放图片动作
        matrix.postScale(scaleWidth, scaleHeight);
        Bitmap bitmap = Bitmap.createBitmap(bgimage, 0, 0, (int) width,
                (int) height, matrix, true);

        File f = new File(name, picName);
        if (f.exists())
        {
            f.delete();
        }
        try
        {
            FileOutputStream out = new FileOutputStream(f);
            bitmap.compress(Bitmap.CompressFormat.PNG, (int)(100/scale), out);
            out.flush();
            out.close();
        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        //return bitmap;
    }

}
