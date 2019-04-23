
--[[
    设置用户头像
    用法：
        local BehaviorMap = import("app.common.behavior").BehaviorMap;
        BehaviorExtend(container)
        container:bindBehavior(BehaviorMap.HeadIconBehavior);
        container:setHeadIcon(pic, width, height, clipPath,clipPlist)
    说明：
        container为放置用户头像的父控件

]]
local HeadIconBehavior = class("HeadIconBehavior", BehaviorBase)
HeadIconBehavior.className_  = "HeadIconBehavior";

---对外导出接口
local exportInterface = {
    "setHeadIcon";
    "removeIcon";
};

function HeadIconBehavior:ctor()
    HeadIconBehavior.super.ctor(self, "HeadIconBehavior", nil, 1);
end

function HeadIconBehavior:dtor()
end

function HeadIconBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function HeadIconBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-- 用来设置用户头像
-- containerNode 使用该behavior的对象
-- url 图片地址
-- width,height 头像的宽高，传入nil则取containerNode的size
-- clipPath 对头像进行裁剪的模板地址
-- clipPlistPath 若模板地址是plist中小图请传入plist路径
function HeadIconBehavior:setHeadIcon(containerNode, url, width, height, clipPath, clipPlistPath,defaultImage)
    local size = containerNode:getContentSize()
    width = width or size.width
    height = height or size.height
    if url then
        local headIcon = nil
        if not g_StringLib.isEmpty(clipPath) then
            local clipNode = containerNode:getChildByName("_head_clip")
            if not clipNode then
                self:createClipNode(containerNode, width, height,defaultImage)
            end
            clipNode = containerNode:getChildByName("_head_clip")
            headIcon = clipNode:getChildByName("_head_icon")
            self:clipHead(containerNode, headIcon, clipPath, clipPlistPath)
        else
            headIcon = containerNode:getChildByName("_head_icon")
            if not headIcon then
                headIcon = self:createNetImageView(containerNode, width, height,defaultImage)
                containerNode:addChild(headIcon)
            end 
        end
        headIcon:loadTexture(defaultImage or g_HeadConfig.DEFAUT_ICON)
        if tonumber(url) then
            if g_HeadConfig.HEAD_IMGS and g_HeadConfig.HEAD_IMGS[tonumber(url)] then
                headIcon:cancelLastCallback()
                local nomStr = g_HeadConfig.HEAD_IMGS[tonumber(url)].path
			    headIcon:loadTexture(nomStr)
		    end
	    else
		    headIcon:setUrlImage(url)
	    end
    end

end

-- 对头像控件进行裁剪
function HeadIconBehavior:clipHead(containerNode, headIcon, clipPath, clipPlistPath)
    if clipPath then
        local clip = containerNode:getChildByName("_head_clip")
        local mask = clip:getStencil();
        if clipPlistPath then
            local cache = cc.SpriteFrameCache:getInstance()
            cache:addSpriteFrames(clipPlistPath)
            mask:setSpriteFrame(clipPath)
        else
            mask:setTexture(clipPath);
        end
        if mask == nil then
            Log.e("HeadIconBehavior", "clipPath or clipPlistPath is wrong")
            return 
        end
        mask:setAnchorPoint(cc.p(0,0));
        local size = headIcon:getContentSize();
        mask:setContentSize(size);
        
    end

end

-- 创建头像控件
function HeadIconBehavior:createNetImageView(containerNode, w, h,defaultImage)
    local NetImageView = import("app.common.customUI").NetImageView
    local headIcon = NetImageView:create(nil,defaultImage)
    headIcon:setAnchorPoint(cc.p(0.5,0.5))
    
    local x,y = containerNode:getPosition()
    headIcon:ignoreContentAdaptWithSize(false) 
    headIcon:setContentSize(cc.size(w, h))
    local size =containerNode:getContentSize()
    headIcon:setPosition(size.width/2, size.height/2)
    headIcon:setName("_head_icon");
    return headIcon
end

function HeadIconBehavior:createClipNode(containerNode, w, h,defaultImage)
    local clip = cc.ClippingNode:create();
    clip:setName("_head_clip")
    clip:setAlphaThreshold(0);
    clip:setInverted(false);
    clip:setAnchorPoint(cc.p(0.5,0.5));
    clip:setContentSize(cc.size(w,h))
    local size = containerNode:getContentSize()
    clip:setPosition(size.width/2, size.height/2)
    containerNode:addChild(clip)
    
    local mask = cc.Sprite:create();
    mask:setAnchorPoint(cc.p(0.5,0.5));
    clip:setStencil(mask);

    local headIcon = self:createNetImageView(containerNode,w,h,defaultImage)
    headIcon:setPosition(w/2, h/2)
    clip:addChild(headIcon)
end

function HeadIconBehavior:removeIcon(containerNode)
    if containerNode:getChildByName("_head_icon") then
        containerNode:removeChildByName("_head_icon",false)
    end
    if containerNode:getChildByName("_head_clip") then
        containerNode:removeChildByName("_head_clip",false)
    end
end

return HeadIconBehavior