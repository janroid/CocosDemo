local NodeUtils = import("framework.utils").NodeUtils
local BehaviorMap = import("app.common.behavior").BehaviorMap
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local StoreManager = require(".StoreManager")
local StoreConfig = require(".StoreConfig")
local StoreSelfPropsListItem  = class("StoreSelfPropsListItem",cc.Node)
BehaviorExtend(StoreSelfPropsListItem);
StoreSelfPropsListItem.ctor = function(self,data)   
    self:bindBehavior(BehaviorMap.DownloadBehavior);
    self:init()
    self.m_data = data
    self:updateView(data)
end

StoreSelfPropsListItem.init = function(self,data)
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/store/layout/layout_store_self_props_list_item.ccreator')
    self:addChild(self.m_root)

    self.m_btnItem          = NodeUtils:seekNodeByName(self.m_root,'btn_item')
    self.m_imgProduct       = NodeUtils:seekNodeByName(self.m_root,'img_product')
    self.m_txtProductName   = NodeUtils:seekNodeByName(self.m_root,'txt_product_name')
    self.m_txtHasProNum     = NodeUtils:seekNodeByName(self.m_root,'txt_has_pro_num')
    self.m_btnBuy           = NodeUtils:seekNodeByName(self.m_root,'btn_buy')
    self.m_txtBtnBuy        = NodeUtils:seekNodeByName(self.m_root,'txt_buy')

    self.m_btnBuy:loadTextures("creator/common/button/btn_yellow_short_normal.png","creator/common/button/btn_yellow_short_normal.png");
    self.m_btnBuy:addClickEventListener(function(sender)
		self:onBtnBuyClick()
    end)
end

StoreSelfPropsListItem.updateView = function(self,data)
    if data~=nil then
        if tonumber(data.a) == 1 then --//金卡
            if(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_VIP_PAGE)) then
                self.m_imgProduct:setTexture("creator/store/store_pro_small_1.png");				
                if  data.d ~=nil then
                    self.m_txtProductName:setString(GameString.get("str_store_prop_using")); 
                    self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
                else
                    self.m_txtProductName:setString(GameString.get("str_store_pop_up_copper_card")); 
                    self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
                end
            else
                self.m_imgProduct:setTexture("creator/store/store_pro_small_1.png");
                if  data.d ~=nil then
                    self.m_txtProductName:setString(GameString.get("str_store_prop_using")); 
                    self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
                else
                    self.m_txtProductName:setString(GameString.get("str_store_vip_card_name")); 
                    self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
                end
                
            end

            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 2 then --//互动道具卡
            self.m_imgProduct:setTexture("creator/store/store_pro_small_2.png");
            self.m_txtProductName:setString(GameString.get("str_store_hddj_prop_name")); 
            self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
                
            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 3 then --//经验卡
            self.m_imgProduct:setTexture("creator/store/store_pro_small_3.png");
            self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            --如果剩余张数大于0
            if data.b > 0 then
                --如果剩余时间大于0
                if(data.e > 0) then
                    self.m_txtProductName:setString(string.format(GameString.get("str_store_prop_remain1"),math.ceil(data.e / 3600),STR_ROOM_HOUR)); 
                else
                    self.m_txtProductName:setString(GameString.get("str_store_double_exp_prop_name"));
                end
                self.m_btnBuy:setVisible(true);
                self.m_btnBuy:loadTextures("creator/common/button/btn_blue_short_normal.png","creator/common/button/btn_blue_short_normal.png");
                self.m_txtBtnBuy:setString(GameString.get("str_store_use"));
            else
                --剩余时间大于0
                if(data.e > 0) then
                    self.m_txtProductName:setString(string.format(GameString.get("str_store_prop_remain"),math.ceil(data.e / 3600),STR_ROOM_HOUR));
                else
                    self.m_txtProductName:setString(GameString.get("str_store_double_exp_prop_name"));
                end
                self.m_btnBuy:setVisible(false);
            end
        elseif tonumber(data.a) == 30 then --//小喇叭
            self.m_imgProduct:setTexture("creator/store/store_pro_small_4.png");
            self.m_txtProductName:setString(GameString.get("str_store_small_laba_name"));
            self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 32 then --//大喇叭
            self.m_imgProduct:setTexture("creator/store/store_pro_small_5.png");
            self.m_txtProductName:setString(GameString.get("str_store_big_laba_name"));
            self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 6 then --//银卡
            self.m_imgProduct:setTexture("creator/store/store_pro_small_6.png");
            if(data.d~=nil) then
                self.m_txtProductName:setString(GameString.get("str_store_prop_using")); 
                self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            else
                self.m_txtProductName:setString(GameString.get("str_store_pop_up_silver_card")); 
                self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            end
            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 7 then --金卡
            self.m_imgProduct:setTexture("creator/store/store_pro_small_7.png");
            if(data.d~=nil) then
                self.m_txtProductName:setString(GameString.get("str_store_prop_using")); 
                self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            else
                self.m_txtProductName:setString(GameString.get("str_store_pop_up_gold_card")); 
                self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            end
            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 8 then -- //钻石卡
            self.m_imgProduct:setTexture("creator/store/store_pro_small_8.png");
            if(data.d~=nil) then
                self.m_txtProductName:setString(GameString.get("str_store_prop_using")); 
                self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            else
                self.m_txtProductName:setString(STR_STORE_STORE_POP_UP_GameString.get("str_store_pop_up_diamon_card")); 
                self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            end
            self.m_btnBuy:setVisible(true);
            self.m_txtBtnBuy:setString(GameString.get("str_store_buy_long"));
        elseif tonumber(data.a) == 77 then --//争霸赛邀请函
            self.m_imgProduct:setTexture("creator/store/store_pro_small_77.png");
            self.m_txtProductName:setString(GameString.get("str_store_user_prop_invite_card")); 
            self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            self.m_btnBuy:setVisible(true);
            self.m_btnBuy:loadTextures("creator/common/button/btn_blue_short_normal.png","creator/common/button/btn_blue_short_normal.png");
            self.m_txtBtnBuy:setString(GameString.get("str_store_use"));
        else
            self.m_txtHasProNum:setString(string.format(GameString.get("str_store_prop_remain"),data.b,data.c));
            self.m_txtProductName:setString(tostring(data.g) or "");  
            self.m_btnBuy:loadTextures("creator/common/button/btn_blue_short_normal.png","creator/common/button/btn_blue_short_normal.png");   
            self.m_txtBtnBuy:setString(GameString.get("str_store_use")); 
            local url = data.f;
            self:downloadImg(url,function(self,result)
                if not result.isSuccess then
                    self.m_imgProduct:setTexture("creator/store/gift-default.png")
                    self.m_imgProduct:setContentSize(cc.size(72,73.5))
                    return 
                end
                self.m_imgProduct:setTexture(result.fullFilePath)
                self.m_imgProduct:setContentSize(cc.size(96,60))
            end,"store/selfProps/",tostring(data.a) .. ".png",false)
        end
    end
end

StoreSelfPropsListItem.onBtnBuyClick = function (self)
    if self.m_txtBtnBuy:getString() == GameString.get("str_store_buy_long") then
        if(self.m_data~=nil and StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_VIP_PAGE) and (self.m_data.a == 1 or self.m_data.a == 6 or self.m_data.a == 7 or self.m_data.a == 8)) then
            g_EventDispatcher:dispatch(g_SceneEvent.STORE_EVENT_SHOW,StoreConfig.STORE_POP_UP_VIP_PAGE);
        else
            g_EventDispatcher:dispatch(g_SceneEvent.STORE_EVENT_SHOW,StoreConfig.STORE_POP_UP_PROPS_PAGE);
        end
    elseif self.m_txtBtnBuy:getString() == GameString.get("str_store_use") then
        if(self.m_data.a == 77) then
            g_EventDispatcher:dispatch(g_SceneEvent.SELF_PROPS_SHOW_PROPS_INFO,77);
        elseif(self.m_data.a == 100 or self.m_data.a == 86) then-- //NeroChen 添加道具
            --使用道具
            g_EventDispatcher:dispatch(g_SceneEvent.SELF_PROPS_USE_PROPS,self.m_data.a);
        elseif (tonumber(self.m_data.a) == 82 or tonumber(self.m_data.a) == 83 or tonumber(self.m_data.a) == 84 or tonumber(self.m_data.a) == 85) then  --打开MTT
            --从主页跳转到锦标赛MTT页面
                g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_STORE);  
            if cc.Director:getInstance():getRunningScene():getName() == "RoomScene" then
                g_Model:setData(g_ModelCmd.ROOM_ENTER_MTT_LOBBY,"666");
                return
            elseif cc.Director:getInstance():getRunningScene():getName() == "MttLobbyScene" then
                return
            end
            local mttLobbyScene = import('app.scenes.mttLobbyScene').scene
            cc.Director:getInstance():pushScene(mttLobbyScene:create());
        elseif(self.m_data.a == 3)  then
            --使用双倍经验卡
            g_EventDispatcher:dispatch(g_SceneEvent.SELF_PROPS_USE_PROPS,3);  
        end
    end
end

return StoreSelfPropsListItem