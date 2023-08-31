--[[=============================================================================
    File is: thermostat_communicator.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_communicator = "2023.05.11"
end


--============================================================================

function ThermostatCom_SetScale(Scale)
	LogTrace("ThermostatCom_SetScale  %s", tostring(Scale))
	LogInfo("Thermostat  Set Scale  Not Implemented")	-- default
end


function ThermostatCom_SetSetpointHeat(Setpoint, Scale)
	LogTrace("ThermostatCom_SetSetpointHeat  %s %s", tostring(Setpoint), tostring(Scale))
	LogInfo("Thermostat  Set Thermostat Setpoint (Heat) Not Implemented")	-- default
end

function ThermostatCom_SetSetpointCool(Setpoint, Scale)
	LogTrace("ThermostatCom_SetSetpointCool  %s %s", tostring(Setpoint), tostring(Scale))
	LogInfo("Thermostat  Set Thermostat Setpoint (Cool) Not Implemented")	-- default
end

function ThermostatCom_SetSetpointSingle(Setpoint, Scale)
	LogTrace("ThermostatCom_SetSetpointSingle  %s %s", tostring(Setpoint), tostring(Scale))
	LogInfo("Thermostat  Set Thermostat Setpoint (Single) Not Implemented")	-- default
end

function ThermostatCom_SetHVACMode(HVACMode)
	LogTrace("ThermostatCom_SetHVACMode  %s", tostring(HVACMode))
	LogInfo("Thermostat  Set HVAC Mode Not Implemented")	-- default
end

function ThermostatCom_SetFanMode(FanMode)
	LogTrace("ThermostatCom_SetFanMode  %s", tostring(FanMode))
	LogInfo("Thermostat  Set Fan Mode Not Implemented")	-- default
end

function ThermostatCom_SetHoldMode(HoldMode)
	LogTrace("ThermostatCom_SetHoldMode  %s", tostring(HoldMode))
	LogInfo("Thermostat  Set Hold Mode Not Implemented")	-- default
end

function ThermostatCom_SetSetpointHumidify(Setpoint)
	LogTrace("ThermostatCom_SetSetpointHumidify  %s", tostring(Setpoint))
	LogInfo("Thermostat  Set Humidify Setpoint Not Implemented")	-- default
end

function ThermostatCom_SetSetpointDehumidify(Setpoint)
	LogTrace("ThermostatCom_SetSetpointDehumidify  %s", tostring(Setpoint))
	LogInfo("Thermostat  Set Dehumidfy Setpoint Not Implemented")	-- default
end

function ThermostatCom_SetVacationMode(VacationMode)
	LogTrace("ThermostatCom_SetVacationMode  %s", tostring(VacationMode))
	LogInfo("Thermostat  Set Vacation Mode Not Implemented")	-- default
end

function ThermostatCom_SetVacationSetpointHeat(Setpoint, Scale)
	LogTrace("ThermostatCom_SetVacationSetpointHeat  %s %s", tostring(Setpoint), tostring(Scale))
	LogInfo("Thermostat  Set Vacation Heat Setpoint Not Implemented")	-- default
end

function ThermostatCom_SetVacationSetpointCool(Setpoint, Scale)
	LogTrace("ThermostatCom_SetVacationSetpointCool  %s %s", tostring(Setpoint), tostring(Scale))
	LogInfo("Thermostat  Set Vacation Cool Setpoint Not Implemented")	-- default
end

function ThermostatCom_SetButtonsLock(LockThem)
	LogTrace("ThermostatCom_SetButtonsLock  %s", tostring(LockThem))
	LogInfo("Thermostat  Set Buttons Lock Not Implemented")	-- default
end

function ThermostatCom_UseRemoteSensor(UseRemote)
	LogTrace("ThermostatCom_UseRemoteSensor  %s", tostring(UseRemote))
	LogInfo("Thermostat  Use Remote Sensor Not Implemented")	-- default
end

function ThermostatCom_SetScale(Scale)
	LogTrace("ThermostatCom_SetScale  %s", tostring(Scale))
	LogInfo("Thermostat  Set Scale  Not Implemented")	-- default
end


function ThermostatCom_UpdateScheduleEntry(DayOfWeek, EntryIndex, TimeHour, TimeMinute, IsEnabled, HeatSetpoint, CoolSetpoint, Scale)
	LogTrace("ThermostatCom_UpdateScheduleEntry  %s %s %02d:%02d %s %d %d %s",
			 tostring(DayOfWeek), tostring(EntryIndex),
			 tonumber(TimeHour), tonumber(TimeMinute),
			 tostring(IsEnabled),
			 tonumber(HeatSetpoint), tonumber(CoolSetpoint), tostring(Scale))
	LogInfo("Thermostat  Update Schedule Entry   Not Implemented")	-- default
end