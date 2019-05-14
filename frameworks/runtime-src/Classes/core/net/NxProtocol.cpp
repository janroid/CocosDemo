
#include "NxProtocol.h"
#include "VxIOStream.h"
#include "VxMsg.h"
#include "VxLocalObject.h"

#include "VxNetClient.h"
#include "VxDef.h"
#include "VxConvert.h"

#include "XGCCallLuaManager.h"



class MsgHeader
{
public:
	MsgHeader(short int nMsgType = 0, int nMsgSize = 0);


	enum
	{
		NF_HEAD_LENGTH = 8,
	};

	void parseBuffData();
	bool isValid();

public:
	int m_nMsgSize;
	short int m_nMsgType;

	char m_pBufData[8];
};


MsgHeader::MsgHeader(short int nMsgType , int nMsgSize )
	: m_nMsgType(nMsgType), m_nMsgSize(nMsgSize)
{
	memset(m_pBufData, 0, NF_HEAD_LENGTH);
	m_pBufData[0] = 'E';
	m_pBufData[1] = 'S';

	unsigned short int temp = m_nMsgType;
	temp = VxConvert::NF_HTONS(temp);
	memcpy(m_pBufData + 2, &temp, sizeof(short int));

	temp = VxConvert::NF_HTONS(1);
	memcpy(m_pBufData + 4, &temp, sizeof(short int));

	temp = VxConvert::NF_HTONS(nMsgSize);
	memcpy(m_pBufData + 6, &temp, sizeof(short int));

}


void MsgHeader::parseBuffData()
{

	unsigned short int temp = 0;
	
	memcpy(&temp , m_pBufData + 2, sizeof(short int));
	m_nMsgType = VxConvert::NF_NTOHS(temp);
	
	memcpy(&temp, m_pBufData + 6, sizeof(short int));
	m_nMsgSize = VxConvert::NF_NTOHS(temp);

}

bool MsgHeader::isValid()
{
	return true;
}



/************************************************************************/
/* NxProtocol
/************************************************************************/

//#define NXPROTOCOL_FRMAE_METAHEADER_SIZE					((int)sizeof(int))

#define NXPROTOCOL_FRMAE_METAHEADER_SIZE					8


NxProtocol::NxProtocol()
{
	m_nFrameMetaHeaderSize = 0;
	m_nFrameTotalSize = 0;
	m_nFrameCurrSize = 0;
	m_pBuffHeadData = nullptr;
	initBuffHeadData();
}

NxProtocol::~NxProtocol()
{
	if (m_pBuffHeadData)
	{
		delete [] m_pBuffHeadData;
	}
}


void NxProtocol::initBuffHeadData()
{
	m_pBuffHeadData = new char[MsgHeader::NF_HEAD_LENGTH];
}



void NxProtocol::start(VxNetClient *netClient)
{
	m_client = netClient;
}

VxMsgNetSendStream*  NxProtocol::createStream(int nMsgType, int nMsgSize, const char* pMsgData)
{
	MsgHeader sMsgHeader(nMsgType, nMsgSize);

	VxMsgNetSendStream* pMsg = NULL;
	VxMemStream* pStream = NULL;
	do
	{

		VxMemStream* pStream = new VxMemStream(nMsgSize + sizeof(MsgHeader), false);
		VxMsgNetSendStream* pMsg = VX_NEW_MSG(VxMsgNetSendStream)(pStream);//new VxMsgNetSendStream(pStream);//
		pStream->release();



		if (!pStream || !pMsg)
		{
			break;
		}



		pStream->write(sMsgHeader.m_pBufData, MsgHeader::NF_HEAD_LENGTH);

		pStream->write((char*)pMsgData, nMsgSize);
		pStream->seek(0);
		return pMsg;

	} while (0);

	VX_SAFE_RELEASE_NULL(pStream);
	VX_SAFE_RELEASE_NULL(pMsg);

	return NULL;
}


int NxProtocol::plParser(VxString* pRecvData)
{
	char* pBuffer = pRecvData->m_pString;
	int nBufferSize = pRecvData->m_nLength;
	int nOnceSize = 0;
	while (0 < nBufferSize)
	{
		if (NXPROTOCOL_FRMAE_METAHEADER_SIZE > m_nFrameMetaHeaderSize)
		{
			nOnceSize = min(nBufferSize, NXPROTOCOL_FRMAE_METAHEADER_SIZE - m_nFrameMetaHeaderSize);
			//memcpy(((char*)&m_nFrameTotalSize) + m_nFrameMetaHeaderSize, pBuffer, nOnceSize);
			memcpy(m_pBuffHeadData + m_nFrameMetaHeaderSize, pBuffer, nOnceSize);
			
			m_nFrameMetaHeaderSize += nOnceSize;
			m_nFrameTotalSize = m_nFrameMetaHeaderSize;
			if (m_nFrameMetaHeaderSize >= NXPROTOCOL_FRMAE_METAHEADER_SIZE)
			{
				short int nTemp = 0;
				memcpy(&nTemp, &m_pBuffHeadData[6], 2);
				m_nFrameTotalSize = VxConvert::NF_NTOHS(nTemp) + m_nFrameMetaHeaderSize;
				m_nFrameCurrSize = m_nFrameMetaHeaderSize;
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
			NxProtocol::plParserFrame();
			m_nFrameMetaHeaderSize = 0;
			m_nFrameTotalSize = 0;
			m_nFrameCurrSize = 0;
			memset(m_pBuffHeadData, 0, MsgHeader::NF_HEAD_LENGTH);
		}
	}
	return 1;
}

void NxProtocol::plParserFrame()
{
	VxCacheIOStream* pStream = (VxCacheIOStream*)m_client->m_socket->getRecvBuffer();
	pStream->flush();

	//VXASSERT(m_nFrameTotalSize + NXPROTOCOL_FRMAE_METAHEADER_SIZE <= pStream->readCapacity(), "");

	static int sTotalCount = 0;
	++sTotalCount;


	//VXASSERT(m_nFrameTotalSize == sProtocolHeader.m_nFrameSize, "m_nFrameTotalSize = %d, sProtocolHeader.m_nFrameSize = %d", m_nFrameTotalSize, sProtocolHeader.m_nFrameSize);
	//for (int i = 0; i < sProtocolHeader.m_nMsgCount; ++i)

	{
		MsgHeader sMsgHeader;
		unsigned short int temp;
		unsigned int nPackageSize = 0;

		pStream->read((char*)sMsgHeader.m_pBufData, MsgHeader::NF_HEAD_LENGTH);
		sMsgHeader.parseBuffData();

		VxMemIOStream* pReadStream = pStream->getReadBuffer();

		if (sMsgHeader.m_nMsgSize > pReadStream->capacity())
		{
			VxLocalString sLocalBuffer(sMsgHeader.m_nMsgSize);
			pStream->read(sLocalBuffer.getString(), sMsgHeader.m_nMsgSize);

			XGCCallLuaManager::getInstance()->recvMsg(m_client->m_nNetSocketId, sMsgHeader.m_nMsgType, sMsgHeader.m_nMsgSize, sLocalBuffer.getString());
		}
		else
		{
			if (sMsgHeader.m_nMsgSize > pReadStream->readBlockBufferSize())
			{
				pStream->fillReadBuffer();
			}
			VxString sStringBuffer = pReadStream->readBlockBuffer(sMsgHeader.m_nMsgSize);
			XGCCallLuaManager::getInstance()->recvMsg(m_client->m_nNetSocketId, sMsgHeader.m_nMsgType, sMsgHeader.m_nMsgSize, sStringBuffer.m_pString);
		}


	}

}