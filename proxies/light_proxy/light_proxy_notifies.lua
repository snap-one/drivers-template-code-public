--[[=============================================================================
    Notification Functions sent to the Light proxy from the driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.light_proxy_notifies = "2021.05.22"
end


---------------------------------------------------------------


function NOTIFY.BUTTON_ACTION(buttonId, action, BindingID)
	LogTrace("NOTIFY.BUTTON_ACTION %d %d %d", buttonId, action, BindingID, BindingID)

	local tParams = {}
	tParams["BUTTON_ID"] = buttonId
	tParams["ACTION"] = action

	SendNotify("BUTTON_ACTION", tParams, BindingID)
end


function NOTIFY.BUTTON_INFO(buttonId, onColor, offColor, currentColor, name, BindingID)
	LogTrace("NOTIFY.BUTTON_INFO %d %s %s %s %s %d", buttonId, onColor, offColor, currentColor, name, BindingID)

	local tParams = {}
	tParams["BUTTON_ID"] = buttonId
	tParams["ON_COLOR"] = onColor
	tParams["OFF_COLOR"] = offColor
	tParams["CURRENT_COLOR"] = currentColor
	tParams["NAME"] = name

	SendNotify("BUTTON_INFO", tParams, BindingID)
end


function NOTIFY.CLICK_RATE_DOWN(milliseconds, BindingID)
	LogTrace("NOTIFY.CLICK_RATE_DOWN %d %d", milliseconds, BindingID)

	SendNotify("CLICK_RATE_DOWN", tostring(milliseconds), BindingID)
end


function NOTIFY.CLICK_RATE_UP(milliseconds, BindingID)
	LogTrace("NOTIFY.CLICK_RATE_UP %d %d", milliseconds, BindingID)

	SendNotify("CLICK_RATE_UP", tostring(milliseconds), BindingID)
end


function NOTIFY.COLD_START_LEVEL(level, BindingID)
	LogTrace("NOTIFY.COLD_START_LEVEL %d %d", level, BindingID)

	SendNotify("COLD_START_LEVEL", tostring(level), BindingID)
end


function NOTIFY.COLD_START_TIME(milliseconds, BindingID)
	LogTrace("NOTIFY.COLD_START_TIME %d %d", milliseconds, BindingID)

	SendNotify("COLD_START_TIME", tostring(milliseconds), BindingID)
end


function NOTIFY.HOLD_RATE_DOWN(milliseconds, BindingID)
	LogTrace("NOTIFY.HOLD_RATE_DOWN %d %d", milliseconds, BindingID)

	SendNotify("HOLD_RATE_DOWN", tostring(milliseconds), BindingID)
end


function NOTIFY.HOLD_RATE_UP(milliseconds, BindingID)
	LogTrace("NOTIFY.HOLD_RATE_UP %d %d", milliseconds, BindingID)

	SendNotify("HOLD_RATE_UP", tostring(milliseconds), BindingID)
end


function NOTIFY.LIGHT_LEVEL(level, BindingID)
	LogTrace("NOTIFY.LIGHT_LEVEL %d %d", level, BindingID)

	SendNotify("LIGHT_LEVEL", tostring(level), BindingID)
end


function NOTIFY.LIGHT_BRIGHTNESS_CHANGING(target, milliseconds, current, BindingID)
	LogTrace("NOTIFY.LIGHT_BRIGHTNESS_CHANGING %d %s %s %d", target, tostring(milliseconds),
		tostring(current), BindingID)

	local tParams = {
		LIGHT_BRIGHTNESS_TARGET = target,
		RATE = milliseconds,
		LIGHT_BRIGHTNESS_CURRENT = current,
	}

	SendNotify("LIGHT_BRIGHTNESS_CHANGING", tParams, BindingID)
end

function NOTIFY.LIGHT_BRIGHTNESS_CHANGED(current, BindingID)
	LogTrace("NOTIFY.LIGHT_BRIGHTNESS_CHANGED %d %d", current, BindingID)

	SendNotify("LIGHT_BRIGHTNESS_CHANGED", { LIGHT_BRIGHTNESS_CURRENT = current }, BindingID)
end


function NOTIFY.MAX_ON_LEVEL(level, BindingID)
	LogTrace("NOTIFY.MAX_ON_LEVEL %d %d", level, BindingID)

	SendNotify("MAX_ON_LEVEL", tostring(level), BindingID)
end


function NOTIFY.MIN_ON_LEVEL(level, BindingID)
	LogTrace("NOTIFY.MIN_ON_LEVEL %d %d", level, BindingID)

	SendNotify("MIN_ON_LEVEL", tostring(level), BindingID)
end


function NOTIFY.NUMBER_BUTTONS(number, BindingID)
	LogTrace("NOTIFY.NUMBER_BUTTONS %d %d", number, BindingID)

	SendNotify("NUMBER_BUTTONS", tostring(number), BindingID)
end


function NOTIFY.ONLINE_CHANGED(state, BindingID)
	LogTrace("NOTIFY.ONLINE_CHANGED %s %d", tostring(state), BindingID)

	local tParams = {}
	tParams["STATE"] = state

	SendNotify("ONLINE_CHANGED", tParams, BindingID)
end


function NOTIFY.PRESET_LEVEL(level, BindingID)
	LogTrace("NOTIFY.PRESET_LEVEL %d %d", level, BindingID)

	SendNotify("PRESET_LEVEL", tostring(level), BindingID)
end


function NOTIFY.BUTTON_COLORS(onColor, offColor, BindingID)
	LogTrace("NOTIFY.BUTTON_COLORS %s %s %d", onColor, offColor, BindingID)

	local tParams = {}
	tParams["ON_COLOR"] = onColor
	tParams["OFF_COLOR"] = offColor

	SendNotify("BUTTON_COLORS", tParams, BindingID)
end


function NOTIFY.MATCH_LED_STATE(state, BindingID)
	LogTrace("NOTIFY.MATCH_LED_STATE %s %d", tostring(state), BindingID)

	local tParams = {}
	tParams["STATE"] = state

--	SendNotify("MATCH_LED_STATE", tParams, BindingID)
	C4:SendToProxy(BindingID, "MATCH_LED_STATE", tParams)
end


function NOTIFY.DYNAMIC_CAPABILITIES_CHANGED(tCapabilities, BindingID)
	LogTrace("NOTIFY.DYNAMIC_CAPABILITIES_CHANGED", BindingID)

	SendNotify("DYNAMIC_CAPABILITIES_CHANGED", tCapabilities, BindingID)
end

function NOTIFY.LIGHT_COLOR_CHANGING(xTarget, yTarget, targetColorMode, milliseconds,
		xCurrent, yCurrent, currentColorMode, BindingID)
	LogTrace("NOTIFY.LIGHT_COLOR_CHANGING Target Color: x = %f, y = %f, Mode = %s, Rate = %dms, %d",
		xTarget, yTarget, tostring(targetColorMode), milliseconds, BindingID)

	tParams = {
		LIGHT_COLOR_TARGET_X = xTarget,
		LIGHT_COLOR_TARGET_Y = yTarget,
		LIGHT_COLOR_TARGET_COLOR_MODE = targetColorMode,
		RATE = milliseconds,
	}

	if xCurrent and yCurrent then
		LogTrace("NOTIFY.LIGHT_COLOR_CHANGING Current Color: x = %f, y = %f, Mode = %s",
			xCurrent, yCurrent, tostring(currentColorMode))
		tParams.LIGHT_COLOR_CURRENT_X = xCurrent
		tParams.LIGHT_COLOR_CURRENT_Y = yCurrent
		tParams.LIGHT_COLOR_CURRENT_COLOR_MODE = currentColorMode
	end

	SendNotify("LIGHT_COLOR_CHANGING", tParams, BindingID)
end


function NOTIFY.LIGHT_COLOR_CHANGED(x, y, colorMode, BindingID)
	LogTrace("NOTIFY.LIGHT_COLOR_CHANGED x = %f, y = %f, %s, %d", x, y, tostring(colorMode),
		BindingID)

	tParams = {
		LIGHT_COLOR_CURRENT_X = x,
		LIGHT_COLOR_CURRENT_Y = y,
		LIGHT_COLOR_CURRENT_COLOR_MODE = colorMode
	}
	SendNotify("LIGHT_COLOR_CHANGED", tParams, BindingID)
end


function NOTIFY.EXTRAS_SETUP_CHANGED(tParams, BindingID)
	LogTrace("NOTIFY.EXTRAS_SETUP_CHANGED")

	SendNotify("EXTRAS_SETUP_CHANGED", tParams, BindingID)
end

function NOTIFY.EXTRAS_STATE_CHANGED(tParams, BindingID)
	LogTrace("NOTIFY.EXTRAS_STATE_CHANGED")

	SendNotify("EXTRAS_STATE_CHANGED", tParams, BindingID)
end
---------------------------------------------------------------


