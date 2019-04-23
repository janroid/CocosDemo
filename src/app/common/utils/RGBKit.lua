
--[Comment]
--这个类专门做一些与颜色相关的操作
local RGBKit = {};
RGBKit.getR = function(hex)
    return g_BitUtil.brshift(g_BitUtil.band(hex, 0xff0000), 16)
end

RGBKit.getG = function(hex)
    return g_BitUtil.brshift(g_BitUtil.band(hex, 0x00ff00), 8)
end

RGBKit.getB = function(hex)
    return g_BitUtil.band(hex, 0x0000ff);
end

RGBKit.getRGB = function(hex)
   return RGBKit.getR(hex), RGBKit.getG(hex), RGBKit.getB(hex);
end

RGBKit.toHex = function(r, g, b)
    r = r or 0;
    g = g or 0;
    b = b or 0;
    local rhex = g_BitUtil.blshift(r, 16);
    local ghex = g_BitUtil.blshift(g, 8);
    local bhex = b;
    return g_BitUtil.bor(g_BitUtil.bor(rhex, ghex), bhex);
end

return RGBKit
