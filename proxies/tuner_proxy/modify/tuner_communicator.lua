--[[=============================================================================
    File is: tuner_communicator.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tuner_proxy_notifies = "2022.05.12"
end


function TunerCom_On(TunerName)
	LogTrace("TunerCom_On (%s)", TunerName)
	LogInfo("On not implemented")	-- default
end

function TunerCom_Off(TunerName)
	LogTrace("TunerCom_Off (%s)", TunerName)
	LogInfo("Off not implemented")	-- default
end

function TunerCom_PresetUp(TunerName)
	LogTrace("TunerCom_PresetUp (%s)", TunerName)
	LogInfo("PresetUp not implemented")	-- default
end

function TunerCom_PresetDown(TunerName)
	LogTrace("TunerCom_PresetDown (%s)", TunerName)
	LogInfo("PresetDown not implemented")	-- default
end

function TunerCom_SetPreset(PresetID, TunerName)
	LogTrace("TunerCom_SetPreset: %d (%s)", PresetID, TunerName)
	LogInfo("SetPreset not implemented")	-- default
end

function TunerCom_SkipForward(TunerName)
	LogTrace("TunerCom_SkipForward (%s)", TunerName)
	LogInfo("SkipForward not implemented")	-- default
end

function TunerCom_SkipReverse(TunerName)
	LogTrace("TunerCom_SkipReverse (%s)", TunerName)
	LogInfo("SkipReverse not implemented")	-- default
end

function TunerCom_ScanForward(TunerName)
	LogTrace("TunerCom_ScanForward (%s)", TunerName)
	LogInfo("ScanForward not implemented")	-- default
end

function TunerCom_ScanReverse(TunerName)
	LogTrace("TunerCom_ScanReverse (%s)", TunerName)
	LogInfo("ScanReverse not implemented")	-- default
end

function TunerCom_SetInput(TargInput, TunerName)
	LogTrace("TunerCom_SetInput %s (%s)", TargInput, TunerName)
	LogInfo("Set Input not implemented")	-- default
end

function TunerCom_InputToggle(TunerName)
	LogTrace("TunerCom_InputToggle (%s)", TunerName)
	LogInfo("InputToggle not implemented")	-- default
end

function TunerCom_SetChannel(ChannelStr, TargBand, TunerName)
	LogTrace("TunerCom_SetChannel %s  %s (%s)", ChannelStr, TargBand, TunerName)
	LogInfo("Set Channel not implemented")	-- default
end

function TunerCom_StartChannelUp(TunerName)
	LogTrace("TunerCom_StartChannelUp (%s)", TunerName)
	LogInfo("StartChannelUp not implemented")	-- default
end

function TunerCom_StopChannelUp(TunerName)
	LogTrace("TunerCom_StopChannelUp (%s)", TunerName)
	LogInfo("StopChannelUp not implemented")	-- default
end

function TunerCom_StartChannelDown(TunerName)
	LogTrace("TunerCom_StartChannelDown (%s)", TunerName)
	LogInfo("StartChannelDown not implemented")	-- default
end

function TunerCom_StopChannelDown(TunerName)
	LogTrace("TunerCom_StopChannelDown (%s)", TunerName)
	LogInfo("StopChannelDown not implemented")	-- default
end

function TunerCom_PulseChannelUp(TunerName)
	LogTrace("TunerCom_PulseChannelUp (%s)", TunerName)
	LogInfo("PulseChannelUp not implemented")	-- default
end

function TunerCom_PulseChannelDown(TunerName)
	LogTrace("TunerCom_PulseChannelDown (%s)", TunerName)
	LogInfo("PulseChannelDown not implemented")	-- default
end

function TunerCom_SendCharacter(TargChar, TunerName)
	LogTrace("TunerCom_SendCharacter (%s)", TunerName)
	LogInfo("SendCharacter not implemented")	-- default
end


function TunerCom_Info(TunerName)
	LogTrace("TunerCom_Info (%s)", TunerName)
	LogInfo("Tuner Info Not Implemented")	-- default
end

function TunerCom_Guide(TunerName)
	LogTrace("TunerCom_Guide (%s)", TunerName)
	LogInfo("Tuner Guide Not Implemented")	-- default
end

function TunerCom_Menu(TunerName)
	LogTrace("TunerCom_Menu (%s)", TunerName)
	LogInfo("Tuner Menu Not Implemented")	-- default
end

function TunerCom_Cancel(TunerName)
	LogTrace("TunerCom_Cancel (%s)", TunerName)
	LogInfo("Tuner Cancel Not Implemented")	-- default
end

function TunerCom_Up(TunerName)
	LogTrace("TunerCom_Up (%s)", TunerName)
	LogInfo("Tuner Up Not Implemented")	-- default
end

function TunerCom_Down(TunerName)
	LogTrace("TunerCom_Down (%s)", TunerName)
	LogInfo("Tuner Down Not Implemented")	-- default
end

function TunerCom_Left(TunerName)
	LogTrace("TunerCom_Left (%s)", TunerName)
	LogInfo("Tuner Left Not Implemented")	-- default
end

function TunerCom_Right(TunerName)
	LogTrace("TunerCom_Right (%s)", TunerName)
	LogInfo("Tuner Right Not Implemented")	-- default
end

function TunerCom_StartDown(TunerName)
	LogTrace("TunerCom_StartDown (%s)", TunerName)
	LogInfo("Tuner StartDown Not Implemented")	-- default
end

function TunerCom_StartUp(TunerName)
	LogTrace("TunerCom_StartUp (%s)", TunerName)
	LogInfo("Tuner StartUp Not Implemented")	-- default
end

function TunerCom_StartLeft(TunerName)
	LogTrace("TunerCom_StartLeft (%s)", TunerName)
	LogInfo("Tuner StartLeft Not Implemented")	-- default
end

function TunerCom_StartRight(TunerName)
	LogTrace("TunerCom_StartRight (%s)", TunerName)
	LogInfo("Tuner StartRight Not Implemented")	-- default
end

function TunerCom_StopDown(TunerName)
	LogTrace("TunerCom_StopDown (%s)", TunerName)
	LogInfo("Tuner StopDown Not Implemented")	-- default
end

function TunerCom_StopUp(TunerName)
	LogTrace("TunerCom_StopUp (%s)", TunerName)
	LogInfo("Tuner StopUp Not Implemented")	-- default
end

function TunerCom_StopLeft(TunerName)
	LogTrace("TunerCom_StopLeft (%s)", TunerName)
	LogInfo("Tuner StopLeft Not Implemented")	-- default
end

function TunerCom_StopRight(TunerName)
	LogTrace("TunerCom_StopRight (%s)", TunerName)
	LogInfo("Tuner StopRight Not Implemented")	-- default
end

function TunerCom_Enter(TunerName)
	LogTrace("TunerCom_Enter (%s)", TunerName)
	LogInfo("Tuner Enter Not Implemented")	-- default
end

function TunerCom_Exit(TunerName)
	LogTrace("TunerCom_Exit (%s)", TunerName)
	LogInfo("Tuner Exit Not Implemented")	-- default
end

function TunerCom_Home()
	LogTrace("TunerCom_Home")
	LogInfo("Tuner Home Not Implemented") -- default
end

function TunerCom_Settings()
	LogTrace("TunerCom_Settings")
	LogInfo("Tuner Settings Not Implemented") -- default
end

function TunerCom_Recall(TunerName)
	LogTrace("TunerCom_Recall (%s)", TunerName)
	LogInfo("Tuner Recall Not Implemented")	-- default
end

function TunerCom_Close(TunerName)
	LogTrace("TunerCom_Close (%s)", TunerName)
	LogInfo("Tuner Close Not Implemented")	-- default
end

function TunerCom_ProgramA(TunerName)
	LogTrace("TunerCom_ProgramA (%s)", TunerName)
	LogInfo("Tuner ProgramA Not Implemented")	-- default
end

function TunerCom_ProgramB(TunerName)
	LogTrace("TunerCom_ProgramB (%s)", TunerName)
	LogInfo("Tuner ProgramB Not Implemented")	-- default
end

function TunerCom_ProgramC(TunerName)
	LogTrace("TunerCom_ProgramC (%s)", TunerName)
	LogInfo("Tuner ProgramC Not Implemented")	-- default
end

function TunerCom_ProgramD(TunerName)
	LogTrace("TunerCom_ProgramD (%s)", TunerName)
	LogInfo("Tuner ProgramD Not Implemented")	-- default
end

function TunerCom_PageUp(TunerName)
	LogTrace("TunerCom_PageUp (%s)", TunerName)
	LogInfo("Tuner PageUp Not Implemented")	-- default
end

function TunerCom_PageDown(TunerName)
	LogTrace("TunerCom_PageDown (%s)", TunerName)
	LogInfo("Tuner PageDown Not Implemented")	-- default
end

