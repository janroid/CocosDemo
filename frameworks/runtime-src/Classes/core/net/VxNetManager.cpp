
#include "VxNetManager.h"
#include "VxNetClient.h"
#include "VxMsg.h"
#include "VxStream.h"
#include "NxProtocol.h"
#include "VxBlockAllocator.h"
#include "VxDef.h"




#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
static int init_win_socket()
{
	static bool hasInit = false;
	if (!hasInit)
	{	
		hasInit = true;
		WSADATA wsaData;
		if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0)
		{
			return -1;
		}
		return 0;
	}
	else
	{
		return 0;
	}
}
#endif

VxNetManager::VxNetManager()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	init_win_socket();
#endif

	s_alloc = new VxBlockAllocator();
	//s_alloc = new VxAllocator();
	s_alloc->init();
	VxAlloc::setAlloc(s_alloc);

	Director::getInstance()->getScheduler()->schedule(schedule_selector(VxNetManager::loop), this, 0, false);
}

VxNetManager::~VxNetManager()
{

	Director::getInstance()->getScheduler()->unschedule(schedule_selector(VxNetManager::loop), this);
	delete s_alloc;

	if (!s_sNetMap.empty())
	{
		for (auto it = s_sNetMap.begin(); it != s_sNetMap.end(); it++)
		{
			if (it->second->isDeleteAvailable())
			{
				delete it->second;
			}
		}
	}
	
}

void VxNetManager::connectToServer(int nNetSocketId, std::string sIp, short port, int nProtocal)
{
	printf("connectToServer connect server %d\n", nNetSocketId);
	if (!hasConnectServer(nNetSocketId))
	{

		std::lock_guard<std::mutex> lk(m_managerMutex);
	
		//s_sNetMap[sServerName] = VxNetAddress(sServerName,sIp, port);
		
		s_sNetMap[nNetSocketId] =  new VxNetClient(nNetSocketId, sIp.c_str(), port, nProtocal);
	
		s_sNetMap[nNetSocketId]->registerEventCb(VxNetManager::socketEventCallback, s_sNetMap[nNetSocketId]);

		s_sNetMap[nNetSocketId]->connect();

	}
	else
	{

		printf("connectToServer has connect server %d\n", nNetSocketId);

		disconnectToServer(nNetSocketId);
		connectToServer(nNetSocketId, sIp, port);

	}
}

void VxNetManager::disconnectToServer(int nNetSocketId)
{
	VxNetClient* pNetClient = nullptr;
	{
		lock_guard<std::mutex> lock(s_sRemoveMutex);

		auto it = s_sNetMap.find(nNetSocketId);


		if (it != s_sNetMap.end())
		{
			pNetClient = it->second;

			s_sNetMap.erase(it);

			//CC_SAFE_DELETE(it->second);

			s_sRemoveNetMap.push_back(pNetClient);
			printf("disconnectToServer  server %d\n", nNetSocketId);
		}
		else
		{
			printf("disconnectToServer  server %d not exist\n", nNetSocketId);
		}
	}
	

	if (pNetClient)
	{
		pNetClient->close();
	}
}


bool VxNetManager::hasConnectServer(int nNetSocketId)
{
	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		return true;
	}
	
	return false;
}





void VxNetManager::sendMsgToServer(int nNetSocketId, int msgType, const char* sMsgData,int nMsgSize)
{


	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		//VxMsgNetSendStream* pSendStream = createStream(msgType, nMsgSize, sMsgData);

		it->second->send(msgType, nMsgSize, sMsgData);
		//return true;
	}

}


void VxNetManager::socketEventCallback(void* pArg, int eEventId, void *pvEventArgs)
{
	VxNetClient* pClient = (VxNetClient*)pArg;
	//VXASSERT(0 <= nSocketId && nSocketId < NX_NET_SOCKET_MAXCOUNT, "");
	//VxNetClient* pClient = s_pNetData[nSocketId].m_pClient;
	VX_RETURN_IF(!pClient);

	switch (eEventId)
	{
	case VXSOCKET_EVENT_CONNECT_BEGIN:
		break;
	case VXSOCKET_EVENT_CONNECT_COMPLETE:
		break;
	case VXSOCKET_EVENT_CONNECT_FAILED:
	case VXSOCKET_EVENT_CLOSED:
		VxNetManager::getInstance()-> disconnectToServer(pClient->m_nNetSocketId);
		//NxNetManager::socketEventAsyncCallback(pArg, eEventId, pvEventArgs);
		break;
	default:
		break;
	}
}


bool VxNetManager::enableTLS(int nNetSocketId, bool bEnable)
{
	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		return it->second->enableTLS(bEnable);
	}
	return false;
}

bool VxNetManager::enableCompress(int nNetSocketId, bool bEnable)
{
	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		return it->second->enableCompress(bEnable);
	}
	return false;
}

bool VxNetManager::continueToRecv(int nNetSocketId)
{
	auto it = s_sNetMap.find(nNetSocketId);
	if (it != s_sNetMap.end())
	{
		return it->second->continueToRecv();
	}
	return false;
}


void VxNetManager::loop(float dt)
{
	if (!s_sRemoveNetMap.empty())
	{
		for (auto it = s_sRemoveNetMap.begin(); it != s_sRemoveNetMap.end(); it++)
		{
			if ((*it)->isDeleteAvailable())
			{
				CC_SAFE_DELETE(*it);
				{
					lock_guard<std::mutex> lock(s_sRemoveMutex);
					s_sRemoveNetMap.erase(it);
				}

				break;
			}
		}
	}
	
	if (!s_sNetMap.empty())
	{
		for (auto it = s_sNetMap.begin(); it != s_sNetMap.end(); it++)
		{
			it->second->loop(dt);
		}
	}

}
