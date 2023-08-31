--[[=============================================================================
    File is: avswitch_communicator.lua

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.avswitch_proxy_communicator = "2023.05.25"
end

function AVSwitchCom_On()
	LogTrace("AVSwitchCom_On")
	LogInfo("AVSwitch On Not Implemented")	-- default
end

function AVSwitchCom_Off()
	LogTrace("AVSwitchCom_Off")
	LogInfo("AVSwitch Off Not Implemented")	-- default
end

function AVSwitchCom_SetInput(OutputName, InputName, ConnectType, AdditionalInfo)
	LogTrace("AVSwitchCom_SetInput %s <- %s (%s)", OutputName, InputName, ConnectType)
	LogDebug(AdditionalInfo)
	LogInfo("AVSwitch Set Input Not Implemented")	-- default
end

function AVSwitchCom_ConnectOutput(OutputName, ConnectType, AdditionalInfo)
	LogTrace("AVSwitchCom_ConnectOutput %s (%s)", OutputName, ConnectType)
	LogDebug(AdditionalInfo)
	LogInfo("AVSwitch Connect Output Not Implemented")	-- default
end

function AVSwitchCom_DisconnectOutput(OutputName, ConnectType, AdditionalInfo)
	LogTrace("AVSwitchCom_DisconnectOutput %s (%s)", OutputName, ConnectType)
	LogDebug(AdditionalInfo)
	LogInfo("AVSwitch Disconnect Output Not Implemented")	-- default
end


function AVSwitchCom_SetCurrentVolume(OutputName, VolumeLevel)
	LogTrace("AVSwitchCom_SetCurrentVolume  %s -> %s", OutputName, VolumeLevel)
	LogInfo("AVSwitch Set Volume Not Implemented")	-- default
end

function AVSwitchCom_PulseVolumeUp(OutputName)
	LogTrace("AVSwitchCom_PulseVolumeUp for %s", OutputName)
	LogInfo("AVSwitch Pulse Volume Up Not Implemented")	-- default
end

function AVSwitchCom_StartVolumeUp(OutputName)
	LogTrace("AVSwitchCom_StartVolumeUp for %s", OutputName)
	LogInfo("AVSwitch Start Volume Up Not Implemented")	-- default
end

function AVSwitchCom_StopVolumeUp(OutputName)
	LogTrace("AVSwitchCom_StopVolumeUp for %s", OutputName)
	LogInfo("AVSwitch Stop Volume Up Not Implemented")	-- default
end

function AVSwitchCom_PulseVolumeDown(OutputName)
	LogTrace("AVSwitchCom_PulseVolumeDown for %s", OutputName)
	LogInfo("AVSwitch Pulse Volume Down Not Implemented")	-- default
end

function AVSwitchCom_StartVolumeDown(OutputName)
	LogTrace("AVSwitchCom_StartVolumeDown for %s", OutputName)
	LogInfo("AVSwitch Start Volume Down Not Implemented")	-- default
end

function AVSwitchCom_StopVolumeDown(OutputName)
	LogTrace("AVSwitchCom_StopVolumeDown for %s", OutputName)
	LogInfo("AVSwitch Stop Volume Down Not Implemented")	-- default
end


function AVSwitchCom_SetCurrentTreble(OutputName, TrebleLevel)
	LogTrace("AVSwitchCom_SetCurrentTreble  %s -> %s", OutputName, TrebleLevel)
	LogInfo("AVSwitch Set Treble Not Implemented")	-- default
end

function AVSwitchCom_PulseTrebleUp(OutputName)
	LogTrace("AVSwitchCom_PulseTrebleUp for %s", OutputName)
	LogInfo("AVSwitch Pulse Treble Up Not Implemented")	-- default
end

function AVSwitchCom_StartTrebleUp(OutputName)
	LogTrace("AVSwitchCom_StartTrebleUp for %s", OutputName)
	LogInfo("AVSwitch Start Treble Up Not Implemented")	-- default
end

function AVSwitchCom_StopTrebleUp(OutputName)
	LogTrace("AVSwitchCom_StopTrebleUp for %s", OutputName)
	LogInfo("AVSwitch Stop Treble Up Not Implemented")	-- default
end

function AVSwitchCom_PulseTrebleDown(OutputName)
	LogTrace("AVSwitchCom_PulseTrebleDown for %s", OutputName)
	LogInfo("AVSwitch Pulse Treble Down Not Implemented")	-- default
end

function AVSwitchCom_StartTrebleDown(OutputName)
	LogTrace("AVSwitchCom_StartTrebleDown for %s", OutputName)
	LogInfo("AVSwitch Start Treble Down Not Implemented")	-- default
end

function AVSwitchCom_StopTrebleDown(OutputName)
	LogTrace("AVSwitchCom_StopTrebleDown for %s", OutputName)
	LogInfo("AVSwitch Stop Treble Down Not Implemented")	-- default
end


function AVSwitchCom_SetCurrentBass(OutputName, BassLevel)
	LogTrace("AVSwitchCom_SetCurrentBass  %s -> %s", OutputName, BassLevel)
	LogInfo("AVSwitch Set Bass Not Implemented")	-- default
end

function AVSwitchCom_PulseBassUp(OutputName)
	LogTrace("AVSwitchCom_PulseBassUp for %s", OutputName)
	LogInfo("AVSwitch Pulse Bass Up Not Implemented")	-- default
end

function AVSwitchCom_StartBassUp(OutputName)
	LogTrace("AVSwitchCom_StartBassUp for %s", OutputName)
	LogInfo("AVSwitch Start Bass Up Not Implemented")	-- default
end

function AVSwitchCom_StopBassUp(OutputName)
	LogTrace("AVSwitchCom_StopBassUp for %s", OutputName)
	LogInfo("AVSwitch Stop Bass Up Not Implemented")	-- default
end

function AVSwitchCom_PulseBassDown(OutputName)
	LogTrace("AVSwitchCom_PulseBassDown for %s", OutputName)
	LogInfo("AVSwitch Pulse Bass Down Not Implemented")	-- default
end

function AVSwitchCom_StartBassDown(OutputName)
	LogTrace("AVSwitchCom_StartBassDown for %s", OutputName)
	LogInfo("AVSwitch Start Bass Down Not Implemented")	-- default
end

function AVSwitchCom_StopBassDown(OutputName)
	LogTrace("AVSwitchCom_StopBassDown for %s", OutputName)
	LogInfo("AVSwitch Stop Bass Down Not Implemented")	-- default
end


function AVSwitchCom_SetCurrentBalance(OutputName, BalanceLevel)
	LogTrace("AVSwitchCom_SetCurrentBalance  %s -> %s", OutputName, BalanceLevel)
	LogInfo("AVSwitch Set Balance Not Implemented")	-- default
end

function AVSwitchCom_PulseBalanceUp(OutputName)
	LogTrace("AVSwitchCom_PulseBalanceUp for %s", OutputName)
	LogInfo("AVSwitch Pulse Balance Up Not Implemented")	-- default
end

function AVSwitchCom_StartBalanceUp(OutputName)
	LogTrace("AVSwitchCom_StartBalanceUp for %s", OutputName)
	LogInfo("AVSwitch Start Balance Up Not Implemented")	-- default
end

function AVSwitchCom_StopBalanceUp(OutputName)
	LogTrace("AVSwitchCom_StopBalanceUp for %s", OutputName)
	LogInfo("AVSwitch Stop Balance Up Not Implemented")	-- default
end


function AVSwitchCom_PulseBalanceDown(OutputName)
	LogTrace("AVSwitchCom_PulseBalanceDown for %s", OutputName)
	LogInfo("AVSwitch Pulse Balance Down Not Implemented")	-- default
end

function AVSwitchCom_StartBalanceDown(OutputName)
	LogTrace("AVSwitchCom_StartBalanceDown for %s", OutputName)
	LogInfo("AVSwitch Start Balance Down Not Implemented")	-- default
end

function AVSwitchCom_StopBalanceDown(OutputName)
	LogTrace("AVSwitchCom_StopBalanceDown for %s", OutputName)
	LogInfo("AVSwitch Stop Balance Down Not Implemented")	-- default
end


function AVSwitchCom_MuteOn(OutputName)
	LogTrace("AVSwitchCom_MuteOn for %s", OutputName)
	LogInfo("AVSwitch Mute On Not Implemented")	-- default
end

function AVSwitchCom_MuteOff(OutputName)
	LogTrace("AVSwitchCom_MuteOff for %s", OutputName)
	LogInfo("AVSwitch Mute Off Not Implemented")	-- default
end

function AVSwitchCom_MuteToggle(OutputName)
	LogTrace("AVSwitchCom_MuteToggle for %s", OutputName)
	LogInfo("AVSwitch Mute Toggle Not Implemented")	-- default
end

function AVSwitchCom_LoudnessOn(OutputName)
	LogTrace("AVSwitchCom_LoudnessOn for %s", OutputName)
	LogInfo("AVSwitch Loudness On Not Implemented")	-- default
end

function AVSwitchCom_LoudnessOff(OutputName)
	LogTrace("AVSwitchCom_LoudnessOff for %s", OutputName)
	LogInfo("AVSwitch Loudness Off Not Implemented")	-- default
end

function AVSwitchCom_LoudnessToggle(OutputName)
	LogTrace("AVSwitchCom_LoudnessToggle for %s", OutputName)
	LogInfo("AVSwitch Loudness Toggle Not Implemented")	-- default
end

function AVSwitchCom_Number0()
	LogTrace("AVSwitchCom_Number0")
	LogInfo("AVSwitch Number 0 Not Implemented")	-- default
end

function AVSwitchCom_Number1()
	LogTrace("AVSwitchCom_Number1")
	LogInfo("AVSwitch Number 1 Not Implemented")	-- default
end

function AVSwitchCom_Number2()
	LogTrace("AVSwitchCom_Number2")
	LogInfo("AVSwitch Number 2 Not Implemented")	-- default
end

function AVSwitchCom_Number3()
	LogTrace("AVSwitchCom_Number3")
	LogInfo("AVSwitch Number 3 Not Implemented")	-- default
end

function AVSwitchCom_Number4()
	LogTrace("AVSwitchCom_Number4")
	LogInfo("AVSwitch Number 4 Not Implemented")	-- default
end

function AVSwitchCom_Number5()
	LogTrace("AVSwitchCom_Number5")
	LogInfo("AVSwitch Number 5 Not Implemented")	-- default
end

function AVSwitchCom_Number6()
	LogTrace("AVSwitchCom_Number6")
	LogInfo("AVSwitch Number 6 Not Implemented")	-- default
end

function AVSwitchCom_Number7()
	LogTrace("AVSwitchCom_Number7")
	LogInfo("AVSwitch Number 7 Not Implemented")	-- default
end

function AVSwitchCom_Number8()
	LogTrace("AVSwitchCom_Number8")
	LogInfo("AVSwitch Number 8 Not Implemented")	-- default
end

function AVSwitchCom_Number9()
	LogTrace("AVSwitchCom_Number9")
	LogInfo("AVSwitch Number 9 Not Implemented")	-- default
end

function AVSwitchCom_Star()
	LogTrace("AVSwitchCom_Star")
	LogInfo("AVSwitch Star Not Implemented")	-- default
end

function AVSwitchCom_Pound()
	LogTrace("AVSwitchCom_Pound")
	LogInfo("AVSwitch Pound Not Implemented")	-- default
end


--========== Menu Commands ========================================

function AVSwitchCom_Info()
	LogTrace("AVSwitchCom_Info")
	LogInfo("AVSwitch Info Not Implemented")	-- default
end

function AVSwitchCom_Guide()
	LogTrace("AVSwitchCom_Guide")
	LogInfo("AVSwitch Guide Not Implemented")	-- default
end

function AVSwitchCom_Menu()
	LogTrace("AVSwitchCom_Menu")
	LogInfo("AVSwitch Menu Not Implemented")	-- default
end

function AVSwitchCom_Cancel()
	LogTrace("AVSwitchCom_Cancel")
	LogInfo("AVSwitch Cancel Not Implemented")	-- default
end

function AVSwitchCom_Up()
	LogTrace("AVSwitchCom_Up")
	LogInfo("AVSwitch Up Not Implemented")	-- default
end

function AVSwitchCom_Down()
	LogTrace("AVSwitchCom_Down")
	LogInfo("AVSwitch Down Not Implemented")	-- default
end

function AVSwitchCom_Left()
	LogTrace("AVSwitchCom_Left")
	LogInfo("AVSwitch Left Not Implemented")	-- default
end

function AVSwitchCom_Right()
	LogTrace("AVSwitchCom_Right")
	LogInfo("AVSwitch Right Not Implemented")	-- default
end

function AVSwitchCom_StartDown()
	LogTrace("AVSwitchCom_StartDown")
	LogInfo("AVSwitch StartDown Not Implemented")	-- default
end

function AVSwitchCom_StartUp()
	LogTrace("AVSwitchCom_StartUp")
	LogInfo("AVSwitch StartUp Not Implemented")	-- default
end

function AVSwitchCom_StartLeft()
	LogTrace("AVSwitchCom_StartLeft")
	LogInfo("AVSwitch StartLeft Not Implemented")	-- default
end

function AVSwitchCom_StartRight()
	LogTrace("AVSwitchCom_StartRight")
	LogInfo("AVSwitch StartRight Not Implemented")	-- default
end

function AVSwitchCom_StopDown()
	LogTrace("AVSwitchCom_StopDown")
	LogInfo("AVSwitch StopDown Not Implemented")	-- default
end

function AVSwitchCom_StopUp()
	LogTrace("AVSwitchCom_StopUp")
	LogInfo("AVSwitch StopUp Not Implemented")	-- default
end

function AVSwitchCom_StopLeft()
	LogTrace("AVSwitchCom_StopLeft")
	LogInfo("AVSwitch StopLeft Not Implemented")	-- default
end

function AVSwitchCom_StopRight()
	LogTrace("AVSwitchCom_StopRight")
	LogInfo("AVSwitch StopRight Not Implemented")	-- default
end

function AVSwitchCom_Enter()
	LogTrace("AVSwitchCom_Enter")
	LogInfo("AVSwitch Enter Not Implemented")	-- default
end

function AVSwitchCom_Exit()
	LogTrace("AVSwitchCom_Exit")
	LogInfo("AVSwitch Exit Not Implemented")	-- default
end

function AVSwitchCom_Home()
	LogTrace("AVSwitchCom_Home")
	LogInfo("AVSwitch Home Not Implemented") -- default
end

function AVSwitchCom_Settings()
	LogTrace("AVSwitchCom_Settings")
	LogInfo("AVSwitch Settings Not Implemented") -- default
end

function AVSwitchCom_Recall()
	LogTrace("AVSwitchCom_Recall")
	LogInfo("AVSwitch Recall Not Implemented")	-- default
end

function AVSwitchCom_Close()
	LogTrace("AVSwitchCom_Close")
	LogInfo("AVSwitch Close Not Implemented")	-- default
end

function AVSwitchCom_ProgramA()
	LogTrace("AVSwitchCom_ProgramA")
	LogInfo("AVSwitch ProgramA Not Implemented")	-- default
end

function AVSwitchCom_ProgramB()
	LogTrace("AVSwitchCom_ProgramB")
	LogInfo("AVSwitch ProgramB Not Implemented")	-- default
end

function AVSwitchCom_ProgramC()
	LogTrace("AVSwitchCom_ProgramC")
	LogInfo("AVSwitch ProgramC Not Implemented")	-- default
end

function AVSwitchCom_ProgramD()
	LogTrace("AVSwitchCom_ProgramD")
	LogInfo("AVSwitch ProgramD Not Implemented")	-- default
end

function AVSwitchCom_PageUp()
	LogTrace("AVSwitchCom_PageUp")
	LogInfo("AVSwitch PageUp Not Implemented")	-- default
end

function AVSwitchCom_PageDown()
	LogTrace("AVSwitchCom_PageDown")
	LogInfo("AVSwitch PageDown Not Implemented")	-- default
end

function AVSwitchCom_StartScanFwd()
	LogTrace("AVSwitchCom_StartScanFwd")
	LogInfo("AVSwitch StartScanFwd Not Implemented")	-- default
end

function AVSwitchCom_StartScanRev()
	LogTrace("AVSwitchCom_StartScanRev")
	LogInfo("AVSwitch StartScanRev Not Implemented")	-- default
end

function AVSwitchCom_StopScanFwd()
	LogTrace("AVSwitchCom_StopScanFwd")
	LogInfo("AVSwitch StopScanFwd Not Implemented")	-- default
end

function AVSwitchCom_StopScanRev()
	LogTrace("AVSwitchCom_StopScanRev")
	LogInfo("AVSwitch StopScanRev Not Implemented")	-- default
end


function AVSwitchCom_Play()
	LogTrace("AVSwitchCom_Play")
	LogInfo("AVSwitch Play Not Implemented")	-- default
end

function AVSwitchCom_Stop()
	LogTrace("AVSwitchCom_Stop")
	LogInfo("AVSwitch Stop Not Implemented")	-- default
end

function AVSwitchCom_Pause()
	LogTrace("AVSwitchCom_Pause")
	LogInfo("AVSwitch Pause Not Implemented")	-- default
end

function AVSwitchCom_Record()
	LogTrace("AVSwitchCom_Record")
	LogInfo("AVSwitch Record Not Implemented")	-- default
end

function AVSwitchCom_SkipFwd()
	LogTrace("AVSwitchCom_SkipFwd")
	LogInfo("AVSwitch SkipFwd Not Implemented")	-- default
end

function AVSwitchCom_SkipRev()
	LogTrace("AVSwitchCom_SkipRev")
	LogInfo("AVSwitch SkipRev Not Implemented")	-- default
end

function AVSwitchCom_ScanFwd()
	LogTrace("AVSwitchCom_ScanFwd")
	LogInfo("AVSwitch ScanFwd Not Implemented")	-- default
end

function AVSwitchCom_ScanRev()
	LogTrace("AVSwitchCom_ScanRev")
	LogInfo("AVSwitch ScanRev Not Implemented")	-- default
end

