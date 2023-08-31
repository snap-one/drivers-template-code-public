--[[=============================================================================
    File is: receiver_apis.lua

    Copyright Snap One, LLC. All Rights Reserved.
	
	API calls for developers using receiver template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.receiver_apis = "2021.09.09"
end

--==================================================================

function GetCurrentVolume(OutputName)
	return TheReceiver:GetCurrentVolume(OutputName)
end

function IsMuted(OutputName)
	return TheReceiver:IsMuted(OutputName)
end

function IsLoudnessOn(OutputName)
	return TheReceiver:IsLoudnessOn(OutputName)
end

function GetCurrentTrebleLevel(OutputName)
	return TheReceiver:GetCurrentTrebleLevel(OutputName)
end

function GetCurrentBassLevel(OutputName)
	return TheReceiver:GetCurrentBassLevel(OutputName)
end

function GetCurrentBalanceLevel(OutputName)
	return TheReceiver:GetCurrentBalanceLevel(OutputName)
end

function GetCurrentSurroundMode(OutputName)
	return TheReceiver:GetCurrentSurroundMode(OutputName)
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

