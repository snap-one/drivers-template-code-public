--[[=============================================================================
    Security Device Class (Partitions)

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "modules.encryption"
require "security_proxy.security_proxy_commands"
require "security_proxy.security_proxy_notifies"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_device_class = "2021.09.22"
end

SecurityPartitionFunctions = {}


--[[=============================================================================
    ARMED STATES
===============================================================================]]
AS_ARMED					= "ARMED"
AS_ALARM					= "ALARM"
AS_OFFLINE					= "OFFLINE"
AS_EXIT_DELAY				= "EXIT_DELAY"
AS_ENTRY_DELAY				= "ENTRY_DELAY"
AS_DISARMED_READY			= "DISARMED_READY"
AS_DISARMED_NOT_READY		= "DISARMED_NOT_READY"
AS_CONFIRMATION_REQUIRED	= "CONFIRMATION_REQUIRED"

SecurityPartition = inheritsFrom(C4ProxyBase)

SecurityPartition.Count = 0
function SecurityPartition.GetNextIndex()
	SecurityPartition.Count = SecurityPartition.Count + 1
	return SecurityPartition.Count
end


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function SecurityPartition:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._IsEnabled = false
	self._PartitionNumber = SecurityPartition.GetNextIndex()
	self._CurrentPartitionState = "Unknown"
	self._InitializingStatus = true
	self._MyZoneList = {}

	self._DelayTimeTotal = 0
	self._DelayTimeRemaining = 0
	self._OpenZoneCount = 0

	self._CodeRequiredToClear = true
	self._InAlarm = false
	self._CurrentStateType = ""

	self._InterfaceID = ""		-- unique ID of last UI to send us a command
	
	self._PersistData = {}
	
	SecurityPartitionIndexList[self._PartitionNumber] = self
end


function SecurityPartition:InitialSetup()
	local PersistName = string.format("Partition%02dPersist", self._PartitionNumber)

	if(PersistData[PersistName] == nil) then
		self._PersistData._CodeRequiredToArm = false
		self._PersistData._DefaultUserCode = Encryption:AsciiEncryptIt("")
		self._PersistData._DefaultUserCodeIsSet = false
	
		PersistData[PersistName] = self._PersistData
	else
		self._PersistData = PersistData[PersistName]
	end
	
	if(self._PersistData._DefaultUserCodeIsSet) then
		self:RequestDefaultUserCode()	-- proxy has the definitive code
	end
end


function SecurityPartition:SetInitializingFlag(FlagValue)
	self._InitializingStatus = FlagValue
end

function SecurityPartition:GetInitializingFlag()
	return self._InitializingStatus
end


function SecurityPartition:EntryExitDelay(DelayType, DelayActive, TotalTime, RemainingTime)
	local DelayMessage = DelayType .. " Delay"
	local OldTotalTime = self._DelayTimeTotal
	local OldRemainingTime = self._DelayTimeRemaining

	if (DelayActive) then
		-- Delay On
		if (TotalTime == 0) then
			TotalTime = OldTotalTime
		end

		self._DelayTimeTotal = (TotalTime > RemainingTime) and TotalTime or RemainingTime
		self._DelayTimeRemaining = RemainingTime
		DelayMessage = DelayMessage .. " On"
	else
		-- Delay Off
		self._DelayTimeTotal = 0
		self._DelayTimeRemaining = 0
		DelayMessage = DelayMessage .. " Off"
	end

	LogDebug("EntryExitDelay: %s", DelayMessage)
end

function SecurityPartition:PartitionXML()
	local PartitionXMLInfo = {}

	table.insert(PartitionXMLInfo, MakeXMLNode("id", tostring(self._PartitionNumber)))
	table.insert(PartitionXMLInfo, MakeXMLNode("enabled", tostring(self._IsEnabled)))
	table.insert(PartitionXMLInfo, MakeXMLNode("binding_id", tostring(self._BindingID)))
	table.insert(PartitionXMLInfo, MakeXMLAttrNode("state", tostring(self._CurrentPartitionState), "type", tostring(self._CurrentStateType)))

	return MakeXMLNode("partition", table.concat(PartitionXMLInfo, "\n"))
end

function SecurityPartition:NotifyPartitionState()

	LogTrace("Partition %d set to partition state %s : %s Alarm is %s", tonumber(self._PartitionNumber), tostring(self._CurrentPartitionState), tostring(self._CurrentStateType), tostring(self._InAlarm))
	if (self._InitializingStatus) then
		NOTIFY.PARTITION_STATE_INIT(self._CurrentPartitionState, self._CurrentStateType, self._DelayTimeTotal, self._DelayTimeRemaining, self._CodeRequiredToClear, self._BindingID)
	else
		NOTIFY.PARTITION_STATE(self._CurrentPartitionState, self._CurrentStateType, self._DelayTimeTotal, self._DelayTimeRemaining, self._CodeRequiredToClear, self._BindingID)
	end

	TheSecurityPanel:NotifyPartitionState(self._PartitionNumber, self._CurrentPartitionState, self._CurrentStateType)
end

function SecurityPartition:ClearDisplayText()
	NOTIFY.DISPLAY_TEXT("", self._BindingID)
end

function SecurityPartition:SetInterfaceID(NewID)
	self._InterfaceID = NewID
end

function SecurityPartition:GetInterfaceID()
	return self._InterfaceID
end

--[[=============================================================================
    Functions for handling request from the Partition Proxy
===============================================================================]]
function SecurityPartition:PrxGetCurrentState(tParams)
	LogTrace("GetCurrentState for partition %d", tonumber(self._PartitionNumber))
	NOTIFY.PARTITION_STATE_INIT(self._CurrentPartitionState, self._CurrentStateType, self._DelayTimeTotal, self._DelayTimeRemaining, self._CodeRequiredToClear, self._BindingID)
end

function SecurityPartition:PrxPartitionArm(tParams)
	local ArmType = tParams["ArmType"]
	local UserCode = tParams["UserCode"]
	local Bypass = toboolean(tParams["Bypass"])
	self._InterfaceID = tParams["InterfaceID"] or ""

	if (self._InterfaceID == "DirectorProgramming") then
		UserCode = self:GetDefaultUserCode()
	end

	LogTrace("PrxPartitionArm %d %s %s", tonumber(self._PartitionNumber), tostring(ArmType), tostring(Bypass))
	LogDev("UserCode: %s", tostring(UserCode))
	SecurityCom_SendArmPartition(self._PartitionNumber, ArmType, UserCode, Bypass, self._InterfaceID)
end

function SecurityPartition:PrxPartitionDisarm(tParams)
	local UserCode = tParams["UserCode"] or ""
	self._InterfaceID = tParams["InterfaceID"] or ""

	if (self._InterfaceID == "DirectorProgramming") then
		UserCode = self:GetDefaultUserCode()
	end

	LogTrace("PartitionDisarm")
	SecurityCom_SendDisarmPartition(self._PartitionNumber, UserCode, InterfaceID)
end

function SecurityPartition:PrxArmCancel(tParams)
	self._InterfaceID = tParams["InterfaceID"] or ""

	LogTrace("ArmCancel")
	SecurityCom_ArmCancel(self._PartitionNumber, self._InterfaceID)
end

function SecurityPartition:PrxExecuteEmergency(tParams)
	local EmergencyType = tParams["EmergencyType"]
	self._InterfaceID = tParams["InterfaceID"] or ""

	LogTrace("ExecuteEmergency")
	SecurityCom_SendExecuteEmergency(self._PartitionNumber, EmergencyType, self._InterfaceID)
end

function SecurityPartition:PrxExecuteFunction(tParams)
	local FunctionName = tParams["Function"]
	self._InterfaceID = tParams["InterfaceID"] or ""
	local trimmedCommand = string.gsub(FunctionName, " ", "")

	LogTrace("Execute Function (%s) from InterfaceID: %s", tostring(FunctionName), tostring(self._InterfaceID))
	if (SecurityPartitionFunctions[FunctionName] ~= nil and type(SecurityPartitionFunctions[FunctionName]) == "function") then
		SecurityPartitionFunctions[FunctionName](self._PartitionNumber, self._InterfaceID)
	elseif (SecurityPartitionFunctions[trimmedCommand] ~= nil and type(SecurityPartitionFunctions[trimmedCommand]) == "function") then
		SecurityPartitionFunctions[trimmedCommand](self._PartitionNumber, self._InterfaceID)
	else
		LogInfo("ID specified is null or not a function name[%s]", tostring(FunctionName))
	end
end

function SecurityPartition:PrxKeyPress(tParams)
	local KeyName = tParams["KeyName"]
	self._InterfaceID = tParams["InterfaceID"] or ""

	LogTrace("PrxKeyPress")
	SecurityCom_SendKeyPress(self._PartitionNumber, KeyName, self._InterfaceID)
end

function SecurityPartition:PrxAdditionalInfo(tParams)
	local NewInfo = tParams["NewInfo"]
	local InfoString = tParams["InfoString"]
	self._InterfaceID = tParams["InterfaceID"] or ""
	local FunctionName = tParams["FunctionName"]

	SecurityCom_ProcessAdditionalInfo(self._PartitionNumber, InfoString, NewInfo, FunctionName, self._InterfaceID)
end

function SecurityPartition:PrxSetDefaultUserCode(tParams)
	local NewUserCode = tParams["Code"]

	LogDev("PrxSetDefaultUserCode  Code is >>%s<<", NewUserCode)
	self:SetDefaultUserCode(NewUserCode)
end

function SecurityPartition:PrxSendConfirmation(tParams)
	self._InterfaceID = tParams["InterfaceID"] or ""
	SecurityCom_SendConfirmation(self._PartitionNumber, self._InterfaceID)
end

--[[=============================================================================
    Functions that are wrappered and meant to be exposed to the driver
===============================================================================]]
function SecurityPartition:RequestAdditionalInfo(Prompt, InfoStr, FunctionName, MaskData, InterfaceID)
	local UseInterfaceID = ((InterfaceID ~= nil) and (string.len(InterfaceID) > 0)) and InterfaceID or self._InterfaceID
	NOTIFY.REQUEST_ADDITIONAL_INFO(Prompt, InfoStr, FunctionName, MaskData, UseInterfaceID, self._BindingID)
end

function SecurityPartition:ArmFailed(Action, InterfaceID)
	local UseInterfaceID = ((InterfaceID ~= nil) and (string.len(InterfaceID) > 0)) and InterfaceID or self._InterfaceID
	NOTIFY.ARM_FAILED(Action, UseInterfaceID, self._BindingID)
end

function SecurityPartition:DisarmFailed(InterfaceID)
	local UseInterfaceID = ((InterfaceID ~= nil) and (string.len(InterfaceID) > 0)) and InterfaceID or self._InterfaceID
	NOTIFY.DISARM_FAILED(UseInterfaceID, self._BindingID)
end

function SecurityPartition:GetZoneIDs()
	local i = 1
	local s = {}

	for k, _ in pairs(self._MyZoneList) do
		s[i] = k
		i = i + 1
	end

	return s
end

function SecurityPartition:GetZoneCount()
	local i = 0

	for _, _ in pairs(self._MyZoneList) do
		i = i + 1
	end

	return i
end

function SecurityPartition:ContainsZone(ZoneID)
	for _, v in pairs(self._MyZoneList) do
		if (v._ZoneID == ZoneID) then
			return true
		end
	end

	return false
end

function SecurityPartition:AddZone(ZoneID)
	local nZoneID = tonumber(ZoneID)
	local TargZone = ZoneInfoList[nZoneID]

	if (TargZone == nil) then
		ZoneInformation:new(nZoneID)
		TargZone = ZoneInfoList[nZoneID]

		-- force a notification to the panel driver
		TargZone:ZoneInfoChanged()
	end

	self._MyZoneList[ZoneID] = TargZone
	NOTIFY.HAS_ZONE(ZoneID, self._BindingID)
end

function SecurityPartition:RemoveZone(ZoneID)
	local TargZone = ZoneInfoList[tonumber(ZoneID)]

	if (TargZone ~= nil) then
		self._MyZoneList[ZoneID] = nil
		NOTIFY.REMOVE_ZONE(ZoneID, self._BindingID)
	end
end

function SecurityPartition:SetEnabled(Enabled)
	LogTrace("Setting Enabled flag for partition %d to %s", self._PartitionNumber, tostring(Enabled))

	self._IsEnabled = Enabled
	if (not Enabled) then
		self._CurrentPartitionState = "Unknown"
	end

	NOTIFY.PARTITION_ENABLED(self._IsEnabled, self._BindingID)
end

function SecurityPartition:IsEnabled()
	return self._IsEnabled
end

function SecurityPartition:SetPartitionState(NewState, NewStateType, TotalDelayTime, RemainingDelayTime, CodeRequiredToClear)
	local previousState = self._CurrentPartitionState
	local previousStateType = self._CurrentStateType
	local SendChange = ((previousState ~= NewState) or (previousStateType ~= NewStateType))
	local TotDelayTime = TotalDelayTime or 0
	local RemDelayTime = RemainingDelayTime or 0

	LogTrace("Partition %d changed state to %s : %s From %s", tonumber(self._PartitionNumber), tostring(NewState), tostring(NewStateType), tostring(self._CurrentPartitionState))
	self._CurrentPartitionState = NewState
	self._CurrentStateType = NewStateType
	if(self._CurrentStateType  == nil) then
		self._CurrentStateType = ""
	end

	if (self._CurrentPartitionState == AS_ALARM) then
		self._InAlarm = true
		self._CodeRequiredToClear = CodeRequiredToClear or false
	else
		self._InAlarm = false
		self._CodeRequiredToClear = true
	end

	if ((NewState == AS_EXIT_DELAY) or (NewState == AS_ENTRY_DELAY) or (previousState == AS_EXIT_DELAY) or (previousState == AS_ENTRY_DELAY)) then
		local DelayType = ((NewState == AS_EXIT_DELAY) or (previousState == AS_EXIT_DELAY)) and "Exit" or "Entry"
		local DelayActive = ((NewState == AS_EXIT_DELAY) or (NewState == AS_ENTRY_DELAY))

		self:EntryExitDelay(DelayType, DelayActive, TotDelayTime, RemDelayTime)
		SendChange = true
	end

	if (SendChange) then
		if(self._InAlarm) then
			RecordHistoryPartitionAlarm("ALARM!", "", 
									string.format("Partition %d in Alarm: %s", self._PartitionNumber, self._CurrentStateType))
	
		else
			RecordHistoryPartitionEvent("State Change", "", 
									string.format("Partition %d changed to %s", self._PartitionNumber, self._CurrentPartitionState))
		end
		
		self:NotifyPartitionState()
	end
end

function SecurityPartition:HaveEmergency(EmergencyType)
	NOTIFY.EMERGENCY_TRIGGERED(EmergencyType, self._BindingID)
end

function SecurityPartition:DisplayText(Message)
	NOTIFY.DISPLAY_TEXT(Message, self._BindingID)
end

function SecurityPartition:SetCodeRequiredToArm(CodeRequired)
	self._PersistData._CodeRequiredToArm = CodeRequired
	NOTIFY.CODE_REQUIRED(self._PersistData._CodeRequiredToArm, self._BindingID)
end

function SecurityPartition:IsCodeRequiredToArm()
	return self._PersistData._CodeRequiredToArm
end

function SecurityPartition:GetPartitionState()
	return self._CurrentPartitionState
end

function SecurityPartition:GetPartitionStateType()
	return self._CurrentStateType
end

function SecurityPartition:IsArmed()
	return ((self._CurrentPartitionState == AS_ARMED) or
	        (self._CurrentPartitionState == AS_ENTRY_DELAY) or
	        (self._CurrentPartitionState == AS_ALARM))
end

function SecurityPartition:IsInDelay()
	return ((self._CurrentPartitionState == AS_EXIT_DELAY) or
	        (self._CurrentPartitionState == AS_ENTRY_DELAY))
end

function SecurityPartition:SetDefaultUserCode(NewCode)
	if (NewCode ~= nil) then
		LogDev("Setting Default User Code for partition %d  to >>%s<<", self._PartitionNumber, NewCode)
		self._PersistData._DefaultUserCode = Encryption:AsciiEncryptIt(NewCode)
		self._PersistData._DefaultUserCodeIsSet = true
	end
end

function SecurityPartition:GetDefaultUserCode()
	if(self._PersistData._DefaultUserCode ~= nil) then
		return Encryption:AsciiDecryptIt(self._PersistData._DefaultUserCode)
	else
		return ""
	end
end

function SecurityPartition:RequestDefaultUserCode()
	NOTIFY.REQUEST_DEFAULT_USER_CODE(self._BindingID)
end



