
#include "VxConst.h"
#include "VxConvert.h"
#include "NxProtocol.h"
#include "sha1.h"

int VxConvert::stringToInteger(const char* input)
{
	return atoi(input);
}

int64 VxConvert::stringToInteger64(const char* input)
{
	int len = strlen(input);
	
	if (len>8) {
		return 0;
	}

	uint64_t n64 = 0;
	for (int i = 0; i<(int)len; i++) {
		n64 |= (uint64_t)input[i] << (i * 8);
	}
	return n64;
}

double VxConvert::stringToDouble(const char* input)
{
	return atof(input);
}

float VxConvert::stringToFloat(const char* input)
{
	return (float)VxConvert::stringToDouble(input);
}

bool VxConvert::stringToBool(const char* input)
{
	return (!strcmp(input, VX_VALUE_STRING_TRUE));
}

std::string VxConvert::integerToString(int input)
{
	char buffer[32] = { 0 };
	VxConvert::integerToChars(input, buffer);
	return buffer;
}

std::string VxConvert::integer64ToString(int64 input)
{
	char buffer[64] = { 0 };
	VxConvert::integer64ToChars(input, buffer);
	return buffer;
}

std::string VxConvert::doubleToString(double input)
{
	char buffer[32] = { 0 };
	VxConvert::doubleToChars(input, buffer);
	return buffer;
}

std::string VxConvert::doubleToString2(double input)
{
	char buffer[32] = { 0 };
	sprintf(buffer, "%.1f", input);
	return buffer;
}

std::string VxConvert::floatToString(float input)
{
	char buffer[32] = { 0 };
	VxConvert::floatToChars(input, buffer);
	return buffer;
}

std::string VxConvert::boolToString(bool input)
{
	if(input)
	{
		return VX_VALUE_STRING_TRUE;
	}
	else
	{
		return VX_VALUE_STRING_FALSE;
	}
}

char* VxConvert::integerToChars(int input, char* buffer)
{
	sprintf(buffer, "%d", input);
	return buffer;
}

char* VxConvert::integer64ToChars(int64 input, char* buffer)
{
	sprintf(buffer, "%lld", input);
	return buffer;
}

char* VxConvert::doubleToChars(double input, char* buffer)
{
	sprintf(buffer, "%f", input);
	return buffer;
}

char* VxConvert::floatToChars(float input, char* buffer)
{
	return VxConvert::doubleToChars(input, buffer);
}

char* VxConvert::boolToChars(bool input, char* buffer)
{
	if(input)
	{
		strcpy(buffer, VX_VALUE_STRING_TRUE);
	}
	else
	{
		strcpy(buffer, VX_VALUE_STRING_FALSE);
	}
	return buffer;
}

ccColor3B VxConvert::integerToColor(int nColor)
{
	ccColor3B sRet;
	sRet.r = (nColor & (0xFF0000)) >> 16;
	sRet.g = (nColor & (0xFF00)) >> 8;
	sRet.b = (nColor & 0xFF);
	return sRet;
}

int64_t VxConvert::NF_HTONLL(int64_t nData)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

	const unsigned __int64 Retval = _WS2_32_WINSOCK_SWAP_LONGLONG(nData);
	return Retval;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
	return HTONLL(nData);
#else
	return htobe64(nData);
#endif
}

int64_t VxConvert::NF_NTOHLL(int64_t nData)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	const unsigned __int64 Retval = _WS2_32_WINSOCK_SWAP_LONGLONG(nData);
	return Retval;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return NTOHLL(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	return betoh64(nData);
#else
	return be64toh(nData);
#endif
}

int32_t VxConvert::NF_HTONL(int32_t nData)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return htonl(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return HTONL(nData);
#else
	return htobe32(nData);
#endif
}

int32_t VxConvert::NF_NTOHL(int32_t nData)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return ntohl(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return NTOHL(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	return betoh32(nData);
#else
	return be32toh(nData);
#endif
}

int16_t VxConvert::NF_HTONS(int16_t nData)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return htons(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return HTONS(nData);
#else
	return htobe16(nData);
#endif
}

int16_t VxConvert::NF_NTOHS(int16_t nData)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return ntohs(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return NTOHS(nData);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	return betoh16(nData);
#else
	return be16toh(nData);
#endif
}



static int RecvByteMap[256] = { 0x51, 0xA1, 0x9E, 0xB0, 0x1E, 0x83, 0x1C, 0x2D, 0xE9,
0x77, 0x3D, 0x13, 0x93, 0x10, 0x45, 0xFF, 0x6D, 0xC9, 0x20, 0x2F, 0x1B,
0x82, 0x1A, 0x7D, 0xF5, 0xCF, 0x52, 0xA8, 0xD2, 0xA4, 0xB4, 0x0B, 0x31,
0x97, 0x57, 0x19, 0x34, 0xDF, 0x5B, 0x41, 0x58, 0x49, 0xAA, 0x5F, 0x0A,
0xEF, 0x88, 0x01, 0xDC, 0x95, 0xD4, 0xAF, 0x7B, 0xE3, 0x11, 0x8E, 0x9D,
0x16, 0x61, 0x8C, 0x84, 0x3C, 0x1F, 0x5A, 0x02, 0x4F, 0x39, 0xFE, 0x04,
0x07, 0x5C, 0x8B, 0xEE, 0x66, 0x33, 0xC4, 0xC8, 0x59, 0xB5, 0x5D, 0xC2,
0x6C, 0xF6, 0x4D, 0xFB, 0xAE, 0x4A, 0x4B, 0xF3, 0x35, 0x2C, 0xCA, 0x21,
0x78, 0x3B, 0x03, 0xFD, 0x24, 0xBD, 0x25, 0x37, 0x29, 0xAC, 0x4E, 0xF9,
0x92, 0x3A, 0x32, 0x4C, 0xDA, 0x06, 0x5E, 0x00, 0x94, 0x60, 0xEC, 0x17,
0x98, 0xD7, 0x3E, 0xCB, 0x6A, 0xA9, 0xD9, 0x9C, 0xBB, 0x08, 0x8F, 0x40,
0xA0, 0x6F, 0x55, 0x67, 0x87, 0x54, 0x80, 0xB2, 0x36, 0x47, 0x22, 0x44,
0x63, 0x05, 0x6B, 0xF0, 0x0F, 0xC7, 0x90, 0xC5, 0x65, 0xE2, 0x64, 0xFA,
0xD5, 0xDB, 0x12, 0x7A, 0x0E, 0xD8, 0x7E, 0x99, 0xD1, 0xE8, 0xD6, 0x86,
0x27, 0xBF, 0xC1, 0x6E, 0xDE, 0x9A, 0x09, 0x0D, 0xAB, 0xE1, 0x91, 0x56,
0xCD, 0xB3, 0x76, 0x0C, 0xC3, 0xD3, 0x9F, 0x42, 0xB6, 0x9B, 0xE5, 0x23,
0xA7, 0xAD, 0x18, 0xC6, 0xF4, 0xB8, 0xBE, 0x15, 0x43, 0x70, 0xE0, 0xE7,
0xBC, 0xF1, 0xBA, 0xA5, 0xA6, 0x53, 0x75, 0xE4, 0xEB, 0xE6, 0x85, 0x14,
0x48, 0xDD, 0x38, 0x2A, 0xCC, 0x7F, 0xB1, 0xC0, 0x71, 0x96, 0xF8, 0x3F,
0x28, 0xF2, 0x69, 0x74, 0x68, 0xB7, 0xA3, 0x50, 0xD0, 0x79, 0x1D, 0xFC,
0xCE, 0x8A, 0x8D, 0x2E, 0x62, 0x30, 0xEA, 0xED, 0x2B, 0x26, 0xB9, 0x81,
0x7C, 0x46, 0x89, 0x73, 0xA2, 0xF7, 0x72 };

std::string VxConvert::encode1(const char* pStr,int nNum)
{
	char* rtn = NULL;
	char* encode = NULL;
	int alen = strlen(pStr);
	const char* ba = pStr;
	if (alen > 0) {
		rtn = (char*)malloc(alen + 1);
		encode = (char*)malloc(alen + 1);
		memcpy(rtn, ba, alen);
		rtn[alen] = 0;
	}

	int ji = nNum;
	int i = 0;
	int xxor = 0;
	xxor = ji % 256;
	for (i = 0; i < alen; i++) {
		int x = 0;
		x = RecvByteMap[*(rtn + i)];
		*(encode + i) = x ^ xxor;
	}
	//	unsigned const char* tmp = (unsigned const char*) encode;
	char *dst = NULL;
	size_t dLen = 0;
	dLen = base64Encode((unsigned const char*)encode, alen, &dst);

	
	std::string ret;
	if (dst)
	{
		ret = dst;
		free(dst);
	}
	
	return ret;
}

std::string VxConvert::encode2(const char* pStr, int version)
{
	std::string jstr;
	if (version == 9) {
		jstr = "hUbJ2wLp1RxU9el1y0v1Zw==";
	}
	else if (version == 3) {
		jstr = "H1q0NPcX7X2HaitZboWrpQ==";
	}
	else if (version == 10) {
		jstr = "YfoGi3ETIUw426w5BfYSIg==";
	}
	else if (version == 4) {
		jstr = "AI54l5cONGIH115HoVgpjg==";
	}
	else {
		jstr = "hUbJ2wLp1RxU9el1y0v1Zw==";
	}

	//auto utf8String = StringUtils::StringUTF8(jstr);


	auto buffers = jstr.c_str();//utf8String.getString();

	char* rtn = NULL;
	char* key = NULL;
	int alen = strlen(pStr);//env->GetArrayLength(jba);
	int alen2 = strlen(buffers);
	auto* ba = pStr;
	auto* ba2 = buffers;
	if (alen > 0) {
		rtn = (char*)malloc(alen + 1);
		memcpy(rtn, ba, alen);
		rtn[alen] = 0;
	}

	if (alen2 > 0) {
		key = (char*)malloc(alen2 + 1);
		memcpy(key, ba2, alen2);
		key[alen2] = 0;
	}

	unsigned char *shadst = NULL;
	size_t shaLen = 0;
	unsigned char c[20];
	sha1_hmac((unsigned char const*)key, alen2, (unsigned char const*)rtn, alen, c);

	char *dst = NULL;
	size_t dLen = 0;
	//base64_encode(dst, &dLen, c, 20);

	dLen = base64Encode((unsigned const char*)c, 20, &dst);

	std::string ret;
	if (dst)
	{
		ret = dst;
		free(dst);
	}

	return ret;
}