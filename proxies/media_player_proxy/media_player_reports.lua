--[[=============================================================================
    File is: media_player_reports.lua

    Copyright 2021 Snap One LLC. All Rights Reserved.
	
	Routines to report information that we have received from the device.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.media_player_reports = "2021.07.07"
end


---------------------------------------------------------------------------------------


function MediaPlayerReport_PowerOn(MediaPlayerIndex)
	TheMediaPlayerList[MediaPlayerIndex or 1]:SetPowerFlag(true)
end

function MediaPlayerReport_PowerOff()
	TheMediaPlayerList[MediaPlayerIndex or 1]:SetPowerFlag(false)
end

