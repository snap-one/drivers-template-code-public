--[[=============================================================================
    File is: receiver_reports.lua

    Copyright 2021 Snap One LLC. All Rights Reserved.
	
	Routines to report information that we have received from the device.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.receiver_reports = "2021.09.09"
end


---------------------------------------------------------------------------------------


function ReceiverReport_PowerOn()
	TheReceiver:PowerFlagIs(true)
end

function ReceiverReport_PowerOff()
	TheReceiver:PowerFlagIs(false)
end

function ReceiverReport_InputOutputChanged(OutputName, InputName)
	TheReceiver:AssignInputOutput(OutputName, InputName)
end


function ReceiverReport_VolumeLevel(OutputName, VolLevel)
	TheReceiver:SetVolumeLevel(OutputName, VolLevel)
end

function ReceiverReport_MuteState(OutputName, MutedFlag)
	TheReceiver:SetMuteState(OutputName, MutedFlag)
end

function ReceiverReport_LoudnessState(OutputName, LoudnessFlag)
	TheReceiver:SetLoudnessState(OutputName, LoudnessFlag)
end

function ReceiverReport_TrebleLevel(OutputName, TrebleLevel)
	TheReceiver:SetTrebleLevel(OutputName, TrebleLevel)
end

function ReceiverReport_BassLevel(OutputName, BassLevel)
	TheReceiver:SetBassLevel(OutputName, BassLevel)
end

function ReceiverReport_BalanceLevel(OutputName, BalanceLevel)
	TheReceiver:SetBalanceLevel(OutputName, BalanceLevel)
end

function ReceiverReport_SurroundMode(OutputName, SurroundMode)
	TheReceiver:SetSurroundMode(OutputName, SurroundMode)
end



