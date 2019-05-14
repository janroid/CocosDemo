#include "CurlUtils.h"
#include <thread>




CurlUtils* CurlUtils::instance = nullptr;

CurlUtils* CurlUtils::getInstance() {
	if (nullptr == instance) {
		instance = new (std::nothrow) CurlUtils();
	}
	return instance;
}

CurlUtils::CurlUtils() {
	curlMap.reserve(20);
	curlResMap.reserve(10);
	lua_state = nullptr;
}

CurlUtils::~CurlUtils() {
	lua_state = nullptr;
	curlResMap.clear();
	curlMap.clear();
}

void CurlUtils::setLuaState(lua_State *L) {
	lua_state = L;
}

void CurlUtils::release() {
	if (nullptr == instance) {
		delete instance;
		instance = nullptr;
	}
}

void CurlUtils::request(lua_State* L) {
	std::unordered_map<int, CurlOptSupprotValue> optMap;
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		printf("first param only support table");
		return;
	}
	// push the first key 
	lua_pushnil(L);
	while (0 != lua_next(L, -2)) {
		if (lua_isnumber(L, -2)) {
			int key = lua_tonumber(L, -2);
			CurlOptSupprotValue supportValue;
			if (lua_isnumber(L, -1)) {
				supportValue.type = 1;
				supportValue.valueLong = static_cast<long>(lua_tonumber(L, -1));
				optMap[key] = supportValue;
			}
			else if (lua_isstring(L, -1)) {
				supportValue.type = 2;
				supportValue.valueStr = std::string(lua_tostring(L, -1));
				optMap[key] = supportValue;
			}
		}
		lua_pop(L, 1);
	}
	lua_pop(L, 1);
	if (optMap.find(CURLOPT_URL) == optMap.end()) {
		printf("curl must set url\n");
		return;
	}
	std::thread t1(&CurlUtils::_request, this, optMap);
	t1.detach();
}


//该方法用于下载写入
static size_t downloadWrite(void *ptr, size_t size, size_t nmemb, FILE* stream) {
	auto ret = fwrite(ptr, size, nmemb, stream);
	/*auto instance = CurlUtils::getInstance();
	instance->_downloadWrite(ptr, size, nmemb, stream);*/
	return ret;
}

static size_t writeResponse(void *ptr, size_t size, size_t nmemb, void* userp) {
	auto instance = CurlUtils::getInstance();
	return instance->_writeResponse(ptr, size, nmemb, userp);
}

size_t CurlUtils::_writeResponse(void *ptr, size_t size, size_t nmemb, void* userp) {
	size_t realsize = size* nmemb;
	int callbackID = *(int*)(userp);
	CurlResponse* mem = curlResMap[callbackID];
	// CurlResponse* mem = (CurlResponse* )user_p;
	if (mem != NULL) {
		mem->memory = (char*)realloc(mem->memory, mem->size + realsize + 1);
		if (mem->memory == NULL) {/* out of memory! */
			printf("not enough memory (realloc returned NULL)\n");
			return 0;
		}
		memcpy(&(mem->memory[mem->size]), ptr, realsize);
		mem->size += realsize;
		mem->memory[mem->size] = 0;
	}
	return realsize;
}

//该方法用于上传字符串
static size_t uploadReadMemory(void *dest, size_t size, size_t nmemb, void* userp)
{
	WriteMemory* wm = (WriteMemory*)userp;
	size_t buffer_size = size* nmemb;

	if (wm->sizeleft) {
		/* copy as much as possible from the source to the destination */
		size_t copy_this_much = wm->sizeleft;
		if (copy_this_much > buffer_size)
			copy_this_much = buffer_size;
		memcpy(dest, wm->readptr, copy_this_much);

		wm->readptr += copy_this_much;
		wm->sizeleft -= copy_this_much;
		return copy_this_much; /* we copied this many bytes */
	}

	return 0; /* no more data left to deliver */
}

//该方法用于 表单或者二进制 上传
static size_t uploadReadFile(void *ptr, size_t size, size_t nmemb, FILE * stream)
{
	size_t retcode = fread(ptr, size, nmemb, stream);
	return retcode;
}


//先关掉
//void CurlUtils::_downloadWrite(void *ptr, size_t size, size_t nmemb, FILE *stream) {
//	for (std::unordered_map<int, WrapFileAndKey>::iterator iter = curlMap.begin(); iter != curlMap.end(); ++iter)
//	{
//		int callbackID = iter->first;
//		WrapFileAndKey wrap = iter->second;
//		if (stream == wrap.file) {
//			callLuaWrite(callbackID, size, nmemb);
//		}
//	}
//}

void CurlUtils::_setCancel(int callBackId) {
	curlMapMutex.lock();
	auto it = curlMap.find(callBackId);
	if (it != curlMap.end()) {
		(*(it)).second.isCancel = true;
	}
	else {
		printf("this callbackID is valid\n");
	}
	curlMapMutex.unlock();
}


static int progress(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded) {
	auto instance = CurlUtils::getInstance();
	bool isCancel = instance->_downloadProgress(ptr, totalToDownload, nowDownloaded, totalToUpLoad, nowUpLoaded);
	if (isCancel) {
		// 返回非0值就会终止 curl_easy_perform 执行
		return -1;
	}
	return 0;
}

static int newProgress(void *ptr, curl_off_t dltotal, curl_off_t dlnow, curl_off_t ultotal, curl_off_t ulnow) {
	return progress(ptr, static_cast<double>(dltotal), static_cast<double>(dlnow),
		static_cast<double>(ultotal), static_cast<double>(ulnow));
}

bool CurlUtils::_downloadProgress(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded) {
	int currentID = *(int*)(ptr);
	if (curlMap.find(currentID) != curlMap.end()) {
		callLuaProgress(currentID, totalToDownload, nowDownloaded, totalToUpLoad, nowUpLoaded);
		if (curlMap[currentID].isCancel) {
			return true;
		}
	}
	return false;
}


//const char* method,const char* url,const char* param1,const char* param2,const char* param3,const char* param4
void CurlUtils::_request(const std::unordered_map<int, CurlOptSupprotValue> optMap) {
	//long, a function pointer, an object pointer or a curl_off_t,
	int callbackID = 0;
	if (optMap.find(-10000) != optMap.end()) {
		callbackID = (*optMap.find(-10000)).second.valueLong;
	}
	//暂停或者恢复
	if (optMap.find(-1001) != optMap.end()) {
		curlMapMutex.lock();
		auto it = curlMap.find(callbackID);
		if (it != curlMap.end()) {
			CURL* handle = (*(it)).second.curl;
			if (optMap.find(-1002) != optMap.end()) {
				long bit = (*optMap.find(-1002)).second.valueLong;
				CURLcode res = CURLE_OK;
				res = curl_easy_pause(handle, static_cast<int>(bit));
				if (res != CURLE_OK) {
					std::string reason(curl_easy_strerror(res));
					callLuaStatus(callbackID, 3, reason.c_str());
				}
				else {
					callLuaStatus(callbackID, 2, "");
				}
			}
		}
		else {
			printf("this callbackID is valid\n");
		}
		curlMapMutex.unlock();
	}
	else if (optMap.find(-1003) != optMap.end()) {
		_setCancel(callbackID);
	}
	else {
		curlMapMutex.lock();
		auto it = curlMap.find(callbackID);
		if (it != curlMap.end()) {
			curlMapMutex.unlock();
			printf("this callbackID is valid\n");
			return;
		}
		curlMapMutex.unlock();
		CURL* curl = curl_easy_init();
		if (curl) {
			//文件操作
			FILE* modifyFile = nullptr;
			std::string modifyPath = "";
			if (optMap.find(-10001) != optMap.end()) {
				std::string mode("wb");
				if (optMap.find(-10002) != optMap.end()) {
					mode = (*optMap.find(-10002)).second.valueStr;
				}
				modifyPath = (*optMap.find(-10001)).second.valueStr;
				modifyFile = fopen(modifyPath.c_str(), mode.c_str());
				if (optMap.find(-10003) != optMap.end()) {
					long offset = (*optMap.find(-10003)).second.valueLong;
					int defaultWhere = 0;
					if (optMap.find(-10004) != optMap.end()) {
						defaultWhere = static_cast<int>((*optMap.find(-10004)).second.valueLong);
					}
					//为了支持断点续传，打开偏移值（上传，下载都需要）
					fseek(modifyFile, offset, defaultWhere);
				}
			}

			//表单行为
			curl_httppost* formPost = nullptr;
			curl_httppost* lastPost = nullptr;

			if (optMap.find(-1004) != optMap.end()) {
				CURLFORMcode res = CURL_FORMADD_OK;
				if (optMap.find(-1005) != optMap.end()) {
					int formGroupNum = (*optMap.find(-1005)).second.valueLong;
					for (int i = 0; i < formGroupNum; i++) {
						std::string name = (*optMap.find(-1005 - i)).second.valueStr;
						std::string contents = (*optMap.find(-1016 - i)).second.valueStr;
						res = curl_formadd(&formPost, &lastPost,
							CURLFORM_COPYNAME, name.c_str(),
							CURLFORM_COPYCONTENTS, contents.c_str(), CURLFORM_END);
						if (res != CURL_FORMADD_OK) {
							callLuaLog(callbackID, "form error");
						}
					}
				}
				std::string fileKey = (*optMap.find(-1004)).second.valueStr;
				res = curl_formadd(&formPost, &lastPost,
					CURLFORM_COPYNAME, fileKey.c_str(),
					CURLFORM_FILE, modifyPath.c_str(), CURLFORM_END);
				if (res != CURL_FORMADD_OK) {
					callLuaLog(callbackID, "form error");
				}
			}

			struct curl_slist* chunk = nullptr;
			if (optMap.find(-1026) != optMap.end()) {
				int headerNum = (*optMap.find(-1026)).second.valueLong;
				for (int i = 0; i < headerNum; i++) {
					std::string value = (*optMap.find(-1026 - i)).second.valueStr;
					chunk = curl_slist_append(chunk, value.c_str());
				}
				CURLcode res = CURLE_OK;
				res = curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
				if (res != CURLE_OK) {
					std::string reason(curl_easy_strerror(res));
					callLuaLog(callbackID, reason.c_str());
				}
			}

			for (const auto& item : optMap)
			{
				CURLcode res = CURLE_OK;
				int key = item.first;
				if (static_cast<CURLoption>(key) == CURLOPT_WRITEDATA) {
					res = curl_easy_setopt(curl, CURLOPT_WRITEDATA, modifyFile);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}

				if (static_cast<CURLoption>(key) == CURLOPT_WRITEFUNCTION) {
					int writeType = item.second.valueLong;
					if (writeType == 1) {
						res = curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, downloadWrite);
					}
					else if (writeType == 2) {
						CurlResponse* curlResponse = new CurlResponse();
						curlResMap[callbackID] = curlResponse;
						res = curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void*)(&callbackID));
						res = curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeResponse);
					}

					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}
				if (static_cast<CURLoption>(key) == CURLOPT_READDATA) {
					res = curl_easy_setopt(curl, CURLOPT_READDATA, modifyFile);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}

				if (static_cast<CURLoption>(key) == CURLOPT_READFUNCTION) {
					res = curl_easy_setopt(curl, CURLOPT_READFUNCTION, uploadReadFile);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}
				if (static_cast<CURLoption>(key) == CURLOPT_PROGRESSFUNCTION) {
					res = curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progress);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}
				if (static_cast<CURLoption>(key) == CURLOPT_XFERINFOFUNCTION) {
					res = curl_easy_setopt(curl, CURLOPT_XFERINFOFUNCTION, newProgress);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}
				if (static_cast<CURLoption>(key) == CURLOPT_PROGRESSDATA) {
					res = curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, (void*)&callbackID);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}
				//post
				if (static_cast<CURLoption>(key) == CURLOPT_HTTPPOST) {
					res = curl_easy_setopt(curl, CURLOPT_HTTPPOST, formPost);
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
					continue;
				}

				if (key >= 0) {
					CurlOptSupprotValue curlOptSupportValue = item.second;
					if (curlOptSupportValue.type == 1) {
						res = curl_easy_setopt(curl, static_cast<CURLoption>(key), static_cast<long>(curlOptSupportValue.valueLong));
					}
					else if (curlOptSupportValue.type == 2) {
						res = curl_easy_setopt(curl, static_cast<CURLoption>(key), curlOptSupportValue.valueStr.c_str());
					}
					if (res != CURLE_OK) {
						std::string reason(curl_easy_strerror(res));
						callLuaLog(callbackID, reason.c_str());
					}
				}

			}
			if (modifyFile != nullptr) {
				fclose(modifyFile);
				modifyFile = nullptr;
			}

			// 执行请求,后释放
			WrapFileAndKey newWrap;
			newWrap.file = modifyFile;
			newWrap.curl = curl;
			curlMapMutex.lock();
			curlMap[callbackID] = newWrap;
			curlMapMutex.unlock();
			CURLcode res = curl_easy_perform(curl);

			if (formPost != nullptr) {
				curl_formfree(formPost);
			}
			curl_easy_cleanup(curl);
			if (modifyFile != nullptr) {
				fclose(modifyFile);
			}
			if (nullptr != chunk) {
				curl_slist_free_all(chunk);
			}
			curlMapMutex.lock();
			curlMap.erase(callbackID);
			auto responseIt = curlResMap.find(callbackID);
			std::string content = "";
			if (responseIt != curlResMap.end()) {
				CurlResponse* curlResponse = responseIt->second;
				if (curlResponse->memory != nullptr) {
					content = std::string(curlResponse->memory);
				}
				delete curlResponse;
				curlResMap.erase(callbackID);
			}

			curlMapMutex.unlock();
			if (res != CURLE_OK) {
				std::string reason(curl_easy_strerror(res));
				callLuaStatus(callbackID, 0, reason.c_str());
			}
			else {
				callLuaStatus(callbackID, 1, content.c_str());
			}
		}
	}
}

void CurlUtils::callLuaStatus(int callbackID, int status, const char* failure) {
	_schedulerMutex.lock();
	std::string copyContent(failure);
	Director::getInstance()->getScheduler()->performFunctionInCocosThread([this, callbackID, status, copyContent]() {
		lua_State* L = lua_state;
		lua_getglobal(L, "cc");
		lua_getfield(L, -1, "exports");
		lua_getfield(L, -1, "vx_http_request_call_lua");

		lua_pushnumber(L, callbackID);
		lua_newtable(L);
		lua_pushstring(L, "status");
		lua_pushnumber(L, status);
		lua_settable(L, -3);
		lua_pushstring(L, "failure");
		lua_pushstring(L, copyContent.c_str());
		lua_settable(L, -3);

		int traceCallback = 0;
		lua_getglobal(L, "__G__TRACKBACK__");
		if (!lua_isfunction(L, -1))
		{
			lua_pop(L, 1);
		}
		else {
			lua_insert(L, -4);                         /* L: ... G func arg1 arg2 ... */
			traceCallback = -4;
		}
		int ret = lua_pcall(L, 2, 1, traceCallback);
		if (ret) {
			if (traceCallback == 0)
			{
				CCLOG("[LUA ERROR] %s", lua_tostring(L, -1));        /* L: ... error */
				lua_pop(L, 1); // remove error message from stack
			}
			else                                                            /* L: ... G error */
			{
				lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
			}
			lua_settop(L, 2);
		}
	});
	_schedulerMutex.unlock();
}

void CurlUtils::callLuaProgress(int callbackID, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded) {
	_schedulerMutex.lock();
	Director::getInstance()->getScheduler()->performFunctionInCocosThread([this, callbackID, totalToDownload, nowDownloaded, totalToUpLoad, nowUpLoaded]() {
		lua_State* L = lua_state;
		lua_getglobal(L, "cc");
		lua_getfield(L, -1, "exports");
		lua_getfield(L, -1, "vx_http_request_call_lua");

		lua_pushnumber(L, callbackID);
		lua_newtable(L);
		lua_pushstring(L, "totalToDownload");
		lua_pushnumber(L, totalToDownload);
		lua_settable(L, -3);
		lua_pushstring(L, "nowDownloaded");
		lua_pushnumber(L, nowDownloaded);
		lua_settable(L, -3);
		lua_pushstring(L, "totalToUpLoad");
		lua_pushnumber(L, totalToUpLoad);
		lua_settable(L, -3);
		lua_pushstring(L, "nowUpLoaded");
		lua_pushnumber(L, nowUpLoaded);
		lua_settable(L, -3);

		int traceCallback = 0;
		lua_getglobal(L, "__G__TRACKBACK__");
		if (!lua_isfunction(L, -1))
		{
			lua_pop(L, 1);
		}
		else {
			lua_insert(L, -4);                         /* L: ... G func arg1 arg2 ... */
			traceCallback = -4;
		}
		int ret = lua_pcall(L, 2, 1, traceCallback);
		if (ret) {
			if (traceCallback == 0)
			{
				CCLOG("[LUA ERROR] %s", lua_tostring(L, -1));        /* L: ... error */
				lua_pop(L, 1); // remove error message from stack
			}
			else                                                            /* L: ... G error */
			{
				lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
			}
			lua_settop(L, 2);
		}
	});
	_schedulerMutex.unlock();
}

// void CurlUtils::callLuaWrite(int callbackID,size_t size, size_t nmemb){
//       _schedulerMutex.lock();
// 	Director::getInstance()->getScheduler()->performFunctionInCocosThread([this,callbackID, size,nmemb]() {
// 		lua_State* L = lua_state;
// 		lua_getglobal(L, "cc");
// 		lua_getfield(L, -1, "exports");
// 		lua_getfield(L, -1, "vx_http_request_call_lua");

//         lua_pushnumber(L, callbackID);
//         lua_newtable(L);
//         lua_pushstring(L, "size");
//         lua_pushnumber(L,size);
//         lua_settable(L,-3);
//         lua_pushstring(L, "nmemb");
//         lua_pushnumber(L,nmemb);
//         lua_settable(L,-3);

// 		int traceCallback = 0;
// 		lua_getglobal(L, "__G__TRACKBACK__");
// 		if (!lua_isfunction(L, -1))
// 		{
// 			lua_pop(L, 1);
// 		}
// 		else {
// 			lua_insert(L, -4);                         /* L: ... G func arg1 arg2 ... */
// 			traceCallback = -4;
// 		}
// 		int ret = lua_pcall(L, 2, 1, traceCallback);
// 		if (ret) {
// 			if (traceCallback == 0)
// 			{
// 				CCLOG("[LUA ERROR] %s", lua_tostring(L, -1));        /* L: ... error */
// 				lua_pop(L, 1); // remove error message from stack
// 			}
// 			else                                                            /* L: ... G error */
// 			{
// 				lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
// 			}
// 			lua_settop(L, 2);
// 		}
// 	});
// 	_schedulerMutex.unlock();
// }

void CurlUtils::callLuaLog(int callbackID, const char* failure) {
	_schedulerMutex.lock();
	std::string copyContent(failure);
	Director::getInstance()->getScheduler()->performFunctionInCocosThread([this, callbackID, copyContent]() {
		lua_State* L = lua_state;
		lua_getglobal(L, "cc");
		lua_getfield(L, -1, "exports");
		lua_getfield(L, -1, "vx_http_request_call_lua");

		lua_pushnumber(L, callbackID);
		lua_newtable(L);
		lua_pushstring(L, "log");
		lua_pushstring(L, copyContent.c_str());
		lua_settable(L, -3);


		int traceCallback = 0;
		lua_getglobal(L, "__G__TRACKBACK__");
		if (!lua_isfunction(L, -1))
		{
			lua_pop(L, 1);
		}
		else {
			lua_insert(L, -4);                         /* L: ... G func arg1 arg2 ... */
			traceCallback = -4;
		}
		int ret = lua_pcall(L, 2, 1, traceCallback);
		if (ret) {
			if (traceCallback == 0)
			{
				CCLOG("[LUA ERROR] %s", lua_tostring(L, -1));        /* L: ... error */
				lua_pop(L, 1); // remove error message from stack
			}
			else                                                            /* L: ... G error */
			{
				lua_pop(L, 2); // remove __G__TRACKBACK__ and error message from stack
			}
			lua_settop(L, 2);
		}
	});
	_schedulerMutex.unlock();
}

