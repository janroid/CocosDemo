
--[[
    礼物图标
    用法：
        local BehaviorMap = import("app.common.behavior").BehaviorMap;
        BehaviorExtend(container)
        container:bindBehavior(BehaviorMap.GiftIconBehavior);
        container:setGiftImg(pic, width, height, clipPath,clipPlist)
    说明：
        container为放置礼物图标的父控件

]]
local GiftIconBehavior = class("GiftIconBehavior", BehaviorBase)
GiftIconBehavior.className_  = "GiftIconBehavior";

---对外导出接口
local exportInterface = {
    "setGift";
    "removeIcon";
};

function GiftIconBehavior:ctor()
    GiftIconBehavior.super.ctor(self, "GiftIconBehavior", nil, 1);
end

function GiftIconBehavior:dtor()
end

function GiftIconBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function GiftIconBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-- 用来设置礼物
-- containerNode 使用该behavior的对象
-- giftId 礼物id
-- defaultImage 默认图片
-- callObj, callFunc, callParams 图片加载完后的回调
-- width,height 头像的宽高，传入nil则取containerNode的size
-- clipPath 对头像进行裁剪的模板地址
-- clipPlistPath 若模板地址是plist中小图请传入plist路径
function GiftIconBehavior:setGift(containerNode, giftId,defaultImage,callObj, callFunc, callParams, width, height, clipPath, clipPlistPath)
    local giftImg = self:createNetImageView(containerNode, width, height,defaultImage)
    self:clipHead(containerNode, giftImg, clipPath, clipPlistPath)
    giftImg:setCallback(callObj, callFunc, callParams)
    if not giftId then
        return
    end
    
    local pre = g_AccountInfo:getGiftSWFURL()
    local map = g_Model:getData(g_ModelCmd.GIFT_ID_FILE_MAPPING)
	local url = ""
    local name = tostring(giftId)
    if type(pre) ~= "string" then
        pre = ""
    end
    if map and map[name] then
        url = pre .. map[name] .. ".png"
    else
        url = pre .. tostring(name) .. ".png"
    end
    giftImg:setUrlImage(url)

end

-- 创建头像控件
function GiftIconBehavior:createNetImageView(containerNode, w, h,defaultImage)
    local NetImageView = import("app.common.customUI").NetImageView
    local giftImg = NetImageView:create(nil,defaultImage)
    giftImg:setAnchorPoint(cc.p(0.5,0.5))
    local size = containerNode:getContentSize()
    local width = w or size.width
    local height = h or size.height
    local x,y = containerNode:getPosition()
    giftImg:ignoreContentAdaptWithSize(false) 
    giftImg:setContentSize(cc.size(width, height))
    giftImg:setPosition(cc.p(size.width/2,size.height/2))
    containerNode:addChild(giftImg)
    giftImg:setName("_gift_img");
    return giftImg
end

-- 对头像控件进行裁剪
function GiftIconBehavior:clipHead(containerNode, giftImg, clipPath, clipPlistPath)
    if clipPath then
        
        local mask
        if clipPlistPath then
            local cache = cc.SpriteFrameCache:getInstance()
            cache:addSpriteFrames(clipPlistPath)
            mask = cc.Sprite:createWithSpriteFrameName(clipPath)
        else
            mask = cc.Sprite:create(clipPath);
        end
        if mask == nil then
            Log.e("GiftIconBehavior", "clipPath or clipPlistPath is wrong")
            return 
        end
        mask:setAnchorPoint(cc.p(0,0));
        local clip = cc.ClippingNode:create();
        local size = giftImg:getContentSize();
        mask:setContentSize(size);
        clip:setStencil(mask);
        clip:setAlphaThreshold(0);
        clip:setInverted(false);
        clip:setAnchorPoint(cc.p(0,0));
        containerNode:removeChildByName("_gift_img",false)
        containerNode:addChild(clip)
        clip:setName("_gift_clip")
        local containerSize = containerNode:getContentSize()
        clip:setPosition((containerSize.width-size.width)/2, (containerSize.height-size.height)/2)

        clip:addChild(giftImg);
    end

end

function GiftIconBehavior:removeIcon(containerNode)
    if containerNode:getChildByName("_gift_img") then
        containerNode:removeChildByName("_gift_img",false)
    end
    if containerNode:getChildByName("_gift_clip") then
        containerNode:removeChildByName("_gift_clip",false)
    end
end

return GiftIconBehavior