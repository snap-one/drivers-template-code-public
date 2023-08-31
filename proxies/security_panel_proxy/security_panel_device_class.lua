--[[=============================================================================
    SecurityPanel Device Class

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "security_panel_proxy.security_panel_proxy_commands"
require "security_panel_proxy.security_panel_proxy_notifies"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_device_class = "2022.10.03"
end

SecurityPanelDevice = inheritsFrom(C4ProxyBase)


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function SecurityPanelDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)
	
end


function SecurityPanelDevice:InitialSetup()
	
	-- if(PersistData.SecurityPanelPersist == nil) then
		-- PersistSecurityPanelData = {}
		-- PersistData.SecurityPanelPersist = PersistSecurityPanelData
		
		-- PersistSecurityPanelData._Capabilities = {}
		-- self:InitializeCapabilities()

	-- else
		-- PersistSecurityPanelData = PersistData.SecurityPanelPersist
	-- end

	self:InitializeVariables()
end


function SecurityPanelDevice:InitializeVariables()
	self._NextTroubleIndex = 0
	self._TroubleTable = {}
end

function SecurityPanelDevice:GetNextTroubleID()

	if (self._NextTroubleIndex == nil) then
		self._NextTroubleIndex = 0
	end

	self._NextTroubleIndex = self._NextTroubleIndex + 1
	return self._NextTroubleIndex
end

--[[=============================================================================
    Functions for handling request from the Panel Proxy
===============================================================================]]
function SecurityPanelDevice:PrxReadPanelInfo()

	-- Force each zone remove the data guard so the value
	-- from the panel will be used.
	for _, CurZone in pairs(ZoneInfoList) do
		CurZone:SetDataGuardFlag(false)
	end

	SecurityPanelCom_ReadPanelInfo()
end


function SecurityPanelDevice:PrxGetPanelSetup()
	self:PrxGetAllPartitionsInfo()
end


function SecurityPanelDevice:PrxGetAllPartitionsInfo()
	LogTrace("SecurityPanel.GetAllPartitionsInfo")

	local AllPartitionsInfos = {}

	for _, CurPartition in pairs(SecurityPartitionIndexList) do
		table.insert(AllPartitionsInfos, CurPartition:PartitionXML())
	end

	NOTIFY.ALL_PARTITIONS_INFO(MakeXMLNode("partitions", table.concat(AllPartitionsInfos, "\n")), self._BindingID)
end


function SecurityPanelDevice:PrxGetAllZonesInfo()
	local AllZoneInfos = {}

	LogTrace("SecurityPanel.GetAllZonesInfo")
	for _, CurZone in pairs(ZoneInfoList) do
		table.insert(AllZoneInfos, CurZone:ZonePanelXML())
	end

	NOTIFY.ALL_ZONES_INFO(MakeXMLNode("zones", table.concat(AllZoneInfos, "\n")), self._BindingID)
end


function SecurityPanelDevice:PrxSetTimeDate(tParams)
	local TargYear = tonumber(tParams.YEAR)
	local TargMonth = tonumber(tParams.MONTH)
	local TargDay = tonumber(tParams.DAY)
	local TargHour = tonumber(tParams.HOUR)
	local TargMinute = tonumber(tParams.MINUTE)
	local TargSecond = tonumber(tParams.SECOND)
	local InterfaceID = tostring(tParams.INTERFACE_ID)
	LogTrace("SecurityPanelDevice:PrxSetTimeDate  Date is: %02d/%02d/%d  Time is: %02d:%02d:%02d", 
			tonumber(TargMonth), tonumber(TargDay), tonumber(TargYear), tonumber(TargHour), tonumber(TargMinute), tonumber(TargSecond))
	SecurityPanelCom_SendDateAndTime(TargYear, TargMonth, TargDay, TargHour, TargMinute, TargSecond, InterfaceID)
end


function SecurityPanelDevice:PrxSetPartitionEnabled(tParams)
	local PartitionID = tonumber(tParams.PARTITION_ID)
	local Enabled = tParams.ENABLED
	local InterfaceID = tParams.INTERFACE_ID
	SecurityPanelCom_SendPartitionEnabled(PartitionID, Enabled, InterfaceID)
end


function SecurityPanelDevice:PrxSetZoneInfo(tParams)
	local ZoneID = tonumber(tParams.ZONE_ID)
	local ZoneName = tParams.NAME
	local ZoneTypeID = tonumber(tParams.TYPE_ID)
	local DataGuardFlag = toboolean(tParams.DATA_GUARDED)
	local InterfaceID = tParams.INTERFACE_ID
	LogTrace("SecurityPanel.PrxSetZoneInfo  Params are %d %s %s", tonumber(ZoneID), tostring(ZoneName), tostring(ZoneTypeID))

	local TargZone = ZoneInfoList[ZoneID]
	if (TargZone ~= nil) then
		TargZone:SetDataGuardFlag(false)
		SecurityPanelCom_SendSetZoneInfo(ZoneID, ZoneName, ZoneTypeID, InterfaceID)
		TargZone:SetDataGuardFlag(DataGuardFlag)
	else
		-- If the proxy is trying to tell us about a zone that we don't have, tell the proxy to get rid of it.
		NOTIFY.PANEL_REMOVE_ZONE(ZoneID, self._BindingID)
	end
end


--[[=============================================================================
    Functions that are wrappered and meant to be exposed to the driver
===============================================================================]]
function SecurityPanelDevice:TroubleStart(TroubleStr)
	local TroubleID = self:GetNextTroubleID()

	if (TroubleID ~= nil) then
		self._TroubleTable[TroubleID] = TroubleStr
		LogTrace("SecurityPanelDevice: TroubleStart String is: %s %s", tostring(TroubleStr), tostring(TroubleID))
		NOTIFY.TROUBLE_START(TroubleStr, TroubleID, self._BindingID)
	end

	return TroubleID
end

function SecurityPanelDevice:TroubleClear(Identifier)
	Identifier = Identifier or 1

	if (self._TroubleTable ~= nil) then
		self._TroubleTable[Identifier] = nil
	end

	NOTIFY.TROUBLE_CLEAR(Identifier, self._BindingID)
end

function SecurityPanelDevice:AddZone(ZoneID)
	local nZoneID = tonumber(ZoneID)

	LogTrace("SecurityPanel.AddZone %d", nZoneID)
	if (ZoneInfoList[nZoneID] == nil) then
		ZoneInformation:new(nZoneID)
	end
end

function SecurityPanelDevice:RemoveZone(ZoneID)
	local nZoneID = tonumber(ZoneID)

	LogTrace("SecurityPanel.RemovePanel %d", tonumber(nZoneID))
	for _, CurPartition in pairs(SecurityPartitionIndexList) do
		CurPartition:RemoveZone(ZoneID)
	end

	if (ZoneInfoList[nZoneID] ~= nil) then
		ZoneInfoList[nZoneID]:destruct()
	end
end

function SecurityPanelDevice:RequestAdditionalInfo(Prompt, CurrentInfoStr, FunctionName, MaskData, InterfaceID)
	LogTrace("SecurityPanel.RequestAdditionalInfo")
	NOTIFY.REQUEST_ADDITIONAL_PANEL_INFO(Prompt, CurrentInfoStr, FunctionName, MaskData, InterfaceID, self._BindingID)
end

function SecurityPanelDevice:PrxHandleAdditionalInfo(tParams)
	local InfoString = tParams.INFO_STRING
	local NewInfo = tParams.NEW_INFO
	local FunctionName = tParams.FUNCTION_NAME
	local InterfaceID = tParams.INTERFACE_ID
	LogTrace("SecurityPanel.PrxHandleAdditionalInfo")
	SecurityPanelCom_ProcessAdditionalPanelInfo(InfoString, NewInfo, FunctionName, InterfaceID)
end

function SecurityPanelDevice:SynchronizePanelInfo()
	LogTrace("SecurityPanelDevice: SynchronizePanelInfo")
	NOTIFY.SYNC_PANEL_INFO(self._BindingID)
end

function SecurityPanelDevice:ReportPanelInitialized()
	LogTrace("SecurityPanelDevice: ReportPanelInitialized")
	NOTIFY.PANEL_INITIALIZED(self._BindingID)
end

-------------

--=============================================================================
--=============================================================================
-- Called from the partition proxy template

function SecurityPanelDevice:NotifyPartitionState(PartitionNumber, CurrentPartitionState, CurrentStateType)
	NOTIFY.PANEL_PARTITION_STATE(PartitionNumber, CurrentPartitionState, CurrentStateType, self._BindingID)
end
	
--=============================================================================
--=============================================================================

