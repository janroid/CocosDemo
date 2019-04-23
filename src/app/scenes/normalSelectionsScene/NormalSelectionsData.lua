
-- 数据包，init中声明外部可访问的信息
local NormalSelectionsData = {}

local SceneConfig = require('config.SceneConfig')

local function tbl_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tbl_copy(orig_key)] = tbl_copy(orig_value)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function NormalSelectionsData:init()
	self.m_roomInfo = {}
	self.m_player5Cap = true
	self.m_player9Cap = true
	self.m_normalRoom = true
	self.m_fastRoom = true
	self.m_fullRoom = true
	self.m_emptyRoom = true

	self.m_sortType = SceneConfig.roomOrderByType.bind_backward
end

function NormalSelectionsData:setFilter(filterArray)
	self.m_player5Cap = filterArray.player5Cap
	self.m_player9Cap = filterArray.player9Cap
	self.m_normalRoom = filterArray.normalRoom
	self.m_fastRoom = filterArray.fastRoom
	self.m_fullRoom = filterArray.fullRoom
	self.m_emptyRoom = filterArray.emptyRoom
end

function NormalSelectionsData:isMatchFilter(roomData)
	if self.m_player5Cap == false and roomData.player_cap == 5 then
		return false
	elseif self.m_player9Cap == false and roomData.player_cap == 9 then
		return false
	elseif self.m_normalRoom == false and roomData.flag == 1 then
		return false
	elseif self.m_fastRoom == false and roomData.flag == 2 then
		return false
	elseif self.m_fullRoom == false and roomData.playing_num == roomData.player_cap then
		return false
	elseif self.m_emptyRoom == false and roomData.playing_num == 0 then
		return false
	end
	return true
end

function NormalSelectionsData:updateData(data)
	if data.tablelist == nil or g_TableLib.isEmpty(data.tablelist) then
		return 
	end
	
	local newData = self:arrangeData(data.tablelist,data.field)
	self.m_roomInfo[data.field] = self:sortData(newData)
end

function NormalSelectionsData:makeSearchData(data)

	local listDisplay = {}
	local graphDisplay = {}
	local newData = {}
	newData.listDisplay = listDisplay
	newData.graphDisplay = graphDisplay

	if g_TableLib.isEmpty(data) then
		return newData
	end
	listDisplay[1] = {}
	graphDisplay[1] = {}

	listDisplay[1].roomID = tonumber(data[1].tid);
	listDisplay[1].bb = tonumber(data[1].bb);
    listDisplay[1].sb = tonumber(data[1].sb);
    listDisplay[1].minb = tonumber(data[1].minb);
    listDisplay[1].maxb = tonumber(data[1].maxb);
    listDisplay[1].field = tonumber(data[1].fld);
    listDisplay[1].player_cap = tonumber(data[1].all);
    listDisplay[1].flag = tonumber(data[1].flag);
    listDisplay[1].addPoint = tonumber(data[1].addPoint);
    listDisplay[1].playing_num = #data[1].users
    listDisplay[1].ip = data[1].ip;
    listDisplay[1].port = data[1].port;

    graphDisplay[1].tables = {}
	graphDisplay[1].tables[1] = {}
    graphDisplay[1].bb = tonumber(data[1].bb);
    graphDisplay[1].sb = tonumber(data[1].sb);
    graphDisplay[1].minb = tonumber(data[1].minb);
    graphDisplay[1].maxb = tonumber(data[1].maxb);
 
    graphDisplay[1].tables[1].tid = tonumber(data[1].tid);
    graphDisplay[1].tables[1].bb = tonumber(data[1].bb);
    graphDisplay[1].tables[1].sb = tonumber(data[1].sb);
    graphDisplay[1].tables[1].minb = tonumber(data[1].minb);
    graphDisplay[1].tables[1].maxb = tonumber(data[1].maxb);
    graphDisplay[1].tables[1].flag = tonumber(data[1].flag);
    graphDisplay[1].tables[1].ip = data[1].ip;
    graphDisplay[1].tables[1].port = data[1].port;
    graphDisplay[1].tables[1].pc = tonumber(data[1].pc);
    graphDisplay[1].tables[1].all = tonumber(data[1].all);
    graphDisplay[1].tables[1].players = data[1].users;

	
	return newData
end

function NormalSelectionsData:arrangeHighLevelData(data)
	local listDisplay = {}
	local graphDisplay = {}
	for i=1,#data do
		local setData = data[i]
		if setData.tables then -- 有tables证明是新的结构，需要分离出集体具体数据
			if #setData.tables > 0 then
				graphDisplay[#graphDisplay+1] = setData
				for j=1,#setData.tables do
					local tableData = setData.tables[j]
					tableData.sb = setData.sb
					tableData.bb = setData.bb
					tableData.player_cap = tableData.all
					tableData.playing_num = tableData.pc

					local newSetData = tbl_copy(setData) -- 复制一个放到list的显示列表
					newSetData.tables = nil
					-- newSetData.tid = tableData.tid
					newSetData.roomID = tableData.tid or tableData.setId
					newSetData.player_cap = tableData.all
					newSetData.playing_num = tableData.pc or 0
					newSetData.flag = tableData.flag or 0
					if newSetData.flag == 8 or newSetData.flag == 9 then
						newSetData.m_index = 1
					else
						newSetData.m_index = 0
					end
					newSetData.ip = tableData.ip
					newSetData.port = tableData.port
					listDisplay[#listDisplay+1] = newSetData
				end
			end
		else
			local newSetData = tbl_copy(setData)
			local newData = {}
			if newSetData.flag == 8 or newSetData.flag == 9 then
				newSetData.m_index = 1
			else
				newSetData.m_index = 0
			end
			newSetData.roomID = setData.tid or setData.setId
			newSetData.playing_num = setData.online or 0
			if newSetData.player_cap == nil then
				newSetData.player_cap =  newSetData.all
			end
			listDisplay[#listDisplay+1] = newSetData
		end
	end
	local newData = {}
	newData.listDisplay = listDisplay
	newData.graphDisplay = graphDisplay
	return newData
end

function NormalSelectionsData:arrangeLowLevelData( data )
	local listDisplay = {}
	local graphDisplay = {}
	for i=1,#data do
		local setData = data[i]
		local newSetData = tbl_copy(setData)
		local newData = {}
		if newSetData.flag == 8 or newSetData.flag == 9 then
			newSetData.m_index = 1
		else
			newSetData.m_index = 0
		end
		newSetData.roomID = setData.tid
		newSetData.playing_num = setData.online or 0
		if newSetData.player_cap == nil then
			newSetData.player_cap =  newSetData.all
		end
		listDisplay[#listDisplay+1] = newSetData
	end

	local index = 1
	listDisplay = self:sortByBindBackward(listDisplay)
	for i=1,#listDisplay do
		local setData = listDisplay[i]
		if setData.roomID == nil then
			setData.roomID = index
			index = index + 1
		end
	end

	local newData = {}
	newData.listDisplay = listDisplay
	newData.graphDisplay = graphDisplay
	return newData	
end

function NormalSelectionsData:arrangeData(data,field)
	-- Log.d('ssss',data)
	if field == 4 then
		return self:arrangeHighLevelData(data)
	else
		return self:arrangeLowLevelData(data)
	end
end

function NormalSelectionsData:setSortType(sortType)
	self.m_sortType = sortType
	self:sortAllData()
end

function NormalSelectionsData:sortAllData()
	for k,v in pairs(self.m_roomInfo) do
		self:sortData(v)
	end
end

function NormalSelectionsData:sortData(data)
	local listDisplay = data.listDisplay
	if self.m_sortType == SceneConfig.roomOrderByType.blind_forward then
		listDisplay =  self:sortByBindForward(listDisplay)
	elseif self.m_sortType == SceneConfig.roomOrderByType.blind_backward then
		listDisplay = self:sortByBindBackward(listDisplay)
	elseif self.m_sortType == SceneConfig.roomOrderByType.carry_forward then
		listDisplay = self:sortByCarryForward(listDisplay)
	elseif self.m_sortType == SceneConfig.roomOrderByType.carry_backward then
		listDisplay = self:sortByCarryBackward(listDisplay)
	elseif self.m_sortType == SceneConfig.roomOrderByType.seat_forward then
		listDisplay = self:sortBySeatForward(listDisplay)
	elseif self.m_sortType == SceneConfig.roomOrderByType.seat_backward then
		listDisplay = self:sortBySeatBackward(listDisplay)
	end
	data.listDisplay = listDisplay
	-- data.listDisplay = self:sortTBList(listDisplay)
	return data
end

function NormalSelectionsData:filterData(data)

	local newData = tbl_copy(data)

	for i = #newData.listDisplay, 1, -1 do
		local subData = newData.listDisplay[i]
		if self:isMatchFilter(subData) == false then
			table.remove(newData.listDisplay, i)
		end  
	end

	for i = #newData.graphDisplay, 1 , -1 do
		local subData = newData.graphDisplay[i]
		local tables = subData.tables
		for j = #tables, 1, -1 do
			local subTable = tables[j]
			if self:isMatchFilter(subTable) == false then
				table.remove(tables, j)
			end 
		end

		if #tables == 0 then
			table.remove(newData.graphDisplay, i)
		end
	end
	return newData
end

function NormalSelectionsData:getDataUseFilter(roomRank)
	local data = self.m_roomInfo[roomRank]
	if data then
		data = self:filterData(data)
		return data
	else
		return nil
	end
end

function NormalSelectionsData:getData(roomRank)
	local data = self.m_roomInfo[roomRank]
	if data then
		return data
	else
		return nil
	end
end

function NormalSelectionsData:searchData(roomID)
	local newData = {}
	newData.listDisplay = {}
	newData.graphDisplay = {}

	for k,data in pairs(self.m_roomInfo) do
		for i=1,#data.listDisplay do
			local setData = data.listDisplay[i]
			if setData.roomID == tonumber(roomID) then
				newData.listDisplay[#newData.listDisplay+1] = setData
			end
		end
		for i=1,#data.graphDisplay do
			local setData = data.graphDisplay[i]
			local newSetData = tbl_copy(setData)

			local tablesData = newSetData.tables

			for j = #tablesData, 1, -1 do
				if tablesData[j].roomID ~= tonumber(roomID) then
					table.remove(tablesData,j)
				end	
			end
			if #tablesData > 0 then 
				newData.graphDisplay[#newData.graphDisplay+1] = tablesData
			end
		end
	end
	return newData
end

function NormalSelectionsData:sortByBindForward(datas)
	table.sort(datas, function (a,b)
		return a.sb + (a.m_index*1000000000) < b.sb + (b.m_index*1000000000)
	end)
	return datas
end

function NormalSelectionsData:sortByBindBackward(datas)
	table.sort(datas, function (a,b)
		return a.sb + (a.m_index*-1000000000) > b.sb + (b.m_index*-1000000000)
	end)
	return datas
end

function NormalSelectionsData:sortByCarryForward(datas)
	table.sort(datas, function (a,b)
		return a.minb + (a.m_index*1000000000) < b.minb + (b.m_index*1000000000) 
	end)
	return datas
end

function NormalSelectionsData:sortByCarryBackward(datas)
	table.sort(datas, function (a,b)
		return a.minb + (a.m_index*-1000000000) > b.minb + (b.m_index*-1000000000)
	end)
	return datas
end

function NormalSelectionsData:sortBySeatForward(datas)
	table.sort(datas, function (a,b)
		return a.playing_num + (a.m_index*1000000000) < b.playing_num + (b.m_index*1000000000)
	end)
	return datas
end

function NormalSelectionsData:sortBySeatBackward(datas)
	table.sort(datas, function (a,b)
		return a.playing_num + (a.m_index*-1000000000) > b.playing_num + (b.m_index*-1000000000)
	end)
	return datas
end

function NormalSelectionsData:sortTBList(datas)
	if not g_TableLib.isTable(datas) or g_TableLib.isEmpty(datas) then
		return datas
	end
	
	for i,v in ipairs(datas) do
		if v.flag == 8 or v.flag == 9 then
			v.m_index = 1
		else
			v.m_index = 0
		end
	end

	table.sort(datas, function (a,b)
		return a.m_index < b.m_index
	end)
	return datas
end

function NormalSelectionsData:cleanData()
	self.m_roomInfo = {}
end

return NormalSelectionsData
