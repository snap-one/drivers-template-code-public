--[[=============================================================================
    File is: media_player_main.lua

    Copyright 2021 Snap One LLC. All Rights Reserved.
===============================================================================]]

require "media_player_proxy.media_player_device_class"
require "media_player_proxy.media_player_reports"
require "media_player_proxy.media_player_apis"
require "media_player_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.media_player_main = "2021.07.07"
end

TheMediaPlayerList = {}

function CreateMediaPlayerProxy(BindingID)
	NewMediaPlayer = MediaPlayerDevice:new(BindingID, NextMediaPlayerIndex)

	if(NewMediaPlayer ~= nil) then
		NewMediaPlayer:InitialSetup()
	else
		LogFatal("CreateMediaPlayerProxy  Failed to instantiate MediaPlayer")
	end
end


