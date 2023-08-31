---
---File is: light_communicator.lua
---
---Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
---

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_communicator = "2021.12.01"
end

---Use cases examples:
---
--- - When the button has been clicked -> PRESS and CLICK will be received
--- - When the button has been pressed, hold and released -> PRESS and RELEASE will be received
--- - When the button has been clicked 2 times in a row -> PRESS, CLICK, PRESS, CLICK, DOUBLE_CLICK will be received

---@alias presetLevelCommand_t "MODIFIED"|"ADDED"|"DELETED"
---There are 3 different ways to change a preset, this type describes what happened with the preset.

--[[=============================================================================
-------------------------------ILLUMINATION HOOKS ------------------------------
===============================================================================]]


---Used to set the target brightness of where the light is being requested to go.
---
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
---
---@param brightnessTarget integer Target brightness value of the dimming process
---@param milliseconds integer Duration of the light dimming process in milliseconds
function LightCom_SetBrightnessTarget(brightnessTarget, milliseconds)
	LogTrace("LightCom_SetBrightnessTarget %d %d", brightnessTarget, milliseconds)
end


---Used to start dimming (ramping up/down, relative dimming), initiated by button press/release,
---group or scene ramp up/down.
---
---For lights that do not support color, color parameters (x, y and colorMode) will be nil
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
---If the function has been successfully executed, the driver must call
---the LightReport_LightColorChanged report. The report LightReport_LightColorChanging should be
---called in transition time.
---
---@param milliseconds integer Duration of the light dimming process in milliseconds
---@param brightnessTarget integer Target brightness value of the light brightness
---@param x number X color component
---@param y number Y color component
---@param colorMode colorMode_t Color Target Color Mode
function LightCom_StartRampDimming(milliseconds, brightnessTarget, x, y, colorMode)
	LogTrace("LightCom_StartRampDimming Brightness %d %d", milliseconds, brightnessTarget)
	if x and y and colorMode then
		LogTrace("LightCom_StartRampDimming Color %f, %f %d", x, y, colorMode)
	end
end


---Used to set the color and brightness target of where the light is being requested to go through scene.
---
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
---If the function has been successfully executed, the driver must call
---the LightReport_LightColorChanged report. The report LightReport_LightColorChanging should be
---called in transition time.
---
---@param brightnessTarget integer Target brightness value of the dimming process
---@param x number X color component
---@param y number Y color component
---@param colorMode colorMode_t Color Target Color Mode
---@param millisecondsBrightness integer Duration of the light dimming process in milliseconds
---@param millisecondsColor integer Duration of the light color changing process in milliseconds
function LightCom_RampToColorAndBrightnessTarget(brightnessTarget, x, y, colorMode, millisecondsBrightness, millisecondsColor)
	LogTrace("LightCom_RampToColorAndBrightnessTarget %d %f %f %d %d %d", brightnessTarget, x, y, colorMode, millisecondsBrightness, millisecondsColor)
end


---Used to stop ongoing ramping process.
---
---This hook will be called only if the *AutoRamp* is set to false.
---Use the LightReport_LightBrightnessChanged report after the function is successfully executed.
function LightCom_RampStop()
	LogTrace("LightCom_RampStop")
end


---Used to set the color of the color-enabled light.
---
---Target color's chromaticity is specified in CIE 1931 (XYZ) color space.
---Will be called only if supports_color lightv2 proxy capability is true.
---If the function has been successfully executed, the driver must call
---the LightReport_LightColorChanged report. The report LightReport_LightColorChanging should be
---called in transition time.
---
---@param x number X color component
---@param y number Y color component
---@param colorMode colorMode_t Color Target Color Mode
---@param milliseconds integer Duration of the light color changing process in milliseconds
function LightCom_SetColorTarget(x, y, colorMode, milliseconds)
	LogTrace("LightCom_SetColorTarget x = %f, y = %f, Mode = %d, Rate = %dms", x, y, colorMode, milliseconds)
end


---Used to hande BUTTON_ACTION proxy commands.
---
---This hook will be called only if the *AutoRamp* is set to false.
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
---
---@param buttonId buttonId_t Id of the triggered button
---@param action buttonAction_t
function LightCom_ButtonAction(buttonId, action)
	LogTrace("LightCom_ButtonAction %d %d", buttonId, action)
end


---Used to turn ON the light.
---
---This hook will be called when the *AutoSwitch* is set to false and the *ON* proxy command has been
---received. ON proxy command will be triggered by the Custom Programming Light Command *On*.
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
function LightCom_On()
	LogTrace("LightCom_On")
end


---Used to turn OFF the light.
---
---This hook will be called when the *AutoSwitch* is set to false and the *OFF* proxy command has been
---received. ON proxy command will be triggered by the Custom Programming Light Command *Off*.
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
function LightCom_Off()
	LogTrace("LightCom_Off")
end

---Used to TOGGLE the light.
---
---This hook will be called when the *AutoSwitch* is set to false and the *TOGGLE* proxy command has been
---received. ON proxy command will be triggered by the Custom Programming Light Command *Toggle*.
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report. The report LightReport_LightBrightnessChanging should be
---called if the driver supports *supports_target* capability.
function LightCom_Toggle()
	LogTrace("LightCom_Toggle")
end


--[[=============================================================================
------------------------ADVANCED LIGHTING SCENE HOOKS --------------------------
===============================================================================]]


---Call when user Activate Scene
---
---Will called only if *AutoAls* is false.
---
---@param sceneId integer Id of the scene
function LightCom_ActivateScene(sceneId)
	LogTrace("LightCom_ActivateScene %d", sceneId)
end


---Call when system All Scenes are Pushed
---
---Will called only if *AutoAls* is false
function LightCom_AllScenesPushed()
	LogTrace("LightCom_AllScenesPushed")
end


---Call when system Clear All Scenes
---
---Will called only if *AutoAls* is false
function LightCom_ClearAllScenes()
	LogTrace("LightCom_ClearAllScenes")
end


---Call when dealer Push Scene
---
---Will called only if *AutoAls* is false.
---
---@param sceneId integer Id of the scene
---@param elements string Scene data XML
---@param flash boolean
---@param ignoreRamp boolean
---@param fromGroup boolean
function LightCom_PushScene(sceneId, elements, flash, ignoreRamp, fromGroup)
	LogTrace("LightCom_PushScene %d \"%s\" %s %s %s", sceneId, elements, tostring(flash), tostring(ignoreRamp), tostring(fromGroup))
end


---Call when user Ramp Scene Down
---
---Will called only if *AutoAls* is false.
---
---@param sceneId integer Id of the scene
---@param milliseconds integer Duration of the scene ramping process in milliseconds
function LightCom_RampSceneDown(sceneId, milliseconds)
	LogTrace("LightCom_RampSceneDown %d %d", sceneId, milliseconds)
end


---Call when user Ramp Scene Down
---
---Will called only if *AutoAls* is false.
---
---@param sceneId integer Id of the scene
---@param milliseconds integer Duration of the scene ramping process in milliseconds
function LightCom_RampSceneUp(sceneId, milliseconds)
	LogTrace("LightCom_RampSceneUp %d %d", sceneId, milliseconds)
end


---Call when dealer Remove Scene
---
---Will called only if *AutoAls* is false.
---
---@param sceneId integer Id of the scene
function LightCom_RemoveScene(sceneId)
	LogTrace("LightCom_RemoveScene %d", sceneId)
end


---Call when user Stop Ramp Scene
---@param sceneId integer Id of the scene
--
---Will called only if *AutoAls* is false.
function LightCom_StopRampScene(sceneId)
	LogTrace("LightCom_StopRampScene %d", sceneId)
end


--[[=============================================================================
------------------------------LOAD GROUP HOOKS ---------------------------------
===============================================================================]]


---Call when user Group Ramp to Level
---
---Will called only if *AutoGroup* is false.
---
---@param groupId integer Id of the group
---@param level integer Target light level
---@param milliseconds integer Duration of the ramping process in milliseconds
function LightCom_GroupRampToLevel(groupId, level, milliseconds)
	LogTrace("LightCom_GroupRampToLevel %d %d %d", groupId, level, milliseconds)
end


---Call when user Group Set Level
---
---Will called only if AutoGroup is false
---If the function has been successfully executed, the driver must call
---the LightReport_LightBrightnessChanged report.
---
---@param groupId integer Id of the group
---@param level integer Target brightness level
function LightCom_GroupSetLevel(groupId, level)
	LogTrace("LightCom_GroupSetLevel %d %d", groupId, level)
end


---Call when user Group Start Ramp
---
---Will called only if *AutoGroup* is false.
---Must call LightReport_LightBrightnessChanged with new level.
---
---@param groupId integer Id of the group
---@param rampUp boolean Indicates ramping up or down
---@param milliseconds integer Duration of the ramping process in milliseconds
function LightCom_GroupStartRamp(groupId, rampUp, milliseconds)
	LogTrace("LightCom_GroupStartRamp %d %s %d", groupId, tostring(rampUp), milliseconds)
end


---Call when user Group Stop Ramp
---
---Will called only if *AutoGroup* is false
---Must call LightReport_LightBrightnessChanged with the new level.
---
---@param groupId integer Id of the group
function LightCom_GroupStopRamp(groupId)
	LogTrace("LightCom_GroupStopRamp %d", groupId)
end


---Call when system Join to Group
---
---Will called only if *AutoGroup* is false.
---
---@param groupId integer Id of the group
---@param keepSync boolean Indicates if the sync option is checked in the Composer Pro Properties
function LightCom_JoinGroup(groupId, keepSync)
	LogTrace("LightCom_JoinGroup %d %s", groupId, tostring(keepSync))
end


---Call when system Leave Group
---
---Will called only if *AutoGroup* is false.
---
---@param groupId integer Id of the group
function LightCom_LeaveGroup(groupId)
	LogTrace("LightCom_LeaveGroup %d", groupId)
end


--[[=============================================================================
----------------------------DRIVER PROPERTIES HOOKS ----------------------------
===============================================================================]]


---Call when dealer change Click Rate Up
---
---@param milliseconds integer Click Rate Up value
function LightCom_SetClickRateUp(milliseconds)
	LogTrace("LightCom_SetClickRateUp %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_ClickRateUp(milliseconds)
end


---Call when dealer change Click Rate Down
---
---@param milliseconds integer Click Rate Down value
function LightCom_SetClickRateDown(milliseconds)
	LogTrace("LightCom_SetClickRateDown %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_ClickRateDown(milliseconds)
end


---Call when dealer change Cold Start Level
---
---@param level integer Cold Start Level Value
function LightCom_SetColdStartLevel(level)
	LogTrace("LightCom_SetColdStartLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_ColdStartLevel(level)
end


---Call when dealer change Cold Start Time
---
---@param milliseconds integer Cold Start Time value
function LightCom_SetColdStartTime(milliseconds)
	LogTrace("LightCom_SetColdStartTime %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_ColdStartTime(milliseconds)
end


---Call when dealer change Hold Rate Down
---
---@param milliseconds integer Hold Rate Down value
function LightCom_SetHoldRateDown(milliseconds)
	LogTrace("LightCom_SetHoldRateDown %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_HoldRateDown(milliseconds)
end


---Call when dealer change Hold Rate Up
---
---@param milliseconds integer Hold Rate Up value
function LightCom_SetHoldRateUp(milliseconds)
	LogTrace("LightCom_SetHoldRateUp %d", milliseconds)

	-- Comment or change next line if You want handling with this
	LightReport_HoldRateUp(milliseconds)
end


---Call when dealer change Max On Level
---
---@param level integer Max On Level value
function LightCom_SetMaxOnLevel(level)
	LogTrace("LightCom_SetMaxOnLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_MaxOnLevel(level)
end


---Call when dealer change Min On Level
---
---@param level integer Min On Level value
function LightCom_SetMinOnLevel(level)
	LogTrace("LightCom_SetMinOnLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_MinOnLevel(level)
end


---Call when dealer change Preset Level
---
---@param level integer Preset Level value
function LightCom_SetPresetLevel(level)
	LogTrace("LightCom_SetPresetLevel %d", level)

	-- Comment or change next line if You want handling with this
	LightReport_PresetLevel(level)
end


---Called when a color preset (driver specific) is modified, added or deleted
---
---@param command presetLevelCommand_t String that describes what is happending with the preset
---@param id integer Preset ID
---@param name string Preset name
---@param x number X chromaticity coordinate
---@param y number Y chromaticity coordinate
---@param colorMode colorMode_t Target color mode
function LightCom_UpdateColorPreset(command, id, name, x, y, colorMode)
	LogTrace("LightCom_UpdateColorPreset command = %s, id = %d, name = %s", command, id, name)
end
