local Toast = {}

function Toast.createToast(text, parent, font_size, line_height)
	if not text or text == "" then return end
    font_size = font_size or 24
    line_height = line_height or 28

    local bg = ccui.ImageView:create("creator/common/dialog/toast_bg.png", ccui.TextureResType.localType)
    local content_size = bg:getContentSize()
    --如果找不到图片资源，也能使label有正确的位置和动画
    local offset_y = content_size.height/2
    bg:setPosition(display.cx, display.height + offset_y)

    local label = cc.Label:createWithSystemFont(text, "fonts/arial.ttf", font_size, cc.size(820,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setLineSpacing(line_height-font_size)
	local lines = label:getStringNumLines()
	label:setAlignment(lines > 1 and cc.TEXT_ALIGNMENT_LEFT or cc.TEXT_ALIGNMENT_CENTER)
	 --label和bg的锚点都是0.5，0.5，setposition是0,0在bg的左下角有点不对劲
    label:setPosition(content_size.width/2, offset_y+5)
    bg:add(label)

    if not parent then
    	parent = display.getRunningScene()
    end
    parent:add(bg,999)

    local actions = {}
    actions[#actions+1] = cc.MoveTo:create(0.15, cc.p(display.cx, display.height - offset_y))
    actions[#actions+1] = cc.DelayTime:create(2.7)
    actions[#actions+1] = cc.MoveTo:create(0.15, cc.p(display.cx, display.height + offset_y))
    actions[#actions+1] = cc.CallFunc:create(function ()
    		if bg then
    			bg:removeSelf()
    		end
    	end)
    bg:runAction(transition.sequence(actions))
end

return Toast