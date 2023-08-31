--[[=============================================================================
    Notification Functions sent to the AVSwitch proxy from the driver

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.avswitch_proxy_notifies = "2022.10.06"
end

function NOTIFY.AVS_ON(BindingID)
	LogTrace("NOTIFY.AVS_ON")
	SendNotify("ON", {}, BindingID)
end


function NOTIFY.AVS_OFF(BindingID)
	LogTrace("AVS_NOTIFY.AVS_OFF")
	SendNotify("OFF", {}, BindingID)
end

function NOTIFY.AVS_INPUT_OUTPUT_CHANGED(InputBinding, OutputBinding, IsAudio, BindingID)
	LogTrace("NOTIFY.AVS_INPUT_OUTPUT_CHANGED")

	Parms = {}
	Parms["INPUT"] = tostring(InputBinding)
	Parms["OUTPUT"] = tostring(OutputBinding)
	Parms["AUDIO"] = tostring(IsAudio)
	Parms["VIDEO"] = tostring(not IsAudio)

	SendNotify("INPUT_OUTPUT_CHANGED", Parms, BindingID)
end

function NOTIFY.AVS_VOLUME_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.AVS_VOLUME_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("VOLUME_LEVEL_CHANGED", Parms, BindingID)
end

function NOTIFY.AVS_BASS_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.AVS_BASS_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("BASS_LEVEL_CHANGED", Parms, BindingID)
end

function NOTIFY.AVS_TREBEL_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.AVS_TREBEL_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("TREBEL_LEVEL_CHANGED", Parms, BindingID)
end

function NOTIFY.AVS_BALANCE_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.AVS_BALANCE_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("BALANCE_LEVEL_CHANGED", Parms, BindingID)
end

function NOTIFY.AVS_LOUDNESS_CHANGED(Loudness, OutputBinding, BindingID)
	LogTrace("NOTIFY.AVS_LOUDNESS_CHANGED")
	
	Parms = {}
	Parms["LOUDNESS"] = tostring(Loudness)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("LOUDNESS_CHANGED", Parms, BindingID)
end

function NOTIFY.AVS_MUTE_CHANGED(Mute, OutputBinding, BindingID)
	LogTrace("NOTIFY.AVS_MUTE_CHANGED")
	
	Parms = {}
	Parms["MUTE"] = tostring(Mute)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("MUTE_CHANGED", Parms, BindingID)
end


