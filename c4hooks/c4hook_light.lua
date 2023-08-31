--[[=============================================================================
	File is: c4hook_light.lua
    Functions to manage the communication with the Control4 Light proxy

    Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_light = "2016.05.25"
end

require "c4hooks.c4hook_base"

C4H_Light = inheritsFrom(C4Hook_Base)


function C4H_Light:construct(BindingID, IsADimmer)
	self:super():construct(BindingID)

	self._Level = 0
	self._DefaultOnValue = 100
	self._IsADimmer = IsADimmer
end


function C4H_Light:destruct()
	self:super():destruct()
end


function C4H_Light:CmdOn(tParams)
	LogTrace("C4H_Light:CmdOn")
	self:SetLevel(self._DefaultOnValue)
end


function C4H_Light:CmdOff(tParams)
	LogTrace("C4H_Light:CmdOff")
	self:SetLevel(0)
end


function C4H_Light:CmdToggle(tParams)
	LogTrace("C4H_Light:CmdToggle")
	if(self:IsOn()) then
		self:CmdOff(tParams)
	else
		self:CmdOn(tParams)
	end
end


function C4H_Light:CmdSetLevel(tParams)
	LogTrace("C4H_Light:SetLevel")
	local TargetLevel = tonumber(tParams.LEVEL)
	self:SetLevel(TargetLevel)
end


function C4H_Light:SetLevel(DesiredLevel)
 	if(C4H_Light.SetLevelOnDevice ~= nil) then
		self.SetLevelOnDevice(DesiredLevel, self._BindingID)		-- API call
	end
end


function C4H_Light:ReceivedLevelFromDevice(ReportedLevel)
	local TargetLevel = tonumber(ReportedLevel)
	LogTrace("C4H_Light:ReceivedLevelFromDevice  Level is: %d", TargetLevel)
	
	if(self._IsADimmer) then
		if(TargetLevel == 0xFF) then
			-- ZWave uses 0xFF to just mean 'ON'; otherwise the value is 0 ~ 99. We'll just use it
			TargetLevel = self._DefaultOnValue
		end
	else
		-- just a switch, either on or off
		TargetLevel = (TargetLevel ~= 0) and self._DefaultOnValue or 0
	end
	
	if(self._Level ~= TargetLevel) then
		self._Level = TargetLevel
		NOTIFY.LIGHT_LEVEL_CHANGED(self._Level, self._BindingID)
	end
end


function C4H_Light:IsOn()
	return (self._Level ~= 0)
end


--[[=============================================================================
	Commands
===============================================================================]]

function PRX_CMD.ON(idBinding, tParams)
	LogTrace("PRX_CMD.ON")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdOn(tParams)
	end
end


function PRX_CMD.OFF(idBinding, tParams)
	LogTrace("PRX_CMD.OFF")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdOff(tParams)
	end
end


function PRX_CMD.TOGGLE(idBinding, tParams)
	LogTrace("PRX_CMD.TOGGLE")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdToggle(tParams)
	end
end


function PRX_CMD.SET_LEVEL(idBinding, tParams)
	LogTrace("PRX_CMD.SET_LEVEL")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdSetLevel(tParams)
	end
end


function PRX_CMD.CLICK_TOGGLE_BUTTON(idBinding, tParams)
	LogTrace("PRX_CMD.CLICK_TOGGLE_BUTTON")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdToggle(tParams)
	end
end

--[[=============================================================================
	Notifications
===============================================================================]]

function NOTIFY.LIGHT_LEVEL_CHANGED(NewLightLevel, BindingID)
	LogTrace("NOTIFY.LIGHT_LEVEL_CHANGED on Binding %d : %d", tonumber(BindingID), tonumber(NewLightLevel))
	SendNotify("LIGHT_LEVEL_CHANGED", tostring(NewLightLevel), BindingID)
end

