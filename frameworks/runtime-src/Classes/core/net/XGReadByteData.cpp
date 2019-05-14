#include "XGReadByteData.h"
#include "VxConvert.h"


XGReadByteData::XGReadByteData(unsigned char* pData, int nLen)
	: m_nCurPosition(0)
	, m_pBuffer(nullptr)
	, m_nLenght(0)
{
	m_pBuffer = new  unsigned char[nLen];
	m_nLenght = nLen;
	memcpy(m_pBuffer, pData, nLen);
	//m_nMsgHeadSize = sizeof(MsgHeader);

}

XGReadByteData::~XGReadByteData()
{
	delete[] m_pBuffer;
}

void XGReadByteData::init()
{

}


void XGReadByteData::readBegin()
{



}

int XGReadByteData::readInt()
{
	int nValue;
	unsigned char*p = (unsigned char*)&nValue;
	p[0] = m_pBuffer[m_nCurPosition];

	p[1] = m_pBuffer[m_nCurPosition + 1] ;
	p[2] = m_pBuffer[m_nCurPosition + 2] ;
	p[3] = m_pBuffer[m_nCurPosition + 3] ;

	m_nCurPosition += 4;
	//m_nLenght += 4;
	nValue = VxConvert::NF_NTOHL(nValue);
	return nValue;
}


int64 XGReadByteData::readInt64()
{
	int64 nValue;
	unsigned char*p = (unsigned char*)&nValue;
	p[0] = m_pBuffer[m_nCurPosition];

	p[1] = m_pBuffer[m_nCurPosition + 1];
	p[2] = m_pBuffer[m_nCurPosition + 2];
	p[3] = m_pBuffer[m_nCurPosition + 3];
	p[4] = m_pBuffer[m_nCurPosition + 4];
	p[5] = m_pBuffer[m_nCurPosition + 5];
	p[6] = m_pBuffer[m_nCurPosition + 6];
	p[7] = m_pBuffer[m_nCurPosition + 7];


	m_nCurPosition += 8;
	nValue = VxConvert::NF_NTOHLL(nValue);
	return nValue;
}

unsigned char XGReadByteData::readByte()
{
	unsigned char nValue = m_pBuffer[m_nCurPosition];
	m_nCurPosition += 1;
	//m_nLenght += 1;
	return nValue;
}

short XGReadByteData::readShort()
{
	short nValue;
	unsigned char*p = (unsigned char*)&nValue;
	p[0] = m_pBuffer[m_nCurPosition];
    p[1] = m_pBuffer[m_nCurPosition + 1];

	m_nCurPosition += 2;
	//m_nLenght += 2;
	nValue = VxConvert::NF_NTOHS(nValue);
	return nValue;
}

std::string XGReadByteData::readString()
{
	char sValue[4096] = {0};
	int len = readInt();
	
	if (len < 4096)
	{
		memcpy(sValue ,&m_pBuffer[m_nCurPosition],len);
		m_nCurPosition += len;
		//m_nLenght += len;
	}
	else
	{
		printf("XGReadByteData::readString error \n");
	}
	return sValue;
}


const unsigned char* XGReadByteData::readData(int len)
{
	const unsigned char *pRet = &m_pBuffer[m_nCurPosition];
	
	m_nCurPosition += len;

	return pRet;
}

void XGReadByteData::readEnd()
{
	//short bodyLen = m_nLenght - HEADER_SIZE;
	//unsigned char* p = (unsigned char*)&bodyLen;
	//m_pBuffer[6] = p[0];
	//m_pBuffer[7] = p[1];

	//m_pBuffer[8] = XGBufferEncrypt::EncryptBuffer(m_pBuffer, HEADER_SIZE, m_nLenght);
}