
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local NoviceRewardItem = class("NoviceRewardItem", ccui.Layout)
BehaviorExtend(NoviceRewardItem);

NoviceRewardItem.s_rewardImgs = {
    [1] = {
        "creator/noviceReward/img/chip1.png",
        "creator/noviceReward/img/prop.png",
        "creator/noviceReward/img/exp.png",
    },
    [2] = {
        "creator/noviceReward/img/chip2.png",
        "creator/noviceReward/img/gift2.png",
        "creator/noviceReward/img/prop.png",
    },
    [3] = {
        "creator/noviceReward/img/chip3.png",
        "creator/noviceReward/img/gift3.png",
        "creator/noviceReward/img/prop.png",
    },
}

function NoviceRewardItem:ctor()
    self:setTouchEnabled(true)
    self:loadLayout()
end

function NoviceRewardItem:loadLayout()
    local friend_item = g_NodeUtils:getRootNodeInCreator('creator/noviceReward/noviceRewardItem.ccreator');
    local item = g_NodeUtils:seekNodeByName(friend_item,"root");
    item:removeFromParent(false);
    item:setPosition(0,0);
    item:setAnchorPoint(0,0);
    self:addChild(item);
    self.m_root = item;

    self:initView();
end

function NoviceRewardItem:getDisplaySize()
    return self.m_root:getContentSize();
end

function NoviceRewardItem:initView()
    self.m_itemBg = g_NodeUtils:seekNodeByName(self.m_root, "bg")
    self.m_labelDesc1 = g_NodeUtils:seekNodeByName(self.m_root, "desc1")
    self.m_labelDesc2 = g_NodeUtils:seekNodeByName(self.m_root, "desc2")
    self.m_labelDesc3 = g_NodeUtils:seekNodeByName(self.m_root, "desc3")
    self.m_labelDay = g_NodeUtils:seekNodeByName(self.m_root, "day")
    self.m_img1 = g_NodeUtils:seekNodeByName(self.m_root, "img1")
    self.m_img2 = g_NodeUtils:seekNodeByName(self.m_root, "img2")
    self.m_img3 = g_NodeUtils:seekNodeByName(self.m_root, "img3")
end

function NoviceRewardItem:refreshData(data)
    Log.d("reneYang","NoviceRewardItem:refreshData", data)
    self.m_data = data
    self:refreshView()
    self:refreshLight()
end
function NoviceRewardItem:getData()
    return self.m_data
end
function NoviceRewardItem:refreshView()
    self.m_labelDesc1:setString(self.m_data[1])
    self.m_labelDesc2:setString(self.m_data[2])
    self.m_labelDesc3:setString(self.m_data[3])
    local day = self.m_data.day
    self.m_labelDay:setString(GameString.get("str_login_novice_reward_title")[day])
    self.m_img1:setTexture(NoviceRewardItem.s_rewardImgs[day][1])
    self.m_img2:setTexture(NoviceRewardItem.s_rewardImgs[day][2])
    self.m_img3:setTexture(NoviceRewardItem.s_rewardImgs[day][3])
end

function NoviceRewardItem:refreshLight()
    if self.m_data["isLight"] == true then
        self.m_itemBg:setOpacity(255)
        self.m_labelDay:setOpacity(255)
        self.m_img1:setColor(cc.c3b(255, 255, 255))
        self.m_img2:setColor(cc.c3b(255, 255, 255))
        self.m_img3:setColor(cc.c3b(255, 255, 255))
    else
        self.m_itemBg:setOpacity(127)
        self.m_labelDay:setOpacity(127)
        self.m_img1:setColor(cc.c3b(127, 127, 127))
        self.m_img2:setColor(cc.c3b(127, 127, 127))
        self.m_img3:setColor(cc.c3b(127, 127, 127))
    end
end


return NoviceRewardItem