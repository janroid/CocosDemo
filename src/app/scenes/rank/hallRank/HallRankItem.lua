local Friend = import("app.scenes.friend")
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local ViewBase = cc.load("mvc").ViewBase;
local HallRankItem = class("HallRankItem", ViewBase)
BehaviorExtend(HallRankItem);

HallRankItem.s_eventFuncMap = {
    [g_SceneEvent.FRIEND_RECALL_SUCCESS]    = "onRecallSuccess";
}

function HallRankItem:ctor()
    ViewBase.ctor(self)
    self:registerEvent()
    self:loadLayout()
    self.m_data = {}
end

function HallRankItem:onCleanup()
    self:unRegisterEvent()
end

function HallRankItem:loadLayout()
    local rank_hall_item = g_NodeUtils:getRootNodeInCreator('creator/rank/hallRank/rank_hall_item.ccreator');
    local item = g_NodeUtils:seekNodeByName(rank_hall_item,"root");
    item:removeFromParent(false);
    item:setPosition(0,0);
    item:setAnchorPoint(0,0);
    self:addChild(item);

    self.m_root = item;

    self:initView();
end

function HallRankItem:getDisplaySize()
    return self.m_root:getContentSize();
end

function HallRankItem:initView()
    local item = self.m_root;
    
    self.m_headNode = g_NodeUtils:seekNodeByName(item,"head_node");
    self.m_labelUserName = g_NodeUtils:seekNodeByName(item,"userName");
    self.m_labelUserMoney = g_NodeUtils:seekNodeByName(item,"userMoney"); 
    self.m_rankIcon = g_NodeUtils:seekNodeByName(item,"rankIcon");
    self.m_rankLabel = g_NodeUtils:seekNodeByName(item,"rankLabel");
    self.m_followBtn = g_NodeUtils:seekNodeByName(item,"followBtn");
    self.m_callBackBtn = g_NodeUtils:seekNodeByName(item,"callBackBtn");

    g_NodeUtils:convertTTFToSystemFont(self.m_labelUserName)

    BehaviorExtend(self.m_headNode)
    self.m_headNode:bindBehavior(BehaviorMap.HeadIconBehavior);
    
    self.m_headNode:addTouchEventListener(function(sender, eventType)
        if (eventType == ccui.TouchEventType.began) then
            self.m_beginY = self:getParent():getParent():getPositionY()
        end
        if (eventType == ccui.TouchEventType.ended) then -- up
            if math.abs(self:getParent():getParent():getPositionY() - self.m_beginY) < 5 then
                self:showPlayerInfoView()
            end
        end
    end)
    
    self.m_followBtn:addClickEventListener(function(sender)
        Log.d("HallRankItem followBtn click",self.m_data);
        g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_TRACK, self.m_data)
    end);
    
    self.m_callBackBtn:addClickEventListener(function(sender)
        print("HallRankItem callBackBtn click");
        g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_RECALL, self.m_data.uid)
    end);
    
    self.m_headNode:setSwallowTouches(false)

    self.m_followBtn:setTouchEnabled(true);
    self.m_followBtn:setSwallowTouches(false);
    self.m_followBtn:setPressedActionEnabled(true);

    self.m_callBackBtn:setTouchEnabled(true);
    self.m_callBackBtn:setSwallowTouches(false);
    self.m_callBackBtn:setPressedActionEnabled(true);
end

-- data = {
--     rank;
--     nick;
--     rankData;
--     img;
--     operate;0:无操作按钮；1-可追踪；2-不可追踪；3-可召回；4-不可召回
-- }
function HallRankItem:refreshData(data)
    data = g_TableLib.verify(data);
    self.m_data = data
    self:refreshHeadView(data);
    self:refreshBaseData(data);
    self:refreshRankData(data.rank);
    local FriendVO = Friend.FriendVO
    local formatData = FriendVO:create()
    formatData:parse(data)
    self:refreshOperate(formatData);
end

function HallRankItem:refreshBaseData(data)
    self.m_labelUserName:setString(g_StringLib.limitLength(data.nick, 22, 120) or "");
    self.m_labelUserMoney:setString(g_MoneyUtil.formatMoney(data.money or data.score));
end

function HallRankItem:refreshRankData(rank)
    rank = g_NumberLib.valueOf(rank,0)
    self.m_rankIcon:setVisible(rank <= 3 and rank >= 1);
    if rank >= 1 and rank <= 3 then 
        local src = string.format("hallRank_rank_%s.png",rank);
        local rankSprite = cc.Sprite:createWithSpriteFrameName(src)
        rankSprite:setAnchorPoint(cc.p(0,0));
        self.m_rankIcon:addChild(rankSprite)
    end 
    self.m_rankLabel:setString(rank);
    self.m_rankLabel:setVisible(rank >= 4);
end 

function HallRankItem:refreshOperate(data)
    local FriendConfig = Friend.FriendConfig
    local operate = 1
    local trackableImg = "creator/rank/hallRank/imgs/btn_trackable.png"
    local untrackableImg = "creator/rank/hallRank/imgs/btn_untrackable.png"
    local recallableImg = "creator/rank/hallRank/imgs/btn_recallable.png"
    local unrecallableImg = "creator/rank/hallRank/imgs/btn_unrecallable.png"
    if data.status == FriendConfig.STATUS.AT_PLAY then
        -- 房间内，可追踪
        operate = 1
        self.m_followBtn:getRendererNormal():setTexture(trackableImg)
        self.m_followBtn:getRendererDisabled():setTexture(trackableImg)
    elseif data.status == FriendConfig.STATUS.ON_LINE then
        -- 房间外，不可追踪
        operate = 2
        self.m_followBtn:getRendererNormal():setTexture(untrackableImg)
        self.m_followBtn:getRendererDisabled():setTexture(untrackableImg)
    elseif data.status == FriendConfig.STATUS.OFF_LINE or data.status == nil then
        --召回 push 0 可以，-1不在xx天内,-2在线,-3次数限制,-5 不是牌友
        if data.push == 0 then
            -- 可召回
            self.m_callBackBtn:getRendererNormal():setTexture(recallableImg)
            self.m_callBackBtn:getRendererDisabled():setTexture(recallableImg)
            operate = 3
        elseif data.push == -3 then
            -- 不可召回
            operate = 4
            self.m_callBackBtn:getRendererNormal():setTexture(unrecallableImg)
            self.m_callBackBtn:getRendererDisabled():setTexture(unrecallableImg)
        else
            -- 不可追踪
            operate = 2
            self.m_followBtn:getRendererNormal():setTexture(untrackableImg)
            self.m_followBtn:getRendererDisabled():setTexture(untrackableImg)
        end

    end
    operate = g_NumberLib.valueOf(operate);
    self.m_followBtn:setVisible(operate >= 1 and operate <= 2);
    self.m_callBackBtn:setVisible(operate >=3 and operate <= 4);

    self.m_followBtn:setEnabled(operate == 1);
    self.m_callBackBtn:setEnabled(operate == 3);
 
end

function HallRankItem:refreshHeadView(data)
    self.m_data = data
    local pic = data.img
    local clipPath = "hallRank_head_frame.png"
    local clipPlist = "creator/rank/hallRank/hallRank.plist"
    self.m_headNode:setHeadIcon(pic, nil, nil, clipPath,clipPlist)
end

function HallRankItem:showPlayerInfoView()
    g_PopupManager:show(g_PopupConfig.S_POPID.RANK_PLAYER_INFO_POP, self.m_data.uid)
end

function HallRankItem:onRecallSuccess(uid)
    if(self.m_data and uid == self.m_data.uid) then
        self.m_data.pushRecallLimit = -3
        self:refreshData(self.m_data)
    end
end

return HallRankItem
