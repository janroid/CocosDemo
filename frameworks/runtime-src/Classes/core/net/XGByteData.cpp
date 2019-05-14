#include "XGByteData.h"
#include "VxConvert.h"



XGByteData::XGByteData(int capacity)
	: m_nCurPosition(0)
	, m_pBuffer(nullptr)
	, m_nLenght(0)
	, m_capacity(capacity)
{
	m_pBuffer = new  unsigned char[capacity];
	memset(m_pBuffer, 0, capacity);
}


XGByteData::~XGByteData()
{
	delete[] m_pBuffer;
}

void XGByteData::init()
{

}

void XGByteData::writeBegin()
{
}


void XGByteData::writeInt(int nValue)
{

	int len = 4;
	if (m_nLenght + len < m_capacity)
	{
		nValue = VxConvert::NF_HTONL(nValue);
		unsigned char*p = (unsigned char*)&nValue;
		m_pBuffer[m_nCurPosition] = p[0];
		m_pBuffer[m_nCurPosition + 1] = p[1];
		m_pBuffer[m_nCurPosition + 2] = p[2];
		m_pBuffer[m_nCurPosition + 3] = p[3];

		m_nCurPosition += 4;
		m_nLenght += 4;
	}
	else
	{

		resizeBuff(m_nLenght + len);
		writeInt(nValue);
	}


	
}

void XGByteData::writeInt64(int64 nValue)
{

	int len = 8;
	if (m_nLenght + len < m_capacity)
	{
		nValue = VxConvert::NF_HTONLL(nValue);
		unsigned char*p = (unsigned char*)&nValue;
		m_pBuffer[m_nCurPosition] = p[0];
		m_pBuffer[m_nCurPosition + 1] = p[1];
		m_pBuffer[m_nCurPosition + 2] = p[2];
		m_pBuffer[m_nCurPosition + 3] = p[3];
		m_pBuffer[m_nCurPosition + 4] = p[4];
		m_pBuffer[m_nCurPosition + 5] = p[5];
		m_pBuffer[m_nCurPosition + 6] = p[6];
		m_pBuffer[m_nCurPosition + 7] = p[7];

		m_nCurPosition += 8;
		m_nLenght += 8;
	}
	else
	{

		resizeBuff(m_nLenght + len);
		writeInt64(nValue);
	}

	
}

void XGByteData::writeByte(unsigned char nValue)
{

	int len = 1;
	if (m_nLenght + len < m_capacity)
	{
		m_pBuffer[m_nCurPosition] = nValue;
		m_nCurPosition += 1;
		m_nLenght += 1;
	}
	else
	{

		resizeBuff(m_nLenght + len);
		writeByte(nValue);
	}


}

void XGByteData::writeShort(short nValue)
{

	int len = 1;
	if (m_nLenght + len < m_capacity)
	{
		nValue = VxConvert::NF_HTONS(nValue);
		unsigned char*p = (unsigned char*)&nValue;
		m_pBuffer[m_nCurPosition] = p[0];
		m_pBuffer[m_nCurPosition + 1] = p[1];

		m_nCurPosition += 2;
		m_nLenght += 2;
	}
	else
	{

		resizeBuff(m_nLenght + len);
		writeShort(nValue);
	}

	
}

void XGByteData::writeString(std::string sValue)
{
	int len = sValue.length();
	int totalLen = len+5;
	if (m_nLenght + totalLen < m_capacity)
	{
		
		writeInt(len + 1);
		if (m_nLenght + len < m_capacity)
		{
			memcpy(&m_pBuffer[m_nCurPosition], sValue.c_str(), len);
			m_nCurPosition += len;
			m_nLenght += len;
			writeByte(0);
		}
	}
	else
	{

		resizeBuff(m_nLenght + totalLen);
		writeString(sValue);
	}

	

}

void XGByteData::writeData(const uint8_t * pData, int len)
{
	if (m_nLenght + len < m_capacity)
	{
		memcpy(&m_pBuffer[m_nCurPosition], pData, len);
		m_nCurPosition += len;
		m_nLenght += len;
	}
	else
	{

		resizeBuff(m_nLenght + len);
		writeData(pData, len);
	}
}


void XGByteData::writeEnd()
{

}

void  XGByteData::add(XGByteData*pData)
{
	int total = m_nLenght + pData->m_nLenght;

	if (total > m_capacity)
	{
		resizeBuff(total);
	}

	writeData(pData->getBuffer(), pData->getLenght());
}

void XGByteData::copy(XGByteData*pData)
{
	m_nCurPosition = pData->m_nCurPosition ;
	m_nLenght = pData->m_nLenght;
	memcpy(m_pBuffer, pData->m_pBuffer,m_nLenght);
}

void XGByteData::resizeBuff(int len)
{
	int t = m_capacity * 2;
	if (len < t)
	{
		len = t;
	}
	else
	{
		len = len * 2;
	}
	unsigned char* pNewBuffer = new  unsigned char[len];
	memset(pNewBuffer, 0, len);
	memcpy(pNewBuffer, m_pBuffer, m_capacity );
	m_capacity = len;
}
