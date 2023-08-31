--[[=============================================================================
	File is: http_apis.lua
    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.http_apis = "2023.01.04"
end

function InitializeHttpCommunication(UserName, Password, AuthRequired, AuthType, Address, HttpPort, RtspPort)
	TheHttpCom:InitialSetup(UserName, Password, AuthRequired, AuthType, Address, HttpPort, RtspPort)
end

--==================================================================

function SetHttpBindingID(NewID)
	TheHttpCom:SetHttpBindingID(NewID)
end

function GetHttpBindingID()
	return TheHttpCom:GetHttpBindingID()
end

function MarkHttpOnline()
	C4:SetBindingStatus(GetHttpBindingID(), "online")
end

function MarkHttpOffline()
	C4:SetBindingStatus(GetHttpBindingID(), "offline")
end

--==================================================================

function HttpGet (url, headers, callback, context, options)
	DataLakeMetrics:MetricsCounter ('TX_GET')
	TheHttpCom:UrlDo ('GET', url, "", headers, callback, context, options)
end

function HttpPost (url, data, headers, callback, context, options)
	DataLakeMetrics:MetricsCounter ('TX_POST')
	TheHttpCom:UrlDo  ('POST', url, data, headers, callback, context, options)
end

function HttpPut (url, data, headers, callback, context, options)
	DataLakeMetrics:MetricsCounter ('TX_PUT')
	TheHttpCom:UrlDo  ('PUT', url, data, headers, callback, context, options)
end

function HttpDelete (url, headers, callback, context, options)
	DataLakeMetrics:MetricsCounter ('TX_DELETE')
	TheHttpCom:UrlDo  ('DELETE', url, headers, callback, context, options)
end

function HttpCustom (url, method, data, headers, callback, context, options)
	DataLakeMetrics:MetricsCounter ('TX_' .. method)
	TheHttpCom:UrlDo  (method, url, data, headers, callback, context, options)
end


--==================================================================

function HttpGetAddress()
	return TheHttpCom:GetAddress()
end

function HttpSetAddress(NewAddress)
	TheHttpCom:SetAddress(NewAddress)
end

function HttpGetHttpPort()
	return TheHttpCom:GetHttpPort()
end

function HttpSetHttpPort(NewPort)
	TheHttpCom:SetHttpPort(NewPort)
end

function HttpGetRtspPort()
	return TheHttpCom:GetRtspPort()
end

function HttpSetRtspPort(NewPort)
	TheHttpCom:SetRtspPort(NewPort)
end

function HttpIsAuthenticationRequired()
	return TheHttpCom:IsAuthenticationRequired()
end

function HttpSetAuthenticationRequired(IsRequired)
	TheHttpCom:SetAuthenticationRequired(IsRequired)
end

function HttpGetAuthenticationType()
	return TheHttpCom:GetAuthenticationType()
end

function HttpAuthIsBasic()
	return TheHttpCom:AuthIsBasic()
end

function HttpAuthIsDigest()
	return TheHttpCom:AuthIsDigest()
end

function HttpSetAuthenticationType(NewType)
	TheHttpCom:SetAuthenticationType(NewType)
end

function HttpGetUserName()
	return TheHttpCom:GetUserName()
end

function HttpSetUserName(NewName)
	TheHttpCom:SetUserName(NewName)
end

function HttpGetPassword()
	return TheHttpCom:GetPassword()
end

function HttpSetPassword(NewPassword)
	TheHttpCom:SetPassword(NewPassword)
end

function HttpAuthHeader()
	return TheHttpCom:AuthHeader()
end

--------------------------------------

function StartHttpPollingTimer()
	TheHttpCom:StartPollingTimer()
end

function KillHttpPollingTimer()
	TheHttpCom:KillPollingTimer()
end

function DisableHttpPollingTimer()
	TheHttpCom:SetPollingTimerEnabled(false)
end

function EnableHttpPollingTimer()
	TheHttpCom:SetPollingTimerEnabled(true)
end

function SetHttpPollingInterval(Interval)
	TheHttpCom:SetPollingInterval(Interval)
end

function SendWOL()
	TheHttpCom:sendWOL()
end
