
#ifndef __XG_READ_BUFFER_DATA_H__
#define __XG_READ_BUFFER_DATA_H__

#include "XGMacros.h"


class XGReadByteData
{
public:
	XGReadByteData(unsigned char* pData,int nLen);
	~XGReadByteData();

	void init();


	void readBegin();
	int readInt();
	int64 readInt64();
	unsigned char readByte();
	short readShort();
	std::string readString();
	const unsigned char* readData(int len);

	void readEnd();

	unsigned char* getBuffer(){ return m_pBuffer; };
	int getLenght(){ return m_nLenght; };


	int m_nCurPosition;
	unsigned char* m_pBuffer;
	int m_nLenght;
	int m_nMsgHeadSize;

};

#endif	// __XG_BUFFER_DATA_H__