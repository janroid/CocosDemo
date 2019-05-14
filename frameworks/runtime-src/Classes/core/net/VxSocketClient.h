
#ifndef __VX_SOCKET_CLIENT_H__
#define __VX_SOCKET_CLIENT_H__


#include "VxTLSSocket.h"
#include "VxConst.h"
#include "VxType.h"
#include "XGDelegate.h"

class VxStream;

class VxSocketClient
{
public:
	VxSocketClient(const char* addr, unsigned short port, bool bUseTLS = false);
	~VxSocketClient();

	// will alloc two memory buffer (send and recv) for copying socket data.
	bool setInternalBufferSize(int size);

	// sendBuffer should be thread-safe
	void setSendBuffer(VxStream* sendBuffer);

	// recvBuffer should be thread-safe
	void setRecvBuffer(VxStream* recvBuffer);

	VxStream* getSendBuffer();
	VxStream* getRecvBuffer();
	void connect();
	void close();
	bool send(VxStream* buffer, int len);
	void flush();
	bool recv(VxStream* buffer, int len);
	void registerEventCb(VxSockEventCb eventCb, void* arg);
	void unregisterEventCb(VxSockEventCb eventCb, void* arg);
	inline int state() { return m_state; }

	bool isDeleteAvailable();

	bool enableTLS(bool bEnable);
	bool enableCompress(bool bEnable);

	bool continueToRecv();
	void setRecvLockStatus();

private:
	static void* _sendThreadProc(void* arg);
	static void* _recvThreadProc(void* arg);
	void notifyEvent(int eventId, void* eventArg);
	void sendThreadProc();
	void recvThreadProc();
	void _close();
	void _createThreadResource();
	void _destroyThreadResource();

public:
	std::mutex m_recvMutex;
	std::mutex m_connectMutex;
	std::mutex m_sendMutex;
	std::thread* m_recvThread;
	std::thread* m_sendThread;
	std::condition_variable m_sendSem;
	std::condition_variable m_connectSem;
	std::condition_variable m_recvSem;
	//VxSem m_sendSem;
	unsigned short m_port;
	std::string m_addr;
	VxSocket *m_socket;
	XGDelegate m_eventCb;
	int m_state;
	char* m_recvInternalBuffer;
	int m_recvInternalBufferSize;
	char* m_sendInternalBuffer;
	int m_sendInternalBufferSize;
	VxStream* m_sendBuffer;
	VxStream* m_recvBuffer;
	int m_totalSend;
	int m_totalRecv;

	//VxSockEventCb m_eventCb;
	void *m_argv;
	bool m_bDeleteAvailable;
	bool m_bRecvThreadAvailable;
	bool m_bSendThreadAvailable;
	bool m_bSendMsgAvailable;
	bool m_bUseTLS;
	bool m_bContinueToRecvAvailable;
};

#endif	// __VX_SOCKET_CLIENT_H__