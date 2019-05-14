
#ifndef __XG_BUFFER_DATA_H__
#define __XG_BUFFER_DATA_H__

#include "XGMacros.h"

class XGByteData
{
public:
	//XGByteData();
	XGByteData(int capacity=256);
	~XGByteData();

	void init();
	void writeBegin();
	void writeInt(int nValue);
	void writeInt64(int64 nValue);
	void writeByte(unsigned char nValue);
	void writeShort(short nValue);
	void writeString(std::string sValue);

	void writeData(const uint8_t * pData,int len);

	void writeEnd();

	void add(XGByteData*pData);

	void copy(XGByteData*pData);
	void resizeBuff(int len);

	unsigned char* getBuffer(){ return m_pBuffer; };
	int getLenght(){ return m_nLenght; };

	int m_nCurPosition;
	unsigned char* m_pBuffer;
	int m_nLenght;
	int m_capacity;

};

#endif	// __XG_BUFFER_DATA_H__