local GamePb = {}

GamePb.S_PATH = "app/net/pb/GamePb.pb"

GamePb.method = {
	ReqLogin = 0;
	ReqRegister = 1;
	RpsAuthor = 2;
	RpsUserInfo = 3;
	ReqUserInfo = 4;
}

GamePb.config = {
	[GamePb.method.ReqLogin] = {method = "gamepb.ReqLogin"};
	[GamePb.method.ReqRegister] = {method = "gamepb.ReqRegister"};
	[GamePb.method.RpsAuthor] = {method = "gamepb.RpsAuthor"};
	[GamePb.method.RpsUserInfo] = {method = "gamepb.RpsUserInfo"};
	[GamePb.method.ReqUserInfo] = {method = "gamepb.ReqUserInfo"};
}

g_Protobuf:registerFile(GamePb)

return GamePb