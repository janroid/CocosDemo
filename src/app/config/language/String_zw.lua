--[[
    多語言文本文件，所有項目中使用到的文字需要定義於該文本中，使用key-value形式，便於後續多語言翻譯
    文件命名格式統一為String_xx,其中xx為語言簡稱，請使用國際通用簡稱。
    ------------------------------------------------------------------
    使用規範：
    1、BYString下字段使用key = value形式，value只可以為String，否則無法對接翻譯後臺
    2、key命名格式：
        str_模塊名_自定義名，BYString內字段key都必須遵循該命名規範，便於管理
    3、新增加文字時，請先查找是否已存在相同文本，避免出現重復文本。
    4、使用方法：調用全局方法GameString.get(key)方法，可以獲得相對應的文本
    -------------------------------------------------------------------
    author:{JanRoid}
    time:2018-10-25 15:44:47
]]

local shareStoreUrl = "http://pclpthik01.boyaagame.com/api/facebook/applink"

local BYString = {

    --common
    str_common_php_request_error_msg	= "您的網路似乎沒有連接";				--您的網路似乎沒有連接
    str_common_currency_multiple		= "1";				--貨幣倍數
    str_common_too_rich				= "您的籌碼已超過 {0} ，不要再虐待新手啦！去更高級的房間挑戰高手，體現王者風範！";				--籌碼太多，不能進入新手場
    str_common_too_poor				= "您的籌碼總額不足 {0} ，當前遊戲場江湖險惡， 請先去初級場或中級場試煉!";				--籌碼太少且等級不足，不能在高級場坐下
    str_common_go_now				= "馬上去";				--馬上去
    str_common_know				= "知道了";				--知道了
    str_common_network_problem          = "無法連接,請檢查網路連接";   --網路問題
    str_common_network_to_set           = "前往設置";   --設置網路
    str_common_network_recieve_fail          = "領取失敗，請檢查網路連接";
    str_common_retry		    		= "重  試";				--重試
    str_common_cancel  = "取 消";
    str_common_confirm = "確 定";
    str_common_back    = "返 回";
    str_common_share    = "分 享";
    str_common_get_new_glory				= "祝賀您獲得了新的成就";				--獲得新成就
    str_common_get_new_message = "您有新的消息，請注意查看郵箱。";
    

    str_common_chip = "籌碼";
    str_common_reward = "獎勵";

    -- 單位
    str_unit_wan = "萬";
    str_unit_yi = "億";
    str_unit_thousand = "K";
    str_unit_million = "M";
    str_unit_billion = "B";

    str_help_title = "幫助中心";
    str_help_title1 = "常見問題";
    str_help_title2 = "基本規則";
    str_help_title3 = "等級說明";
    str_help_title4 = "問題反饋";
    str_help_title5 = "支付問題";
    str_help_title6 = "帳號問題";
    str_help_title7 = "登錄獎勵";
    str_help_title8 = "遊戲BUG" ;
    str_help_title9 = "遊戲建議";
    str_help_title10 = "牌型大小";
    str_help_title11 = "遊戲規則";
    str_help_title12 = "下注規則";
    str_help_title13 = "專業名詞";
    str_help_title14 = "獲得經驗方式";
    str_help_title15 = "等級系統";
    str_help_waiting = "未處理";
    str_help_replied = "已回復";
    str_help_card_dec1= "皇家同花順>同花順>四條>葫蘆>同花>順子>三條>兩對>一對>高牌";
    str_help_card_tit1= "1.皇家同花順";
    str_help_card_dec2= "同一花色中最大的順子";
    str_help_card_tit2= "2.同花順";    
    str_help_card_dec3= "同一花色的順子";
    str_help_card_tit3= "3.四條";       
    str_help_card_dec4= "有四張相同數值的牌";
    str_help_card_tit4= "4.葫蘆";       
    str_help_card_dec5= "三張相同數值的牌加一對";
    str_help_card_tit5= "5.同花";       
    str_help_card_dec6= "五張牌花色相同";
    str_help_card_tit6= "6.順子";       
    str_help_card_dec7= "花色不同的順子";
    str_help_card_tit7= "7.三條";       
    str_help_card_dec8= "三張相同數值的牌加兩單張";
    str_help_card_tit8= "8.兩對";       
    str_help_card_dec9= "兩對加一單張";
    str_help_card_tit9= "9.一對";       
    str_help_card_dec10= "三單張加一對";
    str_help_card_tit10= "10.高牌";      
    str_help_card_dec11= "五張牌各不相同，最大的為A";  
    str_help_rule_dec1 = "用牌";
    str_help_rule_dec2 = "除大小王外的52張撲克牌。";
    str_help_rule_dec3 = "遊戲人數";
    str_help_rule_dec4 = "2-9人，2人即可開始遊戲，最多9人。";
    str_help_rule_dec5 = "遊戲模式—無限制模式";
    str_help_rule_dec6 = "無限制模式是指每輪遊戲過程中沒有任何限制，是德克薩斯撲克遊戲模式中風險更大但更富挑戰性刺激性的遊戲模式。";
    str_help_rule_dec7 = "比牌方式";
    str_help_rule_dec8 = "用自己的2張底牌和5張公共牌結合在一起，選出5張牌，湊成最大的牌型，跟其他玩家比大小。";
    str_help_rule_dec9 = "成牌規則：";
    str_help_rule_dec10 = "公共牌";
    str_help_rule_dec11 = "加上";
    str_help_rule_dec12 = "玩家A手牌";
    str_help_rule_dec13 = "玩家B手牌";
    str_help_rule_dec14 = "負方";
    str_help_rule_dec15 = "勝方";
    str_help_rule_dec16 = "玩家A最佳牌型";
    str_help_rule_dec17 = "玩家B最佳牌型";
    str_help_rule_dec18 = "三條";
    str_help_rule_dec19 = "順子";
    str_help_rule_dec21 = "第一輪下注";    
    str_help_rule_dec22 = "發底牌，開始第一輪下注。系統為小盲位和大盲位玩家自動下小盲注和大盲注。其他玩家可以選擇跟、加或棄牌，本輪下注在所有玩家的下注額達到一致時結束。（德州籌碼不足的玩家需要全下才能參與後面的比牌。)";
    str_help_rule_dec23 = "第二輪下注";    
    str_help_rule_dec24 = "發三張公共牌（翻牌），開始第二輪下注。由小盲位開始依次下注，其他玩家可以選擇跟、加或棄牌，本輪下注在所有玩家的下注額達到一致時結束。（德州籌碼不足的玩家需要全下才能參與後面的比牌。）";
    str_help_rule_dec25 = "第三輪下注";    
    str_help_rule_dec26 = "發第四張公共牌（轉牌），開始第三輪下注。下注規則同上。";
    str_help_rule_dec27 = "第四輪下注";    
    str_help_rule_dec28 = "發第五張公共牌（河牌），開始第四輪下注。下注規則同上。"; 
    str_help_rule_dec29 = "比牌";   
    str_help_rule_dec30 = "比完成四輪下注之後，就開始比牌了。";  
    str_help_noun_tit1 = "莊家";   
    str_help_noun_des1 = "第一盤遊戲開始隨機選定莊家，若第二局遊戲無人進來也無上一局任何一人離開，則按照第一盤遊戲的莊家順時針選定莊家。若有人進來或有任何一人離開則意味著新的一局開始，由系統隨機選取莊家。";
    str_help_noun_tit2 = "小盲位"; 
    str_help_noun_des2 = "小盲位是指由按照順時針次序莊家的下一位玩家。遊戲開始後，小盲位玩家獲得系統自動發的牌，並由系統代該玩家自動下本房間最低額的一半。";
    str_help_noun_tit3 = "大盲位"; 
    str_help_noun_des3 = "大盲位是指由按照順時針次序小盲位的下一位玩家。遊戲開始後，大盲位玩家由系統代其自動下本房間最低額。";
    str_help_noun_tit4 = "發牌";   
    str_help_noun_des4 = "從小盲位的玩家開始發起，按照順時針次序，每人每次一張，直接到所有人都有2張底牌為止。";
    str_help_noun_tit5 = "燒牌";   
    str_help_noun_des5 = "在需要發牌前，按照遊戲規則需要燒牌一張，即從剩餘的牌中按次序拿出最上面一張廢除，再繼續發牌。" ;
    str_help_noun_tit6 = "底牌";   
    str_help_noun_des6 = "最開始發給玩家的兩張牌叫做底牌，只允許玩家自己看到，並且以明牌的方式放置在玩家區域旁。";
    str_help_noun_tit7 = "公共牌"; 
    str_help_noun_des7 = "將根據遊戲的進行，在臺面上擺放5張可以和底牌配套使用的牌叫做公共牌。";
    str_help_noun_tit8 = "下注";     
    str_help_noun_des8 = "是指輪到玩家操作時，此時該玩家可以按照自己的意願率先下一定數量的德州籌碼到遊戲中。";
    str_help_noun_tit9 = "跟";     
    str_help_noun_des9 = "跟是指和前面玩家下同樣數量的德州籌碼。跟的時候只能看到需要跟的數值，無法更改數值，並且顯示的數量是相對增量值，即還需要跟多少。如果玩家擁有的德州籌碼數少於需要跟的值，則不能“跟”只能“全下”。";
    str_help_noun_tit10 = "棄牌";   
    str_help_noun_des10 = "放棄繼續下去。";
    str_help_noun_tit11 = "過牌";   
    str_help_noun_des11 = "不做任何操作過牌到下一個人，並保留下的權利。過牌必須是在無需跟進的情況下使用，比如前面所有玩家都過牌或棄牌的情況。若前面的玩家一旦有人有下則不允許使用過牌。";
    str_help_noun_tit12 = "加注";   
    str_help_noun_des12 = "在前面玩家下、跟、加的基礎上，增加更多的德州籌碼。當之前的玩家必須要有下或跟或加的基礎上，下一位玩家的操作行為才能有“加”。但如果玩家擁有的德州籌碼超過需要跟的值，不足以支撐到加的最低需要數值，那麼不能“加”只能“全下”。";
    str_help_noun_tit13 = "全下";   
    str_help_noun_des13 = "指的是把手上剩下的所有德州籌碼一次全下。一個人在沒有足夠德州籌碼跟的時候可以把僅剩的籌碼全部下上。一旦有人全下，底池可能會分出一個“邊池”。邊池的獎金數只包含眾人從牌局開始到跟進他的“全下”之後超過全下玩家投入的德州籌碼。如果牌局在此人全下以後仍然繼續，則此人如果是最強手則有權利贏走“底池”，但不能贏得其他玩家在他全下以後投進“邊池”的德州籌碼。在這種情況下，第二強的選手將贏走全下以後的邊池，也即是剩餘的德州籌碼。";
    str_help_noun_tit14 = "成手";   
    str_help_noun_des14 = "成手的大小即最後手中牌型的大小。在攤牌階段，每個玩家以七張牌（自己的兩張底牌和五張公共牌）裏面的最好五張組成自己的最佳成手。成手最強的勝出。這可以是玩家的兩張底牌和三張公共牌，或一張底牌加四張公共牌。有時甚至五張公共牌皆是每個人的最佳成手，則大家可以平分“彩池”。每一成手必定由五張牌組成。";
    str_help_que1 = "如何聯繫我們？";                            
    str_help_ans1  = "您可以點擊左側“問題反饋”按鈕給我們反饋問題";
    str_help_que2 = "為什麼我領取不了每日簽到獎勵？";            
    str_help_ans2  = "每日簽到獎勵玩家只能在一天中領取一次，系統會於每天00：00清除您前一天的領獎記錄。";
    str_help_que3 = "我的籌碼用完了，我還想玩，該怎麼辦？";      
    str_help_ans3  = "您可以在商店中付費購買籌碼。您也可以進入活動中心，參加我們的活動或者完成每日獎勵獲取多多免費的籌碼。";
    str_help_que4 = "為什麼我總是頻繁的掉線？";                  
    str_help_ans4  = "請您先檢查當地的網路環境是否正常，沒有流暢的網路，再好的線上遊戲也不能暢玩哦。";
    str_help_que5 = "為什麼我贈送不了遊戲幣？";                  
    str_help_ans5  = "在牌桌介面必須坐下之後才能贈送遊戲幣。或者在好友介面您也能最多5次贈送定額的遊戲幣給您的好友。";
    str_help_que6 = "我存在保險箱的遊戲幣丟失了！我該怎麼辦？";  
    str_help_ans6  = "請您在及時在反饋欄中填寫您丟失的遊戲幣的數目和時間，我們會在第一時間為您查證。";
    str_help_que7 = "無法登錄遊戲，怎麼辦？";                    
    str_help_ans7  = "一般來說，進不去遊戲是因為網路不佳，請您檢查網路環境或者嘗試重新啟動遊戲。";
    str_help_que8 = "無法進入房間怎麼辦？";                      
    str_help_ans8  = "一般情況下，進不去房間是由於網路不穩定，請嘗試使用WIFI連接或者重啟遊戲。";           
    str_help_que9 = "付款了但是沒有獲得籌碼？";                  
    str_help_ans9  = "如果您的餘額不足以支付所購買籌碼數量，系統會自動將您的錢存起，當您將差額補齊，系統為自動為您發放籌碼。";
    str_help_que10 = "遊客帳號是什麼？我不注冊就能玩遊戲嗎？";   
    str_help_ans10 = "為了減少您繁瑣的遊戲注冊步驟，使您能夠快速進入到遊戲中。我們提供了自動注冊遊客帳號功能。您第一進入遊戲時，系統就會為您的機器在伺服器上自動完成遊客帳號的注冊。遊客帳號和其他帳號享有同樣的權利和功能，只是一旦您更換了機器，那麼您的遊客帳號上的遊戲幣，經驗，成就等不能轉移。";
    str_help_que11 = "什麼是郵箱帳號？有什麼用怎麼創建？";       
    str_help_ans11 = "郵箱帳號是您的遊客帳號通過綁定您的郵箱後生成的帳號，郵箱帳號可方便您在更換手機或者系統更新等其他原因導致遊客帳戶資訊丟失時，依舊可以使用郵箱帳號登錄。升級郵箱帳號目前完全免費。遊客登錄遊戲時，在遊戲大廳的左上方，可以看到升級郵箱帳號的按鈕。點擊按鈕就並填寫郵箱資訊和密碼就可以升級成為郵箱帳號。";
    str_help_que12 = "每日登錄獎勵由什麼組成？";                 
    str_help_ans12 = "每日登錄獎勵包括簽到獎勵，玩牌獎勵和VIP獎勵。";
    str_help_que13 = "為什麼我獲得的簽到獎勵每天都是不一樣的？"; 
    str_help_ans13 = "因為簽到獎勵根據已經連續登錄的天數，發不同的獎勵。1天200籌碼，2天500籌碼，3天800籌碼，4天1,000籌碼，5天1,500籌碼，6天即以上2,000籌碼。";
    str_help_que14 = "VIP獎勵有多少，怎麼獲得？";                
    str_help_ans14 = "如果您在商城購買了VIP，您將成為我們尊貴的VIP用戶，享受每天的VIP獎勵。根據VIP類型的不同，VIP獎勵也是不同的。\n銅卡VIP：每天5,000\n銀卡VIP：每天10,000\n金卡VIP：每天40,000\n鑽石VIP：每天200,000";
    str_help_level1 = "1.玩牌獲得經驗：";
    str_help_level2 = "贏牌加經驗，輸牌扣經驗。\n在小盲注<1,000的房間內:贏牌加經驗，所加經驗值=（所贏的玩家人數）X2；輸牌時扣1點經驗值。\n在小盲注>=1,000的房間內:贏牌加經驗，所加經驗值=（所贏的玩家人數）X4；輸牌時扣2點經驗值。";
    str_help_level3 = "注：新手期（LV1—LV3）輸牌不扣經驗值。";
    str_help_level4 = "溫馨提示：遊戲規定每日經驗上限值為600，使用雙倍經驗卡則為1,200。";
    str_help_level5 = "2. 坐下牌桌累積時間獲得相應的經驗：";
    str_help_level6 = "牌桌坐下累積時間";
    str_help_level7 = "獲得的經驗值"; 
    str_help_level8 = "注：2小時以上每小時獲得20點經驗值";
    str_help_level9 = "等級"; 
    str_help_level10 = "稱號";         
    str_help_level11 = "本級經驗";
    str_help_level12 ="總經驗"; 
    str_help_level13 ="等級獎勵";  

    str_hall_icon_mall = "郵件";
    str_hall_icon_game = "小遊戲";
    str_hall_icon_acitvity = "活動";
    str_hall_icon_mession = "任務";
    str_hall_icon_more = "更多";
    str_hall_icon_friend = "好友";
    str_hall_icon_course = "教程";
    str_hall_icon_feedback = "反饋";
    str_hall_icon_setting = "設置";
    str_hall_icon_backpack = "背包";
    str_hall_icon_rank = "排名";

    
    str_common_appeal               = "申訴";               --申訴
    str_common_warning              = "警告";               --警告
    str_common_sure                 = "確認";               --確定
    str_common_ban_tip              = "您的賬號(uid:{0})由於違反遊戲規則已觸發封號處罰！請共同維護良好的遊戲環境，如果您認爲我們的措施並不正當合理，請就該問題聯係我們的客服！"; --封號提示

    str_help_login_feedback1 = "請詳細描述您用何種帳號登錄，登錄有什麼提示，以便我們儘快為您解決。";
    str_help_login_feedback2 = "您的郵箱或手機聯系方式";
    str_help_login_feedback3 = "請確認正確的聯系方式，以便我們聯系到您。";
    str_help_login_feedback_error = "你的聯絡方式格式有錯，請更正後再嘗試發送";
    str_help_login_feedback_not_handle = "未處理";
    str_send = "發送";
    str_help_hall_feedback1 = "您在遊戲中遇到任何問題，都可以向我們反饋，我們會以最快的速度為您解答。";
    str_help_hall_feedback2 = "請盡可能提供詳細的支付資訊以方便我們的客服人員快速為您解決問題。";
    str_help_hall_feedback3 = "請盡可能詳細的提供您的郵箱，注冊日期等有效資訊。";
    str_help_hall_feedback4 = "您對遊戲有任何意見或者建議，我們都歡迎您予以反饋，感謝您對我們遊戲的一貫支持。";
    str_help_feedback_sucess = "反饋成功";

    
    str_store_buy_xxx_by				= "購買{0}金幣";				--購買{0}金幣
    str_store_buy_xxx_chips				= "購買{0}籌碼";				--購買{0}籌碼
    str_store_buy_succ				= "發貨成功";				--發貨成功
    str_store_buy_erro				= "正在發貨";				--正在發貨

    str_store_chips_text = "%s籌碼";
    str_store_coalaa_text = "%s金幣";
    str_bankrupt_buy_chips_test = "立即購買";
    str_bankrupt_title = "很遺憾，您破產了！";
    str_bankrupt_desc_text1 = "您獲得%s籌碼的破產救濟金，同時還獲得當日充值優惠一次，立即充值，重振雄風！";
    str_bankrupt_desc_text2 = "您獲得最後一次%s籌碼的破產救濟金，同時還獲得當日充值優惠一次，立即滿血復活，再戰江湖！";
    str_bankrupt_desc_text3 = "輸贏乃兵家常事，不要灰心，我們贈送您當日充值優惠一次。機不可失！";
    str_bankrupt_desc_text4 = "您已經領取完所有破產救濟金了，您可以去商城購買籌碼，每天登錄還有免費籌碼贈送哦！";
    str_store_use = "使  用";
    str_store_no_props = "無道具，請前往商城購買！";
    str_store_buy_long = "購  買";
    str_store_prop_using = "使用中";
    str_store_prop_remain = "剩餘: %s";
    str_store_prop_remain1 = "剩餘: %s 小時";
    str_store_vip_card_name = "VIP卡";
    str_store_big_laba_name = "大喇叭道具";
    str_store_hddj_prop_name = "互動道具";
    str_store_small_laba_name = "小喇叭道具";
    str_store_double_exp_prop_name = "雙倍經驗卡";
    str_store_pop_up_gold_card = "金卡";
    str_store_pop_up_silver_card = "銀卡";
    str_store_pop_up_copper_card = "銅卡";
    str_store_pop_up_diamon_card = "鑽石卡";	
    str_store_user_prop_invite_card = "邀請函";

    str_rank_playerinfo1 = "LV.%s";
    str_rank_playerinfo2 = "排名:%s";
    str_rank_playerinfo3 = "積分:%s";
    str_rank_playerinfo4 = "勝率:%s%%";
    str_rank_playerinfo5 = "UID:%s";
    str_rank_playerinfo6 = "我的好友";
    str_rank_playerinfo7 = "我的道具";
    str_rank_playerinfo8 = "我的禮物";
    str_rank_playerinfo9 = "贈送禮物";
    str_rank_playerinfo10 = "加爲好友";
    str_rank_playerinfo11 = "追蹤";
    str_rank_playerinfo12 = "玩家不在線，無法追蹤",
    str_rank_playerinfo13 = "玩家不在房間內，無法追蹤",
    str_rank_playerinfo14 = "%s場: %s/%s 打牌",
    str_rank_playerinfo15 = "$%s",
    str_rank_playerinfo16 = "贈送",

    str_rank_rankType1  = "資產排行";
    str_rank_rankType2  = "等級排行";
    str_rank_rankType3  = "成就排行";
    str_rank_rankType4  = "賽況排行";
    str_rank_rankCrowd1  = "全部排行";
    str_rank_rankCrowd2  = "好友排行";
    str_rank_myRank = "我的排名:%s";
    str_ran_noFriendTips = "暫無好友"; 
    str_rank_hallRankCrowd1 = "世界榜";
    str_rank_hallRankCrowd2 = "好友榜";

    -- 排行描述所用字符串start -- 
    str_rank_ranking_format_resource_1 = "你現在是全國首富！是眾人敬畏的頭號莊家！";
	str_rank_ranking_format_resource_2 = "在你的牌友裏你的籌碼最多。";
    str_rank_ranking_format_resource_3 = "你現在在撲克經驗最為豐富，是受人尊重的撲克高手！";
    str_rank_ranking_format_resource_4 = "在你的牌友裏你的等級最高。";
    str_rank_ranking_format_resource_5 = "你現在集萬千榮譽於一身，是撲克界的傳奇人物！";
    str_rank_ranking_format_resource_6 = "在你的牌友裏你的成就最多。";
    str_rank_ranking_format_resource_7 = "再獲得{0}籌碼，就可以成為第{1}名。";
    str_rank_ranking_format_resource_8 = "再獲得{0}經驗值，就可以成為第{1}名。";
    str_rank_ranking_format_resource_9 = "再獲得{0}成就點數，就可以成為第{1}名。";
    str_rank_ranking_format_resource_10 = "再獲得{0}籌碼，就可以進入前{1}名。";
    str_rank_ranking_format_resource_11 = "再獲得{0}經驗值，就可以進入前{1}名。";
    str_rank_ranking_format_resource_12 = "再獲得{0}成就點數，就可以進入前{1}名。";
    str_rank_ranking_format_resource_13 = "你現在是打遍天下無敵手";
    str_rank_ranking_format_resource_14 = "在你的牌友裏積分最多";
    str_rank_ranking_format_resource_15 = "再獲得{0}積分，就可以成爲第{1}名";
    str_rank_ranking_format_resource_16 = "再獲得{0}積分，就可以進入前{1}名";
    -- 排行描述所用字符串end -- 

    --寶箱
    str_room_room_activity_treasuer_box_title	= "倒計時寶箱";				--倒計時寶箱
    str_room_treasure_box_finished				= "您今天的寶箱已經全部領取，明天還有哦。";				--計時寶箱已完成
    str_room_treasure_box_not_reward			= "再玩{0}分{1}秒，您將獲得{2}。";				--計時寶箱不可領獎
    str_room_treasure_box_reward				= "恭喜您獲得寶箱獎勵{0}。";				--計時寶箱領獎
    str_room_treasure_box_not_sit_down		    = "坐下才可以繼續計時。";				--計時寶箱未坐下不能領獎
    
--保險箱
    tips = "溫馨提示",
    confirm_btn = "確 定",
    delete_btn = "刪 除",
    cancel = "取 消",
    save = "存 入",
    take_out = "取 出",
    safeBox_psd = "保險箱密碼",
    cancel_psd = "取消密碼",
    change_psd = "修改密碼",
    psd_error = "密碼錯誤",
    set_psd = "密碼設置",
    enter_psd = "請輸入密碼",
    forgot_psd= "忘記密碼",
    safeBox_tips1 = "根據您的需要選擇修改密碼或者取消密碼",
    safeBox_tips2 = "您已成功設置您的保險箱密碼",
    safeBox_tips3 = "溫馨意識：如果您忘記了密碼，可以通過點擊忘記密碼按鈕，向我們反饋找回密碼",
    safeBox_tips4 = "遊戲內資產:",
    safeBox_tips5 = "保險箱內資產:",
    psd_tip1 = "請輸入6-16位數字或字母",
    psd_tip2 = "請再次輸入密碼",
    psd_tip3 = "兩次輸入的密碼不一致！",
    str_bank_password_modify_fail = "修改失敗";
    str_bank_password_cancel_fail = "取消失敗";
    str_bank_password_modify_success = "您已經成功修改您的銀行密碼";				--修改密碼提示
    str_bank_password_cancel_success = "您已經成功取消您的銀行密碼";				--取消密碼提示
    str_login_private_bank_input_money_label				= "請輸入金額";				--請輸入金額
    str_login_save_money_success				= "存款成功";				--存款成功
    str_login_draw_money_success				= "取款成功";				--取款成功
    safeBox_bank_no_money                       = "保險箱暫無存款",
    str_login_fb = "Facebook登錄";
    str_login_email = "郵箱登錄";
    str_login_guest = "遊客登錄";
    str_login_email_title = "郵箱賬戶登錄";
    str_login_email_account = "賬號";
    str_login_email_account_hint = "電子郵箱";
    str_login_email_pwd = "密碼";
    str_login_email_remember_pwd = "記住密碼";
    str_login_email_forgot_pwd = "忘記密碼";
    str_login_email_content = "如果您沒有郵箱賬戶，請先使用遊客賬戶登錄免費升級為郵箱賬戶";
    str_login_email_login = "登錄";
    str_login_email_format_error = "錯誤的郵箱格式，請檢查！";
    str_login_reset_pwd_title = "重設密碼";
    str_login_reset_pwd_content = "臨時密碼會發送至你的電子郵箱，請注意查收！";
    str_login_reset_pwd_commit = "提交";
    str_login_reward = "更多獎勵";
    str_login_company = "深圳東方博雅科技股份有限公司";
    str_login_workgroup = "我愛德州工作組";
    str_login_workgroup2 = "iPoker Workgroup";
    str_login_copyright = "Boyaa Interactive Copyright 2019";

    str_login_close_guess_register="很抱歉，遊客注冊方式已暫停，請您使用郵箱或facebook帳戶注冊"; --很抱歉，遊客注冊方式已暫停，請您使用郵箱或facebook帳戶注冊
    str_login_network_err="哎呀，您的網絡開小差，請檢查下網絡設置吧！"; --哎呀，您的網絡開小差，請檢查下網絡設置吧
    str_login_server_down="親愛的玩家，服務器正在升級維護，目前無法登錄遊戲，給您帶來的不便我們深感抱歉！";--親愛的玩家，服務器正在升級維護，目前無法登錄遊戲，給您帶來的不便我們深感抱歉！
    str_login_restricte_login="抱歉，您有違反遊戲公平的可疑情況，禁止登陸！";--抱歉，您有違反遊戲公平的可疑情況，禁止登陸
    str_login_restricte_register="抱歉，您的注冊量已達上限！";--抱歉，您的注冊量已達上限
    str_login_fb_access_token_err = "抱歉，facebook授權失敗！";
    str_login_close_guess_login="抱歉，遊客登入方式已關閉，請您使用其它登入方式！";--抱歉，遊客登入方式已關閉，請您使用其它登入方式
    str_login_ban_tip = "您的賬號(uid:%s)由於違反遊戲規則已觸發封號處罰！請共同維護良好的遊戲環境，如果您認爲我們的措施並不正當合理，請就該問題聯係我們的客服！"; --封號提示
    str_login_bad_network = "網路不給力，請檢查網路連接是否正常！";				--網路狀況不佳
    str_login_open_wifi_tip = "開啟wifi可以有更好的遊戲體驗哦";
    str_login_login_password_error = "密碼錯誤，請輸入正確的密碼！";				--密碼錯誤，請輸入正確的密碼！
    str_login_login_email_error	= "電子郵箱錯誤，請輸入正確的電子郵箱！";				--電子郵箱錯誤，請輸入正確的電子郵箱！
    str_login_emulator_limit = "模擬器禁止登陸";--模擬器禁止登錄
    str_login_cancle_tip = '你已取消登陸';

    str_logout_entrance = "登出";
    str_logout_title = "確認登出";
    str_logout_content = "您確定要登出此賬號嗎？";
    str_logout_btn_cancel = "取消";
    str_logout_btn_confirm = "確定";

    str_accountUpgrade_mail = "郵箱";
    str_accountUpgrade_verifyCode = "驗證碼";
    str_accountUpgrade_desc = "升級後我們會保留你的遊客賬號數據，讓你更換設備時沒\n有後顧之憂，還可以享受郵箱找回密碼等更多功能！";
    str_accountUpgrade_getVerifyCode = "獲取驗證碼";
    str_accountUpgrade_hadAccount = "已有賬戶";
    str_accountUpgrade_freeUpgrade = "免費升級";
    str_accountUpgrade_passwordAgain = "密碼確認";
    str_accountUpgrade_existAccount = "此帳戶已存在，請選擇其他的電子郵箱。";
    str_accountUpgrade_createAccount_succ               = "恭喜，您已成功升級為郵箱帳戶！";
    str_accountUpgrade_blindAccount_succ               = "恭喜，您已成功綁定郵箱帳戶！請重新登錄！";
    str_accountUpgrade_verifyError1 = "郵箱驗證不通過";  
    str_accountUpgrade_verifyError2 = "查詢失敗，請稍後再試";  
    str_accountUpgrade_verifyError3 = "郵箱已經綁定過了";  
    str_accountUpgrade_verifyError4 = "當天驗證的次數已經用完";        
    
    str_change_pwd_title = "修改賬戶密碼";
    str_change_pwd_new_pwd = "新密碼";
    str_change_pwd_new_pwd_again = "新密碼確認";
    str_change_pwd_commit = "提交";
    str_change_pwd_inconsistent = "兩次填寫的密碼不一致！";
    
    -- 算牌器
    str_cardCalculator_title				= "算牌器";				--算牌器
    str_room_type_probability				= "成牌概率";				--成牌概率
    str_room_card_type				= { --牌型
        [10]= "高牌";
        [9] = "一對";
        [8] = "兩對";
        [7] = "三條";
        [6] = "順子";
        [5] = "同花";
        [4] = "葫蘆";
        [3] = "四條";
        [2] = "同花順";
        [1] = "皇家同花順";
    },
    str_room_leave_table_confirm				= "如果離開座位，您將失去已下注的籌碼！確定離開嗎？";				--是否離開座位
    str_room_leave_table_confirm2				= "您確定要站起並返回大廳嗎？";				--是否離開座位(坐下但未開始遊戲)
    str_room_leave_match_confirm				= "如果離開座位，你將放棄本輪比賽！確定離開嗎？";				--是否離開比賽
    str_room_match_end_notice				    = "比賽已結束,點擊返回大廳";				--是否離開比賽
    str_room_leave_match_confirm3				= "比賽馬上就要開始了,是否要返回大廳？";				--比賽馬上就要開始了,是否要返回大廳?
    str_room_leave_match_str1                   = "繼續等待";  --繼續等待
    
    str_loginReward_all = "今天領取的獎勵 : ";
    str_loginReward_tips = "玩牌越多獎勵越多";
    str_loginReward_login = "登錄獎勵";
    str_loginReward_play = "玩牌獎勵";
    str_loginReward_vip = "VIP獎勵";
    str_loginReward_fb = "Facebook登錄";
    str_loginReward_hadReward = "PC端已領取";

    str_defaultAccount_title = "設置默認賬戶";
    str_defaultAccount_tips = "此操作會將您當前填寫的遊客賬戶設置為本設備\n的默認賬戶，當前遊客賬戶將會被清空。";
    str_defaultAccount_submit = "提交";

    str_refresh = "正在刷新...";

    str_normal_selections_private_room = "私人房";
    str_normal_selections_filter = "篩選";
    str_normal_selections_list = "列表";
    str_normal_selections_table = "牌桌";

    str_normal_selections_low_rank = "初級場";
    str_normal_selections_middle_rank = "中級場";
    str_normal_selections_high_rank = "高級場";
   
    str_normal_selections_fast_title = "快速場";
    str_normal_selections_fast_desc = "出牌時間為10秒。";
    str_normal_selections_must_title = "打必場";
    str_normal_selections_must_desc = "開局前必須下注指定的等額籌碼。";
    str_normal_selections_must_fast_title = "打必快速場";
    str_normal_selections_must_fast_desc = "開局前必須下注指定的等額籌碼，出牌時間為10秒。";
    str_normal_selections_exp_title = "雙倍經驗場";
    str_normal_selections_exp_desc = "玩牌過程中，經驗加倍。";
    str_normal_selections_private_title = "私人房間";
    str_normal_selections_private_desc = "玩家建立的私人房間。";
    str_normal_selections_room_num = "序號";
    str_normal_selections_blind_num = "小/大盲";
    str_normal_selections_carry_num = "最小/最大攜帶";
    str_normal_selections_bonus_num = "積分";
    str_normal_selections_player_num = "在玩人數";

    str_normal_selections_5_player = "5人";
    str_normal_selections_9_player = "9人";
    str_normal_selections_normal = "普通";
    str_normal_selections_fast = "快速";
    str_normal_selections_full = "滿房";
    str_normal_selections_empty = "空房";

    str_normal_selections_search = "搜索";
    str_normal_selections_enter_num = "請輸入數字";
    str_normal_selections_search_error = "請輸入數字";
    str_normal_selections_enter_roomID = "請輸入房間ID";
    str_normal_selections_sb_blind = "小大盲注";
    str_normal_selections_sb_carry = "攜帶";

    str_normal_selections_bonusPop_desc = "    某些盲注級別的場次或者房間，每打完1次牌局，可以獲得一定數量的積分";

    str_store_chips = "籌碼";
    str_store_coin = "金幣";
    str_store_prop = "道具";
    str_store_vip = "貴賓卡";
    str_store_my_prop = "我的道具";
    str_store_buy_history = "購買記錄";
    str_store_account_manage = "帳戶管理";

    str_store_pay_busy = "正在進行購買，請勿重複提交購買請求";
    str_store_create_order = "正在下單，請稍候";
    str_store_create_order_fail = "創建支付訂單失敗";
    str_store_pay_fail = "商品支付失敗";
    str_store_pay_success = "商品購買成功";
    str_store_pay_request_delivery = "重複提交訂單，處理失敗";
    str_store_pay_cancel = "您已取消商品購買";
    str_store_pay_delivery_fail = "商品發貨失敗，請聯繫管理員處理";
    str_store_pay_unsupport = "當前不支持支付";
    str_price_unit = "$";

    str_room_sit_down_send_chips = "您需要坐下才能贈送籌碼";				--您需要坐下才能贈送籌碼
    str_room_sit_down_play_hddj				= "坐下才能使用互動道具";				--坐下才能使用互動道具
    str_room_not_enough_hddj				= "無互動道具，請前往商城購買！";				--無互動道具，請前往商城購買
    str_common_buy				= "購  買";				--購買
    str_room_match_table_send_chips	= "抱歉，比賽場不能贈送籌碼！";				--抱歉，比賽場不能贈送籌碼！
    str_room_match_room_not_play_hddj				= "抱歉，當前比賽場不能使用互動道具";				--抱歉，比賽場不能使用互動道具
    str_userinfo_win_rate = "生涯勝率";
    str_userinfo_max_win = "贏的最大";
    str_room_userinfo_level				= "LV.{0}";				--等級和頭銜
    str_userinfo_highest_asset = "最高資產";
    str_userinfo_best_hand_card = "最大手牌";
    str_userinfo_no_best_hand_card = "快去玩牌獲得最佳牌型吧";
    str_userinfo_achievement = "最近獲得的成就";
    str_userinfo_no_achievement = "您未獲得任何成就";
    str_room_not_enough_chips_to_send				= "抱歉，您的座位籌碼餘額不足，目前無法贈送籌碼";				--座位籌碼餘額不足無法贈送
    str_room_send_chips_too_many_times				= "您贈送籌碼太頻繁，請稍後再試";				--贈送籌碼太頻繁
    --XML_RESOURCE bundle
    str_xml_resource_level_list = 				--經驗配置
    {
        [ 1] = { b = "撲克入門"     ,c = 0      };
        [ 2] = { b = "撲克新手"     ,c = 10     };
        [ 3] = { b = "撲克愛好者"   ,c = 25     };
        [ 4] = { b = "俱樂部選手"   ,c = 161    };
        [ 5] = { b = "俱樂部大師"   ,c = 520    };
        [ 6] = { b = "俱樂部冠軍"   ,c = 1249   };
        [ 7] = { b = "小鎮選手"     ,c = 2499   };
        [ 8] = { b = "小鎮大師"     ,c = 4427   };
        [ 9] = { b = "小鎮冠軍"     ,c = 7198   };
        [10] = { b = "城際選手"     ,c = 10990  };
        [11] = { b = "城際大師"     ,c = 16003  };
        [12] = { b = "城際冠軍"     ,c = 22466  };
        [13] = { b = "國家選手"     ,c = 30658  };
        [14] = { b = "國家大師"     ,c = 40931  };
        [15] = { b = "國家冠軍"     ,c = 53748  };
        [16] = { b = "亞洲選手"     ,c = 69744  };
        [17] = { b = "亞洲大師"     ,c = 89816  };
        [18] = { b = "亞洲冠軍"     ,c = 115264 };
        [19] = { b = "巡迴賽選手"   ,c = 148000 };
        [20] = { b = "巡迴賽大師"   ,c = 190877 };
        [21] = { b = "巡迴賽冠軍"   ,c = 248186 };
        [22] = { b = "世界選手"     ,c = 326416 };
        [23] = { b = "世界大師"     ,c = 435424 };
        [24] = { b = "世界冠軍"     ,c = 590214 };
        [25] = { b = "撲克之神"     ,c = 813671 };
    };
    str_setting_head_pop_save = "保存";
    str_setting_head_pop_male = "男性";
    str_setting_head_pop_female = "女性";
    str_setting_head_pop_bind_mail = "綁定郵箱領取";
    str_setting_head_pop_mail_change_pwd = "修改帳戶密碼";
    str_setting_head_pop_upgrade_account = "已升級為郵箱帳戶";
    str_setting_head_pop_award_chips = "免費贈送3000籌碼";
    str_setting_head_pop_nick_error = "用戶名不能為空";

    str_head_img_uploading= "正在上傳頭像，請稍候";
    str_head_img_upload_limit = "請勿使用超過%s大小的圖片";	--頭像上傳大小超過限制
    str_head_img_upload_success= "頭像上傳成功";				--頭像上傳成功
    str_head_img_upload_failed= "頭像上傳失敗";				--頭像上傳失敗
    -- 經驗配置
    str_level_system_detail = {
        [1]   = {level = "等級",  name = "稱號",         needExp = "本級經驗",targetExp="總經驗", chips ="等級獎勵",      other = {},fontStyle = { color = {r =162,g =215,b= 255} }};
        [2]   = {level = "LV1",   name = "撲克入門",     needExp = "0",       targetExp="0",      chips ="",              other = {}};
        [3]   = {level = "LV2",   name = "撲克新手",     needExp = "10",      targetExp="10",     chips ="",              other = {}};
        [4]   = {level = "LV3",   name = "撲克愛好者",   needExp = "15",      targetExp="25",     chips ="1,000籌碼",     other = {}};
        [5]   = {level = "LV4",   name = "俱樂部選手",   needExp = "136",     targetExp="161",    chips ="1,000籌碼",     other = {}};
        [6]   = {level = "LV5",   name = "俱樂部大師",   needExp = "359",     targetExp="520",    chips ="5,000籌碼",     other = { [1] ="1個高級禮物"; [2] = "5張雙倍經驗卡"}};
        [7]   = {level = "LV6",   name = "俱樂部冠軍",   needExp = "729",     targetExp="1249",   chips ="5,000籌碼",     other = {}};
        [8]   = {level = "LV7",   name = "小鎮選手",     needExp = "1250",    targetExp="2499",   chips ="5,000籌碼",     other = {}};
        [9]   = {level = "LV8",   name = "小鎮大師",     needExp = "1928",    targetExp="4427",   chips ="5,000籌碼",     other = { [1] ="15個互動道具",[2] = "5張雙倍經驗卡"}};
        [10]  = {level = "LV9",   name = "小鎮冠軍",     needExp = "2771",    targetExp="7198",   chips ="5,000籌碼",     other = {}};
        [11]  = {level = "LV10",  name = "城際選手",     needExp = "3792",    targetExp="10990",  chips ="20,000籌碼",    other = { [1] ="3天VIP",      [2] = "30個互動道具"}};
        [12]  = {level = "LV11",  name = "城際大師",     needExp = "5013",    targetExp="16003",  chips ="20,000籌碼",    other = {}};
        [13]  = {level = "LV12",  name = "城市冠軍",     needExp = "6463",    targetExp="22466",  chips ="20,000籌碼",    other = { [1] ="30個互動道具",[2] = "10張雙倍經驗卡"}};
        [14]  = {level = "LV13",  name = "國家選手",     needExp = "8192",    targetExp="30658",  chips ="20,000籌碼",    other = {}};
        [15]  = {level = "LV14",  name = "國家大師",     needExp = "10273",   targetExp="40931",  chips ="20,000籌碼",    other = {}};
        [16]  = {level = "LV15",  name = "國家冠軍",     needExp = "12817",   targetExp="53748",  chips ="50,000籌碼",    other = {}};
        [17]  = {level = "LV16",  name = "亞洲選手",     needExp = "15996",   targetExp="69744",  chips ="50,000籌碼",    other = { [1] ="5天VIP",      [2] = "30個互動道具"}};
        [18]  = {level = "LV17",  name = "亞洲大師",     needExp = "20072",   targetExp="89816",  chips ="50,000籌碼",    other = {}};
        [19]  = {level = "LV18",  name = "亞洲冠軍",     needExp = "25448",   targetExp="115264", chips ="50,000籌碼",    other = { [1] ="30互動道具",  [2] = "15張雙倍經驗卡"}};
        [20]  = {level = "LV19",  name = "巡迴賽選手",   needExp = "32736",   targetExp="148000", chips ="50,000籌碼",    other = {}};
        [21]  = {level = "LV20",  name = "巡迴賽大師",   needExp = "42877",   targetExp="190877", chips ="100,000籌碼",   other = { [1] ="10天VIP",     [2] = "60個互動道具"}};
        [22]  = {level = "LV21",  name = "巡迴賽冠軍",   needExp = "57309",   targetExp="248186", chips ="100,000籌碼",   other = {}};
        [23]  = {level = "LV22",  name = "世界選手",     needExp = "78230",   targetExp="326416", chips ="100,000籌碼",   other = {}};
        [24]  = {level = "LV23",  name = "世界大師",     needExp = "109008",  targetExp="435424", chips ="100,000籌碼",   other = { [1] ="60個互動道具",[2] = "30張雙倍經驗卡"}};
        [25]  = {level = "LV24",  name = "世界冠軍",     needExp = "154790",  targetExp="590214", chips ="100,000籌碼",   other = {}};
        [26]  = {level = "LV25",  name = "撲克傳奇",     needExp = "223457",  targetExp="813671", chips ="500,000籌碼",   other = { [1] ="1個月VIP",    [2] = "100個互動道具"}}    

    };

    str_exp_system_detail = {
        [1] = {time = "牌桌坐下累積時間", exp = "獲得的經驗值" ,fontStyle = { color = {r =162,g =215,b= 255} }};
        [2] = {time = "5分鐘",            exp = "5點經驗值"};
        [3] = {time = "10分鐘",           exp = "10點經驗值"};
        [4] = {time = "15分鐘",           exp = "10點經驗值"};
        [5] = {time = "20分鐘",           exp = "10點經驗值"};
        [6] = {time = "30分鐘",           exp = "20點經驗值"};
        [7] = {time = "60分鐘",           exp = "60點經驗值"};
        [8] = {time = "90分鐘",           exp = "40點經驗值"};
        [9] = {time = "120分鐘",          exp = "40點經驗值"};
    };

    str_setting_title = "設置";
    str_setting_account_title = "帳戶";
    str_setting_logout = "登出";
    str_setting_voice_shake_title = "聲音與震動";
    str_setting_bgm_title = "背景音樂";
    str_setting_voice_title = "聲音";
    str_setting_shake_title = "震動";
    str_setting_other_title = "其他";
    str_setting_auto_sit = "自動坐下";
    str_setting_auto_buy_in = "自動買入";
    str_setting_play_count = "玩牌統計提示";
    str_setting_clear_cache = "清除緩存";
    str_setting_clear_cache_tips = '已清除緩存數據';
    str_setting_score = "喜歡我們，打分鼓勵";
    str_setting_version_name = "當前版本號 %s";
    str_forget_possword_operatr_succeed="操作成功，請留意郵件";--操作成功，請留意郵件
    str_forget_possword_account_wrong = "郵箱帳號不正確";--郵箱賬號不正確
    str_forget_possword_failse_more = "每天限制5次，已超出限制";--每天限制5次，已超出限制
    str_forget_possword_failse = "操作失敗";--操作失敗
    str_forget_possword_user_none = "帳號不存在";--賬號不存在

    
    str_gift_pop_title_3 = {"籌碼禮物", "金幣禮物","我的禮物"};
    str_gift_pop_title_2 = {"籌碼禮物","我的禮物"};
    str_gift_pop_chip_title = {"全部", "精品","節日","娛樂","其他"};
    str_mygift_left_category_item = {"全部", "已過期"};
    str_gift_buy				                = "購買";				--購買
    str_gift_present_to				            = "贈送給：{0}";				--贈送給：{0}
    str_gift_present				            = "贈  送";				--贈  送
    str_gift_sale_overdue_gift				    = "賣出過期禮物";				--賣出過期禮物
    str_gift_use				                = "使  用";				--使  用
    str_gift_buy_long				            = "購  買";				--購  買
    str_gift_buy_for_table				        = "買給牌桌";				--買給牌桌
    str_gift_no_gift_info_hint				    = "當前類別沒有禮物";				--當前類別沒有禮物
    str_gift_no_own_gift_hint				    = "您目前未擁有禮物";				--您目前未擁有禮物
    str_gift_no_own_due_gift_hint				= "您目前未擁過期禮物";				--您目前未擁過期禮物
    str_gift_sale_all_due_gift_hint				= "一鍵出售";				--一鍵出售所有過期禮物
    str_gift_sale_all_due_gift_price_prompt		= "恭喜，您出售禮物共獲得籌碼:{0}";				--一鍵出售所有過期禮物價格
    str_gift_gift_buy_by_self				    = "自購";				--自購
    str_gift_gift_past_due				        = "已過期";				--已過期
    str_gift_glory_obtain_gift				    = "成就禮物";				--成就禮物
    str_gift_gift_sale_succeed				    = "禮物出售成功";				--禮物出售成功
    str_gift_gift_sale_fail				        = "禮物出售失敗";				--禮物出售失敗
    str_gift_expired_days				        = "有效期：{0}";				--有效期：{0}
    str_gift_gift_past_due_price				= "出售價：{0}";				--出售價：{0}
    str_gift_expired_days_forever				= "永久";				--永久
    str_gift_expired_days_num				    = "{0}天";				--{0}天
    str_gift_room_purchase				= "購買禮物";				--購買禮物

    str_gift_gift_msg_arr			= { --禮物提示消息
        [1] = "必須坐下才可以買禮物給牌桌";
        [2] = "禮物資訊加載失敗";
        [3] = "加載當前禮物失敗";
    },
    str_gift_buy_gift_to_table_result_msg				= { --禮物賣給牌桌伺服器返回狀態對應提示
        ["1"] = "禮物購買成功";								--禮物購買成功
        ["0"] = "您的籌碼不足，無法購買該禮物";								--您的籌碼或金幣不足，無法購買該禮物
        ["-1"] = "系統參數錯誤，請通過設置中的反饋聯繫管理員處理";								--系統參數錯誤，請通過設置中的反饋聯繫管理員處理
        ["-2"] = "您所購買的禮物不存在";								--您所購買的禮物不存在
        ["-3"] = "系統錯誤，購買禮物失敗";								--系統錯誤，購買禮物失敗
        ["-5"] = "您未登錄";								--您未登錄	
        ["-6"] = "您的金幣不足，無法購買該禮物";  -- 您的金幣不足，無法購買該禮物
    },
    str_gift_use_gift_result_msg			= { --使用禮物伺服器返回狀態對應提示
        [1] = "禮物使用成功";								--禮物使用成功
        [0] = "您使用的禮物不存在";								--您使用的禮物不存在
        [-1] = "系統參數錯誤，請通過設置中的反饋聯繫管理員處理";								--系統參數錯誤，請通過設置中的反饋聯繫管理員處理
        [-5] = "您未登錄";								--您未登錄
    },
    str_gift_buy_gift_result_msg				= { --購買禮物伺服器返回狀態對應提示
        ["1"] = "禮物購買成功";								--禮物購買成功
        ["0"] = "您的籌碼不足，無法購買該禮物";								--您的籌碼或金幣不足，無法購買該禮物
        ["-1"] = "系統參數錯誤，請通過設置中的反饋聯繫管理員處理";								--系統參數錯誤，請通過設置中的反饋聯繫管理員處理
        ["-2"] = "您所購買的禮物不存在";								--您所購買的禮物不存在
        ["-3"] = "系統錯誤，購買禮物失敗";								--系統錯誤，購買禮物失敗
        ["-5"] = "您未登錄";								--您未登錄
        ["-6"] = "您的金幣不足，無法購買該禮物";  -- 您的金幣不足，無法購買該禮物
    },

    str_mail_pop_title = {"郵 件", "系統消息"};
    str_mail_cell_operate_get = "領取";
    str_mail_cell_operate_fill = "填寫資料";
    str_mail_cell_operate_read = "查看";
    str_phone_format_error = "手機號碼格式錯誤，請輸入正確的手機號碼格式！";
    str_fill_mail = "填寫郵箱";
    str_fill_phone = "填寫手機號碼";
    str_mail = "郵箱：%s";
    str_phone = "電話：%s";
    str_mail_detail_title = "郵件詳情";
    str_mail_get_reward_failed = "領取獎勵失敗";
    str_mail_null_sys_message_tip = "咦，當前沒有新系統消息耶！";
    str_mail_null_mail_message_tip = "咦，當前沒有新郵件耶！";
    str_mail_remain_date_tip = "郵件最多保留7天";
    str_mail_get_date_fmt = "%Y/%m/%d";

    str_safe_box_vip_level_tips = "當你等級達到七級或者成為VIP的時候才能開啟個人銀行哦!";
    str_become_vip = "成為VIP";
    str_save_bank_money_fail = "存錢操作失敗";				--存錢操作失敗
    str_not_sufficien_funds = "餘額不足";

    str_friend_invite = "邀請好友賺籌碼";
    str_friend_invite_fb_title = "FaceBook邀請";
    str_friend_invite_fb_desc = "邀請好友一起加入遊戲吧！";
    str_friend_userinfo_chips = "籌碼數量：";
    str_friend_userinfo_play_num = "玩牌局數：%s";
    str_friend_userinfo_win_rate = "勝率：%s";
    str_friend_trace = "追蹤";
    str_friend_trace_status1 = "玩家不在綫，無法追蹤";
    str_friend_trace_status2 = "打牌";
    str_friend_trace_status3 = "旁觀";
    str_friend_trace_status4 = "閒逛中，無法追蹤";
    str_friend_user_friend_statue_high_level				= "高級場: %s";				--高級場：{0}
    str_friend_user_friend_statue_middle_level				= "中級場: %s";				--中級場：{0}
    str_friend_user_friend_statue_primary_level				= "初級場: %s";				--初級場：{0}
    str_friend_user_friend_statue_private                   = "私人房: %s";                --私人房：{0}
    str_friend_friend_popup_callback				= "成功召回得%s籌碼";				--成功召回得{0}籌碼
    
    str_friend_track_mtt = "錦標賽";--錦標賽
    str_friend_track_sng = "淘汰賽";--淘汰賽
    str_friend_send_chips = "贈送%s籌碼";
    str_friend_send_gift = "贈送禮物";
    str_friend_delete = "刪除";
    str_friend_offline_today = "上次登錄：今天";
    str_friend_offline_days = "上次登錄：%d天前";
    str_friend_offline_weeks = "上次登錄：%d周前";
    str_friend_offline_month = "上次登錄：%d個月前";
    str_friend_offline_years = "上次登錄：%d年前";
    str_friend_callback = "召回";

    str_friend_invite_only_fb = "該功能僅限FB賬戶使用。邀請好友可獲得超豐厚的籌碼獎勵";
    str_friend_invite_fb_invite_desc = "為您推薦了一個既刺激又好玩的撲克遊戲，我給您贈送了%s的籌碼禮包，注冊即可領取，快來和我一起玩吧！";--為您推薦了一個既刺激又好玩的撲克遊戲，我給您贈送了{0}的籌碼禮包，注冊即可領取，快來和我一起玩吧！
    str_friend_invite_cancel				= "您的邀請已經取消";				--您的邀請已經取消
    str_friend_invite_error 				= "發送邀請出錯 %s";				--發送邀請出錯 {0}
    str_friend_invite_success				= "邀請發送成功";				--邀請發送成功

    str_friend_give_chip_success				= "您成功給好友贈送了%s籌碼。";				--贈送籌碼成功
    str_friend_give_chip_too_poor				= "您的籌碼太少了，請去商城購買籌碼後重試。";				--贈送籌碼失敗
    str_friend_give_chip_count_out				= "您今天已經給該好友贈送過籌碼了，請明天再試。";				--贈送籌碼失敗
    str_friend_go_to_store      				= "去商城";				--去商城
    str_friend_delete_friend_success			= "刪除好友成功。";				--刪除好友成功
    str_friend_delete_friend_fail				= "刪除好友失敗，請稍後重試。";				--刪除好友失敗
    str_friend_recall_success   				= "發送成功，好友上線後即可獲贈籌碼獎勵。";				--召回好友成功
    str_friend_recall_repeat     				= "您今天已經成功發送過了，請明天繼續。";				--召回好友重複
    str_friend_recall_fail      				= "發送失敗，請稍後重試。";				--召回好友失敗
    str_room_track_friend_tips				    = "確定將在本局結束後自動追蹤到好友的房間，取消放棄追蹤。";
    str_room_match_room_track_friend_tips1		= "如果您在比賽開始前未回到比賽將視為放棄比賽";	
    str_room_match_room_track_friend_tips2		= "確認在本局結束後放棄比賽追蹤到好友房間嗎？";				--比賽場牌局中追蹤好友提示
    str_room_match_room_track_friend_tips3		= "您確定要放棄比賽追蹤到好友房間嗎？";	
    str_quit_match_tip                          = "您確定要退出比賽嗎";
    
    

    str_achi_destination				= "目標:";				--目標
    str_achi_reward				        = "獎勵:";	
    str_achi_title_achieve				= "成就";	
    str_achi_title_life				    = "生涯";	
    str_achi_title_record				= "戰績";	
    str_achi_title_stic				    = "統計";	
    str_achi_title_data_stic			= "數據統計";	
    str_achi_get_reward				    = "領取";	
    str_glory_reward_claim_success		= "成就獎勵領取成功";				--成就獎勵領取成功提示
    str_glory_reward_claim_fail			= "成就獎勵領取失敗，請稍候重試";				--成就獎勵領取失敗提示

    str_statistic_top_tab1 = "一天";
    str_statistic_top_tab2 = "一周";
    str_statistic_top_tab3 = "一個月";
    str_statistic_top_tab4 = "三個月";
    str_statistic_top_tab5 = "一年";

    str_statistic_content_title_overview = "概況";
    str_statistic_content_title_overview_sub1 = "牌局總數";
    str_statistic_content_title_overview_sub2 = "勝利總數";
    str_statistic_content_title_special = "特殊統計";
    str_statistic_content_title_special_sub_1 = "All in總數";
    str_statistic_content_title_special_sub_2 = "All in獲勝";
    str_statistic_content_title_game = "牌局統計";
    str_statistic_content_title_game_sub_1 = "棄牌總數";
    str_statistic_content_title_game_sub_2 = "看到頭三張牌";
    str_statistic_content_title_game_sub_3 = "看到轉牌";
    str_statistic_content_title_game_sub_4 = "看到河牌";
    str_statistic_content_title_game_sub_5 = "攤牌比牌";
    str_statistic_content_title_win = "贏牌統計";
    str_statistic_content_title_win_sub_1 = "頭三張之前獲勝";
    str_statistic_content_title_win_sub_2 = "頭三張獲勝";
    str_statistic_content_title_win_sub_3 = "轉牌獲勝";
    str_statistic_content_title_win_sub_4 = "河牌獲勝";
    str_statistic_content_title_win_sub_5 = "比牌獲勝";
    str_statistic_content_title_oprate = "操作統計";
    str_oprate_fold = "棄牌";
    str_oprate_check = "看牌";
    str_oprate_call = "跟注";
    str_oprate_raise = "加注";
    str_oprate_anti_raise = "反加注";
    str_statistic_content_title_fold = "棄牌統計";
    str_statistic_content_title_fold_sub_1 = "整局無棄牌";
    str_statistic_content_title_fold_sub_2 = "頭三張之前棄牌";
    str_statistic_content_title_fold_sub_3 = "頭三張棄牌";
    str_statistic_content_title_fold_sub_4 = "轉牌棄牌";
    str_statistic_content_title_fold_sub_5 = "河牌棄牌";
    str_friend_add_friend_success               = "添加好友成功";--添加好友成功

    str_bigWheel_subTitle = "100%中獎，海量好禮等你拿";
    str_bigWheel_item1 = "籌碼100";
    str_bigWheel_item2 = "雙倍經驗卡";
    str_bigWheel_item3 = "籌碼5K";
    str_bigWheel_item4 = "道具15次";
    str_bigWheel_item5 = "經驗值+10";
    str_bigWheel_item6 = "籌碼1K";
    str_bigWheel_item7 = "籌碼500";
    str_bigWheel_item8 = "道具10次";
    str_bigWheel_item9 = "籌碼3K";
    str_bigWheel_item10 = "道具7次";
    str_bigWheel_item11 = "籌碼10M";
    str_bigWheel_item12 = "再來一次";
    str_bigWheel_ruleTitle = "活動規則";
    str_bigWheel_ruleDesc = "“幸運轉轉轉活動”，每天至少有3次抽獎機會，每次絕不落空，最高可贏取一千萬籌碼。點擊“開始抽獎”立即開始吧！";
    str_bigWheel_remain_draw = "剩餘抽獎機會：";
    str_bigWheel_logTitle = "中獎紀錄";
    str_bigWheel_againDraw = "再來一次";
    str_bigWheel_tips_title = "溫馨提示";
    str_bigWheel_tips_content = "你確定使用%s籌碼購買一次轉盤機會嗎？";
    str_bigWheel_not_enought_money = "餘額不足,購買失敗";
    str_bigWheel_no_free_play = "您今天已經沒有“幸運轉轉轉”抽獎次數，請明天再來吧!";
    str_bigWheel_buy_success = "購買成功";
    str_bigWheel_tips_reward = "恭喜你在幸運轉轉轉中抽中獎品“%s”";
    str_bigWheel_help_title = "中獎率";
    str_bigWheel_help_prize = "獎品";
    str_bigWheel_help_probability = "比例";

    str_modify_email_account_pwd_success = "修改密碼成功!";

    str_exit_game_title = "確認退出";
    str_exit_game_content = "退出遊戲？";

    --操作類型
    str_room_operation_type_0 = "等待下一輪";
    str_room_operation_type_1 = "等待下注";
    str_room_operation_type_2 = "棄牌";
    str_room_operation_type_3 = "全下";
    str_room_operation_type_4 = "跟注";
    str_room_operation_type_5 = "小盲注";
    str_room_operation_type_6 = "大盲注";
    str_room_operation_type_7 = "看牌";
    str_room_operation_type_8 = "加注";
    str_room_operation_type_9 = "前注";
    str_room_sit_fail               = "坐下失敗!";               --坐下失敗
    str_room_sit_ip_equal				= "您已違反遊戲公平競技規則，暫時無法坐下！";				--同一IP不能坐下
    str_room_not_enough_chips				= "對不起，您的籌碼餘額不足，請充值。";				--對不起，您的籌碼餘額不足，請充值
    str_room_error_seat				= "對不起，該座位已經有玩家坐下了。";				--對不起，該座位已經有玩家坐下了
    str_room_not_empty_seat				= "沒有空座位，請選擇其他房間。";				--沒有空座位，請選擇其他房間
    str_room_too_much_chips				= "您的資產達到了一個新的臺階，請前往更高級的場次。";				--您的資產達到了一個新的臺階，請前往更高級的場次
    str_room_useer_game_in_current_chip_shortstage				= "您當前攜帶資產不足，無法坐下。您可以去銀行提取或前往商城購買籌碼";				--用戶遊戲中籌碼不足
    str_room_chip_shortstage_go_bank				= "去銀行";				--去銀行
    str_room_not_enough_money				= "對不起，您的籌碼餘額無法在本牌桌買入，請購買籌碼或換桌！";				--餘額不足
    str_room_buy_chips				= "購買籌碼";				--購買籌碼
    str_room_switch_table				= "換桌";				--換桌
    str_room_check				    = "看   牌";		                    	--看牌
    str_room_fold				    = "棄   牌";		                    	--棄牌
    str_room_raise				    = "加   注";		                    	--加注
    str_room_all_in				    = "All in";		                    	--all in
    str_room_confirm				= "確   定";		                    	--確定
    str_room_call			    	= "跟注%s";		                    	--跟注
    str_room_auto_call				= "跟   注%s";	                        --跟注
    str_room_triple			    	= "3倍反加";		                    	--3倍反加
    str_room_half_pool				= "1/2獎池";		                    	--1/2獎池
    str_room_three_quarter_pool		= "3/4獎池";		                    	--3/4獎池
    str_room_all_pool				= "全部獎池";		                    --全部獎池
    str_room_auto_check				= "自動看牌";		                    --自動看牌
    str_room_check_or_fold			= "看或棄";		                    	--看或棄
    str_room_call_any				= "跟任何注";		                    --跟任何注
    str_room_show_hand_card			= "亮出手牌";		                    --亮出手牌
    str_room_info                   = "房間ID:%s  小/大盲注:%s/%s";
    str_room_auto_check				= "自動看牌";			            	--自動看牌
    str_room_check_or_fold			= "看或棄";			                   	--看或棄
    str_room_call_any				= "跟任何注";			            	--跟任何注
     --牌型
    str_room_card_type_1            = "雜牌";
    str_room_card_type_2            = "高牌";
    str_room_card_type_3            = "一對";
    str_room_card_type_4            = "兩對";
    str_room_card_type_5            = "三條";
    str_room_card_type_6            = "順子";
    str_room_card_type_7            = "同花";
    str_room_card_type_8            = "葫蘆";
    str_room_card_type_9            = "四條";
    str_room_card_type_10           = "同花順";
    str_room_card_type_11           = "皇家同花順";
    str_room_show_hand_card			= "亮出手牌";				--亮出手牌
    str_room_room_track_friend_tips	= "確定將在本局結束後自動追蹤到好友的房間，取消放棄追蹤。";				--房間追蹤好友提示
    str_room_wait_next_round				= "請等待下一局開始";				--請等待下一局開始

    str_common_svr_stop_tip			= "伺服器維護升級中，暫時無法連接，請耐心等待伺服器恢復！";				--停服提示
    str_room_not_exist              ="對不起，房間ID不存在";                              --對不起，房間ID不存在
    str_common_user_forbidden		= "您的帳號被禁用，如有疑問，請聯繫管理員或提交反饋！";				--帳號被禁用
    str_common_room_full			= "當前房間旁觀人數已超過旁觀上限，請選擇其他房間！";				--房間人數已滿
    str_common_end		        	= "比賽結束";							--比賽結束
    str_common_no_apply				= "您未報名該比賽";				--您未報名該比賽
    str_common_connect_room_fail	= "進入房間失敗，請返回大廳重新再試！";				--進入房間失敗，請返回大廳重新再試
    str_room_again_enter_room_fail	= "您剛被房間的房主踢出，10分鐘之內不能進入該房間";				--再次進入房間失敗
    str_common_double_login_error	= "您的帳號已經重複登錄，為保護您的財產安全，請及時提交反饋或者聯繫管理員！";				--重複登錄錯誤

    str_chat_common_1=[[大家好，很高興見到各位]];
    str_chat_common_2=[[快點吧，我等到花兒都謝了]];
    str_chat_common_3=[[衝動是魔鬼！淡定！]];
    str_chat_common_4=[[玩太小沒意思]];
    str_chat_common_5=[[All in]];
    str_chat_common_6=[[讓看看牌先嘛]];
    str_chat_common_7=[[風水不好，換個位置]];
    str_chat_common_8=[[走一個，跟了！]];
    str_chat_common_9=[[高手！佩服]];
    str_chat_common_10=[[哇，你搶錢啊！]];
    str_chat_common_11=[[又斷線了，鬱悶！]];
    str_chat_common_12=[[不要吵了，有什麼好吵的，專心玩遊戲]];
    str_chat_common_13=[[下次再來，我要走了]];
    str_chat_common_14=[[太不和諧了吧]];
    str_chat_common_15=[[看來我是你的剋星]];
    str_chat_common_16=[[搞笑了，想棄牌按到加注！]];
    str_chat_common_17=[[這樣都行？人品啊]];
    str_chat_common_18=[[我快被打暈了，能來點好牌嗎]];
    str_chat_common_19=[[各位，不好意思，離開一會]];


    str_chat_network_weak = "網絡較差，請稍後重發！";

    str_room_gold_card_play_emotion = "您必須擁有VIP道具才能使用本組表情";
    str_login_become_vip = "成為VIP";
    str_room_chat_alert_cancel = "取消";
    str_play_emotion_tips = "溫馨提示";
    str_room_sit_down_play_emotion = "您需要坐下才能發送表情";	

    str_superLotto_title = "奪金島";
    str_superLotto_click = "點擊查看詳情";
    str_superLotto_desc0 = "購買成功扣除";
    str_superLotto_desc1 = "2,000";
    str_superLotto_desc2 = "籌碼並累計到總獎池，成下列牌型可獲得相應比例的獎池獎金";

    str_superLotto_get = "獲得";
    str_superLotto_pool = "獎池";

    str_superLotto_auto_buy             = "自動購買";
    str_superLotto_buy_next_round       = "購買下一局";
    str_superLotto_bought_next_round    = "已購買下一局";
    str_superLotto_reward_list          = "獲獎名單";

    str_superLotto_not_in_seat          = "您需要坐下才能購買奪金島！";
    str_superLotto_buy_next_success     = "您已成功購買本局奪金島！";

    str_superLotto_rule_title           = "獲獎條件";
    str_superLotto_rule_desc            = "購買後至本局結束時獲得牌型，即可從獎池中獲得獎金牌型不分大小，多人同時獲得相同牌型則平分獎池。";
    str_superLotto_rule_remark1          = "注：必須";
    str_superLotto_rule_remark2          = "五張公共牌";
    str_superLotto_rule_remark3          = "全部翻出後牌型才生效。玩家主動棄牌或者其他玩家全部棄牌導致牌局提前結束，則牌型無效；玩家必須堅持到比牌環節（不需要獲勝）才可贏得本局奪金島。";

    str_superLotto_reward_title = "恭喜您贏得奪金島";
    str_superLotto_reward_geting = "正在為您領取獎勵…";
    str_superLotto_reward_percent_num = "獲得奪金島%d%%的獎池";
    str_superLotto_reward_pattern = "你的牌型為：";

    str_superLotto_reward_list_title = "獲獎名單";
    str_superLotto_reward_list_win = "贏取：";

    str_superLotto_reward_success = "獎金已發送至您的個人帳戶中";


    str_superLotto_money_not_enough = "場內籌碼不足，請補充籌碼後再購買奪金島！";
    str_superLotto_system_error              = "出了點小問題，請稍後再試。";  

    str_dealer_change_dealer = "換荷官";
    str_dealer_title = "荷官設置";
    str_dealer_set_dealer = "設為我的荷官";
    str_dealer_send_tips = "給小費";
    str_dealer_desc = "每局收取%d%%大盲注作為荷官小費";
    str_dealer_free_service  = "免費服務";               --免費服務
    str_dealer_no_money    = "由於您的場外籌碼不足，無法給荷官小費"; 
    str_dealer_sit_down_send_chips = "您需要坐下才能贈送小費";

    str_room_dealer_speak_array = { --荷官互動
        [1] = "祝您牌運亨通，{0}";
        [2] = "祝您好運連連，{0}";
        [3] = "您人真好，{0}";
        [4] = "真高興能為您服務，{0}";
        [5] = "衷心的感謝您，{0}";
    };

    str_chatPop_edit_hint = "點擊輸入聊天內容";
    str_chatPop_normal_type = "普通聊天";
    str_chatPop_smallSpeaker_type = "小喇叭";
    str_chatPop_bigSpeaker_type = "大喇叭";
    str_chatPop_buy_speaker = "購買喇叭";
    str_room_chat_trumpet_not_enough = "喇叭數量不足";
    str_room_no_small_trumpet = "無小喇叭";				--無小喇叭
    str_room_no_big_trumpet	= "無大喇叭";				--無大喇叭
    str_room_chat_too_quick	= "發言太快，請稍後再發";	
    
    str_private_create_failure = "對不起，創建私人房只對VIP開放，成為VIP還能獲得每日額外籌碼贈送，免費表情，使用個人銀行等權限。";-- 私人房提示開通VIP
    str_private_create_success = "恭喜你創建成功";
    str_private_room_id        = "私人房間ID:%s";
    str_private_create_success_title = "創建成功";
    str_private_create_success_desc ="你可以把房間ID告訴你的朋友，並讓你的朋友搜索該房間，和你一起玩牌。";
    str_private_create_blind_num = "小/大盲注 %s/%s";
    str_private_create_carry_num = "最小/最大攜帶 %s/%s";
    str_private_create_title       = "創建私人房";
    str_private_create_name        = "房間名稱:";
    str_private_create_type        = "房間類型:";
    str_private_create_blind_carry = "盲注/攜帶:";
    str_private_create_player_num  = "玩牌人數:";
    str_private_create_speed       = "出牌速度:";
    str_private_create_password    = "房間密碼:";
    str_private_create_name_desc   = "%s的房間";
    str_private_pwd_input_tips     = "房間ID為%s的私人房，需要輸入密碼才可以進入，請輸入房間密碼。";
    str_private_input_pwd          = "請輸入房間密碼：";
    str_private_motify_pwd         = "修改密碼";
    str_private_pwd                = "私人房密碼：";
    str_private_input_new_pwd      = "輸入新密碼:";                          
    str_private_input_pwd_placeholder  = "輸入最多16位字符";
    str_private_motify_pwd_placeholder = "輸入最多16位字符，留空則不設密碼";
    str_private_pwd_error       = "您輸入的密碼有誤，請重新輸入";
    str_private_room_not_exist  = "對不起，房間ID不存在";
    str_private_input_pwd_again = "請重新輸入密碼";
    str_private_player_five     = "5人";
    str_private_player_nine     = "9人";
    str_private_speed_quickly   = "快速（10秒）";
    str_private_speed_normal    = "普通（20秒）";
    str_private_pwd_format_err  = "你輸入的格式有誤，密碼最多16位字符，且只能是數字或者字母";
    str_private_create_buyin_fail  = "您的籌碼低於準備創建房間的最小買入，請前往商城購買籌碼再創建你的私人房間。";	
    str_private_room_no_password   = "無密碼";
    str_private_motify_pwd_success = "密碼修改成功";
    str_private_motify_pwd_failure = "密碼修改失敗";
    str_private_owner_leave_room   = "房主關閉了私人房間，該房間將在這輪牌局結束後關閉。";
    str_private_owner_close_room   = "房主已經離開，房間已被解散";--私人房房主離開後，回到大廳的彈框
    str_private_room_dismiss_operator = "您確定要解散當前房間嗎？確認解散後，房間將會在牌局結束後關閉。";--解散房間

        
    -- 3.2.0mtt
    str_new_mtt_help_title = "MTT規則說明";
    str_new_mtt_help_desc_title = "什麼是MTT？";--什麼是mtt
    str_new_mtt_help_desc_content = "MTT是Multi-Table Tournament的縮寫，中文全稱為多桌錦標賽，指的是在多張桌上同時進行的比賽，桌子會隨著選手的不斷淘汰進行合並。最終，錦標賽會減少到一張桌子而進行決賽，當比賽只剩下最後一個人有籌碼時，冠軍產生，比賽結束！";
    str_new_mtt_help_rule_title = "MTT規則";--mtt規則
    str_new_mtt_help_rule_content = "1、參賽人數低於人數限制，比賽將會取消，返還報名費和服務費；\n2、每場比賽玩家會獲得用於本場比賽計數的籌碼，本籌碼不等同於遊戲幣；\n3、前注（Ante）：每局開始前強制下注的籌碼；\n4、加買籌碼（Rebuy）：部分比賽開始後在指定盲注級別內，若手中籌碼≤初始籌碼時，可花費報名費再次買入初始的籌碼值；\n5、最終加買（Addon）:部分比賽在指定盲注級別時可進行最終加買，增加手中比賽的籌碼量；\n6、比賽將按照退出比賽順序取名次，第一個籌碼輸完的玩家即是最後一名，以此類推，如果有同時被淘汰的玩家，則將一次按照牌力、開始時籌碼高低定位名次；\n7、比賽設有退賽功能，開賽前取消或未按時參賽的玩家，將只返還報名費；\n8、未設置延遲報名的比賽，開賽時僅1名玩家在場，比賽取消，其他玩家無法再延遲進入；\n\n祝君好運！";

    str_hall_tournament_apply_succ				= "您已成功報名，請準時參加比賽。";				--報名成功提示
    str_hall_tournament_apply_fail				= "報名失敗";				--報名失敗
    str_hall_tournament_apply_succ1				= "報名成功";				--報名成功
    str_hall_tournament_apply_tip1				= "對不起，報名已截止。";				--對不起，報名已截止。
    str_hall_tournament_apply_tip2				= "對不起，報名名額已滿。";				--對不起，報名名額已滿。
    str_hall_tournament_apply_tip3				= "對不起，您未滿足報名條件。";				--對不起，您未滿足報名條件。
    str_hall_tournament_apply_tip4				= "報名失敗，請稍後重試。";				--報名失敗，請稍後重試。
    str_hall_tournament_apply_same_ip				= "你違反了遊戲公平原則，不可以再報名比賽。";				--相同ip不能報名
    str_hall_tournament_apply_not_enough_by				= "您的金幣數額不足，請獲取更多的金幣再來參賽！";				--金幣不足
    str_hall_tournament_apply_not_enough_chip				= "您的籌碼數額不足，請獲取更多的籌碼再來參賽！";				--籌碼不足
    str_hall_tournament_apply_not_enough_score				= "您的積分數額不足，快去高級場競技贏取積分吧！";				--積分不足
    str_hall_tournament_apply_not_enough_level              = "您的等級不夠";--您的等級不夠
    str_hall_tournament_track_error				            = "出了點小問題，請稍後再試。";				--追蹤用戶失敗
    str_hall_tournament_apply_not_enough_score2				= "您已經在高級場!";				--您已經在高級場!
    str_common_enter_match_room_tip2_while_playing2				= "您正在玩牌中，是否在本局結束後進入高級場玩牌？";--您正在玩牌中，是否在本局結束後進入高級場玩牌？
    str_common_enter_mtt_lobby_while_playing				= "您確定要立即結束當前牌局前往MTT嗎?";				--您確定要立即結束當前牌局前往MTT嗎？

    str_new_mtt_list_my_ticket = "您擁有{0}張門票";--您擁有{0}張門票
    str_new_mtt_list_my_point = "比賽積分 {0}";--比賽積分 x{0}
    str_new_mtt_list_my_chip = "籌碼 {0}";--籌碼 x{0}
    str_new_mtt_list_my_coin = "卡拉幣 {0}";--卡拉幣 x{0}
    str_new_mtt_list_my_point1 = "您有積分{0}";--您有積分{0}
    str_new_mtt_list_my_chip1 = "您有籌碼{0}";--您有籌碼{0}
    str_new_mtt_list_my_coin1 = "您有卡拉幣{0}";--您有卡拉幣{0}
    str_new_mtt_list_free = "免費";--免費
    str_new_mtt_list_apply = "報名";--報名
    str_new_mtt_list_cancel = "取消報名";--取消報名
    str_new_mtt_list_not_cancel = "不取消了";--不取消了
    str_new_mtt_list_enter = "進入";--進入
    str_new_mtt_list_watch = "旁觀";--旁觀
    str_new_mtt_list_result = "查看結果";--結果
    str_new_mtt_list_not_open = "未開放";--未開放
    str_new_mtt_list_open_tips = "賽前{0}小時開放";--賽前{0}小時開放
    str_new_mtt_help_rules = "1.固定時間開始比賽，當參賽人數小於最低開賽人數時，比賽將被取消。\n2.每場比賽玩家會獲得用來計數的籌碼（本籌碼不等同於遊戲籌碼或或金幣），該籌碼只用於本場比賽的計數。\n3.前注（ante）：比賽進行過程中，每局開始前強制每位玩家自動下注若幹籌碼，即為前往。\n4.重買籌碼（rebuy）：在配置了可rebuy的比賽開始後的某個盲注級別前，當玩家手裏籌碼小於等於初始籌碼時，玩家可點擊重購籌碼按鈕花費報名費再次買入初始的籌碼值，不同的比賽可重買的次數不定，當玩家手裏籌碼為0即將被淘汰出賽時，也可通過rebuy復活。\n5.增購籌碼（add-on）：在配置了可add-on的比賽的某個盲注級別時間段內，玩家可點擊增購籌碼按鈕花費報名費再次買入若幹籌碼值，不同的比賽可增購的次數不定，當玩家手裏籌碼為0即將被淘汰時，也可通過add-on復活。\n6.按照玩家退出比賽順序取名次，第一個籌碼輸完的玩家即是最後一名，依次類推，如果有2位以上參賽者於同一局牌被淘汰，則將一次按照牌力、開始時籌碼定位名次，牌力大者排名在前，開始時籌碼多者排名在前。\n7.當比賽裏只剩下最後一名玩家時比賽結束，最後一名玩家即是冠軍。\n8.為提高比賽激烈程度，錦標賽比賽過程中盲注會逐步提升。\n9.優先使用門票報名，籌碼報名（參賽費+服務費，如[1000+100]）預期不參賽將僅退還參賽費。";--mtt規則
    str_new_mtt_help_red_rules = "10.如果報名人數沒有達到最低報名人數要求，則系統不開賽，返還玩家服務費和報名費。\n11.如果比賽開始的時候，只有1個玩家進場，則直接結束比賽，其他玩家無法再延遲進入。";--10.如果報名人數沒有達到最低報名人數要求，則系統不開賽，返還玩家服務費和報名費。\n11.如果比賽開始的時候，只有1個玩家進場，則直接結束比賽，其他玩家無法再延遲進入。
    str_new_mtt_apply_ticket = "門票 x{0}";--門票
    str_new_mtt_match_wait = "等待開始";--等待開始
    str_new_mtt_match_end = "比賽已結束";--比賽已結束
    str_new_mtt_match_on = "比賽進行中";--比賽進行中
    str_new_mtt_less_of_money			= "您的餘額不足";						--您的餘額不足
    str_new_mtt_raise_time_num = "{0}秒";--{0}秒
    str_new_mtt_game_state_rank = "排名:{0}";--排名:{0}
    str_new_mtt_game_state_ante = "前注:{0}";--前注:{0}
    str_new_mtt_game_state_raise = "漲盲時間: {0}秒";--漲盲時間:{0}秒
    str_new_mtt_game_state_blind = "盲注:{0}";--盲注:{0}
    str_new_mtt_result_rank = "恭喜你在本次比賽中獲得第{0}名";--恭喜你在本次比賽中獲得第{0}名
    str_new_mtt_all_rebuy_time = "本場次提供{0}次rebuy賽制";--本場次提供{0}次rebuy賽制
    str_new_mtt_left_rebuy_time = "你還有{0}次rebuy機會";--你還有{0}次rebuy機會
    str_new_mtt_rebut_max_num = "可重購比賽，次數:{0}次";--可重購比賽，次數:{0}次
    str_new_mtt_addon_max_num = "可增購比賽，次數:{0}次";--可增購比賽，次數:{0}次
    str_new_mtt_cancel_apply_tip = "取消報名後，將只返回您報名費，不返還服務費";--取消報名後，將只返回您報名費，不返還服務費
    str_new_mtt_cancel_apply_sure = "你確定要取消報名嗎";--你確定要取消報名嗎
    str_new_mtt_ok = "確定";--確定
    str_new_mtt_cancel = "取消";--取消
    str_new_mtt_name = "賽事名稱";--賽事名稱:
    str_new_mtt_apply_fee = "參賽費用";--參賽費用:
    str_new_mtt_apply_time = "比賽時間";--比賽時間:
    str_new_mtt_apply_inspire = "比賽開始前將在遊戲內提醒您\n祝您手氣如虹";--比賽開始前將在遊戲內提醒您\n祝您手氣如虹
    str_new_mtt_today = "今天";--今天
    str_new_mtt_tomorrow = "明天";--明天
    str_new_mtt_the_day_after_tomorrow = "後天";--後天
    str_new_mtt_coming = "即將開始";--即將開始
    str_new_mtt_delay_enter = "延遲進入";--延遲進入
    str_new_mtt_on = "進行中";--進行中
    str_new_mtt_end = "已結束";--已結束
    str_new_mtt_main = "我的比賽";--已結束
    str_new_mtt_quite = "退出比賽";--退出比賽
    str_new_mtt_back = "返回比賽";--返回比賽
    str_new_mtt_quite_tips = "您是否準備退出比賽，退出比賽後將無法再次進入比賽";--您是否準備退出比賽，退出比賽後\將無法再次進入比賽
    str_new_mtt_lv = "級別";--級別
    str_new_mtt_bline = "盲注";--盲注
    str_new_mtt_ante = "前注";--前注
    str_new_mtt_raise_time = "漲盲時間";--漲盲時間
    str_new_mtt_match_detail = "比賽詳情";--比賽詳情
    str_new_mtt_rank_no_data = "當前沒有資訊";--當前沒有資訊
    str_new_mtt_no_result = "獎勵正在計算中";--獎勵正在計算中
    str_new_mtt_rank_index = "名次";--名次
    str_new_mtt_reward = "獎勵";--獎勵
    str_new_mtt_fixed_reward = "保底";--保底
    str_new_mtt_dynamic_reward = "動態";--動態
    str_new_mtt_reward_rate = "參賽人數*{0}";--參賽人數*{0}
    str_new_mtt_delay_tip = "開賽後{0}分鐘";--開賽後{0}分鐘
    str_new_mtt_rule_apply_fee = "報名費用:  ";--報名費用:
    str_new_mtt_rule_pool = "比賽獎池:  ";--比賽獎池:
    str_new_mtt_rule_fixed = "保底獎池:  ";--保底獎池:
    str_new_mtt_rule_apply_num = "參賽人數:  ";--參賽人數:
    str_new_mtt_rule_reward_rate = "獲獎人數:  ";--獲獎人數:
    str_new_mtt_rule_time = "比賽時間:  ";--比賽時間:
    str_new_mtt_rule_delay_time = "延遲進入:  ";--延遲進入:
    str_new_mtt_rule_origal = "初始籌碼:  ";--初始籌碼:
    str_new_mtt_rule_player_limit  = "人數限制:  ";
    str_new_mtt_add_on_title = "addon服務";--addon服務
    str_new_mtt_add_on_pool = "獎池:{0}";--獎池:
    str_new_mtt_add_on_rank = "排名:{0}/{1}";--排名:
    str_new_mtt_add_on_tip = "本場次提供1次-addon賽制";--本場次提供1次-addon賽制
    str_new_mtt_add_on_tip1 = "額外增加當前籌碼";--額外增加當前籌碼
    str_new_mtt_add_on_spent = "花費:";--花費:
    str_new_mtt_add_on_getchips = "購買:";--購買:
    str_new_mtt_add_on_ok = "增加籌碼";--增加籌碼
    str_new_mtt_add_on_on = "不用了";--不用了
    str_new_mtt_total_pool = "總獎池";--總獎池
    str_new_mtt_rebuy_title = "比賽-rebuy服務";--比賽-rebuy服務
    str_new_mtt_rebuy_goto_match_again = "再次加入比賽！";--再次加入比賽！
    str_new_mtt_get_rwward_title = "領獎";--領獎
    str_new_mtt_get_rwward_succ = "成功獲得";--成功獲得
    str_new_mtt_get_rwward_chip = "籌碼";--籌碼:
    str_new_mtt_get_rwward_by = "金幣";--金幣:
    str_new_mtt_get_rwward_other = "其他";--金幣:
    str_new_mtt_get_rwward_point = "積分";--積分:
    str_new_mtt_get_rwward_exp = "經驗";--經驗:
    str_new_mtt_sign_up_point = "{0} 積分";--積分:
    str_new_mtt_sign_up_ticket = "門票";--門票
    str_new_mtt_result_title = "比賽結果";--比賽結果
    str_new_mtt_result_beat = "比賽結果";--比賽結果
    str_new_mtt_result_fighting = "祝您下次好運，加油！";--祝您下次好運，加油！
    str_slot_lucky_card = "今日幸運數字：%s";
    str_slot_win = "你贏了：%s";
    str_slot_auto_play = "自動";
    str_slot_prize = "頭獎：%s";
    str_slot_luck_rew = "搖中今日幸運數字可獲%s倍獎勵";
    str_slot_luck_tips = "幸運數字不區分花色";
    str_slot_win_untips = "中獎不再提示";	
    str_slot_reward_odds = "牌型與獎金賠率";
    str_slot_bonus = "您的獎金 = 投入的籌碼 × 獎金賠率";	
    str_slot_mag = "%s倍";
    str_slot_luckwin = "<color=#c4d6ec>搖中今日幸運數字可獲</c><color=#fafe93>%s倍</color><color=#c4d6ec>獎勵</c>";	
    str_slot_luck_winmoney = "<color=#c4d6ec>恭喜你搖中了幸運數字，獲得</c><color=#fafe93>%s</color><color=#c4d6ec>籌碼獎勵！</c>";
    str_slot_win_money = "<color=#c4d6ec>恭喜，您在搖搖樂中贏得了</c><color=#fafe93>%s</color><color=#c4d6ec>籌碼！</c>";
    str_slot_fail1 = "<color=#c4d6ec>抱歉，您的場外籌碼餘額不足，無法玩搖搖樂</c>";
    str_slot_success = "<color=#c4d6ec>搖搖樂已準備就緒，祝您中獎多多！</c>";
    str_slot_reconnect = "<color=#c4d6ec>抱歉，由於網絡問題，搖搖樂正在努力重連中！</c>";
    str_slot_fail2 = "<color=#c4d6ec>抱歉，搖搖樂未準備就緒，請稍後再重試！</c>";
    str_slot_fail3 = "<color=#c4d6ec>抱歉，搖搖樂出現異常，請稍後再重試！</c>";
    str_slot_fail4 = "抱歉，網絡異常！";
    str_new_mtt_result_mail_tips = "您的獎勵稍後以郵件的形式發放\n給您。請繼續加油";--您的獎勵稍後以郵件的形式發放\n給您。請繼續加油
    str_new_mtt_result_commite = "提交";--提交
    str_new_mtt_waiting_for_other = "等待其他玩家rebuy({0})";--等待其他玩家rebuy({0})
    str_new_mtt_detail_rule = "比賽規則";--比賽規則
    str_new_mtt_detail_bline = "盲注規則";--盲注規則
    str_new_mtt_detail_reward = "獎勵分配";--獎勵分配
    str_new_mtt_detail_rank = "排名";--排名
    str_new_mtt_no_rank_data = "暫無排名數據";--暫無排名數據
    str_new_mtt_hall_label1 = "賽事編號";--賽事編號
    str_new_mtt_hall_label2 = "賽事資訊";--賽事資訊
    str_new_mtt_hall_label3 = "開賽時間";--開賽時間
    str_new_mtt_hall_label4 = "報名費用";--報名費用
    str_new_mtt_hall_label5 = "報名中";--報名中
    str_new_mtt_hall_label4 = "報名費用";--報名費用
    str_new_mtt_hall_label6 = "熱門賽事";--熱門賽事
    str_new_mtt_hall_label7 = "您未報名任何賽事!";--您未報名任何賽事!
    str_new_mtt_hall_label8 = "多人錦標賽";--多人錦標賽
    str_new_mtt_reward_calculating = "獎勵計算中...";--獎勵計算中...
    str_new_mtt_short_of_ticket = "門票不足,請選用其他方式報名";--門票不足,請選用其他方式報名
    str_new_mtt_cancel_apply_succ = "取消報名成功";--取消報名成功
    str_new_mtt_apply_need_num = "報名人數要求:";--報名人數要求:
    str_new_mtt_rule_before_time = "提前進場:";--提前進場:
    str_new_mtt_rule_before_time_num = "提前{0}分鐘進場";--提前{0}分鐘進場
    str_new_mtt_rule_before_time_num1 = " (  延遲入場剩餘";-- (已進行2分鐘,延遲入場還有3分鐘)
    str_new_mtt_had_applyed = "已報名";--已報名
    str_new_mtt_not_inmatch = "您未參賽";--MTT房間內排行榜未參賽提示
    str_common_enter_match_room_tip				= "您報名的多人比賽將在{0}分鐘後開始，是否現在進場？";				--您報名的多人錦標賽將在5分鐘後開始！
    str_common_enter_match_room_tip_while_playing				= "您報名的多人比賽將在{0}分鐘後開始，是否在本局結束後進場？";				--您報名的多人錦標賽將在5分鐘後開始！
    str_common_enter_match_room_tip2_while_playing				= "您報名的多人比賽將在{0}秒後開始，是否在本局結束後進場？";				--您報名的多人錦標賽將在5秒後開始！
    str_new_mtt_month= "月";--月
    str_new_mtt_day= "日";--日
    str_room_goon_buy_chips				= "購買繼續";				--購買繼續
    str_room_cancle_buy_chips			= "放棄";				--放棄
    str_room_goon_addon_chips			= "增加籌碼";				--增加籌碼
    str_room_cancle_addon_chips			= "放棄增加";				--放棄增加
    str_rebuy_buy_long_7				= "購       買";				--購       買 
    str_rebuy_cost_long_7				= "花       費";				--花       費 
    str_rebuy_over_num			    	= "剩餘次數";				--剩餘次數 
    str_rebuy_total_num				    = "( 總共{0}次 )";				--( 總共{0}次 )
    str_room_tournament_start_time_tip				= "距離比賽開始還有 {0}";				--距離比賽開始還有 01:43
    str_room_tournament_start_time_tip2				= "({0}分鐘後開賽)";				--({0}分鐘後開賽)
    str_room_tournament_start_time_tip3				= "({0}小時後開賽)";				--({0}小時後開賽)
    str_room_tournament_start_time_tip1				= "({0}秒後開賽)";				--({0}秒後開賽)
    str_room_tournament_start_time_tip4				= "({0}天後開賽)";				--({0}天後開賽)
    str_new_mtt_get_reward_palyer_num	= "錢圈人數: ";							--錢圈人數;
    str_room_match_start				= "比賽開始，祝您好運！";				--比賽開始，祝您好運！
    str_room_info_match				= "前注:{0} 小/大盲注:{1}/{2} 我的排名:{3}";				--比賽場的房間資訊前注：{0} 小/大盲注: {0}/{1}  我的排名: {2}
    str_new_mtt_enter_fail_reson_1		= "因為報名人數未達到要求，比賽結束";	--因為報名人數未達到要求，比賽結束
    str_new_mtt_enter_fail_reson_2		= "坐下的人數小於2，比賽結束";			--坐下的人數小於2，比賽結束
    str_new_mtt_add_chips_succ			= "成功增加{0}籌碼";					--增加{0}籌碼成功
    str_hall_tournament_switch_table_tip			= "換桌中...";					--換桌中...
    str_room_blind_chang				= "下一輪盲注增加為:{0}/{1}";				--下一輪盲注增加為:20/40

    str_sng_lobby_title = "淘汰賽";
    str_sng_lobby_score_lack = "跟上一名相差{0}分";
    str_sng_lobby_income = "本月賽事收入";
    str_sng_lobby_total_entries = "累計參賽{0}次";
    str_sng_lobby_title_tips = "{0}人坐滿即玩";	
    str_sng_lobby_mark = "推薦";
    str_sng_lobby_tips ="%s人坐滿即玩";
    str_sng_lobby_five_changed				= "已切換到5人桌";				--已切換到5人桌
    str_sng_lobby_nine_changed				= "已切換到9人桌";				--已切換到9人桌
    str_sng_lobby_not_enough_money          ="您的籌碼數額不足，請獲取更多的籌碼再來參賽！";
    str_sng_lobby_buy_chips                 ="購買";
    str_sng_lobby_cancel                    = "取消";
    str_sng_lobby_confirm                   = "確認";
    str_sng_lobby_entry_tips_title          = "溫馨提示";
    str_sng_lobby_no_nine_table          = "暫無 9 人桌";
    str_sng_lobby_rule_tips                 = "若在比賽開始前離開，系統只返還90%的報名費！";
    str_sng_lobby_help_pop_title            = "單桌淘汰賽規則";
    str_sng_lobby_help_pop_rule             = "規則：比賽開始後,每人分配10,000籌碼,初始盲注為50/100.每隔五分鐘盲注自動翻倍，直至決出第一名。";
    str_sng_lobby_help_pop_tips             = "若在比賽開始前離開,系統只返還90%的報名費";

    str_sng_reward_pop_username             = "%s";
    str_sng_reward_pop_reward_tips          = "恭喜，您獲得了第%s名";
    str_sng_reward_pop_play_again           = "再賽一場";
    str_sng_reward_pop_back                 = "返回";
    str_sng_reward_pop_share                = "分享";
    str_sng_result_pop_title                = "比賽結果";
    str_sng_result_pop_rank_tips            = "您獲得了第%s名!";
    str_sng_result_pop_result_tips          = "很遺憾您已被淘汰!";
    str_sng_room_center_notic               = "請再等待%s人即可開賽";
    str_sng_result_title                    = "比賽結果";
    str_sng_result_rank                     = "您獲得了第%s名!";
    str_sng_match_end                       = "比賽已經結束！";

    str_fb_share_success                    = "FB分享成功!";
    str_fb_share_cancel                     = "FB分享取消!";
    str_fb_share_failed                     = "FB分享失敗!";

    str_fb_share_other_account              = "抱歉，分享功能僅限Face book帳戶使用";

    -- 新手教程 start --
    str_beginner_tutorial_msg = { --新手教程禮包獲取文字提示
	    [1] = "歡迎來到德州撲克專業版的新手教程，在這裏你將學到德州撲克的基本玩法。完成教程還能夠得到豐厚的獎勵哦！";
	    [2] = "桌面上會分三輪連續發出五張公共牌（五張牌所有玩家都可見）。";
	    [3] = "亮牌時，在七張手牌中選出五張組成最大的牌，再與其他玩家鬥牌，最大者獲勝。";
	    [4] = "牌型的大小順序是按右圖中所示：";
	    [5] = "現在我們用真實的牌局來感受一下如何進行德州撲克。";
	    [6] = "遊戲開始，每個玩家得到兩張手牌。現在輪到你操作了，你可以選擇跟注棄牌加注，手裏牌不錯，選擇跟注看看吧。";
	    [7] = "玩家A選擇了跟注，玩家B選擇了看牌，此時這一輪下注完成。荷官發出三張公共牌。此時你的最大牌型是一對。";
	    [8] = "翻牌後玩家A選擇了看牌，玩家B選擇了看牌。其他玩家都選擇了看牌，你也看牌比較穩妥。";
	    [9] = "此時這一輪下注完成了。荷官翻出轉牌。是一張10，此時你手中最大的牌型是三條，不錯的牌。";
	    [10] = "玩家A加注200籌碼，玩家B不想玩這手牌選擇棄牌。那麼她之前下注的籌碼將計入總獎池，無法拿回。現在該你操作了，跟注吧！";
	    [11] = "最後一張河牌發出來了。哇，我們拿到了四條！非常大的牌，基本上玩家A的牌很難大過我們。";
	    [12] = "玩家A選擇加注300籌碼。輪到你操作了。這麼大的牌，選擇加注，拉動加注條進行ALL IN吧！";
	    [13] = "玩家A選擇了跟注，誰是最後的贏家我們拭目以待。YES，你的四條贏了玩家A的兩對！";
	    [14] = "點擊荷官可以更換荷官及贈送荷官籌碼。點擊禮物可以贈送別人禮物！";
    };

	str_beginner_tutorial_tips      				= "皇家同花順>同花順>四條>葫蘆>同花>順子>三條>兩對>一對>高牌";
	str_beginner_tutorial_quit_btn_text				= "退出教程";				--退出
	str_beginner_tutorial_quit_desc_text			= "完成引導可獲贈豐厚獎勵，您確定要退出新手引導嗎？";				--退出彈框描述
	str_beginner_tutorial_complete_btn_text			= "完成教程";				--完成
	str_beginner_tutorial_poker_order_title			= "牌型大小順序";				--牌型順序標題
	str_beginner_tutorial_poker_rule_title			= "● 遊戲規則 ●";				--規則標題
	str_beginner_tutorial_poker_rule_poker_num		= "<color=#C4D5EF>◆用牌：除大小王外的</color><color=#F0EB87>52張撲克牌</color><color=#C4D5EF>。</color>";				--牌數規則
	str_beginner_tutorial_poker_rule_player_num		= "<color=#C4D5EF>◆</color><color=#F0EB87>遊戲人數：2~9人</color><color=#C4D5EF>，2人即可開始遊戲，最多9人。</color>";				--人數規則
	str_beginner_tutorial_poker_rule_win			= "<color=#C4D5EF>目標：</color><color=#F0EB87>贏取獎池中籌碼。</color><br/><color=#C4D5EF>有兩種方法：</color><br/><color=#C4D5EF>    ◆1：在鬥牌中</color><color=#F0EB87>牌型大者勝出。</color><br/><color=#C4D5EF>    ◆2：在下注時</color><color=#F0EB87>讓其他玩家棄牌。</color>";				--贏牌規則
	str_beginner_tutorial_popup_title				= "新手引導";				--新手教程彈框標題
	str_beginner_tutorial_start_desc_text			= "歡迎登錄德州撲克專業版遊戲，我們為您準備了新手教程，通過新手教程能夠快速瞭解遊戲玩法，還能得到以下獎勵：";				--新手教程獎勵描述
	str_beginner_tutorial_complete_desc_text		= "恭喜您完成了新手教程，獲得了以下獎勵：";				--新手教程完成描述
	str_beginner_tutorial_popup_chips				= "{0}籌碼";				--新手教程籌碼獎勵
	str_beginner_tutorial_popup_exp					= "{0}經驗";				--新手教程經驗獎勵
	str_beginner_tutorial_popup_funny_props			= "{0}互動道具";				--新手教程互動道具獎勵
	str_beginner_tutorial_popup_quit_btn			= "退出教程";				--退出新手教程
	str_beginner_tutorial_popup_start_btn			= "開始教程";				--開始新手教程
	str_beginner_tutorial_popup_receive_btn			= "領取獎勵";				--領取獎勵
	str_beginner_tutorial_public_card_tips_one		= "第一輪";				--公共牌提示第一輪
	str_beginner_tutorial_public_card_tips_two		= "第二輪";				--公共牌提示第二輪
	str_beginner_tutorial_public_card_tips_three	= "第三輪";				--公共牌提示第三輪
	str_beginner_tutorial_reveive_reward_seccuess	= "祝賀您成功領取新手教程獎勵！";				--領取獎勵成功
	str_beginner_tutorial_reveive_reward_fail   	= "對不起新手教程獎勵領取失敗。";				--領取獎勵失敗
	str_beginner_tutorial_player_a_name				= "玩家a";				--玩家a
	str_beginner_tutorial_player_b_name				= "玩家b";				--玩家b
    str_beginner_tutorial_step                         = "第{0}步";            --第幾步
    
    str_tutoria_popup_title				= "新手引導";				--新手教程彈框標題
    str_tutoria_start_desc_text				= "歡迎登錄德州撲克專業版遊戲，我們為您準備了新手教程，通過新手教程能夠快速瞭解遊戲玩法，還能得到以下獎勵：";				--新手教程獎勵描述
    str_tutoria_complete_desc_text				= "恭喜您完成了新手教程，獲得了以下獎勵：";				--新手教程完成描述
    str_tutoria_popup_chips				= "{0}籌碼";				--新手教程籌碼獎勵
    str_tutoria_popup_exp				= "{0}經驗";				--新手教程經驗獎勵
    str_tutoria_popup_funny_props				= "{0}互動道具";				--新手教程互動道具獎勵
    -- 新手教程 end   --
    -- 新手獎勵 start --
    str_login_novice_reward_title				= { --第{0}天
        [1] = "第1天";
        [2] = "第2天";
        [3] = "第3天";
    };
    str_login_novice_reward_btn_text				= "領取新手禮包";				--領取新手禮包
    -- 新手獎勵 end --

    str_new_mtt_detail_tab_race_info    = "比賽信息";
    str_new_mtt_detail_tab_blind_struct = "盲注結構";
    str_new_mtt_detail_tab_reward       = "獎勵";
    str_new_mtt_detail_tab_rank         = "排名";

    str_new_mtt_detail_rebuy            = "加買情況:  ";
    str_new_mtt_detail_addon            = "最終加買:  ";
    str_new_mtt_detail_rebuy_time       = "可重購{0}次";
    str_new_mtt_detail_addon_time       = "可加買{0}次";
    str_new_mtt_detail_player_limit_num = "{0} ~ {1}人";

    str_new_mtt_detail_dynamic_desc       = "本場比賽採用動態獎池，獎勵分配將根據參賽人數，rebuy，addon情況進行計算，延遲報名結束後產生最終獎勵分配表";
    str_new_mtt_detail_additional            = "額外獎勵：";
    str_new_mtt_detail_unit_chips               = "{0}籌碼";
    str_new_mtt_detail_unit_colaa               = "{0}金幣";
    str_new_mtt_detail_unit_point                = "{0}積分";
    str_room_operation_timeout_text				= "您已暫離，點擊螢幕回到遊戲。{0}後將自動站起!";				--您已暫離，點擊螢幕回到遊戲。{0}後將自動站起！

    str_new_mtt_detail_rank_index          = "名次";
    str_new_mtt_detail_rank_player          = "玩家";
    str_new_mtt_detail_rank_chips          = "籌碼";

    str_new_mtt_result_defeat       = "共擊敗";
    str_new_mtt_result_defeat_player = "名玩家";

    str_new_mtt_result_ob = "繼續旁觀";
    str_new_mtt_result_back = "返回大廳";
    str_new_mtt_result_good_luck= "祝你下次好運，加油！";
    str_new_mtt_result_defeat_offset = "再擊敗{0}人，就能進入錢圈啦~";
    str_new_mtt_other_result_rank = "第{0}名";
    
    
    -- str_new_mtt_detail_anti       = "前注";
    -- str_new_mtt_detail_rise_time      = "漲盲時間";
    str_room_game_review_players = "玩家";
    str_room_game_review_handcard = "手牌";
    str_room_game_review_publiccard = "頭三張牌";
    str_room_game_review_publiccard1 = "頭三張牌前";
    str_room_game_review_turncard = "轉牌";
    str_room_game_review_rivercard = "河牌";
    str_room_game_review_public = "公共牌";

    str_room_card_type_result			= { --牌型
        [1] = "雜牌";
        [2] = "高牌";
        [3] = "一對";
        [4] = "兩對";
        [5] = "三條";
        [6] = "順子";
        [7] = "同花";
        [8] = "葫蘆";
        [9] = "四條";
        [10] = "同花順";
        [11] = "皇家同花順";
    };
    
    str_max = "最大";
    str_min = "最小";
    str_max_buy = "最高買入";
    str_min_buy = "最低買入";
    str_current_money = "當前資產:%s";
    str_auto_buyIn = "籌碼不足時自動買入";
    str_buyIn = "買入坐下";
    str_keybackpop_title = "溫馨提示";
    str_keybackpop_describe1 = "您可以通過以下方式獲得免費籌碼";
    str_keybackpop_describe2 = "明天再來登錄還有更多獎勵，確定退出嗎？";
    str_keybackpop_wheelLabel = "幸運轉轉轉";
    str_keybackpop_dailyTaskLabel = "每日獎勵";
    str_keybackpop_newestActLabel = "最新活動";
    str_keybackpop_backGame = "返回遊戲";
    str_keybackpop_loginout = "確定退出";

    str_social_config = {              --分享配置
        ["dailyLogin"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我在#德州撲克專業版#累計簽到了{0}天，獲得了{1}的獎勵，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/get2.png";
            link    = shareStoreUrl;
        };
        
        ["dailyTask"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我在#德州撲克專業版#完成了{0}任務，獲得了{1}的獎勵，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/rank.png";
            link = shareStoreUrl;
        };

        ["newestAct"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "#德州撲克專業版#{0}活動火爆進行中，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/gift.png";
            link = shareStoreUrl;
        };
        
        ["actWheelNoReward"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "推薦一個非常好玩的遊戲，#德州撲克專業版#，每天都有幸運轉轉轉可以免費贏取籌碼道具哦！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/lottery10m.png";
            link = shareStoreUrl;
        };

        ["actWheelGotReward"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我剛剛在#德州撲克專業版#幸運轉轉轉中獲得了{0}，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/lottery10m.png";
            link = shareStoreUrl;
        };

        ["gloryGot"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我剛剛在#德州撲克專業版#獲得了%s成就，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/rankinvite.png";
            link = shareStoreUrl;
        };
        
        ["statWin"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我剛剛在#德州撲克專業版#贏了{0}籌碼，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/allin.jpg";
            link = shareStoreUrl;
        };

        ["changeDealer"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "強烈推薦遊戲#德州撲克專業版#，居然還可以換荷官，滿足你不一樣的口味！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/heguanfeedpic1.png";
            link = shareStoreUrl;
        };

        ["levelUp"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我剛剛在#德州撲克專業版#成功升級到了{0}級，快來和我一起玩吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/newlevelup.png";
            link = shareStoreUrl;
        };

        ["cardType"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我在#德州撲克專業版#中以一手{0}牌型橫掃全場，敢來挑戰我嗎？";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/{0}.png";
            link = shareStoreUrl;
        };

        ["winningStreak"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我在#德州撲克專業版#中連贏了{0}局，實力是用事實證明的，敢來挑戰我嗎？";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/{0}.png";
            link = shareStoreUrl;
        };

        ["collectGift"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "我在#德州撲克專業版#中收集到一個非常珍貴的玩偶{0}，你也想獲得嗎？";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/collect_gift_{0}.png";
            link = shareStoreUrl;
        };

        ["newYearRedPack"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "想和你分享這個塞得滿滿的紅包吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/newyearfeed.jpg";
            link = shareStoreUrl;
        };

        ["ActDiamondFeed"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "太強了，我在鑽石大贏家獲得了{0}！羨慕我吧！";
            picture = "https://pclpthik02-static.akamaized.net/ipk/images/1/bigfeed/DiaMond.png";
            link = shareStoreUrl;
        };

        ["matchHall"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "太棒了！您在比賽中獲得了第{0}名，得到{1}籌碼！";
            picture = "http://cfuncstatic-a.akamaihd.net/static/ipokertw/images/bigfeed/taotaisai.png";
            link = shareStoreUrl;
        };

        ["iniviteCode"] = {
            name = "德州撲克專業版";
            caption = "最專業最好玩的德州撲克遊戲";
            message = "你的好友{0}在你的邀請下進入遊戲，獲得邀請獎勵{1}";
            picture = "http://cfuncstatic-a.akamaihd.net/static/ipokertw/images/bigfeed/s_inviteCode.png";
            link = shareStoreUrl;  
        };
    };

    str_friend_invite_friends_page_title				= "邀請打牌";				--邀請好友頁面標題
    str_friend_already_invited  				        = "已邀請";			    	--已邀請
    str_friend_invited          				        = "邀請";			    	--邀請
    str_friend_friend_popup_invite_succ 				= "邀請發送成功..";			--邀請好友成功
    str_friend_chips                    				= "籌碼:%s";				    --籌碼
    str_friend_inGame_invite_tip	        			= "好友 %s 邀請您一起打牌！接受後將在本局結束後自動換房。";				--遊戲中收到好友邀請
    str_friend_outGame_invite_tip	        			= "好友 %s 邀請您一起打牌！立即接受？";				--不在遊戲中收到好友邀請
    str_friend_invite_accept    	        			= "接受";				--接受
    str_activity_newest_empty				= "暫無活動";				--暫無活動
    
    str_receive_invite_tips                             = "您已切換到玩家 %s 所在的房間";

    -- 热更新
    str_update_tips = "更新提示",
    str_confirm_update = "確定更新",
    str_update_loading = "加載資源中...",

    str_task_recieve_reward = "領取獎勵";
    str_task_chip = "籌碼";
    str_task_vip1 = "VIP銅卡";
    str_task_vip2 = "VIP銀卡";
    str_task_vip3 = "VIP金卡";
    str_task_vip4 = "VIP鉆石卡";
    str_task_funFace = "互動道具";
    str_task_double_exp= "雙倍經驗";
    str_task_running = "進行中";
    str_task_finish_tips = "恭喜完成任務";
    str_task_gift = "禮物";
    str_task_finished = "已完成";
    
    str_task_trans = 
    {
        {[1] = "奖",[2]="獎"},
        {[1] = "励",[2]="勵"},
        {[1] = "筹码",[2]="籌碼"},
        {[1] = "礼",[2]="禮"},
        {[1] = "级",[2]="級"},
        {[1] = "场",[2]="場"},
        {[1] = "计",[2]="計"},
        {[1] = "胜",[2]="勝"},
        {[1] = "发",[2]="發"},
        {[1] = "条",[2]="條"},
        {[1] = "请",[2]="請"},
        {[1] = "动",[2]="動"},
        {[1] = "参",[2]="參"},
        {[1] = "夺",[2]="奪"},
        {[1] = "岛",[2]="島"},
        {[1] = "1000",[2]="1,000"},
        {[1] = "1500",[2]="1,500"},
        {[1] = "2000",[2]="2,000"},
        {[1] = "3000",[2]="3,000"},
        {[1] = "5000",[2]="5,000"},
        {[1] = "游戏",[2]="遊戲"},
        {[1] = "一",[2]="一"},
    
    };
    str_common_tutoria_popup_quit_btn				= "退出教程";				--退出新手教程
    str_common_tutoria_popup_start_btn				= "開始教程";				--開始新手教程
    str_common_tutoria_popup_receive_btn			= "領取獎勵";				--領取獎勵
    str_room_game_review_pop_up_title				= "牌局回顧";				--牌局回顧
    str_room_game_review_pop_up_no_review_tips		= "暫無牌局記錄";				--暫無牌局記錄
    
    str_privacy_policy_title = "隐私政策";
    str_privacy_policy_agree = "同 意";
    str_common_number				= "%s次";				    --次數

}

return BYString