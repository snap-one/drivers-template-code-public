--[[=============================================================================
	File is: ir_com.lua
	Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.ir_com = "2022.10.10"
end


IRCom = inheritsFrom(nil)


function IRCom:construct()
	self._IsInitialized = false
	self._BindingID = 0
end

function IRCom:InitialSetup(BindingID)
	LogTrace("IRCom:InitialSetup")
	
	self._BindingID = BindingID

	self._IsInitialized = true
end


function IRCom:GetBindingID()
	return self._BindingID
end


function IRCom:IsInitialized()
	return self._IsInitialized
end


function IRCom:EmitIRData(DataStr)
	C4:SendIR(self._BindingID, DataStr)
end

-------------
