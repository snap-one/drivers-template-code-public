--[[=============================================================================
    File is: avswitch_main.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "avswitch_proxy.avswitch_device_class"
require "avswitch_proxy.avswitch_reports"
require "avswitch_proxy.avswitch_apis"
require "avswitch_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.avswitch_main = "2022.10.15"
end

TheAVSwitch = nil		-- can only have one AVSwitch in a driver

function CreateAVSwitchProxy(BindingID, ProxyInstanceName)
	if(TheAVSwitch == nil) then
		TheAVSwitch = AVSwitchDevice:new(BindingID, ProxyInstanceName)

		if(TheAVSwitch ~= nil) then
			TheAVSwitch:InitialSetup()
		else
			LogFatal("CreateAVSwitchProxy  Failed to instantiate AVSwitch")
		end
	end
end

--========================================================
-- Common property change routines

AVSwitchDevice.RETRY_PROP_INPUT_ENABLE	= "Input Retry Timer"
AVSwitchDevice.RETRY_PROP_INPUT_DELAY		= "Set Input Retry Delay Milliseconds"
AVSwitchDevice.RETRY_PROP_INPUT_COUNT		= "Set Input Retry Max Count"

AVSwitchDevice.RAMP_INTERVAL_PROP			= "Set Ramp Interval Milliseconds"

function AVSwitchDevice.UpdateRetryProperties(RetryTimerInfo)
	UpdateProperty(AVSwitchDevice.RETRY_PROP_INPUT_ENABLE,	RetryTimerInfo.Input.Enabled and "Enable" or "Disable")
	UpdateProperty(AVSwitchDevice.RETRY_PROP_INPUT_DELAY,	RetryTimerInfo.Input.Interval)
	UpdateProperty(AVSwitchDevice.RETRY_PROP_INPUT_COUNT,	RetryTimerInfo.Input.RetryMax)
end

----

ON_PROPERTY_CHANGED[AVSwitchDevice.RETRY_PROP_INPUT_ENABLE] = function (propertyValue)
	if(TheAVSwitch ~= nil) then
		if(propertyValue == "Enable") then
			TheAVSwitch:EnableRetryTimer()
		else
			TheAVSwitch:DisableRetryTimer()
		end
	end
end

ON_PROPERTY_CHANGED[AVSwitchDevice.RETRY_PROP_INPUT_DELAY] = function (propertyValue)
	if(TheAVSwitch ~= nil) then
		TheAVSwitch:SetRetryTimerInterval(tonumber(propertyValue))
	end
end

ON_PROPERTY_CHANGED[AVSwitchDevice.RETRY_PROP_INPUT_COUNT] = function (propertyValue)
	if(TheAVSwitch ~= nil) then
		TheAVSwitch:SetRetryTimerMaxCount(tonumber(propertyValue))
	end
end


ON_PROPERTY_CHANGED[AVSwitchDevice.RAMP_INTERVAL_PROP] = function (propertyValue)
	if(TheAVSwitch ~= nil) then
		TheAVSwitch:SetAllRampTimerIntervals(tonumber(propertyValue))
	end
	
	if((RampIntervalMillisecondsPropertyChanged ~= nil) and (type(RampIntervalMillisecondsPropertyChanged) == "function")) then
		RampIntervalMillisecondsPropertyChanged(propertyValue)
	end
end


----



