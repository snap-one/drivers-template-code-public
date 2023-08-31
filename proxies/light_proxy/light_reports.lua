---
--- File is: light_reports.lua
---
--- Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
---


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_reports = "2021.05.22"
end

---Set Button Action
---
---@param buttonId integer
---@param action buttonAction_t
function LightReport_ButtonAction(buttonId, action)
	TheLight:ReportLightButtonAction(buttonId, action)
end


---Set Buton Info
---
---@param buttonId integer
---@param onColor string
---@param offColor string
---@param currentColor string
---@param name string
function LightReport_ButtonInfo(buttonId, onColor, offColor, currentColor, name)
	TheLight:ReportLightButtonInfo(buttonId, onColor, offColor, currentColor, name)
end


---Set Click Rate Down
---
---@param milliseconds integer
function LightReport_ClickRateDown(milliseconds)
	TheLight:ReportLightClickRateDown(milliseconds)
end


---Set Click Rate Up
---
---@param milliseconds integer
function LightReport_ClickRateUp(milliseconds)
	TheLight:ReportLightClickRateUp(milliseconds)
end


---Set Cold Start Level
---
---@param level integer integer 0-100
function LightReport_ColdStartLevel(level)
	TheLight:ReportLightColdStartLevel(level)
end


---Set Cold Start Time
---
---@param milliseconds integer
function LightReport_ColdStartTime(milliseconds)
	TheLight:ReportLightColdStartTime(milliseconds)
end


---Set Hold Rate Down
---
---@param milliseconds integer
function LightReport_HoldRateDown(milliseconds)
	TheLight:ReportLightHoldRateDown(milliseconds)
end


---Set Hold Rate Up
---
---@param milliseconds integer
function LightReport_HoldRateUp(milliseconds)
	TheLight:ReportLightHoldRateUp(milliseconds)
end


---Set Light Level
---
---@param level integer integer 0-100
function LightReport_LightLevel(level)
	TheLight:ReportLightLightLevel(level)
end


---Part of the new Level Target API, used to notify the proxy that a lights brightness is changing.
---
---@param target integer
---@param milliseconds integer
---@param current integer
function LightReport_LightBrightnessChanging(target, milliseconds, current)
	TheLight:ReportLightBrightnessChanging(target, milliseconds, current)
end


---Part of the new Level Target API, used to notify the proxy that a lights brightness is changed.
---@param current integer
function LightReport_LightBrightnessChanged(current)
	TheLight:ReportLightBrightnessChanged(current)
end


---Set Max Level for On
---
---@param level integer integer 0-100
function LightReport_MaxOnLevel(level)
	TheLight:ReportLightMaxOnLevel(level)
end


---Set Min Level for On
---
---@param level integer integer 0-100
function LightReport_MinOnLevel(level)
	TheLight:ReportLightMinOnLevel(level)
end


---Set Number of Buttons
---
---@param number integer
function LightReport_NumberButtons(number)
	TheLight:ReportLightNumberButtons(number)
end


---Set Online Change Status
---
---@param status boolean
function LightReport_OnlineChanged(status)
	TheLight:ReportLightOnlineChanged(status)
end


---Set Preset Level
---
---@param level integer integer 0-100
function LightReport_PresetLevel(level)
	TheLight:ReportLightPresetLevel(level)
end


---Notify change in this device's capabilities.
---
---@param tCapabilities table Table with capabilities that changed
function LightReport_DynamicCapabilitiesChanged(tCapabilities)
	TheLight:ReportDynamicCapabilitiesChanged(tCapabilities)
end


---Notify that the color is changing. Color is specified in the CIE 1931 (XYZ) color space
---
---@param xTarget number x chromaticity coordinate (float) of the target color
---@param yTarget number y chromaticity coordinate (float) of the target color
---@param targetColorMode colorMode_t Target color mode
---@param milliseconds integer transition/ramp time to get to the target color
---@param xCurrent number? Optional x chromaticity coordinate (float) of the current color
---@param yCurrent number? Optional y chromaticity coordinate (float) of the current color
---@param currentColorMode colorMode_t Current color mode
function LightReport_LightColorChanging(
	xTarget, yTarget, targetColorMode, milliseconds, xCurrent, yCurrent, currentColorMode
)
	TheLight:ReportLightColorChanging(
		xTarget, yTarget, targetColorMode, milliseconds, xCurrent, yCurrent, currentColorMode
	)
end


---Notify that the color changed.
---
---@param x number x coordinate (float) in the CIE 1931 xyY color space chromaticity diagram
---@param y number y coordinate (float) in the CIE 1931 xyY color space chromaticity diagram
---@param colorMode colorMode_t Color mode
function LightReport_LightColorChanged(x, y, colorMode)
	TheLight:ReportLightColorChanged(x, y, colorMode)
end
