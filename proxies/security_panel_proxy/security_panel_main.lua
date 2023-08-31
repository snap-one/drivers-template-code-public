--[[=============================================================================
    File is: security_panel_main.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "security_panel_proxy.security_panel_zone_info"
require "security_panel_proxy.security_panel_device_class"
require "security_panel_proxy.security_panel_reports"
require "security_panel_proxy.security_panel_apis"
require "security_panel_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_main = "2022.10.03"
end


TheSecurityPanel = nil		-- can only have one security panel in a driver


function CreateSecurityPanelProxy(BindingID, ProxyInstanceName)
	if(TheSecurityPanel == nil) then
		TheSecurityPanel = SecurityPanelDevice:new(BindingID, ProxyInstanceName)

		if(TheSecurityPanel ~= nil) then
			TheSecurityPanel:InitialSetup()
		else
			LogFatal("CreateSecurityPanelProxy  Failed to instantiate security_panel")
		end
	end
end


