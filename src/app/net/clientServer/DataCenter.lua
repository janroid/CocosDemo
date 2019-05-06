local DataCenter = class("DataCenter")

function DataCenter:ctor( )
    self:initUser()
end

-- 初始化用户表
function DataCenter:initUser()
    local tab = g_DictUtils.getData(g_DataKey.CS_USER,{})

    g_DictUtils.setData(g_DataKey.CS_USER, tab)
end

--[[
    @desc: user = {mid,exp,name,icon,ac_name,ac_pwd,play_count,play_win,play_out,play_create,honor,money,gold,title}
    author:{author}
    time:2019-04-26 12:01:26
    @return:
]]
function DataCenter:registerUser(name,pwd)
    local userMap = g_DictUtils.getData(g_DataKey.CS_USER,{})

    for k,v in ipairs(userMap) do
        if v.ac_name == name then
            return 
        end
    end

    local id = 1001
    if #userMap > 0 then
        id = userMap[#userMap].mid + 1
    end
    
    local newUser = {
        mid = id,
        exp = 0,
        name = "user_"..id,
        icon = 1,
        ac_name = name,
        ac_pwd = pwd,
        play_count = 0,
        play_win = 0,
        play_out = 0,
        play_create = 0,
        honor = 0,
        money = 1000,
        gold = 0,
        title = 1,
    }


    userMap[#userMap+1] = newUser

    g_DictUtils.setData(g_DataKey.CS_USER, userMap)

    return newUser
end

function DataCenter:getUser(name,pwd)
    local userMap = g_DictUtils.getData(g_DataKey.CS_USER, {})
    for k,v in ipairs(userMap) do
        if v.ac_name == name and v.ac_pwd == pwd then
            return v
        end
    end

    return 
end


return DataCenter