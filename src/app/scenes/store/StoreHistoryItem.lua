local StoreHistoryItem  = class("StoreHistoryItem",cc.Node)

function StoreHistoryItem:ctor(data)
    -- super:ctor()
    self:init()
    self:updateView(data)
end

function StoreHistoryItem:init()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/store/layout/layout_store_buy_history_item.ccreator')
    self:addChild(self.m_root)

    self.m_txtButProduct = g_NodeUtils:seekNodeByName(self.m_root,'txt_buy_product') 
    self.m_txtBuyTime = g_NodeUtils:seekNodeByName(self.m_root,'txt_buy_time') 
    self.m_txtBuyStatus = g_NodeUtils:seekNodeByName(self.m_root,'txt_buy_status') 
end

function StoreHistoryItem:updateView(data)
    -- data = {m_buyTime=1550577583,m_buyCoalaa=100,m_buyMoney=10,m_detail="123",m_status=2}

    local status = data.m_status or -1
    local buyTime = data.m_buyTime or -1

    if(data.m_buyCoalaa~=nil and data.m_buyCoalaa > 0) then
        self.m_txtButProduct:setString(g_StringLib.substitute(GameString.get("str_store_buy_xxx_by"),data.m_buyCoalaa));
    elseif(data.m_buyMoney~=nil and data.m_buyMoney>0) then
        self.m_txtButProduct:setString(g_StringLib.substitute(GameString.get("str_store_buy_xxx_chips"),g_MoneyUtil.formatMoney(data.m_buyMoney)));
    else
        self.m_txtButProduct:setString(data.m_detail and data.m_detail or "");
    end

    if status== 1 then
        self.m_txtBuyStatus:setString(GameString.get("str_store_buy_erro"))
    elseif status== 2 then
        self.m_txtBuyStatus:setString(GameString.get("str_store_buy_succ"))
    end
    local ret = "";
    local pattern = "%Y-%m-%d";
    if buyTime ~= nil then
        ret = os.date(pattern, buyTime/1000);
    end
    self.m_txtBuyTime:setString(ret)


end

return StoreHistoryItem
