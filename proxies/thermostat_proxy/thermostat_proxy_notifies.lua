--[[=============================================================================
    File is: thermostat_proxy_notifies.lua

    Notification Functions sent to the Thermostat proxy from the driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_proxy_notifies = "2023.05.12"
end



function NOTIFY.ALLOWED_FAN_MODES_CHANGED(ModesStr, BindingID)
	LogTrace("NOTIFY.ALLOWED_FAN_MODES_CHANGED")
	local Params = {
		MODES = tostring(ModesStr)
	}

	SendNotify("ALLOWED_FAN_MODES_CHANGED", Params, BindingID)
end

function NOTIFY.ALLOWED_HVAC_MODES_CHANGED(ModesStr, CanHeat, CanCool, CanAuto, BindingID)
	LogTrace("NOTIFY.ALLOWED_HVAC_MODES_CHANGED")
	local Params = {
		MODES = tostring(ModesStr),
		CAN_HEAT = tostring(CanHeat),
		CAN_COOL = tostring(CanCool),
		CAN_AUTO = tostring(CanAuto),
	}

	SendNotify("ALLOWED_HVAC_MODES_CHANGED", Params, BindingID)
end

function NOTIFY.AUXILIARY_HEAT(IsEngaged, BindingID)
	LogTrace("NOTIFY.AUXILIARY_HEAT")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("AUXILIARY_HEAT", Params, BindingID)
end

function NOTIFY.AUXILIARY_HEAT_SOURCE(HeatSourceName, BindingID)
	LogTrace("NOTIFY.AUXILIARY_HEAT_SOURCE")
	local Params = {
		NAME = tostring(HeatSourceName)
	}

	SendNotify("AUXILIARY_HEAT_SOURCE", Params, BindingID)
end

function NOTIFY.BUTTONS_LOCK_CHANGED(Locked, BindingID)
	LogTrace("NOTIFY.BUTTONS_LOCK_CHANGED")
	local Params = {
		LOCK = tostring(Locked)
	}

	SendNotify("BUTTONS_LOCK_CHANGED", Params, BindingID)
end

function NOTIFY.CALIBRATION_CHANGED(Calibration, BindingID)
	LogTrace("NOTIFY.CALIBRATION_CHANGED")
	local Params = {
		CALIBRATION = tostring(Calibration)
	}

	SendNotify("CALIBRATION_CHANGED", Params, BindingID)
end

function NOTIFY.CONNECTION(IsConnected, BindingID)
	LogTrace("NOTIFY.CONNECTION")
	local Params = {
		CONNECTED = tostring(IsConnected)
	}

	SendNotify("CONNECTION", Params, BindingID)
end

function NOTIFY.COOL_SETPOINT_CHANGED(SetpointVal, Scale, BindingID)
	LogTrace("NOTIFY.COOL_SETPOINT_CHANGED")
	local Params = {
		SETPOINT = tostring(SetpointVal),
		SCALE = tostring(Scale)
	}

	SendNotify("COOL_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.DR_EVENT(InEvent, EventSetpoint, EndTime, IsMandatory, BindingID)
	LogTrace("NOTIFY.DR_EVENT")
	local Params = {
		IN_EVENT = tostring(InEvent),
		EVENT_SETPOINT = tostring(EventSetpoint),
		END_TIME = tostring(EndTime),
		IS_MANDATORY = tostring(IsMandatory)
	}

	SendNotify("DR_EVENT", Params, BindingID)
end

function NOTIFY.EMERGENCY_HEAT(IsEngaged, BindingID)
	LogTrace("NOTIFY.EMERGENCY_HEAT")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("EMERGENCY_HEAT", Params, BindingID)
end

function NOTIFY.EMERGENCY_HEAT_SOURCE(Name, BindingID)
	LogTrace("NOTIFY.EMERGENCY_HEAT_SOURCE")
	local Params = {
		NAME = tostring(Name)
	}

	SendNotify("EMERGENCY_HEAT_SOURCE", Params, BindingID)
end

function NOTIFY.FAN_ENGAGED(IsEngaged, BindingID)
	LogTrace("NOTIFY.FAN_ENGAGED")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("FAN_ENGAGED", Params, BindingID)
end

function NOTIFY.FAN_MODE_CHANGED(Mode, BindingID)
	LogTrace("NOTIFY.FAN_MODE_CHANGED")
	local Params = {
		MODE = tostring(Mode)
	}

	SendNotify("FAN_MODE_CHANGED", Params, BindingID)
end

function NOTIFY.FAN_STATE_CHANGED(State, BindingID)
	LogTrace("NOTIFY.FAN_STATE_CHANGED")
	local Params = {
		STATE = tostring(State)
	}

	SendNotify("FAN_STATE_CHANGED", Params, BindingID)
end

function NOTIFY.FORCE_INFO(BindingID)
	LogTrace("NOTIFY.FORCE_INFO")

	SendNotify("FORCE_INFO", {}, BindingID)
end

function NOTIFY.HEAT_PUMP_MODE(HasHeatPump, BindingID)
	LogTrace("NOTIFY.HEAT_PUMP_MODE")
	local Params = {
		HAS_HEAT_PUMP = tostring(HasHeatPump)
	}

	SendNotify("HEAT_PUMP_MODE", Params, BindingID)
end

function NOTIFY.HEAT_SETPOINT_CHANGED(SetpointVal, Scale, BindingID)
	LogTrace("NOTIFY.HEAT_SETPOINT_CHANGED")
	local Params = {
		SETPOINT = tostring(SetpointVal),
		SCALE = tostring(Scale)
	}

	SendNotify("HEAT_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.HOLD_MODE_CHANGED(Mode, BindingID)
	LogTrace("NOTIFY.HOLD_MODE_CHANGED")
	local Params = {
		MODE = tostring(Mode)
	}

	SendNotify("HOLD_MODE_CHANGED", Params, BindingID)
end

function NOTIFY.HVAC_MODE_CHANGED(Mode, BindingID)
	LogTrace("NOTIFY.HVAC_MODE_CHANGED")
	local Params = {
		MODE = tostring(Mode)
	}

	SendNotify("HVAC_MODE_CHANGED", Params, BindingID)
end

function NOTIFY.HVAC_STATE_CHANGED(State, BindingID)
	LogTrace("NOTIFY.HVAC_STATE_CHANGED")
	local Params = {
		STATE = tostring(State)
	}

	SendNotify("HVAC_STATE_CHANGED", Params, BindingID)
end

function NOTIFY.PRIMARY_COOL(IsEngaged, BindingID)
	LogTrace("NOTIFY.PRIMARY_COOL")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("PRIMARY_COOL", Params, BindingID)
end

function NOTIFY.PRIMARY_HEAT(IsEngaged, BindingID)
	LogTrace("NOTIFY.PRIMARY_HEAT")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("PRIMARY_HEAT", Params, BindingID)
end

function NOTIFY.PRIMARY_HEAT_SOURCE(Name, BindingID)
	LogTrace("NOTIFY.PRIMARY_HEAT_SOURCE")
	local Params = {
		NAME = tostring(Name)
	}

	SendNotify("PRIMARY_HEAT_SOURCE", Params, BindingID)
end

function NOTIFY.REMOTE_SENSOR_CHANGED(InUse, BindingID)
	LogTrace("NOTIFY.REMOTE_SENSOR_CHANGED")
	local Params = {
		IN_USE = tostring(InUse)
	}

	SendNotify("REMOTE_SENSOR_CHANGED", Params, BindingID)
end

function NOTIFY.REVERSING_VALVE(Name, BindingID)
	LogTrace("NOTIFY.REVERSING_VALVE")
	local Params = {
		NAME = tostring(Name)
	}

	SendNotify("REVERSING_VALVE", Params, BindingID)
end

function NOTIFY.SCALE_CHANGED(Scale, BindingID)
	LogTrace("NOTIFY.SCALE_CHANGED")
	local Params = {
		SCALE = tostring(Scale)
	}
	SendNotify("SCALE_CHANGED", Params, BindingID)
end

function NOTIFY.SCHEDULE_ENTRIES_CHANGED(Entries, BindingID)
	LogTrace("NOTIFY.SCHEDULE_ENTRIES_CHANGED")
	local Params = {
		ENTRIES = tostring(Entries)
	}

	SendNotify("SCHEDULE_ENTRIES_CHANGED", Params, BindingID)
end

function NOTIFY.SCHEDULE_ENTRY_CHANGED(DayIndex, EntryIndex, EnabledFlag, TimeMinutes, HeatSetpoint, CoolSetpoint, Units, BindingID)
	LogTrace("NOTIFY.SCHEDULE_ENTRY_CHANGED")
	local Params = {
		DayIndex = tostring(DayIndex),
		EntryIndex = tostring(EntryIndex),
		EnabledFlag = tostring(EnabledFlag),
		TimeMinutes = tostring(TimeMinutes),
		HeatSetpoint = tostring(HeatSetpoint),
		CoolSetpoint = tostring(CoolSetpoint),
		Units = tostring(Units)
	}

	SendNotify("SCHEDULE_ENTRY_CHANGED", Params, BindingID)
end

function NOTIFY.SECONDARY_COOL(IsEngaged, BindingID)
	LogTrace("NOTIFY.SECONDARY_COOL")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("SECONDARY_COOL", Params, BindingID)
end

function NOTIFY.SECONDARY_HEAT(IsEngaged, BindingID)
	LogTrace("NOTIFY.SECONDARY_HEAT")
	local Params = {
		ENGAGED = tostring(IsEngaged)
	}

	SendNotify("SECONDARY_HEAT", Params, BindingID)
end

function NOTIFY.TEMPERATURE_CHANGED(Temperature, Scale, BindingID)
	LogTrace("NOTIFY.TEMPERATURE_CHANGED")
	local Params = {
		TEMPERATURE = tostring(Temperature),
		SCALE = tostring(Scale)
	}

	SendNotify("TEMPERATURE_CHANGED", Params, BindingID)
end

function NOTIFY.VACATION_MODE(IsOnVacation, BindingID)
	LogTrace("NOTIFY.VACATION_MODE")
	local Params = {
		ON_VACATION = tostring(IsOnVacation)
	}

	SendNotify("VACATION_MODE", Params, BindingID)
end

function NOTIFY.VACATION_SETPOINTS(HeatSetpoint, CoolSetpoint, Units, BindingID)
	LogTrace("NOTIFY.VACATION_SETPOINTS")
	local Params = {
		VAC_HEAT_SETPOINT = tostring(HeatSetpoint),
		VAC_COOL_SETPOINT = tostring(CoolSetpoint),
		UNITS = tostring(Units)
	}

	SendNotify("VACATION_SETPOINTS", Params, BindingID)
end

function NOTIFY.OUTDOOR_TEMPERATURE_CHANGED(Temperature, Scale, BindingID)
	LogTrace("NOTIFY.OUTDOOR_TEMPERATURE_CHANGED")
	local Params = {
		TEMPERATURE = tostring(Temperature),
		SCALE = tostring(Scale)
	}

	SendNotify("OUTDOOR_TEMPERATURE_CHANGED", Params, BindingID)
end

function NOTIFY.HUMIDITY_CHANGED(HumidityVal, BindingID)
	LogTrace("NOTIFY.HUMIDITY_CHANGED")
	local Params = {
		HUMIDITY = tostring(HumidityVal)
	}

	SendNotify("HUMIDITY_CHANGED", Params, BindingID)
end

function NOTIFY.HUMIDITY_MODE_CHANGED(Mode, BindingID)
	LogTrace("NOTIFY.HUMIDITY_MODE_CHANGED")
	local Params = {
		MODE = tostring(Mode)
	}

	SendNotify("HUMIDITY_MODE_CHANGED", Params, BindingID)
end

function NOTIFY.ALLOWED_HUMIDITY_MODES_CHANGED(ModesList, BindingID)
	LogTrace("NOTIFY.ALLOWED_HUMIDITY_MODES_CHANGED")
	local Params = {
		MODES = tostring(ModesList)
	}

	SendNotify("ALLOWED_HUMIDITY_MODES_CHANGED", Params, BindingID)
end

function NOTIFY.HUMIDITY_STATE_CHANGED(HumidityState, BindingID)
	LogTrace("NOTIFY.HUMIDITY_STATE_CHANGED")
	local Params = {
		STATE = tostring(HumidityState)
	}

	SendNotify("HUMIDITY_STATE_CHANGED", Params, BindingID)
end

function NOTIFY.HUMIDIFY_SETPOINT_CHANGED(HumidifySetpoint, BindingID)
	LogTrace("NOTIFY.HUMIDIFY_SETPOINT_CHANGED")
	local Params = {
		SETPOINT = tostring(HumidifySetpoint)
	}

	SendNotify("HUMIDIFY_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.DEHUMIDIFY_SETPOINT_CHANGED(DehumidifySetpoint, BindingID)
	LogTrace("NOTIFY.DEHUMIDIFY_SETPOINT_CHANGED")
	local Params = {
		SETPOINT = tostring(DehumidifySetpoint)
	}

	SendNotify("DEHUMIDIFY_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.EXTRAS_SETUP_CHANGED(ExtrasSetupXML, BindingID)
	LogTrace("NOTIFY.EXTRAS_SETUP_CHANGED")
	local Params = {
		XML = tostring(ExtrasSetupXML)
	}

	SendNotify("EXTRAS_SETUP_CHANGED", Params, BindingID)
end

function NOTIFY.EXTRAS_STATE_CHANGED(ExtrasStateXML, BindingID)
	LogTrace("NOTIFY.EXTRAS_STATE_CHANGED")
	local Params = {
		XML = tostring(ExtrasStateXML)
	}

	SendNotify("EXTRAS_STATE_CHANGED", Params, BindingID)
end

function NOTIFY.MESSAGE_CHANGED(Message, BindingID)
	LogTrace("NOTIFY.MESSAGE_CHANGED")
	local Params = {
		MESSAGE = Message
	}

	SendNotify("MESSAGE_CHANGED", Params, BindingID)
end

function NOTIFY.DYNAMIC_CAPABILITIES_CHANGED(CapName, CapValue, BindingID)

	--[[
		Valid Capability Names:
			CAN_HEAT
			CAN_COOL
			CAN_AUTO
			HEAT_SETPOINT_MIN_F
			HEAT_SETPOINT_MIN_C
			HEAT_SETPOINT_MAX_F
			HEAT_SETPOINT_MAX_C
			HEAT_SETPOINT_RESOLUTION_F
			HEAT_SETPOINT_RESOLUTION_C
			HEATCOOL_SETPOINTS_DEADBAND_F
			HEATCOOL_SETPOINTS_DEADBAND_C
			COOL_SETPOINT_MIN_F
			COOL_SETPOINT_MIN_C
			COOL_SETPOINT_MAX_F
			COOL_SETPOINT_MAX_C
			COOL_SETPOINT_RESOLUTION_F
			COOL_SETPOINT_RESOLUTION_C
			SINGLE_SETPOINT_MIN_F
			SINGLE_SETPOINT_MIN_C
			SINGLE_SETPOINT_MAX_F
			SINGLE_SETPOINT_MAX_C
			SINGLE_SETPOINT_RESOLUTION_F
			SINGLE_SETPOINT_RESOLUTION_C
			HAS_TEMPERATURE
			HAS_OUTDOOR_TEMPERATURE
			CAN_HUMIDIFY
			CAN_DEHUMIDIFY
			HAS_HUMIDITY
			HUMIDIFY_SETPOINT_MIN
			HUMIDIFY_SETPOINT_MAX
			HUMIDIFY_SETPOINT_RESOLUTION
			HUMIDITY_SETPOINTS_DEADBAND
			DEHUMIDIFY_SETPOINT_MIN
			DEHUMIDIFY_SETPOINT_MAX
			DEHUMIDIFY_SETPOINT_RESOLUTION
			HAS_EXTRAS
			CAN_PRESET
			CAN_PRESET_SCHEDULE
			HAS_SINGLE_SETPOINT
			HAS_HEAT_PUMP
			TEMPERATURE_RESOLUTION_F
			TEMPERATURE_RESOLUTION_C
			TEMPERATURE_MIN_F
			TEMPERATURE_MIN_C
			TEMPERATURE_MAX_F
			TEMPERATURE_MAX_C
			OUTDOOR_TEMPERATURE_RESOLUTION_F
			OUTDOOR_TEMPERATURE_RESOLUTION_C
			CAN_CHANGE_SCALE
	]]
	LogTrace("NOTIFY.DYNAMIC_CAPABILITIES_CHANGED")
	local Params = {}
	Params[CapName] = tostring(CapValue)

	SendNotify("DYNAMIC_CAPABILITIES_CHANGED", Params, BindingID)
end

function NOTIFY.SINGLE_SETPOINT_CHANGED(Setpoint, Scale, BindingID)
	LogTrace("NOTIFY.SINGLE_SETPOINT_CHANGED")
	local Params = {
		SETPOINT = tostring(Setpoint),
		SCALE = tostring(Scale)
	}

	SendNotify("SINGLE_SETPOINT_CHANGED", Params, BindingID)
end

function NOTIFY.ALLOWED_HOLD_MODES_CHANGED(HoldModesList, BindingID)
	LogTrace("NOTIFY.ALLOWED_HOLD_MODES_CHANGED")
	local Params = {
		MODES = tostring(HoldModesList)
	}

	SendNotify("ALLOWED_HOLD_MODES_CHANGED", Params, BindingID)
end

function NOTIFY.PRESET_CHANGED(PresetName, BindingID)
	LogTrace("NOTIFY.PRESET_CHANGED")
	local Params = {
		NAME = tostring(PresetName)
	}

	SendNotify("PRESET_CHANGED", Params, BindingID)
end

function NOTIFY.PRESET_FIELDS_CHANGED(PresetFieldsXML, BindingID)
	LogTrace("NOTIFY.PRESET_FIELDS_CHANGED")
	local Params = {
		XML = tostring(PresetFieldsXML)
	}

	SendNotify("PRESET_FIELDS_CHANGED", Params, BindingID)
end

