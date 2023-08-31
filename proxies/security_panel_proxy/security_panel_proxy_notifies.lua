--[[=============================================================================
    Notification Functions sent to the SecurityPanel proxy from the driver

    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_proxy_notifies = "2018.12.20"
end


function NOTIFY.PANEL_ZONE_STATE(ZoneID, IsOpen, Initializing, BindingID)
	local ZoneParams = {}

	LogTrace("NOTIFY.PANEL_ZONE_STATE: %d %s %s %d", tonumber(ZoneID), tostring(IsOpen), tostring(Initializing), tonumber(BindingID))
	ZoneParams["ZONE_ID"] = ZoneID
	ZoneParams["ZONE_OPEN"] = IsOpen
	ZoneParams["INITIALIZING"] = Initializing

	SendNotify("PANEL_ZONE_STATE", ZoneParams, BindingID)
end

function NOTIFY.PANEL_PARTITION_STATE(PartitionID, PartitionState, StateType, BindingID)
	local PartitionParams = {}

	LogTrace("NOTIFY.PANEL_PARTITION_STATE: %d %s %s %d", tonumber(PartitionID), tostring(PartitionState), tostring(StateType), tonumber(BindingID))
	PartitionParams["PARTITION_ID"] = PartitionID
	PartitionParams["STATE"] = PartitionState
	PartitionParams["TYPE"] = StateType

	SendNotify("PANEL_PARTITION_STATE", PartitionParams, BindingID)
end

function NOTIFY.PANEL_ZONE_INFO(ZoneID, ZoneName, ZoneTypeID, Partitions, IsOpen, BindingID)
	local ZoneInfoParams = {}

	LogTrace("NOTIFY.PANEL_ZONE_INFO: %d %s %d %d", tonumber(ZoneID), tostring(ZoneName), tonumber(ZoneTypeID), tonumber(BindingID))
	ZoneInfoParams["ID"] = ZoneID
	ZoneInfoParams["NAME"] = ZoneName
	ZoneInfoParams["TYPE_ID"] = ZoneTypeID
	ZoneInfoParams["PARTITIONS"] = Partitions
	ZoneInfoParams["IS_OPEN"] = tostring(IsOpen)

	SendNotify("PANEL_ZONE_INFO", ZoneInfoParams, BindingID)
end

function NOTIFY.PANEL_REMOVE_ZONE(ZoneID, BindingID)
	local RemoveZoneParams = {}
	
	LogTrace("NOTIFY.PANEL_REMOVE_ZONE: %d %d", tonumber(ZoneID), tonumber(BindingID))
	RemoveZoneParams["ID"] = ZoneID
	
	SendNotify("PANEL_REMOVE_ZONE", RemoveZoneParams, BindingID)
end

function NOTIFY.TROUBLE_START(TroubleText, Identifier, BindingID)
	local TroubleParams = {}

	LogTrace("NOTIFY.TROUBLE_START: %s %s %d", tostring(TroubleText), tostring(Identifier), tonumber(BindingID))
	TroubleParams["TROUBLE_TEXT"] = TroubleText
	TroubleParams["IDENTIFIER"] = Identifier

	SendNotify("TROUBLE_START", TroubleParams, BindingID)
end

function NOTIFY.TROUBLE_CLEAR(Identifier, BindingID)
	local TroubleParams = {}

	LogTrace("NOTIFY.TROUBLE_CLEAR: %s %d", tostring(Identifier), tonumber(BindingID))
	TroubleParams["IDENTIFIER"] = Identifier

	SendNotify("TROUBLE_CLEAR", TroubleParams, BindingID)
end

function NOTIFY.ALL_PARTITIONS_INFO(InfoStr, BindingID)
	LogTrace("NOTIFY.ALL_PARTITIONS_INFO: %s", InfoStr)
	SendNotify("ALL_PARTITIONS_INFO", InfoStr, BindingID)
end

function NOTIFY.ALL_ZONES_INFO(InfoStr, BindingID)
	LogTrace("NOTIFY.ALL_ZONES_INFO: %s", InfoStr)
	SendNotify("ALL_ZONES_INFO", InfoStr, BindingID)
end


function NOTIFY.REQUEST_ADDITIONAL_PANEL_INFO(Prompt, InfoString, FunctionName, MaskData, InterfaceID, BindingID)
	local ParmList = {}

	LogTrace("NOTIFY.REQUEST_ADDITIONAL_PANEL_INFO: %s %s %d", tostring(Prompt), InfoString, tonumber(BindingID))
	ParmList["PROMPT"] = Prompt
	ParmList["INFO_STRING"] = InfoString
	ParmList["FUNCTION_NAME"] = FunctionName
	ParmList["MASK_DATA"] = tostring(MaskData)
	ParmList["INTERFACE_ID"] = tostring(InterfaceID)

	SendNotify("REQUEST_ADDITIONAL_PANEL_INFO", ParmList, BindingID)
end

function NOTIFY.SYNC_PANEL_INFO(BindingID)
	LogTrace("NOTIFY.SYNC_PANEL_INFO")
	SendNotify("SYNC_PANEL_INFO", {}, BindingID)
end

function NOTIFY.PANEL_INITIALIZED(BindingID)
	LogTrace("NOTIFY.PANEL_INITIALIZED")
	SendNotify("PANEL_INITIALIZED", {}, BindingID)
end



