--[[=============================================================================
    Notification Functions sent to the Receiver proxy from the driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.receiver_proxy_notifies = "2021.06.18"
end

function NOTIFY.REC_ON(BindingID)
	LogTrace("NOTIFY.REC_ON")
	SendNotify("ON", {}, BindingID)
end


function NOTIFY.REC_OFF(BindingID)
	LogTrace("REC_NOTIFY.REC_OFF")
	SendNotify("OFF", {}, BindingID)
end


function NOTIFY.REC_AV_BINDINGS_CHANGED(BindingID)
	LogTrace("REC_NOTIFY.REC_AV_BINDINGS_CHANGED")
	SendNotify("AV_BINDINGS_CHANGED", {}, BindingID)
end


function NOTIFY.REC_INPUT_OUTPUT_CHANGED(InputBinding, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_INPUT_OUTPUT_CHANGED")

	Parms = {}
	Parms["INPUT"] = tostring(InputBinding)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("INPUT_OUTPUT_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_SURROUND_MODE_CHANGED(SurroundMode, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_SURROUND_MODE_CHANGED")

	Parms = {}
	Parms["SURROUND_MODE"] = tostring(SurroundMode)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("SURROUND_MODE_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_VOLUME_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_VOLUME_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("VOLUME_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_BASS_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_BASS_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("BASS_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_TREBEL_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_TREBEL_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("TREBEL_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_BALANCE_LEVEL_CHANGED(Level, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_BALANCE_LEVEL_CHANGED")
	
	Parms = {}
	Parms["LEVEL"] = tostring(Level)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("BALANCE_LEVEL_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_LOUDNESS_CHANGED(Loudness, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_LOUDNESS_CHANGED")
	
	Parms = {}
	Parms["LOUDNESS"] = tostring(Loudness)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("LOUDNESS_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_MUTE_CHANGED(Mute, OutputBinding, BindingID)
	LogTrace("NOTIFY.REC_MUTE_CHANGED")
	
	Parms = {}
	Parms["MUTE"] = tostring(Mute)
	Parms["OUTPUT"] = tostring(OutputBinding)

	SendNotify("MUTE_CHANGED", Parms, BindingID)
end


function NOTIFY.REC_AUDIO_PARAMETER_CHANGED(BindingID)
	LogTrace("NOTIFY.REC_AUDIO_PARAMETER_CHANGED")
	
	SendNotify("AUDIO_PARAMETER_CHANGED", {}, BindingID)
end


