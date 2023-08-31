--[[=============================================================================
    File is: tv_reports.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
	
	Routines to report information that we have received from the device.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tv_reports = "2021.12.15"
end


---------------------------------------------------------------------------------------


function TvReport_PowerOn()
	TheTv:PowerFlagIs(true)
end

function TvReport_PowerOff()
	TheTv:PowerFlagIs(false)
end


function TvReport_Channel(Channel)
	TheTv:CurrentChannelIs(Channel)
end

function TvReport_Input(InputName)
	TheTv:SetInput(InputName)
end


function TvReport_VolumeLevel(VolLevel)
	TheTv:VolumeLevelIs(VolLevel)
end

function TvReport_MuteState(MutedFlag)
	TheTv:MuteStateIs(MutedFlag)
end

function TvReport_LoudnessState(LoudnessFlag)
	TheTv:LoudnessStateIs(LoudnessFlag)
end

function TvReport_BassLevel(BassLevel)
	TheTv:BassLevelIs(BassLevel)
end

function TvReport_TrebleLevel(TrebleLevel)
	TheTv:TrebleLevelIs(TrebleLevel)
end

function TvReport_BalanceLevel(BalanceLevel)
	TheTv:BalanceLevelIs(BalanceLevel)
end



