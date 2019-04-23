/**
 * FileUpload.java
 * Boyaa Texas Poker For Android
 * <p/>
 * Created by JanRoid on 2015-3-31.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.file;

import com.boyaa.entity.common.RequestResult;

import org.apache.http.conn.ConnectTimeoutException;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;

/**
 * @author Janroid
 *
 */
public class FileUpload {
    public FileUpload() {

    }

    private static final String TAG = "FileUpload";

    /**
     * 上传文件
     */
    public RequestResult upload(String urlStr, String filePath, String fileName, int timeout, String time, String fileKey,
                                String mimeType) {
        RequestResult result = new RequestResult();
        HttpURLConnection connection = null;
        DataOutputStream outStream = null;
        String lineEnd = "\r\n";
        String twoHyphens = "--";
        String boundary = "*****";

        int bytesRead;
        int bytesAvailable;
        int bufferSize;

        byte[] buffer;

        int maxBufferSize = 1024 * 1024;
        int timeout2 = timeout < 5000 ? 5000 : timeout;
        try {
            FileInputStream fileInputStream = null;
            try {
                File file = new File(filePath);
                fileInputStream = new FileInputStream(file);
            } catch (FileNotFoundException e) {
                result.code = RequestResult.REQUEST_RESULT_ERROR;
                return result;
            }

            URL url = new URL(urlStr);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(timeout2);
            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setUseCaches(false);

            connection.setRequestMethod("POST");
            connection.setRequestProperty("Connection", "Keep-Alive");
            connection.setRequestProperty("Charset", "UTF-8");
            connection.setRequestProperty("Content-Type",
                    "multipart/form-data;boundary=" + boundary);

            outStream = new DataOutputStream(connection.getOutputStream());

            outStream.writeBytes(twoHyphens + boundary + lineEnd);
            outStream
                    .writeBytes("Content-Disposition: form-data; name=\"" + fileKey + "\";filename=\"" + fileName + "\"" + lineEnd
                            + "Content-Type: " + mimeType + lineEnd
                            + "Content-Transfer-Encoding: binary" + lineEnd + lineEnd);

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
            result.code = RequestResult.REQUEST_RESULT_ERROR;
            return result;
        } catch (ProtocolException e) {
            result.code = RequestResult.REQUEST_RESULT_ERROR;
            result.retStr = e.toString();
            return result;
        } catch (ConnectTimeoutException e) {
            result.code = RequestResult.REQUEST_TIMEOUT;
            result.retStr = e.toString();
            return result;
        } catch (ArrayIndexOutOfBoundsException e) {
            result.code = RequestResult.REQUEST_RESULT_ERROR;
            result.retStr = e.toString();
            return result;
        } catch (IOException e) {
            result.code = RequestResult.REQUEST_TIMEOUT;
            result.retStr = e.toString();
            return result;
        }

        int responseCode;
        try {
            responseCode = connection.getResponseCode();
            StringBuilder response = new StringBuilder();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                InputStream urlStream = connection.getInputStream();
                BufferedReader bufferedReader = new BufferedReader(
                        new InputStreamReader(urlStream));
                String sCurrentLine = "";
                while ((sCurrentLine = bufferedReader.readLine()) != null) {
                    response.append(sCurrentLine);
                }
                bufferedReader.close();
                connection.disconnect();

                result.code = RequestResult.REQUEST_SUCCESS;
                result.retStr = response.toString();
                return result;
            } else {
                result.code = RequestResult.REQUEST_RESULT_ERROR;
            }
        } catch (IOException e) {
            result.code = RequestResult.REQUEST_RESULT_ERROR;
        } finally {

        }

        return result;
    }


    private String addParam(String key, String value,
                            String twoHyphens, String boundary, String lineEnd) {
        return twoHyphens + boundary + lineEnd
                + "Content-Disposition: form-data; name=\"" + key + "\""
                + lineEnd + lineEnd + value + lineEnd;
    }

    /**
     * Convert any non-ascii character into substring containing hex form of unicode
     *
     **/
    private String nonAsciiToUnicode(String str) {
        StringBuffer retStr = new StringBuffer("");
        for (int i = 0; i < str.length(); i++) {
            int code = str.charAt(i);

            if (code >= 0 && code <= 127) {
                retStr.append(str.charAt(i));
            } else {
                retStr.append("\\u" + Integer.toHexString(code));
            }
        }
        return retStr.toString();
    }
}
