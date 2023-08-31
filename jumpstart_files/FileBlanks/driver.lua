--[[=============================================================================
	File is: driver.lua
    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]
require "common.c4_driver_declarations"
require "common.c4_common"
require "common.c4_property"
require "common.c4_init"
require "common.c4_bindings"
require "common.c4_command"
require "common.c4_diagnostics"
require "common.c4_notify"
require "common.c4_utils"
require "modules.c4_metrics"


require "device_specific"

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.driver = "2023.02.06"
end



--[[==========================================================================================
	Initialization Code
============================================================================================]]
function ON_DRIVER_EARLY_INIT.MainDriver()
end

function ON_DRIVER_INIT.MainDriver()
	SetLogName(DRIVER_NAME)
	math.randomseed(os.time())

	if(PersistData == nil) then
		PersistData = {}
	end
end

function ON_DRIVER_LATEINIT.MainDriver()
	DeviceSpecificInitialize()
	UpdateProperty("Driver Version", C4:GetDriverConfigInfo("version"))
end



