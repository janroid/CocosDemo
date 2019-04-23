
#include "IosLuaCallManager.h"
#include "VxNativeUtils.h"
#include "LuaOCBridge.h"


static IosLuaCallManager* s_pInstance = nullptr;

IosLuaCallManager* IosLuaCallManager::getInstance()
{
    if (!s_pInstance){
        s_pInstance = new IosLuaCallManager();
    }
    return s_pInstance;
}


IosLuaCallManager::IosLuaCallManager()
{
}

IosLuaCallManager::~IosLuaCallManager(){}

void IosLuaCallManager::init()
{
    
}

void IosLuaCallManager::callEvent(int nKey,const char* pData)
{
    [[LuaOCBridge shareInstance] luaCallOc:nKey data:pData];
}

void IosLuaCallManager::systemCallLua(int nKey,const char* pData)
{
    VxNativeUtils::systemCallLuaEvent(nKey, pData);
}
