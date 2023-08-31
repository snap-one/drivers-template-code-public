--[[=============================================================================
    File is: light_apis.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.

	API calls for developers using light template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_apis = "2021.11.30"
end

---@class AlsData
---@field delay number
---@field rate number
---@field level number
---@field colorMode number
---@field levelEnabled boolean
---@field levelRate number
---@field levelDelay number
---@field colorEnabled boolean
---@field colorRate number
---@field colorX number
---@field colorY number
---@field brightnessPresetID number
---@field colorPresetID number
---@field colorPresetOrigin number
--- Structure of the ALS configuration table


---Set that driver is Dimmer Type
---
---@param value boolean
function SetTypeDimmer(value)
	TheLight:SetTypeDimmer(value)
end


---Set Auto handling ON, OFF, TOGGLE
---
---@param value boolean
function SetAutoSwitch(value)
	TheLight:SetAutoSwitch(value)
end


---Set Auto handling Button Actions
---
---@param value any
function SetAutoButton(value)
	TheLight:SetAutoButton(value)
end


---Set Auto handling Group
---
---@param value boolean
function SetAutoGroup(value)
	TheLight:SetAutoGroup(value)
end


---Set Auto handling Group commands
---
---@param value boolean
function SetAutoGroupCommands(value)
	TheLight:SetAutoGroupCommands(value)
end


---Set Auto handling Advanced Lighting Scenes commands
---
---@param value boolean
function SetAutoAls(value)
	TheLight:SetAutoAls(value)
end

---Set Debounce time for Button Action in auto handlinge buttons
---
---**Set only if AutoButton is true**
---
---@param milliseconds integer
function SetButtonDebounceMilliseconds(milliseconds)
	TheLight:SetButtonDebounceMilliseconds(milliseconds)
end


---Make Table from ALS elements XML
---
---@param elements string
---@return table AlsData
function LightAlsXmlToTable(elements)
	return TheLight:AlsXmlToTable(elements)
end


--[[=============================================================================

===============================================================================]]

---Return current light color.
---
---Returns the following values:
---
---- x and y that represent chromaticity of the color in the CIE 1931 xyY color space.
---- colorMode that specifies if color is full color (LightDevice.COLOR_MODE_FULL_COLOR) or CCT (LightDevice.COLOR_MODE_CCT).
---
---If current color is not set, returns nil for each color component
---
---@return integer|nil x
---@return integer|nil y
---@return colorMode_t|nil colorMode
function GetLightColor()
	return TheLight:GetLightColor()
end


---Return current light level.
---
---@return integer lightLevel
function GetLightLevel()
	return TheLight:GetLightLevel()
end

--[[=============================================================================

		value - boolean

===============================================================================]]

---Set Warm Dimming feature
---
---If WarmDimming is set True, parameters of WarmDimming should be set with SetWarmDimmingFunctionParameters function.
---
---@param value boolean
function SetWarmDimming(value)
	TheLight:SetWarmDimming(value)
end

---Set Warm Dimming Function parameters
---
---Parameters k and n are parameters of linear function (f(x) = k*x + n).
---x is light brightness and f(x) is cct that will be set.
---
---@param k number
---@param n number
function SetWarmDimmingFunctionParameters(k,n)
	TheLight:SetWarmDimmingFunctionParameters(k,n)
end


---Return CTT min and max value.
---
---@return number cctMin
---@return number cctMax
function GetCCTRange()
	return TheLight:getCCTRange()
end


---Return current light state.
---
---@return boolean lightState
function GetLightState()
	return TheLight:GetLightState()
end


---Return light preset level.
---
---@return integer presetLevel
function GetPresetLevel()
	return TheLight:GetPresetLevel()
end


---Return light click up rate.
---
---@return number clickUpRate
function GetClickRateUp()
	return TheLight:GetClickRateUp()
end


---Return light click down rate.
---
---@return number clickDownRate
function GetClickRateDown()
	return TheLight:GetClickRateDown()
end

---Return light hold up rate.
---
---@return number holdUpRate
function GetHoldRateUp()
	return TheLight:GetHoldRateUp()
end

---Return light hold down rate.
---
---@return number holdDownRate
function GetHoldRateDown()
	return TheLight:GetHoldRateDown()
end

---Gets the default Off/On Colors
---
---@return {x: integer, y: integer, mode: colorMode_t} offColorTable
---@return {x: integer, y:integer, mode: colorMode_t} onColorTable
function GetDefaultColors()
	return TheLight:GetDefaultColors()
end

---Returns the Advanced Lighting Scene table
---
---@return table AlsData
function GetAlsData()
	return TheLight._PersistData.Als
end


---Return WarmDimming boolean value.
---
---@return boolean warmDimmingEnabled
function IsWarmDimmingEnabled()
	return TheLight:IsWarmDimmingEnabled()
end


---Calculate Warm Dimming Function parameters
---
---Parameter cctRange contains min and max cct values that will be used for WD.
---
---@param cctRange {min: number, max: number}
function CalculateWarmDimmingFunctionParameters(cctRange)
	TheLight:CalculatePiecewiseLinearWarmDimming(cctRange)
end


---Return light online state boolean value.
---
---@return boolean lightOnline
function GetLightOnlineStatus()
	return TheLight:GetLightOnlineStatus()
end