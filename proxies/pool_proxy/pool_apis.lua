--[[=============================================================================
    File is: pool_apis.lua

    Copyright Snap One, LLC. All Rights Reserved.
	
	API calls for developers using pool template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_apis = "2022.11.29"
end

--==================================================================

function GetCurrentTemperatureScale()
    return ThePool:GetTemperatureScale()
end

function GetCurrentPoolTemperature()
    return ThePool:GetPoolTemperature()
end

function GetCurrentSpaTemperature()
    return ThePool:GetSpaTemperature()
end

function GetCurrentAirTemperature()
    return ThePool:GetAirTemperature()
end

function GetCurrentPoolSetpoint()
    return ThePool:GetPoolSetpoint()
end

function GetCurrentSpaSetpoint()
    return ThePool:GetSpaSetpoint()
end

function GetCurrentPumpMode()
    return ThePool:GetPumpMode()
end

function GetCurrentSpaMode()
    return ThePool:GetSpaMode()
end

