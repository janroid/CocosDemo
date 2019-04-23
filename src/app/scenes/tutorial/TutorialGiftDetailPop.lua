local GiftDetailPop = import('app.scenes.gift').GiftDetailePop
local GiftManager = import("app.scenes.gift").GiftManager

local TutorialGiftDetailPop = class("TutorialGiftDetailPop",GiftDetailPop)

function TutorialGiftDetailPop:onBtnBuyClick(index)
    self:sendTutorialGift()
end
function TutorialGiftDetailPop:onBtnBuyForTableClick(index)
    self:sendTutorialGift(true)
end
function TutorialGiftDetailPop:onCenterBtnSellClick(index)
    self:sendTutorialGift()
end
function TutorialGiftDetailPop:onBtnSendClick(index)
    self:sendTutorialGift()
end

function TutorialGiftDetailPop:sendTutorialGift(isBuy2Table)
    self:hidden()
    g_PopupManager:hidden(g_PopupConfig.S_POPID.POP_GIFT)
    Log.d("sendTutorialGift",self.m_data)
    g_EventDispatcher:dispatch(g_SceneEvent.BEGINNER_TUTORIAL_SEND_GIFT, self.m_data,isBuy2Table)
end
return TutorialGiftDetailPop