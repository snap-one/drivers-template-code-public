--[[=============================================================================
    File is: tv_main.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "tv_proxy.tv_device_class"
require "tv_proxy.tv_reports"
require "tv_proxy.tv_apis"
require "tv_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tv_main = "2022.04.14"
end

TheTv = nil		-- can only have one TV in a driver

function CreateTvProxy(BindingID, ProxyInstanceName)
	if(TheTv == nil) then
		TheTv = TvDevice:new(BindingID, ProxyInstanceName)

		if(TheTv ~= nil) then
			TheTv:InitialSetup()
		else
			LogFatal("CreateTvProxy  Failed to instantiate Tv")
		end
	end
end

--========================================================
-- Common property change routines

TvDevice.RETRY_PROP_POWERON_ENABLE	= "Power On Retry Timer"
TvDevice.RETRY_PROP_POWERON_DELAY	= "Set Power On Delay Seconds"
TvDevice.RETRY_PROP_POWERON_COUNT	= "Set Power On Retry Max Count"
TvDevice.RETRY_PROP_POWEROFF_ENABLE	= "Power Off Retry Timer"
TvDevice.RETRY_PROP_POWEROFF_DELAY	= "Set Power Off Delay Seconds"
TvDevice.RETRY_PROP_POWEROFF_COUNT	= "Set Power Off Retry Max Count"
TvDevice.RETRY_PROP_INPUT_ENABLE	= "Input Retry Timer"
TvDevice.RETRY_PROP_INPUT_DELAY		= "Set Input Retry Delay Milliseconds"
TvDevice.RETRY_PROP_INPUT_COUNT		= "Set Input Retry Max Count"
TvDevice.RETRY_PROP_CHANNEL_ENABLE	= "Channel Retry Timer"
TvDevice.RETRY_PROP_CHANNEL_DELAY	= "Set Channel Retry Delay Milliseconds"
TvDevice.RETRY_PROP_CHANNEL_COUNT	= "Set Channel Retry Max Count"

TvDevice.RAMP_INTERVAL_PROP			= "Set Ramp Interval Milliseconds"

function TvDevice.UpdateRetryProperties(RetryTimerInfo, RampTimerInfo)
	UpdateProperty(TvDevice.RETRY_PROP_POWERON_ENABLE,	RetryTimerInfo.PowerOn.Enabled and "Enable" or "Disable")
	UpdateProperty(TvDevice.RETRY_PROP_POWERON_DELAY,	RetryTimerInfo.PowerOn.Interval)
	UpdateProperty(TvDevice.RETRY_PROP_POWERON_COUNT,	RetryTimerInfo.PowerOn.RetryMax)
	UpdateProperty(TvDevice.RETRY_PROP_POWEROFF_ENABLE,	RetryTimerInfo.PowerOff.Enabled and "Enable" or "Disable")
	UpdateProperty(TvDevice.RETRY_PROP_POWEROFF_DELAY,	RetryTimerInfo.PowerOff.Interval)
	UpdateProperty(TvDevice.RETRY_PROP_POWEROFF_COUNT,	RetryTimerInfo.PowerOff.RetryMax)
	UpdateProperty(TvDevice.RETRY_PROP_INPUT_ENABLE,	RetryTimerInfo.Input.Enabled and "Enable" or "Disable")
	UpdateProperty(TvDevice.RETRY_PROP_INPUT_DELAY,		RetryTimerInfo.Input.Interval)
	UpdateProperty(TvDevice.RETRY_PROP_INPUT_COUNT,		RetryTimerInfo.Input.RetryMax)
	UpdateProperty(TvDevice.RETRY_PROP_CHANNEL_ENABLE,	RetryTimerInfo.Channel.Enabled and "Enable" or "Disable")
	UpdateProperty(TvDevice.RETRY_PROP_CHANNEL_DELAY,	RetryTimerInfo.Channel.Interval)
	UpdateProperty(TvDevice.RETRY_PROP_CHANNEL_COUNT,	RetryTimerInfo.Channel.RetryMax)

	UpdateProperty(TvDevice.RAMP_INTERVAL_PROP,	RampTimerInfo.VolumeUp.Interval)
end


ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_POWERON_ENABLE] = function (propertyValue)
	if(TheTv ~= nil) then
		if(propertyValue == "Enable") then
			TheTv:EnableRetryTimer("PowerOn")
		else
			TheTv:DisableRetryTimer("PowerOn")
		end
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_POWERON_DELAY] = function (propertyValue)
	if(TheTv ~= nil) then
		local NewInterval = tonumber(propertyValue)
		TheTv:SetRetryTimerInterval("PowerOn", NewInterval)

		-- match all of the retry timers' fallback intervals to the power on delay
		SetRetryTimerFallbackInterval("PowerOn", NewInterval)
		SetRetryTimerFallbackInterval("PowerOff", NewInterval)
		SetRetryTimerFallbackInterval("Input", NewInterval * 1000)		-- in milliseconds
		SetRetryTimerFallbackInterval("Channel", NewInterval * 1000)	-- in milliseconds
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_POWERON_COUNT] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerMaxCount("PowerOn", tonumber(propertyValue))
	end
end

----

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_POWEROFF_ENABLE] = function (propertyValue)
	if(TheTv ~= nil) then
		if(propertyValue == "Enable") then
			TheTv:EnableRetryTimer("PowerOff")
		else
			TheTv:DisableRetryTimer("PowerOff")
		end
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_POWEROFF_DELAY] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerInterval("PowerOff", tonumber(propertyValue))
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_POWEROFF_COUNT] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerMaxCount("PowerOff", tonumber(propertyValue))
	end
end

----

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_INPUT_ENABLE] = function (propertyValue)
	if(TheTv ~= nil) then
		if(propertyValue == "Enable") then
			TheTv:EnableRetryTimer("Input")
		else
			TheTv:DisableRetryTimer("Input")
		end
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_INPUT_DELAY] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerInterval("Input", tonumber(propertyValue))
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_INPUT_COUNT] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerMaxCount("Input", tonumber(propertyValue))
	end
end

----

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_CHANNEL_ENABLE] = function (propertyValue)
	if(TheTv ~= nil) then
		if(propertyValue == "Enable") then
			TheTv:EnableRetryTimer("Channel")
		else
			TheTv:DisableRetryTimer("Channel")
		end
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_CHANNEL_DELAY] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerInterval("Channel", tonumber(propertyValue))
	end
end

ON_PROPERTY_CHANGED[TvDevice.RETRY_PROP_CHANNEL_COUNT] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetRetryTimerMaxCount("Channel", tonumber(propertyValue))
	end
end


ON_PROPERTY_CHANGED[TvDevice.RAMP_INTERVAL_PROP] = function (propertyValue)
	if(TheTv ~= nil) then
		TheTv:SetAllRampTimerIntervals(tonumber(propertyValue))
	end
	
	if((RampIntervalMillisecondsPropertyChanged ~= nil) and (type(RampIntervalMillisecondsPropertyChanged) == "function")) then
		RampIntervalMillisecondsPropertyChanged(propertyValue)
	end
end



----
