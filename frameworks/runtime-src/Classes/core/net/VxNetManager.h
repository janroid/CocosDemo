
#ifndef __VX_NET_MANAGER_H__
#define __VX_NET_MANAGER_H__

#include "cocos2d.h"
#include "VxSocket.h"
#include "VxConst.h"
#include "XGMacros.h"
#include "NxProtocol.h"

class VxNetClient;

class VxNetManager : public  cocos2d::Ref
{
public:
	VxNetManager();
	~VxNetManager();
	XG_SINGLET_WITH_INIT_DECLARE(VxNetManager);
	
	void connectToServer(int nNetSocketId, std::string sIp, short port, int nProtocal= VX_NET_PROTOCOL_IPOKER);
	void disconnectToServer(int nNetSocketId);
	bool hasConnectServer(int nNetSocketId);

	void sendMsgToServer(int nNetSocketId, int msgType, const char* sMsgData,int nMsgSize);

	bool enableTLS(int nNetSocketId, bool bEnable);
	bool enableCompress(int nNetSocketId, bool bEnable);
	bool continueToRecv(int nNetSocketId);

	static void socketEventCallback(void* pArg, int eEventId, void *pvEventArgs);

	void loop(float dt);
public:
	std::mutex m_managerMutex;


	std::map<int, VxNetClient*> s_sNetMap;
	std::list< VxNetClient*> s_sRemoveNetMap;
	std::mutex s_sRemoveMutex;

	VxAllocator* s_alloc;
	
};

#endif	// __VX_NET_MANAGER_H__