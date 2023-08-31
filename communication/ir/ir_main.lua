--[[=============================================================================
	File is: ir_main.lua
	Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]


require "common.c4_bindings"
require "ir.ir_apis"
require "ir.ir_com"
require "ir_device_specific"		-- in the home directory

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.ir_main = "2022.04.12"
end



TheIRCom = nil


function ON_DRIVER_INIT.IRCommunicationSupport(strDit)

	TheIRCom = IRCom:new()

	if(TheIRCom == nil) then
		LogFatal("ON_DRIVER_INIT.IRCommunicationSupport  Failed to instantiate IR Communication")
	end
end


function ON_BINDING_CHANGED.IRCommunication(idBinding, class, bIsBound)
	if(idBinding == TheIRCom:GetBindingID()) then
		if((DeviceCommunicationStatusChanged ~= nil) and (type(DeviceCommunicationStatusChanged) == "function")) then
			DeviceCommunicationStatusChanged("IR", bIsBound)
		end
	end
end
