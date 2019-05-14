/****************************************************************************
 Copyright (c) 2017 Chukong Technologies Inc.
 
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
#include "lua_read_bytedata_manual.hpp"

#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/cocos2d/LuaScriptHandlerMgr.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "base/CCEventListenerFocus.h"
#include "VxConvert.h"
#include "XGReadByteData.h"




static inline void
_pushReadByteData(lua_State *L, XGReadByteData *n) {

	object_to_luaval<XGReadByteData>(L, "ReadByteData", n);

}

static int
ReadByteData_new(lua_State *tolua_S) {
	int argc = 0;
	bool ok = true;


	argc = lua_gettop(tolua_S) - 1;



	if (argc == 2)
	{
		const char* pData = "";
		pData = lua_tostring(tolua_S, 2);
		lua_Number size = lua_tonumber(tolua_S, 3);

		XGReadByteData* ret = new XGReadByteData((unsigned char*)pData,size);//(XGReadByteData*)lua_newuserdata(tolua_S, sizeof(XGReadByteData));

	
		object_to_luaval<XGReadByteData>(tolua_S, "ReadByteData", (XGReadByteData*)ret);
		return 1;
	}
	

	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "ReadByteData:create", argc, 2);
	return 0;
}





static int
readInt32(lua_State *L) {
	XGReadByteData* a = (XGReadByteData*)tolua_tousertype(L, 1, 0);


	int r = a->readInt();

	lua_pushinteger(L,r);

	return 1;
}

static int
readInt64(lua_State *L) {
	XGReadByteData* a = (XGReadByteData*)tolua_tousertype(L, 1, 0);
	lua_pushnumber(L, a->readInt64());

	return 1;
}


static int
readByte(lua_State *L) {
	XGReadByteData* a = (XGReadByteData*)tolua_tousertype(L, 1, 0);


	lua_pushinteger(L, (char)a->readByte());

	return 1;
}

static int
readShort(lua_State *L) {
	XGReadByteData* a = (XGReadByteData*)tolua_tousertype(L, 1, 0);

	lua_pushinteger(L, a->readShort());

	return 1;
}

static int
readData(lua_State *L) {
	XGReadByteData* a = (XGReadByteData*)tolua_tousertype(L, 1, 0);

	lua_Number size = lua_tonumber(L, 2);

	const unsigned char* pData = a->readData(size);
	
	lua_pushlstring(L, (const char*)pData, size);

	return 1;
}


static int
getLength(lua_State *L) {
	XGReadByteData* a = (XGReadByteData*)tolua_tousertype(L, 1, 0);

	lua_pushinteger(L, a->getLenght());

	return 1;
}


int registerReadByteData(lua_State* L)
{
	tolua_usertype(L, "ReadByteData");
	tolua_cclass(L, "ReadByteData", "ReadByteData", "", nullptr);

	tolua_beginmodule(L, "ReadByteData");

	tolua_function(L, "new", ReadByteData_new);


	tolua_function(L, "readInt32", readInt32);
	tolua_function(L, "readInt64", readInt64);
	tolua_function(L, "readByte", readByte);
	tolua_function(L, "readShort", readShort);
	tolua_function(L, "readData", readData);
	tolua_function(L, "getLength", getLength);
	//tolua_function(L, "__gc", uint256_delete);
	

	tolua_endmodule(L);
	std::string typeName = typeid(XGReadByteData).name();
	g_luaType[typeName] = "ReadByteData";
	g_typeCast["ReadByteData"] = "ReadByteData";
	return 1;

}




int register_read_bytedata_manual(lua_State* L)
{


	registerReadByteData(L);

    return 0;
}
