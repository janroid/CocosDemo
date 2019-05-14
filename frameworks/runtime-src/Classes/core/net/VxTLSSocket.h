
#ifndef __VX_TLS_SOCKET_H__
#define __VX_TLS_SOCKET_H__

#include "VxSocket.h"
#include "openssl/x509.h"  
#include "openssl/ssl.h"  
#include "openssl/err.h"  
#include "openssl/rand.h" 


class VxTLSSocket : public VxSocket

{
public:
	VxTLSSocket(SOCKET sock = INVALID_SOCKET);
	~VxTLSSocket();
	int init();

	bool connect(const char* ip, unsigned short port);
	
	virtual int send(const char* buf, int len, int flags = 0);

	virtual int recv(char* buf, int len, int flags = 0);
	int createTLS();
	void clearTLS();
	bool enableTLS(bool bEnable) ;
	bool enableCompress(bool bEnable);

protected:
	
	std::string getCaCrtPath();
	std::string getMyClientCrtPath();
	std::string getMyClientKeyPath();
	int getSrvCert(SSL * ssl, X509 ** pCert);

	//验证证书的合法性
	int verifyCert(X509 * pCert, const char * hostname);

protected:
	SSL_CTX * _ctx;
	SSL* _ssl;
	bool _bEnableTLS;
	bool _bEnableCompress;
};

#endif	// __VX_SOCKET_H__
