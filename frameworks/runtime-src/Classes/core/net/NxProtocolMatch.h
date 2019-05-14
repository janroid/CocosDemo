
#ifndef __NX_PROTOCOL_MATCH_H__
#define __NX_PROTOCOL_MATCH_H__

#include "NxProtocol.h"




class NxProtocolMatch : public NxProtocol
{
public:
	
	VxMsgNetSendStream*  createStream(int nMsgType, int nMsgSize, const char* pMsgData)override;

	int plParser(VxString* pRecvData)override;
	void plParserFrame()override;



public:
	NxProtocolMatch();
	~NxProtocolMatch();

	virtual void initBuffHeadData()override;


	
};

#endif	// __NX_PROTOCOL_H__

