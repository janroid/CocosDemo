--[[
    此位置用于定义游戏中使用到的常量数据
    注意要定义到const表内才生效
    常量统一使用大写K开头,如：Kxxxxx
    或者:全字母大写表示
]]

local const = {
	-- 点击状态定义
	KDPadTouchNone = -1;
	KDPadTouchDown = 0;
	KDPadTouchMove = 1;
	KDPadTouchUp = 2;

	-- 横竖屏常量定义
	KScrollHorizontal = 0;
	KScrollVertical = 1;

	-- socket状态定义
	SERVER_STATUS_NON = -1; -- 初始状态
	SERVER_STATUS_CONNECTING = 0; -- 开始连接
	SERVER_STATUS_CONNECTED = 1; -- 连接成功
	SERVER_STATUS_CONNECTFAIL = 2; -- 连接失败
	SERVER_STATUS_DISCONNECT = 3; -- 连接断开


	-- socket的服务类型定义
	NET_SOCKET_COMMON = 0;
	NET_SOCKET_IM = 1;
};

-- 动画的常量定义
const.KTransition_Table ={
    CCTransitionJumpZoom = 0,
    CCTransitionProgressRadialCCW = 1,
    CCTransitionProgressRadialCW = 2,
    CCTransitionProgressHorizontal = 3,
    CCTransitionProgressVertical = 4,
    CCTransitionProgressInOut = 5,
    CCTransitionProgressOutIn = 6,
    CCTransitionCrossFade = 7,
    TransitionPageForward = 8,
    TransitionPageBackward = 9,
    CCTransitionFadeTR = 10,
    CCTransitionFadeBL = 11,
    CCTransitionFadeUp = 12,
    CCTransitionFadeDown = 13,
    CCTransitionTurnOffTiles = 14,
    CCTransitionSplitRows = 15,
    CCTransitionSplitCols = 16,
    CCTransitionFade = 17,
    FadeWhiteTransition =  18,
    FlipXLeftOver = 19,
    FlipXRightOver = 20,
    FlipYUpOver = 21,
    FlipYDownOver = 22,
    FlipAngularLeftOver = 23,
    FlipAngularRightOver = 24,
    ZoomFlipXLeftOver = 25,
    ZoomFlipXRightOver = 26,
    ZoomFlipYUpOver = 27,
    ZoomFlipYDownOver = 28,
    ZoomFlipAngularLeftOver = 29,
    ZoomFlipAngularRightOver = 30,
    CCTransitionShrinkGrow = 31,
    CCTransitionRotoZoom = 32,
    CCTransitionMoveInL = 33,
    CCTransitionMoveInR = 34,
    CCTransitionMoveInT = 35,
    CCTransitionMoveInB = 36,
    CCTransitionSlideInL = 37,
    CCTransitionSlideInR = 38,
    CCTransitionSlideInT = 39,
    CCTransitionSlideInB = 40,
};

-- 表示渲染层级
const.KZOrder = {
    Scene = 0;
    POP = 100;
    Anim = 200;
    Alert = 300;
    Progress = 400;
}

return const;