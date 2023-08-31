--[[=============================================================================
    Notification Functions sent to the Camera proxy from the driver

    Copyright 2017 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.camera_proxy_notifies = "2017.09.07"
end


function NOTIFY.PROPERTY_DEFAULTS(HttpPort, RtspPort, AuthRequired, AuthType, UserName, UserPassword, BindingID)
	LogTrace("NOTIFY.PROPERTY_DEFAULTS")

	local PropDefsParms = {}
	PropDefsParms["HTTP_PORT"] = HttpPort
	PropDefsParms["RTSP_PORT"] = RtspPort
	PropDefsParms["AUTHENTICATION_REQUIRED"] = tostring(AuthRequired)
	PropDefsParms["AUTHENTICATION_TYPE"] = AuthType
	
	if(UserPassword ~= nil) then
		PropDefsParms["USERNAME"] = UserName
		PropDefsParms["PASSWORD"] = UserPassword
	end

	SendNotify("PROPERTY_DEFAULTS", PropDefsParms, BindingID)
end


function NOTIFY.ADDRESS_CHANGED(TargAddress, BindingID)
	LogTrace("NOTIFY.ADDRESS_CHANGED")

	local AddressChangeParms = {}
	AddressChangeParms["ADDRESS"] = tostring(TargAddress)

	SendNotify("ADDRESS_CHANGED", AddressChangeParms, BindingID)
end


function NOTIFY.HTTP_PORT_CHANGED(TargPort, BindingID)
	LogTrace("NOTIFY.HTTP_PORT_CHANGED")

	HttpPortParms = {}
	HttpPortParms["PORT"] = tostring(TargPort)

	SendNotify("HTTP_PORT_CHANGED", HttpPortParms, BindingID)
end



