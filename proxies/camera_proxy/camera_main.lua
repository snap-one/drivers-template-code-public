--[[=============================================================================
    File is: camera_main.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "camera_proxy.camera_device_class"
require "camera_proxy.camera_reports"
require "camera_proxy.camera_apis"
require "camera_requests"
require "camera_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.camera_main = "2022.09.28"
end


TheCamera = nil		-- can only have one Camera in a driver

function CreateCameraProxy(BindingID)
	if(TheCamera == nil) then
		TheCamera = CameraDevice:new(BindingID)

		if(TheCamera ~= nil) then
			TheCamera:InitialSetup()
		else
			LogFatal("CreateCameraProxy  Failed to instantiate Camera")
		end
	end
end


function InitializeCamera()
	if(TheCamera ~= nil) then
		TheCamera:InitialSetup()
	end
end


-- function ON_DRIVER_INIT.CameraProxySupport()

	-- TheCamera = CameraDevice:new(CAMERA_PROXY_BINDINGID)

	-- if(TheCamera ~= nil) then
		-- TheCamera:InitialSetup()
	-- else
		-- LogFatal("ON_DRIVER_INIT.CameraProxySupport  Failed to instantiate camera")
	-- end
-- end


