
local ChatFaceViewCell  = class("ChatFaceViewCell",cc.Node)

--local SeatManager = import("app.scenes.normalRoom").SeatManager

ChatFaceViewCell.ctor = function(self)   
    self:init()
end

function ChatFaceViewCell:init()
    self.faceSpriteFrame = cc.SpriteFrameCache:getInstance()
    self.faceSpriteFrame:addSpriteFrames("creator/chatPop/imgs/expression_pin.plist")

    local item = g_NodeUtils:getRootNodeInCreator('creator/chatPop/faceItem.ccreator');
    --local item = g_NodeUtils:seekNodeByName(face_item,"root");
    --item:removeFromParent(false);
    item:setPosition(0,0);
    item:setAnchorPoint(0,0);
    self:addChild(item)
    self:setContentSize(item:getContentSize())

    self.m_btnFace    		= g_NodeUtils:seekNodeByName(item,'btn_face') ;
    self.m_btnFace:setSwallowTouches(false)
    self:initListener()
end 

function ChatFaceViewCell:updateCell(data)
    if g_TableLib.isEmpty(data) then
        self.m_btnFace:setOpacity(0)
        self.m_enable = false
        return
    end
    self.m_enable = true
    self.m_btnFace:setOpacity(255)
    self.m_data = data
    local textureName = self.m_data.textureName
    local textureData = self.m_data.texture
    self.m_btnFace:setContentSize(textureData.width,textureData.height)
    local btnRender = self.m_btnFace:getRendererNormal()
    local spriteFrame = self.faceSpriteFrame:getSpriteFrame(textureName)
    local rect = spriteFrame:getRect()
    btnRender:setSpriteFrame(spriteFrame,rect);
    self.m_btnFace:setOpacity(255)
    -- self.m_imgFace :setSpriteFrame(self.faceSpriteFrame:getSpriteFrame(textureName),cc.rect(0,0,0,0));
    self.m_btnFace:setZoomScale(-0.1)
    local size = btnRender:getContentSize()
       
end
function ChatFaceViewCell:initListener()
    -- self.m_imgFace:addClickEventListener(function(sender)
	-- 	self:onCellClick()
    -- end)

    local function btnFaceClickListener(sender)
        local start_pos = sender:getTouchBeganPosition()
        local end_pos = sender:getTouchEndPosition()
        if math.abs(start_pos.y - end_pos.y) > 20 then return end
        self:onCellClick()
    end
    self.m_btnFace:addClickEventListener(btnFaceClickListener)   
end

ChatFaceViewCell.onCellClick = function(self)
    if not self.m_enable then
        return 
    end
    local SeatManager = import("app.scenes.normalRoom").SeatManager:getInstance()
    local id = self.m_data.id
     if  SeatManager:selfInSeat() then
        if (id <= 30 or (id >= 61 and g_AccountInfo:getVip() ~= 0)) then
            Log.d("send emotion normal",id)
            g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_SEND_EXPRESSION,id)
            g_EventDispatcher:dispatch(g_SceneEvent.ROOM_REMOVE_CHAT_POP)
        elseif (id >= 61 and g_AccountInfo:getVip() == 0) then

            g_AlertDialog.getInstance()
		    :setTitle(GameString.get("str_play_emotion_tips"))
		    :setContent(GameString.get("str_room_gold_card_play_emotion"))
            :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
            :setLeftBtnTx(GameString.get("str_room_chat_alert_cancel"))
		    :setRightBtnTx(GameString.get("str_login_become_vip"))
            :setRightBtnFunc(function()
                local StoreConfig = import("app.scenes.store").StoreConfig
			    g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_VIP_PAGE)
		    end)
		    :show()
        end
     else
         g_AlarmTips.getInstance():setText(GameString.get("str_room_sit_down_play_emotion")):show()
     end
end


return ChatFaceViewCell