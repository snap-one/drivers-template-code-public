--[[=============================================================================
	File is: ir_apis.lua
	Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.ir_apis = "2022.03.22"
end


function InitializeIRCommunication(IRBindingID)
	LogTrace("InitializeIRCommunication")
	TheIRCom:InitialSetup(IRBindingID)
end

function IRInitialized()
	return TheIRCom:IsInitialized()
end


--==================================================================

function EmitIR(IRData)
	TheIRCom:EmitIRData(IRData)
end

