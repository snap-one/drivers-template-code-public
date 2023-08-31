--[[=============================================================================
	File is: url_apis.lua
    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.url_apis = "2022.11.07"
end

function InitializeUrlCommunication(UserName, Password, AuthRequired, AuthType, Address, HttpPort, RtspPort)
	TheUrlCom:InitialSetup(UserName, Password, AuthRequired, AuthType, Address, HttpPort, RtspPort)
end

--==================================================================

function SetUrlBindingID(NewID)
	TheUrlCom:SetUrlBindingID(NewID)
end


function GetUrlBindingID()
	return TheUrlCom:GetUrlBindingID()
end


function MarkUrlOnline()
	C4:SetBindingStatus(GetUrlBindingID(), "online")
end


function MarkUrlOffline()
	C4:SetBindingStatus(GetUrlBindingID(), "offline")
end


--==================================================================

function BuildHTTPString(InString)
	return TheUrlCom:BuildHTTP(InString)
end


function UrlPut(url, data, headers, Callback)
	return TheUrlCom:Put(url, data, headers, Callback)
end



function UrlGet(url, Callback)
	TheUrlCom:Get(url, Callback)
end


function UrlPost(url, data, header, Callback)
	return TheUrlCom:Post(url, data, header, Callback)
end

function UrlPostRaw(url, data, header, Callback)
	return TheUrlCom:PostRaw(url, data, header, Callback)
end


--==================================================================

function UrlSetResponse(TicketID, ResponseRoutine)
	gTickets[TicketID] = ResponseRoutine
end

--==================================================================

function UrlGetAddress()
	return TheUrlCom:GetAddress()
end

function UrlSetAddress(NewAddress)
	TheUrlCom:SetAddress(NewAddress)
end

function UrlGetHttpPort()
	return TheUrlCom:GetHttpPort()
end

function UrlSetHttpPort(NewPort)
	TheUrlCom:SetHttpPort(NewPort)
end

function UrlGetRtspPort()
	return TheUrlCom:GetRtspPort()
end

function UrlSetRtspPort(NewPort)
	TheUrlCom:SetRtspPort(NewPort)
end

function UrlIsAuthenticationRequired()
	return TheUrlCom:IsAuthenticationRequired()
end

function UrlSetAuthenticationRequired(IsRequired)
	TheUrlCom:SetAuthenticationRequired(IsRequired)
end

function UrlGetAuthenticationType()
	return TheUrlCom:GetAuthenticationType()
end

function UrlAuthIsBasic()
	return TheUrlCom:AuthIsBasic()
end

function UrlAuthIsDigest()
	return TheUrlCom:AuthIsDigest()
end

function UrlSetAuthenticationType(NewType)
	TheUrlCom:SetAuthenticationType(NewType)
end

function UrlGetUserName()
	return TheUrlCom:GetUserName()
end

function UrlSetUserName(NewName)
	TheUrlCom:SetUserName(NewName)
end

function UrlGetPassword()
	return TheUrlCom:GetPassword()
end

function UrlSetPassword(NewPassword)
	TheUrlCom:SetPassword(NewPassword)
end

function UrlAuthHeader()
	return TheUrlCom:AuthHeader()
end

