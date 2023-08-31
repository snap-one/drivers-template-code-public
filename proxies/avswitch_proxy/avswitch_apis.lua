--[[=============================================================================
    File is: avswitch_apis.lua

    Copyright Snap One, LLC. All Rights Reserved.
	
	API calls for developers using avswitch template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.avswitch_apis = "2021.09.20"
end

--==================================================================

function GetCurrentVolume(OutputName)
	return TheAVSwitch:GetCurrentVolume(OutputName)
end

function IsMuted(OutputName)
	return TheAVSwitch:IsMuted(OutputName)
end

function IsLoudnessOn(OutputName)
	return TheAVSwitch:IsLoudnessOn(OutputName)
end

function GetCurrentTrebleLevel(OutputName)
	return TheAVSwitch:GetCurrentTrebleLevel(OutputName)
end

function GetCurrentBassLevel(OutputName)
	return TheAVSwitch:GetCurrentBassLevel(OutputName)
end

function GetCurrentBalanceLevel(OutputName)
	return TheAVSwitch:GetCurrentBalanceLevel(OutputName)
end

	-----------------------------------------------------------
	-- These commands act on the input retry timers
	
function IsRetryTimerStarted(OutputName)
	return TheAVSwitch:IsRetryTimerStarted(OutputName)
end

function EnableRetryTimer()
	TheAVSwitch:EnableRetryTimer()
end

function DisableRetryTimer()
	TheAVSwitch:DisableRetryTimer()
end

function SetRetryTimerInterval(Interval)
	TheAVSwitch:SetRetryTimerInterval(Interval)
end

function SetRetryTimerMaxCount(Count)
	TheAVSwitch:SetRetryTimerMaxCount(Count)
end

--=========================================

function EnableRampTimers()
	TheAVSwitch:EnableRampTimers()
end

function DisableRampTimers()
	TheAVSwitch:DisableRampTimers()
end

	-----------------------------------------------------------
	-- These commands all act on an individual ramping timer
	-- Valid timer names are:
	--
	--    "VolumeUp"
	--    "VolumeDown"
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
	TheAVSwitch:EnableRampTimer(TimerName)
end

function DisableRampTimer(TimerName)
	TheAVSwitch:DisableRampTimer(TimerName)
end

function SetRampTimerInterval(TimerName, Interval)
	TheAVSwitch:SetRampTimerInterval(TimerName, Interval)
end

function IsRamping(TimerName)
	return TheAVSwitch:IsRamping(TimerName)
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

