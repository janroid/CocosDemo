
local PokerData = class("PokerData")

-- type value
-- byvalue
function PokerData:ctor(a,b)
	if b == nil then
		self.m_nByteValue = a
		self.m_nType ,self.m_nValue= self:parseByteValue(a)
	else
		self.m_nByteValue =  bit.lshift(a,8) + b
		self.m_nType = a
		self.m_nValue = b
	end
end

function PokerData:dtor()
end

function PokerData:getByteValue()
	return self.m_nByteValue
end

function PokerData:getType()
	return self.m_nType
end

function PokerData:getValue()
	return self.m_nValue
end

function PokerData:parseByteValue(value)
    if value and value > 0 then 
        local cardValue = bit.band(value,0xff) 
        local cardType  = bit.rshift(value,8)
        return cardType , cardValue
    end
end

return PokerData