local MttNotify = require(".views.MTTNotify")
local HttpCmd = import("app.config.config").HttpCmd
local SceneConfig = require('config.SceneConfig')
local MTTListVO = require('.model.MTTListVO')
local MTTUtil = require('.MTTUtil')

local MttManager = class("MttManager")

MttManager.s_nowTime = 0;	--全局的倒计 秒
MttManager.TAG = "MttManager";

MttManager.s_eventFuncMap = {
    [g_SceneEvent.MTT_MY_MATCH_TOP_TIPS]         = "showMyMatchTopTips", -- 我的比赛 开赛通知 一分钟
    [g_SceneEvent.MTT_GLOBAL_MATCH_TOP_TIPS]     = "showGlobalMatchTopTips", -- 所有比赛通知 开赛前5分钟
	[g_SceneEvent.MTT_SHOW_ALLPY_SUCC_POP]		 = "showSignupSuccView",   -- 报名成功弹窗
	[g_SceneEvent.MTT_SHOW_APPLY_WAY_POP]        = "showApplyWayChosePop", --报名方式选择
    -- ctr move
	[g_SceneEvent.MTT_GET_LIST_REQUEST]			 = "requestMttRoomInfo", -- 列表
	[g_SceneEvent.MTT_GET_LIST_REQUEST1]		 = "requestMttMatchInfo", -- 列表
	[g_SceneEvent.MTT_APPLY_REQUEST]             = "applyMatchHandle", --报名
	[g_SceneEvent.MTT_CANCEL_REQUEST]            = "cancelApplyMatchHandle", -- 取消报名
    [g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT]   = "getWatchTournament", -- 赛事信息
    [g_SceneEvent.MTT_WATCH]                     = "trackUserHandler", -- 旁观
    [g_SceneEvent.MATCH_HALL_ENTER_ROOM]         = "onEnterMttRoom", -- 旁观
    [g_SceneEvent.REQUEST_QUICK_START]         = "requestQuickStart", -- kuaishi kaishi
}

function MttManager.getInstance()
    if(MttManager.s_instance == nil) then
        MttManager.s_instance = MttManager:create()
    end
    return MttManager.s_instance
end

function MttManager.release()
    MttManager.s_instance:onCleanup()
    MttManager.s_instance = nil
end

function MttManager:ctor()
    self:registerEvent()
    self:clear()
    self.m_needOpenMid = 0
end

function MttManager.clearData()
    if  MttManager.s_instance then
        MttManager.s_instance:clear()
    end
end

function MttManager:clear()
    self.m_mttListData = {};
    self.m_mttListApplyData = {};--报名中
    self.m_mttListHotData = {};--热门赛事 (只包括报名中的热门赛事)
    self.m_mttListOnData = {};--进行中
    self.m_mttListEndData = {};--已结束
    self.m_curMid = 0; --当前正在操作的mid
    self.m_topTabIndex = 1;
    self.m_needOpenTabBarIndex = 1
end

function MttManager:onCleanup()
    self:unRegisterEvent()
end

---注册监听事件
function MttManager:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        g_EventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function MttManager:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

--- ------ event ---------------------------------------

function MttManager:showSignupSuccView(data)
	if not data or not data.mttData or g_TableLib.isEmpty(data.mttData) then
		return
	end
	g_PopupManager:show(g_PopupConfig.S_POPID.MTT_SIGNUP_SUCC_POP,data)
end

function MttManager:showApplyWayChosePop(data,list)
	if not data or not list or g_TableLib.isEmpty(list) or g_TableLib.isEmpty(data) then
		return
	end
	g_PopupManager:show(g_PopupConfig.S_POPID.MTT_SIGNUP_WAY_POP,data,list)
end

-- 已报名的比赛通知 跳转
function MttManager:showMyMatchTopTips(jsonObj)

    local Mdata = g_JsonUtil.decode(jsonObj.Mdata)
    Mdata = require('.model.MTTListVO').parseData(Mdata);
    Log.d("MttManager.showMyMatchTopTips: after",Mdata)

    local msg = g_StringUtils.removeXmlTag(jsonObj.Msg);
    msg = g_StringUtils.convertSlashU(msg)

    local data = {
        title = msg,
        btnTx = jsonObj.Bmg,
        callBack = function()            
            if cc.Director:getInstance():getRunningScene():getName() == "RoomScene" then
                Mdata.tid = 0
                Mdata.tableType = g_RoomInfo.ROOM_TYPE_TOURNAMENT
                g_Model:setData(g_ModelCmd.ROOM_ENTER_MATCH_DATA, Mdata);-- 用户在比游戏中

            
            elseif cc.Director:getInstance():getRunningScene():getName() == "MttLobbyScene" then
                g_Model:setData(g_ModelCmd.ROOM_TOURNAMENT_DATA, Mdata) -- 用于更新rank view 数据
                g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT,{mid = Mdata.mid,time = Mdata.time})
                g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_ENTER_ROOM,{tid = 0, ip = Mdata.ip, port = Mdata.port})

            else
                self:onEnterMttRoom(Mdata)
            end
        end,
    }
    MttNotify.getInstance():setText(data):show()
end

 -- 全服比赛通知
function MttManager:showGlobalMatchTopTips(jsonObj)

    Log.d("MttManager.showGlobalMatchTopTips,befor",jsonObj)
    local _, Mdata = g_XmlUtil.decode(jsonObj.Mdata)
    Mdata = require('.model.MTTListVO').parseData(Mdata and Mdata.match);
    Log.d("MttManager.showGlobalMatchTopTips",Mdata)

    local msg = g_StringUtils.removeXmlTag(jsonObj.Msg)
    msg = g_StringUtils.convertSlashU(msg)

    local data = {
        title = msg,
        btnTx = jsonObj.Bmg ,
        callBack = function()   
            self.m_needOpenMid = tonumber(Mdata.mid)
            self.m_needOpenTabBarIndex = 0
            if cc.Director:getInstance():getRunningScene():getName() == "HallScene" then
                local mttLobbyScene = require('.MttLobbyScene')
                cc.Director:getInstance():pushScene(mttLobbyScene:create());

            else
                self:requestMttMatchInfo()
            end
        end,
    }
    MttNotify.getInstance():setText(data):show()
end

function MttManager:requestMttMatchInfo(mid)
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_LOBBY_LIST)
    if mid then
        self.m_needSaveMid = mid;
        g_HttpManager:doPost(param, self, self.onRequestMttMatchInfoSuccess1);
    else
        g_HttpManager:doPost(param, self, self.onRequestMttMatchInfoSuccess);
    end
end
function MttManager:onRequestMttMatchInfoSuccess(isSuccess, response)
    if not isSuccess or not g_TableLib.isTable(response) then
        Log.d("MttManager.onRequestMttRoomInfoFail")
        
    else
        for i=1,#response do
            local vo = require('.model.MTTListVO').parseData(response[i])
            if(response[1] == nil) then
                MttManager.s_nowTime = 0;
            else
                MttManager.s_nowTime = MTTListVO.parseData(response[1]).now;
            end
            table.insert(self.m_mttListData, vo);
            if tonumber(vo.mid)==tonumber(self.m_needOpenMid) then
                g_Model:setData(g_ModelCmd.NEW_MTT_ALL_LIST_DATA, self.m_mttListData);
                g_PopupManager:show(g_PopupConfig.S_POPID.MTT_DETAIL_POP, vo)
                self.m_needOpenMid = 0
                self.m_needOpenTabBarIndex = 1
                return
            end
        end

    end
end
function MttManager:onRequestMttMatchInfoSuccess1(isSuccess, response)
    if not isSuccess or not g_TableLib.isTable(response) then
        Log.d("MttManager.onRequestMttRoomInfoFail")
    else
        for i=1,#response do
            local vo = require('.model.MTTListVO').parseData(response[i])
            if tonumber(vo.mid)==tonumber(self.m_needSaveMid) then
                g_Model:setData(g_ModelCmd.ROOM_TOURNAMENT_DATA, vo)
                self.m_needSaveMid = 0
                return
            end
        end
    end
end

function MttManager:requestMttRoomInfo(index)
    if type(index) == 'table' then
        if(index.mid ~= nil) then
            self.m_needOpenMid = index.mid;
        end
        if(index.tabIndex ~= nil) then
            self.m_needOpenTabBarIndex = index.tabIndex;
        end
        if(index.curBlind ~= nil) then
            self.m_needOpenDetailCurBlind = index.curBlind;
        end
    else
        self.m_topTabIndex = index or self.m_topTabIndex or 1
    end
    if cc.Director:getInstance():getRunningScene():getName() ~= "RoomScene" then
        g_Progress.getInstance():show()
    end
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_LOBBY_LIST)
	g_HttpManager:doPost(param, self, self.onRequestMttRoomInfoSuccess);
end
function MttManager:onRequestMttRoomInfoSuccess(isSuccess, response)
    g_Progress.getInstance():dismiss()
	g_EventDispatcher:dispatch(g_SceneEvent.MTT_REFRESH_SUCC,true)
    if not isSuccess or not g_TableLib.isTable(response) then
		Log.d("MttManager.onRequestMttRoomInfoFail")
		self:errorCallback()
    else
    	self:paraseMttListData(response)
    end
end

function MttManager:paraseMttListData(value)
    -- Log.d('paraseMttListData----',#value) -- 太多了注释掉

    self.m_mttListData = {}; --全部
    self.m_mttListApplyData = {};
    self.m_mttListHotData = {};
    self.m_mttListOnData = {};
    self.m_mttListEndData = {};
    self.m_mttListMyData = {};
            
    local listLength = #value;
    for i=1,listLength do
        local vo = MTTListVO.parseData(value[i]);
        if MttManager.s_trackMttId and MttManager.s_trackMttId == tonumber(vo.mid) then
            MttManager.s_trackData = vo;
        end
        table.insert(self.m_mttListData, vo);
        if(vo.state == SceneConfig.displayState.STATE_APPLY) then
            table.insert(self.m_mttListApplyData, vo);
            if(vo.light == 1) then
                table.insert(self.m_mttListHotData, vo);
            end
            if(vo.btn == 4 or vo.btn==5) then
                table.insert(self.m_mttListMyData, vo);
                Log.d('zkzk now: ',vo.now,"start:",vo.time,vo.name) 
            end
        elseif(vo.state == SceneConfig.displayState.STATE_ON) then
            table.insert(self.m_mttListOnData, vo);
        elseif(vo.state == SceneConfig.displayState.STATE_END) then
            table.insert(self.m_mttListEndData, vo);
        end
    end
    MttManager.s_trackMttId = nil;
    table.sort(self.m_mttListApplyData, self.sortFunc);
    table.sort(self.m_mttListHotData,   self.sortFunc);
    table.sort(self.m_mttListOnData,    self.sortFunc);
    table.sort(self.m_mttListEndData,   self.sortFunc);
    table.sort(self.m_mttListMyData, self.sortFunc);
    self.m_mttListApplyData = self:reverseTable(self.m_mttListApplyData);
    self.m_mttListHotData   = self:reverseTable(self.m_mttListHotData);
    self.m_mttListOnData    = self:reverseTable(self.m_mttListOnData);
    self.m_mttListMyData    = self:reverseTable(self.m_mttListMyData);
    if(value[1] == nil) then
        MttManager.s_nowTime = 0;
    else
        MttManager.s_nowTime = MTTListVO.parseData(value[1]).now;
    end
    self:isReFleshUpdate(self.m_topTabIndex);

    g_Model:setData(g_ModelCmd.NEW_MTT_ALL_LIST_DATA, self.m_mttListData);
	
    if(self.m_needOpenMid > 0) then
        local mttdata = MTTUtil.getMttDataByMid(self.m_needOpenMid);
        if(mttdata) then
            g_PopupManager:show(g_PopupConfig.S_POPID.MTT_DETAIL_POP, mttdata, self.m_needOpenTabBarIndex, self.m_needOpenDetailCurBlind)
        end
        self.m_needOpenTabBarIndex = 1;
        self.m_needOpenDetailCurBlind = 0;
        self.m_needOpenMid = 0;
    end
end

function MttManager:isReFleshUpdate(index)
    if(index == 1) then --报名中
        g_Model:setData(g_ModelCmd.NEW_MTT_LIST_DATA, self.m_mttListApplyData);
    -- if(index == 1) then --所有比赛
        -- g_Model:setData(g_ModelCmd.NEW_MTT_LIST_DATA, self.m_mttListData);
    elseif(index == 2) then --热门赛事
        g_Model:setData(g_ModelCmd.NEW_MTT_LIST_DATA, self.m_mttListHotData);
    elseif(index == 3) then--进行中
        g_Model:setData(g_ModelCmd.NEW_MTT_LIST_DATA, self.m_mttListOnData);
    elseif(index == 4) then--已结束
        g_Model:setData(g_ModelCmd.NEW_MTT_LIST_DATA, self.m_mttListEndData);
    elseif(index == 5) then--我的
        g_Model:setData(g_ModelCmd.NEW_MTT_LIST_DATA, self.m_mttListMyData);
    end
end

--报名 
function MttManager:applyMatchHandle(data)
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_APPLY)
    param.mid = data.mid
    param.time = data.time
    param.payType = data.payType
	g_HttpManager:doPost(param, self, self.applyDataBack);
end

function MttManager:applyDataBack(isSuccess, result,param)
	g_Progress.getInstance():dismiss()
    if (result) then
        if(not isSuccess or g_TableLib.isEmpty(result)) then
            self:errorCallback()
            -- TopTipKit:badNetworkHandler();
            return;
        end

        self:requestMttRoomInfo();
        self.m_curMid = tonumber(result["mid"]);
        local ret = tonumber(result.ret);
        if(ret == nil) then
            ret = 0;
        end

        --报名成功 
        if(ret == 1) then
            local vo = MTTUtil.getMttDataByMid(result["mid"],param.time);
            vo.btn = self:culBtn(vo.time * 1000 - MttManager.s_nowTime * 1000,vo);
            g_Model:setData(g_ModelCmd.NEW_MTT_SINGLE_MATCH_DATA, vo);
            local types = result["payType"]; --手动维护
--          --因为加了cmd广播1017，不要手动维护了
            g_EventDispatcher:dispatch(g_SceneEvent.MTT_SHOW_ALLPY_SUCC_POP,{["mttData"] = vo, ["payType"] = types})
            -- 报名成功，发OG
            -- if not CookieService.getBoolean(CookieKeys.SENDED_MASTER_OG .. userData.uid) then
            --     EventDispatcher.getInstance():dispatch(CommandEvent.s_event, CommandEvent.s_cmd.SOCIAL_OG, {["type"] = "tournament"});
            --     CookieService.setBoolean(CookieKeys.SENDED_MASTER_OG .. userData.uid, true);
            -- end

        --报名成功并进入赛场
        elseif(ret == 2) then 
            g_EventDispatcher:dispatch(g_SceneEvent.MTT_DETAIL_CLOSE_POP)
            if cc.Director:getInstance():getRunningScene():getName() == "RoomScene" then
                result.tid = 0
                result.tableType = g_RoomInfo.ROOM_TYPE_TOURNAMENT
                    -- user in game
                    g_Model:setData(g_ModelCmd.ROOM_ENTER_MATCH_DATA, result);
            
            elseif cc.Director:getInstance():getRunningScene():getName() == "MttLobbyScene" then
                self:requestMttRoomInfo();
            else
                self:onEnterMttRoom(result)
            end

        --报名已截至 
        elseif(ret == -3) then
            self:showTopTips(GameString.get("str_hall_tournament_apply_tip1"));

        --报名名额已满 
        elseif(ret == -6) then
            self:showTopTips(GameString.get("str_hall_tournament_apply_tip2"));

        --等级不够
        elseif(ret == -8) then
            self:showTopTips(GameString.get("str_hall_tournament_apply_not_enough_level"));

        --其他余额不足
        elseif(ret == -9) then
            self:showTopTips(GameString.get("str_hall_tournament_apply_tip3"));

        --同一IP多个报名限制 
        elseif(ret == -14) then
            self:showTopTips(GameString.get("str_hall_tournament_apply_same_ip"));

        --争霸赛只有白名单才能报名 
        elseif(ret == -15) then
            self:showTopTips(GameString.get("str_hall_tournament_apply_tip3"));

        --coalaa币不足 
        elseif(ret == -100) then
            g_AlertDialog.getInstance()
                :setTitle(GameString.get("str_hall_tournament_apply_fail"))
                :setContent(GameString.get("str_hall_tournament_apply_not_enough_by"))
                :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
                :setCenterBtnTx(GameString.get("str_gift_buy_long"))
                :setCenterBtnFunc(function()
	                g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,import("app.scenes.store").StoreConfig.STORE_POP_UP_BY_PAGE)
                end)
                :show()

        --筹码不足 
        elseif(ret == -101) then
            g_AlertDialog.getInstance()
                :setTitle(GameString.get("str_hall_tournament_apply_fail"))
                :setContent(GameString.get("str_hall_tournament_apply_not_enough_chip"))
                :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
                :setCenterBtnTx(GameString.get("str_gift_buy_long"))
                :setCenterBtnFunc(function()
	                g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,import("app.scenes.store").StoreConfig.STORE_POP_UP_CHIPS_PAGE)
                end)
                :show()

        --积分不足 
        elseif(ret == -102) then
            g_AlertDialog.getInstance()
                :setTitle(GameString.get("str_hall_tournament_apply_fail"))
                :setContent(GameString.get("str_hall_tournament_apply_not_enough_score"))
                :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
                :setCenterBtnTx(GameString.get("str_common_go_now"))
                :setCenterBtnFunc(function()
                    g_EventDispatcher:dispatch(g_SceneEvent.MTT_DETAIL_CLOSE_POP)
                    self:requestQuickStart(4)
                end)
                :show()

        elseif(ret == -201) then
            self:showTopTips(GameString.get("str_new_mtt_short_of_ticket"));
        --已報名
        elseif(ret == -5) then
             self:showTopTips(GameString.get("str_new_mtt_had_applyed"));
        --其他错误 
        else
            local msg = GameString.get("str_hall_tournament_apply_tip4");
            if(g_AppManager:isDebug()) then
                msg = string.format("%s(0x%x)", msg, ret);
            end
            self:showTopTips(msg);
        end
    end
end

--取消报名 
function MttManager:cancelApplyMatchHandle(data)
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_CANCEL_SIGN)
    param.mid = data.mid
    param.time = data.time
	g_HttpManager:doPost(param, self, self.cancelMttDataHandler);
end
function MttManager:cancelMttDataHandler(isSuccess, value)
	g_Progress.getInstance():dismiss()
    if(not isSuccess or g_TableLib.isEmpty(value)) then
        return;
    end

    self:requestMttRoomInfo();
    self.m_curMid = value["mid"];
    if(value.ret == 1) then
        local vo = MTTUtil.getMttDataByMid(value["mid"]);
        vo.btn = 3;
        g_Model:setData(g_ModelCmd.NEW_MTT_SINGLE_MATCH_DATA, vo);
        self:showTopTips(GameString.get("str_new_mtt_cancel_apply_succ"));
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_CANCEL_SIGN_SCUU,vo)
    end
end

--进入房间
function MttManager:onEnterMttRoom(data)
    data.tid = data.tid or 0
	data.tableType = g_RoomInfo.ROOM_TYPE_TOURNAMENT
	local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(data)
end

-- 比赛信息
function MttManager:getWatchTournament(data)
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_MATCH_DETAIL)
    param.mid = data.mid
    param.time = data.time
	g_HttpManager:doPost(param, self, self.requestWatchTournamentHandler);
end
function MttManager:requestWatchTournamentHandler(isSuccess, result) --XmlUtil isSuccess 無用
	g_Progress.getInstance():dismiss()
    if (result) then
        local flag, xml = g_XmlUtil.decode(result);
        if(not flag) then
            self:errorCallback()
            -- TopTipKit:badNetworkHandler();
            return;
        end

        local detail = xml["detail"];
        local plrList = xml["plr"];
        local listLength = g_TableLib.isEmpty(plrList) and 0 or #plrList;
        local userList = {};
        for i=1,listLength do
            userList[i] = require(".model.TournamentUserVO").parseXML(plrList[i], i);
        end

        g_Model:setData(g_ModelCmd.TOURNAMENT_DETAIL_DATA, detail);
        g_Model:setData(g_ModelCmd.TOURNAMENT_USER_DATA, userList);
    end
end

--旁观 
function MttManager:trackUserHandler(data)
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_MATCH_TRACK)
    param.mid = data.mid
    param.time = data.time
	g_HttpManager:doPost(param, self, self.requestTrackUserHandler);
end
function MttManager:requestTrackUserHandler(isSuccess, data) --XmlUtil isSuccess 無用

    g_Progress.getInstance():dismiss()
    if(tonumber(data) ~= nil) then
        self:showTopTips(GameString.get("str_hall_tournament_track_error"));
        return
    end

    local flag, result = g_XmlUtil.decode(data);
    if not flag then
        self:showTopTips(GameString.get("str_hall_tournament_track_error"));
        -- TopTipKit:badNetworkHandler();
    else
        if (g_TableLib.isTable(result.table) and tonumber(result.table.tid) > 0 and result.table.ip ~= nil and result.table.port ~= nil) then
            local roomInfo = {["tid"] = tonumber(result.table["tid"]), ["ip"] = tostring(result.table["ip"]), ["port"] = tonumber(result.table["port"])};
            g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_ENTER_ROOM,roomInfo)      
        else
            self:showTopTips(GameString.get("str_hall_tournament_track_error"));
        end
    end
end

-- 高级场玩牌
function MttManager:requestQuickStart(field)
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.TABLE_QUICKIN)
    param.field = field
	g_HttpManager:doPost(param, self, self.onQuickStartResponse)
end

function MttManager:onQuickStartResponse(isSuccess, data)
    if not isSuccess then
        self:errorRequestQuickStart()
		return
	end
    Log.d("MttManager:onQuickStartResponse",data)
    
    if cc.Director:getInstance():getRunningScene():getName() == "RoomScene" then
        -- user in game
        data.tableType = g_RoomInfo.ROOM_TYPE_NORMAL
        g_Model:setData(g_ModelCmd.ROOM_ENTER_HIGHT_DATA, data);
        return
    end
	local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(data)
end

function MttManager:errorRequestQuickStart()

    Log.d("MttManager:errorRequestQuickStart")
    g_AlertDialog.getInstance()
        :setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_common_network_problem"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_common_retry"))
        :setRightBtnTx(GameString.get("str_common_back"))
        :setCloseBtnVisible(false)
        :setLeftBtnFunc(
            function ()
                self:requestQuickStart(4)
            end)
        :setRightBtnFunc(
            function ()    
                -- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.HIDE_LOGIN_LOADING);进入房间菊花
            end)
        :show()
end

function MttManager:errorCallback()
    self:showTopTips(GameString.get("str_login_bad_network"))
end

function MttManager:showTopTips(str)
    if not str then
        return
    end
    g_AlarmTips.getInstance():setText(str):show()
end

function MttManager:culBtn(temp,vo)
    local btn = 4;
	if temp >= 0 and temp <= tonumber(vo.beftime)*1000 and vo.btn ~=7 then
		btn = 5;--"即将开始";
	end
    return btn;
end

function MttManager.sortFunc(a, b)
    if (a.time > b.time) then
        return true;
    else
        return false;
    end
end

function MttManager:reverseTable (_t)
    local _newT = {};
    local _length = #_t;
    for i = 0, _length - 1 do
        _newT[i + 1] = _t[_length - i];
    end
    return _newT;
end
   

return MttManager