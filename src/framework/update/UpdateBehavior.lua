---热更新管理组件
--@module UpdateBehavior
--@author Loyalwind
--Date   2018/8/13

local UpdateManager = require("UpdateManager")

local UpdateBehavior = class("UpdateBehavior", BehaviorBase)
UpdateBehavior.className_ = "UpdateBehavior";

---对外导出接口
local exportInterface = {
    "becomeResponder",
    "resignResponder",
    "initializeUpdate",
    "checkUpdate",
    "prepareUpdate",
    "confirmUpdate",
    "cancleUpdate",
    "removeOldUpdate",
}

function UpdateBehavior:becomeResponder(object)
    UpdateManager.getInstance():addResponder(object)
end

function UpdateBehavior:resignResponder(object)
    UpdateManager.getInstance():removeResponder(object)
end

function UpdateBehavior:initializeUpdate(object)
    UpdateManager.getInstance():initializeUpdate()
end

function UpdateBehavior:checkUpdate(object, url, params, callBack)
    UpdateManager.getInstance():checkUpdate(url, params, callBack)
end

function UpdateBehavior:prepareUpdate(object,updateInfo)
    UpdateManager.getInstance():prepareUpdate(updateInfo)
end

function UpdateBehavior:confirmUpdate(object,updateInfo)
    UpdateManager.getInstance():confirmUpdate(updateInfo)
end

function UpdateBehavior:cancleUpdate(object)
    UpdateManager.getInstance():cancleUpdate()
end

function UpdateBehavior:removeOldUpdate(object)
    UpdateManager.getInstance():removeOldUpdate()
end

function UpdateBehavior:bind(object)
    for i, v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]));
    end
end

function UpdateBehavior:unBind(object)
    for i, v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end
end

return UpdateBehavior