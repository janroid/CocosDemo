local config = {
	[1] = {['type']='101', a = '1001', b = '第一次升級', c = '升到2級', d = 0, e = 1, g = 0, f = ''};
	[2] = {['type']='101', a = '1002', b = '業餘撲克選手', c = '升到5級', d = 0, e = 1, g = 0, f = ''};
	[3] = {['type']='101', a = '1003', b = '鋒芒畢露', c = '升到10級', d = 0, e = 1, g = 0, f = ''};
	[4] = {['type']='101', a = '1004', b = '國家級選手', c = '升到15級', d = 0, e = 2, g = 0, f = ''};
	[5] = {['type']='101', a = '1005', b = '走向世界', c = '升到20級', d = 0, e = 2, g = 0, f = ''};
	[6] = {['type']='101', a = '1006', b = '牌神降臨', c = '升到25級', d = 0, e = 3, g = 0, f = '永久禮物“神威”'};
	[7] = {['type']='303', a = '1007', b = '歡迎新人', c = '完成第一局撲克', d = 0, e = 1, g = 0, f = ''};
	[8] = {['type']='302', a = '1008', b = '首戰告捷', c = '獲得第一場勝利', d = 0, e = 1, g = 0, f = ''};
	[9] = {['type']='102', a = '1013', b = '萬元戶', c = '遊戲幣達到1萬', d = 0, e = 1, g = 0, f = ''};
	[10] = {['type']='102', a = '1014', b = '第一桶金', c = '遊戲幣達到10萬', d = 0, e = 1, g = 0, f = ''};
	[11] = {['type']='102', a = '1015', b = '百萬富翁', c = '遊戲幣達到100萬', d = 0, e = 2, g = 0, f = '永久禮物“百萬富翁”'};
	[12] = {['type']='102', a = '1016', b = '千萬富翁', c = '遊戲幣達到1000萬', d = 0, e = 2, g = 0, f = '永久禮物“千萬富翁”'};
	[13] = {['type']='102', a = '1017', b = '超級富翁', c = '遊戲幣達到5000萬', d = 0, e = 2, g = 0, f = '永久禮物“超級富豪”'};
	[14] = {['type']='102', a = '1018', b = '億萬富翁', c = '遊戲幣達到1億', d = 0, e = 3, g = 0, f = '永久禮物“億萬富翁”'};
	[15] = {['type']='102', a = '1019', b = '富豪', c = '遊戲幣達到5億', d = 0, e = 3, g = 0, f = '永久禮物“富豪”'};
	[16] = {['type']='102', a = '1020', b = '富甲天下', c = '遊戲幣達到10億', d = 0, e = 3, g = 0, f = '永久禮物“富甲天下”'};
	[17] = {['type']='102', a = '1021', b = '富可敵國', c = '遊戲幣達到50億', d = 0, e = 3, g = 0, f = '永久禮物“富可敵國”'};
	[18] = {['type']='102', a = '1022', b = '窮的只剩錢了', c = '遊戲幣達到100億', d = 0, e = 3, g = 0, f = '永久禮物“窮得只剩錢了”'};
	[19] = {['type']='302', a = '3006', b = '初露鋒芒', c = '累計獲得10場勝利', d = 1, e = 1, g = 10, f = ''};
	[20] = {['type']='302', a = '3007', b = '漸入佳境', c = '累計獲得50場勝利', d = 1, e = 1, g = 50, f = ''};
	[21] = {['type']='302', a = '3008', b = '百戰百勝', c = '累計獲得100場勝利', d = 1, e = 1, g = 100, f = 'VIP1天'};
	[22] = {['type']='302', a = '3009', b = '勢如破竹', c = '累計獲得500場勝利', d = 1, e = 1, g = 500, f = ''};
	[23] = {['type']='302', a = '3010', b = '橫掃千軍', c = '累計獲得1000場勝利', d = 1, e = 2, g = 1000, f = '永久禮物“撲克高手”'};
	[24] = {['type']='302', a = '3011', b = '常勝將軍', c = '累計獲得5000場勝利', d = 1, e = 2, g = 5000, f = 'VIP1個月'};
	[25] = {['type']='302', a = '3012', b = '萬人斬', c = '累計獲得10000場勝利', d = 1, e = 3, g = 10000, f = '永久禮物“撲克大師”'};
	[26] = {['type']='302', a = '3013', b = '撲克怪物', c = '累計獲得50000場勝利', d = 1, e = 3, g = 50000, f = '永久禮物“撲克怪物”+VIP半年'};
	[27] = {['type']='302', a = '3014', b = '撲克之神', c = '累計獲得100000場勝利', d = 1, e = 3, g = 100000, f = '永久禮物“撲克之神”+VIP1年'};
	[28] = {['type']='303', a = '3015', b = '愛上撲克', c = '累計玩牌10局', d = 2, e = 1, g = 10, f = ''};
	[29] = {['type']='303', a = '3016', b = '身經百戰', c = '累計玩牌100局', d = 2, e = 1, g = 100, f = ''};
	[30] = {['type']='303', a = '3017', b = '千戰不殆', c = '累計玩牌1000局', d = 2, e = 1, g = 1000, f = 'VIP3天'};
	[31] = {['type']='303', a = '3018', b = '撲克之心', c = '累計玩牌10000局', d = 2, e = 2, g = 10000, f = '永久禮物“撲克之心”'};
	[32] = {['type']='303', a = '3019', b = '撲克之魂', c = '累計玩牌100000局', d = 2, e = 3, g = 100000, f = '永久禮物“撲克之魂”'};
	[33] = {['type']='303', a = '3020', b = '我是撲克', c = '累計玩牌1000000局', d = 2, e = 3, g = 1000000, f = '永久禮物“我是撲克”'};
	[34] = {['type']='304', a = '3021', b = '百折不撓', c = '累計遭遇100場失敗', d = 3, e = 1, g = 100, f = ''};
	[35] = {['type']='304', a = '3022', b = '剛毅不屈', c = '累計遭遇1000場失敗', d = 3, e = 1, g = 1000, f = ''};
	[36] = {['type']='304', a = '3023', b = '鋼鐵意志', c = '累計遭遇10000場失敗', d = 3, e = 2, g = 10000, f = ''};
	[37] = {['type']='304', a = '3024', b = '永不倒下', c = '累計遭遇100000場失敗', d = 3, e = 2, g = 100000, f = ''};
	[38] = {['type']='304', a = '3025', b = '無敵戰神', c = '累計遭遇1000000場失敗', d = 3, e = 3, g = 1000000, f = '永久禮物“無敵戰神”'};
	[39] = {['type']='401', a = '4001', b = '我不孤單', c = '擁有至少1名牌友', d = 0, e = 1, g = 1, f = ''};
	[40] = {['type']='401', a = '4002', b = '結伴而行', c = '擁有至少10名牌友', d = 5, e = 1, g = 10, f = ''};
	[41] = {['type']='401', a = '4003', b = '高朋滿座', c = '擁有至少50名牌友', d = 5, e = 2, g = 50, f = ''};
	[42] = {['type']='401', a = '4004', b = '撲克紅人', c = '擁有至少100名牌友', d = 5, e = 2, g = 100, f = ''};
	[43] = {['type']='401', a = '4007', b = '來陪我吧', c = '邀請1個好友加入德州撲克', d = 0, e = 1, g = 1, f = ''};
	[44] = {['type']='401', a = '4008', b = '呼朋引伴', c = '邀請5個好友加入德州撲克', d = 6, e = 1, g = 5, f = ''};
	[45] = {['type']='401', a = '4009', b = '召集好友', c = '邀請10個好友加入德州撲克', d = 6, e = 2, g = 10, f = 'VIP7天'};
	[46] = {['type']='401', a = '4010', b = '魅力四射', c = '邀請30個好友加入德州撲克', d = 6, e = 2, g = 30, f = '永久禮物“魅力四射”'};
	[47] = {['type']='401', a = '4011', b = '人氣巨星', c = '邀請100個好友加入德州撲克', d = 6, e = 3, g = 100, f = '永久禮物“人氣之星”+VIP1年'};
	[48] = {['type']='402', a = '4012', b = '交朋友', c = '贈送1個禮物', d = 0, e = 1, g = 1, f = ''};
	[49] = {['type']='402', a = '4013', b = '禮尚往來', c = '贈送10個禮物', d = 7, e = 1, g = 10, f = ''};
	[50] = {['type']='402', a = '4014', b = '慷慨解囊', c = '贈送100個禮物', d = 7, e = 1, g = 100, f = ''};
	[51] = {['type']='402', a = '4015', b = '重情重義', c = '贈送1000個禮物', d = 7, e = 2, g = 1000, f = ''};
	[52] = {['type']='402', a = '4016', b = '禮物帝皇', c = '贈送10000個禮物', d = 7, e = 3, g = 10000, f = '永久禮物“禮物帝皇”'};
	[53] = {['type']='402', a = '4017', b = '討人喜歡', c = '收到1個禮物', d = 0, e = 1, g = 1, f = ''};
	[54] = {['type']='402', a = '4018', b = '氣質非凡', c = '收到10個禮物', d = 8, e = 1, g = 10, f = ''};
	[55] = {['type']='402', a = '4019', b = '人見人愛', c = '收到100個禮物', d = 8, e = 1, g = 100, f = ''};
	[56] = {['type']='402', a = '4020', b = '魅力之星', c = '收到1000個禮物', d = 8, e = 2, g = 1000, f = '永久禮物“魅力之星”'};
	[57] = {['type']='402', a = '4021', b = '全民情敵', c = '收到100000個禮物', d = 8, e = 3, g = 100000, f = '永久禮物“全民情敵”'};
	[58] = {['type']='102', a = '1009', b = '傳奇大師', c = '等級達到30級', d = 0, e = 1, g = 0, f = '傳奇大師'};
}
return config;