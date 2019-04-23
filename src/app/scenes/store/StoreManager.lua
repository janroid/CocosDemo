local StoreManager = class("StoreManager")
local StoreConfig = require("StoreConfig")
local BehaviorMap = import("app.common.behavior").BehaviorMap
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
BehaviorExtend(StoreManager);

StoreManager.s_eventFuncMap = {
    [g_SceneEvent.STORE_REQUEST_BANKRUPT_DATA]         = "reportUserBankrupt",
}

function StoreManager:ctor()
    self.m_storeData ={}
    self.m_postCounts = 4
    self.m_intervalOpen = false
    self.m_timer = nil
    self.m_discountData = nil
    self.m_bankruptData = nil
    self:bindBehavior(BehaviorMap.DownloadBehavior);
    self:registerEvent()
end

function StoreManager.getInstance()
    if not StoreManager.s_instance then
        StoreManager.s_instance = StoreManager:create()
    end

    return StoreManager.s_instance
end

function StoreManager.delete()
    if StoreManager.s_instance then
        delete(StoreManager.s_instance)
        StoreManager.s_instance = nil
    end
end

---注册监听事件
function StoreManager:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        g_EventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function StoreManager:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

function StoreManager.releaseInstance()
    self:unRegisterEvent()
    if StoreManager.s_instance then
        delete(StoreManager.s_instance)
        StoreManager.s_instance = nil
    end
end

function StoreManager:requestData()
    self:requestStoreData()
    self:requestBankruptData()
    self:requestMyStoreData()
end

function StoreManager:requestMyStoreData()
    self:requestHistoryData()
    self:requestUserProps()
end

---
---獲取商城數據
-- @param
-- @return 
function StoreManager:requestStoreData()
    local payConfigUrlAndroid = g_AccountInfo:getPayConfigAndroid()
    self:downloadStoreData(payConfigUrlAndroid)
end

--  下載商城數據
function StoreManager:downloadStoreData(url,params)
    local forceDown = false
    if cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.STORE_CONFIG_URL,"")~=url then
        forceDown = true
        cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.STORE_CONFIG_URL,url)
    end

    local fileName = "StoreConfig.lua"
    local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/")
    self:downloadFile(url,self.downLoadStoreSuccess,filePath,fileName,nil,nil,forceDown)
end


function StoreManager:downLoadStoreSuccess(data)
    Log.d("StoreManager:downLoadStoreSuccess ",data.isSuccess,data.fullFilePath)
    pcall(function()
        if data.isSuccess and data.fullFilePath then
            local fun=loadfile(data.fullFilePath)
            if fun then
                local storeData = fun()
                -- Log.d("Johnson ",storeData)
                if not g_TableLib.isEmpty(storeData) then
                    self:parseData(storeData)
                end
            end 
        end
    end);
end
    
function StoreManager:parseData(config)
    if g_TableLib.isEmpty(config) then
        return;
    end
    local propList = {};
    local chipList = {};
    local coalaaList = {};
    local vipList = {};

    for _,tmp in ipairs(config.props) do
        if tonumber(tmp.id) > 0 then
            local props ={};
            props = self:parseItemData(tmp)
            g_ArrayUtils.push(propList,props);
        else
            Log.i("ignore product => ".. tmp.id);
        end   
    end

    for _,tmp in ipairs(config.chips) do
        if tonumber(tmp.id) > 0 then
            local chips = {};
            chips = self:parseItemData(tmp)
            g_ArrayUtils.push(chipList,chips);
        else
            Log.i("ignore product => ".. tmp.id);
        end   
    end

    for _,tmp in ipairs(config.coalaas) do
        if tonumber(tmp.id) > 0 then
            local coalaa = {};
            coalaa = self:parseItemData(tmp)
            g_ArrayUtils.push(coalaaList,coalaa);
        else
            Log.i("ignore product => ".. tmp.id);
        end   
    end

    for _,tmp in ipairs(config.cards) do
        if tonumber(tmp.id) > 0 then
            local vip = {};
            vip = self:parseItemData(tmp)
            g_ArrayUtils.push(vipList,vip);
        else
            Log.i("ignore product => ".. tmp.id);
        end   
    end

    local postComplete =  function()
        Log.d("StoreManager postComplete")
        self.m_loading = false;
        self:setPageData(StoreConfig.STORE_POP_UP_CHIPS_PAGE, self.m_chipsData)
        self:setPageData(StoreConfig.STORE_POP_UP_BY_PAGE, self.m_coinData)
        self:setPageData(StoreConfig.STORE_POP_UP_PROPS_PAGE,self.m_propsData)
        self:setPageData(StoreConfig.STORE_POP_UP_VIP_PAGE,self.m_vipData)

        self.m_isProductLoaded = true;
    end
    self.m_storeData ={}
    self.m_chipsData = chipList
    self.m_coinData = coalaaList
    self.m_propsData = propList
    self.m_vipData = vipList
    if device.platform == "android" or device.platform == "ios" then
        self:postProductConfigLoaded(self.m_chipsData, self.m_coinData, self.m_propsData, self.m_vipData, postComplete);
    else
        postComplete()
    end
    
end

function StoreManager:postProductConfigLoaded(chips, coalaa, props, vips, completeCallback)
    Log.d("StoreManager:postProductConfigLoaded",completeCallback)
    self.m_pidArray = {};
    self.m_pidProductMapping = {};
    self.m_pidProductMappingIndex = {};
            
    self:addProductIds(chips, self.m_pidArray);
    self:addProductIds(coalaa,self.m_pidArray);
    self:addProductIds(props, self.m_pidArray);
    self:addProductIds(vips,  self.m_pidArray);
  		
    self.m_completeCallback = completeCallback;
            
    if #self.m_pidArray > 0  then
        Log.d("StoreManager:postProductConfigLoaded  NativeEvent.getInstance():callNative")
        local params = {}
        params.pids = self.m_pidArray
        if device.platform == "ios" then
            NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_QUERY_APPLE_PRODUCT, params, self, self.queryAppleProductResponse)
        else
            params.playStorePublicKey = g_AppManager:getPlayStorePublicKey()
            NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_QUERY_GOOGLE_PRODUCT, params, self, self.queryProductResponse)
        end
    end
end

function StoreManager:queryProductResponse(data)
    Log.d("StoreManager:queryProductResponse",data)
    local result = data.result
    if tonumber(result) == 1 then   -- 成功
        if self.m_completeCallback ~= nil then
            if self.m_pidArray~=nil and #self.m_pidArray > 0 then
                for _,pid in ipairs(self.m_pidArray) do
                    local param = {pid = pid}
                    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_QUERY_GOOGLE_PRODUCT_DETAIL,param,self,self.queryProductDetailResponse)
                end
            end
            self.m_completeCallback();
            self.m_completeCallback = nil;
        end
    else
        if self.m_completeCallback ~= nil then
            if self.m_pidArray~=nil and #self.m_pidArray > 0 then
                for _,pid in ipairs(self.m_pidArray) do
                    self.m_pidProductMapping[pid].m_priceFormatter = function(price)
                        return GameString.get("str_price_unit").." "..price;
                    end;
                end
            end
            self.m_completeCallback();
            self.m_completeCallback = nil;
        end
    end
end

function StoreManager:queryProductDetailResponse(data)
    -- Log.d("StoreManager:queryProductDetailResponse",data)
    if tonumber(data.result) == 1 then
        self.m_detail = {};
        self.m_detail["_sku"] = data._sku
        self.m_detail["_type"] = data._type
        self.m_detail["_price"] = data._price
        self.m_detail["_title"] = data._title
        self.m_detail["_descr"] = data._descr
                    
        self.m_pidProductMapping[self.m_detail._sku].m_price = self.m_detail._price;
        self.m_pidProductMapping[self.m_detail._sku].m_priceFormatter = nil;
    end
end

--- itunes 后台商品数据的回调
function StoreManager:queryAppleProductResponse(data)
    Log.d("queryAppleProductResponse", data)
    -- 如果回调为空，不必继续下去了
    if self.m_completeCallback == nil then return end

    if self.m_pidArray ~= nil and #self.m_pidArray > 0 then
        if tonumber(data.result) == 1 then -- 成功
            --[[ iOS中data是这样的
            {
                result = 0 or 1
                products = {
                    pid1 = {},
                    pid2 = {},
                }
            }
            ]]
            local products = data.products
            for _, pid in ipairs(self.m_pidArray) do
                local detail = products[tostring(pid)]
                if self.m_pidProductMapping[pid] ~= nil then
                    self.m_pidProductMapping[pid].m_price = detail._price
                    self.m_pidProductMapping[pid].m_priceFormatter = nil
                end
            end

        else -- 失败
            for _, pid in ipairs(self.m_pidArray) do
                self.m_pidProductMapping[pid].m_priceFormatter = function(price)
                    return GameString.get('str_price_unit') .. ' ' .. price
                end
            end
        end
    end

    self.m_completeCallback()
    self.m_completeCallback = nil
end


function StoreManager:addProductIds(productArr,idArr)
    local pid;
    local prd = {};
    if productArr~=nil and idArr~=nil and #productArr > 0 then
        for i=1,#productArr do
            prd = productArr[i];
            if prd~=nil then
                pid = prd.m_pid;
            else
                pid = nil;
            end
            if pid~=nil and g_TableLib.indexof(idArr,pid) == false then
                g_ArrayUtils.push(idArr,pid);
                self.m_pidProductMapping[pid] = prd;
                self.m_pidProductMappingIndex[pid] = prd.m_price;
                prd.m_priceFormatter= function(price)
                    return self:androidPriceFormatter(price)
                end
            end
        end
    end   
end

function StoreManager:androidPriceFormatter(price)
    return GameString.get("str_price_unit").." ".. price;
end

function StoreManager:parseItemData(tmp)
    local item = {}
    item.m_id            = tmp.id;
    item.m_pid           = tmp.pid;
    item.m_displayName   = string.len(tmp.dname or "") == 0 and tmp.name or tmp.dname;
    item.m_name          = tmp.name;
    item.m_num           = tmp.num;
    item.m_desc          = tmp.desc;
    item.m_hasOff        = (tmp.st == 1);
    item.m_price         = tmp.price;
    item.m_img           = tmp.img or "";
    --支付中心订单id nerochen 20150506
    item.m_orderid      = tmp.oid or 0;
    item.m_priceFormatter = function(price)
        return GameString.get("str_price_unit").." "..price;
    end
    return item
end

-- 請求用戶購買記錄
function StoreManager:requestHistoryData()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.USER_GETPAY)
    param.channel = g_AccountInfo:getChannel()
    g_HttpManager:doPost(param, self,self.handlerLoadUserBuyHistory ,nil,nil);
end

function StoreManager:handlerLoadUserBuyHistory(isSuccess,data)
    -- data = {{appOrderId="3152143417",money="2",buyTime="1550630658",settleTime="1550630658",refundTime=0,status=2,buyMoney="180000",buyCoalaa="0"}}
    local historyData = {}
    Log.d("StoreManager:handlerLoadUserBuyHistory",isSuccess,data)
	if isSuccess and not g_TableLib.isEmpty(data) then
        if #data > 0 then
            for _,obj in pairs(data) do
                local historyItem ={};
                historyItem.m_appOrderId   = obj["appOrderId"]            or "";
                historyItem.m_buyMoney     = tonumber(obj["buyMoney"])    or 0;
                historyItem.m_buyCoalaa    = tonumber(obj["buyCoalaa"])   or 0;
                historyItem.m_money        = tonumber(obj["money"])       or 0;
                historyItem.m_buyTime      = (tonumber(obj["buyTime"])    or 0)   * 1000;
                historyItem.m_settleTime   = (tonumber(obj["settleTime"]) or 0)   * 1000;
                historyItem.m_refundTime   = (tonumber(obj["refundTime"]) or 0)   * 1000;
                historyItem.m_status       = obj["status"];
                historyItem.m_detail       = obj["detail"];
                g_ArrayUtils.push(historyData,historyItem);
            end
        end
    end
    self.m_historyData = historyData
    self:setPageData(StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE,self.m_historyData)
end


-- 下載所有道具數據
function StoreManager:downLoadAllPropsData(data)
    local url = g_AccountInfo:getUserPropUrl()
    local fileName = "Props.lua"
    local forceDown = false
    if cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.PROPS_CONFIG_URL,"")~=url then
        forceDown = true
        cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.PROPS_CONFIG_URL,url)
    end
    self:downloadFile(url,self.loadALLPropsSuccess,nil,fileName,nil,nil,forceDown)
end

function StoreManager:loadALLPropsSuccess(data)
    pcall(function()
        if data.isSuccess and data.fullFilePath then
            local fun=loadfile(data.fullFilePath)
            if fun then
                local allPropsData = fun()
                -- Log.d("Johnson ",allPropsData)
                if not g_TableLib.isEmpty(allPropsData) then
                    -- self.m_myPropData = userPropsData
                    -- -- self:parseUserPropsData(userPropsData)
                    -- self.m_storeData[StoreManager.GOODS_INDEX.OWNPROPS] = self.m_myPropData
                    -- self:onRequestStoreDataResponse(true,storeData)
                end
            end 
        end
    end);
end


-- 請求用戶道具信息
function StoreManager:requestUserProps()
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.USER_GETUSERPROPS)
    g_HttpManager:doPost(postData, self, self.onRequestUserPropsSuc);
end


function StoreManager:onRequestUserPropsSuc(isSuccess,response)
    if isSuccess then
        self.m_myPropData = response
        self:setPageData(StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE,self.m_myPropData)
    end
end

-- 獲取破產數據
function StoreManager:requestBankruptData()
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.BREAK_GETINFO)
    g_HttpManager:doPost(postData, self,self.userCrashCallback);
end

function StoreManager:userCrashCallback(isSuccess,data)
    if isSuccess and not g_TableLib.isEmpty(data) then
        Log.d("StoreManager:userCrashCallback data = ",data)
        local result = tonumber(data.ret)
        if result then
            if(result < 0) then--返回错误
                self.m_postCounts = self.m_postCounts - 1;
                if(self.m_postCounts <= 0) then
                    return;
                end
                self:setDiscountData(nil)
                self:requestBankruptData()
            elseif(result == 1) then--有优惠
                self:setBankruptData(data) 
                -- 刷新商城界面
                local chipsData = self:getPageData(StoreConfig.STORE_POP_UP_CHIPS_PAGE)
                self:setPageData(StoreConfig.STORE_POP_UP_CHIPS_PAGE,chipsData,true)
                -- 計時器
                if self.m_intervalOpen == false then
                   if tonumber(data.info.expire) > 0 then 
                        self:showBankrupcyPop(data)
                        self.m_timer = g_Schedule:schedule(function() 
                            data.info.expire =  tonumber(data.info.expire) - 1;
                            self.m_intervalOpen = true;
                            self:setBankruptData(data)
                            if(tonumber(data.info.expire) <= 0) then
                                self:setPageData(StoreConfig.STORE_POP_UP_CHIPS_PAGE,chipsData,true)
                                if self.m_timer then
                                    g_Schedule:cancel(self.m_timer.eventObj);
                                    self.m_timer = nil
                                end
                            end	
                        end, 1) 
                    end  
                end
                self:setDiscountData(data.info)
            elseif(result == 0) then
                self:setBankruptData(data)
                self:setDiscountData(nil)
                -- self:showBankrupcyPop(data)
                if self.m_timer then
                    g_Schedule:cancel(self.m_timer.eventObj);
                    self.m_timer = nil
                end
            end
        end
    end
end


-- 獲取破產數據
function StoreManager:reportUserBankrupt()
    local postData = HttpCmd:getMethod(HttpCmd.s_cmds.BREAK_REPORT)
    g_HttpManager:doPost(postData, self,self.userCrashReportCallback);
end

StoreManager.m_phpPostCounts = 5;
StoreManager.userCrashReportCallback = function(self, data)
    if data ~= nil then
        if(not g_TableLib.isEmpty(data) and (data.ret == nil or (data.ret and data.ret < 0))) then--上报失败，多上报几次
            if(self.m_phpPostCounts > 0) then
                self.m_phpPostCounts = self.m_phpPostCounts - 1;
                self:reportUserBankrupt()
            else
                self.m_phpPostCounts = 5;
                return;
            end
        end
    end
end

function StoreManager:showBankrupcyPop(data)
    
    local expire = 0
    local discount = 0
    -- local times = 0
    if not g_TableLib.isEmpty(data) then
        local info  =  data.info 
        expire = info.expire   -- 剩餘時間
        discount = info.discount   -- 剩餘時間
        -- times = info.times
    end
    local param = {
        countDown = expire + os.time(),
        percent = discount,
        -- subsidizeChips = 3000,
        -- times = times
    }
    g_EventDispatcher:dispatch(g_SceneEvent.STORE_DISCOUNT_UPDATE1,param)

end

-- 設置折扣信息
function StoreManager:setDiscountData(data)
    self.m_discountData = data
    g_EventDispatcher:dispatch(g_SceneEvent.STORE_DISCOUNT_UPDATE)
end

function  StoreManager:getDiscountData()
    return self.m_discountData
end

-- 設破產數據
function StoreManager:setBankruptData(data)
    self.m_bankruptData  =data 
end

function StoreManager:getBankruptData()
    return self.m_bankruptData  
end

-- 是否支持支付中心
function StoreManager:isSupportPaymentCenter()
    local isSupportPaymentCenter = g_AccountInfo:getIsSupportPaymentCenter()
    if tonumber(isSupportPaymentCenter) == 1 then
        return true
    end
    return false
end

-- 请求下单
function StoreManager:requestCreateOrder(data)
    Log.d("Johnson StoreManager:requestCreateOrder",data)
    if self.m_busyBuying then
        self:showTips(GameString.get("str_store_pay_busy"))
        return
    end
    if self:isSupportPaymentCenter() then
        g_AlarmTips.getInstance():setText(GameString.get("str_store_create_order")):show()
        self.m_busyBuying = true
        local param = HttpCmd:getMethod(HttpCmd.s_cmds.PAY_CREATE_ORDER)
        param.oid = data.m_orderid
        param.payMoney = data.m_price
        g_HttpManager:doPost(param,self,self.onCreateOrderResponse,nil,nil)
    end
end

-- 下单回调
function StoreManager:onCreateOrderResponse(isSuccess, data, param)  
    Log.d("Johnson StoreManager:onCreateOrderResponse " ,isSuccess, data, param)
    if data == "" then
        self:onCreateOrderError()
        return;
    end

    if isSuccess and not g_TableLib.isEmpty(data) then 
        if data.ret ~= nil and data.ret == "0" then
            local orderid = data.orderid
            --支付loger上报
            local tjParam = HttpCmd:getMethod(HttpCmd.s_cmds.TJ_PAY_REPORT)
            tjParam.id = param.oid
            g_HttpManager:doPost(tjParam);
            self:callNativePay(data,param)
            -- self.m_busyBuying = false;
        else
            self.m_busyBuying = false;
            self:showTips(GameString.get("str_store_create_order_fail"));
        end
    else
        self:onCreateOrderError()
    end	
end

function StoreManager:onCreateOrderError()
    self.m_busyBuying = false;
    --提示支付中心下单失败
    self:showTips(GameString.get("str_store_create_order_fail"));
end

--调用原生进行支付
function StoreManager:callNativePay( ret, param )
    --key, data, obj, func
    local params = {}
    params ={
        order=ret.orderid,
        productID =param.oid,
        payMoney = param.payMoney,
        currencyCode = "USD",
    }
    -- NativeCmd.KEY.KEY_PAY
    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_PAY,params,self,self.onNativePayResponse)
end

-- 原生支付回调处理
function StoreManager:onNativePayResponse(data)
    self.m_busyBuying = false;
    Log.d("pay.PayManager StoreManager:onNativePayResponse ",data)
    if device.platform == "android" then
        self:onNativeAndroidPayResponse(data)
    elseif device.platform == "ios" then
        self:onNativeIosPayResponse(data)
    end
end

function StoreManager:onNativeAndroidPayResponse(data)
    local result = tonumber(data.result)
    if result == 1 then
        g_AlarmTips.getInstance():setText(GameString.get("str_store_pay_success")):show()
    elseif result == 9 then -- 发货失败
            g_AlarmTips.getInstance():setText(GameString.get("str_store_pay_delivery_fail")):show()
        --刷新数据，请求更新金币以及筹码
    elseif result == 2 then -- 取消支付
        g_AlarmTips.getInstance():setText(GameString.get("str_store_pay_cancel")):show()
    elseif result == 7 then -- 已拥有该商品，正在发货，发货未成功
        g_AlarmTips.getInstance():setText(GameString.get("str_store_pay_request_delivery")):show()
    elseif result == 3 then    -- Billing API 版本不受所请求类型的支持
        g_AlarmTips.getInstance():setText(GameString.get("str_store_pay_unsupport")):show()
    -- elseif result == 5 then   --向 API 提供的参数无效
    else  --購買失敗
        g_AlarmTips.getInstance():setText(GameString.get("str_store_pay_fail")):show()
    end
    self:requestHistoryData()
end

-- 返回指定index界面的所有数据
function StoreManager:getPageData(index)
    -- Log.d("StoreManager.getLayerData data = ",index,  self.m_storeData[index]) 
    return self.m_storeData[index] or {}
end

-- 设置指定index界面的所有数据，并且更新界面
function StoreManager:setPageData(index,data,needRefresh)
    if  not g_TableLib.isTable(data) then
        data = {}
    end
    self.m_storeData[index] = data
    g_EventDispatcher:dispatch(g_SceneEvent.STORE_EVENT_REFRESH_DATA,{index = index,needRefresh = needRefresh});
end

function StoreManager:onNativeIosPayResponse(data)
    self:onNativeAndroidPayResponse(data)
end



--
function StoreManager:getItemDiscount(value)
    local itemDiscount = g_AccountInfo:getItemDiscount()
    if(itemDiscount and not g_TableLib.isEmpty(itemDiscount) )then
        if(value) then
            if( value.id and itemDiscount["item" .. value.id] ~= nil) then
                return itemDiscount["item"..value.id];
            elseif((value=="chip") and itemDiscount["chipDiscount"] ~= nil) then
                return itemDiscount["chipDiscount"];
            elseif((value=="coin") and itemDiscount["coalaaDiscount"] ~= nil) then
                return itemDiscount["coalaaDiscount"];
            else
                return 0;
            end
        else
            return itemDiscount["discount"];
        end
    else
        return 0;
    end
end

function StoreManager:onUseProps(propsId)
    -- self.m_rTime = Clock.now()
    --使用道具
    -- g_AlarmTips.getInstance():setText("send"):show()
    local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_USEPROPS)
    params.id = propsId
    g_HttpManager:doPost(params,self,self.onUsePropsCallBack)
end

function StoreManager:onUsePropsCallBack(isSuccess,data)
    --更新selfprops数据
    if isSuccess then
        Log.d("StoreSelfPropsPage:onUsePropsCallBack data = ",data)
        StoreManager.getInstance():requestUserProps()
        -- StoreManager.getInstance():setPageData(StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE,data)
    end
    
end

function StoreManager:clearData()
    self.m_storeData[StoreConfig.STORE_POP_UP_CHIPS_PAGE] = nil
    self.m_storeData[StoreConfig.STORE_POP_UP_BY_PAGE] = nil
    self.m_storeData[StoreConfig.STORE_POP_UP_PROPS_PAGE] = nil
    self.m_storeData[StoreConfig.STORE_POP_UP_VIP_PAGE] = nil
    self.m_storeData[StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE] = nil
    self.m_storeData[StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE] = nil
    self.m_storeData ={}
end

function StoreManager:showTips(str)
    g_AlarmTips.getInstance():setText(str):show()
end

return StoreManager
