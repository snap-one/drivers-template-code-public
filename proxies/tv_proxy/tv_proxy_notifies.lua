--[[=============================================================================
    Notification Functions sent to the TV proxy from the driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tv_proxy_notifies = "2021.06.18"
end


function NOTIFY.TV_ON(BindingID)
	LogTrace("NOTIFY.TV_ON")
	SendNotify("ON", {}, BindingID)
end


function NOTIFY.TV_OFF(BindingID)
	LogTrace("NOTIFY.TV_OFF")
	SendNotify("OFF", {}, BindingID)
end


function NOTIFY.TV_CAPABILITIES_CHANGED(BindingID)
	LogTrace("NOTIFY.TV_CAPABILITIES_CHANGED")
	
	SendNotify("CAPABILITIES_CHANGED", {}, BindingID)
end


function NOTIFY.TV_CHANNEL_CHANGED(Channel, ChannelString, BindingID)
	LogTrace("NOTIFY.TV_CHANNEL_CHANGED")
	
	Parms = {}
	Parms["CHANNEL"] = tostring(Channel)
	Parms["CHANNEL_STRING"] = tostring(ChannelString)

	SendNotify("CHANNEL_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_INPUT_CHANGED(Input, BindingID)
	LogTrace("NOTIFY.TV_INPUT_CHANGED")
	
	Parms = {}
	Parms["INPUT"] = tostring(Input)

	SendNotify("INPUT_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_VOLUME_LEVEL_CHANGED(Level, BindingID)
	LogTrace("NOTIFY.TV_VOLUME_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)

	SendNotify("VOLUME_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_BASS_LEVEL_CHANGED(Level, BindingID)
	LogTrace("NOTIFY.TV_BASS_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)

	SendNotify("BASS_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_TREBEL_LEVEL_CHANGED(Level, BindingID)
	LogTrace("NOTIFY.TV_TREBEL_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)

	SendNotify("TREBEL_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_BALANCE_LEVEL_CHANGED(Level, BindingID)
	LogTrace("NOTIFY.TV_BALANCE_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)

	SendNotify("BALANCE_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_LOUDNESS_CHANGED(Loudness, BindingID)
	LogTrace("NOTIFY.TV_LOUDNESS_CHANGED")
	
	Parms = {}
	Parms["LOUDNESS"] = tostring(Loudness)

	SendNotify("LOUDNESS_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_MUTE_CHANGED(Mute, BindingID)
	LogTrace("NOTIFY.TV_MUTE_CHANGED")
	
	Parms = {}
	Parms["MUTE"] = tostring(Mute)

	SendNotify("MUTE_CHANGED", Parms, BindingID)
end


function NOTIFY.TV_AUDIO_PARAMETER_CHANGED(BindingID)
	LogTrace("NOTIFY.TV_AUDIO_PARAMETER_CHANGED")
	
	SendNotify("AUDIO_PARAMETER_CHANGED", {}, BindingID)
end


