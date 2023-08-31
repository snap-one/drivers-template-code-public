--[[=============================================================================
    File is: thermostat_apis.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
	
	API calls for developers using thermostat template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_apis = "2023.05.11"
end

--==================================================================


function IsConnected()
    return TheThermostat:IsConnected()
end


function GetCurrentThermostatTemperature(Scale) -- Scale parameter is optional
    return TheThermostat:GetThermostatTemperature(Scale)
end

function GetCurrentOutdoorTemperature(Scale) -- Scale parameter is optional
    return TheThermostat:GetOutdoorTemperature(Scale)
end

function GetCurrentHumidity()
    return TheThermostat:GetHumidity()
end

function GetCurrentTemperatureScale()
	return TheThermostat:GetTemperatureScale()
end


function GetCurrentTemperatureScale()
    return TheThermostat:GetTemperatureScale()
end

function GetCurrentThermostatHeatSetpoint(Scale)			-- Scale parameter is optional
    return TheThermostat:GetThermostatHeatSetpoint(Scale)
end

function GetCurrentThermostatCoolSetpoint(Scale)			-- Scale parameter is optional
    return TheThermostat:GetThermostatCoolSetpoint(Scale)
end

function GetCurrentThermostatSingleSetpoint(Scale)			-- Scale parameter is optional
    return TheThermostat:GetThermostatSingleSetpoint(Scale)
end

function IsOnVacation()
    return TheThermostat:GetVacationMode()
end

function HasTemperature()
	return TheThermostat:HasTemperature()
end

function HasOutdoorTemperature()
	return TheThermostat:HasOutdoorTemperature()
end

function HasHumidity()
	return TheThermostat:HasHumidity()
end

function CanHeat()
	return TheThermostat:CanHeat()
end

function CanCool()
	return TheThermostat:CanCool()
end

function CanDoAuto()
	return TheThermostat:CanDoAuto()
end

function CanHumidify()
	return TheThermostat:CanHumidify()
end

function CanDehumidify()
	return TheThermostat:CanDehumidify()
end

