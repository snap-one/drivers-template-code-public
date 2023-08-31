--[[=============================================================================
    File is: security_communicator.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_communicator = "2022.11.21"
end

--[[=============================================================================
    Convert the given arm parameters into the format required by the panel
===============================================================================]]
function SecurityCom_SendArmPartition(PartitionIndex, ArmType, UserCode, Bypass, InterfaceID)
	LogTrace("SecurityCom_SendArmPartition Partition %d  Type is %s", tonumber(PartitionIndex), tostring(ArmType))
	LogDev("UserCode is >>%s<<", tostring(UserCode))
	LogInfo("Security Partition   Send Arm Partition Not Implemented")	-- default
end

--[[=============================================================================
    Convert the given disarm parameters into the format required by the panel
===============================================================================]]
function SecurityCom_SendDisarmPartition(PartitionIndex, UserCode, Bypass, InterfaceID)
	LogTrace("SecurityCom_SendDisarmPartition Partition %d", tonumber(PartitionIndex))
	LogDev("UserCode is >>%s<<", tostring(UserCode))
	LogInfo("Security Partition  Send Disarm Partition Not Implemented")	-- default

end


--[[=============================================================================
    Cancel a pending ARM command
===============================================================================]]
function SecurityCom_ArmCancel(PartitionIndex, InterfaceID)
	LogTrace("SecurityCom_ArmCancel Partition %d", tonumber(PartitionIndex))
	LogInfo("Security Partition  Arm Cancel Not Implemented")	-- default

end


--[[=============================================================================
    Convert the given emergency parameters into the format required by the panel
===============================================================================]]
function SecurityCom_SendExecuteEmergency(PartitionIndex, EmergencyType, InterfaceID)
	LogTrace("SecurityCom_SendExecuteEmergency Partition %d", tonumber(PartitionIndex))
	LogInfo("Security Partition  Send Execute Emergency Not Implemented")	-- default

end

--[[=============================================================================
    Send a single key press from the UI keypad to the hardware
===============================================================================]]
function SecurityCom_SendKeyPress(PartitionIndex, KeyValue, InterfaceID)
	LogTrace("SecurityCom_SendKeyPress Partition %d", tonumber(PartitionIndex))
	LogInfo("Security Partition  Send Key Press Not Implemented")	-- default

end

--[[=============================================================================
    Process additional info that was requested from one of the partition UIs
===============================================================================]]
function SecurityCom_ProcessAdditionalInfo(PartitionIndex, InfoString, NewInfo, FunctionName, InterfaceID)
	LogTrace("SecurityCom_ProcessAdditionalInfo Partition %d", tonumber(PartitionIndex))
	LogInfo("Security Partition  Process Additional Info Not Implemented")	-- default

end

--[[=============================================================================
    Received a Confirmation command
===============================================================================]]
function SecurityCom_SendConfirmation(PartitionIndex, InterfaceID)
	LogTrace("SecurityCom_SendConfirmation for Partition %d", tonumber(PartitionIndex))
	LogInfo("Security Partition  Send Confirmation Not Implemented")	-- default

end



