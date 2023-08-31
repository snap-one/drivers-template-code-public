--[[=============================================================================
    File is: receiver_reports.lua

    Copyright 2023 Snap One LLC. All Rights Reserved.
	
	Routines to report information that we have received from the device.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.avswitch_reports = "2023.05.25"
end


---------------------------------------------------------------------------------------

function AVSwitchReport_PowerState(IsOn)
	TheAVSwitch:PowerSetting(IsOn)
end

function AVSwitchReport_InputOutputChanged(OutputName, InputName, IsAudio, IsVideo)
	TheAVSwitch:AssignInputOutput(OutputName, InputName, IsAudio, IsVideo)
end

function AVSwitchReport_OutputDisconnected(OutputName, IsAudio, IsVideo)
	TheAVSwitch:AssignInputOutput(OutputName, "", IsAudio, IsVideo)
end


function AVSwitchReport_VolumeLevel(OutputName, VolLevel)
	TheAVSwitch:SetVolumeLevel(OutputName, VolLevel)
end

function AVSwitchReport_MuteState(OutputName, MutedFlag)
	TheAVSwitch:SetMuteState(OutputName, MutedFlag)
end

function AVSwitchReport_LoudnessState(OutputName, LoudnessFlag)
	TheAVSwitch:SetLoudnessState(OutputName, LoudnessFlag)
end

function AVSwitchReport_TrebleLevel(OutputName, TrebleLevel)
	TheAVSwitch:SetTrebleLevel(OutputName, TrebleLevel)
end

function AVSwitchReport_BassLevel(OutputName, BassLevel)
	TheAVSwitch:SetBassLevel(OutputName, BassLevel)
end

function AVSwitchReport_BalanceLevel(OutputName, BalanceLevel)
	TheAVSwitch:SetBalanceLevel(OutputName, BalanceLevel)
end



