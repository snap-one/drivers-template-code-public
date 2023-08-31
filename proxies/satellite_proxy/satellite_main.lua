--[[=============================================================================
    File is: satellite_main.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "satellite_proxy.satellite_device_class"
require "satellite_proxy.satellite_reports"
require "satellite_proxy.satellite_apis"
require "satellite_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.satellite_main = "2021.10.07"
end


function ON_DRIVER_INIT.SatelliteProxySupport(strDit)

	TheSatellite = SatelliteDevice:new(SATELLITE_PROXY_BINDINGID)

	if(TheSatellite ~= nil) then
		TheSatellite:InitialSetup()
	else
		LogFatal("ON_DRIVER_INIT.SatelliteProxySupport  Failed to instantiate satellite")
	end
end


