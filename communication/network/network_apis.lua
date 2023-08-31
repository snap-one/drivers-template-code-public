--[[=============================================================================
	File is: network_apis.lua
	Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.network_apis = "2022.11.07"
end

function InitializeNetworkCommunication(NetworkBindingID, NetworkPort, NetworkPollingRoutine)
	TheNetworkCom:InitialSetup(NetworkBindingID, NetworkPort, NetworkPollingRoutine)
end

--==================================================================

function SetNetworkBindingID(NewID)
	TheNetworkCom:SetNetworkBindingID(NewID)
end

function GetNetworkBindingID()
	return TheNetworkCom:GetNetworkBindingID()
end

function SetNetworkPort(NewPortNum)
	TheNetworkCom:SetNetworkBindingPort(NewPortNum)
end

function GetNetworkPort()
	return TheNetworkCom:GetNetworkBindingPort()
end

function IsNetworkInitialized()
	return TheNetworkCom:IsInitialized()
end

function IsNetworkOnline()
	return TheNetworkCom:IsOnline()
end


function MarkNetworkOnline()
	TheNetworkCom:GoOnline()
	C4:SetBindingStatus(GetNetworkBindingID(), "online")
end


function MarkNetworkOffline()
	TheNetworkCom:GoOffline()
	C4:SetBindingStatus(GetNetworkBindingID(), "offline")
end


function SendNetworkMessage(msg)
	TheNetworkCom:SendNetworkMessage(msg)
end


function StartNetworkPollingTimer()
	TheNetworkCom:StartPollingTimer()
end

function KillNetworkPollingTimer()
	TheNetworkCom:KillPollingTimer()
end

function DisableNetworkPollingTimer()
	TheNetworkCom:SetPollingTimerEnabled(false)
end

function EnableNetworkPollingTimer()
	TheNetworkCom:SetPollingTimerEnabled(true)
end

function SetNetworkPollingInterval(Interval)
	TheNetworkCom:SetPollingInterval(Interval)
end

function SendWOL()
	TheNetworkCom:sendWOL()
end

function GetDeviceMAC()
	return TheNetworkCom:GetMACAddress()
end

function PrintDailyNetworkMetricsTracking()
	TheNetworkCom:PrintDailyNetworkMetricsTracking()
end

