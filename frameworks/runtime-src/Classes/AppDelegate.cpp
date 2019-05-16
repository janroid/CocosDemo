/****************************************************************************
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

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"

#include "reader/lua-bindings/creator_reader_bindings.hpp"
#include "pbc/pbc-lua.h"
#include "XGLuaBindings.h"
#include "VxNetManager.h"
#include "XGCCallLuaManager.h"
#include "VxResourceManager.h"
#include "XGDBFrameAnimation.h"
#include "lua_byte_data_manual.hpp"
#include "sqlite3/lsqlite3.h"
//#include "CurlUtils.h"
#include "CreatorReader.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "cjson/lua_cjson.h"

#ifdef __cplusplus
}
#endif



// #define USE_AUDIO_ENGINE 1
// #define USE_SIMPLE_AUDIO_ENGINE 1

#if USE_AUDIO_ENGINE && USE_SIMPLE_AUDIO_ENGINE
#error "Don't use AudioEngine and SimpleAudioEngine at the same time. Please just select one in your game!"
#endif

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#elif USE_SIMPLE_AUDIO_ENGINE
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;
#endif

USING_NS_CC;
using namespace std;

static bool firstRunLuaScript = true;
static string defaultResRootPath;
static vector<string> defaultResearchPaths;
static void removeOldUpdateResource();

static bool startLua();
static int fix_restart_lua(lua_State * l);
//static int CurlUtils_register(lua_State * l);

#if __cplusplus    
extern "C" {
#endif    
	extern void ccl_appPause(lua_State* L);
	extern void ccl_appResume(lua_State* L);
#if __cplusplus    
}
#endif   

AppDelegate::AppDelegate()
{
}
AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
	AudioEngine::end();
#elif USE_SIMPLE_AUDIO_ENGINE
	SimpleAudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
	// NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
	RuntimeEngine::getInstance()->end();
#endif

}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
	// set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
	GLContextAttrs glContextAttrs = { 8, 8, 8, 8, 24, 8, 0 };

	GLView::setGLContextAttrs(glContextAttrs);
}



static int readProtobufFile(lua_State *L)

{

	const char *buff = luaL_checkstring(L, -1);

	Data data = CCFileUtils::getInstance()->getDataFromFile(buff);

	lua_pushlstring(L, (const char*)data.getBytes(), data.getSize());

	return 1; /* number of results */

}

static int register_xg(lua_State* tolua_S)
{
	tolua_open(tolua_S);

	tolua_module(tolua_S, "xg", 0);
	tolua_beginmodule(tolua_S, "xg");


	tolua_endmodule(tolua_S);
	return 1;
}


// if you want to use the package manager to install more packages, 
// don't modify or remove this function
static int register_all_packages()
{
	lua_State *L = LuaEngine::getInstance()->getLuaStack()->getLuaState();

	luaopen_protobuf_c(L);
	luaopen_projectx_c(L);
	lua_module_register(L);

	lua_getglobal(L, "_G");
	if (lua_istable(L, -1))//stack:...,_G,
	{
		register_creator_reader_module(L);
		register_xg(L);
		register_byte_data_manual(L);
	}
	lua_pop(L, 1);


	lua_register(L, "readProtobufFile", readProtobufFile);

	lua_register(L, "fix_restart_lua", fix_restart_lua);

	//CurlUtils::getInstance()->setLuaState(L);
	//lua_register(L, "CurlUtils", CurlUtils_register);

	luaopen_lsqlite3(L);

	luaopen_cjson(L);

	return 0; //flag for packages manager
}



bool AppDelegate::applicationDidFinishLaunching()
{
	return startLua();
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
	CCLOG("**applicationDidEnterBackground");
	Director::getInstance()->stopAnimation();

#if USE_AUDIO_ENGINE
	AudioEngine::pauseAll();
#elif USE_SIMPLE_AUDIO_ENGINE
	SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
	SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
	lua_State *L = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	ccl_appPause( L);

}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
	CCLOG("**applicationWillEnterForeground");
	Director::getInstance()->startAnimation();

#if USE_AUDIO_ENGINE
	AudioEngine::resumeAll();
#elif USE_SIMPLE_AUDIO_ENGINE
	SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
	SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif
	lua_State *L = LuaEngine::getInstance()->getLuaStack()->getLuaState();
	ccl_appResume(L);
}


static bool startLua() {
	VxNetManager::getInstance();
	// set default FPS
	Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

	// register lua module
	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
	lua_State* L = engine->getLuaStack()->getLuaState();
	lua_module_register(L);

	XGCCallLuaManager::getInstance()->setLuaState(L);

	register_all_packages();

	LuaStack* stack = engine->getLuaStack();
	stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

	//register custom function
	//LuaStack* stack = engine->getLuaStack();
	//register_custom_function(stack->getLuaState());

#if CC_64BITS
	FileUtils::getInstance()->addSearchPath("src/64bit");
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	//resetWin32DefaulRootPath();
#else
    removeOldUpdateResource();
#endif

	FileUtils::getInstance()->addSearchPath("src");
	FileUtils::getInstance()->addSearchPath("res");
	VxResourceManager::getInstance()->init();
	XGDBFrameAnimationManager::getInstance()->init();
	if (engine->executeScriptFile("main.lua"))
	{
		return false;
	}

	return true;
}


static int fix_restart_lua(lua_State * l) {
	//这里只能使用动作，不能使用定时器，因为CCDirector::getInstance()->getRunningScene() 已经为nil了，不能注册定时器

	auto s = Director::getInstance()->getRunningScene();

	s->runAction(Sequence::create(
		DelayTime::create(0.01),
		CallFunc::create([&]() { 
	
		auto writePath = FileUtils::getInstance()->getWritablePath();
		
		creator::CreatorReader::resetSpriteFrames();
		Director::getInstance()->restart();
		Director::getInstance()->mainLoop();
		ScriptEngineManager::getInstance()->removeScriptEngine();//把原来的luaEngine销毁
		ScriptHandlerMgr::destroyInstance();//把原理注册的函数ID清空
		VxNetManager::release();
		XGCCallLuaManager::release();
		XGDBFrameAnimationManager::release();
		VxResourceManager::pureInstance();
		FileUtils::getInstance()->setWritablePath(writePath);
		startLua();
	
	}),nullptr
		));

	
	return 1;
}

static int CurlUtils_register(lua_State* L) {
	//CurlUtils::getInstance()->request(L);
	return 0;
}

/**
 版本比较

 @return -1：v1<v2(低版本覆盖)； 0：v1==v2（相同版本）; 1：v1>v2（高版本覆盖低版本）
 */
static int compareVersion(std::vector<int> v1, std::vector<int> v2)
{
    int len1 = (int)v1.size();
    int len2 = (int)v2.size();
    int longestLen = len1;
    // 进行补位
    if (len1 < len2) {
        for (int i = len1 + 1; i <= len2; i++) {
            v1.push_back(0);
        }
        longestLen = len2;
    }else if (len1 > len2) {
        for (int i = len2 + 1; i <= len1; i++) {
            v2.push_back(0);
        }
        longestLen = len1;
    }
    // 比较各位的值
    for (int i = 0; i < longestLen; i++) {
        if (v1[i] > v2[i]) {
            return 1;
        }else if (v1[i] < v2[i]){
            return -1;
        }
    }
    return 0;
}

/**
 分割版本号成数组
 
 @param version 版本号: 5.0.0
 @param delim 分割符 .
 @return 数组 [5,0,0]
 */
static std::vector<int> splitVersion(const std::string &version, const std::string &delim)
{
    // 拷贝构造
    std::string version1 = std::string(version);
    // string->char *
    char *c_version = (char *)version1.c_str();
    const char *split = (char *)delim.c_str();
    // 以.为分隔符拆分字符串
    char *p = strtok(c_version, split);
    int a;
    std::vector<int> nums;
    while(p != NULL)
    {
        // char * -> int
        sscanf(p, "%d", &a);
        nums.push_back(a);
        p = strtok(NULL, split);
    }
    return nums;
}

/**
 检测旧版本资源
 */
static void removeOldUpdateResource()
{
    std::string appVersion = Application::getInstance()->getVersion();
    std::string localVersion = UserDefault::getInstance()->getStringForKey("keyLocalVersion", "");
    std::vector<int> v1s = splitVersion(appVersion, ".");
    std::vector<int> v2s = splitVersion(localVersion, ".");
    int ret = compareVersion(v1s, v2s);
    if (ret != 0) { // appVersion != localVersion
        std::string path = FileUtils::getInstance()->getWritablePath();
        FileUtils::getInstance()->removeDirectory(path + "assets/");
        FileUtils::getInstance()->removeDirectory(path + "recordDir/");
        FileUtils::getInstance()->removeDirectory(path + "zipSaveDir/");
        UserDefault::getInstance()->setStringForKey("keyLocalVersion", appVersion);
    }
}
