--[[=============================================================================
    File is: pool_main.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "pool_proxy.pool_device_class"
require "pool_proxy.pool_reports"
require "pool_proxy.pool_apis"
require "pool_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_main = "2023.03.14"
end

ThePool = nil		-- can only have one Pool in a driver

function CreatePoolProxy(BindingID, ProxyInstanceName)
	if(ThePool == nil) then
		ThePool = Pool:new(BindingID, ProxyInstanceName)

		if(ThePool ~= nil) then
			ThePool:InitialSetup()
		else
			LogFatal("CreatePoolProxy  Failed to instantiate Pool")
		end
	end
end
