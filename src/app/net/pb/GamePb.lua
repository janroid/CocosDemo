local GamePb = {}

GamePb.S_PATH = "app/net/pb/GamePb.pb"

GamePb.method = {
    UserLogin = 0;
    LoginResult = 1;

}

GamePb.config = {
    [GamePb.method.UserLogin] = {method = "msg.UserLogin"},
    [GamePb.method.LoginResult] = {method = "msg.LoginResult"},
}

g_Protobuf:registerFile(GamePb)

return GamePb