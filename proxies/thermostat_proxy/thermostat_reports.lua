--[[=============================================================================
    File is: thermostat_reports.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_reports = "2023.05.24"
end


---------------------------------------------------------------------------------------

function ThermostatReport_ConnectionStatus(IsConnected)
    TheThermostat:SetConnectionFlag(IsConnected)
end



function ThermostatReport_TemperatureScale(Scale)
    TheThermostat:SetTemperatureScale(Scale)
end

function ThermostatReport_Temperature(Temperature, Scale)
    TheThermostat:SetTemperature(Temperature, Scale)
end

function ThermostatReport_OutdoorTemperature(Temperature, Scale)
    TheThermostat:SetOutdoorTemperature(Temperature, Scale)
end

function ThermostatReport_SetpointHeat(Setpoint, Scale)
    TheThermostat:SetSetpointHeat(Setpoint, Scale)
end

function ThermostatReport_SetpointCool(Setpoint, Scale)
    TheThermostat:SetSetpointCool(Setpoint, Scale)
end

function ThermostatReport_SetpointSingle(Setpoint, Scale)
    TheThermostat:SetSetpointSingle(Setpoint, Scale)
end


----------

function ThermostatReport_AllowedHVACModes(HVACModesList, CanDoHeat, CanDoCool, CanDoAuto)
    TheThermostat:SetAllowedHVACModes(HVACModesList, CanDoHeat, CanDoCool, CanDoAuto)
end

function ThermostatReport_HVACMode(Mode)
    TheThermostat:SetHVACMode(Mode)
end

function ThermostatReport_HVACState(State)
    TheThermostat:SetHVACState(State)
end

----------

function ThermostatReport_AllowedHoldModes(HoldModesList)
    TheThermostat:SetAllowedHoldModes(HoldModesList)
end

function ThermostatReport_HoldMode(Mode)
    TheThermostat:SetHoldMode(Mode)
end

----------

function ThermostatReport_AllowedFanModes(FanModesList)
    TheThermostat:SetAllowedFanModes(FanModesList)
end

function ThermostatReport_FanMode(Mode)
    TheThermostat:SetFanMode(Mode)
end

function ThermostatReport_FanState(State)
    TheThermostat:SetFanState(State)
end

----------

function ThermostatReport_HumidityValue(Humidity)
    TheThermostat:SetHumidity(Humidity)
end

function ThermostatReport_HumidityMode(HMode)
    TheThermostat:SetHumidityMode(HMode)
end

function ThermostatReport_HumidityState(HState)
    TheThermostat:SetHumidityState(HState)
end

function ThermostatReport_HumidifySetpoint(Setpoint)
    TheThermostat:SetSetpointHumidify(Setpoint)
end

function ThermostatReport_DehumidifySetpoint(Setpoint)
    TheThermostat:SetSetpointDehumidify(Setpoint)
end

----------

function ThermostatReport_Message(Message)
    TheThermostat:SendMessage(Message)
end

----------

function ThermostatReport_OnVacation(OnVacation)
    TheThermostat:SetVacationMode(OnVacation)
end

function ThermostatReport_VacationSetpointHeat(SetpointVal, Scale)
    TheThermostat:SetVacSetpointHeat(SetpointVal, Scale)
end

function ThermostatReport_VacationSetpointCool(SetpointVal, Scale)
    TheThermostat:SetVacSetpointCool(SetpointVal, Scale)
end

----------

function ThermostatReport_ButtonsLocked(AreLocked)
    TheThermostat:SetButtonsLockedFlag(AreLocked)
end

----------

function ThermostatReport_ScheduleEntryChanged(DayOfWeek, EntryIndex, TimeHours, TimeMinutes, IsEnabled, HeatSetpoint, CoolSetpoint, Scale)
    TheThermostat:ScheduleEntryChanged(DayOfWeek, EntryIndex, TimeHours, TimeMinutes, IsEnabled, HeatSetpoint, CoolSetpoint, Scale)
end

----------

function ThermostatReport_CapabilityChanged(CapabilityName, CapabilityValue)
    TheThermostat:ChangeCapability(CapabilityName, CapabilityValue)
end

