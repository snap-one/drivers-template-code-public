--[[=============================================================================
	File is: c4hook_keypad.lua
    Functions to manage the communication with the Control4 Keypad proxy

    Copyright 2017 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_keypad = "2017.03.27"
end

require "c4hooks.c4hook_base"

C4H_Keypad = inheritsFrom(C4Hook_Base)

HOLD_TIMER = nil
HELD_BUTTON = 0
CLICK_NUMBER = 0
CLICK_COUNT = 0
CLICKED_BTN = 0
CLICK_EVENT_INTERVAL = 15
BTN_ACTION_BINDING = 0


function C4H_Keypad:construct(BindingID)
	self:super():construct(BindingID)

	if (PersistData["HOLD_EVENT_INTERVAL"] == nil) then
		PersistData["HOLD_EVENT_INTERVAL"] = 12000
	end
end


function C4H_Keypad:destruct()
	self:super():destruct()
end


function C4H_Keypad:CmdKeypadButtonAction(tParams)
	LogTrace("C4H_Keypad:CmdKeypadButtonAction")

	if(C4H_Keypad.SetKeypadButtonActionOnDevice ~= nil) then
		self.SetKeypadButtonActionOnDevice(tParams["BUTTON_ID"], tParams["ACTION"], self._BindingID)		-- API call
	end
end


function C4H_Keypad:CmdKeypadButtonInfo(tParams)
	LogTrace("C4H_Keypad:CmdKeypadButtonInfo")
	NOTIFY.KEYPAD_BUTTON_INFO(tParams["BUTTON_ID"], tParams["NAME"], self._BindingID)
end


function C4H_Keypad:UpdateHoldInterval(newInterval)
	LogTrace("C4H_Keypad:UpdateHoldInterval %d", tonumber(newInterval))
	PersistData["HOLD_EVENT_INTERVAL"] = (tonumber(newInterval) * 1000) + 2000
end


function C4H_Keypad:ReceivedButtonActionFromDevice(buttonAction, buttonNumber)
	LogTrace("C4H_Keypad:ReceivedButtonActionFromDevice")

	CLICKED_BTN = buttonNumber
	BTN_ACTION_BINDING = self._BindingID

	if (buttonAction == "SINGLE CLICK") then
		CLICK_COUNT = 1
		CLICK_NUMBER = 1
		C4:SetTimer(CLICK_EVENT_INTERVAL, C4H_Keypad.ClickTimerExpired)
	elseif(buttonAction == "DOUBLE CLICK") then
		CLICK_COUNT = 2
		CLICK_NUMBER = 2
		C4:SetTimer(CLICK_EVENT_INTERVAL, C4H_Keypad.ClickTimerExpired)
	elseif(buttonAction == "TRIPLE CLICK") then
		CLICK_COUNT = 3
		CLICK_NUMBER = 3
		C4:SetTimer(CLICK_EVENT_INTERVAL, C4H_Keypad.ClickTimerExpired)
	elseif(buttonAction == "HOLD") then
		if (HOLD_TIMER == nil) then
			NOTIFY.KEYPAD_BUTTON_ACTION(buttonNumber, 1, self._BindingID) -- pushed
			HELD_BUTTON = buttonNumber
		end
		if (HOLD_TIMER ~= nil) then
			HOLD_TIMER = HOLD_TIMER:Cancel()
		end
		HOLD_TIMER = C4:SetTimer(PersistData["HOLD_EVENT_INTERVAL"], C4H_Keypad.HoldTimerExpired)
	elseif(buttonAction == "RELEASE") then
		HOLD_TIMER = HOLD_TIMER:Cancel()
		HELD_BUTTON = 0
		NOTIFY.KEYPAD_BUTTON_ACTION(buttonNumber, 0, self._BindingID) -- released
	end
end


function C4H_Keypad:ClickTimerExpired(timer)
	if (CLICK_COUNT > 0) then
		CLICK_COUNT = CLICK_COUNT - 1
		NOTIFY.KEYPAD_BUTTON_ACTION(CLICKED_BTN, 1, BTN_ACTION_BINDING) -- pushed
		NOTIFY.KEYPAD_BUTTON_ACTION(CLICKED_BTN, 2, BTN_ACTION_BINDING) -- click
		C4:SetTimer(CLICK_EVENT_INTERVAL, C4H_Keypad.ClickTimerExpired)
	else
		NOTIFY.CLICK_COUNT(CLICKED_BTN, CLICK_NUMBER, BTN_ACTION_BINDING) -- click count
		CLICK_NUMBER = 0
		CLICKED_BTN = 0
	end
end


function C4H_Keypad:HoldTimerExpired(idTimer)
	LogTrace("C4H_Keypad:HoldTimerExpired")
	if (HOLD_TIMER ~= nil) then
		HOLD_TIMER = HOLD_TIMER:Cancel()
	end
	NOTIFY.KEYPAD_BUTTON_ACTION(HELD_BUTTON, 0, BTN_ACTION_BINDING) -- released
	HELD_BUTTON = 0
end


function C4H_Keypad:AddButton(buttonId, buttonName)
	LogTrace("C4H_Keypad:AddButton")

	NOTIFY.NEW_KEYPAD_BUTTON(buttonId, buttonName, self._BindingID)
end


--[[=============================================================================
	Commands
===============================================================================]]


function PRX_CMD.KEYPAD_BUTTON_ACTION(idBinding, tParams)
	LogTrace("PRX_CMD.KEYPAD_BUTTON_ACTION")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdKeypadButtonAction(tParams)
	end
end


function PRX_CMD.KEYPAD_BUTTON_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.KEYPAD_BUTTON_INFO")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdKeypadButtonInfo(tParams)
	end
end


--[[=============================================================================
	Notifications
===============================================================================]]

function NOTIFY.CLICK_COUNT(btnId, count, BindingID)
	LogTrace("NOTIFY.CLICK_COUNT on Binding %s btnId %s click count %s", tostring(BindingID), tostring(btnId), tostring(count))
	SendNotify("CLICK_COUNT", {BUTTON_ID = btnId, COUNT = count}, BindingID)
end


function NOTIFY.KEYPAD_BUTTON_ACTION(btnId, action, BindingID)
	LogTrace("NOTIFY.KEYPAD_BUTTON_ACTION on Binding %s btnId %s action %s", tostring(BindingID), tostring(btnId), tostring(action))
	SendNotify("KEYPAD_BUTTON_ACTION", {BUTTON_ID = btnId, ACTION = action}, BindingID)
end

function NOTIFY.KEYPAD_BUTTON_INFO(btnId, newName, BindingID)
	LogTrace("NOTIFY.KEYPAD_BUTTON_INFO on Binding %s", tostring(BindingID))
	SendNotify("KEYPAD_BUTTON_INFO", {BUTTON_ID = btnId, NAME = newName}, BindingID)
end

function NOTIFY.NEW_KEYPAD_BUTTON(buttonId, buttonName, BindingID)
	LogTrace("NOTIFY.NEW_KEYPAD_BUTTON on Binding %s Button Id %s Button Name %s", tostring(BindingID), tostring(buttonId), buttonName)
	SendNotify("NEW_KEYPAD_BUTTON", {BUTTON_ID = buttonId, NAME = buttonName, SLOTS = 1, BINDING = true}, BindingID)
end

function NOTIFY.DELETE_KEYPAD_BUTTON(buttonId, BindingID)
	LogTrace("NOTIFY.DELETE_KEYPAD_BUTTON on Binding %s Button Id %s", tostring(BindingID), tostring(buttonId))
	SendNotify("DELETE_KEYPAD_BUTTON", {BUTTON_ID = buttonId}, BindingID)
end

