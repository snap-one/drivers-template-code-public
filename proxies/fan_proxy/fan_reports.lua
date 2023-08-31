--[[=============================================================================
    File is: fan_reports.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
	
	Routines to report information that we have received from the device.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.fan_reports = "2023.06.01"
end


---------------------------------------------------------------------------------------


function FanReport_Speed(Speed)
	TheFan:SetFanSpeed(Speed)
end

function FanReport_Direction(Direction)
	TheFan:SetFanSpinDirection(Direction)
end

function FanReport_PresetSpeed(PresetSpeed)
	TheFan:SetPresetSpeed(PresetSpeed)
end

