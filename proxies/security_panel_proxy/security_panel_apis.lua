--[[=============================================================================
    File is: security_panel_apis.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
	
	API calls for developers using security_panel template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_apis = "2022.10.03"
end

--==================================================================

function InitializeSecurityPanel()
	TheSecurityPanel:InitialSetup()
end

function SetZoneBindingBase(BindingID)
	ZoneInformation.SetBindingBase(BindingID)
end


function AddZone(ZoneID, UpdateAll)
	if(UpdateAll == nil) then 
		UpdateAll = true 
	end
	
	TheSecurityPanel:AddZone(ZoneID)
	
	if(UpdateAll) then
		SendAllZoneData()
	end
end


function RemoveZone(ZoneID)
	TheSecurityPanel:RemoveZone(ZoneID)
	SendAllZoneData()
end


function SendAllZoneData()
	TheSecurityPanel:PrxGetAllZonesInfo()
end

function ZoneExists(ZoneID)
	return (ZoneInfoList[ZoneID] ~= nil)
end


function ZoneIsOpen(ZoneID)
	if(ZoneExists(ZoneID)) then
		return ZoneInfoList[ZoneID]:IsOpen()
	else
		LogWarn("ZoneIsOpen Invalid Zone ID: %s", tostring(ZoneID))
		return false
	end
end


function ZoneIsBypassed(ZoneID)
	if(ZoneExists(ZoneID)) then
		return ZoneInfoList[ZoneID]:IsBypassed()
	else
		LogWarn("ZoneIsBypassed Invalid Zone ID: %s", tostring(ZoneID))
		return false
	end
end


function GetZoneType(ZoneID)
	if(ZoneExists(ZoneID)) then
		return ZoneInfoList[ZoneID]:GetZoneType()
	else
		LogWarn("GetZoneType Invalid Zone ID: %s", tostring(ZoneID))
		return 0
	end
end

function GetZoneState(ZoneID)
	if(ZoneExists(ZoneID)) then
		return ZoneInfoList[ZoneID]:GetZoneState()
	else
		LogWarn("GetZoneState Invalid Zone ID: %s", tostring(ZoneID))
		return "CLOSED"
	end
end


--==================================================================



