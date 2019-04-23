local FriendConfig = require('FriendConfig')
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local FriendItem = class("FriendItem", ccui.Layout)
BehaviorExtend(FriendItem);

function FriendItem:ctor()
    self:setTouchEnabled(true)
    self:loadLayout()
end

function FriendItem:loadLayout()
    local friend_item = g_NodeUtils:getRootNodeInCreator('creator/friend/friend_list_item.ccreator');
    local item = g_NodeUtils:seekNodeByName(friend_item,"root");
    item:removeFromParent(false);
    item:setPosition(0,0);
    item:setAnchorPoint(0,0);
    self:addChild(item);

    self.m_root = item;
    self:bindBehavior(BehaviorMap.DownloadBehavior);

    self:initView();
end


function FriendItem:getDisplaySize()
    return self.m_root:getContentSize();
end

function FriendItem:initView()
    self.m_userIcon = g_NodeUtils:seekNodeByName(self.m_root, "userIcon")
    self.m_userIconFrame = g_NodeUtils:seekNodeByName(self.m_root, "userIconFrame")
    self.m_userName = g_NodeUtils:seekNodeByName(self.m_root, "userName")
    self.m_checkedBg = g_NodeUtils:seekNodeByName(self.m_root, "checkedBg")
    self.m_btnDelete = g_NodeUtils:seekNodeByName(self.m_root, "btnDelete")
    self.m_labelDelete = g_NodeUtils:seekNodeByName(self.m_root, "labelDelete")
    self.m_statusImg = g_NodeUtils:seekNodeByName(self.m_root, "status")

    g_NodeUtils:convertTTFToSystemFont(self.m_userName)
    self.m_labelDelete:setString(GameString.get('str_friend_delete'))

    self.m_btnDelete:addClickEventListener(function() 
        g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_DELETE_FRIEND, self.m_data)
    end)
end

function FriendItem:refreshData(data)
    self.m_data = data
    self:refreshView()
end
function FriendItem:getData()
    return self.m_data
end
function FriendItem:refreshView()
    self.m_userName:setString(self.m_data.name)

    -- 根据性别设置头像外框
    if self.m_data.sex == "m" then
        local sprite = cc.Scale9Sprite:create("creator/friend/imgs/icon_male_item.png")
        sprite:setContentSize(cc.size(76, 76))
        sprite:setAnchorPoint(0,0)
        self.m_userIconFrame:addChild(sprite)
    else
        local sprite = cc.Scale9Sprite:create("creator/friend/imgs/icon_female_item.png")
        sprite:setContentSize(cc.size(76, 76))
        sprite:setAnchorPoint(0,0)
        self.m_userIconFrame:addChild(sprite)
    end

    -- 设置是否在线
    if  (self.m_data.status == FriendConfig.STATUS.OFF_LINE) then
        self.m_statusImg:setTexture("creator/friend/imgs/status_offline.png")
    else
        self.m_statusImg:setTexture("creator/friend/imgs/status_online.png")
    end

    self.m_checkedBg:setVisible(false)

    -- 设置好友头像
    local size = self.m_userIcon:getContentSize()
    if tonumber(self.m_data.image) and g_HeadConfig.HEAD_IMGS[tonumber(self.m_data.image)] then
        self.m_userIcon:setTexture(g_HeadConfig.HEAD_IMGS[tonumber(self.m_data.image)].path);
        self.m_userIcon:setContentSize(size)
    else
        
      --  self.m_userIcon:setTexture(g_HeadConfig.DEFAUT_ICON)
        self:downloadImg(self.m_data.image,function(self,data)
           if data.isSuccess then 
                if self and self.m_userIcon then
                    local src = data.fullFilePath;
                    self.m_userIcon:setTexture(src);
                    self.m_userIcon:setContentSize(size)
                end
           end 
        end)
    end
    self.m_checkedBg:setVisible(self.m_data._item_checked == true)
end


function FriendItem:refreshCheckStatus(checked)
    self.m_data._item_checked = checked
    self.m_checkedBg:setVisible(checked)
end

function FriendItem:refreshDeleteBtnVisible(visible)
    self.m_btnDelete:setVisible(visible)
    self.m_userName:setVisible(not visible)
    self.m_statusImg:setVisible(not visible)
end

return FriendItem