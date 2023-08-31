--[[=============================================================================
	File is: c4hook_relay.lua
    Functions to manage the communication with the Control4 Relay code
	
    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_relay = "2018.12.20"
end

require "c4hooks.c4hook_base"

C4H_Relay = inheritsFrom(C4Hook_Base)


C4H_Relay.DefaultRelayNameIndex = 0

function C4H_Relay:construct(BindingID, RelayName, ChildRef)

	local function MakeDefaultRelayName()
		C4H_Relay.DefaultRelayNameIndex = C4H_Relay.DefaultRelayNameIndex + 1
		return	string.format("Relay_%d", C4H_Relay.DefaultRelayNameIndex)
	end

	self:super():construct(BindingID, RelayName or MakeDefaultRelayName(), ChildRef or self)

	self._IsOpen = true
	self._IsInitialized = false
end


function C4H_Relay:destruct()
	self:super():destruct()
end


function C4H_Relay:CmdOpen(tParams)
	LogTrace("C4H_Relay:CmdOpen")
 	if(C4H_Relay.DeviceRelayOpen ~= nil) then
		C4H_Relay.DeviceRelayOpen(self._BindingID)		-- old API call
	end

 	if(C4DeviceRelayOpen ~= nil) then
		C4DeviceRelayOpen(self)		-- new API call
	end
end


function C4H_Relay:CmdClose(tParams)
	LogTrace("C4H_Relay:CmdClose")
 	if(C4H_Relay.DeviceRelayClose ~= nil) then
		C4H_Relay.DeviceRelayClose(self._BindingID)		-- old API call
	end

 	if(C4DeviceRelayClose ~= nil) then
		C4DeviceRelayClose(self)		-- new API call
	end
end


function C4H_Relay:CmdToggle(tParams)
	LogTrace("C4H_Relay:CmdToggle")
 	if(C4H_Relay.DeviceRelayToggle ~= nil) then
		C4H_Relay.DeviceRelayToggle(self._BindingID)		-- old API call
	end

 	if(C4DeviceRelayToggle ~= nil) then
		C4DeviceRelayToggle(self)		-- new API call
	end
end


function C4H_Relay:CmdTrigger(tParams)
	LogTrace("C4H_Relay:CmdTrigger")
 	if(C4H_Relay.DeviceRelayTrigger ~= nil) then
		C4H_Relay.DeviceRelayTrigger(tonumber(tParams.TIME), self._BindingID)		-- old API call
	end

 	if(C4DeviceRelayTrigger ~= nil) then
		C4DeviceRelayTrigger(tonumber(tParams.TIME), self)		-- new API call
	end
end


function C4H_Relay:ReceivedStateFromDevice(DeviceOpen)
	LogTrace("C4H_Relay:ReceivedStateFromDevice  State is: %s", DeviceOpen and "Open" or "Closed")
	
	if((self._IsOpen ~= DeviceOpen) or (not self._IsInitialized)) then
		self._IsOpen = DeviceOpen
		NOTIFY.RELAY_STATE(self._IsOpen, self._BindingID)
		self._IsInitialized = true
	end
end


function C4H_Relay:SetStateFromDevice(DeviceOpen)
	LogTrace("C4H_Relay:SetStateFromDevice  State is: %s", DeviceOpen and "Open" or "Closed")
	
	self._IsOpen = DeviceOpen
		
	NOTIFY.INITIAL_RELAY_STATE(self._IsOpen, self._BindingID)
	self._IsInitialized = true
end


function C4H_Relay:IsOn()
	return (self._Level ~= 0)
end


function C4H_Relay:IsOpen()
	return self._IsOpen
end

--[[=============================================================================
	Commands
===============================================================================]]

function PRX_CMD.GET_STATE(idBinding, tParams)
	LogTrace("PRX_CMD.GET_STATE")

	-- report our state if we have heard from the device.  If we haven't heard, then ignore the request.
	local TargRelay = C4_BindingDeviceList[idBinding]
	if(TargRelay ~= nil) then
		if(TargRelay._IsInitialized) then
			NOTIFY.INITIAL_RELAY_STATE(TargRelay._IsOpen, TargRelay._BindingID)
		end
	end
end


function PRX_CMD.OPEN(idBinding, tParams)
	LogTrace("PRX_CMD.OPEN")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdOpen(tParams)
	end
end


function PRX_CMD.CLOSE(idBinding, tParams)
	LogTrace("PRX_CMD.CLOSE")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdClose(tParams)
	end
end


function PRX_CMD.TOGGLE(idBinding, tParams)
	LogTrace("PRX_CMD.TOGGLE")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdToggle(tParams)
	end
end


function PRX_CMD.TRIGGER(idBinding, tParams)
	LogTrace("PRX_CMD.TRIGGER")

	if(C4_BindingDeviceList[idBinding] ~= nil) then
		C4_BindingDeviceList[idBinding]:CmdTrigger(tParams)
	end
end

--[[=============================================================================
	Notifications
===============================================================================]]

function NOTIFY.INITIAL_RELAY_STATE(IsOpen, BindingID)
	LogTrace("Sending Initial Relay State on Binding %d : %s", tonumber(BindingID), tostring((IsOpen and "Open" or "Closed")))
	SendSimpleNotify(IsOpen and "STATE_OPENED" or "STATE_CLOSED", BindingID)
end

function NOTIFY.RELAY_STATE(IsOpen, BindingID)
	LogTrace("Sending Relay State on Binding %d : %s", tonumber(BindingID), tostring((IsOpen and "Open" or "Closed")))
	SendSimpleNotify(IsOpen and "OPENED" or "CLOSED", BindingID)
end

