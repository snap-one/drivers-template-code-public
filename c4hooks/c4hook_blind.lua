--[[=============================================================================
	File is: c4hook_blind.lua
    Functions to manage the communication with the Control4 Blind proxy

    Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_blind = "2016.05.25"
end

require "c4hooks.c4hook_base"

C4H_Blind = inheritsFrom(C4Hook_Base)


function C4H_Blind:construct(BindingID)
	self:super():construct(BindingID)

	self._Level = 0
	self._DefaultOnValue = 100
end


function C4H_Blind:destruct()
	self:super():destruct()
end


function C4H_Blind:CmdStop(tParams)
	LogTrace("C4H_Blind:CmdStop")
	if(C4H_Blind.SetLevelOnDevice ~= nil) then
		self.StopMovementOnDevice(self._BindingID)		-- API call
	end
end


function C4H_Blind:CmdSetLevelTarget(tParams)
	LogTrace("C4H_Blind:CmdSetLevelTarget")
	local TargetLevel = tonumber(tParams.LEVEL_TARGET)
	self:SetLevel(TargetLevel)
end


function C4H_Blind:SetLevel(DesiredLevel)
 	if(C4H_Blind.SetLevelOnDevice ~= nil) then
	   -- calculate ramp
	   local totalRampTimeIncrement = Properties["Ramp Time"] * 10
	   local movementRange = math.abs(self._Level - DesiredLevel)
	   local rampTime = movementRange * totalRampTimeIncrement
	
	     NOTIFY.BLIND_MOVING(DesiredLevel, rampTime, self._BindingID)
		self.SetLevelOnDevice(DesiredLevel, self._BindingID)		-- API call
	end
end


function C4H_Blind:ReceivedLevelFromDevice(ReportedLevel)
	local TargetLevel = tonumber(ReportedLevel)
	LogTrace("C4H_Blind:ReceivedLevelFromDevice  Level is: %d", TargetLevel)
	
	 if(TargetLevel == 0xFF) then
		 -- ZWave uses 0xFF to just mean 'ON'; otherwise the value is 0 ~ 99. We'll just use it
		 TargetLevel = self._DefaultOnValue
	 end
	
	if(self._Level ~= TargetLevel) then
		self._Level = TargetLevel
		NOTIFY.BLIND_STOPPED(self._Level, self._BindingID)
	end
end


--[[=============================================================================
	Commands
===============================================================================]]


function PRX_CMD.SET_LEVEL_TARGET(idBinding, tParams)
	LogTrace("PRX_CMD.SET_LEVEL_TARGET")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdSetLevelTarget(tParams)
	end
end


function PRX_CMD.STOP(idBinding, tParams)
	LogTrace("PRX_CMD.STOP")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdStop(tParams)
	end
end

--[[=============================================================================
	Notifications
===============================================================================]]

function NOTIFY.BLIND_STOPPED(NewBlindLevel, BindingID)
	LogTrace("NOTIFY.BLIND_STOPPED on Binding %d : %d", tonumber(BindingID), tonumber(NewBlindLevel))
	SendNotify("STOPPED", {LEVEL = NewBlindLevel}, BindingID)
end


function NOTIFY.BLIND_MOVING(NewBlindLevel, RampTime, BindingID)
	LogTrace("NOTIFY.BLIND_MOVING on Binding %d level: %d ramp time: %d", tonumber(BindingID), tonumber(NewBlindLevel), tonumber(RampTime))
	SendNotify("MOVING", {LEVEL_TARGET = NewBlindLevel, RAMP_RATE = RampTime}, BindingID)
end

