--[[
    多语言文本文件，所有项目中使用到的文字需要定义于该文本中，使用key-value形式，便于后续多语言翻译
    文件命名格式统一为String_xx,其中xx为语言简称，请使用国际通用简称。
    ------------------------------------------------------------------
    使用规范：
    1、BYString下字段使用key = value形式，value只可以为String，否则无法对接翻译后台
    2、key命名格式：
        str_模块名_自定义名，BYString内字段key都必须遵循该命名规范，便于管理
    3、新增加文字时，请先查找是否已存在相同文本，避免出现重复文本。
    4、使用方法：调用全局方法GameString.get(key)方法，可以获得相对应的文本
    -------------------------------------------------------------------
    author:{JanRoid}
    time:2018-10-25 15:44:47
]]

local shareStoreUrl = "http://pclpthik01.boyaagame.com/api/facebook/applink"

local BYString = {

    --common
    str_common_php_request_error_msg	= "Mạng của bạn chưa kết nối.";				--您的網路似乎沒有連接
    str_common_currency_multiple		= "10000";				--貨幣倍數
    str_common_too_rich				= "Chip của bạn đã vượt qua {0}, xin đi phòng cao cấp hơn thách thức!";				--筹码太多,不能进入新手场
    str_common_too_poor				= "Chip của bạn chưa đủ {0}, xin vui lòng đi sân lính mới rèn luyện lĩnh vực mới làm quen!";				--筹码太少且等级不足,不能在高级场坐下
    str_common_go_now				= "Đi ngay";				--馬上去
    str_common_know				= "Biết rồi";				--知道了
    str_common_network_problem          = "Không thể kết nối, hãy kiểm tra lại mạng";   --網路問題
    str_common_network_to_set           = "Đi cài đặt";   --設置網路
    str_common_network_recieve_fail          = "Nhận thưởng thất bại";
    str_common_retry		    		= "Thử lại";				--重試
    str_common_cancel  = "Hủy";
    str_common_confirm = "Xác nhận";
    str_common_back    = "Trờ về";
    str_common_share    = "Chia sẻ";
    str_common_get_new_glory				= "Chúc bạn thu được thành tích mới.";				--獲得新成就
    str_common_get_new_message = "Nhận được tin mới, bạn có thể kiểm tra tại hòm thư.";
    

    str_common_chip = "Chíp";
    str_common_reward = "Phần thưởng";

    -- 单位
    str_unit_wan = "萬";
    str_unit_yi = "億";
    str_unit_thousand = "K";
    str_unit_million = "M";
    str_unit_billion = "B";

    str_help_title = "Trợ giúp";
    str_help_title1 = "Vấn đề hot";
    str_help_title2 = "Luật chơi";
    str_help_title3 = "Quy tắc cấp bậc";
    str_help_title4 = "Phản hồi";
    str_help_title5 = "VĐ thanh toán";
    str_help_title6 = "VĐ tài khoản";
    str_help_title7 = "GT đăng nhập";
    str_help_title8 = "Lỗi game" ;
    str_help_title9 = "Ý kiến";
    str_help_title10 = "Kiểu bài lớn bé";
    str_help_title11 = "Quy tắc game";
    str_help_title12 = "Đặt cược";
    str_help_title13 = "Danh từ";
    str_help_title14 = "Cách được EXP";
    str_help_title15 = "Thể lệ cấp bậc";
    str_help_waiting = "chưa xử lý";
    str_help_replied = "Đã trả lời";
    str_help_card_dec1= "Sảnh chúa>Sảnh thông>Tứ quý>Cù lủ>Đồng chất>Sảnh>Ba lá>Hai đôi>Một đôi>Cao bài";
    str_help_card_tit1= "1.Sảnh chúa";
    str_help_card_dec2= "Sảnh mạnh nhất khi đồng chất";
    str_help_card_tit2= "2.Sảnh thông";    
    str_help_card_dec3= "Sảnh đồng chất";
    str_help_card_tit3= "3.Tứ quý";       
    str_help_card_dec4= "Bốn lá bài cùng số  1 lá bài lẻ";
    str_help_card_tit4= "4.Cù lủ";       
    str_help_card_dec5= "3 lá bài cùng số và 1đôi";
    str_help_card_tit5= "5.Đồng chất";       
    str_help_card_dec6= "Cùng một loại hoa văn";
    str_help_card_tit6= "6.Sảnh";       
    str_help_card_dec7= "Sảnh có hoa văn khác nhau";
    str_help_card_tit7= "7.Ba lá";       
    str_help_card_dec8= "3 lá bài cùng số và hai lá bài lẻ";
    str_help_card_tit8= "8.Hai đôi";       
    str_help_card_dec9= "Hai đôi và một lá bài lẻ";
    str_help_card_tit9= "9.Một đôi";       
    str_help_card_dec10= "Một đôi";
    str_help_card_tit10= "10.Cao bài";      
    str_help_card_dec11= "Cao bài";  
    str_help_rule_dec1 = "Dùng bài";
    str_help_rule_dec2 = "52 tờ bài poker trừ hai joker";
    str_help_rule_dec3 = "Số người game";
    str_help_rule_dec4 = "2-9 người, 2 người thì có thể chơi,tối đa 9 người.";
    str_help_rule_dec5 = "Kiểu mẫu game-kiểu mẫu vô hạn chế";
    str_help_rule_dec6 = "Kiểu mẫu vô hạn chế tức là trong quá trình game không có hạn chế gì,là rủi ro càng lớn nhưng giàu tính thách thức và tính kích thích trong kiểu mẫu game Poker Texas.";
    str_help_rule_dec7 = "Phương cách so bài";
    str_help_rule_dec8 = "Dùng 2 tờ bài tay kết hợp với 5 bài chung,chọn 5 bài,tổ thành nhóm kiểu bài lớn nhất,so sánh lớn nhỏ với nhà chơi khác.";
    str_help_rule_dec9 = "Như bức tranh:";
    str_help_rule_dec10 = "Bài chung";
    str_help_rule_dec11 = "Và";
    str_help_rule_dec12 = "Người chơi A\n Bài tay";
    str_help_rule_dec13 = "Người chơi B\n Bài tay";
    str_help_rule_dec14 = "Thua";
    str_help_rule_dec15 = "Thắng";
    str_help_rule_dec16 = "Người chơi A\n Kiểu bài tốt nhất";
    str_help_rule_dec17 = "Người chơi B\nKiểu bài tốt nhấ";
    str_help_rule_dec18 = "Ba lá";
    str_help_rule_dec19 = "Sảnh";
    str_help_rule_dec21 = "Đặt cược ván thứ nhất:";    
    str_help_rule_dec22 = "Phát bài tay,bắt đầu đặt cược thứ nhất.Hệ thống tự động đặt cược cho người chơi small blind và người chơi big blind.Nhà chơi khác có thể chọn theo cược,thêm cược hoặc bỏ bài,đặt cược lần này kết thúc đến lúc mức đặt cược của cả người chơi giống nhau. (Người chơi mà Chip không đủ phải đặt tất cả mới có thể tham gia so sanh bài sau.))";
    str_help_rule_dec23 = "Đắt cược thứ hai:";    
    str_help_rule_dec24 = "Phát 3 bài chung(giờ bài),bắt đầu đặt cược ván thứ hai.Từ small blind bắt đầu lần lượt đặt cược,người chơi khác có thể chọn theo cược,thêm cược hoặc bỏ bài,đặt cược lần này kết thúc đến lúc mức đặt cược của cả nhà chơi giống như. (Người chơi mà Chip không đủ phải đặt tất cả mới có thẻ tham gia so sánh bài sau.)";
    str_help_rule_dec25 = "Đặt cược ván thứ ba:";    
    str_help_rule_dec26 = "Phát bài chung thứ tư(turn card),bắt đầu đặt cươc thứ ván ba.Quy tắc đăt cược như trên.";
    str_help_rule_dec27 = "Đặt cược ván thứ tư:";    
    str_help_rule_dec28 = "Phát bài chung thứ nam(river card),bắt đầu đặt cươc thứ tư.Quy tắc đăt cược như trên."; 
    str_help_rule_dec29 = "So bài:";   
    str_help_rule_dec30 = "So bài sau 4 lần đặt cược.";  
    str_help_noun_tit1 = "Nhà cái";   
    str_help_noun_des1 = "Game thứ nhất bắt đầu tùy cơ chọn nhà cái,nếu game thứ hai không có ai đến vào và không có ai trong game thứ nhất rời ra,thì theo hướng đồng hồ nhà cái của game thứ nhất chọn nhà cái.Nếu có người đến vào hoặc người nào rời ra thì có nghĩa là game mới bắt đầu,do hệ thống tùy cơ chọn nhà cái.";
    str_help_noun_tit2 = "Small blind"; 
    str_help_noun_des2 = "Small blind là người chơi nguồi sau nhà cái theo hướng đồng hồ.Sau game bắt đầu,người chơi small blind được bài mà hệ thống tự động phát,và do hệ thống đại biểu người chơi tự động đặt cược một nửa của mức thấp nhất trong phòng này.";
    str_help_noun_tit3 = "Big blind"; 
    str_help_noun_des3 = "Big blind là người chơi ngồi sau small blind theo thứ tự hướng đồng hồ.Sau game bắt đầu,người chơi big blind do hệ thống đại biểu người chơi này tự động đặt cược của mức thấp nhất trong phòng này.";
    str_help_noun_tit4 = "Phát bài";   
    str_help_noun_des4 = "Từ người chơi small blind bắt đậu phát bài,theo thứ tự hướng đồng hồ,mỗi người mỗi lần một tờ bài,trực tiếp đến mỗi ngườ đều có 2 tờ bài kết thúc.";
    str_help_noun_tit5 = "Đốt bài";   
    str_help_noun_des5 = "Trước khi phát bài,theo quy tắc game thì cần đốt một tờ bài,tức là lấy bài trên nhất để hủy bỏ,rồi tiếp tục phát bài." ;
    str_help_noun_tit6 = "Bài tay";   
    str_help_noun_des6 = "Bài phát cho người chơi riêng là bài tay,chỉ cho người chơi tự mình xem đươc,và dùng phương thức cho nhà chơi xem được trong khu vưc người chơi.";
    str_help_noun_tit7 = "Bài chung"; 
    str_help_noun_des7 = "Theo tiến hành của game,bày 5 tờ bài trên bàn mà có thế dùng với bài tay là bài chung.";
    str_help_noun_tit8 = "Đặt cược";     
    str_help_noun_des8 = "Khi dến người chơi thao tác,người chơi này có thể đặt một số chip vào game theo ý của mình.";
    str_help_noun_tit9 = "Theo";     
    str_help_noun_des9 = "Theo là đăt cươc giống như với người chơi trước.Khi theo chỉ xem được số cần theo,không được thay đổi số,và số biểu hiện là số tăng tương đương,thì còn cần theo bao nhiêu.Nếu chip Texas của người chơi thiếu với số cần theo,thì không được theo chỉ đươc all in(hết cược).";
    str_help_noun_tit10 = "Bỏ bài";   
    str_help_noun_des10 = "Bỏ cơ hội tiếp tục chơi.";
    str_help_noun_tit11 = "Qua bài";   
    str_help_noun_des11 = "Không làm gì qua bài đến người chơi sau,và giữ quyền lợi đặt cược.Chỉ trong trưởng hợp không cần theo cược mới có thể qua bài.Ví dù trong trưởng hợp tất cả người chơi trước đều qua bài hoặc bỏ bài.Nếu trong người chơi trước có một người đặt cược thì không đươc qua bài.";
    str_help_noun_tit12 = "Thêm cược";   
    str_help_noun_des12 = "Trên cơ sở người chơi trước đặt cược,theo,thêm cược,tăng gia nhiều chip.Trên cơ sở người chơi trước đặt cươc hoặc theo hoăc thêm cược,người chơi sau mới có thể thêm cươc.Nhưng nếu chips Texas của người chơi vượt qua số cần theo,không đủ thêm cược đến mức số cần thấp nhất,thì không được thêm cươc chỉ được all in(hết cược).";
    str_help_noun_tit13 = "All IN";   
    str_help_noun_des13 = "Là một lần đặt tất cả chip còn lại.khi một người chưa đủ chip Texas có thể đặt cả chip còn lại.Nếu có người all in,gà chủ có lẽ sẽ chia thành một gà phó.Số giải thưởng của gà phó chỉ bao gồm chip mà mỗi người từ game bắt đậu đến theo sau bàn ấy all in vượt qua người chơi all in đăt được.Nếu game sau bàn ấy all in vẫn tiếp tục,thì bàn ấy nếu là người thắng thì có quyền thắng được gà chủ,nhưng không thắng được chip Texas mà sau bàn ấy all in nhà chơi khác đặt được.Trong tình hình này,người chơi có bài lớn thứ hai sẽ thắng đươc gà phó sau all in,thì là chip Texas còn lại.";
    str_help_noun_tit14 = "Thành thủ";   
    str_help_noun_des14 = "Lớn bé thành thủ là lớn nhỏ kiểu bài cuối cùng của mình.Trong giai đoạn show down,mỗi nhà chơi chọn 5 tờ bài tốt nhất trong 7 tờ bài(2 tờ bài tay của mình và 5 tờ bài chung)tổ thành thành thủ tốt nhất của mình.Thành thủ lớn nhất thắng.Đây có thể là 2 tờ bài tay của người chơi và 3 tờ bài chung,hoăc 1 tờ bài tay với 4 tờ bài chung.Lúc khi ngay cả 5 tờ bài chung đều là thành thủ tốt nhất của mỗi người,thì có thể chia đều gà.Mỗi thành thủ có 5 tờ bài.";
    str_help_que1 = "Tôi hết chip nhưng vẫn muốn chơi thì làm thế nào?";                            
    str_help_ans1  = "Bạn có thể đi mua chip trong shop, hoặc tham gia sự kiện và làm nhiệm vụ để kiếm được nhiều chip miễn phí.";
    str_help_que2 = "Tại sao tôi thưởng thưởng bị đẩy ra hoặc ko kết nối được?";            
    str_help_ans2  = "Xin vui lòng kiểm tra mạng của bạn trước.";
    str_help_que3 = "Tại sao tôi ko tặng chip cho bạn khác được?";      
    str_help_ans3  = "Trong sảnh có thể tặng 5 lần chip cho bạn và bạn ngồi xuống trên bàn cũng tặng chip được.";
    str_help_que4 = "Chip trong ngân hàng của mình bị mất, phải làm thế nào?";                  
    str_help_ans4  = "Xin bạn viết rõ số chip và thời gian cụ thể bị mất phản hồi kỹ cho chúng tôi.";
    str_help_que5 = "Chip Xu có tác dùng gì?";                  
    str_help_ans5  = "Xu là chip của Poker Pro.VN, có thể mua quà và đạo cụ, qua mua mới có.";
    str_help_que6 = "Tại sao tôi không đăng nhập vào game được?";  
    str_help_ans6  = "Xin bạn vui lòng kiểm tra mạng của bạn, hoặc thử xem mở máy tính lại xem.";
    str_help_que7 = "Không vào được phòng phải làm sao?";                    
    str_help_ans7  = "Có lẽ là do mạng của bạn ko ổn dẫn đến, xin bạn kết nối mạng lại hoặc mở máy tính lại xem.";
    str_help_que8 = "Không vào được phòng chơi?";                      
    str_help_ans8  = "Thông thường nếu không vào được phòng, bạn có thể kiểm tra lại kết nối mạng hoặc đăng nhập lại game.";           
    str_help_que9 = "Đã bị trừ tiền nhưng ko nhận được chip?";                  
    str_help_ans9  = "Nếu tiền của bạn ko đủ mua Chip hoặc Xu bạn muốn mua，hệ thống sẽ lưu giữ tiền cho bạn, khi bạn nạp tiền thêm hệ thống sẽ tự động phát chip cho bạn.";
    str_help_que10 = "Tài khoản du khách là gì? ko cần đăng ký thì có thể chơi game?";   
    str_help_ans10 = "Tài khoản du khách có chức năng và quyền lợi giống nhau với các tài khoản khác nhưng ngoài khi bạn đổi thiết bị hoặc thăng cấp phiên bản thiết bị của mình, chip cấp hoặc exp ko được chuyển ra.";
    str_help_que11 = "Tài khoản Coalaa là tài khoản thế nào? phải lập thế nào?";       
    str_help_ans11 = "Tài khoản Coalaa là tài khoản của quý khách được mở sau khi sử dụng email để đăng kí, tài khoản coalaa tiện lợi cho việc người chơi khi đổi điện thoại hoặc khi hệ thống nâng cấp bị mất đi dữ liệu, hoàn toàn có thể sử dụng tài khoản coalaa để đăng nhập. Nâng cấp tài khoản coalaa hiện tại miễn phí hoàn toàn. Khi người chơi đăng nhập vào trò chơi, ở góc bên trái giao diện trò chơi có thể nhìn thấy nút nâng cấp tài khoản coalaa, click vào nút đó và điền tài khoản email và password là có thể nâng cấp thành công tài khoản Coalaa.";
    str_help_que12 = "Các loại phần thưởng của thưởng đăng nhập";                 
    str_help_ans12 = "Phần thưởng đăng nhập hàng ngày bao gồm thưởng đăng ký, thưởng chơi bài, thưởng FB và thưởng VIP.";
    str_help_que13 = "Vì sao phần thưởng đăng nhập hàng ngày không giống nhau?"; 
    str_help_ans13 = "Vì phần thưởng đăng nhập sẽ thay đổi theo ngày đăng nhập liên tục. 1 ngày 200k, 2 ngày 500k, 3 ngày 800k, 4 ngày 1M, 5 ngày 1.5M, 6 ngày trở lên 2M.";
    str_help_que14 = "Phần thưởng FB là gì?";                
    str_help_ans14 = "Phần thưởng FB là những bạn chơi dùng tài khoản FB đăng nhập, mỗi ngày có thể lĩnh thưởng 2M.";
    str_help_level1 = "1.Chơi bài được Exp:";
    str_help_level2 = "Thắng bài thêm Exp, thua bài giảm Exp.\nTrong phòng small blind < 10M:Thắng bài thêm Exp,số tăng Exp=(dân số người chơi thắng)X2;\nkhi thua bài giảm 1 Exp.Trong phòng small bind>=10M:Thắng bài thêm Exp, số thêm Exp=(dân số nhà chơi thắng)X4;khi thua bài giảm 2 Exp.";
    str_help_level3 = "Lưu ý:thời kỳ người mới(LV1-LV3),thua bài không giảm Exp.";
    str_help_level4 = "Nhắc yêu:Trò chơi quy định,hàng ngày tối đa có thể được EXP 600,nếu sử dụng thẻ 2lần EXP thì là 1200.";
    str_help_level5 = "2.Ngồi xuống chơi bài tích lũy thời gian được Exp:";
    str_help_level6 = "Thời gian chơi bài";
    str_help_level7 = "được EXP"; 
    str_help_level8 = "Trên 2 tiếng mỗi tiếng được 20 Exp";
    str_help_level9 = "Cấp"; 
    str_help_level10 = "Xưng hô";         
    str_help_level11 = "Cần";
    str_help_level12 ="Tổng Exp"; 
    str_help_level13 ="Phần thưởng";  

    str_hall_icon_mall = "E-mail";
    str_hall_icon_game = "Mini game";
    str_hall_icon_acitvity = "Sự kiện";
    str_hall_icon_mession = "Nhiệm vụ";
    str_hall_icon_more = "More";
    str_hall_icon_friend = "Bạn bè";
    str_hall_icon_course = "Giáo trình";
    str_hall_icon_feedback = "Phản hồi";
    str_hall_icon_setting = "Cài đặt";
    str_hall_icon_backpack = "đạo cụ";
    str_hall_icon_rank = "Xếp hạng";

    
    str_common_appeal               = "Khiếu nại";               --申訴
    str_common_warning              = "Cảnh cáo";               --警告
    str_common_sure                 = "Xác định";               --确定
    str_common_ban_tip              = "Tài khoản (UID:{0})đã bị khóa do vi phạm luật chơi công bằng！Hãy tuân thủ luật chơi công bằng của game, nếu bạn có thắc mắc vì vấn đề bị khóa thì có thể khiếu nại với adm của game！"; --封号提示

    str_help_login_feedback1 = "Bạn vui lòng cung cấp ID của bạn, và nói kỹ về vấn đề, chúng tôi sẽ nỗ lực giải quyết cho bạn!";
    str_help_login_feedback2 = "E-mail hoặc số điện thoại của bạn.";
    str_help_login_feedback3 = "Hãy xác nhận phương thức liên hệ chính xác!";
    str_help_login_feedback_error = "TT liên hệ sai định dạng, mời bạn kiểm tra lại trước khi nhắn tin.";
    str_help_login_feedback_not_handle = "chưa xử lý";
    str_send = "Gửi";
    str_help_hall_feedback1 = "Bạn vui lòng nói kỹ về vấn đề bạn đã gặp";
    str_help_hall_feedback2 = "Bạn vui lòng cũng cấp thời gian nạp tiền, số chip đã nạp và lịch sử thanh toán cho chúng tôi, chúng tôi sẽ giải quyết nhanh cho các bạn!";
    str_help_hall_feedback3 = "Nếu bạn gặp lỗi gì bạn vui lòng phản hồi cho chúng tôi, cảm ơn bạn!";
    str_help_hall_feedback4 = "Nếu bạn có ý kiến gì hay về game, vui lòng phản hồi cho chúng tôi, cảm ơn bạn!";
    str_help_feedback_sucess = "Phản hồi thành công";

    
    str_store_buy_xxx_by				= "Mua {0} Chip Xu";				--購買{0}金幣
    str_store_buy_xxx_chips				= "Mua {0} chip";				--購買{0}籌碼
    str_store_buy_succ				= "Đang phát hàng";				--發貨成功
    str_store_buy_erro				= "Phát hàng thành công";				--正在發貨

    str_store_chips_text = "%s chip";
    str_store_coalaa_text = "%s Coalaa";
    str_bankrupt_buy_chips_test = "Mua chip ngay";
    str_bankrupt_title = "Rất tiếc ,bạn phá sẩn rồi!";
    str_bankrupt_desc_text1 = "Bạn nhận được %s chip cứu trợ lần cuối và 1 lần KM trong ngày. Nạp xu và chiến lại ngay!";
    str_bankrupt_desc_text2 = "Bạn nhận được %s chip cứu trợ lần cuối và 1 lần KM trong ngày.";
    str_bankrupt_desc_text3 = "Thắng thua là chuyện bình thường không nên nản lòng, tặng cho bạn 1 lần khuyến mãi khi nạp thẻ trong ngày!";
    str_bankrupt_desc_text4 = "Bạn đã hết số lần nhận chip cứu trợ phá sản, hãy đến shop để mua chip, mỗi ngày đăng nhập đều có chip tặng free!";
    str_store_use = "Sử dùng";
    str_store_no_props = "Tạm không có đạo cụ";
    str_store_buy_long = "Mua";
    str_store_prop_using = "Đang sử dụng";
    str_store_prop_remain = "Còn: %s";
    str_store_prop_remain1 = "Còn có: %s tiếng";
    str_store_vip_card_name = "Thẻ VIP";
    str_store_big_laba_name = "Loa to";
    str_store_hddj_prop_name = "Đạo cụ giao lưu";
    str_store_small_laba_name = "Loa nhỏ";
    str_store_double_exp_prop_name = "Thẻ expx2";
    str_store_pop_up_gold_card = "Card vàng";
    str_store_pop_up_silver_card = "Card bạc";
    str_store_pop_up_copper_card = "Card đồng";
    str_store_pop_up_diamon_card = "Card kim cương";	
    str_store_user_prop_invite_card = "Thẻ mời TĐ tranh bá";

    str_rank_playerinfo1 = "LV.%s";
    str_rank_playerinfo2 = "Xếp hạng:%s";
    str_rank_playerinfo3 = "Điểm: %s";
    str_rank_playerinfo4 = "X/s thắng: %s%%";
    str_rank_playerinfo5 = "UID:%s";
    str_rank_playerinfo6 = "Bạn bè";
    str_rank_playerinfo7 = "ĐC của tôi";
    str_rank_playerinfo8 = "Quà của tôi";
    str_rank_playerinfo9 = "Tặng quà";
    str_rank_playerinfo10 = "Kết bạn";
    str_rank_playerinfo11 = "Theo";
    str_rank_playerinfo12 = "Không theo chân được người chơi offline!",
    str_rank_playerinfo13 = "Không theo chân được người chơi không ở phòng!",
    str_rank_playerinfo14 = "%s trận: %s/%s đánh bài",
    str_rank_playerinfo15 = "$%s",
    str_rank_playerinfo16 = "Tặng",

    str_rank_rankType1  = "SL chip";
    str_rank_rankType2  = "Cấp bậc";
    str_rank_rankType3  = "Thành tích";
    str_rank_rankType4  = "Xếp hạng";
    str_rank_rankCrowd1  = "Toàn quốc";
    str_rank_rankCrowd2  = "Bạn bè";
    str_rank_myRank = "Xếp hạng của tôi: %s";
    str_ran_noFriendTips = "Tạm chưa có bạn"; 
    str_rank_hallRankCrowd1 = "Tất cả";
    str_rank_hallRankCrowd2 = "Bạn bè";

    -- 排行描述所用字符串start -- 
    str_rank_ranking_format_resource_1 = "Bạn là người giàu nhất trong cả nước, là nhà chơi thứ nhất mọi người đều tôn trọng!";
	str_rank_ranking_format_resource_2 = "Chip của bạn là nhiều nhất trong danh sách.";--"Chip của bạn là nhiều nhất trong các bạn bài.";
    str_rank_ranking_format_resource_3 = "Bạn là người nguyên lão được tôn trọng bởi vì kinh nghiệm về poker của bạn phong phú nhất.";
    str_rank_ranking_format_resource_4 = "Cấp bậc của bạn là cao nhất trong các bạn bài.";
    str_rank_ranking_format_resource_5 = "Bạn đã có các loại thành tựu rồi, là nhân vạt truyền kỳ trong giới Poker.";
    str_rank_ranking_format_resource_6 = "Bạn có thành tích nhiều nhất trong các bạn bài.";
    str_rank_ranking_format_resource_7 = "Được {0} chip sẽ thành thứ {1}.";
    str_rank_ranking_format_resource_8 = "Được {0} EXP sẽ thành thứ {1}.";
    str_rank_ranking_format_resource_9 = "Được {0} thành tích nữa sẽ thành thứ {1}.";
    str_rank_ranking_format_resource_10 = "Được {0} chip sẽ thành thứ {1}.";
    str_rank_ranking_format_resource_11 = "Được {0} EXP sẽ thành thứ {1}.";
    str_rank_ranking_format_resource_12 = "Được {0} thành tích nữa sẽ thành thứ {1}.";
    str_rank_ranking_format_resource_13 = "Hiện này bạn là người vô địch";
    str_rank_ranking_format_resource_14 = "Tích phân của bạn nhiều nhất só với bạn bài";
    str_rank_ranking_format_resource_15 = "Bạn phải giành được {0} tích phân nữa mới có thể đứng top {1}";
    str_rank_ranking_format_resource_16 = "Giành được {0} tích phân nữa là có thể đứng trong đầu top {1}";
    -- 排行描述所用字符串end -- 

    --宝箱
    str_room_room_activity_treasuer_box_title	= "Hòm báu thời gian";				--倒計時寶箱
    str_room_treasure_box_finished				= "Hôm nay bạn đã nhận hết hòm báu, mai nhận tiếp nhé.";				--計時寶箱已完成
    str_room_treasure_box_not_reward			= "Chơi tiếp {0} phút {1} giây, sẽ thu được{2}.";				--計時寶箱不可領獎
    str_room_treasure_box_reward				= "Chúc bạn thu đượ giải hòm báu {0} chip.";				--計時寶箱領獎
    str_room_treasure_box_not_sit_down		    = "Ngồi xuống mới có thể tính giờ tiếp.";				--計時寶箱未坐下不能領獎
    
--保險箱
    tips = "Nhắc nhở hệ thống",
    confirm_btn = "Xác nhận",
    delete_btn = "Xóa",
    cancel = "Hủy",
    save = "Cất vào",
    take_out = "Rút",
    safeBox_psd = "Mật khẩu két",
    cancel_psd = "Hủy mật khẩu",
    change_psd = "Sửa mật khẩu",
    psd_error = "Mật khẩu sai",
    set_psd = "Thiết lập mật khẩu",
    enter_psd = "Nhập mật khẩu",
    forgot_psd= "Quên mật khẩu",
    safeBox_tips1 = "Bạn có thể chọn thay đổi hoặc xóa mật khẩu",
    safeBox_tips2 = "Bạn đã đặt mật khẩu két thành công.",
    safeBox_tips3 = "Nhắc nhở: Nếu quên mật khẩu, bạn có thể Bấm \"Quên\" để phản hồi tới CSKH",
    safeBox_tips4 = "Số chip trong game:",
    safeBox_tips5 = "Số chip trong két:",
    psd_tip1 = "Xin nhập 6-16 chữ hoặc chữ cái.",
    psd_tip2 = "Xin nhập mật khẩu lại.",
    psd_tip3 = "Mật khẩu không khớp.",
    str_bank_password_modify_fail = "Sửa thấtbại";
    str_bank_password_cancel_fail = "Hủy mật khẩu thất bại";
    str_bank_password_modify_success = "Bạn đã sửa mật khẩu ngân hàng thành công.";				--修改密碼提示
    str_bank_password_cancel_success = " Bạn đã xóa mật khẩu ngân hàng thành công.";				--取消密碼提示
    str_login_private_bank_input_money_label				= "Xin nhập số chip";				--請輸入金額
    str_login_save_money_success				= "Gửi tiền thành công";				--存款成功
    str_login_draw_money_success				= "Lấy tiền thành công";				--取款成功
    safeBox_bank_no_money                       = "Tạm không có chip trong két.",
    str_login_fb = "Log in With Facebook";
    str_login_email = "Log in With E-mail";
    str_login_guest = "Log in With Tourist";--Du khách
    str_login_email_title = "Tài khoản Email";
    str_login_email_account = "Tài khoản";
    str_login_email_account_hint = "Email";
    str_login_email_pwd = "Mật khẩu";
    str_login_email_remember_pwd = "Lưu mật khẩu";
    str_login_email_forgot_pwd = "Quên mật khẩu";
    str_login_email_content = "Bạn có thể đăng nhập bằng tài khoản du khách và nâng cấp sang tài khoản email.";
    str_login_email_login = "Đăng nhập";
    str_login_email_format_error = "Email sai, xin kiểm tra lại!";
    str_login_reset_pwd_title = "Thiết lập mật khẩu lại.";
    str_login_reset_pwd_content = "Mật khẩu sẽ được gửi về email, mời bạn check lại!";
    str_login_reset_pwd_commit = "Gửi";
    str_login_reward = "Nhiều phần thưởng";
    str_login_company = "Boyaa Interactive";
    str_login_workgroup = "IPOKER TEAM";
    str_login_workgroup2 = "iPoker Workgroup";
    str_login_copyright = "Boyaa Interactive Copyright 2019";

    str_login_close_guess_register="Xin lỗi, tạm không đăng ký Du khách được, đề nghị bạn đăng ký bằng tài khoản Facebook."; --很抱歉，游客注册方式已暂停，请您使用邮箱或facebook帐户注册
    str_login_network_err="Kết nối mạng bị trục trặc, hãy check lại kết nối mạng!"; --哎呀，您的网络开小差，请检查下网络设置吧
    str_login_server_down="Xin lỗi với các bạn thân mến, tạm không thể đăng nhập game vì máy server đang được nâng cấp!";--亲爱的玩家，服务器正在升级维护，目前无法登录游戏，给您带来的不便我们深感抱歉！
    str_login_restricte_login="Xin lỗi, bạn có hiềm nghi vi phạm luật chơi công bằng, tạm không thể đăng nhập!";--抱歉，您有违反游戏公平的可疑情况，禁止登陆
    str_login_restricte_register="Xin lỗi, số lượng đăng ký của bạn đã đến hạn mức!";--抱歉，您的注册量已达上限
    str_login_fb_access_token_err = "Xin lỗi, Facebook cấp quyền thất bại!";
    str_login_close_guess_login="Xin lỗi, không thể đăng nhập bằng tài khoản du khách nữa, hãy sử dụng phương thức đăng nhập khác!";--抱歉，游客登入方式已关闭，请您使用其它登入方式
    str_login_ban_tip = "Do vi phạm luật chơi, tài khoản bạn (uid:%s) bị khóa. Bạn có thể khiếu nại tới CSKH để giải quyết."; --封号提示
    str_login_bad_network = "Mạng yếu, xin kiểm tra mạng lại!";				--網路狀況不佳
    str_login_open_wifi_tip = "Mời bạn kết nối wifi để được trải nghiệm tốt hơn";
    str_login_login_password_error = "  Mật khẩu sai, xin kiểm tra!";				--密碼錯誤，請輸入正確的密碼！
    str_login_login_email_error	= " Email sai, xin kiểm tra!";				--電子郵箱錯誤，請輸入正確的電子郵箱！
    str_login_emulator_limit = "Cấm đăng nhập bằng phần mềm mô phỏng";--模拟器禁止登录
    str_login_cancle_tip = 'Đã hủy đăng nhập';

    str_logout_entrance = "đăng xuất";
    str_logout_title = "Xác định thoát ra";
    str_logout_content = "Bạn xác nhận hủy tài khoản này?";
    str_logout_btn_cancel = "Hủy";
    str_logout_btn_confirm = "Biết rồi";

    str_accountUpgrade_mail = "Email";
    str_accountUpgrade_verifyCode = "Mã xác nhận";
    str_accountUpgrade_desc = "Hệ thống sẽ giữ số liệu của tài khoản bạn sau khi nâng cấp";
    str_accountUpgrade_getVerifyCode = "Nhận mã xác nhận";
    str_accountUpgrade_hadAccount = "Đã có tài khoản";
    str_accountUpgrade_freeUpgrade = "Lên cấp miễn phí";
    str_accountUpgrade_passwordAgain = "Nhập lại mật khẩu";
    str_accountUpgrade_existAccount = "Tài khoản này đã có, xin chọn email khác.";
    str_accountUpgrade_createAccount_succ               = "Chúc mừng bạn đã lên cấp thành tài khoản Email.";
    str_accountUpgrade_blindAccount_succ               = "Chúc mừng bạn đã lên cấp thành tài khoản Email.";
    str_accountUpgrade_verifyError1 = "Xác nhận qua email thất bại";  
    str_accountUpgrade_verifyError2 = "Tra cứu thất bại, mời bạn thử lại sau";  
    str_accountUpgrade_verifyError3 = "Đã liên kết email";  
    str_accountUpgrade_verifyError4 = "Đã hết số lượt xác nhận hôm nay";        
    
    str_change_pwd_title = "Đổi mật khẩu ";
    str_change_pwd_new_pwd = "Mật khẩu mới";
    str_change_pwd_new_pwd_again = "Xác định";
    str_change_pwd_commit = "Gửi";
    str_change_pwd_inconsistent = "Mật khẩu không khớp!";
    
    -- 算牌器
    str_cardCalculator_title				= "Chuông tính bài";				--算牌器
    str_room_type_probability				= "X/s thành bài";				--成牌概率
    str_room_card_type				= { --牌型
        [10]= "Cao bài";
        [9] = "Bài đôi";
        [8] = "Hai đôi";
        [7] = "Ba lá";
        [6] = "Sảnh";
        [5] = "Đồng hoa";
        [4] = "Cù lủ";
        [3] = "Tứ quý";
        [2] = "Sảnh thông";
        [1] = "Sảnh chúa";
    },
    str_room_leave_table_confirm				= "Nếu ra khỏi chỗ ngồi sẽ mất chip đã đặt. Xác định ra khỏi chưa?";				--是否離開座位
    str_room_leave_table_confirm2				= "Bạn xác định sẽ ra khỏi phòng không?";				--是否離開座位(坐下但未開始遊戲)
    str_room_leave_match_confirm				= "Nếu ra khỏi chỗ ngồi sẽ bỏ thi đấu. Xác định ra khỏi chưa?";				--是否離開比賽
    str_room_match_end_notice				    = "Đã kết thúc";				--是否離開比賽
    str_room_leave_match_confirm3				= "Giải đấu sắp bắt đầu, bạn xác nhận trở về sảnh không?";				--比賽馬上就要開始了,是否要返回大廳?
    str_room_leave_match_str1                   = "Tiếp tục chờ";  --繼續等待
    
    str_loginReward_all = "Thưởng hôm nay: ";
    str_loginReward_tips = "chơi bài nhiều nhận thưởng nhiều";
    str_loginReward_login = "Giải đăng nhập";
    str_loginReward_play = "Giải chơi bài";
    str_loginReward_vip = "Phần thưởng VIP";
    str_loginReward_fb = "Facebook đăng nhập";
    str_loginReward_hadReward = "Đã nhận thưởng trên bản web";

    str_defaultAccount_title = "Cài đặt tài khoản mặc định";
    str_defaultAccount_tips = "Cài đặt thiết bị này thành tài khoản du khách.";
    str_defaultAccount_submit = "Gửi";

    str_refresh = "Đang cập nhật...";

    str_normal_selections_private_room = "Phòng riêng";
    str_normal_selections_filter = "Chọn lọc";
    str_normal_selections_list = "Danh sách";
    str_normal_selections_table = "Bàn";

    str_normal_selections_low_rank = "Sân sơ cấp";
    str_normal_selections_middle_rank = "Sân trung cấp";
    str_normal_selections_high_rank = "Sân cao cấp";
   
    str_normal_selections_fast_title = "Sân cao tốc";
    str_normal_selections_fast_desc = "Thời gian ra bài là 10s.";
    str_normal_selections_must_title = "Sân Ante";
    str_normal_selections_must_desc = "Yêu cầu đặt cược nhất định trước khi bắt đầu ván bài.";
    str_normal_selections_must_fast_title = "Sân Ante cao tốc";
    str_normal_selections_must_fast_desc = "Yêu cầu đặt cược nhất định trước khi bắt đầu ván bài, thời gian thao tác là 10 giây.";
    str_normal_selections_exp_title = "Sân EXP×2";
    str_normal_selections_exp_desc = "Exp sẽ được tăng gấp đôi khi chơi bài";
    str_normal_selections_private_title = "Phòng riêng";
    str_normal_selections_private_desc = "Phòng riêng";
    str_normal_selections_room_num = "Số hiệu";
    str_normal_selections_blind_num = "SB/BB";
    str_normal_selections_carry_num = "Tối thiểu/Tối đa ";
    str_normal_selections_bonus_num = "Tích phân";
    str_normal_selections_player_num = "Số người";

    str_normal_selections_5_player = "5 người";
    str_normal_selections_9_player = "9 người";
    str_normal_selections_normal = "Phổ thông";
    str_normal_selections_fast = "Cao cốc";
    str_normal_selections_full = "Đầy người";
    str_normal_selections_empty = "Phòng trống";

    str_normal_selections_search = "Tìm kiếm";
    str_normal_selections_enter_num = "Hãy nhập con số";
    str_normal_selections_search_error = "Hãy nhập con số";
    str_normal_selections_enter_roomID = "Hãy nhập ID phòng";
    str_normal_selections_sb_blind = "SB/BB";
    str_normal_selections_sb_carry = "Tối thiểu/Tối đa";

    str_normal_selections_bonusPop_desc = "    Chơi bài tại phòng chỉ định có thể tích điểm.";

    str_store_chips = "Chip";
    str_store_coin = "Chip Xu";
    str_store_prop = "Đạo cụ";
    str_store_vip = "Card";
    str_store_my_prop = "Đạo cụ của tôi";
    str_store_buy_history = "Kỷ lục thanh toán";
    str_store_account_manage = "Tài khoản";

    str_store_pay_busy = "Đang mua, xin đừng gửi yêu cầu lặp lại.";
    str_store_create_order = "Đang mua, chờ chút nhé!";
    str_store_create_order_fail = "Mua thất bại";
    str_store_pay_fail = "Thanh toán thất bại";
    str_store_pay_success = "Mua thành công";
    str_store_pay_request_delivery = "Lặp lại gửi đơn đặt hàng, xử lý thất bại.";
    str_store_pay_cancel = "Bạn đã hủy mua";
    str_store_pay_delivery_fail = "Phát hàng thất bại, xin liên hệ với người quản lý.";
    str_store_pay_unsupport = "Tạm không nạp xu được";
    str_price_unit = "$";

    str_room_sit_down_send_chips = "Ngồi xuống trước mới tặng chip được.";				--您需要坐下才能贈送籌碼
    str_room_sit_down_play_hddj				= "Ngồi xuống trước mới có thể dùng đạo cụ.";				--坐下才能使用互動道具
    str_room_not_enough_hddj				= "Không có đạo cụ, đến shop mua.";				--無互動道具，請前往商城購買
    str_common_buy				= "Mua";				--購買
    str_room_match_table_send_chips	= "Xin lỗi, sân thi đấu không được tặng chip!";				--抱歉，比賽場不能贈送籌碼！
    str_room_match_room_not_play_hddj				= "Xin lỗi, sân thi đấu ko được sử dùng đạo cụ giao lưu.";				--抱歉，比賽場不能使用互動道具
    str_userinfo_win_rate = "Tỷ lệ thắng";
    str_userinfo_max_win = "Thắng nhiều nhất";
    str_room_userinfo_level				= "LV.{0}";				--等級和頭銜
    str_userinfo_highest_asset = "Số chip cao nhất từng có";
    str_userinfo_best_hand_card = "Bài tay tốt nhất";
    str_userinfo_no_best_hand_card = "Chơi bài và thắng với kiểu bài mạnh nhất đi!";
    str_userinfo_achievement = "Thành tích mới nhất";
    str_userinfo_no_achievement = "Bạn tạm chưa đạt được thành tựu.";
    str_room_not_enough_chips_to_send				= "Xin lỗi, chip trong phòng chưa đủ,chưa tặng chip được.";				--座位籌碼餘額不足無法贈送
    str_room_send_chips_too_many_times				= "Tặng chip thường xuyên quá, xin thử lại sau.";				--贈送籌碼太頻繁
    --XML_RESOURCE bundle
    str_xml_resource_level_list = 				--經驗配置
    {
        [ 1] = { b = "Chim mới"     ,c = 0      };
        [ 2] = { b = "Lính mới"     ,c = 10     };
        [ 3] = { b = "Cao thủ"   ,c = 25     };
        [ 4] = { b = "Club player"   ,c = 161    };
        [ 5] = { b = "Club master"   ,c = 520    };
        [ 6] = { b = "Club champion"   ,c = 1249   };
        [ 7] = { b = "Player thị trấn"     ,c = 2499   };
        [ 8] = { b = "Master thị trấn"     ,c = 4427   };
        [ 9] = { b = "Quán quân thị trấn"     ,c = 7198   };
        [10] = { b = "Player thành phố"     ,c = 10990  };
        [11] = { b = "Master thành phố"     ,c = 16003  };
        [12] = { b = "Quán quân thành phố"     ,c = 22466  };
        [13] = { b = "Player nhà nước"     ,c = 30658  };
        [14] = { b = "Master nhà nước"     ,c = 40931  };
        [15] = { b = "Quán quân nhà nước"     ,c = 53748  };
        [16] = { b = "Player Châu Á"     ,c = 69744  };
        [17] = { b = "Master châu Á"     ,c = 89816  };
        [18] = { b = "Quán quân châu Á"     ,c = 115264 };
        [19] = { b = "Tour player"   ,c = 148000 };
        [20] = { b = "Tour master"   ,c = 190877 };
        [21] = { b = "Tour champion"   ,c = 248186 };
        [22] = { b = "Player thế giới"     ,c = 326416 };
        [23] = { b = "Master thế giới"     ,c = 435424 };
        [24] = { b = "Quán quân thế giới"     ,c = 590214 };
        [25] = { b = "Thần bài poker"     ,c = 813671 };
    };
    str_setting_head_pop_save = "Lưu";
    str_setting_head_pop_male = "Nam";
    str_setting_head_pop_female = "Nữ";
    str_setting_head_pop_bind_mail = "Liên kết email để nhận thưởng";
    str_setting_head_pop_mail_change_pwd = "Sửa mật khẩu";
    str_setting_head_pop_upgrade_account = "Đã lên cấp thành tài khoản Email";
    str_setting_head_pop_award_chips = "Tặng 30M miễn phí";
    str_setting_head_pop_nick_error = "Tên người không được để trống";

    str_head_img_uploading= "Đăng tải avatar, xin chờ.";
    str_head_img_upload_limit = "Size ảnh không nên quá %s";	--頭像上傳大小超過限制
    str_head_img_upload_success= "Tải avatar thành công";				--頭像上傳成功
    str_head_img_upload_failed= " Tải avata thất bại";				--頭像上传失败
    -- 經驗配置
    str_level_system_detail = {
        [1]   = {level = "Cấp",  name = "Xưng hô",         needExp = "Cần",targetExp="Tổng Exp", chips ="Phần thưởng",      other = {},fontStyle = { color = {r =162,g =215,b= 255} }};   
    };

    str_exp_system_detail = {
        [1] = {time = "Thời gian chơi bài", exp = "được EXP" ,fontStyle = { color = {r =162,g =215,b= 255} }};
        [2] = {time = "5 phút",            exp = "5 Exp"};
        [3] = {time = "10 phút",           exp = "10 Exp"};
        [4] = {time = "15 phút",           exp = "10 Exp"};
        [5] = {time = "20 phút",           exp = "10 Exp"};
        [6] = {time = "30 phút",           exp = "20 Exp"};
        [7] = {time = "60 phút",           exp = "60 Exp"};
        [8] = {time = "90 phút",           exp = "40 Exp"};
        [9] = {time = "120 phút",          exp = "40 Exp"};
    };

    str_setting_title = "Cài đặt ";
    str_setting_account_title = "Tài khoản";
    str_setting_logout = "đăng xuất";
    str_setting_voice_shake_title = "Âm thanh và rung";
    str_setting_bgm_title = "Âm nhạc";
    str_setting_voice_title = "Âm thanh";
    str_setting_shake_title = "Chế độ rung";
    str_setting_other_title = "Khác";
    str_setting_auto_sit = "Ngồi tự động";
    str_setting_auto_buy_in = "Mua vào tự động";
    str_setting_play_count = "Nhắc nhở chơi bài";
    str_setting_clear_cache = "Xóa cache";
    str_setting_clear_cache_tips = 'Xóa cache xong.';
    str_setting_score = "Thích game mình, xin cho điểm để khuyến khích";
    str_setting_version_name = "Phiên bản hiện tại: %s";
    str_forget_possword_operatr_succeed="Thao tác thành công, hãy lưu ý e-mail";--操作成功，請留意郵件
    str_forget_possword_account_wrong = "Tài khoản e-mail sai";--邮箱账号不正确
    str_forget_possword_failse_more = "Hạn chế mỗi ngày 5 lần, đã hết cơ hội";--每天限制5次，已超出限制
    str_forget_possword_failse = "Thao tác thất bại";--操作失败
    str_forget_possword_user_none = "Không có tài khoản này";--账号不存在

    
    str_gift_pop_title_3 = {"Quà chip", "Quà xu","Quà của tôi"};
    str_gift_pop_title_2 = {"Qùa chip","Quà của tôi"};
    str_gift_pop_chip_title = {"Tất cả", "Trang trí","Ngày lễ","Giải trí","Khác"};
    str_mygift_left_category_item = {"Tất cả", "Đã quá hạn"};
    str_gift_buy				                = "Mua";				--購買
    str_gift_present_to				            = "Tặng cho: {0}";				--贈送給：{0}
    str_gift_present				            = "Tặng";				--贈  送
    str_gift_sale_overdue_gift				    = "Bán quà";				--賣出過期禮物
    str_gift_use				                = "Sử dùng";				--使  用
    str_gift_buy_long				            = "Mua";				--購  買
    str_gift_buy_for_table				        = "Mua cho bạn bài";				--買給牌桌
    str_gift_no_gift_info_hint				    = "Loài này chưa có quà";				--當前類別沒有禮物
    str_gift_no_own_gift_hint				    = "Bạn chưa có quà gì";				--您目前未擁有禮物
    str_gift_no_own_due_gift_hint				= "Chưa có quà hết hạn";				--您目前未擁過期禮物
    str_gift_sale_all_due_gift_hint				= "Bán tất cả";				--一鍵出售所有過期禮物
    str_gift_sale_all_due_gift_price_prompt		= "Bán quà quá hạn được: {0}";				--一鍵出售所有過期禮物價格
    str_gift_gift_buy_by_self				    = "Tự mua";				--自購
    str_gift_gift_past_due				        = "Đã quá hạn";				--已過期
    str_gift_glory_obtain_gift				    = "Qùa thành tích";				--成就禮物
    str_gift_gift_sale_succeed				    = "Bán quà thành công";				--禮物出售成功
    str_gift_gift_sale_fail				        = "Bán quà thất bại";				--禮物出售失敗
    str_gift_expired_days				        = "Thời hạn: {0}";				--有效期：{0}
    str_gift_gift_past_due_price				= "Gía bán: {0}";				--出售價：{0}
    str_gift_expired_days_forever				= "Vĩnh cửu";				--永久
    str_gift_expired_days_num				    = "{0} ngày";				--{0}天
    str_gift_room_purchase				= "Mua quà";				--購買禮物

    str_gift_gift_msg_arr			= { --禮物提示消息
        [1] = "Ngồi xuống trước mới mua quà cho bạn bài được.";
        [2] = "Tin quà tải thất bại";
        [3] = "Tải quà này thất bại";
    },
    str_gift_buy_gift_to_table_result_msg				= { --禮物賣給牌桌伺服器返回狀態對應提示
        ["1"] = "Mua quà thành công!";								--禮物購買成功
        ["0"] = "Xin lỗi, tiền của bạn chưa đủ.";								--您的籌碼或金幣不足，無法購買該禮物
        ["-1"] = "Hệ thống có lỗi, xin phản hồi cho người quản lý.";								--系統參數錯誤，請通過設置中的反饋聯繫管理員處理
        ["-2"] = "Chưa có quà mà bạn mua";								--您所購買的禮物不存在
        ["-3"] = "Hệ thống có lỗi, mua quà thất bại.";								--系統錯誤，購買禮物失敗
        ["-5"] = "Bạn chưa đăng nhập";								--您未登錄	
        ["-6"] = "Chip bạn không đủ mua quà";  -- 您的金幣不足，無法購買該禮物
    },
    str_gift_use_gift_result_msg			= { --使用禮物伺服器返回狀態對應提示
        [1] = "Sử dùng quà thành công";								--禮物使用成功
        [0] = "Chưa có quà này";								--您使用的禮物不存在
        [-1] = "Hệ thống có lỗi, xin phản hồi cho người quản lý.";								--系統參數錯誤，請通過設置中的反饋聯繫管理員處理
        [-5] = "Bạn chưa đăng nhập";								--您未登錄
    },
    str_gift_buy_gift_result_msg				= { --購買禮物伺服器返回狀態對應提示
        ["1"] = "Mua quà thành công";								--禮物購買成功
        ["0"] = "Xin lỗi, tiền của bạn chưa đủ.";								--您的籌碼或金幣不足，無法購買該禮物
        ["-1"] = "Hệ thống có lỗi, xin phản hồi cho người quản lý.";								--系統參數錯誤，請通過設置中的反饋聯繫管理員處理
        ["-2"] = "Chưa có quà nàyChưa có quà này";								--您所購買的禮物不存在
        ["-3"] = "Hệ thống có lỗi, mua quà thất bại.";								--系統錯誤，購買禮物失敗
        ["-5"] = "Bạn chưa đăng nhậpBạn chưa đăng nhập";								--您未登錄
        ["-6"] = "Chip bạn không đủ mua quà";  -- 您的金幣不足，無法購買該禮物
    },

    str_mail_pop_title = {"E-mail", "Tin hệ thống"};
    str_mail_cell_operate_get = "Nhận";
    str_mail_cell_operate_fill = "Điền thông tin";
    str_mail_cell_operate_read = "xem kỹ";
    str_phone_format_error = "SĐT sai định dạng, mời bạn xác nhận lại!";
    str_fill_mail = "Email";
    str_fill_phone = "SĐT";
    str_mail = "Email：%s";
    str_phone = "SĐT: %s";
    str_mail_detail_title = "Chi tiết Email";
    str_mail_get_reward_failed = "Rút thưởng thất bại";
    str_mail_null_sys_message_tip = "Tạm không có tin mới";
    str_mail_null_mail_message_tip = "Tạm không có email mới";
    str_mail_remain_date_tip = "Email tối đa được giữ 7 ngày";
    str_mail_get_date_fmt = "%d/%m/%Y";

    str_safe_box_vip_level_tips = "Lên đến cấp 7 hoặc VIP mới được dùng ngân hàng.";
    str_become_vip = "Trở thành VIP";
    str_save_bank_money_fail = "Gửi tiền thất bại";				--存錢操作失敗
    str_not_sufficien_funds = "Chip chưa đủ";

    str_friend_invite = "Rủ bạn nhận thưởng";
    str_friend_invite_fb_title = "Yều cầu Facebook";
    str_friend_invite_fb_desc = "Rủ bạn bè tham gia ngay";
    str_friend_userinfo_chips = "Số lượng chip: ";
    str_friend_userinfo_play_num = "Số ván: %s";
    str_friend_userinfo_win_rate = "X/s thắng: %s";
    str_friend_trace = "Theo";
    str_friend_trace_status1 = "Người chơi chưa online, không theo dõi được!";
    str_friend_trace_status2 = "Đánh bài";
    str_friend_trace_status3 = "Xem";
    str_friend_trace_status4 = "Đang dạo, không theo dõi được!";
    str_friend_user_friend_statue_high_level				= "Sân cao cấp: %s";				--高級場：{0}
    str_friend_user_friend_statue_middle_level				= "Sân trung cấp: %s";				--中級場：{0}
    str_friend_user_friend_statue_primary_level				= "Sân sơ cấp: %s";				--初級場：{0}
    str_friend_user_friend_statue_private                   = "Phòng riêng: %s";                --私人房：{0}
    str_friend_friend_popup_callback				= "Gọi về thành công sẽ được %s chip.";				--成功召回得{0}籌碼
    
    str_friend_track_mtt = "MTT";--錦標賽
    str_friend_track_sng = "SNG";--淘汰賽
    str_friend_send_chips = "Tặng %s chip";
    str_friend_send_gift = "Tặng quà";
    str_friend_delete = "Xóa";
    str_friend_offline_today = "Đăng nhập lần trước: Hôm nay;";
    str_friend_offline_days = "Gần nhất: %d ngày trước";
    str_friend_offline_weeks = "Gần nhất: %d tuần trước";
    str_friend_offline_month = "Gần nhất: %d tháng trước";
    str_friend_offline_years = "Gần nhất: %d năm trước";
    str_friend_callback = "Gọi về";

    str_friend_invite_only_fb = "Tài khoản FB mới có thể sử dụng chức năng này. Mời bạn có thể nhận được phần thưởng lớn.";
    str_friend_invite_fb_invite_desc = "Game poker dễ chơi và đơn giản, nhận %s chip thưởng và chơi cùng với mình đi!";--为您推荐了一个既刺激又好玩的扑克游戏，我给您赠送了{0}的筹码礼包，注册即可领取，快来和我一起玩吧！
    str_friend_invite_cancel				= "Yêu cầu của bạn đã hủy.";				--您的邀請已經取消
    str_friend_invite_error 				= "Gửi yêu cầu mắc lỗi %s";				--發送邀請出錯 {0}
    str_friend_invite_success				= "Gửi yêu cầu thành công";				--邀請發送成功

    str_friend_give_chip_success				= "Bạn đã tặng %s chip cho bạn bè";				--贈送籌碼成功
    str_friend_give_chip_too_poor				= "Chip của bạn ko đủ, xin mua chip trước.";				--贈送籌碼失敗
    str_friend_give_chip_count_out				= "Bạn hôm nay đã tặng chip cho bạn bè rồi, mai tiếp nhé!";				--贈送籌碼失敗
    str_friend_go_to_store      				= "Đi mua";				--去商城
    str_friend_delete_friend_success			= "Xóa bạn thành công.";				--刪除好友成功
    str_friend_delete_friend_fail				= "Xóa bạn thất bại, xin thử lại sau.";				--刪除好友失敗
    str_friend_recall_success   				= "Gửi lời mới thành công, khi bạn ấy đăng nhập vào gaem sẽ nhận được thưởng.";				--召回好友成功
    str_friend_recall_repeat     				= "Hôm nay đã gửi qua, mai tiếp nhé. ";				--召回好友重複
    str_friend_recall_fail      				= "Gửi thất bại, xin thử lại sau.";				--召回好友失敗
    str_room_track_friend_tips				    = "Click xác định thì sẽ đổi đến phòng của bạn sau khi ván này kết thúc.";
    str_room_match_room_track_friend_tips1		= "Nếu không quay về giải đấu trước khi bắt đầu sẽ coi như bỏ cuộc";	
    str_room_match_room_track_friend_tips2		= "Bạn xác nhận theo chân bạn bè sau khi kết thúc ván này?";				--比赛场牌局中追蹤好友提示
    str_room_match_room_track_friend_tips3		= "Bạn xác nhận bỏ cuộc và theo chân bạn bè không?";	
    str_quit_match_tip                          = "Bạn xác nhận bỏ cuộc không?";
    
    

    str_achi_destination				= "Mục tiêu:";				--目標
    str_achi_reward				        = "Giải thưởng:";	
    str_achi_title_achieve				= "Thành tích";	
    str_achi_title_life				    = "Nghề poker";	
    str_achi_title_record				= "Chiến tích";	
    str_achi_title_stic				    = "Thống kê";	
    str_achi_title_data_stic			= "Thống kê";	
    str_achi_get_reward				    = "Nhận";	
    str_glory_reward_claim_success		= "Nhận giải thành tựu thành công";				--成就獎勵領取成功提示
    str_glory_reward_claim_fail			= "Nhận giải thành tựu thất bại, xin thử lại.";				--成就獎勵領取失敗提示

    str_statistic_top_tab1 = "Một ngày";
    str_statistic_top_tab2 = "Một tuần";
    str_statistic_top_tab3 = "Một tháng";
    str_statistic_top_tab4 = "Ba tháng";
    str_statistic_top_tab5 = "Một năm";

    str_statistic_content_title_overview = "Giới thiệu";
    str_statistic_content_title_overview_sub1 = "Số ván bài";
    str_statistic_content_title_overview_sub2 = "Số thắng";
    str_statistic_content_title_special = "Thống kê đặc biệt";
    str_statistic_content_title_special_sub_1 = "Số All in";
    str_statistic_content_title_special_sub_2 = "All in được thắng";
    str_statistic_content_title_game = "Thống kê ván bài";
    str_statistic_content_title_game_sub_1 = "Số bỏ bài";
    str_statistic_content_title_game_sub_2 = "Được xem bài đầu ba lá";
    str_statistic_content_title_game_sub_3 = "Xem tới turn card";
    str_statistic_content_title_game_sub_4 = "Xem tới river card";
    str_statistic_content_title_game_sub_5 = "So bài khi show down";
    str_statistic_content_title_win = "Thống kê thắng bài";
    str_statistic_content_title_win_sub_1 = "Thắng trước đầu ba lá";
    str_statistic_content_title_win_sub_2 = "Thắng đầu ba lá";
    str_statistic_content_title_win_sub_3 = "Thắng turn card";
    str_statistic_content_title_win_sub_4 = "Thắng river card";
    str_statistic_content_title_win_sub_5 = "Thắng so bài";
    str_statistic_content_title_oprate = "Thống kê thao tác";
    str_oprate_fold = "Bỏ bài";
    str_oprate_check = "Xem bài";
    str_oprate_call = "Theo cược";
    str_oprate_raise = "Thêm cược";
    str_oprate_anti_raise = "Thêm cược lại";
    str_statistic_content_title_fold = "Thống kê bỏ bài";
    str_statistic_content_title_fold_sub_1 = "Cả ván không có bỏ bài";
    str_statistic_content_title_fold_sub_2 = "Bỏ bài trước đầu ba lá";
    str_statistic_content_title_fold_sub_3 = "Bỏ bài trước đầu ba lá";
    str_statistic_content_title_fold_sub_4 = "Bỏ bài turn card";
    str_statistic_content_title_fold_sub_5 = "Bỏ bài river card";
    str_friend_add_friend_success               = "Kết bạn thành công";--添加好友成功

    str_bigWheel_subTitle = "Cơ hội trúng thưởng 100%";
    str_bigWheel_item1 = "1M chip";
    str_bigWheel_item2 = "1 thẻ EXPx2";
    str_bigWheel_item3 = "50M chip";
    str_bigWheel_item4 = "15 lần đcgl";
    str_bigWheel_item5 = "EXP+10";
    str_bigWheel_item6 = "10M chip";
    str_bigWheel_item7 = "5M chip";
    str_bigWheel_item8 = "10 lần đcgl";
    str_bigWheel_item9 = "30M chip";
    str_bigWheel_item10 = "7 lần đcgl";
    str_bigWheel_item11 = "100B chip";
    str_bigWheel_item12 = "Một lần nữa";
    str_bigWheel_ruleTitle = "Quy tắc";
    str_bigWheel_ruleDesc = "Cơ hội trúng 100B không thể bỏ lỡ!";
    str_bigWheel_remain_draw = "Còn có cơ hội: ";
    str_bigWheel_logTitle = "TT trúng thưởng";
    str_bigWheel_againDraw = "Quay lại";
    str_bigWheel_tips_title = "Nhắc nhở hệ thống";
    str_bigWheel_tips_content = "Bạn xác nhận mất %s mua 1 lần cơ hội bốc thưởng không?";
    str_bigWheel_not_enought_money = "Chip của bạn không đủ.";
    str_bigWheel_no_free_play = "Số rút thưởng của bạn hôm nay đã hết, mai tiếp nhé!";
    str_bigWheel_buy_success = "Mua thành công";
    str_bigWheel_tips_reward = "Chúc mừng bạn trúng \"%s\"";
    str_bigWheel_help_title = "Tỷ lệ trúng thưởng";
    str_bigWheel_help_prize = "Phần thưởng";
    str_bigWheel_help_probability = "Tỷ lệ";

    str_modify_email_account_pwd_success = "Đổi mật khẩu thành công!";

    str_exit_game_title = "Xác định thoát ra";
    str_exit_game_content = "Đăng xuất?";

    --操作類型
    str_room_operation_type_0 = "Đợi ván sau";
    str_room_operation_type_1 = "Đợi đặt cược";
    str_room_operation_type_2 = "Bỏ bài";
    str_room_operation_type_3 = "All-In";
    str_room_operation_type_4 = "Theo cược";
    str_room_operation_type_5 = "Small blind ";
    str_room_operation_type_6 = "Big blind";
    str_room_operation_type_7 = "Xem bài";
    str_room_operation_type_8 = "Thêm cược";
    str_room_operation_type_9 = "Ante";
    str_room_sit_fail               = "Ngồi xuống thất bại";               --坐下失敗
    str_room_sit_ip_equal				= "Bạn đã vi phạm quy tắc công bằng, chưa ngồi xuống được.";				--同一IP不能坐下
    str_room_not_enough_chips				= "Xin lỗi, chip chưa đủ,xin nạp tiền.";				--對不起，您的籌碼餘額不足，請充值
    str_room_error_seat				= "Xin lỗi, chỗ này đã có người chơi rồi.";				--對不起，該座位已經有玩家坐下了
    str_room_not_empty_seat				= "Không có chỗ trống, xin chọn phòng khác.";				--沒有空座位，請選擇其他房間
    str_room_too_much_chips				= "Chip của bạn đã nhiều, xin đến sân cao cấp hơn chơi.";				--您的資產達到了一個新的臺階，請前往更高級的場次
    str_room_useer_game_in_current_chip_shortstage				= "Ngân hang của bạn vẫn có tiền, lấy ra luôn chưa?";				--用戶遊戲中籌碼不足
    str_room_chip_shortstage_go_bank				= "Đi ngân hàng";				--去銀行
    str_room_not_enough_money				= "Xin lỗi, số dư chưa đủ, xin mua chip hoặc đổi bàn!";				--餘額不足
    str_room_buy_chips				= "Mua chip";				--購買籌碼
    str_room_switch_table				= "Đổi bàn";				--換桌
    str_room_check				    = "Xem bài";		                    	--看牌
    str_room_fold				    = "Bỏ bài";		                    	--棄牌
    str_room_raise				    = "Thêm cược";		                    	--加注
    str_room_all_in				    = "All in";		                    	--all in
    str_room_confirm				= "Xác định";		                    	--確定
    str_room_call			    	= "Theo cược %s";		                    	--跟注
    str_room_auto_call				= "Theo cược %s";	                        --跟注
    str_room_triple			    	= "Thêm 3 lần";		                    	--3倍反加
    str_room_half_pool				= "1/2 gà thưởng";		                    	--1/2獎池
    str_room_three_quarter_pool		= "3/4 gà thưởng";		                    	--3/4獎池
    str_room_all_pool				= "Tổng gà thưởng";		                    --全部獎池
    str_room_auto_check				= "Tự động xem bài";		                    --自動看牌
    str_room_check_or_fold			= "Xem bài/Bỏ bài";		                    	--看或棄
    str_room_call_any				= "Theo mọi cược";		                    --跟任何注
    str_room_show_hand_card			= "Cho xem bài tay";		                    --亮出手牌
    str_room_info                   = "ID Phòng: %s  Small/Big blind: %s/%s";
    str_room_auto_check				= "Tự động xem bài";			            	--自動看牌
    str_room_check_or_fold			= "Xem bài/Bỏ bài";			                   	--看或棄
    str_room_call_any				= "Theo mọi cược";			            	--跟任何注
     --牌型
    str_room_card_type_1            = "Cao bài";
    str_room_card_type_2            = "Cao bài";
    str_room_card_type_3            = "Bài đôi";
    str_room_card_type_4            = "Hai đôi";
    str_room_card_type_5            = "Ba lá";
    str_room_card_type_6            = "Sảnh";
    str_room_card_type_7            = "Đồng hoa";
    str_room_card_type_8            = "Cù lủ";
    str_room_card_type_9            = "Tứ quý";
    str_room_card_type_10           = "Sảnh thông";
    str_room_card_type_11           = "Sảnh chúa";
    str_room_show_hand_card			= "Cho xem bài tay";				--亮出手牌
    str_room_room_track_friend_tips	= "Click xác định thì sẽ đổi đến phòng của bạn sau khi ván này kết thúc.";				--房間追蹤好友提示
    str_room_wait_next_round				= "Xin chờ ván sau bắt đầu";				--請等待下一局開始

    str_common_svr_stop_tip			= "Máy chủ đang thăng cấp cho nên tạm thời không kết nối được, xin chờ máy chủ khôi phục lại!";				--停服提示
    str_room_not_exist              ="Xin lỗi, ID phòng này không tồn tại!";                              --对不起，房间ID不存在
    str_common_user_forbidden		= "Tài khoản của bạn bị khóa, xin liên hệ với người quản lý !";				--帳號被禁用
    str_common_room_full			= "Số khán già của phòng này đã đủ, hãy chọn phòng khác.";				--房間人數已滿
    str_common_end		        	= "Đã kết thúc";							--比賽結束
    str_common_no_apply				= "Bạn chưa đăng ký";				--您未報名該比賽
    str_common_connect_room_fail	= "Vào phòng thất bại, xin thử lại sau!";				--進入房間失敗，請返回大廳重新再試
    str_room_again_enter_room_fail	= "Bạn vừa bị nhà chủ đuổi ra, 10 phút sau mới được vào phòng này lại.";				--再次進入房間失敗
    str_common_double_login_error	= "Tài khoản của bạn đã được đăng nhập lặp lại, xin phản hồi cho chúng tôi hoặc liên hệ với người quản lý để bảo vệ sự an toàn của tài sản!";				--重複登錄錯誤

    str_chat_common_1=[[Chào các bạn, rất vui được làm quen với mọi người!]];
    str_chat_common_2=[[Mau lên nào!]];
    str_chat_common_3=[[Bình tĩnh nào!]];
    str_chat_common_4=[[Chơi nhỏ không thú vị mấy]];
    str_chat_common_5=[[All in]];
    str_chat_common_6=[[Xem bài trước đi!]];
    str_chat_common_7=[[Phong thủy không tốt, đổi chỗ cái]];
    str_chat_common_8=[[Theo cái！]];
    str_chat_common_9=[[Giỏi thật!]];
    str_chat_common_10=[[Các bạn chơi vui  nhé . mình nghỉ chút !]];
    str_chat_common_11=[[Lại bị rơi mạng, buồn thật!]];
    str_chat_common_12=[[Đừng cãi nhau nữa, tập trung chơi bài nào!]];
    str_chat_common_13=[[Lần sau nhé, em có việc đây]];
    str_chat_common_14=[[Chán]];
    str_chat_common_15=[[Bạn thật là đối thủ của tôi!]];
    str_chat_common_16=[[Chết, muốn Bỏ bài mà bấm nhầm Thêm cược!]];
    str_chat_common_17=[[Trời ơi, thế này cũng được à!]];
    str_chat_common_18=[[Má ơi, chia bài tốt được không?]];
    str_chat_common_19=[[Xin lỗi, mình có tý việc!]];

    str_chat_network_weak = "Mạng chậm, mời bạn thử lại sau";

    str_room_gold_card_play_emotion = "Bạn phải có đạo cụ thẻ vàng mới có thể dùng vẻ mặt này.";
    str_login_become_vip = "Trở thành VIP";
    str_room_chat_alert_cancel = "Hủy";
    str_play_emotion_tips = "Nhắc nhở hệ thống";
    str_room_sit_down_play_emotion = "Bạn phải ngồi xuống trước mới có thể sử dụng vẻ mặt.";	

    str_superLotto_desc0 = "Mua xổ số sẽ mất ";
    str_superLotto_desc1 = "20M";
    str_superLotto_desc2 = " chip/lần, bạn sẽ được chia\nthưởng pot theo tỷ lệ khi trúng kiểu bài như sau.";

    str_superLotto_title = "xổ số";
    str_superLotto_click = "Bấm và xem thêm";
    str_superLotto_get = "";
    str_superLotto_pool = " Pot thưởng";

    str_superLotto_auto_buy             = "Tự động mua";
    str_superLotto_buy_next_round       = "Mua ván sau";
    str_superLotto_bought_next_round    = "Đã mua ván sau";
    str_superLotto_reward_list          = "Danh sách";

    str_superLotto_not_in_seat          = "Bạn ngồi xuống mới mua xổ số được.";
    str_superLotto_buy_next_success     = "Bạn đã mua thành công xổ số ván này.";

    str_superLotto_rule_title           = "Điều kiện trúng thưởng";
    str_superLotto_rule_desc            = "Nếu trúng kiểu bài khi ván bài kết thúc, bạn có thể chia thưởng pot. (Nhiều người cùng lúc trúng với kiểu bài như nhau thì chia đều pot)";
    str_superLotto_rule_remark1          = "Lưu ý:";
    str_superLotto_rule_remark2          = "5 lá bài chung";
    str_superLotto_rule_remark3          = "Kiểu bài đến lúc so bài mới có hiệu lực và thắng Xổ số";

    str_superLotto_reward_title = "Chúc bạn thắng được xổ số";
    str_superLotto_reward_geting = "Đang nhận thưởng…";
    str_superLotto_reward_percent_num = "Nhận được %d%% chip thưởng pot Xổ số:";
    str_superLotto_reward_pattern = "Kiểu bài cảu bạn: ";

    str_superLotto_reward_success = "Chip thưởng đã được gửi.";

    str_superLotto_reward_list_title = "Danh sách";
    str_superLotto_reward_list_win = "Thắng: ";

    str_superLotto_money_not_enough = "Chip mua vào của bạn không đủ, xin bổ sung chip trước.";
    str_superLotto_system_error              = "Xẩy ra lỗi, xin thử lại.";  

    str_dealer_change_dealer = "Đổi nhà cái";
    str_dealer_send_tips = "Cho tiền";
    str_dealer_title = "Cài đặt dealer";
    str_dealer_set_dealer = "Chọn tôi";
    str_dealer_desc = "Mỗi ván thu %d%% Big blind làmTips";
    str_dealer_free_service  = "Phục vụ miễn phí";               --免費服務
    str_dealer_no_money    = "Xin lỗi, chip ngoài của bạn chưa đủ."; 
    str_dealer_sit_down_send_chips = "Ngồi xuống trước mới tặng chip được.";

    str_room_dealer_speak_array = { --荷官互動
        [1] = "Chúc bạn thắng được nhiều tiền!{0}";
        [2] = "Chúc bạn may mắn mãi mãi!{0}";
        [3] = "Bạn tốt bùng thế!{0}";
        [4] = "Rất vui được phục vụ cho bạn!{0}";
        [5] = "Chân thành cảm ơn!{0}";
    };

    str_chatPop_edit_hint = "Bấm và viết vào nội dung chat";
    str_chatPop_normal_type = "Chat";
    str_chatPop_smallSpeaker_type = "Loa nhỏ";
    str_chatPop_bigSpeaker_type = "Loa to";
    str_chatPop_buy_speaker = "Mua loa";
    str_room_chat_trumpet_not_enough = "Số loa nhỏ không đủ";
    str_room_no_small_trumpet = "Chưa có loa nhỏ";				--無小喇叭
    str_room_no_big_trumpet	= "Chưa có loa to";				--無大喇叭
    str_room_chat_too_quick	= "Nhắn tin quá thường xuyên, mời bạn thử lại sau";				

    str_private_create_failure = "Xin lỗi, phòng riêng chỉ dành cho VIP. Trở thành VIP còn có thể nhận thêm chip thưởng hàng ngày, miễn phí sử dụng biểu cảm, két bạc";-- 私人房提示开通VIP
    str_private_create_success = "Chúc mừng bạn đã hoàn thành!";
    str_private_room_id        = "ID Phòng riêng: %s";
    str_private_create_success_title = "Lập thành công";
    str_private_create_success_desc ="Bạn bè truy cập ID phòng có thể vào phòng cùng chơi với bạn.";
    str_private_create_blind_num = "Small/Big blind %s/%s";
    str_private_create_carry_num = "Mang vào tối thiểu/đa: %s/%s";
    str_private_create_title       = "Lập phòng riêng";
    str_private_create_name        = "Tên phòng:";
    str_private_create_type        = "Loại phòng:";
    str_private_create_blind_carry = "Blind/Mang:";
    str_private_create_player_num  = "Số người:";
    str_private_create_speed       = "Tốc độ ra bài:";
    str_private_create_password    = "Mật khẩu";
    str_private_create_name_desc   = "Phòng của %s";
    str_private_pwd_input_tips     = "Room %s là phòng riêng, yêu cầu nhập vào mật khẩu mới vào được";
    str_private_input_pwd          = "Hãy nhập mật khẩu phòng:";
    str_private_motify_pwd         = "Sửa mật khẩu";
    str_private_pwd                = "Mật khẩu phòng riêng: ";
    str_private_input_new_pwd      = "Viết vào mật khẩu mới:";                          
    str_private_input_pwd_placeholder  = "Tối đa 16 chữ";
    str_private_motify_pwd_placeholder = "Tối đa 16 chữ, để trống sẽ coi như không đặt mật khẩu";
    str_private_pwd_error       = "Mật khẩu sai, hãy nhập lại!";
    str_private_room_not_exist  = "Xin lỗi, ID phòng này không tồn tại!";
    str_private_input_pwd_again = "Hãy nhập lại mật khẩu";
    str_private_player_five     = "5 người";
    str_private_player_nine     = "9 người";
    str_private_speed_quickly   = "Cao tốc（10s）";
    str_private_speed_normal    = "Phổ thông（20s）";
    str_private_pwd_format_err  = "Mật khẩu sai định dạng! Độ dài tối đa 16 chữ.";
    str_private_create_buyin_fail  = "Chip của bạn thấp hơn chip mua vào tối thiểu của phòng này, xin bổ xung chip trước.";	
    str_private_room_no_password   = "không có mật khẩu";
    str_private_motify_pwd_success = "Đổi mật khẩu thành công!";
    str_private_motify_pwd_failure = "Đổi mật khẩu thất bại!";
    str_private_owner_leave_room   = "Phòng chủ đã đóng phòng nay, phòng sẽ bị đóng sau ván bài kết thúc.";
    str_private_owner_close_room   = "Phòng chơi đã bị hủy do chủ phòng đã rời khỏi.";--私人房房主離開后，回到大廳的彈框
    str_private_room_dismiss_operator = "Phòng chơi sẽ bị hủy sau khi ván bài kết thúc, bạn xác nhận hủy phòng không?";--解散房間

        
    -- 3.2.0mtt
    str_new_mtt_help_title = "Luật chơi MTT";
    str_new_mtt_help_desc_title = "MTT là gì?";--什麼是mtt
    str_new_mtt_help_desc_content = "MTT viết tắt từ Multi-Table Tournament, nhiều bàn chơi tiến hành giải đấu cùng lúc, bàn chơi sẽ được dần dần giảm đi khi người chơi bị loại. Người chơi cuối cùng sẽ được về giải nhất và giải đấu kết thúc!";
    str_new_mtt_help_rule_title = "Luật chơi MTT";--mtt規則
    str_new_mtt_help_rule_content = "1. Số người đăng ký không đủ, giải đấu sẽ hủy và hoàn lại phí báo danh.\n2. Mọi người chơi sẽ được chia số stack khởi đầu như nhau trước khi bắt đầu giải đấu. (Stack đây khác với chip ở sân chơi phổ thông)\n3. Ante: Số chip bắt buộc phải đặt trước khi ván bài.\n4. Rebuy: Khi số stack dưới stack khởi đầu trong giai đoạn blinds chỉ định, bạn có thẻ dùng chip để rebuy lần nữa.\n5. Addon: Mua vào lần cuối ở giai đoạn blinds chỉ định để tăng thêm số stack trong giải đấu.\n6. Xếp hạng theo thứ tự bị loại, người bị loại đầu tiên xếp hạng cuối, nếu bị loại cùng lúc, hệ thống sẽ tính thứ tự dựa vào độ mạnh bài và số stack.\n7. Hủy đăng ký hoặc không vào đấu đúng giờ sẽ chỉ được hoàn lại phí báo danh.\n8. Trong giải đấu không có chế độ đăng ký muộn, nếu chỉ có 1 người tham gia khi đến giờ đấu, giải đấu sẽ bị hủy và không vào muộn được nữa.\n\nChúc bạn may mắn trong giải đấu! ";

    str_hall_tournament_apply_succ				= "Bạn đã đăng ký thành công, xin tham giờ đúng giờ.";				--報名成功提示
    str_hall_tournament_apply_fail				= "Đăng ký thất bại";				--報名失敗
    str_hall_tournament_apply_succ1				= "Báo danh thành công";				--報名成功
    str_hall_tournament_apply_tip1				= "Xin lỗi, đăng ký đã kết thúc.";				--對不起，報名已截止。
    str_hall_tournament_apply_tip2				= "Xin lỗi, số người đã đủ.";				--對不起，報名名額已滿。
    str_hall_tournament_apply_tip3				= "Xin lỗi, bạn không phụ hợp điều kiện.";				--對不起，您未滿足報名條件。
    str_hall_tournament_apply_tip4				= "Xin lỗi, đăng ký thất bại, xin thử lại.";				--報名失敗，請稍後重試。
    str_hall_tournament_apply_same_ip				= "Bạn vi phạm quy tắc công bằng của trò chơi, không thể đăng ký lại nữa.";				--相同ip不能報名
    str_hall_tournament_apply_not_enough_by				= "Chip Coalaa của bạn không đủ, xin bạn bổ xung chip coalaa trước.";				--金幣不足
    str_hall_tournament_apply_not_enough_chip				= "Chip của bạn không đủ, xin bạn bổ xung chip trước.";				--籌碼不足
    str_hall_tournament_apply_not_enough_score				= "Tích phân của bạn ko đủ, đi chơi bài ở sân cao cấp để nhận tích phân nhé";				--積分不足
    str_hall_tournament_apply_not_enough_level              = "LV chưa đặt tiêu chuẩn";--您的等級不夠
    str_hall_tournament_track_error				            = "Xẩy ra lỗi, xin thử lại.";				--追蹤用戶失敗
    str_hall_tournament_apply_not_enough_score2				= "Bạn đang ở Sân cao cấp!";				--您已經在高級場!
    str_common_enter_match_room_tip2_while_playing2				= "Bạn đang chơi bài, xác nhận vào Sân cao cấp sau khi kết thúc ván này không?";--您正在玩牌中，是否在本局結束後進入高級場玩牌？
    str_common_enter_mtt_lobby_while_playing				= "Bạn xác nhận kết thúc ván này ngay và chuyển vào MTT không?";				--您確定要立即結束當前牌局前往MTT嗎？

    str_new_mtt_list_my_ticket = "Bạn có {0} vé";--您擁有{0}張門票
    str_new_mtt_list_my_point = "Điểm giải đấu: {0}";--比赛積分 x{0}
    str_new_mtt_list_my_chip = "Chíp: {0}";--籌碼 x{0}
    str_new_mtt_list_my_coin = "Xu {0}";--卡拉币 x{0}
    str_new_mtt_list_my_point1 = "Điểm của tôi {0}";--您有積分{0}
    str_new_mtt_list_my_chip1 = "Chip: {0}";--您有筹码{0}
    str_new_mtt_list_my_coin1 = "Xu: {0}";--您有卡拉币{0}
    str_new_mtt_list_free = "Miễn phí";--免費
    str_new_mtt_list_apply = "Đăng ký";--報名
    str_new_mtt_list_cancel = "Hủy đăng ký";--取消報名
    str_new_mtt_list_not_cancel = "Không hủy";--不取消了
    str_new_mtt_list_enter = "Vào";--進入
    str_new_mtt_list_watch = "Xem chiến";--旁觀
    str_new_mtt_list_result = "Xem thêm";--結果
    str_new_mtt_list_not_open = "Chưa đối ngoại";--未開放
    str_new_mtt_list_open_tips = "Đối ngoại trước {0}H ";--賽前{0}小時開放
    str_new_mtt_apply_ticket = "Phiếu tham gia x {0}";--門票
    str_new_mtt_match_wait = "Chờ bắt đầu";--等待開始
    str_new_mtt_match_end = "Đã kết thúc";--比賽已結束
    str_new_mtt_match_on = "Đang tiến hành";--比賽進行中
    str_new_mtt_less_of_money			= "Số chíp không đủ";						--您的餘額不足
    str_new_mtt_raise_time_num = "{0} giây";--{0}秒
    str_new_mtt_game_state_rank = "Xếp hạng:{0}";--排名:{0}
    str_new_mtt_game_state_ante = "Ante:{0}";--前注:{0}
    str_new_mtt_game_state_raise = "TG tăng blinds: {0} giây";--漲盲時間:{0}秒
    str_new_mtt_game_state_blind = "Blind:{0}";--盲注:{0}
    str_new_mtt_result_rank = "Chúc bạn giành được top {0} trong cuộc thi đấu";--恭喜你在本次比賽中獲得第{0}名
    str_new_mtt_all_rebuy_time = "Cuộc thi cho phép rebuy {0} lần";--本場次提供{0}次rebuy賽制
    str_new_mtt_left_rebuy_time = "Bạn còn {0} lần cơ hội rubuy";--你還有{0}次rebuy機會
    str_new_mtt_rebut_max_num = "Cuộc thi đấu có thể rebuy, số lần:{0} lần";--可重購比賽，次數:{0}次
    str_new_mtt_addon_max_num = "Cuộc thi đấu có thể add-on, số lần:{0} lần";--可增購比賽，次數:{0}次
    str_new_mtt_cancel_apply_tip = "Nếu bạn hủy đăng ký thì hệ thống chỉ trả lại phí đăng ký, không trả lại phí phục vụ";--取消報名後，將只返回您報名費，不返還服務費
    str_new_mtt_cancel_apply_sure = "Bạn có chắc chắn hủy đăng ký không?";--你確定要取消報名嗎
    str_new_mtt_ok = "Biết rồi";--確定
    str_new_mtt_cancel = "Hủy";--取消
    str_new_mtt_name = "Tên giải đấu";--賽事名稱:
    str_new_mtt_apply_fee = "Phí tham gia";--參賽費用:
    str_new_mtt_apply_time = "TG giải đấu:";--比賽時間:
    str_new_mtt_apply_inspire = "Hệ thống sẽ nhắc nhở bạn khi cuộc thi đấu sắp bắt đầu!\nChúc bạn may mắn!";--比賽開始前將在遊戲內提醒您\n祝您手氣如虹
    str_new_mtt_today = "Hôm nay";--今天
    str_new_mtt_tomorrow = "Ngay mai";--明天
    str_new_mtt_the_day_after_tomorrow = "Ngày kia";--後天
    str_new_mtt_coming = "Sắp bắt đầu";--即將開始
    str_new_mtt_delay_enter = "Vào sau:";--延遲進入
    str_new_mtt_on = "Đang";--進行中
    str_new_mtt_end = "Đã kết thúc";--已結束
    str_new_mtt_main = "Giải đấu của tôi";--已結束
    str_new_mtt_quite = "Thoát ra";--退出比賽
    str_new_mtt_back = "Trở về cuộ thi đấu";--返回比賽
    str_new_mtt_quite_tips = "Bạn sắp thoát ra cuộc thi đấu phải không, sau khi thoát ra sẽ không thể vào lại";--您是否準備退出比賽，退出比賽後\將無法再次進入比賽
    str_new_mtt_lv = "Cấp bậc";--級別
    str_new_mtt_bline = "Blind";--盲注
    str_new_mtt_ante = "Ante";--前注
    str_new_mtt_raise_time = "Tăng Blind";--漲盲時間
    str_new_mtt_match_detail = "Chi tiết";--比賽詳情
    str_new_mtt_rank_no_data = "HIện không có thông tin";--當前沒有資訊
    str_new_mtt_no_result = "Đang tính phần thưởng";--獎勵正在計算中
    str_new_mtt_rank_index = "Xếp hạng";--名次
    str_new_mtt_reward = "Phần thưởng";--獎勵
    str_new_mtt_fixed_reward = "Tối thiểu";--保底
    str_new_mtt_dynamic_reward = "Động thái";--動態
    str_new_mtt_reward_rate = "Số người tham gia*{0}";--參賽人數*{0}
    str_new_mtt_delay_tip = "{0} phút sau khi cuộc thi bắt đầu";--開賽後{0}分鐘
    str_new_mtt_rule_apply_fee = "Phí báo danh:  ";--報名費用:
    str_new_mtt_rule_pool = "Giải thưởng:  ";--比賽獎池:
    str_new_mtt_rule_fixed = "Giải thưởng tối thiểu:  ";--保底獎池:
    str_new_mtt_rule_apply_num = "Số người tham gia:  ";--參賽人數:
    str_new_mtt_rule_reward_rate = "Số người được thưởng:  ";--獲獎人數:
    str_new_mtt_rule_time = "TG giải đấu:  ";--比賽時間:
    str_new_mtt_rule_delay_time = "Đăng ký muộn:  ";--延遲進入:
    str_new_mtt_rule_origal = "Chip khởi đầu:  ";--初始籌碼:
    str_new_mtt_rule_player_limit  = "Giới hạn tối đa:  ";
    str_new_mtt_add_on_title = "Dịch vụ addon";--addon服務
    str_new_mtt_add_on_pool = "Gà thưởng: {0}";--獎池:
    str_new_mtt_add_on_rank = "Xếp hạng: {0}/{1}";--排名:
    str_new_mtt_add_on_tip = "Trận này có thể add on 1 lần";--本場次提供1次-addon賽制
    str_new_mtt_add_on_tip1 = "Thêm chíp ngoài mức quy định";--額外增加當前籌碼
    str_new_mtt_add_on_spent = "Mất:";--花費:
    str_new_mtt_add_on_getchips = "Mua:";--購買:
    str_new_mtt_add_on_ok = "Thêm chíp ";--增加籌碼
    str_new_mtt_add_on_on = "Trở về";--不用了
    str_new_mtt_total_pool = "Gà thưởng ";--總獎池
    str_new_mtt_rebuy_title = "Giải đấu - rebuy";--比賽-rebuy服務
    str_new_mtt_rebuy_goto_match_again = "Vào lại cuộc thi đấu";--再次加入比賽！
    str_new_mtt_get_rwward_title = "Nhận thưởng";--領獎
    str_new_mtt_get_rwward_succ = "GIành được thành công";--成功獲得
    str_new_mtt_get_rwward_chip = "Chíp";--籌碼:
    str_new_mtt_get_rwward_by = "Xu";--金幣:
    str_new_mtt_get_rwward_other = "Khác";--金幣:
    str_new_mtt_get_rwward_point = "Tích phân";--積分:
    str_new_mtt_get_rwward_exp = "EXP";--經驗:
    str_new_mtt_sign_up_point = "{0} Tích phân";--積分:
    str_new_mtt_sign_up_ticket = "Vé";--門票
    str_new_mtt_result_title = "Kết quả";--比賽結果
    str_new_mtt_result_beat = "Kết quả";--比賽結果
    str_new_mtt_result_fighting = "Chúc bạn may mắn lần sau nhé! Cố lên!";--祝您下次好運，加油！
    str_slot_lucky_card = "Số may mắn hôm nay: %s";
    str_slot_win = "Bạn thắng: %s";
    str_slot_auto_play = "Tự động";
    str_slot_prize = "Giải nhất: %s";
    str_slot_luck_rew = "Bạn có thể nhận %s lần chip thưởng nếu trúng số may mắn hôm nay";
    str_slot_luck_tips = "Bài may mắn";
    str_slot_win_untips = "Không hiển thị nữa";
    str_slot_reward_odds = "Tỷ lệ thưởng";
    str_slot_bonus = "Tiền thưởng = phí cược × tỷ lệ thường";	
    str_slot_mag = "%s lần";
    str_slot_luckwin = "<color=#c4d6ec>Bạn sẽ được\nthưởng</c><color=#fafe93>X%s</color><color=#c4d6ec> khi\ntrúng bài may mắn hôm nay</c>";
    str_slot_luck_winmoney = "<color=#c4d6ec> Chúc mừng bạn trúng số may mắn, nhận được </c><color=#fafe93>%s</color><color=#c4d6ec> chip！</c>";
    str_slot_win_money = "<color=#c4d6ec> Chúc mừng bạn đã trúng </c><color=#fafe93>%s</color><color=#c4d6ec>chip! </c>";
    str_slot_fail1 = "<color=#c4d6ec>Số chip của bạn không đủ chơi máy cược</c>";
    str_slot_success = "<color=#c4d6ec>Máy cược đã sẵn sàng, chúc bạn may mắn!</c>";
    str_slot_reconnect = "<color=#c4d6ec>Xin lỗi, hệ thống đang kết nối lại！</c>";
    str_slot_fail2 = "<color=#c4d6ec>Máy cược chưa sẵn sàng, mời bạn thử lại sau！</c>";
    str_slot_fail3 = "<color=#c4d6ec>Xin lỗi, hệ thống đang bị lỗi, mời bạn thử lại sau！</c>";
    str_slot_fail4 = "Xin lỗi, mạng không ổn định!";
    str_new_mtt_result_mail_tips = "Hệ thống sẽ phát phần thường vào e-mail của bạn. Hãy tiếp tục cố lên nhé!";--您的獎勵稍後以郵件的形式發放\n給您。請繼續加油
    str_new_mtt_result_commite = "Gửi";--提交
    str_new_mtt_waiting_for_other = "Đợi bạn khác rebuy({0})";--等待其他玩家rebuy({0})
    str_new_mtt_detail_rule = "Luật thi đấu";--比賽規則
    str_new_mtt_detail_bline = "Luật Blind";--盲注規則
    str_new_mtt_detail_reward = "Phần thưởng";--獎勵分配
    str_new_mtt_detail_rank = "Xếp hạng";--排名
    str_new_mtt_no_rank_data = "Tạm chưa có";--暫無排名數據
    str_new_mtt_hall_label1 = "Số hiệu";--賽事編號
    str_new_mtt_hall_label2 = "Thông tin";--賽事資訊
    str_new_mtt_hall_label3 = "Thời gian";--開賽時間
    str_new_mtt_hall_label4 = "Phí đăng ký";--報名費用
    str_new_mtt_hall_label5 = "Tất cả giải đấu";--報名中
    str_new_mtt_hall_label4 = "Phí đăng ký";--報名費用
    str_new_mtt_hall_label6 = "hot";--熱門賽事
    str_new_mtt_hall_label7 = "Bạn chưa đăng ký!";--您未報名任何賽事!
    str_new_mtt_hall_label8 = "MTT";--多人錦標賽
    str_new_mtt_reward_calculating = "Đang tính phần thưởng...";--獎勵計算中...
    str_new_mtt_short_of_ticket = "Không đủ vé, hãy lựa chọn phương thức khác để đăng ký";--門票不足,請選用其他方式報名
    str_new_mtt_cancel_apply_succ = "Hủy đăng ký thành công";--取消報名成功
    str_new_mtt_apply_need_num = "Yếu cầu số người đăng ký:";--報名人數要求:
    str_new_mtt_rule_before_time = "Vào trước:";--提前進場:
    str_new_mtt_rule_before_time_num = "Vào phòng trước {0} phút";--提前{0}分鐘進場
    str_new_mtt_rule_before_time_num1 = " (  Thời gian vào muộn còn";-- (已進行2分鐘,延遲入場還有3分鐘)
    str_new_mtt_had_applyed = "Đã đăng ký";--已報名
    str_new_mtt_not_inmatch = "Bạn chưa đăng ký thi đấu";--MTT房间内排行榜未参赛提示
    str_common_enter_match_room_tip				= " Cuôc thi đấu mà bạn đã đăng ký sẽ bắt đầu sau {0} phút, bây giờ vào phòng chưa? ";				--您報名的多人錦標賽將在5分鐘後開始！
    str_common_enter_match_room_tip_while_playing				= " Cuôc thi đấu mà bạn đã đăng ký sẽ bắt đầu sau {0} phút, sau ván bài này kết thúc thì vào phòng luôn? ";				--您報名的多人錦標賽將在5分鐘後開始！
    str_common_enter_match_room_tip2_while_playing				= "Cuôc thi đấu mà bạn đã đăng ký sẽ bắt đầu sau {0} phút, bây giờ vào phòng chưa?";				--您報名的多人錦標賽將在5秒後開始！
    str_new_mtt_month= "Tháng";--月
    str_new_mtt_day= "Ngày";--日
    str_room_goon_buy_chips				= "Mua tiếp";				--購買繼續
    str_room_cancle_buy_chips			= "Bỏ";				--放弃
    str_room_goon_addon_chips			= "Thêm chíp ";				--增加籌碼
    str_room_cancle_addon_chips			= "Hủy";				--放棄增加
    str_rebuy_buy_long_7				= "Mua";				--購       買 
    str_rebuy_cost_long_7				= "Mất";				--花       费 
    str_rebuy_over_num			    	= "Còn";				--剩餘次數 
    str_rebuy_total_num				    = "( Tất cả {0} lần )";				--( 總共{0}次 )
    str_room_tournament_start_time_tip				= "Cách thi đấu băt đầu còn có {0}";				--距離比賽開始還有 01:43
    str_room_tournament_start_time_tip2				= "({0} phút sau bắt đầu)";				--({0}分鐘後開賽)
    str_room_tournament_start_time_tip3				= "({0} giờ sau bắt đầu)";				--({0}小時後開賽)
    str_room_tournament_start_time_tip1				= "({0} giây sau bắt đầu)";				--({0}秒後開賽)
    str_room_tournament_start_time_tip4				= "({0} ngày sau bắt đầu)";				--({0}天後開賽)
    str_new_mtt_get_reward_palyer_num	= "Số người được thưởng: ";							--錢圈人數;
    str_room_match_start				= "Bắt đầu thi đấu, chúc bạn may mắn!";				--比賽開始，祝您好運！
    str_room_info_match				= "Ante:{0} SB/BB:{1}/{2} Xếp hạng của tôi:{3}";				--比賽場的房間資訊前注：{0} 小/大盲注: {0}/{1}  我的排名: {2}
    str_new_mtt_enter_fail_reson_1		= "Vì số người đăng ký chưa đạt mức tiêu chuẩn nên kết thúc cuộc thi này";	--因為報名人數未達到要求，比賽結束
    str_new_mtt_enter_fail_reson_2		= "Vì số người ngồi xuông ít hơn 2 người，nên kết thúc cuộc thi này";			--坐下的人數小於2，比賽結束
    str_new_mtt_add_chips_succ			= "Tăng {0} chíp thành công";					--增加{0}籌碼成功
    str_hall_tournament_switch_table_tip			= "Đang đổi bàn...";					--換桌中...
    str_room_blind_chang				= "Vòng sau blind lên đến:{0}/{1}";				--下一輪盲注增加為:20/40

    str_sng_lobby_title = "CTĐVL";
    str_sng_lobby_score_lack = [[Kém người đứng 
trước mình {0} điểm]];
    str_sng_lobby_income = "Thu nhập tháng này";
    str_sng_lobby_total_entries = "Đã tham gia: {0} trận";
    str_sng_lobby_title_tips = "Ngồi đầy {0} người sẽ bắt đầu";	
    str_sng_lobby_mark = "Hot";
    str_sng_lobby_tips ="Ngồi đủ %s người chơi ngay";
    str_sng_lobby_five_changed				= "Đã chuyển tới bàn 5 người";				--已切換到5人桌
    str_sng_lobby_nine_changed				= "Đã chuyển tới bàn 9 người";				--已切換到9人桌
    str_sng_lobby_not_enough_money          ="Chip của bạn không đủ, xin bạn bổ xung chip trước.";
    str_sng_lobby_buy_chips                 ="Mua";
    str_sng_lobby_cancel                    = "Hủy";
    str_sng_lobby_confirm                   = "Xác nhận";
    str_sng_lobby_entry_tips_title          = "Nhắc nhở hệ thống";
    str_sng_lobby_no_nine_table          = "Tạm không có bàn 9 người";
    str_sng_lobby_rule_tips                 = "Đăng ký xong mà không tham gia sẽ chỉ được hoàn về phí đăng ký.";
    str_sng_lobby_help_pop_title            = "Quy tắc của CTĐBĐ";
    str_sng_lobby_help_pop_rule             = "Quy tắc: Chip bắt đầu là 100M, trong quá trình thi đấu không thể mua lại được, chip hết thì bị loại bỏ. Blind ban đầu là 500K/1000K, mỗi 5 phút blind nâng cao 1 lần, đến khi thi đấu kết thúc.";
    str_sng_lobby_help_pop_tips             = "Đăng ký rồi mà ko tham gia thì chỉ được trả lại 80% phí đăng ký.";

    str_sng_reward_pop_username             = "Người chơi: %s";
    str_sng_reward_pop_reward_tips          = "Chúc mừng bạn được vị trí thứ %s";
    str_sng_reward_pop_play_again           = "Chiến lại lần nữa";
    str_sng_reward_pop_back                 = "Về sảnh";
    str_sng_reward_pop_share                = "Chia sẻ";
    str_sng_result_pop_title                = "Kết quả giải đấu";
    str_sng_result_pop_rank_tips            = "Bạn đã được vị trí thứ %s!";
    str_sng_result_pop_result_tips          = "Rất tiếc, bạn đã bị loại!";
    str_sng_room_center_notic               = "Đợi thêm %s người nữa sẽ mở đấu";
    str_sng_result_title                    = "Kết quả thi đấu";
    str_sng_result_rank                     = "Chúc bạn giành được hạng thứ %s!";
    str_sng_match_end                       = "Đã kết thúc";

    str_fb_share_success                    = "Facebook Đã chia sẻ!";
    str_fb_share_cancel                     = "Hủy chia sẻ Facebook!";
    str_fb_share_failed                     = "Chia sẻ thất bại!";

    str_fb_share_other_account              = "Xin lỗi, chức năng chia sẻ chỉ dùng cho tài khoản Facebook!";

    -- 新手教程 start --
    str_beginner_tutorial_msg = { --新手教程禮包獲取文字提示
	    [1] = "Hoanh nghênh bạn đến Poker Pro.VN. Ở đây, bạn sẽ học biết cách chơi của Texas poker. Hoàn thành giáo trình sẽ nhận được phần thưởng nhiều!";
	    [2] = "Trên ván bán sẽ được chia thành 3 vòng phát ra 5 bài chung(5 bài này mọi người đều có thể nhìn thấy).";
	    [3] = "Dùng 2 tờ bài tay kết hợp với 5 bài chung, chọn 5 bài tổ thành nhóm kiểu bài lớn nhất, so sánh lớn bé với nhà chơi khác.";
	    [4] = "Kiểu bài lớn bé như ảnh bên phải:";
	    [5] = "Bây giờ chúng tôi bắt đầu chơi thử xem.";
	    [6] = "Game bắt đầu, mỗi bạn đều được 2 lá bài tay. Hiện đến bạn thao tác rồi, bạn có thể chọn theo cược, bỏ bài, thêm cược. Bài tay khá tốt, chọn theo cược xem.";
	    [7] = "Nhà chơi A chọn theo cược, nhà chơu B chọn xem bài, hiện đã hoàn thành đặt cược vòng này. Nhà cái phát ra 3 lá bài chung, bây giờ kiểu bài lớn nhất của bạn là một đôi.";
	    [8] = "Nhà chơi A chọn xem bài, nhà chơi B chọn xem bài, đề nghị bạn cũng chọn xem bài xem.";
	    [9] = "Hiện đã hoàn thành đặt cược vòng này. Nhà cái lật bài turn card, bây giờ kiểu bài lớn nhất của bạn là ba lá.";
	    [10] = "Nhà chơi A chọn thêm cược, nhà chơi B chọn bỏ bài, bỏ bài thì chip đã đặt cược sẽ ko thu về được. Lần này đề nghị bạn chọn theo cược.";
	    [11] = "Phát ra bài cuối cùng(River card), ôi, Kiểu bài của bạn là tứ quý. Chắc lớn hơn kiểu bài của nhà chơi A.";
	    [12] = "Nhà chơi A chọn thêm cược, kiểu bài lớn thế, đề nghị bạn chọn All in đi.";
	    [13] = "Nhà chơi A chọn theo cược, haaaa YES, Nhà chơi A chỉ có hai đôi, bạn thắng rồi!";
	    [14] = "Click nhà cái có thể đổi và tặng tiền cho nhà cái. Click quà có thể tặng quà cho bạn khác.";
    };

	str_beginner_tutorial_tips      				= "Sảnh chúa>Sảnh thông>Tứ quý>Cù lủ>Đồng chất>Sảnh>Ba lá>Hai đôi>Một đôi>Cao bài";
	str_beginner_tutorial_quit_btn_text				= "Thoát ra giáo trình";				--退出
	str_beginner_tutorial_quit_desc_text			= "Hoàn thành hướng dẫn có thể nhận được nhiều phần thưởng, xác định thoát ra ko?";				--退出彈框描述
	str_beginner_tutorial_complete_btn_text			= "Hoàn thành giáo trình";				--完成
	str_beginner_tutorial_poker_order_title			= "Thứ tự lớn bé";				--牌型順序標題
	str_beginner_tutorial_poker_rule_title			= "● Luật chơi ●";				--規則標題
	str_beginner_tutorial_poker_rule_poker_num		= "<color=#C4D5EF>◆Bài: Ngoài bài joker </color><color=#F0EB87>Tận dụng 52 lá bài</color><color=#C4D5EF>。</color>";				--牌數規則
	str_beginner_tutorial_poker_rule_player_num		= "<color=#C4D5EF>◆</color><color=#F0EB87> Số người: 2~9 </color><color=#C4D5EF>,  2 người có thể bắt đầu, tối đa 9 người </color>";				--人數規則
	str_beginner_tutorial_poker_rule_win			= "<color=#C4D5EF>Mục tiêu: </color><color=#F0EB87>thắng chip trong pot.</color><br/><color=#C4D5EF>có 2 cách: </color><br/><color=#C4D5EF>   ◆1：Trong khi so bài</color><color=#F0EB87> Người có bộ bài lớn hơn sẽ thắng. </color><br/><color=#C4D5EF>   ◆2：Khi đặt cược </color><color=#F0EB87>Khiến người chơi khác bỏ bài. </color>";				--贏牌規則
	str_beginner_tutorial_popup_title				= "Hướng dẫn nhà chơi mới";				--新手教程彈框標題
	str_beginner_tutorial_start_desc_text			= " Hoanh nghênh bạn đến Poker Pro.VN. Chúng tôi có giáo trình sơ cấp để hướng dẫn bạn giỏi cách chơi. Hoàn thành giáo trình sẽ được phần thưởng sau: ";				--新手教程獎勵描述
	str_beginner_tutorial_complete_desc_text		= " Chúc mừng bạn, bạn đã học hết giáo trình và thu được phần thưởng: ";				--新手教程完成描述
	str_beginner_tutorial_popup_chips				= "{0} chip";				--新手教程籌碼獎勵
	str_beginner_tutorial_popup_exp					= "{0}EXP";				--新手教程經驗獎勵
	str_beginner_tutorial_popup_funny_props			= "{0} đạo cụ giao lưu";				--新手教程互動道具獎勵
	str_beginner_tutorial_popup_quit_btn			= "Thoát ra giáo trình";				--退出新手教程
	str_beginner_tutorial_popup_start_btn			= "Bắt đầu giáo trình";				--開始新手教程
	str_beginner_tutorial_popup_receive_btn			= "Nhận thưởng";				--領取獎勵
	str_beginner_tutorial_public_card_tips_one		= "Lật bài";				--公共牌提示第一輪
	str_beginner_tutorial_public_card_tips_two		= "Turn card";				--公共牌提示第二輪
	str_beginner_tutorial_public_card_tips_three	= "River card";				--公共牌提示第三輪
	str_beginner_tutorial_reveive_reward_seccuess	= "Chúc bạn nhận đuợc phần thưởng thành công!";				--領取獎勵成功
	str_beginner_tutorial_reveive_reward_fail   	= "Xin lỗi, nhận thưởng thất bại.";				--領取獎勵失敗
	str_beginner_tutorial_player_a_name				= "Người chơi A";				--玩家a
	str_beginner_tutorial_player_b_name				= "Người chơi B";				--玩家b
    str_beginner_tutorial_step                         = "Bước {0}";            --第幾步
    
    str_tutoria_popup_title				= "Hướng dẫn nhà chơi mới";				--新手教程彈框標題
    str_tutoria_start_desc_text				= " Hoanh nghênh bạn đến Poker Pro.VN. Chúng tôi có giáo trình sơ cấp để hướng dẫn bạn giỏi cách chơi. Hoàn thành giáo trình sẽ được phần thưởng sau: ";				--新手教程獎勵描述
    str_tutoria_complete_desc_text				= " Chúc mừng bạn, bạn đã học hết giáo trình và thu được phần thưởng: ";				--新手教程完成描述
    str_tutoria_popup_chips				= "{0} chip";				--新手教程籌碼獎勵
    str_tutoria_popup_exp				= "{0} EXP";				--新手教程經驗獎勵
    str_tutoria_popup_funny_props				= "{0} đạo cụ giao lưu";				--新手教程互動道具獎勵
    -- 新手教程 end   --
    -- 新手奖励 start --
    str_login_novice_reward_title				= { --第{0}天
        [1] = "Ngày thứ 1";
        [2] = "Ngày thứ 2";
        [3] = "Ngày thứ 3";
    };
    str_login_novice_reward_btn_text				= "Nhận gói quà";				--領取新手禮包
    -- 新手奖励 end --

    str_new_mtt_detail_tab_race_info    = "TT giải đấu";
    str_new_mtt_detail_tab_blind_struct = "Kết cấu Blinds";
    str_new_mtt_detail_tab_reward       = "Phần thưởng";
    str_new_mtt_detail_tab_rank         = "Xếp hạng";

    str_new_mtt_detail_rebuy            = "Tình hình rebuy:  ";
    str_new_mtt_detail_addon            = "Add on cuối cùng:  ";
    str_new_mtt_detail_rebuy_time       = "Có thể rebuy {0} lần";
    str_new_mtt_detail_addon_time       = "Có thể add on {0} lần";
    str_new_mtt_detail_player_limit_num = "{0} ~ {1} người";

    str_new_mtt_detail_dynamic_desc       = "Cơ cấu giải  giải thưởng cuối cùng sẽ công bố sau khi kết thúc giai đoạn đăng ký muộn. ( Tính từ số người rebuy và addon)";
    str_new_mtt_detail_additional            = "Thưởng ngoại lệ: ";
    str_new_mtt_detail_unit_chips               = "{0} chip";
    str_new_mtt_detail_unit_colaa               = "{0} Xu";
    str_new_mtt_detail_unit_point                = "{0} tích phân";
    str_room_operation_timeout_text				= "Chạm màn hình để về game. Bạn sẽ tự động đứng lên sau {0}";				--您已暫離，點擊螢幕回到遊戲。{0}後將自動站起！

    str_new_mtt_detail_rank_index          = "Xếp hạng";
    str_new_mtt_detail_rank_player          = "Bạn chơi";
    str_new_mtt_detail_rank_chips          = "Chíp";

    str_new_mtt_result_defeat       = "Đã đánh bại ";
    str_new_mtt_result_defeat_player = " người";

    str_new_mtt_result_ob = "Khán già tiếp";
    str_new_mtt_result_back = "Trở về sảnh";
    str_new_mtt_result_good_luck= "Chúc may mắn lần sau!";
    str_new_mtt_result_defeat_offset = "Bạn sẽ lọt vào top thưởng sau khi đánh bại {0} người nữa";
    str_new_mtt_other_result_rank = "Thứ {0}";
    
    
    -- str_new_mtt_detail_anti       = "Ante";
    -- str_new_mtt_detail_rise_time      = "Tăng Blind";
    str_room_game_review_players = "Bạn chơi";
    str_room_game_review_handcard = "Bài tay";
    str_room_game_review_publiccard = "Đầu 3 lá";
    str_room_game_review_publiccard1 = "Trước đầu 3 lá";
    str_room_game_review_turncard = "Turn card";
    str_room_game_review_rivercard = "River card";
    str_room_game_review_public = "Bài chung";

    str_room_card_type_result			= { --牌型
        [1] = "Cao bài";
        [2] = "Cao bài";
        [3] = "Bài đôi";
        [4] = "Hai đôi";
        [5] = "Ba lá";
        [6] = "Sảnh";
        [7] = "Đồng hoa";
        [8] = "Cù lủ";
        [9] = "Tứ quý";
        [10] = "Sảnh thông";
        [11] = "Sảnh chúa";
    };
    
    str_max = "Tối đa";
    str_min = "Tối thiểu";
    str_max_buy = "Mua vào tối đa";
    str_min_buy = "Mua vào tối thiểu";
    str_current_money = "Số dư: %s";
    str_auto_buyIn = "Tự động mua vào khi chip chưa đủ.";
    str_buyIn = "Mua vào ngồi xuống";
    str_keybackpop_title = "Nhắc nhở hệ thống";
    str_keybackpop_describe1 = "Bạn có thể thu được chip miễn phí qua những cách sau";
    str_keybackpop_describe2 = "Mai đăng nhập lại nhận nhiều phần thưởng khác nhé.";
    str_keybackpop_wheelLabel = "ĐQMM ";
    str_keybackpop_dailyTaskLabel = "Nhiệm vụ";
    str_keybackpop_newestActLabel = "Hoạt động mới nhất";
    str_keybackpop_backGame = "Trở về game";
    str_keybackpop_loginout = "Xác định thoát ra";

    str_social_config = {              --分享配置
        ["dailyLogin"] = {                          
            name = "Texas Poker Pro Vietnam";                       
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi đã đăng nhập game #Texas Poker Pro Vietnam# {0} ngày , nhận được phần thưởng {1}, mau đến chơi cùng với chúng tôi nhé！";                     
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/get2.png";                        
            link    = shareStoreUrl;                   
        };                          
                                    
        ["dailyTask"] = {                           
            name = "Texas Poker Pro Vietnam";                       
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi đã hoàn thành {0} nhiệm vụ tại game #Texas Poker Pro Vietnam# , nhận được phần thưởng {1}, mau đến chơi cùng với chúng tôi nhé!";                        
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/rank.png";                        
            link = shareStoreUrl;                      
        };                          
                                    
        ["newestAct"] = {                           
            name = "Texas Poker Pro Vietnam";                       
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Hoạt động #Texas Poker Pro Vietnam#{0} đang đưcọ tiến hành hot, mau đến chơi cùng với chúng tôi nhé!";                       
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/gift.png";                        
            link = shareStoreUrl;                      
        };                          
                                    
        ["actWheelNoReward"] = {                            
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "GIới thiệu một game rất hay , #Texas Poker Pro Vietnam#, quay bánh quay may mắn để nhận thưởng miễn phí mỗi ngày";                               
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/lottery10m.png";                              
            link = shareStoreUrl;                              
        };                              
                                    
        ["actWheelGotReward"] = {                               
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi quay được {0} ở bánh quay may mắn của game #Texas Poker Pro Vietnam#, mau đến chơi với chúng tôi nhé!";                              
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/lottery10m.png";                              
            link = shareStoreUrl;                              
        };                              
                                    
        ["gloryGot"] = {                                
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi vừa đạt được {0} thành quả ở game #Texas Poker Pro Vietnam#, mau đến chơi với chúng tôi nhé!";                               
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/rankinvite.png";                              
            link = shareStoreUrl;                              
        };                              
                                        
        ["statWin"] = {                             
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi vừa thắng được {0} chíp ở game #Texas Poker Pro Vietnam#, mau đến chơi với chúng tôi nhé!";                              
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/allin.jpg";                               
            link = shareStoreUrl;                              
        };                              
                                    
        ["changeDealer"] = {                                
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Giới thiệu mạnh mẽ game #Texas Poker Pro Vietnam#, còn có thể đổi nhà cái, làm thỏa mãn nhu cầu của bạn!";
            picture = "https://d21w0fxhsbogha.cloudfront.net/static/ipokersa/images/mobile/heguanfeedpic1.png";
            link = shareStoreUrl;                              
        };                              
                                    
        ["levelUp"] = {                             
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi vừa thăng cấp {0} thành công ở game #Texas Poker Pro Vietnam#, mau đến chơi với chúng tôi nhé!";                             
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/newlevelup.png";                              
            link = shareStoreUrl;                              
        };                              
                                    
        ["cardType"] = {                                
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi thắng tất cả mọi người bằng kiểu bài {0} ở game #Texas Poker Pro Vietnam#, có dám đến khiêu chiến không?";                               
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/{0}.png";                             
            link = shareStoreUrl;                              
        };                              
                                    
        ["winningStreak"] = {                               
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Tôi thắng liên tục {0} ván ở game #Texas Poker Pro Vietnam#, thực lực được chứng minh qua sự thật, có dám đến khiêu chiến với toi không?";                               
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/{0}.png";                             
            link = shareStoreUrl;                              
        };                              
                                    
        ["collectGift"] = {                             
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                            
            message = "Tôi thu thập được một con rối quý báu ở game #Texas Poker Pro Vietnam#, bạn cũng muốn thu thập không?";                              
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/collect_gift_{0}.png";                                
            link = shareStoreUrl;                              
        };                              
                                    
        ["newYearRedPack"] = {                              
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Muốn chia sẻ lì xì này với bạn!";                                
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/newyearfeed.jpg";                             
            link = shareStoreUrl;                              
        };                              
                                    
        ["ActDiamondFeed"] = {                              
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Giải chưa, tôi giành được {0} trong event ‘Chơi bài kiếm kim cương’! Hâm mộ tôi chứ!";                               
            picture = "http://elexcdndexing-a.akamaihd.net/static/ipokertw/images/bigfeed/DiaMond.png";                             
            link = shareStoreUrl;                              
        };                              
                                    
        ["matchHall"] = {                               
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                                
            message = "Giỏi thật! Bạn giành được top {0} trong cuộc thi đấu, nhận được {1} chíp! ";                             
            picture = "http://cfuncstatic-a.akamaihd.net/static/ipokertw/images/bigfeed/taotaisai.png";                             
            link = shareStoreUrl;                              
        };                              
                                    
        ["iniviteCode"] = {                             
            name = "Texas Poker Pro Vietnam";                               
            caption = "Game bài hay nhất và chuyên ngành nhất!";                        
            message = "Bạn rủ được bạn {0} vào game, nhận được phần thưởng rủ bạn{1}. ";                                
            picture = "http://cfuncstatic-a.akamaihd.net/static/ipokertw/images/bigfeed/s_inviteCode.png";                              
            link = shareStoreUrl;                                  
        };              
    };

    str_friend_invite_friends_page_title				= "Rủ chơi bài";				--邀請好友頁面標題
    str_friend_already_invited  				        = "Đã rủ";			    	--已邀請
    str_friend_invited          				        = "Rủ";			    	--邀請
    str_friend_friend_popup_invite_succ 				= "Gửi lời mới thành công.";			--邀請好友成功
    str_friend_chips                    				= "Chíp:%s";				    --籌碼
    str_friend_inGame_invite_tip	        			= "Bạn %s rủ bạn cùng chơi bài, chấp nhận thì sẽ tự động đổi phòng sau ván này kết thúc.";				--遊戲中收到好友邀請
    str_friend_outGame_invite_tip	        			= "Bạn %s rủbạn cùng chơi bài, chấp nhận luôn?";				--不在遊戲中收到好友邀請
    str_friend_invite_accept    	        			= "Chấp nhận";				--接受
    str_activity_newest_empty				= "Tạm thời chưa có hoạt động";				--暫無活動
    
    str_receive_invite_tips                             = "Bạn đã chuyển vào phòng chơi %s đang ở";


    str_task_recieve_reward = "Nhận thưởng";
    str_task_chip = "Chíp";
    str_task_double_exp = "Exp x2";
    str_task_running = "Đang tiến hành";
    str_task_finished = "Hoàn thành";
    str_task_finish_tips = "Chúc mừng hoàn thành";
    str_task_vip1 = "VIP đồng";
    str_task_vip2 = "VIP bạc";
    str_task_vip3 = "VIP vàng";
    str_task_vip4 = "VIP kim cương";
    str_task_funFace = "ĐCGL";
    str_task_gift = "Quà";

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
        {[1] = "一",[2]="壹"},
    
    };
    str_update_loading = "Đang tải...",
    str_common_tutoria_popup_quit_btn				= "Thoát ra giáo trình";				--退出新手教程
    str_common_tutoria_popup_start_btn				= "Bắt đầu giáo trình";				--开始新手教程
    str_common_tutoria_popup_receive_btn				= "Nhận thưởng";				--领取奖励
 
    str_room_game_review_pop_up_title				= "Ván bài xem lại";				--牌局回顾
    str_room_game_review_pop_up_no_review_tips		= "chưa có kỷ lục ván bài";				--暂无牌局记录
    
    str_privacy_policy_title = "Điều khoản riêng tư";
    str_privacy_policy_agree = "Đồng ý";
    str_common_number				= "%sLần";				--次数

}

return BYString