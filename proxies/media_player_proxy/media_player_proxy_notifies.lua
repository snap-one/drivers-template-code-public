--[[=============================================================================
    Notification Functions sent to the MediaPlayer proxy from the driver

    Copyright 2021 Snap One LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.media_player_proxy_notifies = "2021.07.07"
end


function NOTIFY.MEDIAPLAYER_CAPABILITIES_CHANGED(BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_CAPABILITIES_CHANGED")
	SendNotify("CAPABILITIES_CHANGED", {}, BindingID)
end

function NOTIFY.MEDIAPLAYER_VOLUME_LEVEL_CHANGED(Level, OutputID, BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_VOLUME_LEVEL_CHANGED")
	
	VolumeLevelParms = {}
	VolumeLevelParms["LEVEL"] = tostring(Level)
	VolumeLevelParms["OUTPUT"] = tostring(OutputID)
	
	SendNotify("VOLUME_LEVEL_CHANGED", VolumeLevelParms, BindingID)
end

function NOTIFY.MEDIAPLAYER_ON(BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_ON")
	SendNotify("ON", {}, BindingID)
end

function NOTIFY.MEDIAPLAYER_OFF(BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_OFF")
	SendNotify("OFF", {}, BindingID)
end


function NOTIFY.MEDIAPLAYER_PLAY(BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_PLAY")
	SendNotify("PLAY", {}, BindingID)
end

function NOTIFY.MEDIAPLAYER_STOP(BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_STOP")
	SendNotify("STOP", {}, BindingID)
end

function NOTIFY.MEDIAPLAYER_PAUSE(BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_PAUSE")
	SendNotify("PAUSE", {}, BindingID)
end


function NOTIFY.MEDIAPLAYER_UPDATE_PROGRESS_SCAN_MEDIA(MediaXML, BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_UPDATE_PROGRESS_SCAN_MEDIA")
	-- Need to wrap up the media here.  Not sure how to do it yet.
	SendNotify("UPDATE_PROGRESS_SCAN_MEDIA", {}, BindingID)
end

function NOTIFY.MEDIAPLAYER_SET_PTT_URL(Url, Protocol, BindingID)
	LogTrace("NOTIFY.MEDIAPLAYER_SET_PTT_URL")

	PttUrlParms = {}
	PttUrlParms["URL"] = tostring(Url)
	PttUrlParms["PROTOCOL"] = tostring(Protocol)

	SendNotify("SET_PTT_URL", {}, BindingID)
end

