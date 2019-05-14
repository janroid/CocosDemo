
#ifndef __VX_RESOURCE_MANAGER_H__
#define __VX_RESOURCE_MANAGER_H__

#include "VxDef.h"
#include "VxType.h"
#include "network/CCDownloader.h"
#include "VxConst.h"
#include "XGMacros.h"

class VxFileInfo
{
public:
	int m_nOffset;
	int m_nLen;
	std::string m_sKey;
};

class VxDataInfo
{
public:
	VxDataInfo(unsigned char* pData,int nLen)
	{
		m_pData = pData;
		m_nLen = nLen;
	}
	unsigned char* m_pData;
	int m_nLen;
};


class VxResourceManager
{
public:

	XG_SINGLET_DECLARE(VxResourceManager);

	bool unCompress(const char * pOutFileName, const std::string &password);

	void init();
	void clear();
	VxResourceManager();
	~VxResourceManager();

	//void download(std::string &sUrl, std::string &fileName,bool isUpdateZipFile);
	//std::string getUpdatePath();

	void load();
	const unsigned char* getFileData(std::string sKey, ssize_t &nSize);
	void parse(std::string infoName, std::string dataName, std::map<std::string, VxFileInfo*>& sFileDatas,Data& sData,unsigned char argv);

private:
	//void createDownloader();

	//std::unique_ptr<network::Downloader> m_downloader;
	//std::string m_downloaderPath;
	//std::string m_updateZipFile;

	std::map<std::string, VxFileInfo*> m_sFileDatas;
	std::map<std::string, VxFileInfo*> m_sResFileDatas;
	std::map<std::string, VxFileInfo*> m_sResEmptyFileDatas;

	std::map<std::string, VxDataInfo*> m_sUpdateFileDatas;

	Data m_sData;

	Data m_sResData;
	Data m_sResEmptyData;
};

#endif	// __VX_RESOUCE_MANAGER_H__


