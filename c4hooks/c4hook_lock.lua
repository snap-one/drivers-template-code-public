--[[=============================================================================
	File is: c4hook_lock.lua
    Functions to manage the communication with the Control4 Lock Proxy code
	
    Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4hook_relay = "2016.11.14"
end

require "c4hooks.c4hook_base"

C4H_Lock = inheritsFrom(C4Hook_Base)


function C4H_Lock:construct(BindingID)
	self:super():construct(BindingID)

	self._IsLocked = true
	self._IsInitialized = false
end


function C4H_Lock:destruct()
	self:super():destruct()
end


