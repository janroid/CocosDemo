local TableLimit = class("TableLimit")	

--[Comment]
--无限制 	
TableLimit.UNLIMITED        = 0;
        
--[Comment]
--限制坐下 	
TableLimit.SIT_DOWN_LIMITED = 1;
        
--[Comment]
--限制进入 		
TableLimit.ACCESS_LIMITED   = 2;

--[Comment]
--在坐下前检查是否可以坐下
TableLimit.checkPreSitdown = function(tableLevel)
    local ret = true;
    if tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_NEWER) then
        if g_AccountInfo:getCancelLevelLimit() ~= nil and g_AccountInfo:getCancelLevelLimit() > 0 then
            -- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.OPEN_DIALOG, {
            --     ["message"]=str_room_room_prevent_steat_store_level_limit, 
            --     ["confirm"]=STR_COMMON_CONFIRM,
            -- });
        
            -- g_AlertDialog.getInstance()
            -- :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
            -- :setTitle(GameString.get("str_room_room_prevent_steat_store_level_limit"))
            -- :setCloseBtnVisible(false)
            -- :setContent(self.m_data.m_message):show()

            ret = false;				
        end
    end
    return ret;
end
        
TableLimit.check = function(tableLevel, tableType, dialog)
    local ret = TableLimit.UNLIMITED;
    
    if tableType ~= g_RoomInfo.ROOM_TYPE_NORMAL then
        ret = TableLimit.UNLIMITED;
    else
        if tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_NEWER) then
            if g_AccountInfo:getCancelMoney() ~= nil and g_AccountInfo:getCancelMoney() < (g_AccountInfo:getBankMoney()+g_AccountInfo:getMoney()) then
                ret = TableLimit.ACCESS_LIMITED;
            end
        elseif tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_PRIMARY) then
            if g_AccountInfo:getChujichangLimit() ~= nil and g_AccountInfo:getChujichangLimit() < (g_AccountInfo:getBankMoney()+g_AccountInfo:getMoney()) then
                ret = TableLimit.ACCESS_LIMITED;
           end
        elseif tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_INTERMEDIATE) then
        elseif tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_SENIOR) then
            if g_AccountInfo:getTableMoneyLimit() and (g_AccountInfo:getBankMoney()+g_AccountInfo:getMoney()) < g_AccountInfo:getTableMoneyLimit() then 
                ret = TableLimit.SIT_DOWN_LIMITED
            end
        end
    end
    return ret;
end
        
--[Comment]
--检查是否允许进入
--@param tableType
--@return ture 允许进入	
TableLimit.checkAccess = function(tableLevel, tableType, dialog)
    tableType = tableType or g_RoomInfo.ROOM_TYPE_NORMAL;
    dialog = (dialog == nil) and true or dialog;
    local result = TableLimit.check(tableLevel, tableType, dialog) ~= TableLimit.ACCESS_LIMITED;	
    if dialog and not result then
        TableLimit.openDialog(tableLevel);
    end
    return result;
end
        
--[Comment]
--检查是否允许坐下
-- @param tableType
-- @return true 允许坐下
TableLimit.checkSitDown = function(tableLevel, tableType, dialog)
    tableType = tableType or g_RoomInfo.ROOM_TYPE_NORMAL;
    dialog = (dialog == nil) and true or dialog;
    local result = TableLimit.check(tableLevel, tableType, dialog) ~= TableLimit.SIT_DOWN_LIMITED;	
    if dialog and not result then
        TableLimit.openDialog(tableLevel);
    end
    return result;
end
        
TableLimit.openDialog = function(tableLevel)
    local message = nil;
    
    if tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_NEWER) then
       message = g_StringLib.substitute(GameString.get("str_common_too_rich"), g_MoneyUtil.formatMoney(g_AccountInfo:getCancelMoney()));
    
    elseif tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_PRIMARY) then
       message = g_StringLib.substitute(GameString.get("str_common_too_rich"), g_MoneyUtil.formatMoney(g_AccountInfo:getChujichangLimit()));
    
    elseif tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_INTERMEDIATE) then
    elseif tostring(tableLevel) == tostring(g_RoomInfo.ROOM_LEVEL_SENIOR) then
       message = g_StringLib.substitute(GameString.get("str_common_too_poor"), g_MoneyUtil.formatMoney(g_AccountInfo:getTableMoneyLimit()))
    end

    if message ~= nil then
        
		g_AlertDialog.getInstance()
		:setTitle("")
		:setContent(message)
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		:setLeftBtnTx(GameString.get("str_common_go_now"))
		:setRightBtnTx(GameString.get("str_common_cancel"))
		:setCloseBtnVisible(false)
		:setLeftBtnFunc(
        function()
            g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_QUICK_START)
		end)
		:show()
        
    end
end

return TableLimit