
#ifndef __VX_CONVERT_H__
#define __VX_CONVERT_H__

#include "VxDef.h"

class VxConvert
{
public:
	static int stringToInteger(const char* input);
	static int64 stringToInteger64(const char* input);
	static double stringToDouble(const char* input);
	static float stringToFloat(const char* input);
	static bool stringToBool(const char* input);
	static std::string integerToString(int input);
	static std::string integer64ToString(int64 input);
	static std::string doubleToString(double input);
	static std::string doubleToString2(double input);
	static std::string floatToString(float input);
	static std::string boolToString(bool input);
	static char* integerToChars(int input, char* buffer);
	static char* integer64ToChars(int64 input, char* buffer);
	static char* doubleToChars(double input, char* buffer);
	static char* floatToChars(float input, char* buffer);
	static char* boolToChars(bool input, char* buffer);
	static ccColor3B integerToColor(int nColor);

	static int64_t NF_HTONLL(int64_t nData);

	static int64_t NF_NTOHLL(int64_t nData);

	static int32_t NF_HTONL(int32_t nData);

	static int32_t NF_NTOHL(int32_t nData);

	static int16_t NF_HTONS(int16_t nData);

	static int16_t NF_NTOHS(int16_t nData);

	static std::string encode1(const char* pStr,int nNum);
	static std::string encode2(const char* pStr, int nNum);
};

#endif	// __VX_CONVERT_H__