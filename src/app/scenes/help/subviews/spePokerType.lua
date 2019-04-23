local View = class("",cc.Node)

function View:ctor(...)
    local size = ...

    local image = display.newSprite("creator/help/res/pokeType.png")
    image:align(display.CENTER,60,20):addTo(self)

    local gameString = cc.exports.GameString
    local imageSize = image:getContentSize()
    local leftGap = {200,-130}
    local height = 0
    for i=1,10 do
        local title = GameString.createLabel(gameString.get("str_help_card_tit" .. tostring(i)),g_DefaultFontName, 20)
        title:setTextColor(cc.c4b(0xc4,0xd6,0xec,0xff))
        local x = leftGap[(i % 2) + 1]
        local y = imageSize.height - math.modf((i - 1) / 2) * 80 - 30
        title:align(display.LEFT_CENTER,x,y):addTo(image)
    end

end

return View