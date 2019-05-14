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
#include "lua_byte_data_manual.hpp"

#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/cocos2d/LuaScriptHandlerMgr.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "base/CCEventListenerFocus.h"
#include "VxConvert.h"
#include "XGByteData.h"
#include "lua_read_bytedata_manual.hpp"




static inline void
_pushByteData(lua_State *L, XGByteData *n) {

	object_to_luaval<XGByteData>(L, "ByteData", n);

}


static int
ByteData_self_add(lua_State *L) {

	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);

	//XGByteData* b = (XGByteData*)tolua_tousertype(L, 2, 0);
	size_t len = 0;
	const uint8_t * str = (const uint8_t *)lua_tolstring(L, 2, &len);

	a->writeData(str,len);


	_pushByteData(L, a);

	return 1;
}


static int
ByteData_add(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);
	XGByteData* b = (XGByteData*)tolua_tousertype(L, 2, 0);

	XGByteData* c = new XGByteData(a->m_capacity+b->m_capacity);

	c->add(a);
	c->add(b);

	_pushByteData(L, c);

	return 1;
}



static int
bytedata_new(lua_State *tolua_S) {
	int argc = 0;
	bool ok = true;


	argc = lua_gettop(tolua_S) - 1;

	if (argc == 0)
	{

		XGByteData* ret = new XGByteData();
		object_to_luaval<XGByteData>(tolua_S, "ByteData", (XGByteData*)ret);
		return 1;
	}
	else if (argc == 1)
	{

		lua_Number size = lua_tonumber(tolua_S, 2);

		XGByteData* ret = new XGByteData(size);

		object_to_luaval<XGByteData>(tolua_S, "ByteData", (XGByteData*)ret);
		return 1;
	}
	

	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "XGByteData:create", argc, 1);
	return 0;
}





static int
writeInt32(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);
	lua_Number b = lua_tonumber(L, 2);

	a->writeInt(b);

	_pushByteData(L, a);

	return 1;
}

static int
writeInt64(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);
	lua_Number b = lua_tonumber(L, 2);

	a->writeInt64(b);

	_pushByteData(L, a);

	return 1;
}


static int
writeByte(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);
	lua_Number b = lua_tonumber(L, 2);

	a->writeByte(b);

	_pushByteData(L, a);

	return 1;
}

static int
writeShort(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);
	lua_Number b = lua_tonumber(L, 2);

	a->writeShort(b);

	_pushByteData(L, a);

	return 1;
}

static int
writeData(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);
	const  char* pData = "";
	int nSize = 0;

	if (lua_isstring(L, 2))
	{
		pData = lua_tostring(L, 2);
	}

	if (lua_isnumber(L, 3))
	{
		nSize = lua_tointeger(L, 3);
	}


	a->writeData((const unsigned char*)pData, nSize);

	_pushByteData(L, a);

	return 1;
}


static int
getData(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);

	lua_pushlstring(L, (const char*)a->getBuffer(), a->getLenght());

	return 1;
}

static int
getLength(lua_State *L) {
	XGByteData* a = (XGByteData*)tolua_tousertype(L, 1, 0);

	lua_pushinteger(L, a->getLenght());


	return 1;
}


static int registerByteData(lua_State* L)
{
	tolua_usertype(L, "ByteData");
	tolua_cclass(L, "ByteData", "ByteData", "", nullptr);

	tolua_beginmodule(L, "ByteData");

	tolua_function(L, "new", bytedata_new);
	tolua_function(L, "add", ByteData_self_add);
	tolua_function(L, "__add", ByteData_add);

	tolua_function(L, "writeInt32", writeInt32);
	tolua_function(L, "writeInt64", writeInt64);
	tolua_function(L, "writeByte", writeByte);
	tolua_function(L, "writeShort", writeShort);
	tolua_function(L, "writeData", writeData);
	tolua_function(L, "getData", getData);
	tolua_function(L, "getLength", getLength);
	//tolua_function(L, "__gc", uint256_delete);
	

	tolua_endmodule(L);
	std::string typeName = typeid(XGByteData).name();
	g_luaType[typeName] = "ByteData";
	g_typeCast["ByteData"] = "ByteData";
	return 1;

}




int register_byte_data_manual(lua_State* L)
{
	tolua_open(L);

	tolua_module(L, "by", 0);
	tolua_beginmodule(L, "by");


	registerByteData(L);
	register_read_bytedata_manual(L);

	tolua_endmodule(L);

    return 0;
}
