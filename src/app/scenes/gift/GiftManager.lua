local HttpCmd = import("app.config.config").HttpCmd
local GiftVO = require(".GiftVO")

--[Comment]
--礼物模块

local GiftManager = class("GiftManager")
local BehaviorMap = import("app.common.behavior").BehaviorMap
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
BehaviorExtend(GiftManager);
function GiftManager.getInstance()
    if(GiftManager.s_instance == nil) then
        GiftManager.s_instance = GiftManager:create()
    end
    return GiftManager.s_instance
end

function GiftManager.release()
    GiftManager.s_instance:onCleanup()
    GiftManager.s_instance = nil
end

function GiftManager:ctor()
    self:bindBehavior(BehaviorMap.DownloadBehavior);
    self:initialize()
end

function GiftManager:onCleanup()
    self:unRegisterEvent()
end
GiftManager.TAG = "GiftManager";
GiftManager.s_eventFuncMap = {
    [g_SceneEvent.OPEN_GIFT_POPUP] =               "onOpenGiftPopup",
    [g_SceneEvent.LOGIN_SUCCESS]	=              "onUserLoggedIn",
    [g_SceneEvent.GIFT_USE] =                      "onGiftUse",
    [g_SceneEvent.GIFT_BUY_FOR_SELF] =             "onBuyGiftForSelf",
    [g_SceneEvent.GIFT_BUY_FOR_PERSON] =           "onBuyGiftForPerson",
    [g_SceneEvent.GIFT_BUY_FOR_TABLE] =            "onBuyGiftForTable",
    [g_SceneEvent.SALE_OVERDUE_GIFT] =             "onSaleOverdueGift",
    [g_SceneEvent.QUICKLY_SALE_ALL_OVERDUE_GIFT] = "qucikSaleAllDueGift",
    [g_SceneEvent.GIFT_CATEGORY_TAG_CHANGE] =      "onCategoryTagChange",
    [g_SceneEvent.GIFT_DIALPG_ON_POPUP_END] =      "onGiftDialogPopupEnd",
};


GiftManager.initialize = function(self)
    GiftManager.m_giftIdFileMapping = {};
    g_Model:setData(g_ModelCmd.GIFT_ID_FILE_MAPPING, GiftManager.m_giftIdFileMapping);	
    self:registerEvent()
    GiftManager.m_selectedCategory     = "bychip"; -- 上边第一个选项 -> 筹码礼物
    GiftManager.m_myGiftSelectedTag    = "0";      -- 左边第一个选项 - > 全部(我的礼物)
    GiftManager.m_selectedTag          = "0";      -- 左边第一个选项 - > 全部 
end


---注册监听事件
function GiftManager:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        -- assert(self[v],"配置的回调函数不存在")
	        g_EventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function GiftManager:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end
        
--[Comment]
--销售礼物	
GiftManager.onSaleOverdueGift = function(self, data)
    Log.d("GiftManager.onSaleOverdueGift")
    self.m_giftId   = data["id"];
    local giftType  = data["type"];
    local info      = self.m_giftId .. ":" .. giftType;
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_SELL)
    postData.id = info
    g_HttpManager:doPost(postData,self, self.resultCallback);
end

--[Comment]		
--一键出售所有礼物
GiftManager.qucikSaleAllDueGift = function(self)
    local array         = g_Model:getData(g_ModelCmd.GIFT_ALL_DATA);
    self.m_dueGiftlist  = g_Model:getData(g_ModelCmd.GIFT_LIST_OWNED);	
    self.m_salePrice = 0;
    if array ~= nil and self.m_dueGiftlist ~= nil then
        for i = 1, #array do
            for j = 1, #self.m_dueGiftlist do
                if(g_TableLib.isTable(array[i]) and g_TableLib.isTable(self.m_dueGiftlist[j])) then
                    if array[i]["type"] == "1" and self.m_dueGiftlist[j].giftType == "2" then     --找出即使筹码购买的而且是过期的礼物 giftVO中字段type 改为 types
                        if tostring(array[i].id) == tostring(self.m_dueGiftlist[j].id) then	                        -- 根据过期的礼物id找出与之对应的礼物id的价格
                            self.m_salePrice = self.m_salePrice + math.floor((array[i].price) * 30 / 100);
                        end	
                    
                    elseif array[i]["type"]== "2" and self.m_dueGiftlist[j].giftType=="2" then   --找出即使卡拉比购买的而且是过期的礼物
                        if tostring(array[i].id) == tostring(self.m_dueGiftlist[j].id) then                                --根据过期的礼物id找出与之对应的礼物id的价格
                            local current = tonumber(GameString.get("str_common_currency_multiple"))
                            self.m_salePrice = self.m_salePrice + math.floor( (array[i].price) * 30/100 * current * 2000);
                        end
                    end
                end
            end
         end
    end

    -- :setContent(g_StringLib.substitute(GameString.get("str_gift_sale_all_due_gift_price_prompt") ,Formatter.formatBigNumber(self.m_salePrice)))
    g_AlertDialog.getInstance()
        :setContent(g_StringLib.substitute(GameString.get("str_gift_sale_all_due_gift_price_prompt") ,g_MoneyUtil.formatMoney(self.m_salePrice)))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_logout_btn_cancel"))
        :setRightBtnFunc(function()
            self:qucikSaleAllDueGiftCallback(2)
        end)
        :setRightBtnTx(GameString.get("str_logout_btn_confirm"))
        :setRightBtnFunc(function()
            self:qucikSaleAllDueGiftCallback(1)
        end)
        :show()
end

GiftManager.qucikSaleAllDueGiftCallback = function(self, types)
    Log.d("GiftManager.qucikSaleAllDueGiftCallback")
    if types == 1 then
        local infoArray = {};
        for i = 1 , #self.m_dueGiftlist do
            if self.m_dueGiftlist[i].giftType == "2" then
                g_ArrayUtils.push(infoArray, self.m_dueGiftlist[i].id .. ":" .. self.m_dueGiftlist[i]["type"]);
            end
        end
        local info = g_StringLib.join(infoArray, ",");
        local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_SELL)
        postData.id = info
        self.m_salePrice = 0;
        g_HttpManager:doPost(postData, self, self.resultDueGiftCallback);
    else
        self.m_salePrice = 0;  -- 取消弹框时候将 价格从新置为0;
    end
end

GiftManager.resultDueGiftCallback = function(self,isSuccess, data)
    if not isSuccess then
        self:errorCallback()
    end
    if data ~= nil then
        local flag, saleDueGiftData = isSuccess, data
        if flag and g_TableLib.isTable(saleDueGiftData) then
            if saleDueGiftData.ret == 1 then
                self:showTopTip(GameString.get("str_gift_gift_sale_succeed"));
                        
                for i = 1, #self.m_dueGiftlist do
                    if self.m_dueGiftlist.giftType == "2" then    --找出过期礼物
                        g_ArrayUtils.splice(self.m_dueGiftlist, i, 1);
                    end
                end
                g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, self.m_dueGiftlist);
                self:onCategoryTagChange();
            else
                self:showTopTip(GameString.get("str_gift_gift_sale_fail"));
            end	
        else
            Log.e(self.TAG, "resultDueGiftCallback", "decode json has an error occurred!");
        end
    else
        self:showTopTip(GameString.get("str_gift_gift_sale_fail"));
    end
     g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
end
        
GiftManager.errorCallback = function(self)
    self:showTopTip(GameString.get("str_login_bad_network"))
end
GiftManager.showTopTip = function(self,str)
    g_AlarmTips.getInstance():setText(str):show()
end
        
GiftManager.resultCallback = function(self,isSuccess,data,param)
    if not isSuccess then
        self:errorCallback()
    end
    if data ~= nil then
        local flag, saleGiftData = isSuccess,data
        if flag and g_TableLib.isTable(saleGiftData) then
            if saleGiftData.ret == 1 then
                self:showTopTip(GameString.get("str_gift_gift_sale_succeed"));
                local giftlist = g_Model:getData(g_ModelCmd.GIFT_LIST_OWNED);
                for i = 1, #giftlist do
                    if giftlist[i] and giftlist[i].id == self.m_giftId then
                        g_ArrayUtils.splice(giftlist, i, 1);
                        break;
                    end
                end
                g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, giftlist);
                self:onCategoryTagChange();
            else
                self:showTopTip(GameString.get("str_gift_gift_sale_fail"));
            end		
        else
            Log.e(self.TAG, "resultCallback", "decode json has an error occurred!");
        end
    else
        self:showTopTip(GameString.get("str_gift_gift_sale_fail"));
    end	
     g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
end
        
--[Comment]
--弹出礼物窗口
GiftManager.onOpenGiftPopup = function(self, data)
    local params = {};
    params.isInRoom = data.isInRoom;
    params.uid = data.friend;
    params.seatId = data.seatId;
    params.userNick = data.userNick;
    params.type = data.type
    if data["tabId"] ~= nil then
        params.tabId = data["tabId"];
    end
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_GIFT,params)
end

--[Comment]
--礼物窗口弹出后，开始初始化礼物数据(为了解耦这样做。。。)
GiftManager.onGiftDialogPopupEnd = function(self, data)
    self.m_selectedCategory     = data.topSelect;
    self.m_myGiftSelectedTag    = data.leftSelect;     
    self.m_selectedTag          = data.myGiftSelect;      
    self:cacheGiftLua();
    self:setMyGiftDisplayingData();
end
        
--[Comment]
--用户登录处理，清理前一个用户的数据，及状态，
GiftManager.onUserLoggedIn = function(self, data)
    
    g_Schedule:schedulerOnce(function()
        self.m_buzy = false;
        self.m_loadDueBuzy = false;
        self.m_loadOwnBuzy = false;
        g_Model:clearData(g_ModelCmd.GIFT_LIST_DISPLAYING);
        g_Model:clearData(g_ModelCmd.GIFT_LIST_OWNED);
        self:cacheGiftLua();
    end,1)
end
        
--[Comment]
--使用礼物
GiftManager.onGiftUse = function(self, data)
    Log.d("GiftManager.onGiftUse")
    local giftId     = data.giftId;
    local showTips   = data.showTips or false;
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_USE)
    postData.id = data.giftId
    g_HttpManager:doPost(postData, self, function(self,isSuccess,ret,param)
        if not isSuccess then
            self:errorCallback()
            return
        end
        if showTips and ret then
            self:showTopTip(GameString.get("str_gift_use_gift_result_msg")[ret]);
        end
        
        if tostring(ret) == "1" then
            g_AccountInfo:setUserUseGiftId(tonumber(param.id))
            local param = {}
            param.giftId = giftId
            param.mid = g_AccountInfo:getId()
            g_EventDispatcher:dispatch(g_SceneEvent.GIFT_NOTIFY_GIFT_USED, param);
            g_EventDispatcher:dispatch(g_SceneEvent.GIFT_SEV_CHANGE_GIFT, data);
        end
    end , nil,nil);
     g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
end
-- 待補充
GiftManager.updateUserMoney = function(self, data)
    if not g_TableLib.isTable(data) then
        return
    end
    if (type(data.money) == "number") then
        g_AccountInfo:setMoney(data.money)
        local selfSeat = import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeat()
        if selfSeat then
            local data12 = selfSeat:getSeatData()
            selfSeat:getSeatData().totalChips = data.money;
        end
    end
    if (type(data.coalaa) == "number") then
        g_AccountInfo:setUserCoalaa(data.coalaa)
    end
end

--[Comment]
-- 给自己买礼物
GiftManager.onBuyGiftForSelf = function(self, data)
    Log.d("GiftManager.onBuyGiftForSelf")
    --如果是新手引导，不处理购买礼物事件
    -- if TutorialKit.isTutorial() then
    --      g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
    --     return;
    -- end
	local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_BUY)
    postData.id    = data.id;
    postData.type = data.type
    g_HttpManager:doPost(postData, self, function(self,isSuccess,ret,param)
        local flag, jsonObj = isSuccess,ret
        if flag and g_TableLib.isTable(jsonObj) then
            if tostring(jsonObj.ret) == "1" then
                 g_EventDispatcher:dispatch(
                     
                    g_SceneEvent.GIFT_USE, {["giftId"] = param.id, ["showTips"] = false});
                self:updateUserMoney(jsonObj);
            end
            local errorF = tostring(jsonObj.ret)=="0" and param.type=="2" and -6  or jsonObj.ret-- 修改卡拉币 提示语
            self:showTopTip(GameString.get("str_gift_buy_gift_result_msg")[tostring(errorF)]);
            self:loadOwnGift();
            self:setDisplayingData();
        else
            Log.e(self.TAG, "onBuyGiftForSelf", "decode json has an error occurred!");
        end
    end, nil,nil);
     g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
end

        
--[Comment]
--赠送一个人礼物
GiftManager.onBuyGiftForPerson = function(self, data)
    Log.d("GiftManager.onBuyGiftForPerson")
    --如果是新手引导，不处理购买礼物事件
    -- if TutorialKit.isTutorial() then
    --      g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
    --     return;
    -- end
    local giftId = data.id;
    local toPersonId = data.uid or 0;	
    local toSeatId = import("app.scenes.normalRoom").SeatManager:getInstance():getSeatIdByUid(toPersonId)
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_PRESENT)
    postData.id = giftId
    postData.list = toPersonId
    postData.type = data.type
    g_HttpManager:doPost(postData, self, function(self,isSuccess,ret,param)
        local flag, jsonObj = isSuccess,ret
        if flag and g_TableLib.isTable(jsonObj) then
            if jsonObj then
                --as 1和"1"相等
                if tostring(jsonObj.ret) == "1" then
                     g_EventDispatcher:dispatch(
                        g_SceneEvent.GIFT_SEND_GIFT, {["giftId"] = giftId, ["userIds"] = {toPersonId}, ["seatIds"] = {toSeatId}});
                    self:updateUserMoney(jsonObj);
                end
                local errorF = tostring(jsonObj.ret)=="0" and param.type=="2" and -6  or jsonObj.ret-- 修改卡拉币 提示语
                self:showTopTip(GameString.get("str_gift_buy_gift_to_table_result_msg")[tostring(errorF)]);
            end
        else
            Log.e(self.TAG, "onBuyGiftForPerson", "decode json has an error occurred!");
        end 
    end, nil, nil);
     g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
end
        
--[Comment]
--给桌上的人买礼物
GiftManager.onBuyGiftForTable = function(self, data)
    Log.d("GiftManager.onBuyGiftForTable")
    --如果是新手引导，不处理购买礼物事件
    -- if TutorialKit.isTutorial() then
    --      g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
    --     return;
    -- end
    local sitDowUsers = import("app.scenes.normalRoom").SeatManager:getInstance():getSeatIds()
    local userIds = {};
    local seatIds = {};
    local giftId = data.id
    local foundSelf = false;
    if sitDowUsers then
        for i, seat in ipairs(sitDowUsers) do
            g_ArrayUtils.push(userIds, seat:getSeatData().uid);
            g_ArrayUtils.push(seatIds, seat:getSeatData().seatId);
            if seat:isSelf() then
                foundSelf = true;
            end
        end
    end
    if not foundSelf then
        self:showTopTip(GameString.get("str_gift_gift_msg_arr")[1]);
        return;
    end
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_PRESENT)
    postData.id = giftId
    postData.list = g_StringLib.join(userIds, ",")
    postData.type = data.type
    g_HttpManager:doPost(postData, self, function(self,isSuccess,ret,param)
        local flag, jsonObj = isSuccess,ret
        if flag and g_TableLib.isTable(jsonObj) then
            if jsonObj then
                if jsonObj.ret == "1" or jsonObj.ret == 1 then
                     g_EventDispatcher:dispatch(
                        g_SceneEvent.GIFT_SEND_GIFT, {["giftId"] = giftId, ["userIds"] = userIds, ["seatIds"] = seatIds});
                    self:updateUserMoney(jsonObj);
                end
                local errorF = tostring(jsonObj.ret)=="0" and param.type=="2" and -6  or jsonObj.ret-- 修改卡拉币 提示语
                self:showTopTip(GameString.get("str_gift_buy_gift_to_table_result_msg")[tostring(errorF)]);
            end
            if g_TableLib.indexof(userIds, import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeatId()) then
                local postData = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_USE)
                postData.id = giftId
                g_HttpManager:doPost(postData, self, 
                function(self,isSuccess,ret)
                        if tostring(ret) == "1" then
                            g_AccountInfo:setUserUseGiftId(tonumber(giftId))
                        end
                    end , 
                    self.errorCallback, 
                    nil,
                    "GiftManager.onBuyGiftForTable");
                self:loadOwnGift();
                self:setDisplayingData();
            end
        else
            Log.e(self.TAG, "onBuyGiftForTable", "decode json has an error occurred!");
        end 
    end, nil, nil);
     g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
end

--[Comment]
--当前显示的Tab或分类改变处理，取对应类型的数据，放到显示礼物列表中	"bychip","bycoalaa","mygift"
GiftManager.onCategoryTagChange = function(self, data)
    if data == nil then
        return;
    end
    if data.selectedCategory then
        self.m_selectedCategory = data.selectedCategory;
    end
    if data.myGiftSelectedTag then
        self.m_myGiftSelectedTag = data.myGiftSelectedTag;
    end
    if data.selectedTag then
        self.m_selectedTag = data.selectedTag;
    end
    if not self.m_buzy then
       if not (self.m_selectedCategory == "mygift") and g_TableLib.indexof({"bychip", "bycoalaa"}, self.m_selectedCategory) then
            if not self:getGiftData() or self:getGiftData() == GameString.get("str_common_php_request_error_msg") then
                self:cacheGiftLua();
            end
        end
    end	
    if self.m_selectedCategory == "mygift" then
        self:setMyGiftDisplayingData();
    end
    self:setDisplayingData();
end
        
 ---       
GiftManager.setMyGiftDisplayingData = function(self)
    if self.m_myGiftSelectedTag == "0" then
         g_EventDispatcher:dispatch(  g_SceneEvent.GIFT_SALE_BUTTON_STATUS_CHANGE_DARK);
        self:loadOwnGift();
    elseif self.m_myGiftSelectedTag =="1" then
        self:loadDueGift();
    end
end
        
GiftManager.setDisplayingData = function(self)
    local category  = self.m_selectedCategory;
    local tag       = self.m_selectedTag;
    local giftData  = self:getGiftData();	
    if category == "bychip" then
         g_EventDispatcher:dispatch(  g_SceneEvent.GIFT_SALE_BUTTON_STATUS_CHANGE_DARK);
        if giftData == nil then
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, {});
        elseif type(giftData) == "string" then 
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, giftData);
        elseif not giftData["bychip"][tag] or type(giftData["bychip"][tag]) == "table" and #giftData["bychip"][tag] == 0 then
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, GameString.get("str_gift_no_gift_info_hint"));
        else
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, giftData["bychip"][tag]);
        end
    elseif category == "bycoalaa" then
         g_EventDispatcher:dispatch(  g_SceneEvent.GIFT_SALE_BUTTON_STATUS_CHANGE_DARK);
        if giftData == nil then
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, {});
        elseif type(giftData) == "string" then 
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, giftData);
        elseif not giftData["bycoalaa"][tag] or type(giftData["bycoalaa"][tag]) == "table" and #giftData["bycoalaa"][tag] == 0 then
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, GameString.get("str_gift_no_gift_info_hint"));
        else
            g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, giftData["bycoalaa"][tag]);
        end
    elseif category == "mygift" then
        local myData = self:getMyGiftList()
        g_Model:setData(g_ModelCmd.GIFT_LIST_DISPLAYING, self:getMyGiftList() or {});
    end
end
            
GiftManager.getGiftData = function(self)
    return g_Model:getData(g_ModelCmd.GIFT_DATA);
end
        
GiftManager.getMyGiftList = function(self)
    return g_Model:getData(g_ModelCmd.GIFT_LIST_OWNED);
end
    
--[Comment]
--xml需要转换成lua，还没做    	
GiftManager.cacheGiftLua = function (self)
    if not self.m_buzy then
        if not g_Model:hasData(g_ModelCmd.GIFT_DATA) then
            self.m_buzy = true;
            self.m_tryTimes = 1;
            local url = g_AccountInfo:getGiftDownloadUrl()
            local fileName = "gift.lua"
            local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/")

            local forceDown = false
            if cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.GIFT_CONFIG_URL,"")~=url then
                forceDown = true
                cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.GIFT_CONFIG_URL,url)
            end
            self:downloadFile(url,self.cacheGiftLuaResult,filePath,fileName,nil,nil,forceDown)
        end
    end

end

GiftManager.cacheGiftLuaResult = function(self, data)
    
    Log.d("GiftManager:cacheGiftLuaResult ",data.isSuccess,data.fullFillePath)
    if not (data.isSuccess and data.fullFilePath)then
        self:defaultErrorHandler()
        return
    end
    pcall(function()
        if data.isSuccess and data.fullFilePath then
            local fun=loadfile(data.fullFilePath)
            if fun then
                local storeData = fun()
                if not g_TableLib.isEmpty(storeData) then
                    self:parseGiftData(storeData)
                end
            end 
        end
    end);
end

GiftManager.parseGiftData = function(self, config)
    --XML类别 1 精品 2 礼物 3 节日 4 其他 5娱乐
    --可供选择的类别 0 全部 1 精品 2 节日 3 娱乐 4 其他
    local tagMapping = {["1"] = "1", ["2"] = "4", ["3"] = "2", ["4"] = "4", ["5"] = "3", ["6"] = 4};--类型映射
    self.m_buzy = false;
    local bychip = {};
    local bycoalaa = {};
    local gift = {};
    local array = {};
    local bSet = false;
    if config and type(config) == "table" then
        for key, tmp in ipairs(config) do
            gift = GiftVO:create(tmp);
            g_ArrayUtils.push(array, gift);
            if tmp.i == nil or string.len(tmp.i) == 0 then
                GiftManager.m_giftIdFileMapping[gift.id] = gift.id;
            else
                GiftManager.m_giftIdFileMapping[gift.id] = tmp.i;
            end
            if gift["type"] == "1" and gift.price ~=0 then
                if not bychip[tagMapping[gift.tag]] then
                    if tagMapping[gift.tag] then
                        bychip[tagMapping[gift.tag]] = {gift};
                    end
                else
                    g_ArrayUtils.push(bychip[tagMapping[gift.tag]], gift);
                end
                if not bychip["0"] then
                    bychip["0"] = {gift};
                else
                    g_ArrayUtils.push(bychip["0"], gift);
                end
            elseif (gift["type"] == "2") and (gift.price ~= 0) then
                if not bycoalaa[tagMapping[gift.tag]] then
                    bycoalaa[tagMapping[gift.tag]] = {gift};
                else
                    g_ArrayUtils.push(bycoalaa[tagMapping[gift.tag]], gift);
                end
                if not bycoalaa["0"] then
                    bycoalaa["0"] = {gift};
                else
                    g_ArrayUtils.push(bycoalaa["0"], gift);
                end
            end
        end
        bSet = true;
    else
--        self:cacheGiftXml(); -- 测试。。。
        if(self.m_tryTimes > 0) then
            self.m_tryTimes = self.m_tryTimes - 1;
            local url = g_AccountInfo:getGiftDownloadUrl()
            local fileName = "gift.lua"
            local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/")
            local forceDown = false
            if cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.GIFT_CONFIG_URL,"")~=url then
                forceDown = true
                cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.GIFT_CONFIG_URL,url)
            end
            self:downloadFile(url,self.cacheGiftLuaResult,filePath,fileName,nil,nil,forceDown)
        else
            bSet = true;
        end
    end
    if(bSet) then
        g_Model:setData(g_ModelCmd.GIFT_ALL_DATA,array);
        g_Model:setData(g_ModelCmd.GIFT_DATA, {["bychip"] = bychip, ["bycoalaa"] = bycoalaa});
        self:setDisplayingData();
    end
end
        
GiftManager.loadDueGift = function (self)
    Log.d("GiftManager.loadDueGift")
    g_Model:clearData(g_ModelCmd.GIFT_LIST_OWNED);  
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_OWN)
    if not self.m_loadDueBuzy then
        self.m_loadDueBuzy = true;
        g_HttpManager:doPost(param, self, function(self,isSuccess,ret)
            self.m_loadDueBuzy = false;
            if self.m_myGiftSelectedTag == "1" then
                if ret ~= "0" then
                    local flag, jsonObj = isSuccess,ret
                    if flag and g_TableLib.isTable(jsonObj) then
                        local list = {};
                        if jsonObj and jsonObj.c then
                            for key, obj2 in ipairs(jsonObj.c) do
                                local giftVO = {};
                                giftVO.expire   = obj2.expire;
                                giftVO.name     = obj2.desc;
                                giftVO.id       = obj2.id;
                                giftVO["type"]  = obj2["type"];
                                giftVO.time     = obj2.time;
                                giftVO.isOwn    = true;
                                giftVO.giftType = "2";
                                g_ArrayUtils.push(list, giftVO);
                            end
                        end
                        if #list == 0 then
                            g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, GameString.get("str_gift_no_own_due_gift_hint"));
                             g_EventDispatcher:dispatch(  g_SceneEvent.GIFT_SALE_BUTTON_STATUS_CHANGE_DARK);
                        else
                            g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, list);
                             g_EventDispatcher:dispatch(  g_SceneEvent.GIFT_SALE_BUTTON_STATUS_CHANGE_LIGHT);
                        end
                        self:setDisplayingData();
                        return;
                    else
                        Log.e(self.TAG, "loadDueGift", "decode json has an error occurred!");
                    end
                end
            end
        end,nil,nil);
    end
end
        
GiftManager.loadOwnGift = function(self)
    Log.d("GiftManager.loadOwnGift")
    g_Model:clearData(g_ModelCmd.GIFT_LIST_OWNED);
    if not self.m_loadOwnBuzy then
        self.m_loadOwnBuzy = true;
        local param = HttpCmd:getMethod(HttpCmd.s_cmds.GIFT_GET_OWN)
        g_HttpManager:doPost(param, self, self.loadOwnGiftResultHandler);
    end
end

GiftManager.loadOwnGiftResultHandler = function(self,isSuccess,ret,param)
    if not isSuccess then
        self:loadOwnGiftErrorHandler()
    end
    self.m_loadOwnBuzy = false;
    -- Log.e("GiftManager.loadOwnGiftResultHandler", ret);
    if self.m_myGiftSelectedTag == "0" then
        if ret ~= "0" then
            local jsonObj = ret
            if isSuccess and g_TableLib.isTable(jsonObj) then
                local list = {};
                if jsonObj and jsonObj.a then
                    for key, obj in ipairs(jsonObj.a) do
                        if obj.expire > jsonObj.time then
                            local giftVO = {};
                            giftVO.expire   = obj.expire;
                            giftVO.name     = obj.desc;
                            giftVO.id       = obj.id;
                            giftVO["type"]  = obj["type"];
                            giftVO.time     = obj.time;
                            giftVO.isOwn    = true;
                            giftVO.giftType = "0";
                            g_ArrayUtils.push(list, giftVO);
                        end
                    end
                end
                if jsonObj and jsonObj.b then
                    for key, obj in ipairs(jsonObj.b) do
                        local giftVO = {};
                        giftVO.expire   = obj.expire;
                        giftVO.name     = obj.desc;
                        giftVO.id       = obj.id;
                        giftVO["type"]  = obj["type"];
                        giftVO.time     = obj.time;
                        giftVO.isOwn    = true;
                        giftVO.giftType = "1";
                        g_ArrayUtils.push(list, giftVO);
                    end
                end
                if jsonObj and jsonObj.c then
                    for key, obj in ipairs(jsonObj.c) do
                        local giftVO = {};
                        giftVO.expire   = obj.expire;
                        giftVO.name     = obj.desc;
                        giftVO.id       = obj.id;
                        giftVO["type"]  = obj["type"];
                        giftVO.time     = obj.time;
                        giftVO.isOwn    = true;
                        giftVO.giftType = "2";
                        g_ArrayUtils.push(list, giftVO);
                    end
                end
                if #list == 0 then
                    g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, GameString.get("str_gift_no_own_due_gift_hint"));
                else
                    g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, list);
                end
                self:setDisplayingData();
                return;
            else
                Log.e(self.TAG, "loadOwnGift", "decode json has an error occurred!");
            end 
        end
    end
end

GiftManager.defaultErrorHandler = function(self, arg1, arg2)
    self.m_buzy = false;
    g_Model:setData(g_ModelCmd.GIFT_DATA, GameString.get("str_common_php_request_error_msg"));
    self:setDisplayingData();
end
        
GiftManager.loadDueGiftErrorHandler = function(self, arg1, arg2)
    self.m_loadDueBuzy = false;
    g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, GameString.get("str_common_php_request_error_msg"));
    self:setDisplayingData();
end
        
GiftManager.loadOwnGiftErrorHandler = function(self, arg1, arg2)
    self.m_loadOwnBuzy = false;
    g_Model:setData(g_ModelCmd.GIFT_LIST_OWNED, GameString.get("str_common_php_request_error_msg"));
    self:setDisplayingData();
end


-----------------------test data -----------------------------------
--[Comment]
--本地测试用 win32没有下载
GiftManager.cacheGiftXml = function (self)
    --XML类别 1 精品 2 礼物 3 节日 4 其他 5娱乐
    --可供选择的类别 0 全部 1 精品 2 节日 3 娱乐 4 其他
    local tagMapping = {["1"] = "1", ["2"] = "4", ["3"] = "2", ["4"] = "4", ["5"] = "3"};--类型映射
    if not self.m_buzy then
        if not g_Model:hasData(g_ModelCmd.GIFT_DATA) then
                self.m_buzy = false;
                local bychip = {};
                local bycoalaa = {};
                local gift = {};
                local array = {};
                local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/gift")
                local GIFT_CONFIG = require1(filePath);
                for key, tmp in ipairs(GIFT_CONFIG) do
                    gift = new(GiftVO, tmp);
                    g_ArrayUtils.push(array, gift);
                    if tmp.i == nil or string.len(tmp.i) == 0 then
                        GiftManager.m_giftIdFileMapping[gift.id] = gift.id;
                    else
                        GiftManager.m_giftIdFileMapping[gift.id] = tmp.i;
                    end
                    if gift["type"] == "1" and gift.price ~=0 then
                        if not bychip[tagMapping[gift.tag]] then
                            if tagMapping[gift.tag] then
                                bychip[tagMapping[gift.tag]] = {gift};
                            end
                        else
                            g_ArrayUtils.push(bychip[tagMapping[gift.tag]], gift);
                        end
                        if not bychip["0"] then
                            bychip["0"] = {gift};
                        else
                            g_ArrayUtils.push(bychip["0"], gift);
                        end
                    elseif (gift["type"] == "2") and (gift.price ~= 0) then
                        if not bycoalaa[tagMapping[gift.tag]] then
                            bycoalaa[tagMapping[gift.tag]] = {gift};
                        else
                            g_ArrayUtils.push(bycoalaa[tagMapping[gift.tag]], gift);
                        end
                        if not bycoalaa["0"] then
                            bycoalaa["0"] = {gift};
                        else
                            g_ArrayUtils.push(bycoalaa["0"], gift);
                        end
                    end
                end
                g_Model:setData(g_ModelCmd.GIFT_ALL_DATA,array);
                g_Model:setData(g_ModelCmd.GIFT_DATA, {["bychip"] = bychip, ["bycoalaa"] = bycoalaa});
                self:setDisplayingData();
        end
    end
end

return GiftManager