
#include "VxTLSSocket.h"
#include "VxConst.h"

#define CACERT     "ca.crt"
#define MYCERTF    "client.crt"
#define MYKEYF     "client.key"
#define MSGLENGTH  1024

#define HOST_NAME "localhost"

const char* const PREFERRED_CIPHERS = "AES256-SHA";



int pem_password_cb1(char *buf, int size, int rwflag, void *userdata)
{
    return 0;
}



VxTLSSocket::VxTLSSocket(SOCKET sock)
        :VxSocket(sock)
        , _ctx(nullptr)
        , _ssl(nullptr)
        , _bEnableTLS(false)
        , _bEnableCompress(false)
{
    init();
}

VxTLSSocket::~VxTLSSocket()
{
    clearTLS();
    if(_ctx)
        SSL_CTX_free(_ctx);
}


std::string VxTLSSocket::getCaCrtPath()
{
    return FileUtils::getInstance()->fullPathForFilename(CACERT);
}

std::string VxTLSSocket::getMyClientCrtPath()
{
    return FileUtils::getInstance()->fullPathForFilename(MYCERTF);
}

std::string VxTLSSocket::getMyClientKeyPath()
{
    return FileUtils::getInstance()->fullPathForFilename(MYKEYF);
}


int VxTLSSocket::getSrvCert(SSL * ssl, X509 ** pCert)
{
    int rv = -1;
    if (ssl == NULL)
    {
        return rv;
    }
    rv = SSL_get_verify_result(ssl);
    *pCert = SSL_get_peer_certificate(ssl);
    return rv;
}

int VxTLSSocket::verifyCert(X509 * pCert, const char * hostname)
{
    char commonName[512] = { 0 };
    X509_name_st * name = NULL;

    if (pCert == NULL || hostname == NULL)
    {
        return -1;
    }

    name = X509_get_subject_name(pCert);
    X509_NAME_get_text_by_NID(name, NID_commonName, commonName, 512);
    fprintf(stderr, "VerifyCert - Common Name on certificate: %s\n", commonName);
    if (strcmp(commonName, hostname) == 0)
    {
        printf("\n", commonName);
        return 1;
    }
    else
    {
        return 0;
    }
}


static SSL_CTX* InitCTX(void)

{
    const SSL_METHOD *method;

    SSL_CTX *ctx;

    SSL_library_init();

	ERR_load_BIO_strings();
	// 加载所有 加密 和 散列 函数

    OpenSSL_add_all_algorithms(); /* Load cryptos, et.al. */

    SSL_load_error_strings();  /* Bring in and register error messages */

    method = TLS_client_method(); /* Create new client-method instance */

    ctx = SSL_CTX_new(method);  /* Create new context */

    if (ctx == NULL)

    {

        ERR_print_errors_fp(stderr);

        printf("Eroor: %s\n", stderr);

        abort();

    }

    return ctx;

}


int VxTLSSocket::init()
{
    CCLOG("VxTLSSocket 1");

    int seed_int[100];

    _ctx = InitCTX();
    if (NULL == _ctx)
        return -1;

    CCLOG("VxTLSSocket 4");

   // SSL_CTX_set_default_passwd_cb_userdata(_ctx, (void*)"123321");

   // SSL_CTX_set_verify(_ctx, SSL_VERIFY_PEER, NULL);
	SSL_CTX_set_verify(_ctx, SSL_VERIFY_NONE, NULL);
	
    SSL_CTX_load_verify_locations(_ctx, getCaCrtPath().c_str(), NULL);

    CCLOG("VxTLSSocket 5");
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
    srand((unsigned)time(NULL));
	for (int i = 0; i < 100; i++)
		seed_int[i] = rand();
	RAND_seed(seed_int, sizeof(seed_int));
#endif

    CCLOG("VxTLSSocket 6");

    //SSL_CTX_set_cipher_list(ctx, "RC4-MD5");
    int res = SSL_CTX_set_cipher_list(_ctx, PREFERRED_CIPHERS);
    if (1 != res)
    {
        printf("SSL_CTX_set_cipher_list: failed!!!\n");
        return -1;
    }
    CCLOG("VxTLSSocket 7");


    //  SSL_CTX_set_mode(_ctx, SSL_MODE_AUTO_RETRY);
    //  CCLOG("VxTLSSocket end");
	return 0;
}


bool VxTLSSocket::connect(const char* ip, unsigned short port)
{
    CCLOG("VxTLSSocket connect");
    //SSL_connect(_ssl);
    auto ret = VxSocket::connect(ip, port);

    if (ret)
    {
        //enableTLS(true);
    }
    return ret;
}


int VxTLSSocket::send(const char* buf, int len, int flags )
{
    CCLOG("VxTLSSocket send");
    if (_bEnableTLS)
    {
        return SSL_write(_ssl, buf, len);
    }
    else
    {
        return VxSocket::send(buf, len, flags);
    }

}

int VxTLSSocket::recv(char* buf, int len, int flags)
{
    CCLOG("VxTLSSocket recv");
    int ret = 0;
    if (_bEnableTLS)
    {
        ret =  SSL_read(_ssl, buf, len);
    }
    else
    {
        ret = VxSocket::recv(buf, len, flags);
       // enableTLS(true);
    }
    return ret;
}

int VxTLSSocket::createTLS()
{

    CCLOG("VxTLSSocket createTLS");
	clearTLS();
    _ssl = SSL_new(_ctx);
    if (NULL == _ssl)
        return -1;
    if (0 >= SSL_set_fd(_ssl, m_sock)) {
		CCLOG("Attach to Line fail!\n");
        return -1;
    }

    int k = SSL_connect(_ssl);
    if (0 == k) {
		CCLOG("%d\n", k);
		CCLOG("SSL connect fail!\n");
        return -1;
    }
	CCLOG("链接服务器成功\n");

    fprintf(stderr, "Retrieving peer certificate\n");


    X509* pCert = NULL;
    if (getSrvCert(_ssl, &pCert) != X509_V_OK)
    {
        if (SSL_get_verify_result(_ssl) != X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY)
        {
            fprintf(stderr, "Certificate verification error: %i\n", SSL_get_verify_result(_ssl));
            SSL_CTX_free(_ctx);
            _ctx = nullptr;
            return -1;
        }
        else
        {
            fprintf(stderr, "X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY\n");
        }
    }

    char buf[MSGLENGTH] = "\0";

    //int ret = SSL_read(_ssl, buf, MSGLENGTH);


    return 0;
}

void VxTLSSocket::clearTLS()
{
    if (_ssl)
    {
        SSL_free(_ssl);
        _ssl = nullptr;
    }
}


bool VxTLSSocket::enableTLS(bool bEnable)
{
    _bEnableTLS = bEnable;
    if (_bEnableTLS && !_ssl)
    {

        if (0 == createTLS())
        {
            return true;
        }
        else
        {
            _bEnableTLS = false;
            return false;
        }

    }
    return true;
}

bool VxTLSSocket::enableCompress(bool bEnable) {
    _bEnableCompress = bEnable;
    return true;
};
