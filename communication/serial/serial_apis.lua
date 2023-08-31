--[[=============================================================================
	File is: serial_apis.lua
	Copyright 2019 Control4 Corporation. All Rights Reserved.
===============================================================================]]

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.serial_apis = "2019.02.07"
end


function InitializeSerialCommunication(SerBindingID)
	LogTrace("InitializeSerialCommunication")
	TheSerialCom:InitialSetup(SerBindingID)
end

function SerialInitialized()
	return TheSerialCom:IsInitialized()
end


function ClearSerialBuffer()
	TheSerialCom:ClearReceiveBuffer()
end

function SerialMonitor(MonitorFlag)
	TheSerialCom:MonitorIt(MonitorFlag)
end

--==================================================================

function SendSerial(SerData)
	TheSerialCom:SendSerialData(SerData)
end

