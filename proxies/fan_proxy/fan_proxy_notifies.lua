--[[=============================================================================
    Notification Functions sent to the Fan proxy from the driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.fan_proxy_notifies = "2023.05.31"
end


function NOTIFY.FAN_ON(BindingID)
	LogTrace("NOTIFY.FAN_ON")
	SendNotify("ON", {}, BindingID)
end


function NOTIFY.FAN_OFF(BindingID)
	LogTrace("NOTIFY.FAN_OFF")
	SendNotify("OFF", {}, BindingID)
end


function NOTIFY.FAN_CURRENT_SPEED(CurSpeed, BindingID)
	LogTrace("NOTIFY.FAN_CURRENT_SPEED")
	Params = {
		SPEED = CurSpeed
	}
	SendNotify("CURRENT_SPEED", Params, BindingID)
end


function NOTIFY.FAN_DIRECTION(CurDirection, BindingID)
	LogTrace("NOTIFY.FAN_DIRECTION")
	
	Params = {
		DIRECTION = CurDirection
	}
	SendNotify("DIRECTION", Params, BindingID)
end


function NOTIFY.PRESET_SPEED(PresetSpeed, BindingID)
	LogTrace("NOTIFY.PRESET_SPEED")
	
	Parms = {
		SPEED = PresetSpeed
	}
	SendNotify("PRESET_SPEED", Parms, BindingID)
end


