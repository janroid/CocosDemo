--[[--ldoc desc
@module MTTSignupSuccPop
@author CavanZhou

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MTTSignupSuccPop = class("MTTSignupSuccPop",PopupBase);
BehaviorExtend(MTTSignupSuccPop);

function MTTSignupSuccPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".views.MTTSignupSuccCtr"))
	self:loadLayout('creator/mttLobbyScene/layout/mttSignupSuccPop.ccreator')
    self.m_tip1      = g_NodeUtils:seekNodeByName(self.m_root,"tip1")
    self.m_tip2      = g_NodeUtils:seekNodeByName(self.m_root,"tip2")
    self.m_tip3      = g_NodeUtils:seekNodeByName(self.m_root,"tip3")
    self.m_tipTime3  = g_NodeUtils:seekNodeByName(self.m_root,"tiptime3")
    self.m_icon_chip = g_NodeUtils:seekNodeByName(self.m_root,"icon_chip")
    self.m_tipFree   = g_NodeUtils:seekNodeByName(self.m_root,"tipFree")
	self.m_tipTime3:setString("") -- (10分钟后开始)

	self.m_tipFree:setString(GameString.get("str_new_mtt_list_free"))

    g_NodeUtils:seekNodeByName(self.m_root,"tipTitle1"):setString(GameString.get("str_new_mtt_name"))
    g_NodeUtils:seekNodeByName(self.m_root,"tipTitle2"):setString(GameString.get("str_new_mtt_apply_fee"))
    g_NodeUtils:seekNodeByName(self.m_root,"tipTitle3"):setString(GameString.get("str_new_mtt_apply_time"))
    g_NodeUtils:seekNodeByName(self.m_root,"btn_center_txt"):setString(GameString.get("str_new_mtt_ok"))
    g_NodeUtils:seekNodeByName(self.m_root,"alert_title"):setString(GameString.get("str_hall_tournament_apply_succ1"))
    g_NodeUtils:seekNodeByName(self.m_root,"btn_close"):addClickEventListener(function(sender) self:hidden() end)
    g_NodeUtils:seekNodeByName(self.m_root,"btn_center"):addClickEventListener(function(sender) self:hidden() end)
    g_NodeUtils:seekNodeByName(self.m_root,"bg"):addClickEventListener(function(sender) end)
    g_NodeUtils:seekNodeByName(self.m_root,"pop_transparency_bg"):addClickEventListener(function(sender) self:hidden() end)
	
end

function MTTSignupSuccPop:updateUI(data)
	local str = ""
	local file = "creator/common/icon/icon_chip.png"
	if data.payType==1 then
		local arr = g_StringLib.split(data.mttData.chips,"|");
		if arr[2] and arr[2] ~= 0 then
			str = g_MoneyUtil.formatMoney(tonumber(arr[1])) .. " + " .. g_MoneyUtil.formatMoney(tonumber(arr[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr[1]));
		end
		file = "creator/common/icon/icon_chip.png"
	elseif data.payType==2 then
		local arr1 = g_StringLib.split(data.mttData.coalaa,"|");
		if arr1[2] and arr1[2] ~= 0 then
			str =  g_MoneyUtil.formatMoney(tonumber(arr1[1])) .. " + " ..  g_MoneyUtil.formatMoney(tonumber(arr1[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr1[1]));
        end
		file = "creator/common/icon/icon_coin.png"
	elseif data.payType==3 then
		str = tostring(data.mttData.point)
		file = "creator/mttLobbyScene/imgs/lobby/iconCup.png"
	elseif data.payType==4 then
		str = " x 1"
		file = "creator/mttLobbyScene/imgs/lobby/iconTicket.png"
	else
		str = GameString.get("str_new_mtt_list_free")
	end
	if data.payType<=4 then
		self.m_tipFree:setVisible(false)
		self.m_icon_chip:setVisible(true)
		self.m_tip2:setVisible(true)
	else
		self.m_tipFree:setVisible(true)
		self.m_icon_chip:setVisible(false)
		self.m_tip2:setVisible(false)
	end
	self.m_tip1:setString(data.mttData.name)
	self.m_tip2:setString(str)
	self.m_tip3:setString(require('.MTTUtil'):culTime(data.mttData.time*1000,data.mttData.now*1000,true));
	self.m_countDownT = data.mttData.time or 0
	self:countDownIntervalHandler()
	self:startCountDownInterval()
    self.m_icon_chip:setTexture(file)
end

function MTTSignupSuccPop:show(list)
    self:updateUI(list)
	PopupBase.show(self)
end

function MTTSignupSuccPop:hidden()
	self:stopCountDownInterval()
	PopupBase.hidden(self)
end

--開賽 倒計時
function MTTSignupSuccPop:stopCountDownInterval()
    if self.m_scheduleCountDownTask then
        g_Schedule:cancel(self.m_scheduleCountDownTask.eventObj)
    end
end     
function MTTSignupSuccPop:startCountDownInterval()
	self:stopCountDownInterval()
	local ct = self.m_countDownT - os.time()
	ct = ct >=0 and ct or 0
	self.m_scheduleCountDownTask = g_Schedule:schedule(function()
		self:countDownIntervalHandler()
	end,1,0,ct+1) 
end
function MTTSignupSuccPop:countDownIntervalHandler()
	local st = ""
	local date= g_TimeLib.timeDiff(self.m_countDownT,os.time()) --{sec=0, min=0, hour= 0, day=0}; 
	if tonumber(date.day)>0 then
		st = g_StringLib.substitute(GameString.get("str_room_tournament_start_time_tip4"), tonumber(date.day)) 
	elseif tonumber(date.hour)>0 then
		st = g_StringLib.substitute(GameString.get("str_room_tournament_start_time_tip3"), tonumber(date.hour)) 
	elseif tonumber(date.min)>0 then
		st = g_StringLib.substitute(GameString.get("str_room_tournament_start_time_tip2"), tonumber(date.min)) 
	elseif tonumber(date.sec)>0 then
		st = g_StringLib.substitute(GameString.get("str_room_tournament_start_time_tip1"), tonumber(date.sec)) 
	end
	if self.m_countDownT<=os.time() then
		self:stopCountDownInterval()
		self.m_countDownT = 0
		self.m_tipTime3:setString("")
		return
	end
	self.m_tipTime3:setString(st)
end


return MTTSignupSuccPop