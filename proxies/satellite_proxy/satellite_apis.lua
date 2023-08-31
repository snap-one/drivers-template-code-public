--[[=============================================================================
    File is: satellite_apis.lua

    Copyright 2018 Control4 Corporation. All Rights Reserved.
	
	API calls for developers using satellite template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.satellite_apis = "2018.03.08"
end

--==================================================================

function IsPlaying()
	return TheSatellite:IsPlaying()
end

function IsStopped()
	return TheSatellite:IsStopped()
end


function IsPaused()
	return TheSatellite:IsPaused()
end


function IsRecording()
	return TheSatellite:IsRecording()
end


function GetCurrentChannel()
	return TheSatellite:GetCurrentChannel()
end


function GetCurrentMediaInfo()
	return TheSatellite:GetCurrentMediaInfo()
end




