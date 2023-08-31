--[[=============================================================================
    File is: security_reports.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_reports = "2020.03.09"
end


---------------------------------------------------------------------------------------

--[[=============================================================================
    SecurityReport_ArmPartitionFailed(PartitionID, Action, InterfaceID)

    Description: 
    Notifies the system that an arm partition has failed, and tells the UI what
    action if any needs to be taken in order to proceed.

    Parameters:
    PartitionID(int)    - The index of the partition we are arming
    Action(string)      - Indicates the action that the UI should take to help 
                          rectify. Following is a list of actions that can be
                          taken keypad(if a keycode is needed), bypass, or
                          NA(general failure)
    InterfaceID(string) - The unique identifier string of the UI which requested
                          the arming action.  We only want that UI to respond to
                          the failed message.

    Returns:
    None
===============================================================================]]
function SecurityReport_ArmPartitionFailed(PartitionID, Action, InterfaceID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:ArmFailed(Action, InterfaceID)
	end
end


--[[=============================================================================
    SecurityReport_DisarmPartitionFailed(PartitionID, InterfaceID)

    Description: 
    Notifies the system that a disarm partition has failed.

    Parameters:
    PartitionID(int)    - The index of the partition we are disarming
    InterfaceID(string) - The unique identifier string of the UI which requested
                          the disarming action. 
                          We only want that UI to respond to the failed message.

    Returns:
    None
===============================================================================]]
function SecurityReport_DisarmPartitionFailed(PartitionID, InterfaceID)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:DisarmFailed(InterfaceID)
	end
end


--[[=============================================================================
    SecurityReport_DisplayPartitionText(PartitionID, Message)

    Description: 
    Writes the given message to the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are writing the message to
    Message(string)  - The message to be written to the UI

    Returns:
    Writes the given message to the display field of the UI
===============================================================================]]
function SecurityReport_DisplayPartitionText(PartitionID, Message)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:DisplayText(Message)
	end
end

--[[=============================================================================
    SecurityReport_PartitionState(PartitionID, State, StateType, TotalDelayTime, RemainingDelayTime, CodeRequiredToClear)

    Description: 
    Sets the specified partitions current state in the system

    Parameters:
    PartitionID(int)             - The number for the partition whose state is being set
    State(string)                - The state of the partition indicated by PartitionID
                                   Following are a list of valid states:
									AS_ARMED					= "ARMED"
									AS_ALARM					= "ALARM"
									AS_OFFLINE					= "OFFLINE"
									AS_EXIT_DELAY				= "EXIT_DELAY"
									AS_ENTRY_DELAY				= "ENTRY_DELAY"
									AS_DISARMED_READY			= "DISARMED_READY"
									AS_DISARMED_NOT_READY		= "DISARMED_NOT_READY"
									AS_CONFIRMATION_REQUIRED	= "CONFIRMATION_REQUIRED"

    StateType(string)            - Some description to further clarify the partition
                                   state. If the state is ARMED, the state type might
                                   be "Home" or "Away".  If the state is ALARM, the
                                   state type might be "FIRE" or "BURGLARY". This
                                   may also be an empty string for other states.
    TotalDelayTime(int)          - An optional parameter that is to be used when
                                   the state being specified is either (ENTRY_DELAY
                                   or EXIT_DELAY)
    RemainingDelayTime(int)      - An optional parameter that is to be used when
                                   the state being specified is either (ENTRY_DELAY
                                   or EXIT_DELAY)
    CodeRequiredToClear(boolean) - An optional parameter that is defaulted to true.
                                   Identifies whether or not a code is required to
                                   clear the alarm event

    Returns:
    None
===============================================================================]]
function SecurityReport_PartitionState(PartitionID, State, StateType, TotalDelayTime, RemainingDelayTime, CodeRequiredToClear)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		StateType = StateType or ""
		TotalDelayTime = tonumber(TotalDelayTime) or 0
		RemainingDelayTime = tonumber(RemainingDelayTime) or 0

		if (CodeRequiredToClear == nil) then 
			CodeRequiredToClear = true 
		end

		SecurityPartitionIndexList[tonumber(PartitionID)]:SetPartitionState(State, StateType, TotalDelayTime, RemainingDelayTime, CodeRequiredToClear)
	end
end


--[[=============================================================================
    SecurityReport_PartitionEnabled(PartitionID, Enabled)

    Description: 
    Marks the specified partition as enabled within the system. If set to false
    the partition will not be visible to the UI.

    Parameters:
    PartitionID(int) - The index of the partition we are enabling or disabling
    Enabled(bool)    - The state of the partition

    Returns:
    None
===============================================================================]]
function SecurityReport_PartitionEnabled(PartitionID, Enabled)
	if (SecurityPartitionIndexList[tonumber(PartitionID)] ~= nil) then
		SecurityPartitionIndexList[tonumber(PartitionID)]:SetEnabled(Enabled)
	end
end

--[[=============================================================================
    SecurityReport_AddZoneToPartition(PartitionID, ZoneID)

    Description: 
    Adds the given zone to the specified partition
    Note: SetZoneInfo must be called before this function in order for the call
          to succeed

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    ZoneID(int)      - The zone id that is being added to the partition

    Returns:
    None
===============================================================================]]
function SecurityReport_AddZoneToPartition(PartitionID, ZoneID)
	local TargPartition = SecurityPartitionIndexList[tonumber(PartitionID)]

	if(TargPartition ~= nil) then
		if(not TargPartition:ContainsZone(ZoneID)) then
			TargPartition:AddZone(tonumber(ZoneID))
			ZoneInfoList[tonumber(ZoneID)]:AddToPartition(tonumber(PartitionID))
		end
	end
end


--[[=============================================================================
    SecurityReport_RemoveZoneFromPartition(PartitionID, ZoneID)

    Description: 
    Removes the given zone from the specified partition

    Parameters:
    PartitionID(int) - The index of the partition we are adding the zone to
    ZoneID(int)      - The zone id that is being added to the partition

    Returns:
    None
===============================================================================]]
function SecurityReport_RemoveZoneFromPartition(PartitionID, ZoneID)
	local TargPartition = SecurityPartitionIndexList[tonumber(PartitionID)]

	if(TargPartition ~= nil) then
		if(TargPartition:ContainsZone(ZoneID)) then
			TargPartition:RemoveZone(tonumber(ZoneID))
			ZoneInfoList[tonumber(ZoneID)]:RemoveFromPartition(tonumber(PartitionID))
		end
	end
end


--[[=============================================================================
    Records a Critical Security event with the history agent.
===============================================================================]]
function RecordHistoryPartitionAlarm(subCategory, eventType, description)
	RecordCriticalHistory(eventType, "Security", subCategory, description)
end

--[[=============================================================================
    Records an Info Security event with the history agent.
===============================================================================]]
function RecordHistoryPartitionEvent(subCategory, eventType, description)
	RecordInfoHistory(eventType, "Security", subCategory, description)
end

--[[=============================================================================
    Records a Warning Security event with the history agent.
===============================================================================]]
function RecordHistoryPartitionAlert(subCategory, eventType, description)
	RecordWarningHistory(eventType, "Security", subCategory, description)
end


