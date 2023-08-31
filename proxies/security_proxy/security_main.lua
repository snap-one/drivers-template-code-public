--[[=============================================================================
    File is: security_main.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "security_proxy.security_device_class"
require "security_proxy.security_reports"
require "security_proxy.security_apis"
require "security_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_main = "2021.09.22"
end

SecurityPartitionIndexList = {}


function CreateSecurityPartitionProxy(BindingID, ProxyInstanceName)
	local NewPartition = SecurityPartition:new(BindingID, ProxyInstanceName)
	
	if(NewPartition ~= nil) then
		NewPartition:InitialSetup()
	else
		LogFatal("CreateSecurityPartitionProxy  Failed to instantiate partition on binding %d", BindingID)
	end
end



