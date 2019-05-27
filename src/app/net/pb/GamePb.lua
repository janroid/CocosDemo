local GamePb = {}

GamePb.S_PATH = "app/net/pb/GamePb.pb"

GamePb.method = {
    UserLogin = 0,
	UserRegister = 1, 
	LoginResult = 2,
	GetUserInfo = 3

}

GamePb.config = {
    [GamePb.method.UserLogin] = {method = "gamepb.UserLogin"},
    [GamePb.method.UserRegister] = {method = "gamepb.UserRegister"},
    [GamePb.method.LoginResult] = {method = "gamepb.LoginResult"},
    [GamePb.method.GetUserInfo] = {method = "gamepb.GetUserInfo"},
}

g_Protobuf:registerFile(GamePb)

return GamePb