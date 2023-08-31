--[[=============================================================================
    File is: satellite_reports.lua

    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.satellite_reports = "2018.03.08"
end


---------------------------------------------------------------------------------------


function SatelliteReport_PowerOn()
	TheSatellite:SetPowerOnFlag(true)
end

function SatelliteReport_PowerOff()
	TheSatellite:SetPowerOnFlag(false)
end

function SatelliteReport_Playing()
	TheSatellite:SetCurrentState(SAT_STATE_PLAY)
end

function SatelliteReport_Pause()
	TheSatellite:SetCurrentState(SAT_STATE_PAUSE)
end

function SatelliteReport_Stop()
	TheSatellite:SetCurrentState(SAT_STATE_STOP)
end

function SatelliteReport_Record()
	TheSatellite:SetCurrentState(SAT_STATE_RECORD)
end

function SatelliteReport_Channel(Channel)
	TheSatellite:GetCurrentChannel(Channel)
end

function SatelliteReport_MediaInfo(MediaInfo)
	TheSatellite:SetCurrentMediaInfo(MediaInfo)
end



