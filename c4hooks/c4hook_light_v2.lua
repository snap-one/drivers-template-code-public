--[[=============================================================================
	File is: c4hook_light_v2.lua
    Functions to manage the communication with the Control4 Light v2 proxy

	Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_light_v2 = "2016.05.25"
end

require "c4hooks.c4hook_base"

C4H_LightV2 = inheritsFrom(C4Hook_Base)

LIGHT_PROXY_BINDING_ID = 5001


function C4H_LightV2:construct(BindingID, IsADimmer)
	self:super():construct(BindingID)

	self._Level = 0
	self._DefaultOnValue = 100
	self._IsADimmer = IsADimmer
	self._ClickRateUp = 0
	self._ClickRateDown = 0

	if (PersistData["VirtualButtons"] == nil) then
		local topButton = {ON_COLOR="0000ff", OFF_COLOR="000000"}
		local bottomButton = {ON_COLOR="000000", OFF_COLOR="0000ff"}
		local toggleButton = {ON_COLOR="0000ff", OFF_COLOR="000000"}
		PersistData["VirtualButtons"] = {}
		PersistData["VirtualButtons"][200] = topButton
		PersistData["VirtualButtons"][201] = bottomButton
		PersistData["VirtualButtons"][202] = toggleButton
	end
end


function C4H_LightV2:destruct()
	self:super():destruct()
end


function C4H_LightV2:CmdGetConnectedState(tParams)
    LogTrace("C4H_LightV2:CmdGetConnectedState")
    NOTIFY.ONLINE_CHANGED("TRUE", self._BindingID)
end


function C4H_LightV2:CmdSetClickRateUp(tParams)
    LogTrace("C4H_LightV2:CmdSetClickRateUp")

	if(C4H_LightV2.SetClickRateDownOnDevice ~= nil) then
		self.SetClickRateUpOnDevice(tonumber(tParams.RATE), self._BindingID)		-- API call
	end
end


function C4H_LightV2:CmdSetClickRateDown(tParams)
    LogTrace("C4H_LightV2:CmdSetClickRateDown")

	if(C4H_LightV2.SetClickRateDownOnDevice ~= nil) then
		self.SetClickRateDownOnDevice(tonumber(tParams.RATE), self._BindingID)		-- API call
	end
end


function C4H_LightV2:CmdOn(tParams)
	LogTrace("C4H_LightV2:CmdOn")
	if (PersistData["PresetOnValue"] ~= nil) then
		self:SetLevel(PersistData["PresetOnValue"], 0)
	else
		self:SetLevel(self._DefaultOnValue, 0)
	end
end


function C4H_LightV2:CmdOff(tParams)
	LogTrace("C4H_LightV2:CmdOff")
	self:SetLevel(0, 0)
end


function C4H_LightV2:CmdToggle(tParams)
	LogTrace("C4H_LightV2:CmdToggle")
	if(self:IsOn()) then
		self:CmdOff(tParams)
	else
		self:CmdOn(tParams)
	end
end


function C4H_LightV2:CmdSetPresetLevel(tParams)
	LogTrace("C4H_LightV2:CmdSetPresetLevel")

	PersistData["PresetOnValue"] = tonumber(tParams.LEVEL)
end


function C4H_LightV2:CmdSetLevel(tParams)
	LogTrace("C4H_LightV2:SetLevel")
	local TargetLevel = tonumber(tParams.LEVEL)
	self:SetLevel(TargetLevel, 0)
end


function C4H_LightV2:CmdRampToLevel(tParams)
	LogTrace("C4H_LightV2: CmdRampToLevel")
	self:SetLevel(tonumber(tParams.LEVEL), tonumber(tParams.TIME))
end


function C4H_LightV2:SetLevel(DesiredLevel, specifiedRate)
 	if(C4H_LightV2.SetLevelOnDevice ~= nil) then
		self.SetLevelOnDevice(DesiredLevel, self._BindingID, self._Level, specifiedRate) -- API call
	end
end


function C4H_LightV2:ReceivedLevelFromDevice(ReportedLevel)
	local TargetLevel = tonumber(ReportedLevel)
	LogTrace("C4H_LightV2:ReceivedLevelFromDevice  Level is: %d", TargetLevel)

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
		self:NotifyLinksOfState()
		NOTIFY.LIGHT_LEVEL_CHANGED(self._Level, self._BindingID)
	end
end


function C4H_LightV2:SendClickRateUpNotify(Rate)
	NOTIFY.CLICK_RATE_UP(Rate, self._BindingID)
	self._ClickRateUp = Rate
end


function C4H_LightV2:SendClickRateDownNotify(Rate)
	NOTIFY.CLICK_RATE_DOWN(Rate, self._BindingID)
	self._ClickRateDown = Rate
end


function C4H_LightV2:GetClickRateUp()
	return self._ClickRateUp
end


function C4H_LightV2:GetClickRateDown()
	return self._ClickRateDown
end


function C4H_LightV2:GetLevel()
	return self._Level
end


function C4H_LightV2:IsOn()
	return (self._Level ~= 0)
end


function C4H_LightV2:CmdBtnAction(tParams)
	LogTrace("C4H_LightV2:CmdBtnAction")

	local btnID = tonumber (tParams.BUTTON_ID)
    local btnAction = tonumber (tParams.ACTION)

    print ("button ID: " .. tostring(btnID) .. " button Action: " .. tostring(btnAction))

    -- every btn action should use the default ramp set on the device (if ramp exists)
    if (btnAction == 1) then --press
    	if(C4H_LightV2.ButtonPushed ~= nil) then
			C4H_LightV2.ButtonPushed(btnID)
		end
	elseif (btnAction == 2) then -- click
		if(C4H_LightV2.ButtonClicked ~= nil) then
			C4H_LightV2.ButtonClicked(btnID)
		end
	elseif (btnAction == 0) then -- release
		if(C4H_LightV2.ButtonReleased ~= nil) then
			C4H_LightV2.ButtonReleased(btnID)
		end
    end
end


function C4H_LightV2:CmdSetBtnColor(tParams)
	LogTrace("C4H_LightV2:CmdSetBtnColor")

	local btnBindingId = tonumber(tParams.BUTTON_ID) + 200

	if (tParams.ON_COLOR ~= nil) then
		PersistData["VirtualButtons"][btnBindingId].ON_COLOR = tostring(tParams.ON_COLOR)
	elseif (tParams.OFF_COLOR ~= nil) then
		PersistData["VirtualButtons"][btnBindingId].OFF_COLOR = tostring(tParams.OFF_COLOR)
	end

	local currentColor = self:GetCurrentColor(btnBindingId)

	NOTIFY.BTN_COLOR_CHANGED("BUTTON_COLORS", PersistData["VirtualButtons"][btnBindingId].ON_COLOR, PersistData["VirtualButtons"][btnBindingId].OFF_COLOR, currentColor, tonumber(tParams.BUTTON_ID), btnBindingId) -- notify bound buttons
	NOTIFY.BTN_COLOR_CHANGED("BUTTON_INFO", PersistData["VirtualButtons"][btnBindingId].ON_COLOR, PersistData["VirtualButtons"][btnBindingId].OFF_COLOR, currentColor, tonumber(tParams.BUTTON_ID), self._BindingID) -- notify proxy
	self:NotifyLinksOfState()
end


function C4H_LightV2:CmdRequestBtnColors(tParams)
	LogTrace("C4H_LightV2:CmdRequestBtnColors")

	local btnBindingId = tonumber(tParams.ID_BINDING)
	local currentColor = self:GetCurrentColor(btnBindingId)

	NOTIFY.BTN_COLOR_CHANGED("BUTTON_COLORS", PersistData["VirtualButtons"][btnBindingId].ON_COLOR, PersistData["VirtualButtons"][btnBindingId].OFF_COLOR, currentColor, btnBindingId - 200, btnBindingId) -- notify bound buttons
	self:NotifyLinksOfState()
end


function C4H_LightV2:NotifyLinksOfState()
	LogTrace("C4H_LightV2:NotifyLinksOfState")

	local ledState = self:IsOn()

	C4:SendToProxy(200, "MATCH_LED_STATE", {STATE=ledState}, "COMMAND")
	NOTIFY.BTN_COLOR_CHANGED("BUTTON_INFO", PersistData["VirtualButtons"][200].ON_COLOR, PersistData["VirtualButtons"][200].OFF_COLOR, self:GetCurrentColor(200), 0, self._BindingID)
	C4:SendToProxy(201, "MATCH_LED_STATE", {STATE=ledState}, "COMMAND")
	NOTIFY.BTN_COLOR_CHANGED("BUTTON_INFO", PersistData["VirtualButtons"][201].ON_COLOR, PersistData["VirtualButtons"][201].OFF_COLOR, self:GetCurrentColor(201), 1, self._BindingID)
	C4:SendToProxy(202, "MATCH_LED_STATE", {STATE=ledState}, "COMMAND")
	NOTIFY.BTN_COLOR_CHANGED("BUTTON_INFO", PersistData["VirtualButtons"][202].ON_COLOR, PersistData["VirtualButtons"][202].OFF_COLOR, self:GetCurrentColor(202), 2, self._BindingID)
end


function C4H_LightV2:GetCurrentColor(btnBindingId)
	if (self:IsOn()) then
		return PersistData["VirtualButtons"][btnBindingId].ON_COLOR
	else
		return PersistData["VirtualButtons"][btnBindingId].OFF_COLOR
	end
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


function PRX_CMD.SET_PRESET_LEVEL(idBinding, tParams)
	LogTrace("PRX_CMD.SET_PRESET_LEVEL")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdSetPresetLevel(tParams)
	end
end


function PRX_CMD.BUTTON_ACTION(idBinding, tParams)
    LogTrace("PRX_CMD.BUTTON_ACTION")

    if(C4_BindingDeviceList[idBinding] ~= nil) then
    	C4_BindingDeviceList[idBinding]:CmdBtnAction(tParams)
    end
end


function PRX_CMD.RAMP_TO_LEVEL(idBinding, tParams)
	LogTrace("PRX_CMD.RAMP_TO_LEVEL")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdRampToLevel(tParams)
	end
end


function PRX_CMD.GET_CONNECTED_STATE(idBinding, tParams)
    LogTrace("PRX_CMD.GET_CONNECTED_STATE")

    if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdGetConnectedState(tParams)
    end
end


function PRX_CMD.SET_CLICK_RATE_UP(idBinding, tParams)
	LogTrace("PRX_CMD.SET_CLICK_RATE_UP")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdSetClickRateUp(tParams)
    end
end


function PRX_CMD.SET_CLICK_RATE_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.SET_CLICK_RATE_DOWN")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdSetClickRateDown(tParams)
    end
end


--[[=============================================================================
	Virtual Button Commands
===============================================================================]]


function PRX_CMD.DO_PUSH(idBinding, tParams)
    LogTrace("PRX_CMD.DO_PUSH")

    if(C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID] ~= nil) then
    	local args = {}
    	args["BUTTON_ID"] = idBinding - 200 -- base button id
    	args["ACTION"] = 1 -- push
    	C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID]:CmdBtnAction(args) -- send to lightv2 code
    end
end


function PRX_CMD.DO_RELEASE(idBinding, tParams)
    LogTrace("PRX_CMD.DO_RELEASE")

    if(C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID] ~= nil) then
    	local args = {}
    	args["BUTTON_ID"] = idBinding - 200 -- base button id
    	args["ACTION"] = 0 -- release
    	C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID]:CmdBtnAction(args) -- send to lightv2 code
    end
end


function PRX_CMD.DO_CLICK(idBinding, tParams)
    LogTrace("PRX_CMD.DO_CLICK")

    if(C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID] ~= nil) then
    	local args = {}
    	args["BUTTON_ID"] = idBinding - 200 -- base button id
    	args["ACTION"] = 2 -- click
    	C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID]:CmdBtnAction(args) -- send to lightv2 code
    end
end


function PRX_CMD.REQUEST_BUTTON_COLORS(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_BUTTON_COLORS")

	if(C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID] ~= nil) then
		tParams.ID_BINDING = idBinding
    	C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID]:CmdRequestBtnColors(tParams) -- send to lightv2 code
    end
end


function PRX_CMD.SET_BUTTON_COLOR(idBinding, tParams)
	LogTrace("PRX_CMD.SET_BUTTON_COLOR")

	if(C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID] ~= nil) then
    	C4_BindingDeviceList[LIGHT_PROXY_BINDING_ID]:CmdSetBtnColor(tParams) -- send to lightv2 code
    end
end


--[[=============================================================================
	Notifications
===============================================================================]]

function NOTIFY.LIGHT_LEVEL_CHANGED(NewLightLevel, BindingID)
	LogTrace("NOTIFY.LIGHT_LEVEL on Binding %d : %d", tonumber(BindingID), tonumber(NewLightLevel))
	SendNotify("LIGHT_LEVEL", tostring(NewLightLevel), BindingID)
end

function NOTIFY.ONLINE_CHANGED(onlineChanged, BindingID)
	LogTrace("NOTIFY.ONLINE_CHANGED on Binding %d : %s", tonumber(BindingID), onlineChanged)
	SendNotify("ONLINE_CHANGED", {STATE = onlineChanged}, BindingID) -- for regular lightv2 proxy
	SendNotify("ONLINE_CHANGED", onlineChanged, BindingID) -- for outlet light driver
end

function NOTIFY.CLICK_RATE_UP(Rate, BindingID)
	LogTrace("NOTIFY.CLICK_RATE_UP on Binding %d : %d", tonumber(BindingID), tonumber(Rate))
	SendNotify("CLICK_RATE_UP", tonumber(Rate), BindingID)
end

function NOTIFY.CLICK_RATE_DOWN(Rate, BindingID)
	LogTrace("NOTIFY.CLICK_RATE_DOWN on Binding %d : %d", tonumber(BindingID), tonumber(Rate))
	SendNotify("CLICK_RATE_DOWN", tonumber(Rate), BindingID)
end


function NOTIFY.BTN_COLOR_CHANGED(notifyString, onColor, offColor, currentColor, buttonId, BindingID)
	LogTrace("NOTIFY.BTN_COLOR_CHANGED on Binding %d Button ID %d On Color %s Off Color %s Current Color %s", tonumber(BindingID), tonumber(buttonId), tostring(onColor), tostring(offColor), tostring(currentColor))
	SendNotify(notifyString, {BUTTON_ID=buttonId, ON_COLOR=onColor, OFF_COLOR=offColor, CURRENT_COLOR=currentColor}, tonumber(BindingID))
end

