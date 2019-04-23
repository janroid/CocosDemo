local StoreConfig = class("StoreConfig")

StoreConfig.STORE_POP_UP_CHIPS_PAGE         = 1;
StoreConfig.STORE_POP_UP_BY_PAGE            = 2;
StoreConfig.STORE_POP_UP_PROPS_PAGE         = 3;
StoreConfig.STORE_POP_UP_VIP_PAGE           = 4;
StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE   = 5;
StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE   = 6;

StoreConfig.STR_STORE_PRODUCT_CATEGORY_ITEM				= { --商品類別子項
	[1] = GameString.get("str_store_chips");
	[2] = GameString.get("str_store_coin");
	[3] = GameString.get("str_store_prop");
	[4] = GameString.get("str_store_vip");
    [5] = GameString.get("str_store_my_prop");
	[6] = GameString.get("str_store_buy_history");
}

StoreConfig.STR_STORE_ACCOUNT_MANAGE_ITEM				= { --帳戶管理子項
	[1] =  GameString.get("str_store_my_prop");
	[2] =  GameString.get("str_store_buy_history");
}

return StoreConfig