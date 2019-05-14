
#include "VxSocket.h"
#include "VxConst.h"



//ÅÐ¶ÏÊÇ·ñIPv6ÍøÂç
static bool isIPV6Net(const std::string domainStr = "www.baidu.com")
{
	bool isIPV6Net = false;

	struct addrinfo *result = nullptr, *curr;

	struct sockaddr_in6 dest;
	memset(&dest,0,sizeof(dest));

	dest.sin6_family = AF_INET6;

	int ret = getaddrinfo(domainStr.c_str(), nullptr, nullptr, &result);
	if (ret == 0)
	{
		for (curr = result; curr != nullptr; curr = curr->ai_next)
		{
			switch (curr->ai_family)
			{
			case AF_INET6:
			{
				isIPV6Net = true;
				break;
			}
			case AF_INET:

				break;

			default:
				break;
			}
		}
	}
	if (result)
	{
		freeaddrinfo(result);
	}
	

	return isIPV6Net;
}



VxSocket::VxSocket(SOCKET sock)
{
	m_sock = sock;
	m_isIPV6Net = false;
}

VxSocket::~VxSocket()
{
	if(INVALID_SOCKET != m_sock)
	{
		this->close();
	}
}

bool VxSocket::create(int af, int type, int protocol)
{
	//m_sock = socket(af, type, protocol);
	m_isIPV6Net = isIPV6Net();
	m_sock = socket((m_isIPV6Net ? AF_INET6 : AF_INET), SOCK_STREAM, protocol);

	if (m_sock == INVALID_SOCKET)
	{
		return false;
	}
	return true;
}

bool VxSocket::bind(unsigned short port)
{
	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = INADDR_ANY;
	svraddr.sin_port = htons(port);
	int opt =  1;
	if(setsockopt(m_sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt)) < 0)
	{
		return false;
	}

	int ret = ::bind(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));   
	if(ret == SOCKET_ERROR)
	{
		return false;
	}

	return true;
}

bool VxSocket::listen(int backlog)
{
	int ret = ::listen(m_sock, backlog);
	if (ret == SOCKET_ERROR)
	{
		return false;
	}
	return true;
}

bool VxSocket::accept(VxSocket& s, char* fromip)
{
	struct sockaddr_in cliaddr;
	socklen_t addrlen = sizeof(cliaddr);
	SOCKET sock = ::accept(m_sock, (struct sockaddr*)&cliaddr, &addrlen);

	if(sock == SOCKET_ERROR)
	{
		return false;
	}

	s = sock;
	if(fromip != NULL)
	{
		sprintf(fromip, "%s", inet_ntoa(cliaddr.sin_addr));
	}

	return true;
}

bool VxSocket::connectIpv4(const char* ip, unsigned short port)
{
	char tempIp[64] = { 0 };
	bool b = parseDns(ip, tempIp);
	if (!b)
	{
		return false;
	}


	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = inet_addr(tempIp);
	svraddr.sin_port = htons(port);

	int ret = ::connect(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));
	

	if (ret == SOCKET_ERROR)
	{
		return false;
	}

	return true;
}


bool VxSocket::connectIpv6(const char* ip, unsigned short port)
{
    char strPort[10] ={0};
    sprintf(strPort,"%d",port);
	struct addrinfo hint;
	memset(&hint, 0x0, sizeof(hint));
	hint.ai_family = AF_INET6;
	hint.ai_flags = AI_V4MAPPED;

	addrinfo* ailist = nullptr;
	getaddrinfo(ip, strPort, &hint, &ailist);

	int ret = -1;

	if (ailist != nullptr)
	{
		for (auto aip = ailist; aip != nullptr; aip = aip->ai_next) {

			if (aip->ai_addr->sa_family == AF_INET6) {
				ret = ::connect(m_sock, aip->ai_addr, sizeof(struct sockaddr_in6));
			}
			else
			{
				continue;
			}
			if (ret < 0) {
				printf("can't connect to %s: %s\n", ip, strerror(errno));
				continue;
			}
			break;
		}
		
		freeaddrinfo(ailist);
	}

	if (ret == SOCKET_ERROR)
	{
		return false;
	}

	return true;
}


bool VxSocket::connect(const char* ip, unsigned short port)
{
	int ret = SOCKET_ERROR;

	if (!m_isIPV6Net)
	{
		ret = connectIpv4(ip, port);
	}
	else
	{
		ret = connectIpv6(ip, port);
	}
	return ret;
}

int VxSocket::send(const char* buf, int len, int flags)
{
	int bytes;
	int count = 0;
	while (count < len)
	{
		bytes = ::send(m_sock, buf + count, len - count, flags);

		if (bytes == -1 || bytes == 0)
		{
			return -1;
		}
		count += bytes;
	}
	return count;
}

int VxSocket::recv(char* buf, int len, int flags)
{
	return (::recv(m_sock, buf, len, flags));
}

int VxSocket::close()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return (::closesocket(m_sock));
#else
	::shutdown(m_sock, SHUT_RDWR);
	return (::close(m_sock));
#endif
}


bool VxSocket::enableTLS(bool bEnable)
{
	return false;
}

bool VxSocket::enableCompress(bool bEnable)
{
	return false;
}

int VxSocket::getError()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return (WSAGetLastError());
#else
	return (errno);
#endif
}

VxSocket& VxSocket::operator = (SOCKET sock)
{
	m_sock = sock;
	return (*this);
}

SOCKET VxSocket::handle()
{
	return m_sock;
}

int VxSocket::init()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	WSADATA wsaData;
	//#define MAKEWORD(a,b) ((WORD) (((BYTE) (a)) | ((WORD) ((BYTE) (b))) << 8))    
	WORD version = MAKEWORD(2, 0);
	//win sock start up
	int ret = WSAStartup(version, &wsaData);
	if (ret)
	{
		// VXLOG("Initilize winsock error !");
		return VXERR_FAILED;
	}
#endif
	return VXERR_SUCCESS;
}

int VxSocket::clean()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return (WSACleanup());
#endif
	return 0;
}

bool VxSocket::parseDns(const char* domain, char* ip)
{
	struct hostent* p;
	if ((p = gethostbyname(domain)) == NULL)
	{
		return false;
	}
	sprintf(ip,
		"%u.%u.%u.%u",
		(unsigned char)p->h_addr_list[0][0],
		(unsigned char)p->h_addr_list[0][1],
		(unsigned char)p->h_addr_list[0][2],
		(unsigned char)p->h_addr_list[0][3]);
	return true;  
}


