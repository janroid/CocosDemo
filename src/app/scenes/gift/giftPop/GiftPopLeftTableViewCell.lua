local GiftPopLeftTableViewCell  = class("GiftPopLeftTableViewCell",cc.TableViewCell)

GiftPopLeftTableViewCell.TYPE_GET = 1;   -- 领取
GiftPopLeftTableViewCell.TYPE_SIGN = 2;   -- 填写资料
GiftPopLeftTableViewCell.TYPE_CHECK = 3; -- 查看
GiftPopLeftTableViewCell.TYPE_PIC = 4; --  显示图片
GiftPopLeftTableViewCell.ctor = function(self)   
    self:init()
end

GiftPopLeftTableViewCell.init = function(self)

    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/gift/layout/giftLeftTabItem.ccreator')
    self:addChild(self.m_root)
    self.m_isSelect = false -- 默认选中样式
    self.m_imgSelect = g_NodeUtils:seekNodeByName(self.m_root,'sel')
    self.m_tittle = g_NodeUtils:seekNodeByName(self.m_root,'tittle')
    self.m_imgSelect:setOpacity(self.m_isSelect and 255 or 0)
end

GiftPopLeftTableViewCell.updateCell = function(self,data,isShow)
    self.m_data = data or ""
    self.m_tittle:setString(data)
    self:onCellTouch(isShow)
    
end

GiftPopLeftTableViewCell.onCellTouch = function(self,isShow)
    self.m_imgSelect:setOpacity(isShow and 255 or 0) 
    self.m_isSelect = isShow
end


return GiftPopLeftTableViewCell