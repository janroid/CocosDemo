local BatMask = import("BitMask")

local Player = class("Player",function(fileName)
        return cc.Sprite:create(fileName)
    end)

Player.S_MAXJUMP = 100000
Player.S_MAXSPEED = 400
Player.S_MASS = 200
Player.S_DENTITY = 0.3

local points = {
    {
        cc.p(-46.00000,16.00000),
        cc.p(-36.00000,12.00000),
        cc.p(-34.00000,-2.00000),
        cc.p(-51.00000,1.00000),
        cc.p(-57.00000,11.00000)
    },
    {
        cc.p(-4.00000,-60.00000),
        cc.p(-18.00000,-48.00000),
        cc.p(-19.00000,-30.00000),
        cc.p(20.00000,-30.00000),
        cc.p(17.00000,-53.00000)
    },
    {
        cc.p(20.00000,-30.00000),
        cc.p(-19.00000,-30.00000),
        cc.p(-30.00000,-27.00000),
        cc.p(-36.00000,12.00000),
        cc.p(36.00000,11.00000),
        cc.p(37.00000,-4.00000),
        cc.p(35.00000,-24.00000)
    },
    {
        cc.p(36.00000,31.00000),
        cc.p(36.00000,11.00000),
        cc.p(-36.00000,12.00000),
        cc.p(-30.00000,40.00000),
        cc.p(-8.00000,55.00000),
        cc.p(18.00000,55.00000)
    },
    {
        cc.p(60.00000,7.00000),
        cc.p(37.00000,-4.00000),
        cc.p(36.00000,11.00000),
        cc.p(56.00000,15.00000)
    }
}

function Player:ctor()
    self:setScale(0.5,0.5)

    self.m_physicsBody = cc.PhysicsBody:createPolygon(points[1],cc.PhysicsMaterial(Player.S_DENTITY, 0.5, 0.5));
    for k,v in ipairs(points) do
        if k > 1 then
            local sape = cc.PhysicsShapePolygon:create(v,cc.PhysicsMaterial(Player.S_DENTITY, 0.5, 0.5))
            self.m_physicsBody:addShape(sape,true)
        end
    end

    self.m_physicsBody:setCategoryBitmask(BatMask.C_PLAYER)
	self.m_physicsBody:setCollisionBitmask(BatMask.CL_PLAYER)
	self.m_physicsBody:setContactTestBitmask(BatMask.CT_PLAYER)
    self.m_physicsBody:addMass(self.S_MASS)
    self:setPhysicsBody(self.m_physicsBody)
    self.m_physicsBody:setVelocityLimit(200)
    self.m_physicsBody:setRotationEnable(false)
    self:frameUpdate()

    self:init()
end

function Player:init( )
    self.m_moveType = 0    -- 是否移动
    self.m_speed = 0         -- 速度
    self.m_isJump = false    -- 是否跳跃状态
    self.m_moveAngle = 90   -- 移动角度
    
    self.m_force = self.S_MASS * (self.S_MAXSPEED / 1)  -- 作用力

end

--[[
    @desc: 玩家移动
    author:{JanRoid}
    time:2019-07-19 15:20:18
    --@mtype : 1: 往前， 0：停止，-1：往后
    @return:
]]
function Player:runing(mtype)
    mtype = mtype or 0
    if mtype ~= 1 and mtype ~= -1 then
        mtype = 0
    end

    self.m_moveType = mtype
end

function Player:setAngle(angle)
    angle = angle or 0
    if angle > 360 then
        angle = angle - 360
    end

    self.m_moveAngle = angle
end

function Player:resetJump(  )
    self.m_isJump = false
end

function Player:jump()
    if self.m_isJump then
        return
    end
    self.m_physicsBody:applyImpulse(cc.p(0,Player.S_MAXJUMP))
    self.m_isJump = true
end

function Player:isRuning()
    return self.m_moveType ~= 0
end

function Player:getMoveType( )
    return self.m_moveType or 0
end


function Player:frameUpdate()
    self:scheduleUpdate(function(dt)
        local moveF = self.m_moveType*self.m_force*math.sin(math.rad(self.m_moveAngle))
        local moveJ = self.m_moveType*self.m_force*math.cos(math.rad(self.m_moveAngle))

        self.m_physicsBody:resetForces()
        self.m_physicsBody:applyForce(cc.p(moveF,moveJ))
    end)
end

return Player