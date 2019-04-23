--region StoreDiscountImg.lua
--Author : JohnsonZhang
--Date   : 2018/10/30
--Description: 由图片组成的文字，
local StoreDiscountImg = class("StoreDiscountImg",cc.Node);

StoreDiscountImg.S_NUM_WIDTH = 11; -- 每张图片宽度
StoreDiscountImg.S_NUM_HIGH = 17; -- 每张图片高度
-- StoreDiscountImg.S_UNIT_WIDTH = 34;

StoreDiscountImg.S_PIC={}

StoreDiscountImg.ctor = function(self,num,view)
	self.m_num = num;
	self.m_posX = 0;
	self.m_imgMap = {};
	self.m_numfile = {
			[0]  = "creator/store/goldNum/gold_num_0.png";
			[1]  = "creator/store/goldNum/gold_num_1.png";
			[2]  = "creator/store/goldNum/gold_num_2.png";
			[3]  = "creator/store/goldNum/gold_num_3.png";
			[4]  = "creator/store/goldNum/gold_num_4.png";
			[5]  = "creator/store/goldNum/gold_num_5.png";
			[6]  = "creator/store/goldNum/gold_num_6.png";
			[7]  = "creator/store/goldNum/gold_num_7.png";
			[8]  = "creator/store/goldNum/gold_num_8.png";
			[9]  = "creator/store/goldNum/gold_num_9.png";
			[10] = "creator/store/goldNum/gold_num_10.png"; -- %
			[11] = "creator/store/goldNum/gold_num_11.png"; -- +
	};
	self.m_viewMoney = view
	self:initView();
end

StoreDiscountImg.dtor = function(self)
	self.m_num = 0;
	self.m_posX = 0;
	self.m_imgMap = {};
    self.m_viewMoney = nil;
end

StoreDiscountImg.setNum = function(self,num)
	self.m_num = num;
	self:initView();
end

StoreDiscountImg.initView = function(self)
	for k,v in pairs(self.m_imgMap) do
		v:setVisible(false);
	end

	local numMap = self:decodeNum(self.m_num);
	local max = #numMap;
	self.m_posX = 0;
	for k = 1, max do
		self:createNum(numMap[k],k);
	end
    self:setContentSize(cc.size(self.m_posX,StoreDiscountImg.S_NUM_HIGH));
end


StoreDiscountImg.decodeNum = function(self,num)
	local jia = "+";
	local jian = "-";
	local percent = "%"
    local numMap = {
        ["0"]  = 0;
        ["1"]  = 1;
        ["2"]  = 2;
        ["3"]  = 3;
        ["4"]  = 4;
        ["5"]  = 5;
        ["6"]  = 6;
        ["7"]  = 7;
        ["8"]  = 8;
        ["9"]  = 9;
        [percent] = 10;
        [jia] = 11; 
        [jian] = 12; 
    };

    local ret = {}
    local map = string.utf8Array(num);
    for k,v in ipairs(map) do
        local num = numMap[v];
        if not num then
            return {"0"};
        end
        ret[k] = num;
    end
    return ret
end



function StoreDiscountImg:createNum(num,index)
	local file = self.m_numfile[num];
	local img = self.m_imgMap[index];
	if not file then
		return ;
	end
	local y = 0;
	local x = 0;
	if not img then
		img = cc.Sprite:create(file);
		self:addChild(img);
		local imgSize = img:getContentSize();
		local w = imgSize.width
		local h = imgSize.height
		if h < StoreDiscountImg.S_NUM_HIGH then
			y = h-StoreDiscountImg.S_NUM_HIGH+2;
		end
		if num  == 10 then
			x = self.m_posX+3
		else
			x = self.m_posX
		end
		-- img:setPositionX(x)
		table.insert(self.m_imgMap,img);
		img:setPosition(cc.p(x,y));
		
	else
		img:setTexture(file);
		local imgSize = img:getContentSize()
		local w = imgSize.width or 0
		local h = imgSize.height or 0
		img:setContentSize(cc.size(w,h));
		local y = 0;
		if h < StoreDiscountImg.S_NUM_HIGH then
			y = h-StoreDiscountImg.S_NUM_HIGH+2;
		end

		-- img:setPosition(cc.p(self.m_posX,y));
		if num  == 10 then
			x = self.m_posX+3
		else
			x = self.m_posX
		end
		img:setPosition(cc.p(x,y))
		
	end
	img:setVisible(true);

	local imgSize = img:getContentSize();
	self.m_posX = self.m_posX + imgSize.width;

    StoreDiscountImg.S_PIC[index] = img;
end

return StoreDiscountImg
