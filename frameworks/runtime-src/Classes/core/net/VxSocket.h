
#ifndef __VX_SOCKET_H__
#define __VX_SOCKET_H__

#include "VxDef.h"

class VxSocket
{
public:
	VxSocket(SOCKET sock = INVALID_SOCKET);
	~VxSocket();

	bool create(int af = AF_INET, int type = SOCK_STREAM, int protocol = 0);

	bool bind(unsigned short port);

	bool listen(int backlog);

	bool accept(VxSocket& s, char* fromip);

	bool connectIpv4(const char* ip, unsigned short port);
	bool connectIpv6(const char* ip, unsigned short port);
	virtual bool connect(const char* ip, unsigned short port);

	virtual int send(const char* buf, int len, int flags = 0);

	virtual int recv(char* buf, int len, int flags = 0);

	int close();

	virtual bool enableTLS(bool bEnable);

	virtual bool enableCompress(bool bEnable);

	static int getError();

	VxSocket& operator = (SOCKET sock);

	SOCKET handle();

	static int init();

	static int clean();

	bool parseDns(const char* domain, char* ip);

public:
	SOCKET m_sock;
	bool m_isIPV6Net;
};

#endif	// __VX_SOCKET_H__
