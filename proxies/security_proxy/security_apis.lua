--[[=============================================================================
    File is: security_apis.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
	
	API calls for developers using security partition template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_apis = "2020.06.19"
end

--===============================================================================


function SetAllPartitionsOffline()

	LogTrace("SetAllPartitionsOffline")
	for _, CurPartition in pairs(SecurityPartitionIndexList) do
		if(CurPartition:IsEnabled()) then
			CurPartition:SetPartitionState(AS_OFFLINE, "")
		end
	end
end


--[[=============================================================================
    GetPartitionZoneIDs(PartitionID)

    Description: 
    Get the list of zone IDs that are associated with the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are getting the list from

    Returns:
    A table containing a list of the zone numbers for the specified partition
===============================================================================]]
function GetPartitionZoneIDs(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetZoneIDs()
	else
		LogWarn("GetPartitionZoneIDs  Undefined PartitionID: %s", tostring(PartitionID))
		return nil
	end
end

--[[=============================================================================
    GetPartitionZoneCount(PartitionID)

    Description: 
    Get the count of the zones that are associated with the zone

    Parameters:
    PartitionID(int) - The index of the partition we are getting the count from

    Returns:
    The zone count for the associated partition
===============================================================================]]
function GetPartitionZoneCount(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetZoneCount()
	else
		LogWarn("GetPartitionZoneCount  Undefined PartitionID: %s", tostring(PartitionID))
		return 0
	end
end


--[[=============================================================================
    PartitionContainsZone(PartitionID, ZoneID)

    Description: 
    Tells if the given zone is a member of the given partition

    Parameters:
    PartitionID(int) - The index of the partition we are checking
    ZoneID(int)      - The id of the zone we are checking

    Returns:
    True if the partition contains the zone; False if it doesn't
===============================================================================]]
function PartitionContainsZone(PartitionID, ZoneID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:ContainsZone(ZoneID)
	else
		LogWarn("PartitionContainsZone  Undefined PartitionID: %s", tostring(PartitionID))
		return false
	end
end

--[[=============================================================================
    SetPartitionInitializingFlag(PartitionID, InitializingFlag)

    Description: 
    Marks the specified partition as currently being initialized. Some behaviours
    are different if a setting is happening for the first time

    Parameters:
    PartitionID(int)       - The index of the partition we are enabling or disabling
    InitializingFlag(bool) - True if the partition is currently being initialized

    Returns:
    None
===============================================================================]]
function SetPartitionInitializingFlag(PartitionID, InitializingFlag)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetInitializingFlag(InitializingFlag)
	else
		LogWarn("SetPartitionInitializingFlag  Undefined PartitionID: %s", tostring(PartitionID))
	end
end


function GetPartitionInitializingFlag(PartitionID)
	local RetVal = false

	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		RetVal = SecurityPartitionIndexList[tonumber(PartitionID)]:GetInitializingFlag()
	else
		LogWarn("GetPartitionInitializingFlag  Undefined PartitionID: %s", tostring(PartitionID))
	end
	
	return RetVal
end

--[[=============================================================================
    IsPartitionEnabled(PartitionID)

    Description: 
    Identifies whether or not the specified partition is enabled

    Parameters:
    PartitionID(int) - The index of the partition we are checking

    Returns:
    True if the partition is enabled
===============================================================================]]
function IsPartitionEnabled(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsEnabled()
	else
		LogWarn("IsPartitionEnabled  Undefined PartitionID: %s", tostring(PartitionID))
		return false
	end
end

--[[=============================================================================
    GetPartitionState(PartitionID)

    Description:
    Get the state of the partition that was specified by the given PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the state from

    Returns:
    The state of the partition specified by the PartitionID
    Following are a list of states that should be returned (ARMED, ALARM, 
    DISARMED_NOT_READY, DISARMED_READY, EXIT_DELAY, and ENTRY_DELAY)
===============================================================================]]
function GetPartitionState(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetPartitionState()
	else
		LogWarn("GetPartitionState  Undefined PartitionID: %s", tostring(PartitionID))
		return AS_DISARMED_READY
	end
end

--[[=============================================================================
    GetPartitionStateType(PartitionID)

    Description: 
    Get the state type of the partition that was specified by the given PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the state type from

    Returns:
    The description of the state for the partition specified by the PartitionID
===============================================================================]]
function GetPartitionStateType(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetPartitionStateType()
	else
		LogWarn("GetPartitionStateType  Undefined PartitionID: %s", tostring(PartitionID))
		return "UNKNOWN"
	end
end

--[[=============================================================================
    SetCodeRequiredToArm(PartitionID, CodeRequired)

    Description: 
    Tells the system that the given partition requires a code to arm.

    Parameters:
    PartitionID(int)   - The index of the partition we are specifiying the status
    CodeRequired(bool) - True if a code is required to arm the partition, and
                         false otherwise.

    Returns:
    None
===============================================================================]]
function SetCodeRequiredToArm(PartitionID, CodeRequired)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetCodeRequiredToArm(CodeRequired)
	else
		LogWarn("SetCodeRequiredToArm  Undefined PartitionID: %s", tostring(PartitionID))
	end
end

--[[=============================================================================
    IsCodeRequiredToArm(PartitionID)

    Description: 
    Reports if currently a code is required to am the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are asking about

    Returns:
    True if a code is required to arm the partition, and false otherwise.
===============================================================================]]
function IsCodeRequiredToArm(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsCodeRequiredToArm()
	else
		LogWarn("IsCodeRequiredToArm  Undefined PartitionID: %s", tostring(PartitionID))
		return false
	end
end

--[[=============================================================================
    IsPartitionArmed(PartitionID)

    Description: 
    Returns the armed state of the partition indicated by PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting the armed
                       status for

    Returns:
    The armed state of the partition specified
===============================================================================]]
function IsPartitionArmed(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsArmed()
	else
		LogWarn("IsPartitionArmed  Undefined PartitionID: %s", tostring(PartitionID))
		return false
	end
end

--[[=============================================================================
    IsPartitionInDelay(PartitionID)

    Description: 
    Returns the delay information for the partition indicated by PartitionID

    Parameters:
    PartitionID(int) - The index of the partition we are getting delay
                       information for

    Returns:
    True if the Partition is currently in a delay state, false otherwise
===============================================================================]]
function IsPartitionInDelay(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:IsInDelay()
	else
		LogWarn("IsPartitionInDelay  Undefined PartitionID: %s", tostring(PartitionID))
		return false
	end
end


--[[=============================================================================
    HaveEmergency(EmergencyName)

    Description: 
    Notifies all partitions that an emergency has been triggered.

    Parameters:
    EmergencyName(string) - The type of emergency that is being triggered.
                            Current Emergency Types: 
                            Fire, Medical, Police, and Panic.
                            However other strings could be sent if desired. The
                            UI just may not have icons for them

    Returns:
    None
===============================================================================]]
function HaveEmergency(EmergencyName)
	for _, v in pairs(SecurityPartitionIndexList) do
		v:HaveEmergency(EmergencyName)
	end
end

--[[=============================================================================
    PartitionRequestAdditionalInfo(PartitionID, Prompt, ParmList, FunctionName, MaskData, InterfaceID)

    Description: 
    Provides a mechanism to ask the UI for the given partition to provide more
    info, the most common use case would be if a user code or an installers code
    would be required to complete a desired action.

    Parameters:
    PartitionID(int)     - The index of the partition to provide the new information.
    Prompt(string)       - The prompt that the UI will display when asking for the
                           additional information.
    ParmList(string)     - A string of current information that will be passed
                           along as the new information is requested and then passed
                           back to this driver. This string would contain information
                           as to what the driver should do with the new information.
                           Usually it would indicate which routine should be called
                           and what parameters should be passed to that routine.
    FunctionName(string) - The name of the function to be called on return.
    MaskData(boolean)    - True the input off the keypad will be obscured when 
                           entering data, False the input will be visiable
    InterfaceId(string)  - A unique string identifying which interface this
                           request is being sent to. Usually this would be the
                           InterfaceId paramater given to the command that is
                           requesting more info.  An empty string is also legal
                           the command will be acted upon by all navigator 
                           interfaces.
===============================================================================]]
function PartitionRequestAdditionalInfo(PartitionID, Prompt, ParmList, FunctionName, MaskData, InterfaceId)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:RequestAdditionalInfo(tostring(Prompt), ParmList, tostring(FunctionName), toboolean(MaskData), tostring(InterfaceId))
	else
		LogWarn("PartitionRequestAdditionalInfo  Undefined PartitionID: %s", tostring(PartitionID))
	end
end

--[[=============================================================================
    SetDefaultUserCode(PartitionID, NewCode)

    Description: 
    Provides a mechanism to store a default user code for times when the user
    will be unavailable(i.e. Composer programming events)

    Parameters:
    PartitionID(int) - The index of the partition to provide the new information.
    NewCode(string)  - The default user code that will be provided when there is 
                       no user to provide the input.
===============================================================================]]
function SetDefaultUserCode(PartitionID, NewCode)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetDefaultUserCode(NewCode)
	else
		LogWarn("SetDefaultUserCode  Undefined PartitionID: %s", tostring(PartitionID))
	end
end

--[[=============================================================================
    GetDefaultUserCode(PartitionID)

    Description: 
    Returns the stored default user code

    Parameters:
    PartitionID(int) - The index of the partition to provide the new information.
===============================================================================]]
function GetDefaultUserCode(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetDefaultUserCode()
	else
		LogWarn("GetDefaultUserCode  Undefined PartitionID: %s", tostring(PartitionID))
		return ""
	end
end


function SetInterfaceID(PartitionID, NewInterfaceID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetInterfaceID(NewInterfaceID)
	else
		LogWarn("SetInterfaceID  Undefined PartitionID: %s", tostring(PartitionID))
	end
end


function GetInterfaceID(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:GetInterfaceID()
	else
		LogWarn("GetInterfaceID  Undefined PartitionID: %s", tostring(PartitionID))
		return ""
	end
end


function RequestDefaultUserCode(PartitionID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		return SecurityPartitionIndexList[tonumber(PartitionID)]:RequestDefaultUserCode()
	else
		LogWarn("RequestDefaultUserCode  Undefined PartitionID: %s", tostring(PartitionID))
		return ""
	end
end



