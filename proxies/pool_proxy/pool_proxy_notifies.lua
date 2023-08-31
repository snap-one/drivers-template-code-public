--[[=============================================================================
    File is: pool_proxy_notifies.lua

    Notification Functions sent to the Pool proxy from the driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_proxy_notifies = "2023.03.14"
end


function NOTIFY.SCALE_CHANGED(Scale, BindingID)
	LogTrace("NOTIFY.SCALE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.SCALE_CHANGED: %s %d", tostring(Scale), tonumber(BindingID))
	Params["SCALE"] = Scale

	SendNotify("SCALE_CHANGED", Params, BindingID)
end

function NOTIFY.NUM_AUXS(AuxCount, BindingID)
	LogTrace("NOTIFY.NUM_AUXS")
	local Params = {}

	LogTrace("NOTIFY.NUM_AUXS: %s %d", tostring(AuxCount), tonumber(BindingID))
	Params["AUXS"] = tostring(AuxCount)

	SendNotify("NUM_AUXS", Params, BindingID)
end

function NOTIFY.POOL_PUMPMODE_LIST_CHANGED(PoolmodesList, BindingID)
	LogTrace("NOTIFY.POOL_PUMPMODE_LIST_CHANGED: %s %d", tostring(PoolmodesList), tonumber(BindingID))
	SendNotify("POOL_PUMPMODE_LIST_CHANGED", PoolmodesList, BindingID)
end

function NOTIFY.SPA_PUMPMODE_LIST_CHANGED(SpamodesList, BindingID)
	LogTrace("NOTIFY.SPA_PUMPMODE_LIST_CHANGED: %s %d", tostring(SpamodesList), tonumber(BindingID))
	SendNotify("SPA_PUMPMODE_LIST_CHANGED", SpamodesList, BindingID)
end

function NOTIFY.SPA_MODE_CHANGED(SpaMode, BindingID)
	LogTrace("NOTIFY.SPA_MODE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.SPA_MODE_CHANGED: %s %d", tostring(SpaMode), tonumber(BindingID))
	Params["SPAMODE"] = SpaMode

	SendNotify("SPA_MODE_CHANGED", Params, BindingID)
end

function NOTIFY.PUMP_MODE_CHANGED(PumpMode, BindingID)
	LogTrace("NOTIFY.PUMP_MODE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.PUMP_MODE_CHANGED: %s %d", tostring(PumpMode), tonumber(BindingID))
	Params["PUMPMODE"] = PumpMode

	SendNotify("PUMP_MODE_CHANGED", Params, BindingID)
end

function NOTIFY.PUMP_BUTTON_STATE_CHANGED(IsEnabled, ButtonText, BindingID)
	LogTrace("NOTIFY.PUMP_BUTTON_STATE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.PUMP_BUTTON_STATE_CHANGED: %s %s %d", tostring(IsEnabled), tostring(ButtonText), tonumber(BindingID))
	Params["ENABLED"] = tostring(IsEnabled)
	Params["TEXT"] = ButtonText

	SendNotify("PUMP_BUTTON_STATE_CHANGED", Params, BindingID)
end

function NOTIFY.POOL_SETPOINT_CHANGED(PoolSetpoint, BindingID)
	LogTrace("NOTIFY.POOL_SETPOINT_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.POOL_SETPOINT_CHANGED: %s %d", tostring(PoolSetpoint), tonumber(BindingID))
	Params["SETPOINT"] = PoolSetpoint

	SendNotify("POOL_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.SPA_SETPOINT_CHANGED(SpaSetpoint, BindingID)
	LogTrace("NOTIFY.SPA_SETPOINT_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.SPA_SETPOINT_CHANGED: %s %d", tostring(SpaSetpoint), tonumber(BindingID))
	Params["SETPOINT"] = SpaSetpoint

	SendNotify("SPA_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.POOL_TEMP_CHANGED(PoolTemperature, BindingID)
	LogTrace("NOTIFY.POOL_TEMP_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.POOL_TEMP_CHANGED: %s %d", tostring(PoolTemperature), tonumber(BindingID))
	Params["TEMPERATURE"] = tostring(PoolTemperature)

	SendNotify("POOL_TEMP_CHANGED", Params, BindingID)
end

function NOTIFY.SPA_TEMP_CHANGED(SpaTemperature, BindingID)
	LogTrace("NOTIFY.SPA_TEMP_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.SPA_TEMP_CHANGED: %s %d", tostring(SpaTemperature), tonumber(BindingID))
	Params["TEMPERATURE"] = SpaTemperature

	SendNotify("SPA_TEMP_CHANGED", Params, BindingID)
end

function NOTIFY.AIR_TEMP_CHANGED(AirTemperature, BindingID)
	LogTrace("NOTIFY.AIR_TEMP_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.AIR_TEMP_CHANGED: %s %d", tostring(AirTemperature), tonumber(BindingID))
	Params["TEMPERATURE"] = AirTemperature

	SendNotify("AIR_TEMP_CHANGED", Params, BindingID)
end

function NOTIFY.AUX_NAMES_CHANGED(AuxNames, BindingID)
	LogTrace("NOTIFY.AUX_NAMES_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.AUX_NAMES_CHANGED: %s %d", tostring(AuxNames), tonumber(BindingID))
	Params["AUXNAMES"] = AuxNames

	SendNotify("AUX_NAMES_CHANGED", Params, BindingID)
end

function NOTIFY.AUX_TYPES_CHANGED(AuxTypes, BindingID)
	LogTrace("NOTIFY.AUX_TYPES_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.AUX_TYPES_CHANGED: %s %d", tostring(AuxTypes), tonumber(BindingID))
	Params["AUXTYPES"] = AuxTypes

	SendNotify("AUX_TYPES_CHANGED", Params, BindingID)
end

function NOTIFY.AUXMODE_CHANGED(AuxMode, BindingID)
	LogTrace("NOTIFY.AUXMODE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.AUXMODE_CHANGED: %s %d", tostring(AuxMode), tonumber(BindingID))
	Params["AUXMODE"] = AuxMode

	SendNotify("AUXMODE_CHANGED", Params, BindingID)
end

function NOTIFY.POOL_HEATMODE_LIST_CHANGED(PoolHeatmodesList, BindingID)
	LogTrace("NOTIFY.POOL_HEATMODE_LIST_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.POOL_HEATMODE_LIST_CHANGED: %s %d", tostring(PoolHeatmodesList), tonumber(BindingID))
	Params["POOL_HEATMODES"] = PoolHeatmodesList

	SendNotify("POOL_HEATMODE_LIST_CHANGED", Params, BindingID)
end

function NOTIFY.SPA_HEATMODE_LIST_CHANGED(SpaHeatmodesList, BindingID)
	LogTrace("NOTIFY.SPA_HEATMODE_LIST_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.SPA_HEATMODE_LIST_CHANGED: %s %d", tostring(SpaHeatmodesList), tonumber(BindingID))
	Params["SPA_HEATMODES"] = SpaHeatmodesList

	SendNotify("SPA_HEATMODE_LIST_CHANGED", Params, BindingID)
end

function NOTIFY.SPA_HEATMODE_CHANGED(SpaHeatmode, BindingID)
	LogTrace("NOTIFY.SPA_HEATMODE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.SPA_HEATMODE_CHANGED: %s %d", tostring(SpaHeatmode), tonumber(BindingID))
	Params["HEATMODE"] = SpaHeatmode

	SendNotify("SPA_HEATMODE_CHANGED", Params, BindingID)
end

function NOTIFY.POOL_HEATMODE_CHANGED(PoolHeatmode, BindingID)
	LogTrace("NOTIFY.POOL_HEATMODE_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.POOL_HEATMODE_CHANGED: %s %d", tostring(PoolHeatmode), tonumber(BindingID))
	Params["HEATMODE"] = PoolHeatmode

	SendNotify("POOL_HEATMODE_CHANGED", Params, BindingID)
end

function NOTIFY.OPTIONS(Options, BindingID)
	LogTrace("NOTIFY.OPTIONS")
	local Params = {}

	LogTrace("NOTIFY.OPTIONS: %s %d", tostring(Options), tonumber(BindingID))
	Params["OPTIONS"] = Options

	SendNotify("OPTIONS", Params, BindingID)
end

function NOTIFY.HASSPA_CHANGED(HasSpa, BindingID)
	LogTrace("NOTIFY.HASSPA_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.HASSPA_CHANGED: %s %d", tostring(HasSpa), tonumber(BindingID))
	Params["HASSPA"] = tostring(HasSpa)

	SendNotify("HASSPA_CHANGED", Params, BindingID)
end

function NOTIFY.HASAIR_CHANGED(HasAir, BindingID)
	LogTrace("NOTIFY.HASAIR_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.HASAIR_CHANGED: %s %d", tostring(HasAir), tonumber(BindingID))
	Params["HASAIR"] = tostring(HasAir)

	SendNotify("HASAIR_CHANGED", Params, BindingID)
end

function NOTIFY.HASPOOL_CHANGED(HasPool, BindingID)
	LogTrace("NOTIFY.HASPOOL_CHANGED")
	local Params = {}

	LogTrace("NOTIFY.HASPOOL_CHANGED: %s %d", tostring(HasPool), tonumber(BindingID))
	Params["HASPOOL"] = tostring(HasPool)

	SendNotify("HASPOOL_CHANGED", Params, BindingID)
end

