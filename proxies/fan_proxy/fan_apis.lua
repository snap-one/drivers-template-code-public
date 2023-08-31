--[[=============================================================================
    File is: fan_apis.lua

    Copyright 2023  Snap One, LLC. All Rights Reserved.
	
	API calls for developers using Fan template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.fan_apis = "2023.06.01"
end

--==================================================================

function IsFanOn()
	return TheFan:IsPowerOn()
end

function GetCurrentFanSpeed()
	return TheFan:GetCurrentSpeed()
end

function GetCurrentPresetSpeedLevel()
	return TheFan:GetCurrentPreset()
end

function GetSpeedLevelMax()
	return TheFan:GetSpeedLevelMax()
end

function GetCurrentFanDirection()
	return TheFan:GetSpinDirection()
end

function CanDoReverse()
	return TheFan:CanReverse()
end
