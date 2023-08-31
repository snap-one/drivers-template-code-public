--[[=============================================================================
    File is: thermostat_device_class.lua

    Thermostat Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "thermostat_proxy.thermostat_proxy_commands"
require "thermostat_proxy.thermostat_proxy_notifies"


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.thermostat_device_class = "2023.05.24"
end

Thermostat = inheritsFrom(C4ProxyBase)

Thermostat.FAHRENHEIT	= "F"
Thermostat.CELSIUS		= "C"
Thermostat.DEFAULT_TEMPERATURE = -40		-- Works for F or C
Thermostat.DEFAULT_HUMIDITY = 0

--------

Thermostat.TEMPERATURE_CONVERSION_RATIO = (9.0 / 5.0)
Thermostat.TEMPERATURE_CONVERSION_OFFSET = 32.0
Thermostat.KELVIN_OFFSET = 273.15

Thermostat.DoWConvert = {
	[0] = "Sunday",
	[1] = "Monday",
	[2] = "Tueday",
	[3] = "Wednesday",
	[4] = "Thursday",
	[5] = "Friday",
	[6] = "Saturday",

	Sunday = 0,
	Monday = 1,
	Tueday = 2,
	Wednesday = 3,
	Thursday = 4,
	Friday = 5,
	Saturday = 6,
}


function Thermostat.FtoC(FTemperature)
	return (FTemperature - Thermostat.TEMPERATURE_CONVERSION_OFFSET) / Thermostat.TEMPERATURE_CONVERSION_RATIO
end

function Thermostat.CtoF(CTemperature)
	return (CTemperature * Thermostat.TEMPERATURE_CONVERSION_RATIO) + Thermostat.TEMPERATURE_CONVERSION_OFFSET
end

function Thermostat.FRound(FTemperature)
	-- Round Farhenheit temperatures to the nearest degree
	return (FTemperature < 0.0) and math.ceil(FTemperature - 0.5) or math.floor(FTemperature + 0.5)
end

function Thermostat.CRound(CTemperature)
	-- Round Celsius temperatures to the nearest half degree
	local WorkVal = CTemperature * 2.0
	return ((WorkVal < 0.0) and math.ceil(WorkVal - 0.5) or math.floor(WorkVal + 0.5)) / 2
end

--------

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]

Thermostat.PERSIST_DATA = "ThermostatPersist"

function Thermostat:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	if(PersistData[Thermostat.PERSIST_DATA] == nil) then

		PersistData[Thermostat.PERSIST_DATA] = {
			_Scale = GetProjectTemperatureScale(),

			_HasTemperature = C4:GetCapability('has_temperature') and toboolean(C4:GetCapability('has_temperature')) or true,
			_TemperatureResF = C4:GetCapability('current_temperature_resolution_f') or 1.0,
			_TemperatureResC = C4:GetCapability('current_temperature_resolution_c') or 0.5,
			_CanCalibrate = C4:GetCapability('can_calibrate') and toboolean(C4:GetCapability('can_calibrate')) or false,

			_HvacModesStr = C4:GetCapability('hvac_modes') or "Off,Heat",
			_HvacStatesStr = C4:GetCapability('hvac_states') or "Off,On",

			_FanModesStr = C4:GetCapability('fan_modes') or "Auto,On",
			_FanStatesStr = C4:GetCapability('fan_states') or "Off,On",

			_HoldModesStr = C4:GetCapability('hold_modes') or "Off",

			_CanHeat = C4:GetCapability('can_heat') and toboolean(C4:GetCapability('can_heat')) or true,
			_HeatSetpointMinF = C4:GetCapability('setpoint_heat_min_f') or 40,
			_HeatSetpointMinC = C4:GetCapability('setpoint_heat_min_c') or 4,
			_HeatSetpointMaxF = C4:GetCapability('setpoint_heat_max_f') or 87,
			_HeatSetpointMaxC = C4:GetCapability('setpoint_heat_max_c') or 30,
			_HeatSetpointResF = C4:GetCapability('setpoint_heat_resolution_f') or 1.0,
			_HeatSetpointResC = C4:GetCapability('setpoint_heat_resolution_c') or 0.5,
			_HeatSetpointF = 50,
			_HeatSetpointC = 10,

			_CanCool = C4:GetCapability('can_cool') and toboolean(C4:GetCapability('can_cool')) or false,
			_CoolSetpointMinF = C4:GetCapability('setpoint_cool_min_f') or 43,
			_CoolSetpointMinC = C4:GetCapability('setpoint_cool_min_c') or 6,
			_CoolSetpointMaxF = C4:GetCapability('setpoint_cool_max_f') or 90,
			_CoolSetpointMaxC = C4:GetCapability('setpoint_cool_max_c') or 32,
			_CoolSetpointResF = C4:GetCapability('setpoint_cool_resolution_f') or 1.0,
			_CoolSetpointResC = C4:GetCapability('setpoint_cool_resolution_c') or 0.5,
			_CoolSetpointF = 86,
			_CoolSetpointC = 30,

			_CanAuto = C4:GetCapability('can_do_auto') and toboolean(C4:GetCapability('can_do_auto')) or false,

			_HeatCoolDeadbandF = C4:GetCapability('setpoint_heatcool_deadband_f') or 3,
			_HeatCoolDeadbandC = C4:GetCapability('setpoint_heatcool_deadband_c') or 2,

			_HasSingleSetpoint = C4:GetCapability('has_single_setpoint') and toboolean(C4:GetCapability('has_single_setpoint')) or false,
			_SingleSetpointMinF = C4:GetCapability('setpoint_single_min_f') or 40,
			_SingleSetpointMinC = C4:GetCapability('setpoint_single_min_c') or 4,
			_SingleSetpointMaxF = C4:GetCapability('setpoint_single_max_f') or 90,
			_SingleSetpointMaxC = C4:GetCapability('setpoint_single_max_c') or 32,
			_SingleSetpointResF = C4:GetCapability('setpoint_single_resolution_f') or 1.0,
			_SingleSetpointResC = C4:GetCapability('setpoint_single_resolution_c') or 0.5,
			_SingleSetpointF = 50,
			_SingleSetpointC = 10,


			_HasHumidity = C4:GetCapability('has_humidity') and toboolean(C4:GetCapability('has_humidity')) or false,

			_HumidityModesStr = C4:GetCapability('humidity_modes') or "Off,Humidify,Dehumidify",
			_HumidityStatesStr = C4:GetCapability('humidity_states') or "Off,Humidify,Dehumidify",

			_CanHumidfy = C4:GetCapability('can_humidify') and toboolean(C4:GetCapability('can_humidify')) or false,
			_HumidifySetpointMin = C4:GetCapability('setpoint_humidify_min') or 10,
			_HumidifySetpointMax = C4:GetCapability('setpoint_humidify_max') or 80,
			_HumidifySetpointRes = C4:GetCapability('setpoint_humidify_resolution') or 2,
			_HumidifySetpoint = 40,

			_CanDehumidify = C4:GetCapability('can_dehumidify') and toboolean(C4:GetCapability('can_dehumidify')) or false,
			_DehumidifySetpointMin = C4:GetCapability('setpoint_dehumidify_min') or 20,
			_DehumidifySetpointMax = C4:GetCapability('setpoint_dehumidify_max') or 90,
			_DehumidifySetpointRes = C4:GetCapability('setpoint_dehumidify_resolution') or 2,
			_DehumidifySetpoint = 60,

			_HumidityDeadband = C4:GetCapability('setpoint_humidity_deadband') or 5,

			_HasVacationMode = C4:GetCapability('has_vacation_mode') and toboolean(C4:GetCapability('has_vacation_mode')) or false,
			_VacationHeatSetpointF = 50,
			_VacationHeatSetpointC = 10,
			_VacationCoolSetpointF = 86,
			_VacationCoolSetpointC = 30,

			_HasOutdoorTemperature = C4:GetCapability('has_outdoor_temperature') and toboolean(C4:GetCapability('has_outdoor_temperature')) or false,
			_OutdoorTemperatureResF = C4:GetCapability('outdoor_temperature_resolution_f') or 1.0,
			_OutdoorTemperatureResC = C4:GetCapability('outdoor_temperature_resolution_c') or 0.5,

			_CanLockButtons = C4:GetCapability('can_lock_buttons') and toboolean(C4:GetCapability('can_lock_buttons')) or false,

		}

		self:PersistSave()
	end

	self._PersistData = PersistData[Thermostat.PERSIST_DATA]

	self._IsConnected = false
	self._ThermostatTemperatureF = Thermostat.DEFAULT_TEMPERATURE
	self._ThermostatTemperatureC = Thermostat.DEFAULT_TEMPERATURE
	self._OutdoorTemperatureF = Thermostat.DEFAULT_TEMPERATURE
	self._OutdoorTemperatureC = Thermostat.DEFAULT_TEMPERATURE
	self._Humidity = Thermostat.DEFAULT_HUMIDITY
	self._OnVacation = false

	self._FanModesList = StringSplit(self._PersistData._FanModesStr, ",")
	self._FanStatesList = StringSplit(self._PersistData._FanStatesStr, ",")
	self._HvacModesList = StringSplit(self._PersistData._HvacModesStr, ",")
	self._HvacStatesList = StringSplit(self._PersistData._HvacStatesStr, ",")
	self._HoldModesList = StringSplit(self._PersistData._HoldModesStr, ",")
	self._HumidityModesList = StringSplit(self._PersistData._HumidityModesStr, ",")
	self._HumidityStatesList = StringSplit(self._PersistData._HumidityStatesStr, ",")

	self._CurFanMode =  self._FanModesList[1]
	self._CurFanState = self._FanStatesList[1]

	self._CurHvacMode =  self._HvacModesList[1]
	self._CurHvacState = self._HvacStatesList[1]

	self._CurHoldMode =  self._HoldModesList[1]

	self._CurHumidityMode =  self._HumidityModesList[1]
	self._CurHumidityState = self._HumidityStatesList[1]

	self._ButtonsLocked = false
end

----------------------

function Thermostat:PersistSave()
	C4:PersistSetValue(Thermostat.PERSIST_DATA, self._PersistData)
end

----------------------

function Thermostat:InitialSetup()
	self:InitializeVariables()

	NOTIFY.ALLOWED_FAN_MODES_CHANGED(self._PersistData._FanModesStr, self._BindingID)
	NOTIFY.FAN_MODE_CHANGED(self._CurFanMode, self._BindingID)
	NOTIFY.FAN_STATE_CHANGED(self._CurFanState, self._BindingID)

	NOTIFY.ALLOWED_HVAC_MODES_CHANGED(self._PersistData._HvacModesStr,
									self._PersistData._CanHeat,
									self._PersistData._CanCool,
									self._PersistData._CanAuto,
									self._BindingID)
	NOTIFY.HVAC_MODE_CHANGED(self._CurHvacMode, self._BindingID)
	NOTIFY.HVAC_STATE_CHANGED(self._CurHvacState, self._BindingID)

	NOTIFY.ALLOWED_HOLD_MODES_CHANGED(self._PersistData._HoldModesStr, self._BindingID)
	NOTIFY.HOLD_MODE_CHANGED(self._CurHoldMode, self._BindingID)

	NOTIFY.COOL_SETPOINT_CHANGED(self:IsCelsius() and self._PersistData._CoolSetpointC or self._PersistData._CoolSetpointF, self:GetTemperatureScale(), self._BindingID)
	NOTIFY.HEAT_SETPOINT_CHANGED(self:IsCelsius() and self._PersistData._HeatSetpointC or self._PersistData._HeatSetpointF, self:GetTemperatureScale(), self._BindingID)

	if(self._PersistData._HasVacationMode) then
		NOTIFY.VACATION_SETPOINTS(self:IsCelsius() and self._PersistData._VacationHeatSetpointC or self._PersistData._VacationHeatSetpointF,
								  self:IsCelsius() and self._PersistData._VacationCoolSetpointC or self._PersistData._VacationHeatSetpointF,
								  self:GetTemperatureScale(), self._BindingID)
	end

	if(self._PersistData._HasHumidity) then
		NOTIFY.ALLOWED_HUMIDITY_MODES_CHANGED(self._PersistData._HumidityModesStr, self._BindingID)
		NOTIFY.HUMIDITY_MODE_CHANGED(self._PersistData._CurHumidityMode, self._BindingID)
		NOTIFY.HUMIDITY_STATE_CHANGED(self._CurHumidityState, self._BindingID)
	end


end


function Thermostat:InitializeVariables()
end


function Thermostat:SetConnectionFlag(IsConnected)
	self._IsConnected = IsConnected
	NOTIFY.CONNECTION(self._IsConnected, self._BindingID)
end

function Thermostat:IsConnected()
	return self._IsConnected
end

function Thermostat:IsCelsius()
	return (self._PersistData._Scale == Thermostat.CELSIUS)
end

function Thermostat:GetTemperatureScale()
	return self._PersistData._Scale
end

function Thermostat:HasTemperature()
	return self._PersistData._HasTemperature
end

function Thermostat:HasOutdoorTemperature()
	return self._PersistData._HasOutdoorTemperature
end

function Thermostat:HasHumidity()
	return self._PersistData._HasHumidity
end

function Thermostat:CanHeat()
	return self._PersistData._CanHeat
end

function Thermostat:CanCool()
	return self._PersistData._CanCool
end

function Thermostat:CanDoAuto()
	return self._PersistData._CanAuto
end

function Thermostat:CanHumidify()
	return (self._PersistData._HasHumidity and self._PersistData._CanHumidfy)
end

function Thermostat:CanDehumidify()
	return (self._PersistData._HasHumidity and self._PersistData._CanDehumidify)
end


function Thermostat:SetTemperatureScale(NewScale)
	if((NewScale == Thermostat.FAHRENHEIT) or (NewScale == Thermostat.CELSIUS)) then
		self._PersistData._Scale = NewScale
		NOTIFY.SCALE_CHANGED(self._PersistData._Scale, self._BindingID)
	else
		LogError('Invalid Temperature Scale Type: %s  (Should be "C" or "F")', tostring(NewScale))
	end
end


function Thermostat:GetThermostatTemperature(Scale)
	Scale = Scale or self:GetTemperatureScale()
	return (Scale == Thermostat.FAHRENHEIT) and self._ThermostatTemperatureF or self._ThermostatTemperatureC
end

function Thermostat:GetOutdoorTemperature(Scale)
	Scale = Scale or self:GetTemperatureScale()
	return (Scale == Thermostat.FAHRENHEIT) and self._OutdoorTemperatureF or self._OutdoorTemperatureC
end

function Thermostat:GetHumidity()
	return self._Humidity
end

function Thermostat:GetThermostatHeatSetpoint(Scale)
	Scale = Scale or self:GetTemperatureScale()
	return ((Scale == Thermostat.FAHRENHEIT) and self._PersistData._HeatSetpointF or self._PersistData._HeatSetpointC), Scale
end

function Thermostat:GetThermostatCoolSetpoint(Scale)
	Scale = Scale or self:GetTemperatureScale()
	return (Scale == Thermostat.FAHRENHEIT) and self._PersistData._CoolSetpointF or self._PersistData._CoolSetpointC, Scale
end

function Thermostat:SetTemperature(NewTemperature, Scale)
	if(self:HasTemperature()) then
		Scale = Scale or self:GetTemperatureScale()
		local NumTemperature = tonumber(NewTemperature)
		if(NumTemperature ~= nil) then
			if(Scale == Thermostat.FAHRENHEIT) then
				local FTemp = Thermostat.FRound(NumTemperature)
				if(FTemp ~= self._ThermostatTemperatureF) then
					self._ThermostatTemperatureF = FTemp
					self._ThermostatTemperatureC = Thermostat.CRound(Thermostat.FtoC(NumTemperature))
					NOTIFY.TEMPERATURE_CHANGED(self._ThermostatTemperatureF, Thermostat.FAHRENHEIT, self._BindingID)
				end
			else
				local CTemp = Thermostat.CRound(NumTemperature)
				if(CTemp ~= self._ThermostatTemperatureC) then
					self._ThermostatTemperatureF = Thermostat.FRound(Thermostat.CtoF(NumTemperature))
					self._ThermostatTemperatureC = CTemp
					NOTIFY.TEMPERATURE_CHANGED(self._ThermostatTemperatureC, Thermostat.CELSIUS, self._BindingID)
				end
			end
		else
			LogError('Invalid Thermostat Temperature: %s  (Should be a number)', tostring(NewTemperature))
		end
	else
		LogWarn("This device doesn't support temperature")
	end
end

function Thermostat:SetOutdoorTemperature(NewTemperature, Scale)
	if(self:HasOutdoorTemperature()) then
		Scale = Scale or self:GetTemperatureScale()
		local NumTemperature = tonumber(NewTemperature)
		if(NumTemperature ~= nil) then
			if(Scale == Thermostat.FAHRENHEIT) then
				local FTemp = Thermostat.FRound(NumTemperature)
				if(FTemp ~= self._OutdoorTemperatureF) then
					self._OutdoorTemperatureF = FTemp
					self._OutdoorTemperatureC = Thermostat.CRound(Thermostat.FtoC(NumTemperature))
					NOTIFY.OUTDOOR_TEMPERATURE_CHANGED(self._OutdoorTemperatureF, Thermostat.FAHRENHEIT, self._BindingID)
				end
			else
				local CTemp = Thermostat.CRound(NumTemperature)
				if(CTemp ~= self._ThermostatTemperatureC) then
					self._OutdoorTemperatureF = Thermostat.FRound(Thermostat.CtoF(NumTemperature))
					self._OutdoorTemperatureC = CTemp
					NOTIFY.OUTDOOR_TEMPERATURE_CHANGED(self._OutdoorTemperatureC, Thermostat.CELSIUS, self._BindingID)
				end
			end
		else
			LogError('Invalid Outdoor Temperature: %s  (Should be a number)', tostring(NewTemperature))
		end
	else
		LogWarn("This device doesn't support outdoor temperature")
	end
end

function Thermostat:SetSetpointHeat(NewSetpoint, Scale)
	Scale = Scale or self:GetTemperatureScale()
	local NumSetpoint = tonumber(NewSetpoint)
	if(NumSetpoint ~= nil) then
		if(Scale == Thermostat.FAHRENHEIT) then
			local FTemp = Thermostat.FRound(NumSetpoint)
			if(FTemp ~= self._PersistData._HeatSetpointF) then
				self._PersistData._HeatSetpointF = FTemp
				self._PersistData._HeatSetpointC = Thermostat.CRound(Thermostat.FtoC(NumSetpoint))
				NOTIFY.HEAT_SETPOINT_CHANGED(self._PersistData._HeatSetpointF, Thermostat.FAHRENHEIT, self._BindingID)
			end
		else
			local CTemp = Thermostat.CRound(NumSetpoint)
			if(CTemp ~= self._PersistData._HeatSetpointC) then
				self._PersistData._HeatSetpointF = Thermostat.FRound(Thermostat.CtoF(NumSetpoint))
				self._PersistData._HeatSetpointC = CTemp
				NOTIFY.HEAT_SETPOINT_CHANGED(self._PersistData._HeatSetpointC, Thermostat.CELSIUS, self._BindingID)
			end
		end
	else
		LogError('Invalid Heat Setpoint: %s  (Should be a number)', tostring(NewSetpoint))
	end
end

function Thermostat:SetSetpointCool(NewSetpoint, Scale)
	Scale = Scale or self:GetTemperatureScale()
	local NumSetpoint = tonumber(NewSetpoint)
	if(NumSetpoint ~= nil) then
		if(Scale == Thermostat.FAHRENHEIT) then
			local FTemp = Thermostat.FRound(NumSetpoint)
			if(FTemp ~= self._PersistData._CoolSetpointF) then
				self._PersistData._CoolSetpointF = FTemp
				self._PersistData._CoolSetpointC = Thermostat.CRound(Thermostat.FtoC(NumSetpoint))
				NOTIFY.COOL_SETPOINT_CHANGED(self._PersistData._CoolSetpointF, Thermostat.FAHRENHEIT, self._BindingID)
			end
		else
			local CTemp = Thermostat.CRound(NumSetpoint)
			if(CTemp ~= self._PersistData._CoolSetpointC) then
				self._PersistData._CoolSetpointF = Thermostat.FRound(Thermostat.CtoF(NumSetpoint))
				self._PersistData._CoolSetpointC = CTemp
				NOTIFY.COOL_SETPOINT_CHANGED(self._PersistData._CoolSetpointC, Thermostat.CELSIUS, self._BindingID)
			end
		end
	else
		LogError('Invalid Cool Setpoint: %s  (Should be a number)', tostring(NewSetpoint))
	end
end

function Thermostat:SetSetpointSingle(NewSetpoint, Scale)
	Scale = Scale or self:GetTemperatureScale()
	local NumSetpoint = tonumber(NewSetpoint)
	if(NumSetpoint ~= nil) then
		if(Scale == Thermostat.FAHRENHEIT) then
			local FTemp = Thermostat.FRound(NumSetpoint)
			if(FTemp ~= self._PersistData._SingleSetpointF) then
				self._PersistData._SingleSetpointF = FTemp
				self._PersistData._SingleSetpointC = Thermostat.CRound(Thermostat.FtoC(NumSetpoint))
				NOTIFY.SINGLE_SETPOINT_CHANGED(self._PersistData._SingleSetpointF, Thermostat.FAHRENHEIT, self._BindingID)
			end
		else
			local CTemp = Thermostat.CRound(NumSetpoint)
			if(CTemp ~= self._PersistData._SingleSetpointC) then
				self._PersistData._SingleSetpointF = Thermostat.FRound(Thermostat.CtoF(NumSetpoint))
				self._PersistData._SingleSetpointC = CTemp
				NOTIFY.COOL_SETPOINT_CHANGED(self._PersistData._SingleSetpointC, Thermostat.CELSIUS, self._BindingID)
			end
		end
	else
		LogError('Invalid Cool Setpoint: %s  (Should be a number)', tostring(NewSetpoint))
	end
end

function Thermostat:SetAllowedHVACModes(ModesList, CanDoHeat, CanDoCool, CanDoAuto)
	self._PersistData._HvacModesStr = ModesList
	self._PersistData._CanHeat = CanDoHeat or self._PersistData._CanHeat
	self._PersistData._CanCool = CanDoCool or self._PersistData._CanCool
	self._PersistData._CanAuto =  CanDoAuto or self._PersistData._CanAuto

	NOTIFY.ALLOWED_HVAC_MODES_CHANGED(self._PersistData._HvacModesStr,
									  self._PersistData._CanHeat,
									  self._PersistData._CanCool,
									  self._PersistData._CanAuto,
									  self._BindingID)

end


function Thermostat:SetHVACMode(NewHvacMode)
	local FoundIt = false
	for _, CheckMode in pairs(self._HvacModesList) do
		if(NewHvacMode == CheckMode) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurHvacMode = NewHvacMode
		NOTIFY.HVAC_MODE_CHANGED(self._CurHvacMode, self._BindingID)
	else
		LogWarn("Thermostat:SetHVACMode Invalide Mode: %s", tostring(NewHvacMode))
	end
end

function Thermostat:SetHVACState(NewHvacState)
	local FoundIt = false
	for _, CheckState in pairs(self._HvacStatesList) do
		if(NewHvacState == CheckState) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurHvacState = NewHvacState
		NOTIFY.HVAC_STATE_CHANGED(self._CurHvacState, self._BindingID)
	else
		LogWarn("Thermostat:SetHVACState Invalide Mode: %s", tostring(NewHvacState))
	end
end

function Thermostat:SetAllowedHoldModes(HoldModesList)
	self._PersistData._HoldModesStr = HoldModesList
	NOTIFY.ALLOWED_HOLD_MODES_CHANGED(self._PersistData._HoldModesStr, self._BindingID)
end


function Thermostat:SetHoldMode(NewHoldMode)
	local FoundIt = false
	for _, CheckMode in pairs(self._HoldModesList) do
		if(NewHoldMode == CheckMode) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurHoldMode = NewHoldMode
		NOTIFY.FAN_MODE_CHANGED(self._CurHoldMode, self._BindingID)
	else
		LogWarn("Thermostat:SetHoldMode Invalide Mode: %s", tostring(NewHoldMode))
	end
end

function Thermostat:SetAllowedFanModes(FanModesList)
	self._PersistData._FanModesStr = FanModesList
	NOTIFY.ALLOWED_FAN_MODES_CHANGED(self._PersistData._FanModesStr, self._BindingID)
end


function Thermostat:SetFanMode(NewFanMode)
	local FoundIt = false
	for _, CheckMode in pairs(self._FanModesList) do
		if(NewFanMode == CheckMode) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurFanMode = NewFanMode
		NOTIFY.FAN_MODE_CHANGED(self._CurFanMode, self._BindingID)
	else
		LogWarn("Thermostat:SetFanMode Invalide Mode: %s", tostring(NewFanMode))
	end
end


function Thermostat:SetFanState(NewFanState)
	local FoundIt = false
	for _, CheckState in pairs(self._FanStatesList) do
		if(NewFanState == CheckState) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurFanState = NewFanState
		NOTIFY.FAN_STATE_CHANGED(self._CurFanState, self._BindingID)
	else
		LogWarn("Thermostat:SetHVACState Invalide Mode: %s", tostring(NewFanState))
	end
end

function Thermostat:SetHumidity(Humidity)
	if(self:HasHumidity()) then
		self._Humidity = Humidity
		NOTIFY.HUMIDITY_CHANGED(self._Humidity, self._BindingID)
	else
		LogWarn("This device doesn't support humidity")
	end
end

function Thermostat:SetHumidityMode(NewHMode)
	local FoundIt = false
	for _, CheckMode in pairs(self._HumidityModesList) do
		if(NewHMode == CheckMode) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurHumidityMode = NewHMode
		NOTIFY.HUMIDITY_MODE_CHANGED(self._CurHumidityMode, self._BindingID)
	else
		LogWarn("Thermostat:SetHumidityMode Invalide Mode: %s", tostring(NewHMode))
	end
end

function Thermostat:SetHumidityState(HState)
	local FoundIt = false
	for _, CheckState in pairs(self._HumidityModesList) do
		if(HState == CheckState) then
			FoundIt = true
			break
		end
	end

	if(FoundIt) then
		self._CurHumidityState = HState
		NOTIFY.HUMIDITY_STATE_CHANGED(self._CurHumidityState, self._BindingID)
	else
		LogWarn("Thermostat:SetHumidityState Invalide Mode: %s", tostring(HState))
	end
end

function Thermostat:SetSetpointHumidify(Setpoint)
	self._PersistData._HumidifySetpoint = Setpoint
	NOTIFY.HUMIDIFY_SETPOINT_CHANGED(self._PersistData._HumidifySetpoint, self._BindingID)
end

function Thermostat:SetSetpointDehumidify(Setpoint)
	self._PersistData._DehumidifySetpoint = Setpoint
	NOTIFY.DEHUMIDIFY_SETPOINT_CHANGED(self._PersistData._DehumidifySetpoint, self._BindingID)
end


function Thermostat:SendMessage(MsgText)
	NOTIFY.MESSAGE_CHANGED(MsgText, self._BindingID)
end

function Thermostat:SetVacationMode(OnVacation)
	self._OnVacation = OnVacation
	NOTIFY.VACATION_MODE(self._OnVacation, self._BindingID)
end

function Thermostat:GetVacationMode()
	return self._OnVacation
end

function Thermostat:SetVacSetpointHeat(SetpointVal, Scale)
	Scale = Scale or self:GetTemperatureScale()
	local NumSetpoint = tonumber(SetpointVal)
	if(NumSetpoint ~= nil) then
		if(Scale == Thermostat.FAHRENHEIT) then
			local FTemp = Thermostat.FRound(NumSetpoint)
			if(FTemp ~= self._PersistData._VacationHeatSetpointF) then
				self._PersistData._VacationHeatSetpointF = FTemp
				self._PersistData._VacationHeatSetpointC = Thermostat.CRound(Thermostat.FtoC(NumSetpoint))
				NOTIFY.VACATION_SETPOINTS(self._PersistData._VacationHeatSetpointF, self._PersistData._VacationCoolSetpointF, Thermostat.FAHRENHEIT, self._BindingID)
			end
		else
			local CTemp = Thermostat.CRound(NumSetpoint)
			if(CTemp ~= self._PersistData._VacationHeatSetpointC) then
				self._PersistData._VacationHeatSetpointF = Thermostat.FRound(Thermostat.CtoF(NumSetpoint))
				self._PersistData._VacationHeatSetpointC = CTemp
				NOTIFY.VACATION_SETPOINTS(self._PersistData._VacationHeatSetpointC, self._PersistData._VacationCoolSetpointC, Thermostat.CELSIUS, self._BindingID)
			end
		end
	else
		LogError('Invalid Vacation Heat Setpoint: %s  (Should be a number)', tostring(SetpointVal))
	end
end

function Thermostat:SetVacSetpointCool(SetpointVal, Scale)
	Scale = Scale or self:GetTemperatureScale()
	local NumSetpoint = tonumber(SetpointVal)
	if(NumSetpoint ~= nil) then
		if(Scale == Thermostat.FAHRENHEIT) then
			local FTemp = Thermostat.FRound(NumSetpoint)
			if(FTemp ~= self._PersistData._VacationCoolSetpointF) then
				self._PersistData._VacationCoolSetpointF = FTemp
				self._PersistData._VacationCoolSetpointC = Thermostat.CRound(Thermostat.FtoC(NumSetpoint))
				NOTIFY.VACATION_SETPOINTS(self._PersistData._VacationHeatSetpointF, self._PersistData._VacationCoolSetpointF, Thermostat.FAHRENHEIT, self._BindingID)
			end
		else
			local CTemp = Thermostat.CRound(NumSetpoint)
			if(CTemp ~= self._PersistData._VacationCoolSetpointC) then
				self._PersistData._VacationCoolSetpointF = Thermostat.FRound(Thermostat.CtoF(NumSetpoint))
				self._PersistData._VacationCoolSetpointC = CTemp
				NOTIFY.VACATION_SETPOINTS(self._PersistData._VacationHeatSetpointC, self._PersistData._VacationCoolSetpointC, Thermostat.CELSIUS, self._BindingID)
			end
		end
	else
		LogError('Invalid Vacation Heat Setpoint: %s  (Should be a number)', tostring(SetpointVal))
	end
end


function Thermostat:ChangeCapability(CapName, CapVal)
	local SendChange = true

	if(CapName == "CAN_HEAT") then
		self._PersistData._CanHeat = toboolean(CapVal)

	elseif(CapName == "CAN_COOL") then
		self._PersistData._CanCool = toboolean(CapVal)

	elseif(CapName == "CAN_AUTO") then
		self._PersistData._CanAuto = toboolean(CapVal)

	elseif(CapName == "HEAT_SETPOINT_MIN_F") then
		self._PersistData._HeatSetpointMinF = tonumber(CapVal)

	elseif(CapName == "HEAT_SETPOINT_MIN_C") then
		self._PersistData._HeatSetpointMinC = tonumber(CapVal)

	elseif(CapName == "HEAT_SETPOINT_MAX_F") then
		self._PersistData._HeatSetpointMaxF = tonumber(CapVal)

	elseif(CapName == "HEAT_SETPOINT_MAX_C") then
		self._PersistData._HeatSetpointMaxC = tonumber(CapVal)

	elseif(CapName == "HEAT_SETPOINT_RESOLUTION_F") then
		self._PersistData._HeatSetpointResF = tonumber(CapVal)

	elseif(CapName == "HEAT_SETPOINT_RESOLUTION_C") then
		self._PersistData._HeatSetpointResC = tonumber(CapVal)

	elseif(CapName == "HEATCOOL_SETPOINTS_DEADBAND_F") then
		self._PersistData._HeatCoolDeadbandF = tonumber(CapVal)

	elseif(CapName == "HEATCOOL_SETPOINTS_DEADBAND_C") then
		self._PersistData._HeatCoolDeadbandC = tonumber(CapVal)

	elseif(CapName == "COOL_SETPOINT_MIN_F") then
		self._PersistData._CoolSetpointMinF = tonumber(CapVal)

	elseif(CapName == "COOL_SETPOINT_MIN_C") then
		self._PersistData._CoolSetpointMinC = tonumber(CapVal)

	elseif(CapName == "COOL_SETPOINT_MAX_F") then
		self._PersistData._CoolSetpointMaxF = tonumber(CapVal)

	elseif(CapName == "COOL_SETPOINT_MAX_C") then
		self._PersistData._CoolSetpointMaxC = tonumber(CapVal)

	elseif(CapName == "COOL_SETPOINT_RESOLUTION_F") then
		self._PersistData._CoolSetpointResF = tonumber(CapVal)

	elseif(CapName == "COOL_SETPOINT_RESOLUTION_C") then
		self._PersistData._CoolSetpointResC = tonumber(CapVal)

	elseif(CapName == "SINGLE_SETPOINT_MIN_F") then
		self._PersistData._SingleSetpointMinF = tonumber(CapVal)

	elseif(CapName == "SINGLE_SETPOINT_MIN_C") then
		self._PersistData._SingleSetpointMinC = tonumber(CapVal)

	elseif(CapName == "SINGLE_SETPOINT_MAX_F") then
		self._PersistData._SingleSetpointMaxF = tonumber(CapVal)

	elseif(CapName == "SINGLE_SETPOINT_MAX_C") then
		self._PersistData._SingleSetpointMaxC = tonumber(CapVal)

	elseif(CapName == "SINGLE_SETPOINT_RESOLUTION_F") then
		self._PersistData._SingleSetpointResF = tonumber(CapVal)

	elseif(CapName == "SINGLE_SETPOINT_RESOLUTION_C") then
		self._PersistData._SingleSetpointResC = tonumber(CapVal)

	elseif(CapName == "HAS_TEMPERATURE") then
		self._PersistData._HasTemperature = toboolean(CapVal)

	elseif(CapName == "HAS_OUTDOOR_TEMPERATURE") then
		self._PersistData._HasOutdoorTemperature = toboolean(CapVal)

	elseif(CapName == "CAN_HUMIDIFY") then
		self._PersistData._CanHumidfy = toboolean(CapVal)

	elseif(CapName == "CAN_DEHUMIDIFY") then
		self._PersistData._CanDehumidfy = toboolean(CapVal)

	elseif(CapName == "HAS_HUMIDITY") then
		self._PersistData._HasHumidity = toboolean(CapVal)

	elseif(CapName == "HUMIDIFY_SETPOINT_MIN") then
		self._PersistData._HumidifySetpointMin = tonumber(CapVal)

	elseif(CapName == "HUMIDIFY_SETPOINT_MAX") then
		self._PersistData._HumidifySetpointMax = tonumber(CapVal)

	elseif(CapName == "HUMIDIFY_SETPOINT_RESOLUTION") then
		self._PersistData._HumidifySetpointRes = tonumber(CapVal)

	elseif(CapName == "HUMIDITY_SETPOINTS_DEADBAND") then
		self._PersistData._HumidityDeadband = tonumber(CapVal)

	elseif(CapName == "DEHUMIDIFY_SETPOINT_MIN") then
		self._PersistData._DehumidifySetpointMin = tonumber(CapVal)

	elseif(CapName == "DEHUMIDIFY_SETPOINT_MAX") then
		self._PersistData._DehumidifySetpointMax = tonumber(CapVal)

	elseif(CapName == "DEHUMIDIFY_SETPOINT_RESOLUTION") then
		self._PersistData._DehumidifySetpointRes = tonumber(CapVal)

	elseif(CapName == "HAS_SINGLE_SETPOINT") then
		self._PersistData._HasSingleSetpoint = toboolean(CapVal)

	elseif(CapName == "TEMPERATURE_RESOLUTION_F") then
		self._PersistData._TemperatureResF = tonumber(CapVal)

	elseif(CapName == "TEMPERATURE_RESOLUTION_C") then
		self._PersistData._TemperatureResC = tonumber(CapVal)

	elseif(CapName == "OUTDOOR_TEMPERATURE_RESOLUTION_F") then
		self._PersistData._OutdoorTemperatureResF = tonumber(CapVal)

	elseif(CapName == "OUTDOOR_TEMPERATURE_RESOLUTION_C") then
		self._PersistData._OutdoorTemperatureResC = tonumber(CapVal)

	else
		--[[
			Possibly:
				HAS_EXTRAS
				CAN_PRESET
				CAN_PRESET_SCHEDULE
				HAS_HEAT_PUMP
				TEMPERATURE_MIN_F
				TEMPERATURE_MIN_C
				TEMPERATURE_MAX_F
				TEMPERATURE_MAX_C
				CAN_CHANGE_SCALE
		]]
		SendChange = false
		LogWarn("Thermostat:ChangeCapability Not supported capability change: %s", tostring(CapName))
	end

	if(SendChange) then
		NOTIFY.DYNAMIC_CAPABILITIES_CHANGED(CapName, CapVal, self._BindingID)
	end
end

function Thermostat:SetButtonsLockedFlag(AreLocked)
	if(self._PersistData._CanLockButtons) then
		self._ButtonsLocked = toboolean(AreLocked)
		NOTIFY.BUTTONS_LOCK_CHANGED(self._ButtonsLocked, self._BindingID)
	else
		LogWarn("Thermostat:SetButtonsLockedFlag  Button locking not supported.")
	end
end

function Thermostat:ScheduleEntryChanged(DayOfWeek, EntryIndex, TimeHours, TimeMinutes, IsEnabled, HeatSetpoint, CoolSetpoint, Scale)
	local DoWIndex = Thermostat.DoWConvert[DayOfWeek] or 0
	local SchedIndex = EntryIndex - 1		-- back to zero based
	local TimeMin = (TimeHours * 60) + TimeMinutes		-- minutes into the day
	local EnabledFlag = toboolean(IsEnabled)

	NOTIFY.SCHEDULE_ENTRY_CHANGED(DoWIndex, SchedIndex, EnabledFlag, TimeMin, HeatSetpoint, CoolSetpoint, Scale, self._BindingID)
end

--=============================================================================
--=============================================================================

function Thermostat:PrxSetScale(tParams)
	if(tParams.SCALE == "FAHRENHEIT") then
		ThermostatCom_SetScale(Thermostat.FAHRENHEIT)

	elseif(tParams.SCALE == "CELSIUS") then
		ThermostatCom_SetScale(Thermostat.CELSIUS)

	else
	 	LogWarn("Thermostat.PrxSetScale  Invalid Scale: %s", tostring(tParams.SCALE))

	end
end


function Thermostat.ExtractSetpointScale(tParams)
	local UseScale
	if(tParams.SETPOINT == tParams.FAHRENHEIT) then
		UseScale = Thermostat.FAHRENHEIT

	elseif(tParams.SETPOINT == tParams.CELSIUS) then
		UseScale = Thermostat.CELSIUS

	else
		UseScale = nil

	end
	return UseScale
end

function Thermostat:PrxSetSetpointHeat(tParams)
	LogTrace("Thermostat:PrxSetSetpointHeat")
	ThermostatCom_SetSetpointHeat(tParams.SETPOINT, Thermostat.ExtractSetpointScale(tParams))
end

function Thermostat:PrxSetSetpointCool(tParams)
	LogTrace("Thermostat:PrxSetSetpointCool")
	ThermostatCom_SetSetpointCool(tParams.SETPOINT, Thermostat.ExtractSetpointScale(tParams))
end

function Thermostat:PrxSetSetpointSingle(tParams)
	LogTrace("Thermostat:PrxSetSetpointSingle")
	ThermostatCom_SetSetpointSingle(tParams.SETPOINT, Thermostat.ExtractSetpointScale(tParams))
end

function Thermostat:PrxSetHVACMode(tParams)
	LogTrace("Thermostat:PrxSetHVACMode")
	ThermostatCom_SetHVACMode(tParams.MODE)
end

function Thermostat:PrxSetFanMode(tParams)
	LogTrace("Thermostat:PrxSetFanMode")
	ThermostatCom_SetFanMode(tParams.MODE)
end

function Thermostat:PrxSetHoldMode(tParams)
	LogTrace("Thermostat:PrxSetHoldMode")
	ThermostatCom_SetHoldMode(tParams.MODE)
end

function Thermostat:PrxUpdateScheduleEntries(tParams)
	-- LogTrace("Thermostat:PrxUpdateScheduleEntries")
	local EntriesTab = C4:ParseXml(tParams.ENTRIES)

	for _, CurSchedEntry in ipairs(EntriesTab.ChildNodes) do
		local EntryAttribs = CurSchedEntry.Attributes
		local DoW = Thermostat.DoWConvert[tonumber(EntryAttribs.DayOfWeek)]
		local Hrs = tonumber(EntryAttribs.EntryTime) / 60
		local Mns = tonumber(EntryAttribs.EntryTime) % 60
		local IsEnabled = toboolean(EntryAttribs.IsEnabled)
		local HeatSp = (tonumber(EntryAttribs.HeatSetpoint) / 10.0) - Thermostat.KELVIN_OFFSET
		local CoolSp = (tonumber(EntryAttribs.CoolSetpoint) / 10.0) - Thermostat.KELVIN_OFFSET

		if(self:IsCelsius()) then
			HeatSp = Thermostat.CRound(HeatSp)
			CoolSp = Thermostat.CRound(CoolSp)
		else
			HeatSp = Thermostat.FRound(Thermostat.CtoF(HeatSp))
			CoolSp = Thermostat.FRound(Thermostat.CtoF(CoolSp))
		end

		ThermostatCom_UpdateScheduleEntry(DoW, tonumber(EntryAttribs.EntryIndex) + 1,
										Hrs, Mns, IsEnabled,
										HeatSp, CoolSp, self:GetTemperatureScale())
	end

end

function Thermostat:PrxSetSetpointHumidfy(tParams)
	LogTrace("Thermostat:PrxSetSetpointHumidfy")
	ThermostatCom_SetSetpointHumidify(tParams.SETPOINT)
end

function Thermostat:PrxSetSetpointDehumidfy(tParams)
	LogTrace("Thermostat:PrxSetSetpointDehumidfy")
	ThermostatCom_SetSetpointDehumidify(tParams.SETPOINT)
end

function Thermostat:PrxSetVacationMode(tParams)
	LogTrace("Thermostat:PrxUpdateScheduleEntries")
	ThermostatCom_SetVacationMode(tParams.MODE)
end

function Thermostat:PrxSetVacationSetpointHeat(tParams)
	LogTrace("Thermostat:PrxSetVacationSetpointHeat")
	local CurScale = self:GetTemperatureScale()
	local Setpoint
	if(CurScale == Thermostat.FAHRENHEIT) then
		Setpoint = tParams.FAHRENHEIT

	elseif(CurScale == Thermostat.CELSIUS) then
		Setpoint = tParams.CELSIUS

	else
		LogWarn("Thermostat:PrxSetVacationSetpointHeat  Invalid Scale: %s", tostring(CurScale))
	end

	ThermostatCom_SetVacationSetpointHeat(Setpoint, CurScale)
end

function Thermostat:PrxSetVacationSetpointCool(tParams)
	LogTrace("Thermostat:PrxSetVacationSetpointCool")
	local CurScale = self:GetTemperatureScale()
	local Setpoint
	if(CurScale == Thermostat.FAHRENHEIT) then
		Setpoint = tParams.FAHRENHEIT

	elseif(CurScale == Thermostat.CELSIUS) then
		Setpoint = tParams.CELSIUS

	else
		LogWarn("Thermostat:PrxSetVacationSetpointCool  Invalid Scale: %s", tostring(CurScale))
	end

	ThermostatCom_SetVacationSetpointCool(Setpoint, CurScale)
end

function Thermostat:PrxSetButtonsLock(tParams)
	LogTrace("Thermostat:PrxSetButtonsLock")
	local LockIt = (tonumber(tParams.LOCK) == 1)
	ThermostatCom_SetButtonsLock(LockIt)
end

function Thermostat:PrxSetRemoteSensor(tParams)
	LogTrace("Thermostat:PrxSetRemoteSensor")
	local UseRemote = toboolean(tParams.IN_USE)
	ThermostatCom_UseRemoteSensor(UseRemote)
end

function Thermostat:PrxSetPresets(tParams)
	LogTrace("Thermostat:PrxSetPresets")
	LogInfo(tParams)
end

function Thermostat:PrxSetEvents(tParams)
	LogTrace("Thermostat:PrxSetEvents")
	LogInfo(tParams)
end


