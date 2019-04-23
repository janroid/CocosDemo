--[[--ldoc 枚举值
@module UpdateEnum
@author:LoyalwindPeng
 date: 2019-01-22 
]]

local UpdateEnum = {}

UpdateEnum.Type = {
    --- 更新类型
    Lua    = 0; -- lua更新
    App    = 1; -- 整包更新（Java更新）（a.国内安卓使用商店或者公司服务器下载;b.海外安卓，iOS平台使用商店更新）
}

--- 更新方式
UpdateEnum.Mode = {
    Silent   = 1; -- '静默'更新
    Optional = 2; -- '可选'更新
    Forced   = 3; -- '强制'更新
}

---错误信息（0~-3根据cocos引擎内部定的）
UpdateEnum.ErrorCode = { 
    None            = 0;   --没有错误,
    InvalidParams   = -1;  -- 参数问题，
    FileOpFailed    = -2;  -- 文件操作问题，
    IMPLInternal    = -3;  -- 内部实现错误，
    FileHashInvalid = -4;  -- 文件值不正确，
    FileUnzipFailed = -5;  -- 文件解压失败，
    DownloadNumberOut = -6;  -- 下载超过次数了，
}

--- 响应者必须要实现的函数
UpdateEnum.ResponderFunc = {
    onPreparedLuaOptional = "onPreparedLuaOptional";
    onPreparedLuaSilent   = "onPreparedLuaSilent";
    onPreparedLuaForced   = "onPreparedLuaForced";
    onPreparedAppForced   = "onPreparedAppForced";
    onPreparedAppOptional = "onPreparedAppOptional";
    onUpdateProgress      = "onUpdateProgress";
    onUpdateError         = "onUpdateError";
    onUpdateSuccess       = "onUpdateSuccess";
}

return  UpdateEnum