--[[=============================================================================
	File is: relay_communicator.lua
    Functions to manage the communication with the Control4 Relay code
	
    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_relay = "2018.10.16"
end


function C4DeviceRelayOpen(TargRelay)
	LogTrace("C4DeviceRelayOpen  (%s)", TargRelay:GetDeviceName())
	
end


function C4DeviceRelayClose(TargRelay)
	LogTrace("C4DeviceRelayClose  (%s)", TargRelay:GetDeviceName())
	
end


function C4DeviceRelayToggle(TargRelay)
	LogTrace("C4DeviceRelayToggle  (%s)", TargRelay:GetDeviceName())
	
end


function C4DeviceRelayTrigger(TriggerTime, TargRelay)
	LogTrace("C4DeviceRelayToggle  (%s)  Time: %d", TargRelay:GetDeviceName(), tonumber(TriggerTime))
	
end


