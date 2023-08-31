--[[=============================================================================
   File is: c4hook_base.lua

    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_base = "2018.10.15"
end

require "common.c4_driver_declarations"
require "lib.c4_object"

C4_BindingDeviceList = {}
C4_NameDeviceList = {}

C4Hook_Base = inheritsFrom(nil)

C4Hook_Base._DefaultDeviceNameIndex = 0




function C4Hook_Base:construct(BindingID, DeviceName, ChildRef)
	
	local function MakeDeviceDefaultName()
		C4Hook_Base._DefaultDeviceNameIndex = C4Hook_Base._DefaultDeviceNameIndex + 1
		return string.format("GenericDevice_%d", C4Hook_Base._DefaultDeviceNameIndex)
	end

	self._BindingID = BindingID
	self._ChildRef = ChildRef or self
	self._DeviceName = DeviceName or MakeDeviceDefaultName()
	
	C4_BindingDeviceList[self._BindingID] = self._ChildRef
	C4_NameDeviceList[self._DeviceName] = self._ChildRef
end


function C4Hook_Base:destruct()
	C4_BindingDeviceList[self._BindingID] = nil
	C4_NameDeviceList[self._DeviceName] = nil
end


function C4Hook_Base:GetDeviceName()
	return self._DeviceName
end


function C4Hook_Base:BindingChanged(strClass, bIsBound)
	LogTrace("C4Hook_Base:BindingChanged %s %s", tostring(strClass), tostring(strClass))
	-- override as needed
end


function C4Hook_Base.GetDeviceFromBinding(idBinding)
	return C4_BindingDeviceList[idBinding]
end


function C4Hook_Base.GetDeviceFromName(CheckName)
	return C4_NameDeviceList[CheckName]
end


function C4Hook_Base.OnBindingChanged(idBinding, strClass, bIsBound)
	local TargDevice = C4Hook_Base.GetDeviceFromBinding(idBinding)
	
	if(TargDevice ~= nil) then
		TargDevice:BindingChanged(strClass, bIsBound)
	end
end



