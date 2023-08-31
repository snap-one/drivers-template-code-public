--[[=============================================================================
    Fan Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "fan_proxy.fan_proxy_commands"
require "fan_proxy.fan_proxy_notifies"
require "modules.c4_metrics"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.fan_device_class = "2023.06.01"
end

FanDevice = inheritsFrom(C4ProxyBase)

FanDevice.DIRECTION_FORWARD = "FORWARD"
FanDevice.DIRECTION_REVERSE = "REVERSE"


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function FanDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._PersistRecordName = string.format("Fan%dPersist", tonumber(BindingID))
	PersistData[self._PersistRecordName] = C4:PersistGetValue(self._PersistRecordName)
	
	if(PersistData[self._PersistRecordName] == nil) then
		PersistData[self._PersistRecordName] = {
			_SpeedLevels = tonumber(C4:GetCapability('discrete_levels') or 1),
			_CanSetPreset = C4:GetCapability('can_set_preset') or false,
			_PresetSpeed = tonumber(C4:GetCapability('preset_speed') or 1),
			_CanReverse = C4:GetCapability('can_reverse') or false,
		}

		self:PersistSave()
	end

	self._PersistData = PersistData[self._PersistRecordName]

	self._PowerOn = false
	self._SpinDirection = FanDevice.DIRECTION_FORWARD
	self._CurrentSpeed = 0

end


----------------------

function FanDevice:PersistSave()
	C4:PersistSetValue(self._PersistRecordName, PersistData[self._PersistRecordName])
end

----------------------

function FanDevice:InitialSetup()
	
end

-------------

function FanDevice:IsPowerOn()
	return self._PowerOn
end

function FanDevice:PowerFlagIs(PowerFlag)
	if(PowerFlag ~= self._PowerOn) then
		self._PowerOn = PowerFlag
		
		if(self._PowerOn) then
			DataLakeMetrics:MetricsCounter('Fan PowerOnSuccess')
			NOTIFY.FAN_ON(self._BindingID)
			
		else
			DataLakeMetrics:MetricsCounter('Fan PowerOffSuccess')
			NOTIFY.FAN_OFF(self._BindingID)
		end
	end
end

function FanDevice:GetSpinDirection()
	return self._SpinDirection
end

function FanDevice:CanReverse()
	return self._PersistData._CanReverse
end

function FanDevice:SetFanSpinDirection(Direction)
	if(self:CanReverse()) then
		local DirChar = Direction:sub(1,1):upper()	-- Be forgiving. Any string that starts with an "R", or "r" will be "REVERSE"
													-- Everything else will be FORWARD

		local NewSpinDirection = (DirChar == "R") and FanDevice.DIRECTION_REVERSE or FanDevice.DIRECTION_FORWARD
		if(self._SpinDirection ~= NewSpinDirection) then
			self._SpinDirection = NewSpinDirection
			NOTIFY.FAN_DIRECTION(self._SpinDirection, self._BindingID)
		end
	else
		LogWarn("FanDevice:SetFanSpinDirection  Fan doesn't support spin direction")
	end
end

function FanDevice:GetCurrentPreset()
	return self._PersistData._PresetSpeed
end

function FanDevice:SetPresetSpeed(PresetSpeedLevel)
	local nPresetSpeedLevel = tonumber(PresetSpeedLevel)
	if((nPresetSpeedLevel ~= nil) and (nPresetSpeedLevel > 0) and (nPresetSpeedLevel <= self._PersistData._SpeedLevels)) then
		self._PersistData._PresetSpeed = nPresetSpeedLevel
		NOTIFY.PRESET_SPEED(self._PersistData._PresetSpeed, self._BindingID)
	else
		LogWarn("FanDevice:SetPresetSpeed  Invalid speed preset level: %s", tostring(PresetSpeedLevel))
	end
end


function FanDevice:GetCurrentSpeed()
	return self._CurrentSpeed
end

function FanDevice:SetFanSpeed(SpeedLevel)
	local nSpeedLevel = tonumber(SpeedLevel)
	if((nSpeedLevel ~= nil) and (nSpeedLevel >= 0) and (nSpeedLevel <= self._PersistData._SpeedLevels)) then
		self._CurrentSpeed = nSpeedLevel
		self:PowerFlagIs(self._CurrentSpeed ~= 0)
		NOTIFY.FAN_CURRENT_SPEED(self._CurrentSpeed, self._BindingID)
	else
		LogWarn("FanDevice:SetFanSpeed  Invalid speed level: %s", tostring(SpeedLevel))
	end
end

function FanDevice:GetSpeedLevelMax()
	return self._PersistData._SpeedLevels
end

--=============================================================================
--=============================================================================

function FanDevice:PrxOn(tParams)
	LogTrace("FanDevice:PrxOn")
	FanCom_On()
end

function FanDevice:PrxOff(tParams)
	LogTrace("FanDevice:PrxOff")
	FanCom_Off()
end

function FanDevice:PrxToggle(tParams)
	LogTrace("FanDevice:PrxToggle")
	FanCom_Toggle()
end

function FanDevice:PrxDesignatePreset(tParams)
	LogTrace("FanDevice:PrxDesignatePreset")
	FanCom_DesignatePreset(tParams.PRESET)
end

function FanDevice:PrxSetSpeed(tParams)
	LogTrace("FanDevice:PrxSetSpeed")
	FanCom_SetSpeed(tParams.SPEED)
end

function FanDevice:PrxCycleSpeedUp(tParams)
	LogTrace("FanDevice:PrxCycleSpeedUp")
	FanCom_IncreaseSpeed()
end

function FanDevice:PrxCycleSpeedDown(tParams)
	LogTrace("FanDevice:PrxCycleSpeedDown")
	FanCom_DecreaseSpeed()
end

function FanDevice:PrxSetDirection(tParams)
	LogTrace("FanDevice:PrxSetDirection")
	if(self:CanReverse()) then
		FanCom_SetDirection(tParams.DIRECTION)
	else
		LogWarn("FanDevice:PrxToggleDirection  Fan doesn't support spin direction")
	end
end

function FanDevice:PrxToggleDirection(tParams)
	LogTrace("FanDevice:PrxToggleDirection")
	if(self:CanReverse()) then
		FanCom_ToggleDirection()
	else
		LogWarn("FanDevice:PrxToggleDirection  Fan doesn't support spin direction")
	end
end

