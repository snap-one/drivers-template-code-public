--[[=============================================================================
    File is: receiver_main.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "receiver_proxy.receiver_device_class"
require "receiver_proxy.receiver_reports"
require "receiver_proxy.receiver_apis"
require "receiver_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.receiver_main = "2021.09.14"
end

TheReceiver = nil		-- can only have one Receiver in a driver

function CreateReceiverProxy(BindingID, ProxyInstanceName)
	if(TheReceiver == nil) then
		TheReceiver = ReceiverDevice:new(BindingID, ProxyInstanceName)

		if(TheReceiver ~= nil) then
			TheReceiver:InitialSetup()
		else
			LogFatal("CreateReceiverProxy  Failed to instantiate Receiver")
		end
	end
end


