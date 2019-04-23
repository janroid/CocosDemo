#ifndef __XG_IOS_LUA_CALL_MANAGER_H__
#define __XG_IOS_LUA_CALL_MANAGER_H__

#include <iostream>

class IosLuaCallManager
{
public:
    static IosLuaCallManager* getInstance();
    IosLuaCallManager();
    virtual ~IosLuaCallManager();
    virtual void init();
    
    /**
     Lua 调用 OC
     
     @param nKey key
     @param pData 传递数据
     */
    virtual void callEvent(int nKey,const char* pData);
    
    /**
     OC 调用 Lua
     
     @param nKey key
     @param pData 传递数据
     */
    void systemCallLua(int nKey,const char* pData);
};

#endif
