--[[=============================================================================
    File is: pool_reports.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_reports = "2022.11.29"
end


---------------------------------------------------------------------------------------

function PoolReport_SetTemperatureScale(Scale)
    ThePool:SetTemperatureScale(Scale)
end

function PoolReport_SetPoolTemperature(Temperature)
    ThePool:SetPoolTemperature(Temperature)
end

function PoolReport_SetSpaTemperature(Temperature)
    ThePool:SetSpaTemperature(Temperature)
end

function PoolReport_SetAirTemperature(Temperature)
    ThePool:SetAirTemperature(Temperature)
end

function PoolReport_SetPoolSetpoint(Setpoint)
    ThePool:SetPoolSetpoint(Setpoint)
end

function PoolReport_SetSpaSetpoint(Setpoint)
    ThePool:SetSpaSetpoint(Setpoint)
end

function PoolReport_SetPumpMode(PumpMode)
    ThePool:SetPumpMode(PumpMode)
end

function PoolReport_SetSpaMode(SpaMode)
    ThePool:SetSpaMode(SpaMode)
end

function PoolReport_SetPoolHeatMode(HeaterID, HeatMode)
    ThePool:SetPoolHeatMode(HeaterID, HeatMode)
end


