local BatMask = {
    C_PLAYER = 0x1;  -- 刚体掩码值
    C_FLOOR = 0x2;
    C_SLOPE = 0x4;

    CT_PLAYER = 0xf;    -- 接触掩码
    CT_FLOOR = 0x3;
    CT_SLOPE = 0x5;

    CL_PLAYER = 0x7;    -- 碰撞掩码
    CL_FLOOR = 0x3;
    CL_SLOPE = 0x5;
}


return BatMask