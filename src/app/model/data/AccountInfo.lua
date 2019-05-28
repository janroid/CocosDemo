local AccountInfo = class(AccountInfo)

function AccountInfo.getInstance()
	if not AccountInfo.s_instance then
		AccountInfo.s_instance = AccountInfo.new()
	end

	return AccountInfo.s_instance
end

function AccountInfo:ctor()
	addProperty(self, "m_uid", -1)       
	addProperty(self, "m_exp", 0)       
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

	self:init()

	g_EventDispatcher:register(g_CustomEvent.USERINFO_RPS,self,self.init)
end

function AccountInfo:init(data)
	data = data or {}

	self.m_uid        = data.Uid or self.m_uid       
	self.m_exp        = data.Money or self.m_exp       
	self.m_name       = data.Exp or self.m_name      
	self.m_icon       = data.Icon or self.m_icon      
	self.m_acName     = data.AcName or self.m_acName    
	self.m_acPwd      = data.AcPwd or self.m_acPwd     
	self.m_playCount  = data.PlayCount or self.m_playCount 
	self.m_playWin    = data.PlayWin or self.m_playWin   
	self.m_playOut    = data.PlayOut or self.m_playOut   
	self.m_playCreate = data.PlayCreate or self.m_playCreate
	self.m_honor      = data.Honor or self.m_honor     
	self.m_money      = data.Gold or self.m_money     
	self.m_gold       = data.Title or self.m_gold      
	self.m_title      = data.Status or self.m_title     
	self.m_status     = data.Name or self.m_status    

end

function AccountInfo:getIcon()
	return g_ClientConfig[self.m_icon] or g_ClientConfig[1]

end

function AccountInfo:setIcon(mtype)
	self.m_icon = mtype
end


return AccountInfo