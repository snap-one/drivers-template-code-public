--[[=============================================================================
    File is: thermostat_main.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "thermostat_proxy.thermostat_device_class"
require "thermostat_proxy.thermostat_reports"
require "thermostat_proxy.thermostat_apis"
require "thermostat_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_main = "2023.05.01"
end

TheThermostat = nil		-- can only have one Thermostat in a driver

function CreateThermostatProxy(BindingID, ProxyInstanceName)
	if(TheThermostat == nil) then
		TheThermostat = Thermostat:new(BindingID, ProxyInstanceName)

		if(TheThermostat ~= nil) then
			TheThermostat:InitialSetup()
		else
			LogFatal("CreateThermostatProxy  Failed to instantiate Thermostat")
		end
	end
end
