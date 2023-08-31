--[[=============================================================================
    Command Functions Received From Fan Proxy to the Driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tv_proxy_commands = "2023.05.31"
end

---------------------------------------------------------------

function PRX_CMD.ON(idBinding, tParams)
	LogTrace("PRX_CMD.ON")
	ProxyInstance(idBinding):PrxOn(tParams)
end

function PRX_CMD.OFF(idBinding, tParams)
	LogTrace("PRX_CMD.OFF")
	ProxyInstance(idBinding):PrxOff(tParams)
end


function PRX_CMD.TOGGLE(idBinding, tParams)
	LogTrace("PRX_CMD.TOGGLE")
	ProxyInstance(idBinding):PrxToggle(tParams)
end

function PRX_CMD.DESIGNATE_PRESET(idBinding, tParams)
	LogTrace("PRX_CMD.DESIGNATE_PRESET")
	ProxyInstance(idBinding):PrxDesignatePreset(tParams)
end

function PRX_CMD.SET_SPEED(idBinding, tParams)
	LogTrace("PRX_CMD.SET_SPEED")
	ProxyInstance(idBinding):PrxSetSpeed(tParams)
end

function PRX_CMD.CYCLE_SPEED_UP(idBinding, tParams)
	LogTrace("PRX_CMD.CYCLE_SPEED_UP")
	ProxyInstance(idBinding):PrxCycleSpeedUp(tParams)
end

function PRX_CMD.CYCLE_SPEED_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.CYCLE_SPEED_DOWN")
	ProxyInstance(idBinding):PrxCycleSpeedDown(tParams)
end

function PRX_CMD.SET_DIRECTION(idBinding, tParams)
	LogTrace("PRX_CMD.SET_DIRECTION")
	ProxyInstance(idBinding):PrxSetDirection(tParams)
end

function PRX_CMD.TOGGLE_DIRECTION(idBinding, tParams)
	LogTrace("PRX_CMD.TOGGLE_DIRECTION")
	ProxyInstance(idBinding):PrxToggleDirection(tParams)
end



