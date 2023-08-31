--[[=============================================================================
    File is: tuner_main.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "tuner_proxy.tuner_device_class"
require "tuner_proxy.tuner_reports"
require "tuner_proxy.tuner_apis"
require "tuner_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tuner_main = "2021.09.09"
end



function CreateTunerProxy(BindingID, ProxyInstanceName)
	local NewTuner = TunerDevice:new(BindingID, ProxyInstanceName)

	if(NewTuner ~= nil) then
		NewTuner:InitialSetup()
	else
		LogFatal("CreateTunerProxy  Failed to instantiate Tuner")
	end
end


