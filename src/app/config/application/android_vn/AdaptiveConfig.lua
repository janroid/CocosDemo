--[[
    author:{JanRoid}
    time:2019-1-4
	Description: 多语言版本适配配置
				用于保存：布局，字体，字号，大小，坐标，图片等一切配置
				用于保存：游戏中定义到客户单的常量数据

				新增字段注意同步到其他语言
]] 


local config = {}

config.AchieveConfig = {   -- 成就默认配置
	[1] = {['type']='101', a = '1001', b = 'Nâng cấp lần thứ 1', c = 'Lên đến cấp2', d = 0, e = 1, g = 0, f = ''};
	[2] = {['type']='101', a = '1002', b = 'Tuyển thủ nghiệp dư', c = 'Lên đến cấp5', d = 0, e = 1, g = 0, f = ''};
	[3] = {['type']='101', a = '1003', b = 'Tài năng được hiện', c = 'Lên đến cấp10', d = 0, e = 1, g = 0, f = ''};
	[4] = {['type']='101', a = '1004', b = 'Tuyển thủ nhà nước', c = 'Lên đến cấp15', d = 0, e = 2, g = 0, f = ''};
	[5] = {['type']='101', a = '1005', b = 'Đi hướng thế giới', c = 'Lên đến cấp20', d = 0, e = 2, g = 0, f = ''};
	[6] = {['type']='101', a = '1006', b = 'Thần bài xuống', c = 'Lên đến cấp25', d = 0, e = 3, g = 0, f = 'Quà vĩnh cửu"Thần uy"'};
	[7] = {['type']='102', a = '1007', b = 'Hoan nghênh ', c = 'Hoàn thành cuộc thứ nhất', d = 0, e = 1, g = 0, f = ''};
	[8] = {['type']='102', a = '1008', b = 'Thắng lần thứ nhất', c = 'Được cuộc thắng thứ nhất', d = 0, e = 1, g = 0, f = ''};
	[9] = {['type']='102', a = '1018', b = 'Nhà trăm triệu phú', c = 'Chips game đặt 100000000', d = 0, e = 3, g = 0, f = 'Quà vĩnh cửu"Nhà trăm triệu phú"'};
	[10] = {['type']='102', a = '1019', b = 'Phú Hào', c = 'Chips game đặt 500000000', d = 0, e = 3, g = 0, f = 'Quà vĩnh cửu"Nhà Phú hào"'};
	[11] = {['type']='102', a = '1020', b = 'Phú Giáp Thiên Hạ', c = 'Chips game đặt 1000000000', d = 0, e = 3, g = 0, f = 'Quà vĩnh cửu"Phú giáp thiên hạ"'};
	[12] = {['type']='102', a = '1021', b = 'Giàu có', c = 'Chips game đặt 5000000000', d = 0, e = 3, g = 0, f = 'Quà vĩnh cửu"rất giàu có"'};
	[13] = {['type']='102', a = '1022', b = 'Chỉ còn tiền', c = 'Chips game đặt 10000000000', d = 0, e = 3, g = 0, f = 'Quà vĩnh cửu"không gì mà còn tiền"'};
	[14] = {['type']='302', a = '3006', b = 'Tài năng mới hiện', c = 'Tích lũy thắng 10 cuộc ', d = 1, e = 1, g = 10, f = ''};
	[15] = {['type']='302', a = '3007', b = 'Dần vào cảnh đẹp', c = 'Tích lũy thắng 50 cuộc', d = 1, e = 1, g = 50, f = ''};
	[16] = {['type']='302', a = '3008', b = 'Trăm trận trăm thắng', c = 'Tích lũy thắng 100 cuộc', d = 1, e = 1, g = 100, f = 'VIP 3 ngày'};
	[17] = {['type']='302', a = '3009', b = 'Thế như chẻ tre', c = 'Tích lũy thắng 500 cuộc', d = 1, e = 1, g = 500, f = ''};
	[18] = {['type']='302', a = '3010', b = 'Càn Quét thiên quân', c = 'Tích lũy thắng 1000 cuộc', d = 1, e = 2, g = 1000, f = 'Quà vĩnh cửu"Cao thủ poker"'};
	[19] = {['type']='302', a = '3011', b = 'Tướng lĩnh mãi thắng', c = 'Tích lũy thắng 5000 cuộc', d = 1, e = 2, g = 5000, f = 'VIP 1 tháng'};
	[20] = {['type']='302', a = '3012', b = 'Vạn nhân chém', c = 'Tích lũy thắng 10000 cuộc', d = 1, e = 3, g = 10000, f = 'Quà vĩnh cửu"Đại sư poker"'};
	[21] = {['type']='302', a = '3013', b = 'Quái Vật Poker', c = 'Tích lũy thắng 50000 cuộc', d = 1, e = 3, g = 50000, f = 'Quà vĩnh cửu"Quái vật poker"+VIP nửa năm'};
	[22] = {['type']='302', a = '3014', b = 'Thần Poker', c = 'Tích lũy thắng 100000 cuộc', d = 1, e = 3, g = 100000, f = 'Quà vĩnh cửu"Thần poker"+VIP nửa năm'};
	[23] = {['type']='303', a = '3015', b = 'Yêu Poker', c = 'Tích lũy chơi bài 10 cuộc', d = 2, e = 1, g = 10, f = '10000000 chips'};
	[24] = {['type']='303', a = '3016', b = 'Cựu chiến binh', c = 'Tích lũy chơi bài 100 cuộc', d = 2, e = 1, g = 100, f = ''};
	[25] = {['type']='303', a = '3017', b = 'Nghìn trận không thua', c = 'Tích lũy chơi bài 1000 cuộc', d = 2, e = 1, g = 1000, f = 'VIP 7 ngày'};
	[26] = {['type']='303', a = '3018', b = 'Trái tâm Poker', c = 'Tích lũy chơi bài 10000 cuộc', d = 2, e = 2, g = 10000, f = 'Quà vĩnh cửu"Trái tâm Poker"'};
	[27] = {['type']='303', a = '3019', b = 'Tâm hồn Poker', c = 'Tích lũy chơi bài 100000 cuộc', d = 2, e = 3, g = 100000, f = 'Quà vĩnh cửu"Tâm hồn Poker"'};
	[28] = {['type']='303', a = '3020', b = 'Tôi là Poker', c = 'Tích lũy chơi bài 1000000 cuộc', d = 2, e = 3, g = 1000000, f = 'Quà vĩnh cửu"Tôi là Poker"'};
	[29] = {['type']='304', a = '3021', b = 'Bất khuất', c = 'Tích lũy thất bại 100 cuộc', d = 3, e = 1, g = 100, f = ''};
	[30] = {['type']='304', a = '3022', b = 'Kiên cường bất khuất', c = 'Tích lũy thất bại 1000 cuộc', d = 3, e = 1, g = 1000, f = ''};
	[31] = {['type']='304', a = '3023', b = 'Ý chí sắt đá ', c = 'Tích lũy thất bại 10000 cuộc', d = 3, e = 2, g = 10000, f = ''};
	[32] = {['type']='304', a = '3024', b = 'Không bao giờ rơi', c = 'Tích lũy thất bại 100000 cuộc', d = 3, e = 2, g = 100000, f = ''};
	[33] = {['type']='304', a = '3025', b = 'Chiến thần vô địch', c = 'Tích lũy thất bại 1000000 cuộc', d = 3, e = 3, g = 1000000, f = 'Quà vĩnh cửu"Vô địch chiến thần"'};
	[34] = {['type']='401', a = '4001', b = 'Tôi không cô đơn', c = 'Ít nhất có 1 bạn bài', d = 0, e = 1, g = 1, f = ''};
	[35] = {['type']='401', a = '4002', b = 'Cùng đi với bạn', c = 'Ít nhất có 10 bạn bài', d = 5, e = 1, g = 10, f = ''};
	[36] = {['type']='401', a = '4003', b = 'Nhiều bạn bè', c = 'Ít nhất có 50 bạn bài', d = 5, e = 2, g = 50, f = ''};
	[37] = {['type']='401', a = '4004', b = 'Được ưa thích', c = 'Ít nhất có 100 bạn bài', d = 5, e = 2, g = 100, f = ''};
	[38] = {['type']='401', a = '4007', b = 'Cùng chơi vơi tôi', c = 'Mời 1 bạn fb tham gia Poker Texas', d = 0, e = 1, g = 1, f = ''};
	[39] = {['type']='401', a = '4008', b = 'Gọi bạn bè', c = 'Mời 5 bạn fb tham gia Poker Texas', d = 6, e = 1, g = 5, f = ''};
	[40] = {['type']='401', a = '4009', b = 'Gọi bạn kéo lũ', c = 'Mời 10 bạn fb tham gia Poker Texas', d = 6, e = 2, g = 10, f = 'VIP 7 ngày'};
	[41] = {['type']='401', a = '4010', b = 'Đẩy sức hấp dẫn', c = 'Mời 30 bạn fb tham gia Poker Texas', d = 6, e = 2, g = 30, f = 'Quà vĩnh cửu"Đầy sức hấp dẫn"'};
	[42] = {['type']='401', a = '4011', b = 'Siêu sao', c = 'Mời 100 bạn fb tham gia Poker Texas', d = 6, e = 3, g = 100, f = 'Quà vĩnh cửu"Ngôi sao nhân khí "+VIP 1 năm'};
	[43] = {['type']='402', a = '4012', b = 'Kết bạn ', c = 'Tặng 1 quà', d = 0, e = 1, g = 1, f = ''};
	[44] = {['type']='402', a = '4013', b = 'Có đi có lại', c = 'Tặng 10 quà', d = 7, e = 1, g = 10, f = ''};
	[45] = {['type']='402', a = '4014', b = 'viện trợ rộng rãi', c = 'Tặng 100 quà', d = 7, e = 1, g = 100, f = ''};
	[46] = {['type']='402', a = '4015', b = 'Trọng tình nghĩa', c = 'Tặng 1000 quà', d = 7, e = 2, g = 1000, f = ''};
	[47] = {['type']='402', a = '4016', b = 'vua quà', c = 'Tặng 10000 quà', d = 7, e = 3, g = 10000, f = 'Quà vĩnh cửu"Vua quà"'};
	[48] = {['type']='402', a = '4017', b = 'Có duyên', c = 'Thu được 1 quà', d = 0, e = 1, g = 1, f = ''};
	[49] = {['type']='402', a = '4018', b = 'Khí chất bất thường', c = 'Thu được 10 quà', d = 8, e = 1, g = 10, f = ''};
	[50] = {['type']='402', a = '4019', b = 'Mọi người đều thích', c = 'Thu được 100 quà', d = 8, e = 1, g = 100, f = ''};
	[51] = {['type']='402', a = '4020', b = 'Ngôi sao có duyên', c = 'Thu được 1000 quà', d = 8, e = 2, g = 1000, f = 'Quà vĩnh cửu"Ngôi sao poker"'};
	[52] = {['type']='402', a = '4021', b = 'Tình địch toàn dân', c = 'Thu được 100000 quà', d = 8, e = 3, g = 100000, f = 'Quà vĩnh cửu"Tình địch toàn dân"'};
	[53] = {['type']='101', a = '1009', b = 'Đại sư truyền kỳ', c = 'Lên đến cấp bậc 30', d = 0, e = 3, g = 0, f = 'Đại sư truyền kỳ'};
}

config.SlotBounsConfig = {  -- 老虎机奖励倍数默认配置
 	[1] = 10000;
 	[2] = 1000;
 	[3] = 200;
 	[4] = 80;
 	[5] = 20;
 	[6] = 10;
 	[7] = 5;
 	[8] = 3;
 	[9] = 1;
}

config.Login = {
	rewardFontSize = 15,
	upgradeBtnFontSize = 24,
}

config.Help = {
	TabarFontSize = 24,
	SubviewTabarFontSize = 18,
	SubViewFontSize = 18,
	SubViewFontSize2 = 18,
	LevelSystemFontSize = 18,
}

config.NormalSelections = {
	TabarFontSize = 24,
}

config.MTTResult = {
	RankTitlePosition = 80,
}
	
config.RoomChat = {
	EditBoxPlaceholderFontSize = 22,
	QuickChatFontSize = 26;
}

config.SNGLobby = {
	RankGapWithPreviousFontSize = 20,
	MonthMatchIncomeFontSize = 18,
	TitleFontName = nil,
}

config.PrivateRoom = {
    MotifyPwdPlaceholderFontSize = 15,
}

config.SuperLotto = {
	TextClickFontSize = 20,
	RewardPokerPosX = 128,
}


return config;