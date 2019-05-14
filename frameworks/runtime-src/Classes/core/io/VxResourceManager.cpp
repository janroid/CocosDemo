
#include "VxResourceManager.h"
#include "XGCCallLuaManager.h"
#include "VxFile.h"
#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else // from our embedded sources
#include "unzip.h"
#endif

#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

USING_NS_CC;

VxResourceManager::VxResourceManager()
{
	//m_downloader.reset(new network::Downloader());
	//this->createDownloader();
	//std::string  writeablePath = FileUtils::getInstance()->getWritablePath();
	//m_downloaderPath = writeablePath + "/update/";
	//m_updateZipFile = "temp_update.zip";

	//if (FileUtils::getInstance()->isFileExist(m_downloaderPath + m_updateZipFile))

	{
		//this->unCompress((m_downloaderPath + m_updateZipFile).c_str(), "");
	}
	//

	/*auto updateResPath = FileUtils::getInstance()->getWritablePath() + "assets/res";
	if (!FileUtils::sharedFileUtils()->isDirectoryExist(updateResPath))
	{
		FileUtils::sharedFileUtils()->createDirectory(updateResPath);
	}
	

	auto updateSrcPath = FileUtils::getInstance()->getWritablePath() + "assets/src";
	if (!FileUtils::sharedFileUtils()->isDirectoryExist(updateSrcPath))
	{
		FileUtils::sharedFileUtils()->createDirectory(updateSrcPath);
	}*/
}

void VxResourceManager::init()
{
	load();
}

VxResourceManager::~VxResourceManager()
{
	clear();
}


void VxResourceManager::clear()
{
	//m_downloader.reset();
	if (!m_sFileDatas.empty())
	{
		for (auto it = m_sFileDatas.begin(); it != m_sFileDatas.end(); it++)
		{
			delete it->second;
		}
		m_sFileDatas.clear();
	}

	if (!m_sResFileDatas.empty())
	{
		for (auto it = m_sResFileDatas.begin(); it != m_sResFileDatas.end(); it++)
		{
			delete it->second;
		}
		m_sResFileDatas.clear();
	}

	if (!m_sResEmptyFileDatas.empty())
	{
		for (auto it = m_sResEmptyFileDatas.begin(); it != m_sResEmptyFileDatas.end(); it++)
		{
			delete it->second;
		}
		m_sResEmptyFileDatas.clear();
	}

	if (!m_sUpdateFileDatas.empty())
	{
		for (auto it = m_sUpdateFileDatas.begin(); it != m_sUpdateFileDatas.end(); it++)
		{
			delete[] it->second->m_pData;
			delete it->second;
		}
		m_sUpdateFileDatas.clear();
	}


}



bool VxResourceManager::unCompress(const char * pOutFileName, const std::string &password)
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


static long lcc_getmicrosecond() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	long microsecond = tv.tv_sec * 1000000 + tv.tv_usec;
	return microsecond;
}


static long lcc_getmillisecond() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	long millisecond = (tv.tv_sec * 1000000 + tv.tv_usec) / 1000;

	return millisecond;
}


void VxResourceManager::load()
{
	clear();
	long ns = lcc_getmillisecond();
	CCLOG("****load start %ld", ns);

	CCLOG("****load start res");
	parse("resinfo", "resdata", m_sResFileDatas, m_sResData, 0xe7);
	CCLOG("****load start src");
	parse("srcinfo", "srcdata", m_sFileDatas, m_sData, 0xe7);
	//parse("resImginfo", "resImg", m_sResEmptyFileDatas, m_sResEmptyData, 0xe7);
	CCLOG("****load start end");
	//parseSrcData("srcinfo", "srcdata");

	
	char sTempPng[200] = { 0 };

	for (int i = 0; i < 10; i++)
	{
		char sTempPlist[200] = { 0 };
		//memset(sTempPlist, 0, 200);
		memset(sTempPng, 0, 200);
		sprintf(sTempPlist, "tex%d.plist", i);
		sprintf(sTempPng, "tex%d.png", i);
		if (FileUtils::getInstance()->isFileExist(sTempPng))
		{
			SpriteFrameCache::getInstance()->addSpriteFramesWithFile(sTempPlist);
			Director::getInstance()->getTextureCache()->addImage(sTempPng);
			//Director::getInstance()->getTextureCache()->addImageAsync(sTempPng, [&](cocos2d::Texture2D *texture) {
			
			//	SpriteFrameCache::getInstance()->addSpriteFramesWithFile(sTempPlist);
			//});
		}
		else
		{
			break;
		}
	}
	CCLOG("****load end %d", lcc_getmillisecond()- ns);
}

const unsigned char* XGGetFileData(const std::string &sKey, ssize_t &nSize)
{
	return VxResourceManager::getInstance()->getFileData(sKey, nSize);
}


const unsigned char* VxResourceManager::getFileData(std::string sKey, ssize_t &nSize)
{

	if (!FileUtils::getInstance()->isAbsolutePath(sKey))
	{
		//is in update cache
		if (!m_sUpdateFileDatas.empty())
		{
			auto it = m_sUpdateFileDatas.find(sKey);
			if (it != m_sUpdateFileDatas.end())
			{
				nSize = it->second->m_nLen;
				return it->second->m_pData;
			}
		}
		
		// update path
		auto updateSrcPath = FileUtils::getInstance()->getWritablePath() + "assets/src/"+ sKey;
		if (VxFile::isFileExist(updateSrcPath.c_str()))
		{
			unsigned char* pData = VxFile::createFileData(updateSrcPath.c_str(),"rb", (unsigned long*)&nSize);
			if (pData)
			{
				m_sUpdateFileDatas[sKey] = new VxDataInfo(pData, nSize);
				return pData;
			}
		}
		
		
		auto updateResPath = FileUtils::getInstance()->getWritablePath() + "assets/res/" + sKey;
		if (VxFile::isFileExist(updateResPath.c_str()))
		{
			unsigned char* pData = VxFile::createFileData(updateResPath.c_str(), "rb", (unsigned long*)&nSize);
			if (pData)
			{
				m_sUpdateFileDatas[sKey] = new VxDataInfo(pData, nSize);
				return pData;
			}
		}
	}
	

#if 1
	std::map<std::string, VxFileInfo*>::iterator it = m_sFileDatas.find(sKey);
	if (m_sFileDatas.end() != it)
	{
		//XGFileInfo* pInfo = it->second;
		nSize = it->second->m_nLen;
		return m_sData.getBytes() + it->second->m_nOffset;
	}
	else
	{
		std::map<std::string, VxFileInfo*>::iterator it = m_sResFileDatas.find(sKey);
		if (m_sResFileDatas.end() != it)
		{
			nSize = it->second->m_nLen;
			return m_sResData.getBytes() + it->second->m_nOffset;
		}
	}


	std::map<std::string, VxFileInfo*>::iterator itEmpty = m_sResEmptyFileDatas.find(sKey);
	if (m_sResEmptyFileDatas.end() != itEmpty)
	{
		//SpriteFrame *frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(sKey);
		//if (!frame)
		//{
			nSize = itEmpty->second->m_nLen;
			return m_sResEmptyData.getBytes() + itEmpty->second->m_nOffset;
		//}
	}

#else
	return	CCFileUtils::sharedFileUtils()->getFileData(sKey.c_str(), "rb", &nSize);
#endif

	return NULL;
}

static void  readFileInfo(std::string sContent,std::string& pTem,int &len )
{
	
	//sscanf(sContent.c_str(), "%d", &len);
	int index = sContent.rfind(' ');

	pTem = sContent.substr(0, index);

	sscanf(sContent.substr(index+1).c_str() , "%d", &len);



}

void VxResourceManager::parse(std::string infoName, std::string dataName, std::map<std::string, VxFileInfo*>& sFileDatas, Data& sData, unsigned char argv)
{
	//static bool hasParse = false;
	//XG_RETURN_IF(hasParse);
	//hasParse = true;

	//MessageBox("XGResourceMananger::parse", "");
	ssize_t nSize;
	unsigned char* pFileInfo = nullptr;
	//unsigned char* pFileInfo = nullptr;
	std::string sFileInfo;
	std::string sWritePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	std::string sFileName = dataName;

	if (CCFileUtils::sharedFileUtils()->isFileExist((sWritePath + sFileName).c_str()))
	{
		sData = CCFileUtils::getInstance()->getDataFromFile(dataName);//CCFileUtils::sharedFileUtils()->getFileData((sWritePath+sFileName).c_str(),"rb+",&m_nDataSize);
		
		pFileInfo = CCFileUtils::sharedFileUtils()->getFileData((sWritePath + infoName).c_str(), "r", &nSize);
		//sFileInfo = (char*)
	}
	else if (CCFileUtils::sharedFileUtils()->isFileExist(sFileName.c_str()))
	{
		sData = CCFileUtils::getInstance()->getDataFromFile(dataName);

		pFileInfo = CCFileUtils::sharedFileUtils()->getFileData(infoName, "rb", &nSize);
		
	}

	if (pFileInfo)
	{
		//auto p = new char[nSize + 1];
		//p = (char*)pFileInfo;
		//p[nSize] = '/0';
		sFileInfo.assign((char*)pFileInfo, nSize);
		//delete[] p;
	}


	int nOffset = 0;

	if (!sData.isNull())
	{
		FileUtils::getInstance()->setXGFileDataFunc(XGGetFileData);

		for (int nStart = 0; nStart < sFileInfo.length(); )
		{
			int nPos = sFileInfo.find('\n', nStart);
			if (nPos == std::string::npos)
			{
				break;
			}
			VxFileInfo* pInfo = new VxFileInfo();
			//char pTmp[100] = { 0 };
			std::string sTmp;
			int nLen = 0;

			readFileInfo(sFileInfo.substr(nStart, nPos - nStart), sTmp, nLen);

			

			pInfo->m_sKey = sTmp;
			pInfo->m_nLen = nLen;
			pInfo->m_nOffset = nOffset;
			sFileDatas[sTmp] = pInfo;


			//CCLOG("%s %d %d", pInfo->m_sKey.c_str(), nLen, nOffset);
			nStart = nPos + 1;
			nOffset += nLen;

			{
				unsigned char keys[] = { 0x90,0xac,0x9d,0xfb };

				unsigned char * pBuffer = NULL;
				pBuffer = sData.getBytes() + pInfo->m_nOffset;

				if (pInfo->m_nLen > 4)
				{
					if (pBuffer[nLen - 4] == keys[0] && pBuffer[nLen - 3] == keys[1] && pBuffer[nLen - 2] == keys[2] && pBuffer[nLen - 1] == keys[3])
					{
						//nLen = nLen-4;
						pInfo->m_nLen = pInfo->m_nLen - 4;
						for (int i = 0; i < nLen; i++)
						{
							//pBuffer[i] = pBuffer[i] ^ 0xe3ff;
							pBuffer[i] = pBuffer[i] ^ argv;// 0xe3ff;
						}
					}
					else
					{
						//std::string s = pTmp;// ;
						//s = "file name "+s + " has space character!!!";
						//CCLOG(s.c_str());
					}
				}

				
			}
		}
	}

	CC_SAFE_FREE(pFileInfo);


	//MessageBox(sFileInfo.c_str(), "");
}
