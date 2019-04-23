--[[--ldoc desc
@module ChooseMTTorSNGpop
@author JamesLiang

Date   2018-12-13
]]

local PopupBase = import("app.common.popup").PopupBase
local ViewScene = import("framework.scenes").ViewScene;

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ChooseMTTorSNGpop = class("ChooseMTTorSNGpop",ViewScene);
BehaviorExtend(ChooseMTTorSNGpop);

function ChooseMTTorSNGpop:ctor()
	ViewScene.ctor(self);
	self:bindCtr(require(".ChooseMTTorSNGCtr"));
	self:init();
end

function ChooseMTTorSNGpop:init()
	self.m_root = self:loadLayout('creator/chooseSNGorMTT/chooseSNGorMTT.ccreator')
	self:addChild(self.m_root)
    self:initScene()
end

function ChooseMTTorSNGpop:initScene()
    self.m_mttBtn = g_NodeUtils:seekNodeByName(self.m_root,"mttBtn")
	self.m_mttSprite = g_NodeUtils:seekNodeByName(self.m_root,"mtt_textImage")
	self.m_sngBtn = g_NodeUtils:seekNodeByName(self.m_root,"sngBtn")
    self.m_sngSprite = g_NodeUtils:seekNodeByName(self.m_root,"sng_textImage")
    self.m_backBtn = g_NodeUtils:seekNodeByName(self.m_root,"btn_back")
    self.m_mttImg = g_NodeUtils:seekNodeByName(self.m_root,"mtt_textImage")
    self.m_sngImg = g_NodeUtils:seekNodeByName(self.m_root,"sng_textImage")
	
	self.m_mttImg:setTexture(switchFilePath("chooseSNGorMTT/MTT.png"))
	self.m_sngImg:setTexture(switchFilePath("chooseSNGorMTT/SNG.png"))

    self.m_mttBtn:addClickEventListener(function (sender)
        self:onMttBtnClick()
    end)
    self.m_sngBtn:addClickEventListener(function (sender)
        self:onSngBtnClick()
    end)
    self.m_backBtn:addClickEventListener(function (sender)
	    cc.Director:getInstance():popScene()
    end)
end

function ChooseMTTorSNGpop:onMttBtnClick()
    -- self:hidden()
    local mttLobbyScene = import('app.scenes.mttLobbyScene').scene
    cc.Director:getInstance():pushScene(mttLobbyScene:create());
    print("jf_点击mtt btn")
end

function ChooseMTTorSNGpop:onSngBtnClick()
    -- self:hidden()
    local sngLobbyScene = import('app/scenes/sngLobby').SngLobbyScene
    cc.Director:getInstance():pushScene(sngLobbyScene:create());
    print("jf_点击sng btn")
end

return ChooseMTTorSNGpop;