
#include "NxProtocolMatch.h"
#include "VxIOStream.h"
#include "VxMsg.h"
#include "VxLocalObject.h"

#include "VxNetClient.h"
#include "VxDef.h"
#include "VxConvert.h"

#include "XGCCallLuaManager.h"

#define NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE					7


/*
MsgMatchHeader
*/

class MsgMatchHeader
{
public:
	MsgMatchHeader(int nLen=0, char nType=0)
	{
		 m_sMagic[0] = 'V';
		 m_sMagic[1] = '1';
		 m_nLen = nLen;
		 m_nType = nType;
		 packToBuffData();
	}
	MsgMatchHeader(char* pNetData)
	{
		memcpy(m_pBufData, pNetData, MATCH_HEAD_LENGTH);
		parseBuffData();
	}

	enum
	{
		MATCH_HEAD_LENGTH = 7,
	};

	void packToBuffData();
	void parseBuffData();
	bool isValid();

public:

	char  m_sMagic[2];
	unsigned int m_nLen;
	char m_nType;


	char m_pBufData[MATCH_HEAD_LENGTH];
};


void MsgMatchHeader::packToBuffData()
{

	

	memcpy( m_pBufData, m_sMagic, 2);


	unsigned  int len = m_nLen;
	len = VxConvert::NF_HTONL(len);
	memcpy(m_pBufData + 2  , &len, 4);
	

	m_pBufData[6] = m_nType ;

}


void MsgMatchHeader::parseBuffData()
{

	unsigned short int temp = 0;
	
	
	memcpy(m_sMagic, m_pBufData+0, 2);
	

	unsigned  int len = 0;
	memcpy(&len, m_pBufData + 2, 4);
	m_nLen = VxConvert::NF_NTOHL(len);

	m_nType = m_pBufData[6];

}

bool MsgMatchHeader::isValid()
{
	return true;
}



/**
NxProtocolMatch
*/
NxProtocolMatch::NxProtocolMatch()
{

}

NxProtocolMatch::~NxProtocolMatch()
{

}

void NxProtocolMatch::initBuffHeadData()
{
	m_pBuffHeadData = new char[MsgMatchHeader::MATCH_HEAD_LENGTH];
}


VxMsgNetSendStream*  NxProtocolMatch::createStream(int nMsgType, int nMsgSize, const char* pMsgData)
{
	

	VxMsgNetSendStream* pMsg = NULL;
	VxMemStream* pStream = NULL;
	do
	{

		VxMemStream* pStream = new VxMemStream(nMsgSize + sizeof(MsgMatchHeader), false);
		VxMsgNetSendStream* pMsg = VX_NEW_MSG(VxMsgNetSendStream)(pStream);//new VxMsgNetSendStream(pStream);//
		pStream->release();



		if (!pStream || !pMsg)
		{
			break;
		}

		
		MsgMatchHeader sMsgHeader(nMsgSize+ MsgMatchHeader::MATCH_HEAD_LENGTH, nMsgType);

		pStream->write(sMsgHeader.m_pBufData, MsgMatchHeader::MATCH_HEAD_LENGTH);

		pStream->write((char*)pMsgData, nMsgSize);
		pStream->seek(0);
		return pMsg;

	} while (0);

	VX_SAFE_RELEASE_NULL(pStream);
	VX_SAFE_RELEASE_NULL(pMsg);

	return NULL;
}


int NxProtocolMatch::plParser(VxString* pRecvData)
{
	char* pBuffer = pRecvData->m_pString;
	int nBufferSize = pRecvData->m_nLength;
	int nOnceSize = 0;
	bool bplParserFrameFlag = false;
	while (0 < nBufferSize)
	{
		if (NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE > m_nFrameMetaHeaderSize)
		{
			nOnceSize = min(nBufferSize, NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE - m_nFrameMetaHeaderSize);
			//memcpy(((char*)&m_nFrameTotalSize) + m_nFrameMetaHeaderSize, pBuffer, nOnceSize);
			memcpy(m_pBuffHeadData + m_nFrameMetaHeaderSize, pBuffer, nOnceSize);

			m_nFrameMetaHeaderSize += nOnceSize;
			m_nFrameTotalSize = m_nFrameMetaHeaderSize;
			if (m_nFrameMetaHeaderSize >= NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE)
			{

				MsgMatchHeader sHeader(m_pBuffHeadData);
				m_nFrameCurrSize = NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE;
				m_nFrameTotalSize = sHeader.m_nLen;
			}
		}
		else
		{
			nOnceSize = min(m_nFrameTotalSize - m_nFrameCurrSize, nBufferSize);
			m_nFrameCurrSize += nOnceSize;
		}

		pBuffer += nOnceSize;
		nBufferSize -= nOnceSize;

		if (m_nFrameTotalSize == m_nFrameCurrSize)
		{
			bplParserFrameFlag = true;
			plParserFrame();
			m_nFrameMetaHeaderSize = 0;
			m_nFrameTotalSize = 0;
			m_nFrameCurrSize = 0;
			memset(m_pBuffHeadData, 0, MsgMatchHeader::MATCH_HEAD_LENGTH);
		}
	}
	if (!bplParserFrameFlag)
	{
		return 0;
	}
	return 1;
}

void NxProtocolMatch::plParserFrame()
{
	VxCacheIOStream* pStream = (VxCacheIOStream*)m_client->m_socket->getRecvBuffer();
	pStream->flush();

	//VXASSERT(m_nFrameTotalSize + NXPROTOCOL_FRMAE_METAHEADER_SIZE <= pStream->readCapacity(), "");

	static int sTotalCount = 0;
	++sTotalCount;


	//VXASSERT(m_nFrameTotalSize == sProtocolHeader.m_nFrameSize, "m_nFrameTotalSize = %d, sProtocolHeader.m_nFrameSize = %d", m_nFrameTotalSize, sProtocolHeader.m_nFrameSize);
	//for (int i = 0; i < sProtocolHeader.m_nMsgCount; ++i)

	{
		MsgMatchHeader sMsgHeader;
		unsigned short int temp;
		unsigned int nPackageSize = 0;
		unsigned int bodyLen = 0;

		pStream->read((char*)sMsgHeader.m_pBufData, MsgMatchHeader::MATCH_HEAD_LENGTH);
		sMsgHeader.parseBuffData();

		bodyLen = sMsgHeader.m_nLen - MsgMatchHeader::MATCH_HEAD_LENGTH;

		VxMemIOStream* pReadStream = pStream->getReadBuffer();

		if (bodyLen > pReadStream->capacity())
		{
			VxLocalString sLocalBuffer(bodyLen);
			pStream->read(sLocalBuffer.getString(), bodyLen);

			XGCCallLuaManager::getInstance()->recvMsg(m_client->m_nNetSocketId, sMsgHeader.m_nType, bodyLen, sLocalBuffer.getString());
		}
		else
		{
			if (bodyLen > pReadStream->readBlockBufferSize())
			{
				pStream->fillReadBuffer();
			}
			VxString sStringBuffer = pReadStream->readBlockBuffer(bodyLen);
			XGCCallLuaManager::getInstance()->recvMsg(m_client->m_nNetSocketId, sMsgHeader.m_nType, bodyLen, sStringBuffer.m_pString);
		}


	}

}