--[[=============================================================================
    Command Functions Received From Security Panel Proxy to the Driver

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_proxy_commands = "2022.10.03"
end


---------------------------------------------------------------

function PRX_CMD.READ_PANEL_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.READ_PANEL_INFO")
	ProxyInstance(idBinding):PrxReadPanelInfo(tParams)
end

function PRX_CMD.GET_PANEL_SETUP(idBinding, tParams)
	LogTrace("PRX_CMD.GET_PANEL_SETUP")
	ProxyInstance(idBinding):PrxGetPanelSetup(tParams)
end

function PRX_CMD.GET_ALL_PARTITION_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.GET_ALL_PARTITION_INFO")
	ProxyInstance(idBinding):PrxGetAllPartitionsInfo(tParams)
end

function PRX_CMD.GET_ALL_ZONE_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.GET_ALL_ZONE_INFO")
	ProxyInstance(idBinding):PrxGetAllZonesInfo(tParams)
end


function PRX_CMD.SET_PANEL_TIME_DATE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_PANEL_TIME_DATE")
	ProxyInstance(idBinding):PrxSetTimeDate(tParams)
end

function PRX_CMD.SET_PARTITION_ENABLED(idBinding, tParams)
	LogTrace("PRX_CMD.SET_PARTITION_ENABLED")
	ProxyInstance(idBinding):PrxSetPartitionEnabled(tParams)
end

function PRX_CMD.SET_ZONE_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.SET_ZONE_INFO")
	ProxyInstance(idBinding):PrxSetZoneInfo(tParams)
end

function PRX_CMD.ADDITIONAL_PANEL_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.ADDITIONAL_PANEL_INFO")
	ProxyInstance(idBinding):PrxHandleAdditionalInfo(tParams)
end

