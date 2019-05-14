
#ifndef __VX_NATIVE_UTILS_H__
#define __VX_NATIVE_UTILS_H__

#include "VxDef.h"
#include "VxConst.h"



class VxNativeUtils
{
public:

	static bool unCompress(const char * pOutFileName, std::string pOutDir,const std::string &password);

	static std::string  callAndroidString(const char* pClass, const char* pMethod, const char* pType);
	static int  callAndroidInteger(const char* pClass, const char* pMethod, const char* pType);


	static void callSystemEvent(int nKey, const char*  sJsonData);

	static void systemCallLuaEvent(int nKey, const char*  sJsonData);

	static std::string getDefaultFontName();
	static void setDefaultFontName(std::string  sFontName);

};

#endif	// __VX_NATIVE_UTILS_H__


