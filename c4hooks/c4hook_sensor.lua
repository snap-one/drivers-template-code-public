--[[=============================================================================
	File is: c4hook_sensor.lua
    For communicating with a C4 sensor device
	
    Copyright 2019 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_sensor = "2019.01.02"
end

require "c4hooks.c4hook_base"

C4H_Sensor = inheritsFrom(C4Hook_Base)



function C4H_Sensor:construct(BindingID)
	self:super():construct(BindingID)

	self._IsVerified = false
	self._IsInitialized = false
	self._IsOpen = false
	self._PersistValueName = "C4H_Sensor_" .. tostring(BindingID)
	if(PersistData ~= nil) then
		if(PersistData[self._PersistValueName] ~= nil) then
			self._IsOpen = toboolean(PersistData[self._PersistValueName])
			self._IsInitialized = true
		end
	end
	
end


function C4H_Sensor:destruct()
	self:super():destruct()
end


function C4H_Sensor:IsVerified()
	return self._IsVerified
end


function C4H_Sensor:IsInitialized()
	return self._IsInitialized
end


function C4H_Sensor:ReceivedStateFromDevice(IsOpen)
	LogTrace("C4H_Sensor:ReceivedStateFromDevice  State is: %s", IsOpen and "Open" or "Closed")
	
	-- if the state has changed, set the new state and fire the event
	if((self._IsOpen ~= IsOpen) or (not self._IsInitialized)) then
		self._IsOpen = IsOpen
		if(PersistData ~= nil) then
			PersistData[self._PersistValueName] = tostring(self._IsOpen)
		end
		
		if(self._IsInitialized) then
			NOTIFY.SENSOR_STATE(self._IsOpen, self._BindingID)
		else
			NOTIFY.INITIAL_SENSOR_STATE(self._IsOpen, self._BindingID)
		end

		self._IsVerified = true
		self._IsInitialized = true
	end
end


function C4H_Sensor:SetStateFromDevice(IsOpen)
	LogTrace("C4H_Sensor:SetStateFromDevice  State is: %s", IsOpen and "Open" or "Closed")
	
	-- just set the state and don't fire the events
	self._IsOpen = IsOpen
	if(PersistData ~= nil) then
		PersistData[self._PersistValueName] = tostring(self._IsOpen)
	end
		
	NOTIFY.INITIAL_SENSOR_STATE(self._IsOpen, self._BindingID)
	self._IsVerified = true
	self._IsInitialized = true
end


--[[=============================================================================
	Commands
===============================================================================]]

function PRX_CMD.GET_STATE(idBinding, tParams)
	LogTrace("PRX_CMD.GET_STATE")

	-- report our state if we have heard from the device.  If we haven't heard, then ignore the request.
	local TargSensor = C4_BindingDeviceList[idBinding]
	if(TargSensor ~= nil) then
		if(TargSensor._IsInitialized) then
			NOTIFY.INITIAL_SENSOR_STATE(TargSensor._IsOpen, TargSensor._BindingID)
		end
	end
end


--[[=============================================================================
	Notifications
===============================================================================]]

function NOTIFY.INITIAL_SENSOR_STATE(IsOpen, BindingID)
	LogTrace("NOTIFY.INITIAL_SENSOR_STATE   Binding: %d  State: %s", tonumber(BindingID), tostring((IsOpen and "Open" or "Closed")))
	SendSimpleNotify(IsOpen and "STATE_OPENED" or "STATE_CLOSED", BindingID)
end

function NOTIFY.SENSOR_STATE(IsOpen, BindingID)
	LogTrace("NOTIFY.SENSOR_STATE   Binding: %d  State: %s", tonumber(BindingID), tostring((IsOpen and "Open" or "Closed")))
	SendSimpleNotify(IsOpen and "OPENED" or "CLOSED", BindingID)
end



