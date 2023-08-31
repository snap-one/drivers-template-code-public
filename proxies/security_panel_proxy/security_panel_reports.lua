--[[=============================================================================
    File is: security_panel_reports.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_reports = "2020.06.04"
end

gSecurityPanelReportLastTroubleID = 0

---------------------------------------------------------------------------------------

function SecurityPanelReport_TroubleStart(TroubleStr)
	gSecurityPanelReportLastTroubleID = TheSecurityPanel:TroubleStart(TroubleStr)
	return gSecurityPanelReportLastTroubleID
end


function SecurityPanelReport_TroubleClear(Identifier)
	TheSecurityPanel:TroubleClear(Identifier or gSecurityPanelReportLastTroubleID)
end


function SecurityPanelReport_SetZoneInfo(ZoneNum, ZoneName, ZoneTypeID, ZoneTypeID_C4, ForceSend)
	if(ZoneInfoList[ZoneNum] ~= nil) then
		ZoneInfoList[ZoneNum]:SetZoneInfo(ZoneName, ZoneTypeID, ZoneTypeID_C4, ForceSend)
	end
end


function SecurityPanelReport_SetZoneState(ZoneNum, IsOpen, Initializing)
	if(ZoneInfoList[ZoneNum] ~= nil) then
		ZoneInfoList[ZoneNum]:SetZoneState(IsOpen, Initializing)
	end
end


function SecurityPanelReport_SetZoneBypass(ZoneNum, IsBypassed, Initializing)
	if(ZoneInfoList[ZoneNum] ~= nil) then
		ZoneInfoList[ZoneNum]:SetBypassState(IsBypassed, Initializing)
	end
end

--[[=============================================================================
    Records a Critical Security event with the history agent.
===============================================================================]]
function RecordHistoryPanelAlarm(eventType, description)
	RecordCriticalHistory("Security", "Panel", eventType, description)
end

--[[=============================================================================
    Records an Info Security event with the history agent.
===============================================================================]]
function RecordHistoryPanelEvent(eventType, description)
	RecordInfoHistory("Security", "Panel", eventType, description)
end

--[[=============================================================================
    Records a Warning Security event with the history agent.
===============================================================================]]
function RecordHistoryPanelAlert(eventType, description)
	RecordHistoricalEvent("Security", "Panel", eventType, description)
end


