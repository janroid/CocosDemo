assert(CurlUtils,"must exist")
-- 支持的包装方法（这里仅能正常支持传递long，函数回调和对象等需要原生层提前预支持）
local SUPPORTPAUSEFIELDNAME = {
    CURLPAUSE_RECV = 1;
    CURLPAUSE_RECV_CONT = 0;
    CURLPAUSE_SEND = 4;
    CURLPAUSE_SEND_CONT = 0;
    CURLPAUSE_ALL = 5;
    CURLPAUSE_CONT = 0;
}

local SUPPORTOPTFIELDNAME = {
    --支持行为,默认为创建任务
    CUSTOM_CALL_TYPE_CREATE = -1000;                --创建CURL任务(默认行为)
    CUSTOM_CALL_TYPE_PAUSE_AND_RESUME = -1001;      --暂停/恢复CURL任务
    CUSTOM_CALL_TYPE_PAUSE_AND_RESUME_BIT = -1002;  --暂停恢复参数

    CUSTOM_CALL_TYPE_CANCEL = -1003;                --取消CURL任务
    CUSTOM_CALL_TYPE_OPEN_FORM = -1004;             --上传的文件key, CURLFORM_COPYNAME
                                                    --也意味着打开表单上传功能,


    CUSTOM_CALL_TYPE_FORM_NUM = -1005;  --表示接下来的自定义个数


    -- -1006 ~ -1025为表单使用字段 (20个保留字段) CURLFORM_COPYNAME / CURLFORM_COPYCONTENTS
    CUSTOM_CALL_TYPE_FORM_NAME_1 = -1006;
    CUSTOM_CALL_TYPE_FORM_NAME_2 = -1007;
    CUSTOM_CALL_TYPE_FORM_NAME_3 = -1008;
    CUSTOM_CALL_TYPE_FORM_NAME_4 = -1009;
    CUSTOM_CALL_TYPE_FORM_NAME_5 = -1010;
    CUSTOM_CALL_TYPE_FORM_NAME_6 = -1011;
    CUSTOM_CALL_TYPE_FORM_NAME_7 = -1012;
    CUSTOM_CALL_TYPE_FORM_NAME_8 = -1013;
    CUSTOM_CALL_TYPE_FORM_NAME_9 = -1014;
    CUSTOM_CALL_TYPE_FORM_NAME_10 = -1015;

    CUSTOM_CALL_TYPE_FORM_CONTENTS_1 = -1016;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_2 = -1017;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_3 = -1018;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_4 = -1019;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_5 = -1020;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_6 = -1021;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_7 = -1022;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_8 = -1023;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_9 = -1024;
    CUSTOM_CALL_TYPE_FORM_CONTENTS_10 = -1025;

    -- -1026 ~ -1036 为头部使用字段（10个保留字段）

    CUSTOM_CALL_TYPE_HEADER_VALUE_1 = -1026; --第一个用于标记个数一共使用了多少个头部

    CUSTOM_CALL_TYPE_HEADER_VALUE_2 = -1027;
    CUSTOM_CALL_TYPE_HEADER_VALUE_3 = -1028;
    CUSTOM_CALL_TYPE_HEADER_VALUE_4 = -1029;
    CUSTOM_CALL_TYPE_HEADER_VALUE_5 = -1030;
    CUSTOM_CALL_TYPE_HEADER_VALUE_6 = -1031;
    CUSTOM_CALL_TYPE_HEADER_VALUE_7 = -1032;
    CUSTOM_CALL_TYPE_HEADER_VALUE_8 = -1033;
    CUSTOM_CALL_TYPE_HEADER_VALUE_9 = -1034;
    CUSTOM_CALL_TYPE_HEADER_VALUE_10 = -1035;
    CUSTOM_CALL_TYPE_HEADER_VALUE_11 = -1036;



    --自定义字段，不要和CURL OPT 字段重复，否则不能正常传递到C
    CUSTOM_CALL_BACK_ID = -10000;       --回调ID，读、写、进度、终止（上传或者下载都需要该字段支持）

    --文件一组,造作文件
    CUSTOM_MODIFY_PATH = -10001;        --操作文件地址，上传文件地址、下载文件地址(下载默认输出)
    CUSTOM_MODIFY_FILE_MODE = -10002;   --文件打开模式，参考fopen函数，默认wb   wb 只写打开或新建一个二进制文件；只允许写数据。
                                        -- r/r+/rb+/rw+/w/w+/a/a+/wb/wb+/ab+
    CUSTOM_MODIFY_FILE_SEEK_OFFSET = -10003;   
    CUSTOM_MODIFY_FILE_SEEK_WHERE = -10004; 
                                        --偏移起始位置：文件头0(SEEK_SET)，当前位置1(SEEK_CUR)，文件尾2(SEEK_END)）
                                        --为基准，偏移offset（指针偏移量）个字节的位置。如果执行失败(比如offset超过文件自身大小)，
                                        --则不改变stream指向的位置。

    CURLOPT_URL = 10002;                --URL地址 (该字段必须存在)

    CURLOPT_READDATA = 10009;           --上传读取对象，目前仅支持默认操作文件，
    CURLOPT_WRITEDATA = 10001;          --写入对象，目前仅支持CUSTOM_MODIFY_PATH传入的文件对象
    CURLOPT_HTTPHEADER = 10023;         --自定义头部
    CURLOPT_WRITEFUNCTION = 20011;      --下载写入函数，目前仅支持默认操下载函数，
    CURLOPT_READFUNCTION = 20012;       --上传读取函数，目前仅支持默认操上传函数，

    CURLOPT_VERBOSE = 41;               --会输出通信过程中的一些细节。如果使用的是http协 议，请求头/响应头也会被输出。
    CURLOPT_HEADER = 42;                --头信息将出现在消息的内容中
    CURLOPT_NOPROGRESS = 43;            --是否"不显示进度"，打开的话会有默认函数
    CURLOPT_PROGRESSFUNCTION = 20056;   --进度回调，目前仅支持默认进度回调函数，
    CURLOPT_XFERINFOFUNCTION = 20219;   --同上，better

    CURLOPT_PROGRESSDATA = 10057;       --进度回调数据,默认使用传入ID
    CURLOPT_HTTPPOST = 10024;           --自定义行为,为开启表单功能，CURL中为指定多部分表单发布内容
    CURLOPT_POSTFIELDS = 10015;          --设置post内容，注意该模式sends a "normal"
                                        -- POST with a content-type of x-url-form-encoded but with no encoding done by 


    CURLOPT_NOSIGNAL = 99;              --关闭信号
    CURLOPT_FOLLOWLOCATION = 53;        --重定向

    CURLOPT_TIMEOUT = 13;               --超时 单位为秒 默认0表示不超时
    CURLOPT_TIMEOUT_MS = 155;           --超时 单位为毫秒 默认0表示不超时

    CURLOPT_RANGE = 10007;              --请求大小，默认不穿为NULL 支持格式“X-Y”
                                        -- "0-199"  first 200 bytes 
                                        -- "200-"   starting from index 200
                                        -- "0-199,1000-199" 200 bytes from index 0 and 200 bytes from index 1000:

    
    CURLOPT_SSL_VERIFYPEER = 64;        --证书不对可以设置为false

    CURLOPT_TCP_KEEPALIVE = 213;        --enable TCP keep-alive for this transfer
    CURLOPT_TCP_KEEPIDLE = 214;         -- keep-alive idle time to set seconds
    CURLOPT_TCP_KEEPINTVL = 215;        --interval time between keep-alive probes:  seconds
}


local writablePath = device.writablePath
local directorySeparator = device.directorySeparator
local callBackIDs = {}
local callbackInfos = {}

local randomID = math.random( 1,10000)
local function getCallbackID()
    randomID = randomID + 1
    return randomID
end

local function downImage(url,savePath)
    local callbackID = getCallbackID()
    local opt = {
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_BACK_ID] = callbackID;
        [SUPPORTOPTFIELDNAME.CURLOPT_URL] = url;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_PATH] = savePath;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_FILE_MODE] = "wb";

        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEDATA] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEFUNCTION] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOPROGRESS] = 0;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSFUNCTION] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSDATA] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOSIGNAL] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_FOLLOWLOCATION] = 1;

        -- [SUPPORTOPTFIELDNAME.CURLOPT_TIMEOUT_MS] = 200; --超时
        [SUPPORTOPTFIELDNAME.CURLOPT_SSL_VERIFYPEER] = 0;

    }
    CurlUtils(opt)
    return callbackID
end

--大文件需要HTTP ALive设置
local function downBigFile(url,savePath,func)
    local callbackID = getCallbackID()
    callBackIDs[callbackID] = func
    local opt = {
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_BACK_ID] = callbackID;
        [SUPPORTOPTFIELDNAME.CURLOPT_URL] = url;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_PATH] = savePath;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_FILE_MODE] = "wb";

        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEDATA] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEFUNCTION] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOPROGRESS] = 0;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSFUNCTION] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSDATA] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOSIGNAL] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_FOLLOWLOCATION] = 1;

        -- [SUPPORTOPTFIELDNAME.CURLOPT_TIMEOUT_MS] = 200; --超时
        [SUPPORTOPTFIELDNAME.CURLOPT_SSL_VERIFYPEER] = 0;

        [SUPPORTOPTFIELDNAME.CURLOPT_TCP_KEEPALIVE] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_TCP_KEEPIDLE] = 120;
        [SUPPORTOPTFIELDNAME.CURLOPT_TCP_KEEPINTVL] = 60;

    }
    CurlUtils(opt)
    return callbackID
end

-- CUSTOM_CALL_TYPE_PAUSE_AND_RESUME = -1001;      --暂停/恢复CURL任务
-- CUSTOM_CALL_TYPE_PAUSE_AND_RESUME_BIT = -1002;  --暂停恢复参数
local function pause_resume_downloadImage(callbackID,isPause)
    -- CURLPAUSE_ALL = 5;
    -- CURLPAUSE_CONT = 0;
    local bit = SUPPORTPAUSEFIELDNAME.CURLPAUSE_CONT
    if isPause then
        bit = SUPPORTPAUSEFIELDNAME.CURLPAUSE_ALL
    end
    local opt = {
        [SUPPORTOPTFIELDNAME.CURLOPT_URL] = "for";
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_BACK_ID] = callbackID;
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_PAUSE_AND_RESUME] = 1;
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_PAUSE_AND_RESUME_BIT] = bit;
    }
    CurlUtils(opt)
end

local function cancelDownload(callbackID)
    local opt = {
        [SUPPORTOPTFIELDNAME.CURLOPT_URL] = "for";
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_BACK_ID] = callbackID;
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_CANCEL] = 1;
    }
    CurlUtils(opt)
end

local function rangeDownload(url,savePath,func)
    local oldSize = cc.FileUtils:getInstance():getFileSize(savePath)
    local callbackID = getCallbackID()

    callBackIDs[callbackID] = func
    local opt = {
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_BACK_ID] = callbackID;
        [SUPPORTOPTFIELDNAME.CURLOPT_URL] = url;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_PATH] = savePath;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_FILE_MODE] = "ab";

        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEDATA] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEFUNCTION] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOPROGRESS] = 0;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSFUNCTION] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSDATA] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOSIGNAL] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_FOLLOWLOCATION] = 1;

        -- [SUPPORTOPTFIELDNAME.CURLOPT_TIMEOUT_MS] = 200; --超时
        [SUPPORTOPTFIELDNAME.CURLOPT_SSL_VERIFYPEER] = 0;

        [SUPPORTOPTFIELDNAME.CURLOPT_TCP_KEEPALIVE] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_TCP_KEEPIDLE] = 120;
        [SUPPORTOPTFIELDNAME.CURLOPT_TCP_KEEPINTVL] = 60;

        [SUPPORTOPTFIELDNAME.CURLOPT_RANGE] = tostring(oldSize) .. "-";
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_FILE_SEEK_WHERE] = 2;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_FILE_SEEK_OFFSET] = 0;

    }
    CurlUtils(opt)
    return callbackID
end

local function uploadFile(url,formName,name,savePath,func)
    local callbackID = getCallbackID()
    callBackIDs[callbackID] = func
    local opt = {
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_BACK_ID] = callbackID;
        [SUPPORTOPTFIELDNAME.CURLOPT_URL] = url;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_PATH] = savePath;
        [SUPPORTOPTFIELDNAME.CUSTOM_MODIFY_FILE_MODE] = "rb";

        -- [SUPPORTOPTFIELDNAME.CURLOPT_READDATA] = 1;  --二进制上传
        [SUPPORTOPTFIELDNAME.CURLOPT_READFUNCTION] = 1; --表单上传
        [SUPPORTOPTFIELDNAME.CURLOPT_WRITEFUNCTION] = 2; --写入函数,
        
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_OPEN_FORM] = formName;

        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_FORM_NUM] = 1; --1组
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_FORM_NAME_1] = "name";
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_FORM_CONTENTS_1] = name;

        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_HEADER_VALUE_1] = 1; --1组
        [SUPPORTOPTFIELDNAME.CUSTOM_CALL_TYPE_HEADER_VALUE_2] = "Expect:"; --Disable Expect: 100-continue

        [SUPPORTOPTFIELDNAME.CURLOPT_TIMEOUT] = 0;
        [SUPPORTOPTFIELDNAME.CURLOPT_HEADER] = 0;
        [SUPPORTOPTFIELDNAME.CURLOPT_HTTPPOST] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_NOPROGRESS] = 0;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSFUNCTION] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_PROGRESSDATA] = 1;

        [SUPPORTOPTFIELDNAME.CURLOPT_NOSIGNAL] = 1;
        [SUPPORTOPTFIELDNAME.CURLOPT_FOLLOWLOCATION] = 1;

        --输出日志
        [SUPPORTOPTFIELDNAME.CURLOPT_VERBOSE] = 1;
        
    }
    CurlUtils(opt)
    return callbackID
end

local parseScehduler = nil

-- 重启等操作需要关闭
local function closeScheduler()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(parseScehduler)
end


--通用解析
local time = 0
parseScehduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (  )
    for callID,data in pairs(callbackInfos) do
        local func = callBackIDs[callID]
        if func then
            if data.status ~= nil then
                if data.status == 0 then --任务异常结束
                    callBackIDs[callID] = nil
                    func(data.failure)
                elseif data.status == 1 then--任务正常结束
                    dump(data)
                    callBackIDs[callID] = nil
                    callbackInfos[callID] = nil
                    func("finish success")
                elseif data.status == 2 then--任务暂停、恢复成功
                    func("pause/resume success")
                elseif data.status == 3 then--任务暂停、恢复异常
                    func(data.failure)
                end
            elseif data.nowDownloaded ~= nil and  math.abs(data.nowDownloaded - 0.0001) > 0.0001 then
                if  data.totalToDownload == 0 then
                    func("current download byte" .. tostring(data.nowDownloaded))
                else
                    func("current download percent" .. tostring(data.nowDownloaded / data.totalToDownload))
                end
            elseif data.nowUpLoaded ~= nil and  data.nowUpLoaded > 0.0001 then
                if  data.totalToUpLoad == 0 then
                    func("current upload byte" .. tostring(data.nowUpLoaded))
                else
                    func("current upload percent" .. tostring(data.nowUpLoaded / data.totalToUpLoad))
                end
            end
        end
    end
    -- time = time + 1
end,0,false)



--该函数频繁调用，不再该函数中做处理，该函数一帧(1/60)有可能被调用几十次
cc.exports.vx_http_request_call_lua = function(...)
    local callID,data = ...
    callbackInfos[callID] = data
    -- 日志不用考虑多线程
    if data.log then
        print(data.log)
    end
    return 0
end






return {
    downImage = downImage,
    downBigFile = downBigFile;
    pause_resume_downloadImage = pause_resume_downloadImage,
    cancelDownload = cancelDownload,
    rangeDownload = rangeDownload,
    closeScheduler = closeScheduler,
    uploadFile = uploadFile
}

