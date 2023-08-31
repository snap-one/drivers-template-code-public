--[[=============================================================================
    Notification Functions sent to the Tuner proxy from the driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tuner_proxy_notifies = "2021.06.28"
end


function NOTIFY.TUNER_ON(BindingID)
	LogTrace("NOTIFY.TUNER_ON")
	SendNotify("ON", {}, BindingID)
end


function NOTIFY.TUNER_OFF(BindingID)
	LogTrace("NOTIFY.TUNER_OFF")
	SendNotify("OFF", {}, BindingID)
end


function NOTIFY.TUNER_CAPABILITIES_CHANGED(BindingID)
	LogTrace("NOTIFY.TUNER_CAPABILITIES_CHANGED")
	
	SendNotify("CAPABILITIES_CHANGED", {}, BindingID)
end


function NOTIFY.TUNER_CHANNEL_CHANGED(Channel, BindingID)
	LogTrace("NOTIFY.TUNER_CHANNEL_CHANGED")
	
	Parms = {}
	Parms["CHANNEL"] = tostring(Channel)

	SendNotify("CHANNEL_CHANGED", Parms, BindingID)
end


function NOTIFY.TUNER_INPUT_CHANGED(BandType, InputID, MinChannel, MaxChannel, ChannelSpacing, BindingID)
	LogTrace("NOTIFY.TUNER_INPUT_CHANGED")
	
	Parms = {}
	Parms["BANDTYPE"] = tostring(BandType)
	Parms["INPUT"] = tostring(InputID)
	Parms["MINCHANNEL"] = tostring(MinChannel)
	Parms["MAXCHANNEL"] = tostring(MaxChannel)
	Parms["CHANNELSPACING"] = tostring(ChannelSpacing)

	SendNotify("INPUT_CHANGED", Parms, BindingID)
end


function NOTIFY.TUNER_PSN_CHANGED(ProgramStationName, BindingID)
	LogTrace("NOTIFY.TUNER_PSN_CHANGED")
	
	Parms = {}
	Parms["PSN"] = tostring(ProgramStationName)

	SendNotify("PSN_CHANGED", Parms, BindingID)
end


function NOTIFY.TUNER_RADIO_TEXT_CHANGED(RadioText, BindingID)
	LogTrace("NOTIFY.TUNER_RADIO_TEXT_CHANGED")
	
	Parms = {}
	Parms["RADIO_TEXT"] = tostring(RadioText)

	SendNotify("RADIO_TEXT_CHANGED", Parms, BindingID)
end

--[[  Not sure if this is used any more
function NOTIFY.TUNER_MODE_CHANGED(Mode, BindingID)
	LogTrace("NOTIFY.TUNER_MODE_CHANGED")
	
	Parms = {}
	Parms["MODE"] = tostring(Mode)

	SendNotify("MODE_CHANGED", Parms, BindingID)
end

]]