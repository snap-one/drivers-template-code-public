--[[=============================================================================
    File is: tv_apis.lua

    Copyright 2023  Snap One, LLC. All Rights Reserved.
	
	API calls for developers using Tv template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tv_apis = "2023.07.20"
end

--==================================================================

function IsPowerOn()
	return TheTv:IsPowerOn()
end

function GetCurrentVolume()
	return TheTv:GetCurrentVolume()
end

function GetCurrentBassLevel()
	return TheTv:GetCurrentBassLevel()
end

function GetCurrentTrebleLevel()
	return TheTv:GetCurrentTrebleLevel()
end

function GetCurrentBalanceLevel()
	return TheTv:GetCurrentBalanceLevel()
end

function IsMuted()
	return TheTv:IsMuted()
end

function IsLoudnessOn()
	return TheTv:IsLoudnessOn()
end

function GetCurrentInputName()
	return TheTv:GetCurrentInputName()
end

function IsCurrentInputMiniApp()
	return TheTv:IsCurrentInputMiniApp()
end

function GetCurrentInputBindingId()
	return TheTv:GetCurrentInputBindingId()
end

function GetCurrentChannel()
	return TheTv:GetCurrentChannel()
end


function IsPlaying()
	return TheTv:IsPlaying()
end

function IsStopped()
	return TheTv:IsStopped()
end


function IsPaused()
	return TheTv:IsPaused()
end


function IsRecording()
	return TheTv:IsRecording()
end


function GetCurrentChannel()
	return TheTv:GetCurrentChannel()
end


function GetCurrentMediaInfo()
	return TheTv:GetCurrentMediaInfo()
end

--=========================================

function EnableRetryTimers()
	TheTv:EnableRetries()
end

function DisableRetryTimers()
	TheTv:DisableRetries()
end
	-----------------------------------------------------------
	-- These commands all act on an individual retry timer
	-- Valid timer names are:
	--
	--    "PowerOn"
	--    "PowerOff"
	--    "Input"
	--    "Channel"

function IsRetryTimerStarted(TimerName)
	return TheTv:IsRetryTimerStarted(TimerName)
end

function EnableRetryTimer(TimerName)
	TheTv:EnableRetryTimer(TimerName)
end

function DisableRetryTimer(TimerName)
	TheTv:DisableRetryTimer(TimerName)
end

function SetRetryTimerInterval(TimerName, Interval)
	TheTv:SetRetryTimerInterval(TimerName, Interval)
end

-- Retry timers will use their main timer interval for the first two retries.  After that
-- they will use the fallback interval.
function SetRetryTimerFallbackInterval(TimerName, Interval)
	TheTv:SetRetryTimerFallbackInterval(TimerName, Interval)
end

function AbortRetryTimer(TimerName)
	TheTv:AbortRetryTimer(TimerName)
end


--=========================================

function EnableRampTimers()
	TheTv:EnableRampTimers()
end

function DisableRampTimers()
	TheTv:DisableRampTimers()
end

	-----------------------------------------------------------
	-- These commands all act on an individual ramping timer
	-- Valid timer names are:
	--
	--    "VolumeUp"
	--    "VolumeDown"
	--    "ChannelUp"
	--    "ChannelDown"
	--    "Up"
	--    "Down"
	--    "Left"
	--    "Right"
	--    "BassUp"
	--    "BassDown"
	--    "TrebleUp"
	--    "TrebleDown"
	--    "BalanceUp"
	--    "BalanceDown"
	--    "ScanFwd"
	--    "ScanRev"

function EnableRampTimer(TimerName)
	TheTv:EnableRampTimer(TimerName)
end

function DisableRampTimer(TimerName)
	TheTv:DisableRampTimer(TimerName)
end

function SetRampTimerInterval(TimerName, Interval)
	TheTv:SetRampTimerInterval(TimerName, Interval)
end

function IsRamping(TimerName)
	return TheTv:IsRamping(TimerName)
end

--================================================================
require 'common.c4_avutils'

--[[=============================================================================
    ConvertVolumeToC4(volume, minDeviceLevel, maxDeviceLevel)

    Description
    Convert a volume level from a device to a percentage value that can be used by C4 proxies

    Parameters
    volume (number) - The volume value from the device
    minDeviceLevel (number) - The minimum device volume level
	maxDeviceLevel (number) - The maximum device volume level

    Returns
    The C4 usable volume level (0 to 100)
===============================================================================]]

--[[=============================================================================
    ConvertVolumeToDevice(volumePercent, minDeviceLevel, maxDeviceLevel)

    Description
    Convert a volume percentage from a C4 proxy to a numeric level used by a device

    Parameters
    volumePercent (number) - The volume value from the c4 proxy (0 to 100)
    minDeviceLevel (number) - The minimum device volume level
	maxDeviceLevel (number) - The maximum device volume level

    Returns
    The device usable volume level (minDeviceLevel to maxDeviceLevel)
===============================================================================]]

