#include "VxNativeUtils.h" 
#include "XGCCallLuaManager.h"

#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <unistd.h>
#elif CC_PLATFORM_IOS == CC_TARGET_PLATFORM
#include "IosLuaCallManager.h"
#endif

#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else // from our embedded sources
#include "unzip.h"
#endif

#define BUFFER_SIZE    8192
#define MAX_FILENAME   512


static std::string s_sDefaultFontName = "";

bool VxNativeUtils::unCompress(const char * pOutFileName, std::string  pOutDir, const std::string &password)
{
	if (!pOutFileName) {
		CCLOG("unCompress() - invalid arguments");
		return 0;
	}
	FileUtils *utils = FileUtils::getInstance();
	std::string outFileName = utils->fullPathForFilename(pOutFileName);
	// 打开压缩文件  
	unzFile zipfile = unzOpen(outFileName.c_str());
	if (!zipfile)
	{
		CCLOG("can not open downloaded zip file %s", outFileName.c_str());
		return false;
	}
	// 获取zip文件信息  
	unz_global_info global_info;
	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLOG("can not read file global info of %s", outFileName.c_str());
		unzClose(zipfile);
		return false;
	}
	// 临时缓存，用于从zip中读取数据，然后将数据给解压后的文件  
	char readBuffer[BUFFER_SIZE];
	//开始解压缩  
	CCLOG("start uncompressing");
	//根据自己压缩方式修改文件夹的创建方式  
	std::string storageDir;
	int pos = outFileName.find_last_of("/");
	storageDir = outFileName.substr(0, pos);

	if (!pOutDir.empty())
	{
		storageDir = pOutDir;
	}


	//    FileUtils::getInstance()->createDirectory(storageDir);  

	// 循环提取压缩包内文件  
	// global_info.number_entry为压缩包内文件个数  
	uLong i;
	for (i = 0; i < global_info.number_entry; ++i)
	{
		// 获取压缩包内的文件名  
		unz_file_info fileInfo;
		char fileName[MAX_FILENAME];
		if (unzGetCurrentFileInfo(zipfile,
			&fileInfo,
			fileName,
			MAX_FILENAME,
			NULL,
			0,
			NULL,
			0) != UNZ_OK)
		{
			CCLOG("can not read file info");
			unzClose(zipfile);
			return false;
		}

		//该文件存放路径  
		std::string fullPath = storageDir + "/" + fileName;

		// 检测路径是文件夹还是文件  
		const size_t filenameLength = strlen(fileName);
		if (fileName[filenameLength - 1] == '/')
		{
			// 该文件是一个文件夹，那么就创建它  
			if (!FileUtils::getInstance()->createDirectory(fullPath.c_str()))
			{
				CCLOG("can not create directory %s", fullPath.c_str());
				unzClose(zipfile);
				return false;
			}
		}
		else
		{
			// 该文件是一个文件，那么就提取创建它  
			if (password.empty())
			{
				if (unzOpenCurrentFile(zipfile) != UNZ_OK)
				{
					CCLOG("can not open file %s", fileName);
					unzClose(zipfile);
					return false;
				}
			}
			else
			{
				if (unzOpenCurrentFilePassword(zipfile, password.c_str()) != UNZ_OK)
				{
					CCLOG("can not open file %s", fileName);
					unzClose(zipfile);
					return false;
				}
			}

			// 创建目标文件  
			FILE *out = fopen(fullPath.c_str(), "wb");
			if (!out)
			{
				CCLOG("can not open destination file %s", fullPath.c_str());
				unzCloseCurrentFile(zipfile);
				unzClose(zipfile);
				return false;
			}

			// 将压缩文件内容写入目标文件  
			int error = UNZ_OK;
			do
			{
				error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
				if (error < 0)
				{
					CCLOG("can not read zip file %s, error code is %d", fileName, error);
					unzCloseCurrentFile(zipfile);
					unzClose(zipfile);
					return false;
				}
				if (error > 0)
				{
					fwrite(readBuffer, error, 1, out);
				}
			} while (error > 0);

			fclose(out);
		}
		//关闭当前被解压缩的文件  
		unzCloseCurrentFile(zipfile);

		// 如果zip内还有其他文件，则将当前文件指定为下一个待解压的文件  
		if ((i + 1) < global_info.number_entry)
		{
			if (unzGoToNextFile(zipfile) != UNZ_OK)
			{
				CCLOG("can not read next file");
				unzClose(zipfile);
				return false;
			}
		}
	}
	//压缩完毕  
	CCLOG("end uncompressing");

	//压缩完毕删除zip文件，删除前要先关闭  
	unzClose(zipfile);
	if (remove(outFileName.c_str()) != 0)
	{
		CCLOG("can not remove downloaded zip file %s", outFileName.c_str());
	}
	return true;
}



std::string  VxNativeUtils::callAndroidString(const char* pClass, const char* pMethod, const char* pType)
{
	std::string sRet = "";
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
	JniMethodInfo methodInfo;
	if (JniHelper::getStaticMethodInfo(methodInfo, pClass, pMethod, pType))
	{
		jstring result = (jstring)methodInfo.env->CallStaticObjectMethod(methodInfo.classID, methodInfo.methodID);
		sRet = methodInfo.env->GetStringUTFChars(result, 0);
		methodInfo.env->DeleteLocalRef(result);
		methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}
	CCLOG("callAndroidString %s", sRet.c_str());
#else
#endif
	return sRet;
}


int  VxNativeUtils::callAndroidInteger(const char* pClass, const char* pMethod, const char* pType)
{
	int nRet = 1;
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
	JniMethodInfo methodInfo;
	if (JniHelper::getStaticMethodInfo(methodInfo, pClass, pMethod, pType))
	{
		nRet = (int)methodInfo.env->CallStaticObjectMethod(methodInfo.classID, methodInfo.methodID);
		methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}
	CCLOG("callAndroidInterger %d", nRet);
#endif
	return nRet;
}

void VxNativeUtils::callSystemEvent(int nKey, const char* sJsonData)
{
#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM

	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo, "com/boyaa/entity/luaManager/LuaCallManager", "callEvent", "(ILjava/lang/String;)V"))
	{
		
		jstring stringArg2 = minfo.env->NewStringUTF(sJsonData);
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, nKey, stringArg2);
		minfo.env->DeleteLocalRef(stringArg2);
		minfo.env->DeleteLocalRef(minfo.classID);
	}
#elif CC_PLATFORM_IOS == CC_TARGET_PLATFORM
    
    IosLuaCallManager::getInstance()->callEvent(nKey, sJsonData);

#endif
}

void VxNativeUtils::systemCallLuaEvent(int nKey, const char* sJsonData)
{
	XGCCallLuaManager::getInstance()->systemCallLuaEvent(nKey, sJsonData);
}



std::string VxNativeUtils::getDefaultFontName()
{
	return s_sDefaultFontName;
}
 
void VxNativeUtils::setDefaultFontName(std::string  sFontName)
{
	s_sDefaultFontName = sFontName;
}


#if CC_PLATFORM_ANDROID == CC_TARGET_PLATFORM
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
extern "C"
{
	void __attribute__((visibility("default"))) Java_com_boyaa_entity_luaManager_LuaCallManager_systemCallLuaEvent(JNIEnv*  env, jobject thiz, jint nKey, jstring sJsonData)
	{
		/*Get the native string from javaString*/
		const char *nativeString = (env)->GetStringUTFChars(sJsonData, 0);


		VxNativeUtils::systemCallLuaEvent(nKey, nativeString);
		

		/*DON'T FORGET THIS LINE!!!*/
		(env)->ReleaseStringUTFChars(sJsonData, nativeString);

	}



}
#endif
