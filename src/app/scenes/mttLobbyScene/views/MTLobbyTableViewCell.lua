local MTLobbyTableViewCell  = class("MTLobbyTableViewCell",cc.TableViewCell)
local NetImageView = import("app.common.customUI").NetImageView
local MTTListTimeView = require('views.MTTListTimeView')
-- BehaviorExtend(MTLobbyTableViewCell)
-- local BehaviorExtend = import("framework.behavior").BehaviorExtend;
-- local BehaviorExtend = import("framework.behavior").BehaviorExtend
-- local BehaviorMap = import("app.common.behavior").BehaviorMap

MTLobbyTableViewCell.ctor = function(self)   
    self:init()
	g_EventDispatcher:register(g_SceneEvent.MTT_DELETE_LIST_EVENT,self,self.onCleanup)
end

function MTLobbyTableViewCell:onCleanup()
    self:stopInterval()
    g_EventDispatcher:unRegisterAllEventByTarget(self)
end

function MTLobbyTableViewCell:stopInterval()
    if self.m_viewTime then
        self.m_viewTime:clear()
    end
end

MTLobbyTableViewCell.init = function(self)

    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/mttLobbyScene/layout/roomListItem.ccreator')
    self:addChild(self.m_root)
    self.m_urlPre         = g_AccountInfo:getCDNUrl() .. "images/match/"
	self.m_iconMatch 	  = g_NodeUtils:seekNodeByName(self.m_root, 'iconMatch')
	self.m_labelMatchName = g_NodeUtils:seekNodeByName(self.m_root, 'labelMatchName')
	self.m_tx_player_num  = g_NodeUtils:seekNodeByName(self.m_root, 'tx_player_num')
	self.m_iconR 		  = g_NodeUtils:seekNodeByName(self.m_root, 'iconR')
	self.m_iconL 		  = g_NodeUtils:seekNodeByName(self.m_root, 'iconL')
	self.m_iconA 		  = g_NodeUtils:seekNodeByName(self.m_root, 'iconA')
	self.m_labelDay 	  = g_NodeUtils:seekNodeByName(self.m_root, 'labelDay')
	self.m_labelTime	  = g_NodeUtils:seekNodeByName(self.m_root, 'labelTime')
	self.m_btnSignUp 	  = g_NodeUtils:seekNodeByName(self.m_root, 'btnSignUp')
	self.m_LabelSignUp 	  = g_NodeUtils:seekNodeByName(self.m_root, 'LabelSignUp')
	self.m_lablePlayOff   = g_NodeUtils:seekNodeByName(self.m_root, 'lablePlayOff')
	-- fee
	self.m_txSignUpMoney  = g_NodeUtils:seekNodeByName(self.m_root, 'txSignUpMoney')
	self.m_iconSignUp 	  = g_NodeUtils:seekNodeByName(self.m_root, 'iconSignUp')
	--ticket
	self.m_viewTicket 	  = g_NodeUtils:seekNodeByName(self.m_root, 'viewTicket')
	self.m_iconTicket	  = g_NodeUtils:seekNodeByName(self.m_root, 'iconTicket')
	self.m_labelTicketNum = g_NodeUtils:seekNodeByName(self.m_root, 'labelTicketNum')
	self.m_labelTicketDsc = g_NodeUtils:seekNodeByName(self.m_root, 'labelTicketDsc')
	--rank
	self.m_viewPrizeDsc   = g_NodeUtils:seekNodeByName(self.m_root, 'viewPrizeDsc')
    self.m_txPrizenum     = g_NodeUtils:seekNodeByName(self.m_root, 'txPrizenum')
    --free
    self.m_lableFree      = g_NodeUtils:seekNodeByName(self.m_root, 'lableFree')
    
    self.m_viewTime = MTTListTimeView:create(self.m_labelDay,self.m_labelTime)
    self.m_viewTicket:setVisible(false)
    self.m_txSignUpMoney:setVisible(false)
    self.m_viewPrizeDsc:setVisible(false)
    self.m_lableFree:setVisible(false)
    self.m_btnSignUp:addClickEventListener(function(sender)
        self:onBtnSignUpClick(sender)
    end)
	-- BehaviorExtend(self.m_iconMatch)
	-- self.m_iconMatch:bindBehavior(BehaviorMap.HeadIconBehavior)
end

MTLobbyTableViewCell.updateCell = function(self,data)
    self.m_data = data or {}
    
	self.m_labelMatchName:setString(g_StringLib.limitLength(self.m_data.name,26,420))
    self.m_tx_player_num:setString(self.m_data.num)
    
	self.m_iconR:setVisible(self.m_data.rebuy==1 and true or false)
	self.m_iconL:setVisible(false) -- 延迟报名
	self.m_iconA:setVisible(self.m_data.addon==1 and true or false)
    
    self.m_viewTime:setInfo(self.m_data);
    self:updateApplyWay(self.m_data)
    self:updateApplyBtn(self.m_data)
    self:addUrlImage(self.m_iconMatch,self.m_urlPre .. self.m_data.img,"creator/store/Chip-100.png")
end

function MTLobbyTableViewCell:addUrlImage(imgView,url,defaultUrl)
    if imgView and url then
        
        -- imgView:removeAllChildren()
        -- imgView:setHeadIcon(url,nil,nil,nil,nil,defaultUrl)
        local urlImg = imgView:getChildren()[1]
        if not urlImg then
            urlImg = NetImageView:create(url,defaultUrl)
            local size = imgView:getContentSize()
            urlImg:setPosition(cc.p(size.width/2,size.height/2))
            urlImg:setAnchorPoint(cc.p(0.5,0.5))
            imgView:addChild(urlImg)
        else
            urlImg:setUrlImage(url)
        end
    end 

end

function MTLobbyTableViewCell:updateApplyBtn(data)

    if(g_TableLib.isTable(data)) then

        local arr = g_StringLib.split(data.signup,",");
        -- arr = self:sortSignupArr(self.arr)
        -- self.m_applyType = arr[1];
        local file = "creator/mttLobbyScene/imgs/lobby/btnEnter.png" -- 进入

        if data.btn == 1 then --等待开始
            self.m_lablePlayOff:setString(GameString.get("str_new_mtt_match_wait")) 
	    elseif data.btn == 2 then --未开放
            self.m_lablePlayOff:setString(g_StringLib.substitute(GameString.get("str_new_mtt_list_open_tips"),self.m_data.opentime))
	    elseif data.btn == 3 then --报名
            file = "creator/mttLobbyScene/imgs/lobby/btnSignUp.png"
            self.m_LabelSignUp:setString(GameString.get("str_new_mtt_list_apply")) -- 
        elseif data.btn == 4 then --取消报名
            file = "creator/common/button/btn_red_short_normal.png" 
            self.m_LabelSignUp:setString(GameString.get("str_new_mtt_list_cancel")) -- 
        elseif data.btn == 5 then --进入
            file = "creator/mttLobbyScene/imgs/lobby/btnEnter.png"
            self.m_LabelSignUp:setString(GameString.get("str_new_mtt_list_enter")) -- 
	    elseif data.btn == 6 then--观看
            file = "creator/mttLobbyScene/imgs/lobby/btnLookOn.png"
            self.m_LabelSignUp:setString(GameString.get("str_new_mtt_list_watch")) -- 
	    else --结果
            file = "creator/mttLobbyScene/imgs/lobby/btnSignUp.png"
            self.m_LabelSignUp:setString(GameString.get("str_new_mtt_list_result")) -- 
        end
        if data.btn <= 2 then
            self.m_btnSignUp:setVisible(false)
            self.m_lablePlayOff:setVisible(true)
        else
            self.m_btnSignUp:setVisible(true)
            self.m_lablePlayOff:setVisible(false)
            self.m_btnSignUp:loadTextureNormal(file)
            self.m_btnSignUp:loadTexturePressed(file)
        end
    end
end

-- 满足下显示顺序: 门票＞积分＞筹码＞卡拉币 修改后台改
-- 都不满足: 只显示筹码报名费用
-- 参赛卷 只能一张
function MTLobbyTableViewCell:updateApplyWay(data)
    if data == nil or data.signup == nil then return end
    
    self.m_viewTicket:setVisible(false)
    self.m_txSignUpMoney:setVisible(false)
    self.m_viewPrizeDsc:setVisible(false)
    self.m_lableFree:setVisible(false)

    local str = "";
    self.m_signupArr = self:getUserSignupWay(data)
    self.m_signupArr = self:sortSignupArr(self.m_signupArr)
    local sign = tonumber(self.m_signupArr[1]);

    if sign == 1 then --筹码
		local arr = g_StringLib.split(data.chips,"|");
		if arr[2] and arr[2] ~= 0 then
			str = g_MoneyUtil.formatMoney(tonumber(arr[1])) .. " + " .. g_MoneyUtil.formatMoney(tonumber(arr[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr[1]));
        end
        self.m_txSignUpMoney:setVisible(true)
        self.m_iconSignUp:setTexture("creator/common/icon/icon_chip.png")
        self.m_txSignUpMoney:setString(str)
        self.m_iconSignUp:setContentSize(cc.size(35,35))

    elseif sign == 2 then	--卡拉币
		local arr1 = g_StringLib.split(data.coalaa,"|");
		if arr1[2] and arr1[2] ~= 0 then
			str =  g_MoneyUtil.formatMoney(tonumber(arr1[1])) .. " + " ..  g_MoneyUtil.formatMoney(tonumber(arr1[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr1[1]));
        end
        self.m_txSignUpMoney:setVisible(true)
        self.m_iconSignUp:setTexture("creator/common/icon/icon_coin.png")
        self.m_txSignUpMoney:setString(str)
        self.m_iconSignUp:setContentSize(cc.size(32,32))

    elseif sign == 3 then--积分
        self.m_viewPrizeDsc:setVisible(true)
        self.m_txPrizenum:setString(tostring(data.point))

    elseif sign == 4 then--门票

        self.m_viewTicket:setVisible(true)
        if data.ticketType then
            -- local url = g_AccountInfo:getPropsUrl() .. tostring(data.ticketType).."_small" .. ".png";--加载类门票 id取图标地
            -- self:addUrlImage(self.m_iconTicket,url,"creator/mttLobbyScene/imgs/lobby/iconTicket.png")
            self.m_iconTicket:setTexture("creator/mttLobbyScene/imgs/lobby/iconTicket.png")
        end
        self.m_labelTicketDsc:setString(g_StringLib.substitute(GameString.get("str_new_mtt_list_my_ticket"),0))
        local allTicket = g_AccountInfo:getATicket()
        if allTicket and not g_TableLib.isEmpty(allTicket) then
            for key, value in pairs(allTicket) do
                if data and tostring(data.ticketType) == tostring(key) then
                    self.m_labelTicketDsc:setString(g_StringLib.substitute(GameString.get("str_new_mtt_list_my_ticket"),value)) --ticketName
                end
            end
        end

    else --免费
        self.m_lableFree:setVisible(true)
        self.m_lableFree:setString(GameString.get("str_new_mtt_list_free"))

	end
end

function MTLobbyTableViewCell:onBtnSignUpClick(sender)
    Log.d("onBtnSignUpClick ----------------",self.m_data.btn)
    if self.m_data.btn == 3 then -- 報名
        if #self.m_signupArr>1 then
            g_EventDispatcher:dispatch(g_SceneEvent.MTT_SHOW_APPLY_WAY_POP,self.m_data,self.m_signupArr)
            return
        end
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_APPLY_REQUEST,{mid = self.m_data.mid,time = self.m_data.time,payType = tonumber(self.m_signupArr[1])})

    elseif self.m_data.btn == 4 then-- 取消
        g_AlertDialog.getInstance()
            :setTitle(GameString.get("str_bigWheel_tips_title"))
            :setContent(GameString.get("str_new_mtt_cancel_apply_tip"))
            :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
            :setLeftBtnTx(GameString.get("str_new_mtt_list_cancel"))
            :setRightBtnTx(GameString.get("str_new_mtt_list_not_cancel"))
            :setLeftBtnFunc(function()
                g_EventDispatcher:dispatch(g_SceneEvent.MTT_CANCEL_REQUEST, self.m_data)
            end)
            :show()

	elseif self.m_data.btn == 5 then--进入
        g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT,{mid = self.m_data.mid,time = self.m_data.time})
        g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_ENTER_ROOM,{tid = 0, ip = self.m_data.ip, port = self.m_data.port})
        g_Model:setData(g_ModelCmd.ROOM_TOURNAMENT_DATA, self.m_data)
        
	elseif self.m_data.btn == 6 then--观看
        g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT,{mid = self.m_data.mid,time = self.m_data.time})
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_WATCH,{mid = self.m_data.mid,time = self.m_data.time})
        g_Model:setData(g_ModelCmd.ROOM_TOURNAMENT_DATA, self.m_data)
        
    elseif self.m_data.btn == 7 then -- 結果
        g_PopupManager:show(g_PopupConfig.S_POPID.MTT_DETAIL_POP, self.m_data, 4)

	end
end

MTLobbyTableViewCell.onCellTouch = function(self)
    g_PopupManager:show(g_PopupConfig.S_POPID.MTT_DETAIL_POP, self.m_data)
    -- g_PopupManager:show(UIEvent.s_event, UIEvent.s_cmd.SHOW_TOURNAMENT_DETAIL, {id = 1, mid = data.mid, time = data.time});-
end

MTLobbyTableViewCell.getUserSignupWay = function(self,data)
    local sign = data.payType or 0;
    local signArr = {sign}
	if sign == 0 then
        signArr = g_StringLib.split(data.signup,",");
    else
        return signArr
    end
    if #signArr==1 then -- 只有一种
        return signArr
    else
        local payArr = {}
        for i,sign in ipairs(signArr) do
            local num 
            if sign == "1" then --筹码
                local arr = g_StringLib.split(data.chips,"|");
                if arr[2] and arr[2] ~= 0 then
                    num = tonumber(arr[1])+ tonumber(arr[2])
                else
                    num = tonumber(arr[1])
                end
                if tonumber(g_AccountInfo:getMoney()) >= num then
                    table.insert(payArr, sign);
                end
        
            elseif sign == "2" then	--卡拉币
                local arr1 = g_StringLib.split(data.coalaa,"|");
                if arr1[2] and arr1[2] ~= 0 then
                    num = tonumber(arr1[1])+ tonumber(arr1[2])
                else
                    num = tonumber(arr1[1])
                end
                if tonumber(g_AccountInfo:getUserCoalaa()) >= num then
                    table.insert(payArr, sign);
                end
        
            elseif sign == "3" then--积分
                self.m_txPrizenum:setString(tostring(data.point))
                if tonumber(g_AccountInfo:getScore()) >= tonumber(data.point) then
                    table.insert(payArr, sign);
                end
        
            elseif sign == "4" then--门票
        
                local allTicket = g_AccountInfo:getATicket()
                if allTicket and not g_TableLib.isEmpty(allTicket) then
                    for key, value in pairs(allTicket) do
                        if data and tostring(data.ticketType) == tostring(key) then
                            self.m_labelTicketDsc:setString(g_StringLib.substitute(GameString.get("str_new_mtt_list_my_ticket"),value))
                            if tonumber(value) >= 1 then
                                table.insert(payArr, sign);
                            end
                        end
                    end
                end
        
            else --免费
                return {sign}
            end
        end
        if g_TableLib.isEmpty(payArr) then --都不满足
                
            for i,v in ipairs(signArr) do
                if v==1 then
                    table.insert(payArr,v); -- 都不满足 有筹码 显示筹码
                    return payArr
                end
            end
            table.insert(payArr,signArr[1]); -- 都不满足 无筹码 就只显示第一个
        end

        return payArr
    end
end

MTLobbyTableViewCell.sortSignupArr = function(self,signup)
    if signup and g_TableLib.isTable(signup ) then

        local arr = {}-- 6:免费,4:参赛券,3:积分,1:筹码,2:卡拉币
        for i,v in ipairs({"6","4","3","1","2"}) do
            for i,v1 in ipairs(signup) do
                if v==v1 then
                    table.insert(arr,v)
                end
            end
        end
        return arr
    end
end

function MTLobbyTableViewCell:getBeginTime()
    return self.m_labelDay:getString() .. " " .. self.m_labelTime:getString()
end

return MTLobbyTableViewCell