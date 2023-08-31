--[[=============================================================================
	File is: http_main.lua
	Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "http.http_apis"
require "http.http_com"
require "http_device_specific"		-- in the home directory

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.http_main = "2022.06.03"
end



TheHttpCom = nil

HttpCom.PROP_MAC_ADDRESS	= "MAC Address"

function ON_DRIVER_INIT.HttpCommunicationSupport(strDit)

	TheHttpCom = HttpCom:new()

	if(TheHttpCom == nil) then
		LogFatal("ON_DRIVER_INIT.HttpCommunicationSupport  Failed to instantiate Http Communication")
	end
end


function GetHTTPResponseString(ResponseCode)
	return (HttpStatusResponseStrings[ResponseCode] ~= nil) and HttpStatusResponseStrings[ResponseCode] or "Unknown"
end

function HTTP_ResponseIsValid(ResponseCode)
	return ((ResponseCode == 200) or (ResponseCode == 202))
end

function HTTP_ResponseUnauthorized(ResponseCode)
	return (ResponseCode == 401)
end



ON_PROPERTY_CHANGED[HttpCom.PROP_MAC_ADDRESS] = function (propertyValue)
	if(TheHttpCom ~= nil) then
		TheHttpCom:SetMACAddress(propertyValue)
	end
end


HttpStatusResponseStrings = {
	[100]	= "Continue",
	[101]	= "Switching Protocols",

	[200]	= "Success",
	[201]	= "Created",
	[202]	= "Accepted",
	[203]	= "Non-Authoritative Information",
	[204]	= "No Content",
	[205]	= "Reset Content",
	[206]	= "Partial Content",

	[300]	= "Multiple Choices",
	[301]	= "Moved Permanently",
	[302]	= "Found",
	[303]	= "See Other",
	[304]	= "Not Modified",
	[307]	= "Temporary Redirect",
	[308]	= "Permanent Redirect",
	
	[400]	= "Bad Request",
	[401]	= "Unauthorized",
	[402]	= "Payment Required",
	[403]	= "Forbidden",
	[404]	= "Not Found",
	[405]	= "Method Not Allowed",
	[406]	= "Not Acceptable",
	[407]	= "Proxy Authentication Required",
	[408]	= "Request Timed Out",
	[409]	= "Conflict",
	[410]	= "Gone",
	[411]	= "Length Required",
	[412]	= "Precondition Failed",
	[413]	= "Payload Too Large",
	[414]	= "URI Too Long",
	[415]	= "Unsupported Media Type",
	[416]	= "Range Not Satisfiable",
	[417]	= "Expectation Failed",
	[418]	= "I'm A Teapot",			-- I love this one
	[426]	= "Upgrade Required",
	[428]	= "Precondition Required",
	[429]	= "Too Many Rquests",
	[431]	= "Request Header Fields Too Large",
	[451]	= "Failed For Legal Reasons",
	
	[500]	= "Internal Server Error",
	[501]	= "Not Implemented",
	[502]	= "Bad Gateway",
	[503]	= "Service Unavailable",
	[504]	= "Gateway Timeout",
	[505]	= "HTTP Version Not Supported",
	[511]	= "Network Authentication Required"

}

