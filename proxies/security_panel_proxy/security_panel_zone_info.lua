--[[=============================================================================
    File is: security_panel_zone_info.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "c4hooks.c4hook_sensor"

TEMPLATE_VERSION.securitypanelzoneinfo = "2020.06.04"

-- Control4 zone type mapping
ZoneTypes = {
	-- Name to ID mappings
	UNKNOWN = 0,
	CONTACT_SENSOR = 1,
	EXTERIOR_DOOR = 2,
	EXTERIOR_WINDOW = 3,
	INTERIOR_DOOR = 4,
	MOTION_SENSOR = 5,
	FIRE = 6,
	GAS = 7,
	CARBON_MONOXIDE = 8,
	HEAT = 9,
	WATER = 10,
	SMOKE = 11,
	PRESSURE = 12,
	GLASS_BREAK = 13,
	GATE = 14,
	GARAGE_DOOR = 15,
	TYPES_COUNT = 16,        -- The number of defined values
	-- ID to Name mappings
	[0] = "UNKNOWN",
	"CONTACT_SENSOR",
	"EXTERIOR_DOOR",
	"EXTERIOR_WINDOW",
	"INTERIOR_DOOR",
	"MOTION_SENSOR",
	"FIRE",
	"GAS",
	"CARBON_MONOXIDE",
	"HEAT",
	"WATER",
	"SMOKE",
	"PRESSURE",
	"GLASS_BREAK",
	"GATE",
	"GARAGE_DOOR" }

ZoneInfoList = {}
ZoneInformation = inheritsFrom(C4H_Sensor)
DefaultZoneName = "Zone "

ZONEINFORMATION_DEFAULT_BINDING_BASE = 100

ZoneInformation._BindingBase = ZONEINFORMATION_DEFAULT_BINDING_BASE

function ZoneInformation.GetBindingBase()
	return ZoneInformation._BindingBase
end

function ZoneInformation.SetBindingBase(NewBase)
	ZoneInformation._BindingBase = NewBase
end


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function ZoneInformation:construct(ZoneID, BindingID, ChildRef)
	self:super():construct(BindingID or (ZoneID + ZoneInformation._BindingBase))
	
	self._ZoneID = ZoneID
	self._IsOpen = 0			-- boolean, but it gets reported around as a 0 (closed)or 1 (opened)
	self._IsBypassed = false
	self._ZoneName = DefaultZoneName .. tostring(ZoneID)
	self._ZoneTypeID_C4 = 0     -- Control4 zone type
	self._ZoneTypeID_3P = 0     -- Security panel zone type
	self._NeedToSendInitialInfo = true

	self._PartitionMemberList = {}

	ZoneInfoList[ZoneID] = ChildRef or self
	self._DataGuarded = false

end


function ZoneInformation:destruct()
	NOTIFY.PANEL_REMOVE_ZONE(self._ZoneID, TheSecurityPanel._BindingID)
	ZoneInfoList[self._ZoneID] = nil
	self:super():destruct()
end


function ZoneInformation:ZonePanelXML()
	local ZoneXMLInfo = {}

	table.insert(ZoneXMLInfo, MakeXMLNode("id", tostring(self._ZoneID)))
	table.insert(ZoneXMLInfo, MakeXMLNode("name", tostring(self._ZoneName)))
	table.insert(ZoneXMLInfo, MakeXMLNode("type_id", tostring(self._ZoneTypeID_C4)))
	table.insert(ZoneXMLInfo, MakeXMLNode("partitions", self:ListPartitions()))
	table.insert(ZoneXMLInfo, MakeXMLNode("can_bypass", "true"))
	table.insert(ZoneXMLInfo, MakeXMLNode("is_open", tostring(self._IsOpen)))

	return MakeXMLNode("zone", table.concat(ZoneXMLInfo, "\n"))
end

function ZoneInformation:ZonePartitionXML()
	return MakeXMLNode("zone", MakeXMLNode("id", tostring(self._ZoneID)))
end

function ZoneInformation:ListPartitions()
	local PartitionList = ""

	for i, p in pairs(self._PartitionMemberList) do
		if (PartitionList ~= "") then
			PartitionList = (PartitionList .. ",")
		end

		PartitionList = PartitionList .. tostring(i)
	end

	return (PartitionList ~= "") and PartitionList or " "
end

function ZoneInformation:ZoneInfoChanged()
	LogDebug("ZoneInfoChanged => Zone %d: Name = %s, Type = %d, Type_Alt = %d", tonumber(self._ZoneID), tostring(self._ZoneName), tonumber(self._ZoneTypeID_C4), tonumber(self._ZoneTypeID_3P))
	RecordHistoryPanelEvent("Zone State Change", 
							string.format("%s (Zone %d) changed to %s", self._ZoneName, self._ZoneID, self:GetZoneState()))
	NOTIFY.PANEL_ZONE_INFO(self._ZoneID, self._ZoneName, self._ZoneTypeID_C4, self:ListPartitions(), self._IsOpen, TheSecurityPanel._BindingID)
end

--[[=============================================================================
    Functions that are wrappered and meant to be exposed to the driver
===============================================================================]]
function ZoneInformation:IsBypassed()
	return self._IsBypassed
end

function ZoneInformation:IsOpen()
	return toboolean(self._IsOpen)
end

function ZoneInformation:GetZoneType()
	return self._ZoneTypeID_3P
end

function ZoneInformation:GetZoneState()
	LogDebug("ZoneInformation:GetZoneState Zone %d  _IsOpen is: %s", self._ZoneID, tostring(self._IsOpen))
	return self:IsOpen() and "OPENED" or "CLOSED"
end

function ZoneInformation:SetDataGuardFlag(GuardIt)
	self._DataGuarded = GuardIt
	LogTrace("ZoneInformation:SetDataGuardFlag for Zone %d   to %s", self._ZoneID, tostring(self._DataGuarded))
end

function ZoneInformation:SetZoneInfo(ZoneName, ZoneTypeID, ZoneTypeID_C4, ForceSend)
	ForceSend = ForceSend or false
	local SomethingChanged = false

	if(not self._DataGuarded) then
		if (self._ZoneName ~= ZoneName and ZoneName ~= "") then
			LogTrace("Changing name for zone %d from %s to %s", self._ZoneID, self._ZoneName, ZoneName)
			self._ZoneName = ZoneName
			SomethingChanged = true
		end

		if (self._ZoneTypeID_C4 ~= ZoneTypeID_C4 and ZoneTypeID_C4 ~= "") then
			self._ZoneTypeID_C4 = ZoneTypeID_C4
			SomethingChanged = true
		end
	end

	if (self._ZoneTypeID_3P ~= ZoneTypeID and ZoneTypeID ~= "") then
		self._ZoneTypeID_3P = ZoneTypeID
	end

	if(SomethingChanged or ForceSend) then
		self:ZoneInfoChanged()
	end
end

function ZoneInformation:AddToPartition(PartitionID)
	self._PartitionMemberList[PartitionID] = SecurityPartitionIndexList[PartitionID]
end

function ZoneInformation:RemoveFromPartition(PartitionID)
	self._PartitionMemberList[PartitionID] = nil
end

function ZoneInformation:SetZoneState(IsOpen, Initializing)
	local RetVal = false     -- return true if the state changed, false if it didn't
	local JustInitializing = Initializing or false

	if ((self._IsOpen ~= IsOpen) or self._NeedToSendInitialInfo or JustInitializing) then
		if(self._NeedToSendInitialInfo or JustInitializing) then
			self:SetStateFromDevice(IsOpen)			-- call base class
		else
			self:ReceivedStateFromDevice(IsOpen)	-- call base class
		end
		
		RetVal = true

		LogDebug("!!!!!!   Zone %d %s  !!!!!!", tonumber(self._ZoneID), tostring(self:GetZoneState()))
		for k, CurPartition in pairs(self._PartitionMemberList) do
			NOTIFY.ZONE_STATE(self._ZoneID, self._IsOpen, self._IsBypassed, CurPartition._BindingID)
		end
 
		NOTIFY.PANEL_ZONE_STATE(self._ZoneID, self._IsOpen, self._NeedToSendInitialInfo or JustInitializing, TheSecurityPanel._BindingID)

		self._NeedToSendInitialInfo = false
	end

	return RetVal
end

function ZoneInformation:SetBypassState(IsBypassed, Initializing)
	local RetVal = false     -- return true if the state changed, false if it didn't
	local JustInitializing = Initializing or false

	if (self._IsBypassed ~= IsBypassed) then

		RetVal = true
		self._IsBypassed = IsBypassed

		if (not JustInitializing) then

			for k, CurPartition in pairs(self._PartitionMemberList) do
				NOTIFY.ZONE_STATE(self._ZoneID, self._IsOpen, self._IsBypassed, CurPartition._BindingID)
			end
		end
	end

	return RetVal
end


function ZoneInformation:GetPeekInfo(PeekTab)
--	LogTrace("VC_Item_Base:GetPeekInfo")
	self:AddZonePeek(PeekTab, "ZoneID", self._ZoneID)
	self:AddZonePeek(PeekTab, "Name", self._ZoneName)
	self:AddZonePeek(PeekTab, "ZoneType", ZoneTypes[self._ZoneTypeID_C4])
	self:AddZonePeek(PeekTab, "ZoneType_3P", self._ZoneTypeID_3P)
	self:AddZonePeek(PeekTab, "Open", toboolean(self._IsOpen))
	self:AddZonePeek(PeekTab, "Bypassed", toboolean(self._IsBypassed))
	self:AddZonePeek(PeekTab, "Partitions", self:ListPartitions())
end


function ZoneInformation:AddZonePeek(InPeekTab, PeekLabel, PeekValue)
--	LogTrace("ZoneInformation:AddZonePeek %s %s", tostring(PeekLabel), tostring(PeekValue))
	table.insert(InPeekTab, string.format("%s -> %s\n", tostring(PeekLabel), tostring(PeekValue)))
end



function ZoneInformation:Peek()
	local PeekInfoTable = {}
	table.insert(PeekInfoTable, "\n")		-- add a break line

	self:GetPeekInfo(PeekInfoTable)
	table.insert(PeekInfoTable, "\n")
	local PeekStr = table.concat(PeekInfoTable)
	LogInfo(PeekStr)

	return PeekStr	-- for unit testing
end


function ZonePeek()
	for _, v in pairs(ZoneInfoList) do
		v:Peek()
	end
end

