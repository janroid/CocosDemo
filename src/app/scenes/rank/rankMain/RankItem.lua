local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local RankItem = class("RankItem", cc.Layer)
BehaviorExtend(RankItem);

function RankItem:ctor()
	self:loadLayout()
end

function RankItem:loadLayout()
    self.m_imgSpriteFrame = cc.SpriteFrameCache:getInstance()
    self.m_imgSpriteFrame:addSpriteFrames("creator/rank/rankMain/rankMain.plist")
    local rank_item = g_NodeUtils:getRootNodeInCreator('creator/rank/rankMain/rank_item.ccreator');
    local item = g_NodeUtils:seekNodeByName(rank_item,"root");
    item:removeFromParent(false);
    item:setPosition(0,0);
    item:setAnchorPoint(0,0);
    self:addChild(item); 

    self.m_root = item; 

    self:initView();
end

function RankItem:initView()
    local item = self.m_root;

    self.m_headNode = g_NodeUtils:seekNodeByName(item,"head_frame");
    self.m_userName = g_NodeUtils:seekNodeByName(item,"userName");
    self.m_detail = g_NodeUtils:seekNodeByName(item,"detail");  
    self.m_arrowImg = g_NodeUtils:seekNodeByName(item, "arrowImg")

    g_NodeUtils:convertTTFToSystemFont(self.m_userName)

    BehaviorExtend(self.m_headNode)
    self.m_headNode:bindBehavior(BehaviorMap.HeadIconBehavior);
    self.m_headNode:setTouchEnabled(true);
    self.m_headNode:setSwallowTouches(false);
end

function RankItem:getDisplaySize()
    return self.m_root:getContentSize();
end

function RankItem:refreshData(data)
    data = g_TableLib.verify(data);
    self:refreshBaseData(data);
    self:refreshRankData(data.m_index);
    self:refreshHeadView(data);
end

function RankItem:refreshBaseData(data)
    self.m_userName:setString(g_StringLib.limitLength(data.m_nick or "", 24, 240))
    self.m_detail:setString(g_MoneyUtil.formatMoney(data.m_chipTotal));
    if(data.upOrDown and data.upOrDown ~= "") then
        local texture = string.format("creator/rank/rankMain/icon_rank_%s.png", data.upOrDown)
        self.m_arrowImg:setTexture(texture)
        self.m_arrowImg:setVisible(true)
    else
        self.m_arrowImg:setVisible(false)
    end
end

function RankItem:refreshRankData(rank)
    local item = self.m_root;
    local rankIcon = g_NodeUtils:seekNodeByName(item,"rankIcon");
    local rankNode = g_NodeUtils:seekNodeByName(item,"rankNode");
    rankNode:removeAllChildren(true);

    rank = g_NumberLib.valueOf(rank,10000);
    rankIcon:setVisible(rank <= 3);
    if rank >= 1 and rank <= 3 then 
        local src = string.format("ranking_%s.png",rank);
        local rankSprite = cc.Sprite:createWithSpriteFrameName(src)
        rankSprite:setAnchorPoint(cc.p(0,0));
        rankIcon:addChild(rankSprite)
    else 
        local node = cc.Node:create();
        node:setAnchorPoint(cc.p(0,0.5));
        local tt = g_StringLib.toCharArray(tostring(rank));
        local x = 0;
        local height = 0;
        for k,v in ipairs(tt) do 
            local sprite = cc.Sprite:createWithSpriteFrameName(string.format("%s.png",v))
            sprite:setAnchorPoint(0,0.5);
            local size = sprite:getContentSize();
            sprite:setPosition(cc.p(x,0));
            node:addChild(sprite);
            x = x + size.width;
            height = size.height;
        end 
        node:setContentSize(cc.p(x,height));
        node:setPosition(cc.p(-x/2,0));
        rankNode:addChild(node);
    end 
end

function RankItem:refreshHeadView(data)
    local item = self.m_root;
    self.m_headNode:addClickEventListener(function(sender)
        print("RankItem headBtn click")
        self:showPlayerInfoView(data);
    end);

    local pic = data.m_img
    local clipPath = "hallRank_head_frame.png"
    local clipPlist = "creator/rank/hallRank/hallRank.plist"
    local size = self.m_headNode:getContentSize()
    local frameBorder = 4
    self.m_headNode:setHeadIcon(pic, size.width - frameBorder, size.height - frameBorder, clipPath,clipPlist)
end


function RankItem:showPlayerInfoView(data)
    g_PopupManager:show(g_PopupConfig.S_POPID.RANK_PLAYER_INFO_POP, data.m_uid)
end

return RankItem
