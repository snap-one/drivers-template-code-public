--[[=============================================================================
    File is: camera_apis.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
	
	API calls for developers using camera template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_status = "2022.09.28"
end

--==================================================================
--==================================================================

function GetCameraID()
	return TheCamera:GetID()
end

function SetCameraID(NewID)
	TheCamera:SetID(NewID)
end

----------

function GetPTZIncrement()
	return (TheCamera ~= nil) and TheCamera:GetPTZIncrement() or 1
end

function SetPTZIncrement(NewIncrement)
	if (TheCamera ~= nil) then 
		TheCamera:SetPTZIncrement(NewIncrement) 
	end
end

----------

function HasEPTZ()
	return TheCamera:HasEPTZ()
end

function SetEPTZFlag(FlagValue)
	TheCamera:SetEPTZ(FlagValue)
end

----------

function HasAutoFocus()
	return TheCamera:HasAutoFocus()
end

function SetAutoFocusFlag(FlagValue)
	TheCamera:SetAutoFocus(FlagValue)
end

----------

