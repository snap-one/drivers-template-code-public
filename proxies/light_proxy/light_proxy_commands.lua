--[[=============================================================================
    Command Functions Received From Light Proxy to the Driver

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_proxy_commands = "2023.05.01"
end


---------------------------------------------------------------


function PRX_CMD.BUTTON_ACTION(idBinding, tParams)
	local buttonId = tointeger(tParams.BUTTON_ID)
	local action = tointeger(tParams.ACTION)
	LogTrace("PRX_CMD.BUTTON_ACTION %d %d", buttonId, action)
	if (TheLight and TheLight:GetBindingID() == idBinding) then
		TheLight:PrxButtonAction(buttonId, action)
	end
end


function PRX_CMD.GET_CONNECTED_STATE(idBinding, tParams)
	LogTrace("PRX_CMD.GET_CONNECTED_STATE")
	if (TheLight) then
		TheLight:PrxGetConnectedState()
	end
end


function PRX_CMD.GET_LIGHT_LEVEL(idBinding, tParams)
	LogTrace("PRX_CMD.GET_LIGHT_LEVEL")
	if (TheLight) then
		TheLight:PrxGetLightLevel()
	end
end


function PRX_CMD.OFF(idBinding, tParams)
	LogTrace("PRX_CMD.OFF")
	if (TheLight) then
		TheLight:PrxOff()
	end
end


function PRX_CMD.ON(idBinding, tParams)
	LogTrace("PRX_CMD.ON")
	if (TheLight) then
		TheLight:PrxOn()
	end
end


function PRX_CMD.RAMP_TO_LEVEL(idBinding, tParams)
	local level = tointeger(tParams.LEVEL)
	local milliseconds = tointeger(tParams.TIME)
	LogTrace("PRX_CMD.RAMP_TO_LEVEL %d %d", level, milliseconds)
	if (TheLight) then
		TheLight:PrxRampToLevel(level, milliseconds)
	end
end


function PRX_CMD.SET_BRIGHTNESS_TARGET(idBinding, tParams)
	local brightnessTarget = tointeger(tParams.LIGHT_BRIGHTNESS_TARGET)
	local milliseconds = tointeger(tParams.RATE or 0)

	LogTrace("PRX_CMD.SET_BRIGHTNESS_TARGET %d %d", brightnessTarget, milliseconds)
	if (TheLight) then
		TheLight:PrxSetBrightnessTarget(brightnessTarget, milliseconds)
	end
end


function PRX_CMD.SET_ALL_LED(idBinding, tParams)
	local color = tParams.COLOR
	LogTrace("PRX_CMD.SET_ALL_LED %s", color)
	if (TheLight) then
		TheLight:PrxSetAllLed(color)
	end
end


function PRX_CMD.SET_BUTTON_COLOR(idBinding, tParams)
	local buttonId = tointeger(tParams.BUTTON_ID)
	local onColor = tParams.ON_COLOR
	local offColor = tParams.OFF_COLOR
	local currentColor = tParams.CURRENT_COLOR
	LogTrace("PRX_CMD.SET_BUTTON_COLOR %d %d %s %s %s", idBinding, buttonId, onColor, offColor, currentColor)
	if (TheLight) then
		TheLight:PrxSetButtonColor(idBinding, buttonId, onColor, offColor, currentColor)
	end
end


function PRX_CMD.SET_CLICK_RATE_UP(idBinding, tParams)
	local rate = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.SET_CLICK_RATE_UP %d", rate)
	if (TheLight) then
		TheLight:PrxSetClickRateUp(rate)
	end
end


function PRX_CMD.SET_CLICK_RATE_DOWN(idBinding, tParams)
	local rate = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.SET_CLICK_RATE_DOWN %d", rate)
	if (TheLight) then
		TheLight:PrxSetClickRateDown(rate)
	end
end


function PRX_CMD.SET_COLD_START_LEVEL(idBinding, tParams)
	local level = tointeger(tParams.LEVEL)
	LogTrace("PRX_CMD.SET_COLD_START_LEVEL %d", level)
	if (TheLight) then
		TheLight:PrxSetColdStartLevel(level)
	end
end


function PRX_CMD.SET_COLD_START_TIME(idBinding, tParams)
	local time = tointeger(tParams.TIME)
	LogTrace("PRX_CMD.SET_COLD_START_TIME %d", time)
	if (TheLight) then
		TheLight:PrxSetColdStartTime(time)
	end
end


function PRX_CMD.SET_HOLD_RATE_DOWN(idBinding, tParams)
	local rate = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.SET_HOLD_RATE_DOWN %d", rate)
	if (TheLight) then
		TheLight:PrxSetHoldRateDown(rate)
	end
end


function PRX_CMD.SET_HOLD_RATE_UP(idBinding, tParams)
	local rate = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.SET_HOLD_RATE_UP %d", rate)
	if (TheLight) then
		TheLight:PrxSetHoldRateUp(rate)
	end
end


function PRX_CMD.SET_LEVEL(idBinding, tParams)
	local level = tointeger(tParams.LEVEL)
	LogTrace("PRX_CMD.SET_LEVEL %d", level)
	if (TheLight) then
		TheLight:PrxSetLevel(level)
	end
end


function PRX_CMD.SET_MAX_ON_LEVEL(idBinding, tParams)
	local level = tointeger(tParams.LEVEL)
	LogTrace("PRX_CMD.SET_MAX_ON_LEVEL %d", level)
	if (TheLight) then
		TheLight:PrxSetMaxOnLevel(level)
	end
end


function PRX_CMD.SET_MIN_ON_LEVEL(idBinding, tParams)
	local level = tointeger(tParams.LEVEL)
	LogTrace("PRX_CMD.SET_MIN_ON_LEVEL %d", level)
	if (TheLight) then
		TheLight:PrxSetMinOnLevel(level)
	end
end


function PRX_CMD.SET_PRESET_LEVEL(idBinding, tParams)
	local level = tointeger(tParams.LEVEL)
	LogTrace("PRX_CMD.SET_PRESET_LEVEL %d", level)
	if (TheLight) then
		TheLight:PrxSetPresetLevel(level)
	end
end


function PRX_CMD.TOGGLE(idBinding, tParams)
	LogTrace("PRX_CMD.TOGGLE")
	if (TheLight) then
		TheLight:PrxToggle()
	end
end


function PRX_CMD.DO_PUSH(idBinding, tParams)
	LogTrace("PRX_CMD.DO_PUSH %d", idBinding)
	if (TheLight) then
		TheLight:PrxDoPush(idBinding)
	end
end


function PRX_CMD.DO_CLICK(idBinding, tParams)
	LogTrace("PRX_CMD.DO_CLICK %d", idBinding)
	if (TheLight) then
		TheLight:PrxDoClick(idBinding)
	end
end


function PRX_CMD.DO_RELEASE(idBinding, tParams)
	LogTrace("PRX_CMD.DO_RELEASE %d", idBinding)
	if (TheLight) then
		TheLight:PrxDoRelease(idBinding)
	end
end


function PRX_CMD.REQUEST_BUTTON_COLORS(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_BUTTON_COLORS %d", idBinding)
	if (TheLight) then
		TheLight:PrxRequestButtonColors(idBinding)
	end
end


function PRX_CMD.ACTIVATE_SCENE(idBinding, tParams)
	local sceneId = tointeger(tParams.SCENE_ID)
	LogTrace("PRX_CMD.ACTIVATE_SCENE %d", sceneId)
	if (TheLight) then
		TheLight:PrxActivateScene(sceneId)
	end
end


function PRX_CMD.ALL_SCENES_PUSHED(idBinding, tParams)
	LogTrace("PRX_CMD.ALL_SCENES_PUSHED")
	if (TheLight) then
		TheLight:PrxAllScenesPushed()
	end
end


function PRX_CMD.CLEAR_ALL_SCENES(idBinding, tParams)
	LogTrace("PRX_CMD.CLEAR_ALL_SCENES")
	if (TheLight) then
		TheLight:PrxClearAllScenes()
	end
end


function PRX_CMD.PUSH_SCENE(idBinding, tParams)
	local sceneId = tointeger(tParams.SCENE_ID)
	local elements = tParams.ELEMENTS
	local flash = toboolean(tParams.FLASH)
	local ignoreRamp = toboolean(tParams.IGNORE_RAMP)
	local fromGroup = toboolean(tParams.FROM_GROUP)
	LogTrace("PRX_CMD.PUSH_SCENE %d \"%s\" %s %s %s", sceneId, elements, tostring(flash), tostring(ignoreRamp), tostring(fromGroup))
	if (TheLight) then
		TheLight:PrxPushScene(sceneId, elements, flash, ignoreRamp, fromGroup)
	end
end


function PRX_CMD.RAMP_SCENE_DOWN(idBinding, tParams)
	local sceneId = tointeger(tParams.SCENE_ID)
	local rate = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.RAMP_SCENE_DOWN %d %d", sceneId, rate)
	if (TheLight) then
		TheLight:PrxRampSceneDown(sceneId, rate)
	end
end


function PRX_CMD.RAMP_SCENE_UP(idBinding, tParams)
	local sceneId = tointeger(tParams.SCENE_ID)
	local rate = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.RAMP_SCENE_UP %d %d", sceneId, rate)
	if (TheLight) then
		TheLight:PrxRampSceneUp(sceneId, rate)
	end
end


function PRX_CMD.REMOVE_SCENE(idBinding, tParams)
	local sceneId = tointeger(tParams.SCENE_ID)
	LogTrace("PRX_CMD.REMOVE_SCENE %d", sceneId)
	if (TheLight) then
		TheLight:PrxRemoveScene(sceneId)
	end
end


function PRX_CMD.STOP_SCENE_RAMP(idBinding, tParams)
	local sceneId = tointeger(tParams.SCENE_ID)
	LogTrace("PRX_CMD.STOP_SCENE_RAMP %d", sceneId)
	if (TheLight) then
		TheLight:PrxStopSceneRamp(sceneId)
	end
end


function PRX_CMD.GROUP_RAMP_TO_LEVEL(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	local level = tointeger(tParams.LEVEL)
	local milliseconds = tointeger(tParams.TIME)
	LogTrace("PRX_CMD.GROUP_RAMP_TO_LEVEL %d %d %d", groupId, level, milliseconds)
	if (TheLight) then
		TheLight:PrxGroupRampToLevel(groupId, level, milliseconds)
	end
end


function PRX_CMD.GROUP_SET_LEVEL(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	local level = tointeger(tParams.LEVEL)
	LogTrace("PRX_CMD.GROUP_SET_LEVEL %d %d", groupId, level)
	if (TheLight) then
		TheLight:PrxGroupSetLevel(groupId, level)
	end
end


function PRX_CMD.GROUP_START_RAMP(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	local rampUp = toboolean(tParams.RAMP_UP)
	local milliseconds = tointeger(tParams.RATE)
	LogTrace("PRX_CMD.GROUP_START_RAMP %d %s %d", groupId, tostring(rampUp), milliseconds)
	if (TheLight) then
		TheLight:PrxGroupStartRamp(groupId, rampUp, milliseconds)
	end
end


function PRX_CMD.GROUP_STOP_RAMP(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	LogTrace("PRX_CMD.GROUP_STOP_RAMP %d", groupId)
	if (TheLight) then
		TheLight:PrxGroupStopRamp(groupId)
	end
end


function PRX_CMD.JOIN_GROUP(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	local keepSync = toboolean(tParams.KEEP_SYNC)
	LogTrace("PRX_CMD.JOIN_GROUP %d %s", groupId, tostring(keepSync))
	if (TheLight) then
		TheLight:PrxJoinGroup(groupId, keepSync)
	end
end


function PRX_CMD.LEAVE_GROUP(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	LogTrace("PRX_CMD.LEAVE_GROUP %d", groupId)
	if (TheLight) then
		TheLight:PrxLeaveGroup(groupId)
	end
end


function PRX_CMD.SET_GROUP_SYNC(idBinding, tParams)
	local groupId = tointeger(tParams.GROUP_ID)
	local keepSync = toboolean(tParams.KEEP_SYNC)
	LogTrace("PRX_CMD.SET_GROUP_SYNC %d %s", groupId, keepSync)
	if (TheLight) then
		TheLight:PrxSetGroupSync(groupId, keepSync)
	end
end


function PRX_CMD.SET_COLOR_TARGET(idBinding, tParams)
	local x = tonumber_loc(tParams.LIGHT_COLOR_TARGET_X)
	local y = tonumber_loc(tParams.LIGHT_COLOR_TARGET_Y)
	local colorMode = tointeger(tParams.LIGHT_COLOR_TARGET_MODE)
	-- On OS >= 3.3.2, RATE parameter is deprecated and LIGHT_COLOR_TARGET_RATE should be used instead
	local rate = tointeger(tParams.LIGHT_COLOR_TARGET_RATE or tParams.RATE or 0)

	LogTrace("PRX_CMD.SET_COLOR_TARGET x = %f, y = %f, Mode = %d, Rate = %dms", x, y, colorMode, rate)

	if (TheLight) then
		TheLight:PrxSetColorTarget(x, y, colorMode, rate)
	end
end

function PRX_CMD.UPDATE_COLOR_PRESET(idBinding, tParams)
	local command = tParams.COMMAND
	local id = tonumber(tParams.ID)
	local name = tParams.NAME
	local x, y = tonumber_loc(tParams.COLOR_X), tonumber_loc(tParams.COLOR_Y)
	local mode = tonumber(tParams.COLOR_MODE)
	LogTrace("PRX_CMD.UPDATE_COLOR_PRESET command = %s, name = %s, id = %d", command, name, id)
	if (TheLight) then
		TheLight:PrxUpdateColorPreset(command, id, name, x, y, mode)
	end
end

function PRX_CMD.UPDATE_COLOR_ON_MODE(idBinding, tParams)
	local onPreset = {
		id = tonumber(tParams.COLOR_PRESET_ID),
		origin = tonumber(tParams.COLOR_PRESET_ORIGIN),
		x = tonumber_loc(tParams.COLOR_PRESET_COLOR_X),
		y = tonumber_loc(tParams.COLOR_PRESET_COLOR_Y),
		mode = tonumber_loc(tParams.COLOR_PRESET_COLOR_MODE)
	}
	local dimPreset = {
		id = tonumber(tParams.COLOR_FADE_PRESET_ID),
		origin = tonumber(tParams.COLOR_FADE_PRESET_ORIGIN),
		x = tonumber_loc(tParams.COLOR_FADE_PRESET_COLOR_X),
		y = tonumber_loc(tParams.COLOR_FADE_PRESET_COLOR_Y),
		mode = tonumber_loc(tParams.COLOR_FADE_PRESET_COLOR_MODE)
	}
	TheLight:PrxUpdateColorOnMode(onPreset, dimPreset)
end

function PRX_CMD.UPDATE_BRIGHTNESS_ON_MODE(idBinding, tParams)
	TheLight:PrxUpdateBrightnessOnMode(tonumber(tParams.BRIGHTNESS_PRESET_ID),
		tonumber(tParams.BRIGHTNESS_PRESET_LEVEL))
end

function PRX_CMD.UPDATE_BRIGHTNESS_PRESET(idBinding, tParams)
	local command = tParams.COMMAND
	local presetId = tonumber(tParams.ID)
	local presetLevel = tonumber(tParams.LEVEL)
	TheLight:UpdateBrightnessPreset(command, presetId, presetLevel)
end

---------------------------------------------------------------


