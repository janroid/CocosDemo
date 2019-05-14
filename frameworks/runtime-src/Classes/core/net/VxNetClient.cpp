
#include "VxNetClient.h"
#include "VxMsg.h"
#include "VxTime.h"
//#include "VxTimer.h"
//#include "VxEnv.h"
#include "VxLocalObject.h"
#include "VxDef.h"
#include "VxIOStream.h"
#include "XGCCallLuaManager.h"
#include "NxProtocolMatch.h"


#define __VX_NET_CLIENT_USE_MEMORY_BUFFER__

/************************************************************************/
/* VxNetAddress
/************************************************************************/
VxNetAddress::VxNetAddress()
	: m_nPort(0)
	, m_sAddress("")
{
}

VxNetAddress::VxNetAddress(const std::string& sServerName, const std::string& sAddress, int nPort)
	: m_sAddress(sAddress)
	, m_nPort(nPort)
	, m_sServerName(sServerName)
{
}

/************************************************************************/
/* VxNetSendStreamData
/************************************************************************/
class VxNetSendStreamData
{
public:
	VxNetSendStreamData(VxNetSendCb func, void* arg, int startPos, int totalSize)
		: m_func(func), m_arg(arg), m_startPos(startPos), m_sentSize(0), m_totalSize(totalSize), m_lastCallbackTime(0)
	{
	}

	void runEventCb(int eventId, void* eventArg)
	{
		if(m_func)
		{
			int nTime = VxTime::getCurrMilliSecs();
			//if(m_lastCallbackTime + VxEnvNet::getSendEventCbDuration() <= nTime)
			{
				m_lastCallbackTime = nTime;
				//VxMsgManager::dispatchExecMsg(VXMODULE_ID_DATA, (VxFuncPtrAAA)m_func, m_arg, (void*)eventId, eventArg);
			}
			//m_func(m_arg, eventId, eventArg);
		}
	}
public:
	VxNetSendCb m_func;
	void* m_arg;
	int m_totalSize;
	int m_startPos;
	int m_sentSize;
	int64 m_lastCallbackTime;
};


/************************************************************************/
/* VxNetClient
/************************************************************************/

VxNetClient::VxNetClient(int nNetSocketId, const char* addr, unsigned port, int nProtocol)
	//: VxMsgModule(VXMODULE_ID_DYNAMIC)
{
	m_nConnectCount = 0;
	m_nNetSocketId = nNetSocketId;


	if (nProtocol == VX_NET_PROTOCOL_IPOKER)
	{
		m_pProtocol = new NxProtocol();
		CCLOG("VxNetClient ipoker");
	}
	else if(nProtocol == VX_NET_PROTOCOL_MATCH)
	{
		m_pProtocol = new NxProtocolMatch();
		CCLOG("VxNetClient match");
	}
	
	
	m_pProtocol->start(this);

	bool bUseTLS = nProtocol == VX_NET_PROTOCOL_MATCH;
	m_socket = new VxSocketClient(addr, port, bUseTLS);
	m_socket->setInternalBufferSize(VXSOCKETCLIENT_INTERNAL_BUFFER_SIZE);
	m_socket->registerEventCb(VxNetClient::_netClientEventCb, this);

#if defined(__VX_NET_CLIENT_USE_MEMORY_BUFFER__)

#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	m_recvBuffer = new VxCacheIOStream(64, 128);
	m_sendBuffer = new VxCacheIOStream(64, 128);
#else
	m_recvBuffer = new VxCacheIOStream(VXSTREAM_MEMORY_BUFFER_DEFAULT_SIZE);
	m_sendBuffer = new VxCacheIOStream(VXSTREAM_MEMORY_BUFFER_DEFAULT_SIZE);
#endif

#else

#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	m_recvBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str(), 128);
	m_sendBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str(), 128);
#else
	m_recvBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str());
	m_sendBuffer = new VxCacheIOStream(VxPath::createRandomPath().c_str());
#endif

#endif
	m_socket->setRecvBuffer(m_recvBuffer);
	m_socket->setSendBuffer(m_sendBuffer);
	//setMsgProcFunc(VxNetClient::_netClientProcFunc, this);
	//VxMutexManager::create(&m_sSendingListMutex);
	registerEventCb(VxNetClient::_netClientAsyncEventCb, this);
	CCLOG("VxNetClient 5");
}

VxNetClient::~VxNetClient()
{
	//VxMutexManager::destroy(&m_sSendingListMutex);

	{
		std::lock_guard<std::mutex> lk(m_msgMutex);
		for (std::list<VxMsg*>::iterator i = m_msgList.begin(); m_msgList.end() != i; ++i)
		{
			if (*i)
			{
				(*i)->release();
			}
		}
		m_msgList.clear();
	}
	

#if !defined(__VX_NET_CLIENT_USE_MEMORY_BUFFER__)
	VxPath::destroyRandomPath(m_recvBuffer->getIOFilePath());
	VxPath::destroyRandomPath(m_sendBuffer->getIOFilePath());
#endif
	
	VX_SAFE_RELEASE_NULL(m_recvBuffer);
	VX_SAFE_RELEASE_NULL(m_sendBuffer);

	VX_SAFE_DELETE(m_socket);
	VX_SAFE_DELETE(m_pProtocol);

	
}

void VxNetClient::connect()
{
	if(0 == m_nConnectCount)
	{
		VXLOG("VxNetClient::connect, start begin");
		//this->start();
		VXLOG("VxNetClient::connect, start end");
	}
	m_recvBuffer->reset();
	m_sendBuffer->reset();
	++m_nConnectCount;
	m_totalSend = 0;
	m_totalSent = 0;
	m_totalRecv = 0;
	VXLOG("VxNetClient::connect, connect begin");
	m_socket->connect();
	VXLOG("VxNetClient::connect, connect end");

}

void VxNetClient::disconnect()
{
	m_socket->close();
}

void VxNetClient::close()
{
	if (m_socket->state() != VXSOCKET_STATE_CLOSING)
	{
		VXLOG("VxNetClient::close, begin");
		m_socket->close();
		VXLOG("VxNetClient::close, m_socket->close end");

		{
			//VxLocalMutex sLocalMutex(&(m_sSendingListMutex));

			VXLOG("VxNetClient::close, runMsgEventCb VXSOCKET_EVENT_CLOSED");
			runMsgEventCb(VXSOCKET_EVENT_CLOSED, NULL);
			{
				std::lock_guard<std::mutex> lk(m_sSendingListMutex);
				m_sendingList.clear();
			}

		}
		VXLOG("VxNetClient::close, end");
	}

	
}

void VxNetClient::loop(float dt)
{
	
	if (!m_msgList.empty() && m_socket->m_bSendMsgAvailable)
	{
		VxMsgNetSendStream* pMsg = (VxMsgNetSendStream*)m_msgList.front();
		m_socket->send(pMsg->m_stream, pMsg->m_stream->size());
		VXLOG("VxNetClient::loop, VxMsgNetSendStream");
		//popMsg();
	}
}

void VxNetClient::send(VxMsgNetSendStream* sendObject)
{
	//VXASSERT(this, "VxNetClient::send, error, disconnect with server.");
	if(m_socket->state() == VXSOCKET_STATE_RUNNING)
	{
		this->pushMsg(sendObject);
	}
	VX_SAFE_RELEASE_NULL(sendObject);
}

int VxNetClient::pushMsg(VxMsgNetSendStream* sendObject,bool isFront,bool bWithTypeCheck)
{
	VxMsg* msg = sendObject;

	if (!msg)
	{
		return 0;
	}
	std::lock_guard<std::mutex> lk(m_msgMutex);

	sendObject->retain();
	m_msgList.push_back(sendObject);

	//socket->send(sendObject->m_stream, sendObject->m_stream->size());
	
	return 1;
}

void VxNetClient::popMsg() {
	
	std::lock_guard<std::mutex> lk(m_msgMutex);
	
	if (!m_msgList.empty())
	{
		VxMsg* pMsg = m_msgList.front();
		pMsg->release();
		m_msgList.pop_front();
	}
}


void VxNetClient::registerEventCb(VxNetEventCb func, void* arg)
{
	m_eventCb.add((void*)func, arg);
}

void VxNetClient::unregisterEventCb(VxNetEventCb func, void* arg)
{
	auto s = VxPriorityFuncion((void*)func, arg);
	m_eventCb.removeFunc(&s);
	//m_eventCb.remove((void*)func, arg);
}

bool VxNetClient::isDeleteAvailable()
{
	return m_socket->isDeleteAvailable();
}


bool VxNetClient::enableTLS(bool bEnable)
{
	return m_socket->enableTLS(bEnable);
}

bool VxNetClient::enableCompress(bool bEnable)
{
	return m_socket->enableCompress(bEnable);
}


bool VxNetClient::continueToRecv()
{
	return m_socket->continueToRecv();
}

VxMsgNetSendStream* VxNetClient::createStream(int nMsgType, int nMsgSize, const char* pMsgData)
{
	return m_pProtocol->createStream(nMsgType, nMsgSize, pMsgData);
}


void VxNetClient::send(int nMsgType, int nMsgSize, const char* pMsgData)
{
	VxMsgNetSendStream* pSendStream = createStream(nMsgType, nMsgSize, pMsgData);
	send(pSendStream);
}


void VxNetClient::_netClientAsyncEventCb(void* arg, int eventId, void* eventArg)
{
	VxNetClient* client = (VxNetClient*)arg;
	switch(eventId)
	{
	case VXSOCKET_EVENT_CONNECT_FAILED:
	case VXSOCKET_EVENT_CLOSED:
		{
			client->close();
		}
		break;
	}
}

void VxNetClient::_netClientEventCb(void* arg, int eventId, void* eventArg)
{
	VxNetClient* client = (VxNetClient*)arg;
	bool bAsync = true;
	switch(eventId)
	{
	case VXSOCKET_EVENT_CONNECT_BEGIN:
		break;
	case VXSOCKET_EVENT_CONNECT_COMPLETE:
		break;
	case VXSOCKET_EVENT_CONNECT_FAILED:
	case VXSOCKET_EVENT_CLOSED:
		{
			//VxLocalMutex sLocalMutex(&(client->m_sSendingListMutex));
			client->runMsgEventCb(VXSOCKET_EVENT_CLOSED, NULL);
			client->m_sendingList.clear();
		}
		break;
	case VXSOCKET_EVENT_RECV:
	{
		VxString *pRecvData = (VxString *)eventArg;

		int ret = client->m_pProtocol->plParser(pRecvData);
		if (ret == 0)
		{
			client->m_socket->continueToRecv();
		}
	}




		bAsync = false;
		break;
	case VXSOCKET_EVENT_SEND:
		{
			unsigned long sentSize = (unsigned long)eventArg;
			if(0 < sentSize)
			{
				client->popMsg();
			}
			client->m_totalSent += sentSize;

			
		}
		bAsync = false;
		break;
	default:
		break;
	}

	XGCCallLuaManager::getInstance()->socketEvent(client->m_nNetSocketId,eventId, eventArg);
	client->m_eventCb.run(eventId, eventArg);
	if(bAsync)
	{
		//client->m_eventCb.dispatch(VXMODULE_ID_DATA, (void*)eventId, eventArg);
	}
	else
	{
		//client->m_eventCb.run((void*)eventId, eventArg);
	}
}

void VxNetClient::runMsgEventCb(int eventId, void* eventArg)
{
	for(std::list<VxNetSendStreamData>::iterator i = m_sendingList.begin(); m_sendingList.end() != i; ++i)
	{
		i->runEventCb(eventId, eventArg);
	}
}

void VxNetClient::reconnect()
{
	++m_nConnectCount;
	m_totalSend = 0;
	m_totalSent = 0;
	m_totalRecv = 0;
	m_socket->close();
	m_recvBuffer->reset();
	m_sendBuffer->reset();
	m_socket->connect();
}
