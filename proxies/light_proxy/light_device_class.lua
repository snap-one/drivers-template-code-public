--[[=============================================================================
    Light Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "light_proxy.light_proxy_commands"
require "light_proxy.light_proxy_notifies"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_device_class = "2023.04.28"
end

LightDevice = inheritsFrom(C4ProxyBase)

---@alias buttonId_t
---|`LightDevice.BUTTON_ID_TOP` 0 -> Top Button (LightDevice.BUTTON_ID_TOP)
---|`LightDevice.BUTTON_ID_BOTTOM` 1 -> Bottom Button (LightDevice.BUTTON_ID_BOTTOM)
---|`LightDevice.BUTTON_ID_TOGGLE` 2 -> Toggle Button (LightDevice.BUTTON_ID_TOGGLE)

LightDevice.BUTTON_ID_TOP    = 0
LightDevice.BUTTON_ID_BOTTOM = 1
LightDevice.BUTTON_ID_TOGGLE = 2

---@alias buttonAction_t
---|`LightDevice.BUTTON_ACTION_RELEASE` 0 -> Release (LightDevice.BUTTON_ACTION_RELEASE)
---|`LightDevice.BUTTON_ACTION_PRESS` 1 -> Press (LightDevice.BUTTON_ACTION_PRESS)
---|`LightDevice.BUTTON_ACTION_CLICK` 2 -> Click (LightDevice.BUTTON_ACTION_CLICK)
---|`LightDevice.BUTTON_ACTION_DOUBLE_CLICK` 3 -> Double Click (LightDevice.BUTTON_ACTION_DOUBLE_CLICK)
---|`LightDevice.BUTTON_ACTION_TRIPLE_CLICK` 4 -> Triple Click (LightDevice.BUTTON_ACTION_TRIPLE_CLICK)

LightDevice.BUTTON_ACTION_RELEASE      = 0
LightDevice.BUTTON_ACTION_PRESS        = 1
LightDevice.BUTTON_ACTION_CLICK        = 2
LightDevice.BUTTON_ACTION_DOUBLE_CLICK = 3
LightDevice.BUTTON_ACTION_TRIPLE_CLICK = 4

---@alias colorMode_t
---|`LightDevice.COLOR_MODE_FULL_COLOR` 0 -> Full Color (LightDevice.COLOR_MODE_FULL_COLOR)
---|`LightDevice.COLOR_MODE_CCT` 1 -> CCT (LightDevice.COLOR_MODE_CCT)

LightDevice.COLOR_MODE_FULL_COLOR = 0
LightDevice.COLOR_MODE_CCT        = 1

LightDevice.DEFAULT_ON_COLOR_PRESET_ID = 1
LightDevice.DEFAULT_OFF_COLOR_PRESET_ID = 2

-- Preset origin enums in the light proxy
LightDevice.COLOR_PRESET_ORIGIN_INVALID = 0
LightDevice.COLOR_PRESET_ORIGIN_DEVICE = 1
LightDevice.COLOR_PRESET_ORIGIN_GLOBAL = 2

LightDevice.LIGHT_ON = true
LightDevice.LIGHT_OFF = false


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function LightDevice:construct(BindingID, InstanceName, ButtonLinkBindingIdBase)
	self:super():construct(BindingID, self, InstanceName)
	self._ButtonLinkBindingIdBase = ButtonLinkBindingIdBase
end

function LightDevice:InitialSetup()

	if (PersistData.LightPersist == nil) then
		self._PersistData = {}
		PersistData.LightPersist = self._PersistData
		self._PersistData.autoSwitch = false
		self._PersistData.autoButton = false
		self._PersistData.warmDimming = false
		self._PersistData.autoGroup = false
		self._PersistData.autoGroupCommands = false
		self._PersistData.autoAls = false
		self._PersistData.buttonDebounceMilliseconds = 250
		self._PersistData.onlineStatus = false
		self._PersistData.level = 0
		self._PersistData.presetLevel = 100
		self._PersistData.clickRateUp = 250
		self._PersistData.clickRateDown = 750
		self._PersistData.holdRateUp = 5000
		self._PersistData.holdRateDown = 5000
		self._PersistData.minOnLevel = 1
		self._PersistData.maxOnLevel = 100
		self._PersistData.coldStartLevel = 0
		self._PersistData.coldStartTime = 0
		self._PersistData.numberButtons = 3
		self._PersistData.groupsHaveSync = false
		self._PersistData.brightnessOnMode = nil

	else
		self._PersistData = PersistData.LightPersist
	end
	if (self._PersistData.buttonColors == nil) then
		self._PersistData.buttonColors = {}
		for i = 0, self._PersistData.numberButtons-1 do
			if (i%3 == 1) then
				self._PersistData.buttonColors[i] = { pressed = false, onColor = '0000ff', offColor = '000000' }
			else
				self._PersistData.buttonColors[i] = { pressed = false, onColor = '000000', offColor = '0000ff' }
			end
		end
	end
	if (self._PersistData.Als == nil) then
		self._PersistData.Als = {}
	end
	if (self._PersistData.Groups == nil) then
		self._PersistData.Groups = {}
	end

	self._PersistData.supportsTarget = self._PersistData.supportsTarget or false
	self._PersistData.supportsColor = self._PersistData.supportsColor or false
	self._PersistData.supportsColorTemperature = self._PersistData.supportsColorTemperature or false

	self._PersistData.lightColor = self._PersistData.lightColor or {}

	self.debounceTimers = {}
	self.rampTimer = nil
	self.AlsTimers = {}
	self.lastState = nil

	-- Next on color. On Color can be different than the Default On color [DRIV-7274].
	-- E.g. if command to set the color is sent while the light was off, driver should 'save' that
	-- color and turn on to the last color that was received from the proxy.
	-- Table, same keys as for the Default On/Dim colors
	self.NextOnColor = nil
	-- colorCommandReceived is variable that is true when light got color command. It goes to false
	-- when light is turned off. WD will became inactive when this variable is set to true.
	self.colorCommandReceived = nil
end

function LightDevice:LateSetup()
	self._PersistData.isDimmer = self._PersistData.isDimmer or toboolean(self:GetCapabilityValue("dimmer"))
	LogDebug("LightDevice:LateSetup isDimmer %s", tostring(self._PersistData.isDimmer))

	self._PersistData.supportsColor = self._PersistData.supportsColor or toboolean(self:GetCapabilityValue("supports_color"))
	LogDebug("LightDevice:LateSetup supportsColor %s", tostring(self._PersistData.supportsColor))

	self._PersistData.supportsColorTemperature = self._PersistData.supportsColorTemperature or toboolean(self:GetCapabilityValue("supports_color_correlated_temperature"))
	LogDebug("LightDevice:LateSetup supportsColor %s", tostring(self._PersistData.supportsColorTemperature))

	self._PersistData.supportsTarget = self._PersistData.supportsTarget or toboolean(self:GetCapabilityValue("supports_target"))
	LogDebug("LightDevice:LateSetup supportsTarget %s", tostring(self._PersistData.supportsTarget))
end

--=============================================================================

function LightDevice:_StopButtonDebounceTimer(buttonId)
	if (self.debounceTimers[buttonId]) then
		self.debounceTimers[buttonId]:Cancel()
		self.debounceTimers[buttonId] = false
	end
end

function LightDevice:GroupCheckSync(strCommand, tParams)
	local hasSync = self._PersistData.autoGroup and self._PersistData.groupsHaveSync
	if hasSync then
		for groupId, keepSync in pairs(self._PersistData.Groups) do
			if (keepSync) then
				LogTrace('SendToDevice %d %s', groupId, strCommand)
				C4:SendToDevice(groupId, strCommand, tParams)
			end
		end
	end
	return hasSync
end

function LightDevice:PrxButtonAction(buttonId, action)
	LogTrace("LightDevice:PrxButtonAction %d %d", buttonId, action)
	if (self:GroupCheckSync('BUTTON_ACTION', { BUTTON_ID = buttonId, ACTION = action })) then
		return
	else
		if (self._PersistData.autoButton) then
			if (action == self.BUTTON_ACTION_PRESS) then
				if (not self._PersistData.buttonColors[buttonId].pressed) then
					self._PersistData.buttonColors[buttonId].pressed = true
					if (self._PersistData.isDimmer) then
						self.debounceTimers[buttonId] = C4:SetTimer(
							self._PersistData.buttonDebounceMilliseconds,
							function(oTimer)
								self._PersistData.buttonColors[buttonId].pressed = false
								self.debounceTimers[buttonId] = false
								self:ButtonStartRamp(buttonId)
							end
						)
					else
						self:ButtonDo(buttonId)
					end
				end
			elseif (action == self.BUTTON_ACTION_CLICK) then
				self._PersistData.buttonColors[buttonId].pressed = false
				if (self._PersistData.isDimmer) then
					self:_StopButtonDebounceTimer(buttonId)
					self:ButtonDo(buttonId)
				end
			elseif (action == self.BUTTON_ACTION_RELEASE) then
				self._PersistData.buttonColors[buttonId].pressed = false
				if (self._PersistData.isDimmer) then
					self:_StopButtonDebounceTimer(buttonId)
					self:ButtonStopRamp(buttonId)
				end
			else
				if (self._PersistData.isDimmer) then
					self:_StopButtonDebounceTimer(buttonId)
				end
				self._PersistData.buttonColors[buttonId].pressed = false
			end
		else
			LightCom_ButtonAction(buttonId, action)
		end

		LightReport_ButtonAction(buttonId, action)
	end
end


function LightDevice:PrxGetConnectedState()
	LogTrace("LightDevice:PrxGetConnectedState")
	self:ReportLightOnlineChanged(self._PersistData.onlineStatus)
end


function LightDevice:PrxGetLightLevel()
	LogTrace("LightDevice:PrxGetLightLevel")
	self:ReportLightLightLevel(self._PersistData.level)
end


function LightDevice:PrxOff()
	LogTrace("LightDevice:PrxOff")
	self:AlsStopAll()
	if not self:GroupCheckSync('OFF') then
		if (self._PersistData.autoSwitch) then
			self:PrxSetLevel(0, true)
		else
			LightCom_Off()
		end
	end
end


function LightDevice:PrxOn()
	LogTrace("LightDevice:PrxOn")
	self:AlsStopAll()
	if not self:GroupCheckSync('ON') then
		if (self._PersistData.autoSwitch) then
			self:PrxSetLevel(self:GetPresetLevel(), true)
		else
			LightCom_On()
		end
	end
end


function LightDevice:SetBrightnessTarget(brightnessTarget, milliseconds, skipColor)
	LogTrace("LightDevice:SetBrightnessTarget %d %d", brightnessTarget, milliseconds)
	if self.NextOnColor then
		LogTrace("NextOnColor: %s", self:ColorDebugString(self.NextOnColor.x, self.NextOnColor.y,
			self.NextOnColor.mode))
	end

	local defaultOff, defaultOn = self:GetDefaultColors()
	local onColor = self.NextOnColor or defaultOn
	local isSpecialTransition = (self:IsLightTurningOn(brightnessTarget) and onColor) or
		(self:IsLightTurningOff(brightnessTarget) and defaultOff) or self:IsWarmDimmingActive()

	LogTrace("LightDevice:SetBrightnessTarget isSpecialTransition %s", tostring(isSpecialTransition))
	if (not self:SupportsColor() or skipColor or not isSpecialTransition) then
		LightCom_SetBrightnessTarget(brightnessTarget, milliseconds)
		return
	end

	local x, y, targetMode
	if self:IsWarmDimmingActive() then
		x, y, targetMode = self:CalculateWarmDimmingTargetColor(brightnessTarget)
	else
		if self:IsLightTurningOn(brightnessTarget) then
			LogTrace("LightDevice:SetBrightnessTarget LightIsTurningOn")
			x = onColor.x
			y = onColor.y
			targetMode = onColor.mode
		elseif self:IsLightTurningOff(brightnessTarget) then
			LogTrace("LightDevice:SetBrightnessTarget LightIsTurningOff")
			x = defaultOff.x
			y = defaultOff.y
			targetMode = defaultOff.mode
		end
	end
	LightCom_RampToColorAndBrightnessTarget(brightnessTarget, x, y, targetMode, milliseconds, milliseconds)
end


function LightDevice:PrxSetBrightnessTarget(brightnessTarget, milliseconds)
	LogTrace("LightDevice:PrxSetBrightnessTarget %d %d", brightnessTarget, milliseconds)

	self:AlsStopAll()

	if self:GroupCheckSync('RAMP_TO_LEVEL', { LEVEL = brightnessTarget, TIME = milliseconds }) then
		return
	end

	self:SetBrightnessTarget(brightnessTarget, milliseconds)
end


function LightDevice:PrxRampToLevel(level, milliseconds, skipStop, skipGroup, skipColor)
	LogTrace("LightDevice:PrxRampToLevel %d %d", level, milliseconds)

	if (not skipStop) then
		self:AlsStopAll()
	end

	if (not skipGroup and self:GroupCheckSync('RAMP_TO_LEVEL', { LEVEL = level, TIME = milliseconds })) then
		return
	end

	self:SetBrightnessTarget(level, milliseconds, skipColor)
end


function LightDevice:PrxSetLevel(level, skipStop, skipGroup, skipColor)
	LogTrace("LightDevice:PrxSetLevel %d", level)

	if (not skipStop) then
		self:AlsStopAll()
	end

	if (not skipGroup and self:GroupCheckSync('SET_LEVEL', { LEVEL = level })) then
		return
	end

	self:SetBrightnessTarget(level, 0, skipColor)
end


function LightDevice:PrxStartRampDimming(brightnessTarget, milliseconds, x, y, colorMode)
	LogTrace("LightDevice:PrxStartRampDimming %d %d", brightnessTarget, milliseconds)
	self:AlsStopAll()

	local _, defaultOn = self:GetDefaultColors()
	local onColor = self.NextOnColor or defaultOn
	local targetMode = colorMode
	if  self:IsWarmDimmingActive() then
		x, y, targetMode = self:CalculateWarmDimmingTargetColor(brightnessTarget)
	elseif self:SupportsColor() and defaultOn and self:IsLightTurningOn(brightnessTarget) then
		LogTrace("LightDevice:PrxStartRampDimming LightIsTurningOn")
		x = onColor.x
		y = onColor.y
		targetMode = onColor.mode
	end
	LightCom_StartRampDimming(milliseconds, brightnessTarget, x, y, targetMode)
end

function LightDevice:PrxSetAllLed(color)
	LogTrace("LightDevice:PrxSetAllLed %s", color)
	for i = 0, self._PersistData.numberButtons-1 do
		self:ReportLightButtonInfo(i, color, color)
	end
end


function LightDevice:PrxSetButtonColor(idBinding, buttonId, onColor, offColor, currentColor)
	LogTrace("LightDevice:PrxSetButtonColor %d %d %s %s %s", idBinding, buttonId, onColor, offColor, currentColor)
	if (buttonId == nil and idBinding ~= self:GetBindingID()) then
		buttonId = self:getButtonIdFromBindingId(idBinding)
	end
	if (self:buttonIdIsValid(buttonId)) then
		self:ReportLightButtonInfo(buttonId, onColor, offColor, currentColor)
	end
end


function LightDevice:PrxSetClickRateUp(milliseconds)
	LogTrace("LightDevice:PrxSetClickRateUp %d", milliseconds)
	LightCom_SetClickRateUp(milliseconds)
end


function LightDevice:PrxSetClickRateDown(milliseconds)
	LogTrace("LightDevice:PrxSetClickRateDown %d", milliseconds)
	LightCom_SetClickRateDown(milliseconds)
end


function LightDevice:PrxSetColdStartLevel(level)
	LogTrace("LightDevice:PrxSetColdStartLevel %d", level)
	LightCom_SetColdStartLevel(level)
end


function LightDevice:PrxSetColdStartTime(milliseconds)
	LogTrace("LightDevice:PrxSetColdStartTime %d", milliseconds)
	LightCom_SetColdStartTime(milliseconds)
end


function LightDevice:PrxSetHoldRateDown(milliseconds)
	LogTrace("LightDevice:PrxSetHoldRateDown %d", milliseconds)
	LightCom_SetHoldRateDown(milliseconds)
end


function LightDevice:PrxSetHoldRateUp(milliseconds)
	LogTrace("LightDevice:PrxSetHoldRateUp %d", milliseconds)
	LightCom_SetHoldRateUp(milliseconds)
end


function LightDevice:PrxSetMaxOnLevel(level)
	LogTrace("LightDevice:PrxSetMaxOnLevel %d", level)
	LightCom_SetMaxOnLevel(level)
end


function LightDevice:PrxSetMinOnLevel(level)
	LogTrace("LightDevice:PrxSetMinOnLevel %d", level)
	LightCom_SetMinOnLevel(level)
end


function LightDevice:PrxSetPresetLevel(level)
	LogTrace("LightDevice:PrxSetPresetLevel %d", level)
	LightCom_SetPresetLevel(level)
end

function LightDevice:PrxToggle()
	LogTrace("LightDevice:PrxToggle")
	self:AlsStopAll()

	if self:GroupCheckSync('TOGGLE') then return end

	if (self._PersistData.autoSwitch) then
		if (self:getLevelState()) then
			self:PrxOff()
		else
			self:PrxOn()
		end
	else
		LightCom_Toggle()
	end
end


function LightDevice:PrxDoPush(idBinding)
	LogTrace("LightDevice:PrxDoPush %d", idBinding)
	local buttonId = self:getButtonIdFromBindingId(idBinding)
	if (self:buttonIdIsValid(buttonId)) then
		self:PrxButtonAction(buttonId, self.BUTTON_ACTION_PRESS)
	end
end


function LightDevice:PrxDoClick(idBinding)
	LogTrace("LightDevice:PrxDoClick %d", idBinding)
	local buttonId = self:getButtonIdFromBindingId(idBinding)
	if (self:buttonIdIsValid(buttonId)) then
		self:PrxButtonAction(buttonId, self.BUTTON_ACTION_CLICK)
	end
end


function LightDevice:PrxDoRelease(idBinding)
	LogTrace("LightDevice:PrxDoRelease %d", idBinding)
	local buttonId = self:getButtonIdFromBindingId(idBinding)
	if (self:buttonIdIsValid(buttonId)) then
		self:PrxButtonAction(buttonId, self.BUTTON_ACTION_RELEASE)
	end
end


function LightDevice:PrxRequestButtonColors(idBinding)
	LogTrace("LightDevice:PrxRequestButtonColors %d", idBinding)
	local buttonId = self:getButtonIdFromBindingId(idBinding)
	if (self:buttonIdIsValid(buttonId)) then
		self:ReportLightButtonColorsAndMatch(buttonId, idBinding)
	end
end


function LightDevice:PrxActivateScene(sceneId)
	LogTrace("LightDevice:PrxActivateScene %d", sceneId)
	self:AlsStopAll()
	if (self._PersistData.autoAls) then
		self._PersistData.Als[sceneId].state = 0
		self:AlsDo(sceneId)
	else
		LightCom_ActivateScene(sceneId)
	end
end


function LightDevice:PrxAllScenesPushed()
	LogTrace("LightDevice:PrxAllScenesPushed")
	if (not self._PersistData.autoAls) then
		LightCom_AllScenesPushed()
	end
end


function LightDevice:PrxClearAllScenes()
	LogTrace("LightDevice:PrxClearAllScenes")
	if (self._PersistData.autoAls) then
		self._PersistData.Als = {}
	else
		LightCom_ClearAllScenes()
	end
end


function LightDevice:PrxPushScene(sceneId, elements, flash, ignoreRamp, fromGroup)
	LogTrace("LightDevice:PrxPushScene %d \"%s\" %s %s %s", sceneId, elements, tostring(flash), tostring(ignoreRamp), tostring(fromGroup))
	if (self._PersistData.autoAls) then
		self._PersistData.Als[sceneId] = {
			elements = self:AlsXmlToTable(elements),
			flash = flash,
			ignoreRamp = ignoreRamp,
			fromGroup = fromGroup
		}
	else
		LightCom_PushScene(sceneId, elements, flash, ignoreRamp, fromGroup)
	end
end


function LightDevice:PrxRampSceneDown(sceneId, milliseconds)
	LogTrace("LightDevice:PrxRampSceneDown %d %d", sceneId, milliseconds)
	if (self._PersistData.Als[sceneId].ignoreRamp == false) then
		self:RampStop()
		self:AlsStopAll()
		local elements = self._PersistData.Als[sceneId].elements
		local x = elements[#elements].colorX
		local y = elements[#elements].colorY
		local colorMode = elements[#elements].colorMode
		if (self._PersistData.autoAls) then
			self:PrxStartRampDimming(0, milliseconds, x, y,colorMode)
		else
			LightCom_RampSceneDown(sceneId, milliseconds)
		end
	end
end


function LightDevice:PrxRampSceneUp(sceneId, milliseconds)
	LogTrace("LightDevice:PrxRampSceneUp %d %d", sceneId, milliseconds)
	if (self._PersistData.Als[sceneId].ignoreRamp == false) then
		self:RampStop()
		self:AlsStopAll()
		local elements = self._PersistData.Als[sceneId].elements
		local x = elements[#elements].colorX
		local y = elements[#elements].colorY
		local colorMode = elements[#elements].colorMode
		if (self._PersistData.autoAls) then
			self:PrxStartRampDimming(self:GetPresetLevel(), milliseconds, x, y, colorMode)
		else
			LightCom_RampSceneUp(sceneId, milliseconds)
		end
	end
end


function LightDevice:PrxRemoveScene(sceneId)
	LogTrace("LightDevice:PrxRemoveScene %d", sceneId)
	if (self._PersistData.autoAls) then
		self._PersistData.Als[sceneId] = nil
	else
		LightCom_RemoveScene(sceneId)
	end
end


function LightDevice:PrxStopSceneRamp(sceneId)
	LogTrace("LightDevice:PrxStopSceneRamp %d", sceneId)
	self:RampStop()
	self:AlsStopAll()
	if (not self._PersistData.autoAls) then
		LightCom_StopRampScene(sceneId)
	end
end


function LightDevice:PrxGroupRampToLevel(groupId, level, milliseconds)
	LogTrace("LightDevice:PrxGroupRampToLevel %d %d %d", groupId, level, milliseconds)
	self:RampStop()
	self:AlsStopAll()
	if (self._PersistData.autoGroupCommands) then
		self:PrxRampToLevel(level, milliseconds, true, true, self:ShouldSkipColor(level))
	else
		LightCom_GroupRampToLevel(groupId, level, milliseconds)
	end
end


function LightDevice:PrxGroupSetLevel(groupId, level)
	LogTrace("LightDevice:PrxGroupSetLevel %d %d", groupId, level)
	self:RampStop()
	self:AlsStopAll()
	if (self._PersistData.autoGroupCommands) then
		self:PrxSetLevel(level, true, true, self:ShouldSkipColor(level))
	else
		LightCom_GroupSetLevel(groupId, level)
	end
end


function LightDevice:PrxGroupStartRamp(groupId, rampUp, milliseconds)
	LogTrace("LightDevice:PrxGroupStartRamp %d %s %d", groupId, tostring(rampUp), milliseconds)
	self:RampStop()
	self:AlsStopAll()
	if (self._PersistData.autoGroupCommands) then
		local brightnessTarget = rampUp and self:GetPresetLevel() or 0
		self:PrxStartRampDimming(brightnessTarget, milliseconds)
	else
		LightCom_GroupStartRamp(groupId, rampUp, milliseconds)
	end
end


function LightDevice:PrxGroupStopRamp(groupId)
	LogTrace("LightDevice:PrxGroupStopRamp %d", groupId)
	self:RampStop()
	self:AlsStopAll()
	if (not self._PersistData.autoGroupCommands) then
		LightCom_GroupStopRamp(groupId)
	end
end


function LightDevice:PrxJoinGroup(groupId, keepSync)
	LogTrace("LightDevice:PrxJoinGroup %d %s", groupId, tostring(keepSync))
	if ( self._PersistData.autoGroup) then
		self._PersistData.Groups[groupId] = keepSync
		self:CalcGroupsHaveSync()
	else
		LightCom_JoinGroup(groupId, keepSync)
	end
end


function LightDevice:PrxLeaveGroup(groupId)
	LogTrace("LightDevice:PrxLeaveGroup %d", groupId)
	if ( self._PersistData.autoGroup) then
		self._PersistData.Groups[groupId] = nil
		self:CalcGroupsHaveSync()
	else
		LightCom_LeaveGroup(groupId)
	end
end


function LightDevice:PrxSetGroupSync(groupId, keepSync)
	LogTrace("LightDevice:PrxSetGroupSync %d %s", groupId, tostring(keepSync))
	if ( self._PersistData.autoGroup) then
		self._PersistData.Groups[groupId] = keepSync
		self:CalcGroupsHaveSync()
	else
		LightCom_SetGroupSync(groupId, keepSync)
	end
end

function LightDevice:PrxSetColorTarget(x, y, colorMode, milliseconds)
	LogTrace("LightDevice:PrxSetColorTarget %s, Rate = %dms", self:ColorDebugString(x, y, colorMode),
		milliseconds)
	-- If color is received while the light is off, save it. Light should turn on to that color instead
	-- of the Default On Color. Also notify the proxy that the color has changed
	self.colorCommandReceived = true
	if not self:GetLightState() then
		LogTrace("LightDevice:PrxSetColorTarget: Light if off, not setting color.")
		self.NextOnColor = { x = x, y = y, mode = colorMode }
		LightReport_LightColorChanged(x, y, colorMode)
	else
		LightCom_SetColorTarget(x, y, colorMode, milliseconds)
	end
end


--=============================================================================

function LightDevice:ReportLightButtonAction(ButtonId, Action)
	ButtonId = tointeger(ButtonId)
	Action = tointeger(Action)
	LogTrace("LightDevice:ReportLightButtonAction %d %d", ButtonId, Action)
	NOTIFY.BUTTON_ACTION(ButtonId, Action, self:GetBindingID())
end


function LightDevice:ReportLightButtonInfo(ButtonId, OnColor, OffColor, CurrentColor, Name)
	ButtonId = tointeger(ButtonId)
	LogTrace("LightDevice:ReportLightButtonInfo %d %s %s %s %s", ButtonId, OnColor, OffColor, CurrentColor, Name)
	if (OnColor) then
		self._PersistData.buttonColors[ButtonId].onColor = OnColor
	end
	if (OffColor) then
		self._PersistData.buttonColors[ButtonId].offColor = OffColor
	end
	NOTIFY.BUTTON_INFO(ButtonId, OnColor, OffColor, CurrentColor, Name, self:GetBindingID())
	local idBinding = self:getBindingIdFromButtonId(ButtonId)
	if (C4:GetBoundConsumerDevices(0, idBinding) and (OnColor or OffColor)) then
		self:ReportLightButtonColorsAndMatch(ButtonId, idBinding)
	end
end


function LightDevice:ReportLightClickRateDown(Milliseconds)
	Milliseconds = tointeger(Milliseconds)
	LogTrace("LightDevice:ReportLightClickRateDown %d", Milliseconds)
	self._PersistData.clickRateDown = Milliseconds
	NOTIFY.CLICK_RATE_DOWN(Milliseconds, self:GetBindingID())
end


function LightDevice:ReportLightClickRateUp(Milliseconds)
	Milliseconds = tointeger(Milliseconds)
	LogTrace("LightDevice:ReportLightClickRateUp %d", Milliseconds)
	self._PersistData.clickRateUp = Milliseconds
	NOTIFY.CLICK_RATE_UP(Milliseconds, self:GetBindingID())
end


function LightDevice:ReportLightColdStartLevel(Level)
	Level = self:toLevel(Level)
	LogTrace("LightDevice:ReportLightColdStartLevel %d", Level)
	self._PersistData.coldStartLevel = Level
	NOTIFY.COLD_START_LEVEL(Level, self:GetBindingID())
end


function LightDevice:ReportLightColdStartTime(Milliseconds)
	Milliseconds = tointeger(Milliseconds)
	LogTrace("LightDevice:ReportLightColdStartTime %d", Milliseconds)
	self._PersistData.coldStartTime = Milliseconds
	NOTIFY.COLD_START_TIME(Milliseconds, self:GetBindingID())
end


function LightDevice:ReportLightHoldRateDown(Milliseconds)
	Milliseconds = tointeger(Milliseconds)
	LogTrace("LightDevice:ReportLightHoldRateDown %d", Milliseconds)
	self._PersistData.holdRateDown = Milliseconds
	NOTIFY.HOLD_RATE_DOWN(Milliseconds, self:GetBindingID())
end


function LightDevice:ReportLightHoldRateUp(Milliseconds)
	Milliseconds = tointeger(Milliseconds)
	LogTrace("LightDevice:ReportLightHoldRateUp %d", Milliseconds)
	self._PersistData.holdRateUp = Milliseconds
	NOTIFY.HOLD_RATE_UP(Milliseconds, self:GetBindingID())
end


function LightDevice:ReportLightLightLevel(Level)
	Level = self:toLevel(Level)
	LogTrace("LightDevice:ReportLightLightLevel %d", Level)
	NOTIFY.LIGHT_LEVEL(Level, self:GetBindingID())
	self:LightBrightnessChanged(Level)
end


function LightDevice:ReportLightBrightnessChanging(Target, Milliseconds, Current)
	LogTrace("LightDevice:ReportLightBrightnessChanging %d %s %s", Target, tostring(Milliseconds),
		tostring(Current))
	NOTIFY.LIGHT_BRIGHTNESS_CHANGING(Target, Milliseconds, Current, self:GetBindingID())
end


function LightDevice:ReportLightBrightnessChanged(Current)
	Current = self:toLevel(Current)
	LogTrace("LightDevice:ReportLightBrightnessChanged %d", Current)
	NOTIFY.LIGHT_BRIGHTNESS_CHANGED(Current, self:GetBindingID())
	self:LightBrightnessChanged(Current)
end

function LightDevice:LightBrightnessChanged(brightness)
	brightness = self:toLevel(brightness)
	self._PersistData.level = brightness
	local state = self:getLevelState()
	if (state ~= self.lastState) then
		self.lastState = state
		if state then
			-- If on, clear the Next On Color
			self.NextOnColor = nil
		else
			self.colorCommandReceived = false
		end
		for i = 0, self._PersistData.numberButtons-1 do
			local idBinding = self:getBindingIdFromButtonId(i)
			if (C4:GetBoundConsumerDevices(0, idBinding)) then
				NOTIFY.MATCH_LED_STATE(state, idBinding)
			end
		end
	end
end


function LightDevice:ReportLightMaxOnLevel(Level)
	Level = self:toLevel(Level)
	LogTrace("LightDevice:ReportLightMaxOnLevel %d", Level)
	self._PersistData.maxOnLevel = Level
	NOTIFY.MAX_ON_LEVEL(Level, self:GetBindingID())
end


function LightDevice:ReportLightMinOnLevel(Level)
	Level = self:toLevel(Level)
	LogTrace("LightDevice:ReportLightMinOnLevel %d", Level)
	self._PersistData.minOnLevel = Level
	NOTIFY.MIN_ON_LEVEL(Level, self:GetBindingID())
end


function LightDevice:ReportLightNumberButtons(Number)
	Number = tointeger(Number)
	LogTrace("LightDevice:ReportLightNumberButtons %d", Number)
	if (Number < self._PersistData.numberButtons) then
		for i = Number, self._PersistData.numberButtons-1 do
			self._PersistData.buttonColors[i] = nil
		end
	end
	if (Number > self._PersistData.numberButtons) then
		for i = self._PersistData.numberButtons, Number-1 do
			if (i%3 == 1) then
				self._PersistData.buttonColors[i] = { onColor = '0000ff', offColor = '000000' }
			else
				self._PersistData.buttonColors[i] = { onColor = '000000', offColor = '0000ff' }
			end
		end
	end
	if (Number ~= self._PersistData.numberButtons) then
		self._PersistData.numberButtons = Number
		NOTIFY.NUMBER_BUTTONS(Number, self:GetBindingID())
	end
end


function LightDevice:ReportLightOnlineChanged(Status)
	Status = toboolean(Status)
	LogTrace("LightDevice:ReportLightOnlineChanged %s", tostring(Status))
	self._PersistData.onlineStatus = Status
	NOTIFY.ONLINE_CHANGED(Status, self:GetBindingID())
end


function LightDevice:ReportLightPresetLevel(Level)
	Level = self:toLevel(Level)
	LogTrace("LightDevice:ReportLightPresetLevel %d", Level)
	self._PersistData.presetLevel = Level
	NOTIFY.PRESET_LEVEL(Level, self:GetBindingID())
end


function LightDevice:ReportLightButtonColorsAndMatch(buttonId, idBinding)
	LogTrace("LightDevice:ReportLightButtonColors %d %d", buttonId, idBinding)
	NOTIFY.BUTTON_COLORS(
		self._PersistData.buttonColors[buttonId].onColor,
		self._PersistData.buttonColors[buttonId].offColor,
		idBinding
	)
	NOTIFY.MATCH_LED_STATE(self:getLevelState(), idBinding)
end


function LightDevice:ReportDynamicCapabilitiesChanged(tCapabilities)
	LogTrace("LightDevice:ReportDynamicCapabilitiesChanged")

	if tCapabilities.color_correlated_temperature_min then
		self._PersistData.ct_min = tointeger(tCapabilities.color_correlated_temperature_min)
	end

	if tCapabilities.color_correlated_temperature_max then
		self._PersistData.ct_max = tointeger(tCapabilities.color_correlated_temperature_max)
	end

	if tCapabilities.supports_color ~= nil then
		self._PersistData.supportsColor = toboolean(tCapabilities.supports_color)
	end

	if tCapabilities.supports_color_correlated_temperature ~= nil then
		self._PersistData.supportsColorTemperature = toboolean(tCapabilities.supports_color_correlated_temperature)
	end

	if tCapabilities.supports_target ~= nil then
		self._PersistData.supportsTarget = toboolean(tCapabilities.supports_target)
	end

	if tCapabilities.dimmer ~= nil then
		self._PersistData.isDimmer = toboolean(tCapabilities.dimmer)
	end

	NOTIFY.DYNAMIC_CAPABILITIES_CHANGED(tCapabilities, self:GetBindingID())
end


--=============================================================================

function LightDevice:ReportLightColorChanging(xTarget, yTarget, targetColorMode, milliseconds,
		xCurrent, yCurrent, currentColorMode)
	LogTrace("LightDevice:ReportLightColorChanging Target Color: %s, Rate = %dms",
		self:ColorDebugString(xTarget, yTarget, targetColorMode), milliseconds)
	if xCurrent and yCurrent then
		LogTrace("LightDevice:ReportLightColorChanging, Current Color: %s",
		self:ColorDebugString(xCurrent, yCurrent, currentColorMode))
	end
	NOTIFY.LIGHT_COLOR_CHANGING(xTarget, yTarget, targetColorMode, milliseconds,
		xCurrent, yCurrent, currentColorMode, self:GetBindingID())
end


function LightDevice:ReportLightColorChanged(x, y, colorMode)
	LogTrace("LightDevice:ReportLightColorChanged %s", self:ColorDebugString(x, y, colorMode))

	self:SetLightColor(x, y, colorMode)

	NOTIFY.LIGHT_COLOR_CHANGED(x, y, colorMode, self:GetBindingID())
end

function LightDevice:SetLightColor(x, y, colorMode)
	self._PersistData.lightColor.x = x
	self._PersistData.lightColor.y = y
	self._PersistData.lightColor.mode = colorMode
end

function LightDevice:GetLightColor()
	local color = self._PersistData.lightColor
	if color.x and color.y and color.mode then
		LogTrace("LightDevice:GetLightColor %s", self:ColorDebugString(color.x, color.y, color.mode))
		return color.x, color.y, color.mode
	else
		LogTrace("LightDevice:GetLightColor: Color unknown")
		return nil, nil, nil
	end
end

function LightDevice:GetLightMode()
	return self._PersistData.lightColor.mode
end

function LightDevice:ColorDebugString(x, y, colorMode)
	local strMode
	if colorMode == LightDevice.COLOR_MODE_CCT then
		strMode = "CCT"
	elseif colorMode == LightDevice.COLOR_MODE_FULL_COLOR then
		strMode = "Full Color"
	else
		strMode = "Unknown"
	end
	return string.format("%s x = %f, y = %f", strMode, x, y)
end

function LightDevice:GetLightLevel()
	return self:getLevel()
end

function LightDevice:GetLightState()
	return self:getLevelState()
end

function LightDevice:GetPresetLevel()
	local brightnessOnMode = self._PersistData.brightnessOnMode
	if brightnessOnMode then
		return brightnessOnMode.presetLevel
	end
	return self._PersistData.presetLevel
end

function LightDevice:GetClickRateDown()
	return self._PersistData.clickRateDown
end

function LightDevice:GetClickRateUp()
	return self._PersistData.clickRateUp
end

function LightDevice:GetHoldRateDown()
	return self._PersistData.holdRateDown
end

function LightDevice:GetHoldRateUp()
	return self._PersistData.holdRateUp
end
--=============================================================================


function LightDevice:SetTypeDimmer(value)
	self._PersistData.isDimmer = toboolean(value)
	NOTIFY.DYNAMIC_CAPABILITIES_CHANGED({dimmer = toboolean(value)}, self:GetBindingID())
end


function LightDevice:SetAutoSwitch(value)
	self._PersistData.autoSwitch = toboolean(value)
end

function LightDevice:SetWarmDimming(value)
	self._PersistData.warmDimming = toboolean(value)
end

function LightDevice:SetWarmDimmingFunctionParameters(k,n)
	self._PersistData.warmDimmingFunctionN = n
	self._PersistData.warmDimmingFunctionK = k
end

function LightDevice:SetAutoButton(value)
	self._PersistData.autoButton = toboolean(value)
end


function LightDevice:SetAutoGroup(value)
	self._PersistData.autoGroup = toboolean(value)
end


function LightDevice:SetAutoGroupCommands(value)
	self._PersistData.autoGroupCommands = toboolean(value)
end


function LightDevice:SetAutoAls(value)
	self._PersistData.autoAls = toboolean(value)
end


function LightDevice:SetButtonDebounceMilliseconds(milliseconds)
	self._PersistData.buttonDebounceMilliseconds = tointeger(milliseconds)
end


function LightDevice:getButtonIdFromBindingId(idBinding)
	return idBinding-self._ButtonLinkBindingIdBase
end


function LightDevice:getBindingIdFromButtonId(buttonId)
	return self._ButtonLinkBindingIdBase+buttonId
end

function LightDevice:GetCapabilityValue(capability)
	local xml = C4:SendUIRequest(C4:GetProxyDevices(), 'GET_SETUP', {})

	local value = self:GetCapabilityDynamicFromElement(capability, xml)
	value = value or self:GetCapabilityDynamicFromAttribute(capability, xml)
	value = value or self:GetCapabilityStatic(capability)

	return value
end

function LightDevice:GetCapabilityStatic(capability)
	return C4:GetCapability(capability)
end

function LightDevice:GetCapabilityDynamicFromElement(capability, setupXml)
	setupXml = setupXml or C4:SendUIRequest(C4:GetProxyDevices(), 'GET_SETUP', {})
	return string.match(setupXml, '<' .. capability .. '>(.-)</' .. capability .. '>')
end

function LightDevice:GetCapabilityDynamicFromAttribute(capability, setupXml)
	setupXml = setupXml or C4:SendUIRequest(C4:GetProxyDevices(), 'GET_SETUP', {})
	return string.match(setupXml, capability .. '="(.-)"')
end

function LightDevice:getCCTRange()
	return self._PersistData.ct_min, self._PersistData.ct_max
end

---Check if specified color object has all necessary fields
---@param color table x,y,mode keys
---@return boolean True if all fileds exist
function LightDevice:IsColorValid(color)
	return color ~= nil and color.x ~= nil and color.y ~= nil and color.mode ~= nil
end

---Returns on and off colors (default colors or Color On Mode colors)
---@return table Off color
---@return table On Color
function LightDevice:GetDefaultColors()
	local colorOnMode = self._PersistData.colorOnMode
	if colorOnMode then
		local colorOnPreset, colorDimPreset = colorOnMode.onPreset, colorOnMode.dimPreset
		if colorOnPreset then
			if not self:IsColorValid(colorOnPreset) then colorOnPreset = nil end
			if not self:IsColorValid(colorDimPreset) then colorDimPreset = nil end
			-- In Previous color on mode, dim color can be nil. If both presets are nil, return
			-- default on and off colors
			if colorOnPreset or colorDimPreset then
				return colorDimPreset, colorOnPreset
			end
		end
	end

	local defaultOn, defaultOff = self._PersistData.DefaultOnColor, self._PersistData.DefaultOffColor
	if not self:IsColorValid(defaultOff) then defaultOff = nil end
	if not self:IsColorValid(defaultOn) then defaultOn = nil end
	return defaultOff, defaultOn
end

function LightDevice:buttonIdIsValid(buttonId)
	return buttonId >= 0 and buttonId < self._PersistData.numberButtons
end

function LightDevice:toLevel(number)
	number = tointeger(number)
	if (number < 0) then
		number = 0
	end
	if (number > 100) then
		number = 100
	end
	return number
end


function LightDevice:getLevelState()
	return self._PersistData.level ~= 0
end

function LightDevice:getLevel()
	return self._PersistData.level
end

function LightDevice:IsWarmDimmingEnabled()
	return self._PersistData.warmDimming
end

function LightDevice:ButtonStartRamp(buttonId)
	local rampTime = 0
	if (buttonId == self.BUTTON_ID_TOP) then
		rampTime = self._PersistData.holdRateUp * (100 - self:getLevel())/100
		self:PrxStartRampDimming(100, rampTime)
	elseif (buttonId == self.BUTTON_ID_BOTTOM) then
		rampTime = self._PersistData.holdRateDown * self:getLevel()/100
		self:PrxStartRampDimming(0, rampTime)
	elseif (buttonId == self.BUTTON_ID_TOGGLE) then
		if (self:getLevelState()) then
			self:ButtonStartRamp(self.BUTTON_ID_BOTTOM)
		else
			self:ButtonStartRamp(self.BUTTON_ID_TOP)
		end
	end
end


function LightDevice:ButtonStopRamp(buttonId)
	self:RampStop()
end


function LightDevice:ButtonDo(buttonId)
	if self._PersistData.isDimmer then
		if (buttonId == self.BUTTON_ID_TOP) then
			self:PrxRampToLevel(self:GetPresetLevel(), self._PersistData.clickRateUp)
		elseif (buttonId == self.BUTTON_ID_BOTTOM) then
			self:PrxRampToLevel(0, self._PersistData.clickRateDown)
		elseif (buttonId == self.BUTTON_ID_TOGGLE) then
			self:ButtonDo(self:GetLightState() and self.BUTTON_ID_BOTTOM or self.BUTTON_ID_TOP)
		end
	else
		if (buttonId == self.BUTTON_ID_TOP) then
			self:PrxOn()
		elseif (buttonId == self.BUTTON_ID_BOTTOM) then
			self:PrxOff()
		elseif (buttonId == self.BUTTON_ID_TOGGLE) then
			self:PrxToggle()
		end
	end
end


function LightDevice:RampStop()
	LightCom_RampStop()
end


function LightDevice:AlsStopAll()
	if (self._PersistData.autoAls) then
		for sceneId, _ in pairs(self.AlsTimers) do
			self.AlsTimers[sceneId]:Cancel()
			self.AlsTimers[sceneId] = nil
		end
	end
end


function LightDevice:AlsDo(sceneId)
	self.AlsTimers[sceneId] = nil
	while (true) do
		local action = math.floor(self._PersistData.Als[sceneId].state/2)+1
		if (action > #self._PersistData.Als[sceneId].elements) then
			if (self._PersistData.Als[sceneId].flash) then
				self._PersistData.Als[sceneId].state = 0
			else
				return
			end
		else
			local currentAction = self._PersistData.Als[sceneId].elements[action]
			local sleep = currentAction.delay
			if (self._PersistData.Als[sceneId].state%2 == 1) then
				local brightnessRate = currentAction.levelRate or 0
				local colorRate = currentAction.colorRate or 0
				if (currentAction.levelEnabled == true and currentAction.colorEnabled == true) then -- Brightness and Color
					LightCom_RampToColorAndBrightnessTarget(currentAction.level, currentAction.colorX, currentAction.colorY, currentAction.colorMode, brightnessRate, colorRate, true)
					sleep = brightnessRate
					if (sleep < colorRate) then
						sleep = colorRate
					end

				elseif (currentAction.levelEnabled == true) then -- Brightness Only
					local skipColor = self:ShouldSkipColor(currentAction.level)
					if (brightnessRate > 0) then
						self:PrxRampToLevel(currentAction.level, brightnessRate, true, false, skipColor)
					else
						self:PrxSetLevel(currentAction.level, true, false, skipColor)
					end
					sleep = brightnessRate

				elseif (currentAction.colorEnabled == true) then -- Color Only
					self:PrxSetColorTarget(currentAction.colorX, currentAction.colorY, currentAction.colorMode, colorRate)
					sleep = colorRate
				else -- for switch light
					self:PrxSetLevel(currentAction.level, true, false, skipColor)
				end
			end
			self._PersistData.Als[sceneId].state = self._PersistData.Als[sceneId].state+1

			if (sleep > 0) then
				self.AlsTimers[sceneId] = C4:SetTimer(
					sleep,
					function(oTimer)
						self:AlsDo(sceneId)
					end
				)
				return
			end
		end
	end
end

function LightDevice:AlsXmlToTable(elements)
	local result = {}
	local xml = C4:ParseXml('<d>' .. elements .. '</d>')
	for _, elementXml in ipairs(xml.ChildNodes) do
		if (elementXml.Name == 'element') then
			local delay
			local rate = 0
			local colorRate = 0
			local colorX, colorY
			local colorMode
			local level
			local levelEnabled = false
			local colorEnabled = false
			local brightnessPresetID = 0
			local colorPresetID = 0
			local colorPresetOrigin = 0
			for _, dataXml in ipairs(elementXml.ChildNodes) do
				if (dataXml.Name == 'delay') then
					delay = tointeger(dataXml.Value)
				elseif (dataXml.Name == 'rate'or dataXml.Name == 'brightnessRate') then
					rate = tointeger(dataXml.Value)
				elseif (dataXml.Name == 'level' or dataXml.Name == 'brightness') then
					level = tointeger(dataXml.Value)
				elseif (dataXml.Name == 'brightnessEnabled') then
					levelEnabled = toboolean(dataXml.Value)
				elseif (dataXml.Name == 'colorEnabled') then
					colorEnabled = toboolean(dataXml.Value)
				elseif (dataXml.Name == 'colorRate') then
					colorRate = tointeger(dataXml.Value)
				elseif (dataXml.Name == 'colorX') then
					colorX = tonumber_loc(dataXml.Value)
				elseif (dataXml.Name == 'colorY') then
					colorY = tonumber_loc(dataXml.Value)
				elseif (dataXml.Name == 'colorMode') then
					colorMode = tointeger(dataXml.Value)
				elseif(dataXml.Name == "brightnessPresetID") then
					brightnessPresetID = tointeger(dataXml.Value)
				elseif(dataXml.Name == "colorPresetID") then
					colorPresetID = tointeger(dataXml.Value)
				elseif(dataXml.Name == "colorPresetOrigin") then
					colorPresetOrigin = tointeger(dataXml.Value)
				end
			end
			if delay then
				table.insert(result, {delay = delay, rate = rate, level = level, colorMode = colorMode,
							levelEnabled = levelEnabled, levelRate = rate, levelDelay = delay,
							colorEnabled = colorEnabled, colorRate = colorRate, colorX = colorX, colorY = colorY,
							brightnessPresetID = brightnessPresetID, colorPresetID = colorPresetID,
							colorPresetOrigin = colorPresetOrigin})
			end
		end
	end
	return result
end


function LightDevice:CalcGroupsHaveSync()
	self._PersistData.groupsHaveSync = false
	for groupId, keepSync in pairs(self._PersistData.Groups) do
		if (keepSync) then
			self._PersistData.groupsHaveSync = true
			return
		end
	end
end

---Check if provided preset matches specified preset id and origin
---@param preset table
---@param id number
---@param origin number
---@return boolean
function LightDevice:PresetEquals(preset, id, origin)
	return preset.id == id and preset.origin == origin
end

function LightDevice:PrxUpdateColorPreset(command, id, name, x, y, mode)
	LogTrace("LightDevice:PrxUpdateColorPreset id = %d, %s", id, self:ColorDebugString(x, y, mode))
	-- Template only cares if On and Off presets (id 1 and 2), or colorOn/Fade presets are modified
	if (command == "MODIFIED") or (command == "ADDED") then
		local color = {x = x, y = y, mode = mode}
		if (id == LightDevice.DEFAULT_ON_COLOR_PRESET_ID) then
			self._PersistData.DefaultOnColor = color
		elseif (id == LightDevice.DEFAULT_OFF_COLOR_PRESET_ID) then
			self._PersistData.DefaultOffColor = color
		end

		-- Now check if this preset is also used as colorOnMode preset
		local colorOnMode = self._PersistData.colorOnMode
		if colorOnMode then
			local colorPreset
			if self:PresetEquals(colorOnMode.onPreset, id, LightDevice.COLOR_PRESET_ORIGIN_DEVICE) then
				colorPreset = colorOnMode.onPreset
			elseif colorOnMode.dimPreset and
				self:PresetEquals(colorOnMode.dimPreset, id, LightDevice.COLOR_PRESET_ORIGIN_DEVICE) then
				colorPreset = colorOnMode.dimPreset
			end

			if colorPreset then
				colorPreset.x = x
				colorPreset.y = y
				colorPreset.mode = mode
			end
		end
	end

	-- If driver does not support driver specific presets, it should not care about this command
	if LightCom_UpdateColorPreset then
		LightCom_UpdateColorPreset(command, id, name, x, y, mode)
	end
end

function LightDevice:PrxUpdateColorOnMode(onPreset, dimPreset)
	LogTrace("Color On Preset")
	LogTrace(onPreset)
	LogTrace("Color Dim (Fade) Preset")
	LogTrace(dimPreset)
	if dimPreset.origin == LightDevice.COLOR_PRESET_ORIGIN_INVALID then dimPreset = nil end
	self._PersistData.colorOnMode = {onPreset = onPreset, dimPreset = dimPreset }
end

function LightDevice:PrxUpdateBrightnessOnMode(presetId, presetLevel)
	LogTrace("PrxUpdateBrightnessOnMode: preset %d,level %d", presetId, presetLevel)
	-- Use a dedicated field in PersistData - presetLevel cannot be used because the proxy will send
	-- SET_PRESET_LEVEL command anyway
	self._PersistData.brightnessOnMode = {presetId = presetId, presetLevel = presetLevel}
end

function LightDevice:UpdateBrightnessPreset(command, presetId, presetLevel)
	local brightnessOnMode = self._PersistData.brightnessOnMode
	for sceneId, scene in pairs(self._PersistData.Als) do
		for actionId, action in pairs(scene.elements) do
			if(action.brightnessPresetID == presetId) then
				action.level = presetLevel
			end
		end
	end
	if not (brightnessOnMode and brightnessOnMode.presetId == presetId) then return end
	if command == "MODIFIED" then
		brightnessOnMode.presetLevel = presetLevel
	elseif command == "DELETED" then
		self._PersistData.brightnessOnMode = nil
	end
 end

function LightDevice:CalculatePiecewiseLinearWarmDimming(warmDimmingCCTRange)
	LogTrace("LightDevice:CalculatePiecewiseLinearWarmDimming()")

	self:SetWarmDimmingFunctionParameters(nil, nil)

	if not self:SupportsCCT() or not warmDimmingCCTRange then return end

	local cctMin, cctMax = warmDimmingCCTRange.min, warmDimmingCCTRange.max

	if(not cctMin) then
		LogTrace("LightDevice:CalculatePiecewiseLinearWarmDimming cctMin is not set. It must be set for Warm Dimming.")
		return
	end

	if(not cctMax) then
		LogTrace("LightDevice:CalculatePiecewiseLinearWarmDimming cctMax is not set. It must be set for Warm Dimming.")
		return
	end

	local k = (cctMax - cctMin)/99
	local n = cctMin - 1*k
	LogTrace("LightDevice:CalculatePiecewiseLinearWarmDimming k = %f, n = %f", k, n)
	LogTrace("LightDevice:CalculatePiecewiseLinearWarmDimming Parameters are set.")
	self:SetWarmDimmingFunctionParameters(k, n)
end

function LightDevice:IsWarmDimmingActive()
	return self:SupportsCCT() and
		self._PersistData.warmDimming and
		(self._PersistData.warmDimmingFunctionK ~= nil) and (self._PersistData.warmDimmingFunctionN ~= nil) and
		(self:GetLightMode() == LightDevice.COLOR_MODE_CCT) and
		not self.colorCommandReceived
end

--- Calculates target color for warm dimming brightness change
---@param brightnessTarget number Brightness to go to
---
---@return Tree values: x, y, colorMode
function LightDevice:CalculateWarmDimmingTargetColor(brightnessTarget)
	local minCt, maxCt = self:getCCTRange()
	local warmDimmingFunctionN = self._PersistData.warmDimmingFunctionN
	local warmDimmingFunctionK = self._PersistData.warmDimmingFunctionK
	local warmDimmingCt = tointeger(brightnessTarget * warmDimmingFunctionK + warmDimmingFunctionN)
	if(warmDimmingCt > maxCt) then
		warmDimmingCt = maxCt
	elseif(warmDimmingCt < minCt) then
		warmDimmingCt = minCt
	end

	local x, y = C4:ColorCCTtoXY(warmDimmingCt)
	return x, y, LightDevice.COLOR_MODE_CCT
end

function LightDevice:SupportsColor()
	return self._PersistData.supportsColor or self:SupportsCCT()
end

function LightDevice:SupportsCCT()
	return self._PersistData.supportsColorTemperature
end

function LightDevice:SupportsTarget()
	return self._PersistData.supportsTarget
end

function LightDevice:IsLightTurningOn(targetBrightness)
	local targetState = targetBrightness > 0
	local currentState = self:GetLightState()
	if (targetState ~= currentState and currentState == LightDevice.LIGHT_OFF and targetState == LightDevice.LIGHT_ON) then
		return true
	end
	return false
end

function LightDevice:IsLightTurningOff(targetBrightness)
	local targetState = targetBrightness > 0
	local currentState = self:GetLightState()
	if (targetState ~= currentState and currentState == LightDevice.LIGHT_ON and targetState == LightDevice.LIGHT_OFF) then
		return true
	end
	return false
end

function LightDevice:ShouldSkipColor(brightness)
	brightness = brightness or 0
	return not self:IsWarmDimmingActive() and self:IsLightTurningOff(brightness)
end

function LightDevice:GetLightOnlineStatus()
	return self._PersistData.onlineStatus
end