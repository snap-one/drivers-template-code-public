---
--- Initial driver initialization and destruction functions
---
--- Copyright 2022 Snap One, LLC. All Rights Reserved.
---
require "common.c4_driver_declarations"
require "common.c4_property"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_init = "2022.08.09"
end


---Invoked by director when a driver is loaded. This API is provided for the
---driver developer to contain all of the driver objects that will require
---initialization.
---
---@param strDit string
function OnDriverInit(strDit)
	gInitializingDriver = true
	C4:ErrorLog("INIT_CODE: OnDriverInit()")

	-- Call all ON_DRIVER_EARLY_INIT functions.
	for k,v in pairs(ON_DRIVER_EARLY_INIT) do
		if (ON_DRIVER_EARLY_INIT[k] ~= nil and type(ON_DRIVER_EARLY_INIT[k]) == "function") then
			C4:ErrorLog("INIT_CODE: ON_DRIVER_EARLY_INIT." .. k .. "()")
			local status, err = pcall(ON_DRIVER_EARLY_INIT[k], strDit)
			if (not status) then
				C4:ErrorLog("LUA_ERROR: " .. err)
			end
		end
	end

	-- Call all ON_DRIVER_INIT functions
	for k,v in pairs(ON_DRIVER_INIT) do
		if (ON_DRIVER_INIT[k] ~= nil and type(ON_DRIVER_INIT[k]) == "function") then
			C4:ErrorLog("INIT_CODE: ON_DRIVER_INIT." .. k .. "()")
			local status, err = pcall(ON_DRIVER_INIT[k], strDit)
			if (not status) then
				C4:ErrorLog("LUA_ERROR: " .. err)
			end
		end
	end

	-- Fire OnPropertyChanged to set the initial Headers and other Property
	-- global sets, they'll change if Property is changed.
	for k,v in pairs(Properties) do
		C4:ErrorLog("INIT_CODE: Calling OnPropertyChanged - " .. k .. ": " .. v)
		local status, err = pcall(OnPropertyChanged, k)
		if (not status) then
			C4:ErrorLog("LUA_ERROR: " .. err)
		end
	end

	gInitializingDriver = false
end


---Invoked by director after all drivers in the project have been loaded. This
---API is provided for the driver developer to contain all of the driver
---objects that will require initialization after all drivers in the project
---have been loaded.
---
---@param strDit string
function OnDriverLateInit(strDit)
	C4:ErrorLog("INIT_CODE: OnDriverLateInit()")

	if (not C4.GetDriverConfigInfo or not (VersionCheck (C4:GetDriverConfigInfo ('minimum_os_version')))) then
		local errtext = {
			'DRIVER DISABLED - ',
			C4:GetDriverConfigInfo ('model'),
			'driver',
			C4:GetDriverConfigInfo ('version'),
			'requires at least C4 OS',
			C4:GetDriverConfigInfo ('minimum_os_version'),
			': current C4 OS is',
			C4:GetVersionInfo ().version,
		}
		errtext = table.concat (errtext, ' ')

		C4:UpdateProperty ('Driver Version', errtext)
		for property, _ in pairs (Properties) do
			C4:SetPropertyAttribs (property, 1)
		end
		C4:SetPropertyAttribs ('Driver Version', 0)
		return
	end

	-- Call all ON_DRIVER_LATEINIT functions
	for k,v in pairs(ON_DRIVER_LATEINIT) do
		if (ON_DRIVER_LATEINIT[k] ~= nil and type(ON_DRIVER_LATEINIT[k]) == "function") then
			C4:ErrorLog("INIT_CODE: ON_DRIVER_LATEINIT." .. k .. "()")
			ON_DRIVER_LATEINIT[k](strDit)
		end
	end
end



---Function called by Director when a driver is removed. Release things this
---driver has allocated such as timers.
---
---@param strDit string
function OnDriverDestroyed(strDit)
	C4:ErrorLog("INIT_CODE: OnDriverDestroyed()")

	-- Call all ON_DRIVER_DESTROYED functions
	for k, v in pairs(ON_DRIVER_DESTROYED) do
		if (ON_DRIVER_DESTROYED[k] ~= nil and type(ON_DRIVER_DESTROYED[k]) == "function") then
			C4:ErrorLog("INIT_CODE: ON_DRIVER_DESTROYED." .. k .. "()")
			ON_DRIVER_DESTROYED[k](strDit)
		end
	end
end
