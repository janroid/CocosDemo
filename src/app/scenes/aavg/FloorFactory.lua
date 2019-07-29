local FloorFactory = class("FloorFactory")

local BatMask = import("BitMask")

local stairsPoints = {
    cc.p(64.00000,64.00000 ),
    cc.p(65.00000,22.00000 ),
    cc.p(-64.00000,21.00000),
    cc.p(-64.00000,64.00000)
}


local slopePoints = {
    cc.p(-64.00000,-64.00000),
    cc.p(-64.00000,-54.00000),
    cc.p(54.00000,67.00000),
    cc.p(64.00000,60.00000),
    cc.p(64.00000,-63.00000)
}

function FloorFactory:createSlopeBody()
    local body = cc.PhysicsBody:createEdgePolygon(slopePoints)
    body:setCategoryBitmask(BatMask.C_SLOPE)
    body:setCollisionBitmask(BatMask.CL_SLOPE)
    body:setContactTestBitmask(BatMask.CT_SLOPE)

    return body
end

function FloorFactory:createStairsBody()
    local body = cc.PhysicsBody:createEdgePolygon(stairsPoints)
    body:setCategoryBitmask(BatMask.C_FLOOR)
    body:setCollisionBitmask(BatMask.CL_FLOOR)
	body:setContactTestBitmask(BatMask.CT_FLOOR)

    return body
end


return FloorFactory