local AccountInfo = class(AccountInfo)

function AccountInfo.getInstance()
	if not AccountInfo.s_instance then
		AccountInfo.s_instance = AccountInfo.new()
	end

	return AccountInfo.s_instance
end

function AccountInfo:ctor()
	addProperty(self, "m_uid", -1)            
	addProperty(self, "m_name", "")              
	addProperty(self, "m_playCount", 0) 
	addProperty(self, "m_playWin", 0)   
	addProperty(self, "m_playOut", 0)   
	addProperty(self, "m_playCreate", 0)
	addProperty(self, "m_honor", 0)     
	addProperty(self, "m_money", 0)     
	addProperty(self, "m_gold", 0)      
	addProperty(self, "m_title", 0)     
	addProperty(self, "m_status", 0)   
	self.m_exp = 0
	self.m_icon = 5
	self.m_progress = 0.01

	self:init()

	g_EventDispatcher:register(g_CustomEvent.USERINFO_RPS,self,self.init)
end

function AccountInfo:init(data)
	data = data or {}

	self.m_uid        = data.Uid or self.m_uid       
	self.m_exp        = data.Exp or self.m_exp       
	self.m_name       = data.Name or self.m_name      
	self.m_icon       = data.Icon or self.m_icon        
	self.m_playCount  = data.PlayCount or self.m_playCount 
	self.m_playWin    = data.PlayWin or self.m_playWin   
	self.m_playOut    = data.PlayOut or self.m_playOut   
	self.m_playCreate = data.PlayCreate or self.m_playCreate
	self.m_honor      = data.Honor or self.m_honor     
	self.m_money      = data.Money or self.m_money     
	self.m_gold       = data.Gold or self.m_gold      
	self.m_title      = data.Title or self.m_title     
	self.m_status     = data.Status or self.m_status    

	g_EventDispatcher:dispatchEvent(g_CustomEvent.UPDATE_USERINFO)
end

function AccountInfo:getIcon()
	return g_ClientConfig.S_ICONFILE[tonumber(self.m_icon)] or g_ClientConfig.S_ICONFILE[1]

end

function AccountInfo:setIcon(mtype)
	self.m_icon = mtype
end

function AccountInfo:setExp(exp)
	self.m_exp = exp
	self.m_level = nil
	self.m_progress = nil
end

function AccountInfo:getExp()
	return self.m_exp
end

function AccountInfo:getLevel()
	if self.m_level then
		return self.m_level, self.m_progress
	end

	if self.m_exp <= 0 then
		return "LV：1", 1
	end

	for k,v in ipairs(g_ClientConfig.S_LEVELMAP) do
		if self.m_exp < v then
			self.m_level = "LV：" .. (k-1)

			self.m_progress = (self.m_exp - (g_ClientConfig.S_LEVELMAP[k-1])) / v * 100

			return self.m_level, self.m_progress
		end
	end

	self.m_level = #g_ClientConfig.S_LEVELMAP
	self.m_progress = 100

	return self.m_level, self.m_progress
end


return AccountInfo