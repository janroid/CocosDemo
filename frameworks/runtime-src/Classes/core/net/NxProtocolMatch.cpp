
#include "NxProtocolMatch.h"
#include "VxIOStream.h"
#include "VxMsg.h"
#include "VxLocalObject.h"

#include "VxNetClient.h"
#include "VxDef.h"
#include "VxConvert.h"

#include "XGCCallLuaManager.h"

#define NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE					4


/*
MsgMatchHeader
*/

class MsgMatchHeader
{
public:
	MsgMatchHeader(int nLen=0, int nType=0)
	{
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
		MATCH_HEAD_LENGTH = 4,
	};

	void packToBuffData();
	void parseBuffData();
	bool isValid();

public:

	unsigned int m_nLen;  // 数据长度
	unsigned int m_nType;  // 消息命令字，leaf server定义


	char m_pBufData[MATCH_HEAD_LENGTH];
};

// 组装发送数据头
void MsgMatchHeader::packToBuffData()
{
	unsigned short int tmp;
	unsigned int len = m_nLen + 2; // 数据长度 + ID长度
	tmp = VxConvert::NF_HTONS(len);
	memcpy(m_pBufData, &tmp, sizeof(short int));
	
	tmp = VxConvert::NF_HTONS(m_nType);
	memcpy(m_pBufData + 2, &tmp, sizeof(short int));

}

// 解析发送数据头
void MsgMatchHeader::parseBuffData()
{
	unsigned short int tmp = 0;
	memcpy(&tmp, m_pBufData, sizeof(short int));
	m_nLen = VxConvert::NF_NTOHS(tmp) - 2;

	memcpy(&tmp, m_pBufData + 2, sizeof(short int));
	m_nType = VxConvert::NF_NTOHS(tmp);

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

		VxMemStream* pStream = new VxMemStream(nMsgSize + MsgMatchHeader::MATCH_HEAD_LENGTH, false);//sizeof(MsgMatchHeader), false);
		VxMsgNetSendStream* pMsg = VX_NEW_MSG(VxMsgNetSendStream)(pStream);//new VxMsgNetSendStream(pStream);//
		pStream->release();

		if (!pStream || !pMsg)
		{
			break;
		}

		MsgMatchHeader sMsgHeader(nMsgSize, nMsgType);

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
		if (NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE > m_nFrameMetaHeaderSize) // 第一次读取头数据
		{
			nOnceSize = min(nBufferSize, NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE - m_nFrameMetaHeaderSize);
			//memcpy(((char*)&m_nFrameTotalSize) + m_nFrameMetaHeaderSize, pBuffer, nOnceSize);
			memcpy(m_pBuffHeadData + m_nFrameMetaHeaderSize, pBuffer, nOnceSize);

			m_nFrameMetaHeaderSize += nOnceSize;
			m_nFrameTotalSize = m_nFrameMetaHeaderSize;
			if (m_nFrameMetaHeaderSize >= NXPROTOCOL_MATCH_FRMAE_METAHEADER_SIZE)
			{

				MsgMatchHeader sHeader(m_pBuffHeadData);
				m_nFrameCurrSize = 0;
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

	MsgMatchHeader sMsgHeader;
	unsigned short int temp;
	unsigned int nPackageSize = 0;
	unsigned int bodyLen = 0;

	pStream->read((char*)sMsgHeader.m_pBufData, MsgMatchHeader::MATCH_HEAD_LENGTH);
	sMsgHeader.parseBuffData();

	bodyLen = sMsgHeader.m_nLen;

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