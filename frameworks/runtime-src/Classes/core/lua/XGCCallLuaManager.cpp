#include "XGCCallLuaManager.h"
#include <mutex>
#include <thread>
#include "VxConst.h"
//#include "MsgProtocol.pb.h"
#include "VxNetManager.h"

USING_NS_CC;

#if __cplusplus    
extern "C" {
#endif    
	void ccl_socketEvent(lua_State *L, int nNetSocketId, int eventId, const char * pStr);
	void ccl_recvMsgFromServer(lua_State *L, int nNetSocketId, int msgType, int msgSize,const char * pStr);

	void ccl_downloaderOnTaskProgress(lua_State *L, const std::string &identifier, int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpected);
	void ccl_downloaderOnDataTaskSuccess(lua_State *L, const std::string &identifier, unsigned char* pData, int nSize);
	void ccl_downloaderOnFileTaskSuccess(lua_State *L, const std::string &identifier);
	void ccl_downloaderOnTaskError(lua_State *L, const std::string &identifier, int errorCode, int errorCodeInternal, const std::string& errorStr);

	void ccl_systemCallLuaEvent(lua_State* L, int nKey, const char* sJsonData);

#if __cplusplus    

}

#endif  


class SocketEventData
{
public :
	SocketEventData(int nNetSocketId, int eventId, char *argv, int msgType = -1)
		: m_nNetSocketId(nNetSocketId)
		, m_eventId(eventId)
		, m_argv(argv)
		, m_msgType(msgType)
	{

	}
	int m_nNetSocketId;
	int m_eventId;
	int m_msgType;
	char* m_argv;
};

class RecvMsgData
{
public:
	RecvMsgData(int nNetSocketId, int msgType, int msgSize,char *argv)
		: m_nNetSocketId(nNetSocketId)
		, m_argv(argv)
		, m_msgType(msgType)
		, m_msgSize(msgSize)
	{

	}
	int m_nNetSocketId;
	int m_msgType;
	int m_msgSize;
	char* m_argv;

};


class NaticeEventData
{
public:
	NaticeEventData(int key, const char *argv)
		: m_key(key)
		, m_sData(argv)
	{

	}

	int m_key;
	std::string m_sData;
};


static std::mutex s_mutex;
static std::mutex s_tempMutex;
static std::mutex s_eventDataMutex;

static std::list<SocketEventData> s_socketDataList;
static std::list<SocketEventData> s_socketTempDataList;
static std::list<RecvMsgData> s_recvMsgDataList;
static std::list<NaticeEventData> s_eventDataList;



XGCCallLuaManager::XGCCallLuaManager()
	:m_pLuaState(nullptr)
	, m_bCallingSocketEvent(false)
{
	Director::getInstance()->getScheduler()->schedule(schedule_selector(XGCCallLuaManager::loop),this,0,false);
	//schedule_selector(XGCCallLuaManager::loop), this, 0, false
}

XGCCallLuaManager::~XGCCallLuaManager()
{
}

void XGCCallLuaManager::loop(float dt)
{
	
	if (!s_socketDataList.empty())
	{
		m_bCallingSocketEvent = true;
		for (auto it = s_socketDataList.begin(); it != s_socketDataList.end(); it++)
		{
			ccl_socketEvent(m_pLuaState, it->m_nNetSocketId, it->m_eventId, it->m_argv);
		}
		m_bCallingSocketEvent = false;

		{
			std::lock_guard<std::mutex> lk(s_mutex);
			s_socketDataList.clear();
		}

		if (!s_socketTempDataList.empty())
		{
			for (auto it = s_socketTempDataList.begin(); it != s_socketTempDataList.end(); it++)
			{
				//s_socketDataList.push_back(*it);
				ccl_socketEvent(m_pLuaState, it->m_nNetSocketId, it->m_eventId, it->m_argv);
			}
			
		}
		clearSocketTempEventData();
	}


	if (!s_recvMsgDataList.empty())
	{
		for (auto it = s_recvMsgDataList.begin(); it != s_recvMsgDataList.end(); it++)
		{
			ccl_recvMsgFromServer(m_pLuaState, it->m_nNetSocketId, it->m_msgType, it->m_msgSize, it->m_argv);
			VxNetManager::getInstance()->continueToRecv(it->m_nNetSocketId);
			delete[] it->m_argv;
		}
		std::lock_guard<std::mutex> lk(s_mutex);
		s_recvMsgDataList.clear();

		
	}


	{
		
		//CCLOG("**s_eventDataList");
		std::lock_guard<std::mutex> lk(s_eventDataMutex);
		for (auto it = s_eventDataList.begin(); it != s_eventDataList.end(); it++)
		{
			//CCLOG("**s_eventDataList %d", (*it).m_key);
			ccl_systemCallLuaEvent(m_pLuaState, (*it).m_key, (*it).m_sData.c_str());
		}
		
		s_eventDataList.clear();
	}
	
}

void XGCCallLuaManager::setLuaState(lua_State *L)
{
	m_pLuaState = L;
}

void XGCCallLuaManager::clearSocketTempEventData()
{
	std::lock_guard<std::mutex> lk(s_tempMutex);
	s_socketTempDataList.clear();
}

void XGCCallLuaManager::addSocketTempEventData(int nNetSocketId, int eventId, void* argv)
{
	std::lock_guard<std::mutex> lk(s_tempMutex);
	s_socketTempDataList.push_back(SocketEventData(nNetSocketId, eventId, (char*)argv));
}


void XGCCallLuaManager::addSocketEventData(int nNetSocketId, int eventId, void* argv)
{
	
	std::lock_guard<std::mutex> lk(s_mutex);
	s_socketDataList.push_back(SocketEventData(nNetSocketId, eventId, (char*)argv));
}


void XGCCallLuaManager::socketEvent(int nNetSocketId, int eventId, void* argv)
{
	if (eventId != VXSOCKET_EVENT_RECV && eventId != VXSOCKET_EVENT_SEND)
	{
		if (argv == nullptr)
		{
			argv = (void*)"";
		}
		if (m_bCallingSocketEvent)
		{
			addSocketTempEventData(nNetSocketId, eventId, argv);
		}
		else
		{
			addSocketEventData(nNetSocketId, eventId, argv);
		}
	}
}

void XGCCallLuaManager::recvMsg(int nNetSocketId, int msgType, int msgSize,char* argv)
{
	std::lock_guard<std::mutex> lk(s_mutex);

	char* pData = new char[msgSize];
	memcpy(pData, argv, msgSize);
	s_recvMsgDataList.push_back(RecvMsgData(nNetSocketId, msgType, msgSize,(char*)pData));



	//ccl_recvMsgFromServer(m_pLuaState, nNetSocketId, msgType, msgSize, (const char*)argv);
}



void XGCCallLuaManager::downloaderOnTaskProgress(const std::string &identifier, int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpected)
{
	ccl_downloaderOnTaskProgress(m_pLuaState,identifier,  bytesReceived,  totalBytesReceived,  totalBytesExpected);
}

void XGCCallLuaManager::downloaderOnDataTaskSuccess(const std::string &identifier,  unsigned char* pData, int nSize)
{
	ccl_downloaderOnDataTaskSuccess(m_pLuaState, identifier, pData, nSize);
}

void XGCCallLuaManager::downloaderOnFileTaskSuccess(const std::string &identifier)
{
	ccl_downloaderOnFileTaskSuccess(m_pLuaState, identifier);
}

void XGCCallLuaManager::downloaderOnTaskError(const std::string &identifier, int errorCode, int errorCodeInternal, const std::string& errorStr)
{
	ccl_downloaderOnTaskError(m_pLuaState, identifier, errorCode, errorCodeInternal, errorStr);
}


void XGCCallLuaManager::systemCallLuaEvent(int nKey,const char*sJsonData)
{
	if (!m_pLuaState)
	{
		CCLOG("Lua engine not start!");
		return;
	}

	{
		std::lock_guard<std::mutex> lk(s_eventDataMutex);
		s_eventDataList.push_back(NaticeEventData(nKey, sJsonData));
	}
}
