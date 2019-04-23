local GameReviewPlayerListData = class("GameReviewPlayerListData");
GameReviewPlayerListData.ctor = function(self)
end

GameReviewPlayerListData.dtor = function(self)
end

GameReviewPlayerListData.seatId                 = -1;	--座位id;
GameReviewPlayerListData.uid                    = -1;	--用户id;
GameReviewPlayerListData.name                   = "";	--用户名
GameReviewPlayerListData.seatChips              = 0;	--座位的钱数
GameReviewPlayerListData.betInChips             = 0;	--座位的总下注数
GameReviewPlayerListData.platFlag               = 0;  	--平台标识
GameReviewPlayerListData.isWin                  = false;
GameReviewPlayerListData.isBigWinner            = false;
GameReviewPlayerListData.winChip                = 0;
GameReviewPlayerListData.beforeFlopOperation    = {{},{},{},{},{},{},{},{},{}}     --GameReviewBetData
GameReviewPlayerListData.flopCardOperation      = {{},{},{},{},{},{},{},{},{}};    --GameReviewBetData
GameReviewPlayerListData.turnCardOperation      = {{},{},{},{},{},{},{},{},{}};    --GameReviewBetData
GameReviewPlayerListData.riverCardOperation     = {{},{},{},{},{},{},{},{},{}};    --GameReviewBetData
GameReviewPlayerListData.gameOverData           = nil;
GameReviewPlayerListData.selfSeatId             = 0;
GameReviewPlayerListData.selfCard1              = 0;
GameReviewPlayerListData.selfCard2              = 0;

return GameReviewPlayerListData
