--[[=============================================================================
    File is: fan_main.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "fan_proxy.fan_device_class"
require "fan_proxy.fan_reports"
require "fan_proxy.fan_apis"
require "fan_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.fan_main = "2023.05.31"
end

TheFan = nil		-- can only have one Fan in a driver

function CreateFanProxy(BindingID, ProxyInstanceName)
	if(TheFan == nil) then
		TheFan = FanDevice:new(BindingID, ProxyInstanceName)

		if(TheFan ~= nil) then
			TheFan:InitialSetup()
		else
			LogFatal("CreateFanProxy  Failed to instantiate Fan")
		end
	end
end

--========================================================
