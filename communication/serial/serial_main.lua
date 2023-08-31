--[[=============================================================================
	File is: serial_main.lua
	Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_bindings"
require "serial.serial_apis"
require "serial.serial_com"
require "serial_device_specific"		-- in the home directory

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.serial_main = "2022.04.12"
end



TheSerialCom = nil


function ON_DRIVER_INIT.SerialCommunicationSupport(strDit)

	TheSerialCom = SerialCom:new()

	if(TheSerialCom == nil) then
		LogFatal("ON_DRIVER_INIT.SerialCommunicationSupport  Failed to instantiate Serial Communication")
	end
end

function ON_BINDING_CHANGED.SerialCommunication(idBinding, class, bIsBound)
	if(idBinding == TheSerialCom:GetBindingID()) then
		if((DeviceCommunicationStatusChanged ~= nil) and (type(DeviceCommunicationStatusChanged) == "function")) then
			DeviceCommunicationStatusChanged("Serial", bIsBound)
		end
	end
end

