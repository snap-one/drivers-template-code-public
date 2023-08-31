--[[=============================================================================
    File is: pool_proxy_commands.lua    
    Command Functions Received From Pool Proxy to the Driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_proxy_commands = "2023.03.14"
end


---------------------------------------------------------------

function PRX_CMD.GET_STATE_HANDLED(bindingID, tParams)
	LogTrace("PRX_CMD.GET_STATE_HANDLED")
	ProxyInstance(idBinding):PrxGetStateHandled(tParams)
end

function PRX_CMD.SET_AUX_MODE(bindingID, tParams)
	LogTrace("PRX_CMD.SET_AUX_MODE")
	ProxyInstance(idBinding):PrxSetAuxMode(tParams)
end

function PRX_CMD.SET_POOL_HEATMODE(bindingID, tParams)
	LogTrace("PRX_CMD.SET_POOL_HEATMODE")
	ProxyInstance(idBinding):PrxSetPoolHeatmode(tParams)
end

function PRX_CMD.SET_SPA_HEATMODE(bindingID, tParams)
	LogTrace("PRX_CMD.SET_SPA_HEATMODE")
	ProxyInstance(idBinding):PrxSetSpaHeatmode(tParams)
end

function PRX_CMD.SET_POOL_SETPOINT(bindingID, tParams)
	LogTrace("PRX_CMD.SET_POOL_SETPOINT")
	ProxyInstance(idBinding):PrxSetPoolSetpoint(tParams)
end

function PRX_CMD.SET_SPA_SETPOINT(bindingID, tParams)
	LogTrace("PRX_CMD.SET_SPA_SETPOINT")
	ProxyInstance(idBinding):PrxSetSpaSetpoint(tParams)
end

function PRX_CMD.SET_POOL_PUMPMODE(bindingID, tParams)
	LogTrace("PRX_CMD.SET_POOL_PUMPMODE")
	ProxyInstance(idBinding):PrxSetPoolPumpmode(tParams)
end

function PRX_CMD.SET_SPA_PUMPMODE(bindingID, tParams)
	LogTrace("PRX_CMD.SET_SPA_PUMPMODE")
	ProxyInstance(idBinding):PrxSetSpaPumpmode(tParams)
end

function PRX_CMD.AUX_ITEM_ADDED(bindingID, tParams)
	LogTrace("PRX_CMD.AUX_ITEM_ADDED")
	ProxyInstance(idBinding):PrxAuxItemAdded(tParams)
end

function PRX_CMD.AUX_ITEM_UPDATED(bindingID, tParams)
	LogTrace("PRX_CMD.AUX_ITEM_UPDATED")
	ProxyInstance(idBinding):PrxAuxItemUpdated(tParams)
end

function PRX_CMD.AUX_ITEM_REMOVED(bindingID, tParams)
	LogTrace("PRX_CMD.AUX_ITEM_REMOVED")
	ProxyInstance(idBinding):PrxAuxItemRemoved(tParams)
end

function UI_REQ.GET_AUX_LIST(tParams)
	LogTrace("UI_REQ.GET_AUX_LIST")
	return ProxyInstance(idBinding):ReqGetAuxList()
end
