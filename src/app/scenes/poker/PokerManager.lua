local PokerData = require("PokerData")

local PokerManager = class("PokerManager")

local POKER_MAX_NUM = 52
local POKER_COMMON_HAND_COUNT =  7

local	POKER_TYPE_NONE = 0
local POKER_TYPE_NORMAL = 1
local	POKER_TYPE_PAIR = 2
local POKER_TYPE_TWO_PAIR = 3
local	POKER_TYPE_THREE = 4
local	POKER_TYPE_FLUSH = 5
local	POKER_TYPE_SAME_COLOR = 6
local	POKER_TYPE_FULL_HOUSE = 7--THRE_TWO,
local	POKER_TYPE_FOUR_OF_KING = 8
local	POKER_TYPE_STRAIGHT_FLUSH = 9
local	POKER_TYPE_ROYAL_FLUSH = 10


local insert = table.insert

function PokerManager.getInstance()
	if not PokerManager.s_instance then
		PokerManager.s_instance = PokerManager:create()
	end
	return PokerManager.s_instance
end

function PokerManager:release()
	delete(PokerManager.s_instance)
	PokerManager.s_instance = nil
end



function PokerManager:ctor()
	--self.m_pPokers = {}
	self:init()
end

function PokerManager:dtor()
end

function PokerManager:createPokerData(nType,nValue)
	return PokerData:create(nType,nValue)
end

function PokerManager:init()

end

function PokerManager:release()

end

local function pokerCompare( a,  b)  
	return (a:getValue() < b:getValue()) 
end



local  function factorial(n)
    if(n <= 0) then return 1; end
    if(n == 1) then return 1;
    elseif(n == 2) then return 2;
    elseif(n == 3) then return 6;
    elseif(n == 4) then return 24;
    elseif(n == 5) then return 120;
    elseif(n == 6) then return 720;
    else
		--return (n-6) * MathLib.factorial(6);
		return n*factorial(n-1)
    end
    return r;
end

local combine = function(m, n)
		if(n > m) then return 0 end
		if(n == 0) then return 1 end
    return (factorial(m) / factorial(n))/factorial(m-n)
end


local s_roaylFlushTable = {[10]=1,[11]=1,[12]=1,[13]=1,[14]=1}

function PokerManager:getSameColorPokerList( sPokers)

	local len = #sPokers
	local types = {{},{},{},{},{}}  
	for i = 1, len do
		local nType = sPokers[i]:getType()
		insert(types[nType],sPokers[i])
	end
	return types
end


function PokerManager:getRoaylFlushCardCount( sPokers)

	local len = #sPokers
	local count = 0
	for i = 1, len do
		if s_roaylFlushTable[sPokers[i]:getValue()] then
			count = count+1
		end
	end
	return count 
end


function PokerManager:getRoaylFlushProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameColorPokerList(sPokers)

	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine


	local probability = 0

	local targetCount = 0


	for k,v in pairs(sSamePokers) do
		local count = self:getRoaylFlushCardCount(v)
		local needCount = 5-count
		local f = remainCount - needCount

		if remainCount >= needCount  then

			 targetCount = targetCount+combine(remainPokers -needCount , remainCount-needCount)
		end
	end

	ret = targetCount/totalCombine

	return ret
end



function PokerManager:getStraightFlushCardCount( sPokers)

	local len = #sPokers
	local count = 1
	local startIndex = 1
	local maxCount = 1

	for i = 2, len do

		 local dcount = sPokers[i]:getValue() - sPokers[startIndex]:getValue()

		if dcount < 5 then
			count = count+1
			if count > maxCount then
				maxCount = count
			end
		else
			startIndex = i
			count = 1
		end
	end
	return maxCount 
end


function PokerManager:getSameColorPokerListEx( sPokers)

	local len = #sPokers
	local types = {{},{},{},{},{}}  
	for i = 1, len do
		local nType = sPokers[i]:getType()
		types[nType][sPokers[i]:getValue()]=sPokers[i]
	end
	return types
end


function PokerManager:getStraightFlushProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameColorPokerListEx(sPokers)
	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine
	local targetCount = 0

	for k,v in pairs(sSamePokers) do
			v[1] = v[14]
		for i = 1,10 do

			local count = 0
			for j = i , i + 4 do
				if v[j] then
					count = count + 1
				end
			end


			--还需要多少个组成同花顺
			local r = 5 - count
			local r2 = remainCount -r


			if r2 == 0 then
				targetCount = targetCount + 1
			elseif r2 > 0 then
				local t = combine(remainPokers-r,r2) 
				targetCount = targetCount + t
			end
		end


	end
	ret = targetCount/totalCombine
	return ret
end


function PokerManager:getSameValuePokerListEx( sPokers)

	local len = #sPokers
	local list = {}
	for i=1,14 do
		list[i] = 0
 	end  
	for i = 1, len do
		local value = sPokers[i]:getValue()
		list[value] = list[value] + 1
	end
	--list[1] = list[14]
	return list
end


function PokerManager:getFourOfKingProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameValuePokerListEx(sPokers)
	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine
	local targetCount = 0


		for i = 2,14 do
			local count = sSamePokers[i] or 0

			--还需要多少个组成四条
			local r = 4 - count
			local r2 = remainCount -r

			if remainCount>=r then
					if r2 == 0 then
						targetCount = targetCount + 1
					elseif r2 > 0 then
						local t = combine(remainPokers-r,r2) 
						targetCount = targetCount + t
					end
			end
		end
	
	ret = targetCount/totalCombine
	return ret
end



function PokerManager:getFullHouseProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameValuePokerListEx(sPokers)
	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine
	local targetCount = 0

	--for k,v in pairs(sSamePokers) do
		for i = 2,14 do
			local count = sSamePokers[i] or 0

			--还需要多少个组成3条
			local r = 3 - count
			r = r < 0 and 0 or r
			local r2  =  remainCount - r
			r2 = r2 < 0 and 0 or r2

			local m = combine(4-count,r)
			local n = 0

			if remainCount>=r then
					for j = 2 ,14 do
						if j ~= i then
							local c = sSamePokers[j] or 0
							if c > 0 then
								if c == 1 then
									if r2 >= 1 then
										n = n + combine(3,1) + combine(remainPokers-r-1,r2-1) 
									end
								else
									n = n +  combine(remainPokers-r,r2) 
								end
							else
								if r2 >= 2 then
									n = n + combine(r2,2) 
								end
							end

						end
					end
			end

			targetCount = targetCount + m*n
		end
	--end
	ret = targetCount/totalCombine
	return ret
end




function PokerManager:getSameColorPokerCount(sPokers)

	local len = #sPokers
	local types = {0,0,0,0,0}  
	for i = 1, len do
		local nType = sPokers[i]:getType()
		types[nType] = types[nType]+1
		--insert(types[nType],sPokers[i])
	end
	return types
end




function PokerManager:getSameColorProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sTypePokers = self:getSameColorPokerCount(sPokers)
	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine
	local targetCount = 0


		for i = 1,4 do
			local count = sTypePokers[i] or 0

			local r = 5 - count
			r = r < 0 and 0 or r
			local r2  =  remainCount - r
			r2 = r2 < 0 and 0 or r2

			local m = 0
			local n = 0

			if remainCount>=r then
				 m = combine(13-count,r)
				 n = combine(remainPokers - r,r2)
			end
			targetCount = targetCount + m*n
		end
	
	ret = targetCount/totalCombine
	return ret
end



function PokerManager:getFlushProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameValuePokerListEx(sPokers)
	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine
	local targetCount = 0

	--for k,v in pairs(sSamePokers) do
		sSamePokers[1] = sSamePokers[14]

		for i = 1,10 do
			local count = 0
			for j = i , i + 4 do
				if sSamePokers[j] > 0 then
					count = count + 1
				end
			end

			local r = 5 - count
			r = r < 0 and 0 or r
			local r2  =  remainCount - r
			r2 = r2 < 0 and 0 or r2

			local s = 1
			local n = 0
			if remainCount >= r then
				for j=1,r do
					s = s*combine(4,1) 
				end

				 n = combine(remainPokers - r,r2)
			end

			targetCount = targetCount+ s*n
			
		
		end
--	end
	ret = targetCount/totalCombine
	return ret
end



function PokerManager:getThreeProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameValuePokerListEx(sPokers)
	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine
	local targetCount = 0

	--for k,v in pairs(sSamePokers) do
		for i = 2,14 do
			local count = sSamePokers[i] or 0

			--还需要多少个组成3条
			local r = 3 - count
			r = r < 0 and 0 or r
			local r2  =  remainCount - r
			r2 = r2 < 0 and 0 or r2


			local m = 0
			local n = 0
			if remainCount >= r then
				 m = combine(4-count,r)
				 n = combine(remainPokers-r,r2) 
			end
	
			targetCount = targetCount + m*n
		end
	--end
	ret = targetCount/totalCombine
	return ret
end




function PokerManager:getTwoPairProbability(sPokers)
	
	local len = #sPokers
	local ret = 0
	local sSamePokers = self:getSameValuePokerListEx(sPokers)

	local remainCount = self.m_remainCount
	local remainPokers = self.m_remainPokers
	local totalCombine = self.m_totalCombine


	local targetCount = 0

	--for k,v in pairs(sSamePokers) do
		for i = 2,14 do
			local count = sSamePokers[i] or 0

			--还需要多少个组成2条
			local r = 2 - count
			r = r < 0 and 0 or r
			local r2  =  remainCount - r
			r2 = r2 < 0 and 0 or r2

			local m = combine(4-count,r)
			local n = 0

			if remainCount>=r then

				for j = i+1 ,14 do
					local c = sSamePokers[j] or 0

					if c > 0 then
						if c == 1 then
							if r2 >= 1 then
								n = n + combine(3,1)* combine(remainPokers-r-1,r2-1) 
							end
						else
							n = n +  combine(remainPokers-r,r2) 
						end
					else
						if r2 >= 2 then
							n = n + combine(4,2)*combine(remainPokers-r-2,r2-2) 
						end
					end
				end
			end

			targetCount = targetCount + m*n
		end
	--end
	ret = targetCount/totalCombine
	return ret
end


function PokerManager:getPokersProbability(sBytePokers)
	local len = #sBytePokers
	local sPokers = {}
	for i=1,len do
		local poker = PokerData:create(sBytePokers[i])
		insert(sPokers,poker)
	end

	table.sort(sPokers, pokerCompare)


	len = #sPokers
	self.m_remainCount = POKER_COMMON_HAND_COUNT - len
	self.m_remainPokers = POKER_MAX_NUM - len

	self.m_totalCombine = combine(self.m_remainPokers,self.m_remainCount) 

	local cardProbability = {}


	local nRet = self:getRoaylFlushProbability(sPokers)
	cardProbability[1] = tonumber(string.format("%.2f", (nRet * 100)))
--	print("RoaylFlush ="..string.format( "%.6f", nRet))

	nRet = self:getStraightFlushProbability(sPokers)
	cardProbability[2] = tonumber(string.format("%.2f", (nRet * 100)))
	--print("StraightFlush ="..string.format( "%.6f", nRet))

	nRet = self:getFourOfKingProbability(sPokers )
	cardProbability[3] = tonumber(string.format("%.2f", (nRet * 100)))
	--print("FourOfKing ="..string.format( "%.6f", nRet))

	nRet = self:getFullHouseProbability(sPokers)
	cardProbability[4] = tonumber(string.format("%.2f", (nRet * 100)))
	--print("FullHouse ="..string.format( "%.6f", nRet))

	nRet = self:getSameColorProbability(sPokers)
	cardProbability[5] = tonumber(string.format("%.2f", (nRet * 100)))
--	print("SameColor ="..string.format( "%.6f", nRet))

	nRet = self:getFlushProbability(sPokers)
	cardProbability[6] = tonumber(string.format("%.2f", (nRet * 100)))
	--print("Flush ="..string.format( "%.6f", nRet))

	nRet = self:getThreeProbability(sPokers)
	cardProbability[7] = tonumber(string.format("%.2f", (nRet * 100)))
	--print("Three ="..string.format( "%.6f", nRet))

	nRet = self:getTwoPairProbability(sPokers)
	cardProbability[8] = tonumber(string.format("%.2f", (nRet * 100)))
	--print("TwoPair ="..string.format( "%.6f", nRet))
	
	local reset = false
	for i= 1,8 do
		if reset then
			cardProbability[i] = 0
		end
		if cardProbability[i] >= 100.0 then
			cardProbability[i] = 100.0
			reset = true
		end
	end
	
	cardProbability[2] = tonumber(string.format("%.2f", cardProbability[2] - cardProbability[1]))
	cardProbability[5] = tonumber(string.format("%.2f", cardProbability[5] - cardProbability[2] - cardProbability[1]))
	cardProbability[6] = tonumber(string.format("%.2f", cardProbability[6] - cardProbability[2] - cardProbability[1]))
	
	for i= 1,8 do
		if cardProbability[i] < 0 then
			cardProbability[i] = 0
		end
	end
	return cardProbability
end



return PokerManager