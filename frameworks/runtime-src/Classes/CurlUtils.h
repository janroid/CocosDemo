#ifndef __IPOKER_CURL_TUILS_H__
#define __IPOKER_CURL_TUILS_H__

#include <stdio.h>
#include <iostream>
#include <string>
#include <unordered_map>
#include "cocos2d.h"
#include <curl/curl.h>
#include "scripting/lua-bindings/manual/CCLuaEngine.h"


USING_NS_CC;

struct _CurlOptSupprotValue{
    std::string valueStr;
	long valueLong;
    int type; // 1 long 2 string
};

typedef struct _CurlOptSupprotValue CurlOptSupprotValue;


typedef struct WrapFileAndKey {
	FILE* file;
    CURL* curl;
	bool isCancel;
	WrapFileAndKey() {
		isCancel = false;
	}
}WrapFileAndKey;

//from https://curl.haxx.se/libcurl/c/post-callback.html
typedef struct _WriteMemory {
    const char *readptr;
    size_t sizeleft;
}WriteMemory;


typedef struct _CurlResponse{
    char *memory;
    size_t size;

    _CurlResponse(){
        size = 0;
        memory = nullptr;
    }
}CurlResponse;

class CurlUtils{
public:
    static CurlUtils* getInstance();
    static void release();
    
    void setLuaState(lua_State* L);
    void request(lua_State* L);
	
    //todo 先简单处理，不支持自定义一些操作,只支持上传下载进度回调
	// void _downloadWrite(void *ptr, size_t size, size_t nmemb, FILE* stream);
    // void _uploadRead(void *ptr, size_t size, size_t nmemb, FILE* stream);
	bool _downloadProgress(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded);
    size_t _writeResponse(void *ptr, size_t size, size_t nmemb,void* userp);

	void _setCancel(int callbackID);
private:
    CurlUtils();
    ~CurlUtils();

    void _request(const std::unordered_map<int, CurlOptSupprotValue> optMap);
    void callLuaStatus(int callbackID,int status,const char* failure);
    void callLuaProgress(int callbackID,double,double,double,double);
    void callLuaWrite(int callbackID,size_t,size_t);
	void callLuaLog(int callbackID, const char* failure);



	
    // void upload(const char* url,const char* fileName,const char* filePath);
    // void download(const char* url,const char* savePath);

    // size_t httpPost(const char* url,const char* fileName,const char* filePath);
    // size_t httpGet(const char* url,const char* savePath);

    // static size_t respond_callback(uint8_t* dataPtr,size_t size,size_t nmemb,void* user_p);
    // static size_t progress_callback(void* clientp,double dltotal,double dlnow, double ultotal, double ulnow);

private:
    lua_State* lua_state;
    static CurlUtils* instance;
	std::unordered_map<int, WrapFileAndKey> curlMap;
	std::unordered_map<int, CurlResponse*> curlResMap;
	std::mutex _schedulerMutex;
    std::mutex curlMapMutex;
};




#endif //__IPOKER_CURL_TUILS_H__