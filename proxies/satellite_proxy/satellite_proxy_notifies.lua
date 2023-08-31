--[[=============================================================================
    Notification Functions sent to the Satellite proxy from the driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.satellite_proxy_notifies = "2021.06.15"
end


function NOTIFY.SAT_ON(BindingID)
	LogTrace("NOTIFY.SAT_ON")
	SendNotify("ON", {}, BindingID)
end


function NOTIFY.SAT_OFF(BindingID)
	LogTrace("NOTIFY.SAT_OFF")
	SendNotify("OFF", {}, BindingID)
end


function NOTIFY.SAT_PLAY(BindingID)
	LogTrace("NOTIFY.SAT_PLAY")
	SendNotify("PLAY", {}, BindingID)
end


function NOTIFY.SAT_STOP(BindingID)
	LogTrace("NOTIFY.SAT_STOP")
	SendNotify("STOP", {}, BindingID)
end


function NOTIFY.SAT_PAUSE(BindingID)
	LogTrace("NOTIFY.SAT_PAUSE")
	SendNotify("PAUSE", {}, BindingID)
end


function NOTIFY.SAT_RECORD(BindingID)
	LogTrace("NOTIFY.SAT_RECORD")
	SendNotify("RECORD", {}, BindingID)
end


function NOTIFY.SAT_CHANNEL_CHANGED(NewChannel, BindingID)
	LogTrace("NOTIFY.SAT_CHANNEL_CHANGED")

	ChannelParms = {}
	ChannelParms["CHANNEL"] = tostring(NewChannel)

	SendNotify("CHANNEL_CHANGED", ChannelParms, BindingID)
end


function NOTIFY.SAT_UPDATE_MEDIA_INFO(Title, BindingID)
	LogTrace("NOTIFY.SAT_UPDATE_MEDIA_INFO")

	UpdateMediaInfoParms = {}
	UpdateMediaInfoParms["TITLE"] = tostring(Title)

	SendNotify("", UpdateMediaInfoParms, BindingID)
end



