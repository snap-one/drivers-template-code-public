---
--- ON_INIT, Timer,s and Property management functions
---
--- Copyright 2021 Snap One, LLC. All Rights Reserved.
---
require "common.c4_driver_declarations"
require "lib.c4_log"
require "lib.c4_timer"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_common = "2021.10.07"
end


---Create and Initialize Logging
---
---@param strDit string
function ON_DRIVER_EARLY_INIT.c4_common(strDit)
	-- Create a logger
	LOG = c4_log:new("Template_c4z Change Name")
end

function ON_DRIVER_INIT.c4_common(strDit)
	-- Create Log Timer
	gC4LogTimer = c4_timer:new("Log Timer", 45, "MINUTES", OnLogTimerExpired)
end


---Log timer callback function
function OnLogTimerExpired()
	LogWarn("Turning Log Mode Off (timer expired)")
	gC4LogTimer:KillTimer()

	C4:UpdateProperty("Log Mode", "Off")
	OnPropertyChanged("Log Mode")
end

gForceLogging = false
gLimitLogging = true

function ON_PROPERTY_CHANGED.LogMode(propertyValue)
	gC4LogTimer:KillTimer()

	if (gForceLogging) then
		LOG:OutputPrint(true)
		LOG:OutputC4Log(true)
	else
		LOG:OutputPrint(propertyValue:find("Print") ~= nil)
		LOG:OutputC4Log(propertyValue:find("Log") ~= nil)
		if ((propertyValue ~= "Off") and gLimitLogging) then
			gC4LogTimer:StartTimer()
		end
	end
end

function ON_PROPERTY_CHANGED.LogLevel(propertyValue)
	LOG:SetLogLevel(propertyValue)
end

function LogTimerToggle()
	gLimitLogging = (not gLimitLogging)

	if(not gLimitLogging) then
		gC4LogTimer:KillTimer()
		LogInfo("Logging will not automatically turn off.")
	else
		gC4LogTimer:StartTimer()
		LogInfo("Logging will automatically turn off after 45 minutes.")
	end
end

function LogForever()
	LogTimerToggle()	-- wrap in a name I can remember
end


---Print Template Versions
function TemplateVersion()
	print ("\nTemplate Versions")
	print ("-----------------------")
	for k, v in pairs(TEMPLATE_VERSION) do
		print (k .. " = " .. v)
	end

	print ("")
end

---
--- Release vs. Development
---

gIsDevelopmentVersionOfDriver = false
function IsDevelopmentVersionOfDriver()
	return gIsDevelopmentVersionOfDriver
end


function SetDevelopmentVersionOfDriverFlag(IsDevelopment)
	gIsDevelopmentVersionOfDriver = IsDevelopment
end

