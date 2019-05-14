
#ifndef __NX_PROTOCOL_H__
#define __NX_PROTOCOL_H__

#include "VxDef.h"
#include <cstring>
#include <cerrno>
#include <cstdio>
#include <csignal>
#include <cstdint>
#include <iostream>
#include <map>
#include <vector>
#include <functional>
#include <memory>
#include <list>
#include <vector>
#include <cassert>

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <WinSock2.h>
#include <windows.h>

#define _WS2_32_WINSOCK_SWAP_LONGLONG(l)            \
            ( ( ((l) >> 56) & 0x00000000000000FFLL ) |       \
              ( ((l) >> 40) & 0x000000000000FF00LL ) |       \
              ( ((l) >> 24) & 0x0000000000FF0000LL ) |       \
              ( ((l) >>  8) & 0x00000000FF000000LL ) |       \
              ( ((l) <<  8) & 0x000000FF00000000LL ) |       \
              ( ((l) << 24) & 0x0000FF0000000000LL ) |       \
              ( ((l) << 40) & 0x00FF000000000000LL ) |       \
              ( ((l) << 56) & 0xFF00000000000000LL ) )

#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC

#include <libkern/OSByteOrder.h>

#endif

#include <netinet/in.h>


#include <sys/socket.h>
#include <unistd.h>

#endif
/*
class ProtocolHeader
{
public:
ProtocolHeader(int nFrameSize = 0, int nSessionId = 0, int nMsgCount = 1)
: m_nFrameSize(nFrameSize), m_nSessionId(nSessionId), m_nMsgCount(nMsgCount)
{
}
public:
int m_nFrameSize;
int m_nSessionId;
int m_nMsgCount;
};
*/

enum {
	VX_NET_PROTOCOL_IPOKER = 0,
	VX_NET_PROTOCOL_MATCH = 1,
};


class VxNetClient;
class VxString;
class VxMsgNetSendStream;

class NxProtocol 
{
public:
	
	void start(VxNetClient *netClient);

	virtual VxMsgNetSendStream* createStream(int nMsgType, int nMsgSize, const char* pMsgData);

	virtual int plParser(VxString* pRecvData);
	virtual void plParserFrame();



public:
	NxProtocol();
	~NxProtocol();

	virtual void initBuffHeadData();



public:
	int m_nFrameMetaHeaderSize;
	int m_nFrameTotalSize;
	int m_nFrameCurrSize;
	char* m_pBuffHeadData;


	VxNetClient* m_client;
	
};

#endif	// __NX_PROTOCOL_H__

