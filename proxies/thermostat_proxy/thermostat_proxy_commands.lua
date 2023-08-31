--[[=============================================================================
    File is: thermostat_proxy_commands.lua    
    Command Functions Received From Thermostat Proxy to the Driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_proxy_commands = "2023.05.09"
end


---------------------------------------------------------------

function PRX_CMD.SET_SETPOINT_HEAT(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_SETPOINT_HEAT")
	ProxyInstance(idBinding):PrxSetSetpointHeat(tParams)
end

function PRX_CMD.SET_SETPOINT_COOL(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_SETPOINT_COOL")
	ProxyInstance(idBinding):PrxSetSetpointCool(tParams)
end

function PRX_CMD.SET_SETPOINT_SINGLE(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_SETPOINT_SINGLE")
	ProxyInstance(idBinding):PrxSetSetpointSingle(tParams)
end

function PRX_CMD.SET_MODE_HVAC(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_MODE_HVAC")
	ProxyInstance(idBinding):PrxSetHVACMode(tParams)
end

function PRX_CMD.SET_MODE_FAN(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_MODE_FAN")
	ProxyInstance(idBinding):PrxSetFanMode(tParams)
end

function PRX_CMD.SET_MODE_HOLD(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_MODE_HOLD")
	ProxyInstance(idBinding):PrxSetHoldMode(tParams)
end

function PRX_CMD.UPDATE_SCHEDULE_ENTRIES(idBinding, tParams)
	LogTrace("PRX_CMD.UPDATE_SCHEDULE_ENTRIES")
	ProxyInstance(idBinding):PrxUpdateScheduleEntries(tParams)
end

function PRX_CMD.SET_SETPOINT_HUMIDIFY(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_SETPOINT_HUMIDIFY")
	ProxyInstance(idBinding):PrxSetSetpointHumidfy(tParams)
end

function PRX_CMD.SET_SETPOINT_DEHUMIDIFY(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_SETPOINT_DEHUMIDIFY")
	ProxyInstance(idBinding):PrxSetSetpointDehumidfy(tParams)
end

function PRX_CMD.SET_VACATION_MODE(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_VACATION_MODE")
	ProxyInstance(idBinding):PrxSetVacationMode(tParams)
end

function PRX_CMD.SET_VAC_SETPOINT_HEAT(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_VAC_SETPOINT_HEAT")
	ProxyInstance(idBinding):PrxSetVacationSetpointHeat(tParams)
end

function PRX_CMD.SET_VAC_SETPOINT_COOL(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_VAC_SETPOINT_COOL")
	ProxyInstance(idBinding):PrxSetVacationSetpointCool(tParams)
end


function PRX_CMD.SET_BUTTONS_LOCK(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_BUTTONS_LOCK")
	ProxyInstance(idBinding):PrxSetButtonsLock(tParams)
end

function PRX_CMD.SET_REMOTE_SENSOR(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_REMOTE_SENSOR")
	ProxyInstance(idBinding):PrxSetRemoteSensor(tParams)
end

function PRX_CMD.SET_SCALE(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_SCALE")
	ProxyInstance(idBinding):PrxSetScale(tParams)
end

function PRX_CMD.SET_PRESETS(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_PRESETS")
	ProxyInstance(idBinding):PrxSetPresets(tParams)
end

function PRX_CMD.SET_EVENTS(idBinding, tParams)
	-- LogTrace("PRX_CMD.SET_EVENTS")
	ProxyInstance(idBinding):PrxSetEvents(tParams)
end











