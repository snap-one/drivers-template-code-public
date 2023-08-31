--[[=============================================================================
    File is: receiver_communicator.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.receiver_proxy_notifies = "2022.05.12"
end



function ReceiverCom_On()
	LogTrace("ReceiverCom_On")
	LogInfo("Receiver On Not Implemented")	-- default
end

function ReceiverCom_Off()
	LogTrace("ReceiverCom_Off")
	LogInfo("Receiver Off Not Implemented")	-- default
end

function ReceiverCom_SetInput(OutputName, InputName, ConnectionType, AdditionalInfo)
	LogTrace("ReceiverCom_SetInput %s <- %s (%s)", OutputName, InputName, ConnectionType)
	LogInfo(AdditionalInfo)
	LogInfo("Receiver Set Input Not Implemented")	-- default
end

function ReceiverCom_ConnectOutput(OutputName)
	LogTrace("ReceiverCom_ConnectOutput %s", OutputName)
	LogInfo("Receiver Connect Output Not Implemented")	-- default
end

function ReceiverCom_DisconnectOutput(OutputName)
	LogTrace("ReceiverCom_DisconnectOutput %s", OutputName)
	LogInfo("Receiver Disconnect Output Not Implemented")	-- default
end



function ReceiverCom_SetSurroundMode(OutputName, SurroundModeID)
	LogTrace("ReceiverCom_SetSurroundMode %s -> %s", OutputName, SurroundModeID)
	LogInfo("Receiver Set Surround Mode Not Implemented")	-- default
end

function ReceiverCom_SetCurrentVolume(OutputName, VolumeLevel)
	LogTrace("ReceiverCom_SetCurrentVolume  %s -> %s", OutputName, VolumeLevel)
	LogInfo("Receiver Set Volume Not Implemented")	-- default
end

function ReceiverCom_PulseVolumeUp(OutputName)
	LogTrace("ReceiverCom_PulseVolumeUp for %s", OutputName)
	LogInfo("Receiver Pulse Volume Up Not Implemented")	-- default
end

function ReceiverCom_StartVolumeUp(OutputName)
	LogTrace("ReceiverCom_StartVolumeUp for %s", OutputName)
	LogInfo("Receiver Start Volume Up Not Implemented")	-- default
end

function ReceiverCom_StopVolumeUp(OutputName)
	LogTrace("ReceiverCom_StopVolumeUp for %s", OutputName)
	LogInfo("Receiver Stop Volume Up Not Implemented")	-- default
end

function ReceiverCom_PulseVolumeDown(OutputName)
	LogTrace("ReceiverCom_PulseVolumeDown for %s", OutputName)
	LogInfo("Receiver Pulse Volume Down Not Implemented")	-- default
end

function ReceiverCom_StartVolumeDown(OutputName)
	LogTrace("ReceiverCom_StartVolumeDown for %s", OutputName)
	LogInfo("Receiver Start Volume Down Not Implemented")	-- default
end

function ReceiverCom_StopVolumeDown(OutputName)
	LogTrace("ReceiverCom_StopVolumeDown for %s", OutputName)
	LogInfo("Receiver Stop Volume Down Not Implemented")	-- default
end


function ReceiverCom_SetCurrentTreble(OutputName, TrebleLevel)
	LogTrace("ReceiverCom_SetCurrentTreble  %s -> %s", OutputName, TrebleLevel)
	LogInfo("Receiver Set Treble Not Implemented")	-- default
end

function ReceiverCom_PulseTrebleUp(OutputName)
	LogTrace("ReceiverCom_PulseTrebleUp for %s", OutputName)
	LogInfo("Receiver Pulse Treble Up Not Implemented")	-- default
end

function ReceiverCom_PulseTrebleDown(OutputName)
	LogTrace("ReceiverCom_PulseTrebleDown for %s", OutputName)
	LogInfo("Receiver Pulse Treble Down Not Implemented")	-- default
end

function ReceiverCom_StartTrebleUp(OutputName)
	LogTrace("ReceiverCom_StartTrebleUp for %s", OutputName)
	LogInfo("Receiver Start Treble Up Not Implemented")	-- default
end

function ReceiverCom_StopTrebleUp(OutputName)
	LogTrace("ReceiverCom_StopTrebleUp for %s", OutputName)
	LogInfo("Receiver Stop Treble Up Not Implemented")	-- default
end

function ReceiverCom_StartTrebleDown(OutputName)
	LogTrace("ReceiverCom_StartTrebleDown for %s", OutputName)
	LogInfo("Receiver Start Treble Down Not Implemented")	-- default
end

function ReceiverCom_StopTrebleDown(OutputName)
	LogTrace("ReceiverCom_StopTrebleDown for %s", OutputName)
	LogInfo("Receiver Stop Treble Down Not Implemented")	-- default
end


function ReceiverCom_SetCurrentBass(OutputName, BassLevel)
	LogTrace("ReceiverCom_SetCurrentBass  %s -> %s", OutputName, BassLevel)
	LogInfo("Receiver Set Bass Not Implemented")	-- default
end

function ReceiverCom_PulseBassUp(OutputName)
	LogTrace("ReceiverCom_PulseBassUp for %s", OutputName)
	LogInfo("Receiver Pulse Bass Up Not Implemented")	-- default
end

function ReceiverCom_PulseBassDown(OutputName)
	LogTrace("ReceiverCom_PulseBassDown for %s", OutputName)
	LogInfo("Receiver Pulse Bass Down Not Implemented")	-- default
end

function ReceiverCom_StartBassUp(OutputName)
	LogTrace("ReceiverCom_StartBassUp for %s", OutputName)
	LogInfo("Receiver Start Bass Up Not Implemented")	-- default
end

function ReceiverCom_StopBassUp(OutputName)
	LogTrace("ReceiverCom_StopBassUp for %s", OutputName)
	LogInfo("Receiver Stop Bass Up Not Implemented")	-- default
end

function ReceiverCom_StartBassDown(OutputName)
	LogTrace("ReceiverCom_StartBassDown for %s", OutputName)
	LogInfo("Receiver Start Bass Down Not Implemented")	-- default
end

function ReceiverCom_StopBassDown(OutputName)
	LogTrace("ReceiverCom_StopBassDown for %s", OutputName)
	LogInfo("Receiver Stop Bass Down Not Implemented")	-- default
end


function ReceiverCom_SetCurrentBalance(OutputName, BalanceLevel)
	LogTrace("ReceiverCom_SetCurrentBalance  %s -> %s", OutputName, BalanceLevel)
	LogInfo("Receiver Set Balance Not Implemented")	-- default
end

function ReceiverCom_PulseBalanceUp(OutputName)
	LogTrace("ReceiverCom_PulseBalanceUp for %s", OutputName)
	LogInfo("Receiver Pulse Balance Up Not Implemented")	-- default
end

function ReceiverCom_PulseBalanceDown(OutputName)
	LogTrace("ReceiverCom_PulseBalanceDown for %s", OutputName)
	LogInfo("Receiver Pulse Balance Down Not Implemented")	-- default
end

function ReceiverCom_StartBalanceUp(OutputName)
	LogTrace("ReceiverCom_StartBalanceUp for %s", OutputName)
	LogInfo("Receiver Start Balance Up Not Implemented")	-- default
end

function ReceiverCom_StopBalanceUp(OutputName)
	LogTrace("ReceiverCom_StopBalanceUp for %s", OutputName)
	LogInfo("Receiver Stop Balance Up Not Implemented")	-- default
end

function ReceiverCom_StartBalanceDown(OutputName)
	LogTrace("ReceiverCom_StartBalanceDown for %s", OutputName)
	LogInfo("Receiver Start Balance Down Not Implemented")	-- default
end

function ReceiverCom_StopBalanceDown(OutputName)
	LogTrace("ReceiverCom_StopBalanceDown for %s", OutputName)
	LogInfo("Receiver Stop Balance Down Not Implemented")	-- default
end


function ReceiverCom_MuteOn(OutputName)
	LogTrace("ReceiverCom_MuteOn for %s", OutputName)
	LogInfo("Receiver Mute On Not Implemented")	-- default
end

function ReceiverCom_MuteOff(OutputName)
	LogTrace("ReceiverCom_MuteOff for %s", OutputName)
	LogInfo("Receiver Mute Off Not Implemented")	-- default
end

function ReceiverCom_MuteToggle(OutputName)
	LogTrace("ReceiverCom_MuteToggle for %s", OutputName)
	LogInfo("Receiver Mute Toggle Not Implemented")	-- default
end

function ReceiverCom_LoudnessOn(OutputName)
	LogTrace("ReceiverCom_LoudnessOn for %s", OutputName)
	LogInfo("Receiver Loudness On Not Implemented")	-- default
end

function ReceiverCom_LoudnessOff(OutputName)
	LogTrace("ReceiverCom_LoudnessOff for %s", OutputName)
	LogInfo("Receiver Loudness Off Not Implemented")	-- default
end

function ReceiverCom_LoudnessToggle(OutputName)
	LogTrace("ReceiverCom_LoudnessToggle for %s", OutputName)
	LogInfo("Receiver Loudness Toggle Not Implemented")	-- default
end

function ReceiverCom_Number0()
	LogTrace("ReceiverCom_Number0")
	LogInfo("Receiver Number 0 Not Implemented")	-- default
end

function ReceiverCom_Number1()
	LogTrace("ReceiverCom_Number1")
	LogInfo("Receiver Number 1 Not Implemented")	-- default
end

function ReceiverCom_Number2()
	LogTrace("ReceiverCom_Number2")
	LogInfo("Receiver Number 2 Not Implemented")	-- default
end

function ReceiverCom_Number3()
	LogTrace("ReceiverCom_Number3")
	LogInfo("Receiver Number 3 Not Implemented")	-- default
end

function ReceiverCom_Number4()
	LogTrace("ReceiverCom_Number4")
	LogInfo("Receiver Number 4 Not Implemented")	-- default
end

function ReceiverCom_Number5()
	LogTrace("ReceiverCom_Number5")
	LogInfo("Receiver Number 5 Not Implemented")	-- default
end

function ReceiverCom_Number6()
	LogTrace("ReceiverCom_Number6")
	LogInfo("Receiver Number 6 Not Implemented")	-- default
end

function ReceiverCom_Number7()
	LogTrace("ReceiverCom_Number7")
	LogInfo("Receiver Number 7 Not Implemented")	-- default
end

function ReceiverCom_Number8()
	LogTrace("ReceiverCom_Number8")
	LogInfo("Receiver Number 8 Not Implemented")	-- default
end

function ReceiverCom_Number9()
	LogTrace("ReceiverCom_Number9")
	LogInfo("Receiver Number 9 Not Implemented")	-- default
end

function ReceiverCom_Dash()
	LogTrace("ReceiverCom_Dash")
	LogInfo("Receiver Dash Not Implemented")	-- default
end

function ReceiverCom_Star()
	LogTrace("ReceiverCom_Star")
	LogInfo("Receiver Star Not Implemented")	-- default
end

function ReceiverCom_Pound()
	LogTrace("ReceiverCom_Pound")
	LogInfo("Receiver Pound Not Implemented")	-- default
end


--========== Menu Commands ========================================

function ReceiverCom_Info()
	LogTrace("ReceiverCom_Info")
	LogInfo("Receiver Info Not Implemented")	-- default
end

function ReceiverCom_Guide()
	LogTrace("ReceiverCom_Guide")
	LogInfo("Receiver Guide Not Implemented")	-- default
end

function ReceiverCom_Menu()
	LogTrace("ReceiverCom_Menu")
	LogInfo("Receiver Menu Not Implemented")	-- default
end

function ReceiverCom_Play()
	LogTrace("ReceiverCom_Play")
	LogInfo("Receiver Play Not Implemented")	-- default
end

function ReceiverCom_Stop()
	LogTrace("ReceiverCom_Stop")
	LogInfo("Receiver Stop Not Implemented")	-- default
end

function ReceiverCom_Pause()
	LogTrace("ReceiverCom_Pause")
	LogInfo("Receiver Pause Not Implemented")	-- default
end

function ReceiverCom_Record()
	LogTrace("ReceiverCom_Record")
	LogInfo("Receiver Record Not Implemented")	-- default
end

function ReceiverCom_Eject()
	LogTrace("ReceiverCom_Eject")
	LogInfo("Receiver Eject Not Implemented")	-- default
end

function ReceiverCom_Close()
	LogTrace("ReceiverCom_Close")
	LogInfo("Receiver Close Not Implemented")	-- default
end

function ReceiverCom_SkipFwd()
	LogTrace("ReceiverCom_SkipFwd")
	LogInfo("Receiver Skip Forward Not Implemented")	-- default
end

function ReceiverCom_SkipRev()
	LogTrace("ReceiverCom_SkipRev")
	LogInfo("Receiver Skip Reverse Not Implemented")	-- default
end

function ReceiverCom_ScanFwd()
	LogTrace("ReceiverCom_ScanFwd")
	LogInfo("Receiver Scan Forward Not Implemented")	-- default
end

function ReceiverCom_ScanRev()
	LogTrace("ReceiverCom_ScanRev")
	LogInfo("Receiver Scan Reverse Not Implemented")	-- default
end

function ReceiverCom_Cancel()
	LogTrace("ReceiverCom_Cancel")
	LogInfo("Receiver Cancel Not Implemented")	-- default
end

function ReceiverCom_Up()
	LogTrace("ReceiverCom_Up")
	LogInfo("Receiver Up Not Implemented")	-- default
end

function ReceiverCom_Down()
	LogTrace("ReceiverCom_Down")
	LogInfo("Receiver Down Not Implemented")	-- default
end

function ReceiverCom_Left()
	LogTrace("ReceiverCom_Left")
	LogInfo("Receiver Left Not Implemented")	-- default
end

function ReceiverCom_Right()
	LogTrace("ReceiverCom_Right")
	LogInfo("Receiver Right Not Implemented")	-- default
end

function ReceiverCom_StartDown()
	LogTrace("ReceiverCom_StartDown")
	LogInfo("Receiver StartDown Not Implemented")	-- default
end

function ReceiverCom_StartUp()
	LogTrace("ReceiverCom_StartUp")
	LogInfo("Receiver StartUp Not Implemented")	-- default
end

function ReceiverCom_StartLeft()
	LogTrace("ReceiverCom_StartLeft")
	LogInfo("Receiver StartLeft Not Implemented")	-- default
end

function ReceiverCom_StartRight()
	LogTrace("ReceiverCom_StartRight")
	LogInfo("Receiver StartRight Not Implemented")	-- default
end

function ReceiverCom_StopDown()
	LogTrace("ReceiverCom_StopDown")
	LogInfo("Receiver StopDown Not Implemented")	-- default
end

function ReceiverCom_StopUp()
	LogTrace("ReceiverCom_StopUp")
	LogInfo("Receiver StopUp Not Implemented")	-- default
end

function ReceiverCom_StopLeft()
	LogTrace("ReceiverCom_StopLeft")
	LogInfo("Receiver StopLeft Not Implemented")	-- default
end

function ReceiverCom_StopRight()
	LogTrace("ReceiverCom_StopRight")
	LogInfo("Receiver StopRight Not Implemented")	-- default
end

function ReceiverCom_Enter()
	LogTrace("ReceiverCom_Enter")
	LogInfo("Receiver Enter Not Implemented")	-- default
end

function ReceiverCom_Exit()
	LogTrace("ReceiverCom_Exit")
	LogInfo("Receiver Exit Not Implemented")	-- default
end

function ReceiverCom_Home()
	LogTrace("ReceiverCom_Home")
	LogInfo("Receiver Home Not Implemented") -- default
end

function ReceiverCom_Settings()
	LogTrace("ReceiverCom_Settings")
	LogInfo("Receiver Settings Not Implemented") -- default
end

function ReceiverCom_Recall()
	LogTrace("ReceiverCom_Recall")
	LogInfo("Receiver Recall Not Implemented")	-- default
end

function ReceiverCom_Close()
	LogTrace("ReceiverCom_Close")
	LogInfo("Receiver Close Not Implemented")	-- default
end

function ReceiverCom_ProgramA()
	LogTrace("ReceiverCom_ProgramA")
	LogInfo("Receiver ProgramA Not Implemented")	-- default
end

function ReceiverCom_ProgramB()
	LogTrace("ReceiverCom_ProgramB")
	LogInfo("Receiver ProgramB Not Implemented")	-- default
end

function ReceiverCom_ProgramC()
	LogTrace("ReceiverCom_ProgramC")
	LogInfo("Receiver ProgramC Not Implemented")	-- default
end

function ReceiverCom_ProgramD()
	LogTrace("ReceiverCom_ProgramD")
	LogInfo("Receiver ProgramD Not Implemented")	-- default
end

function ReceiverCom_PageUp()
	LogTrace("ReceiverCom_PageUp")
	LogInfo("Receiver PageUp Not Implemented")	-- default
end

function ReceiverCom_PageDown()
	LogTrace("ReceiverCom_PageDown")
	LogInfo("Receiver PageDown Not Implemented")	-- default
end


function ReceiverCom_StartScanFwd()
	LogTrace("ReceiverCom_StartScanFwd")
	LogInfo("Receiver StartScanFwd Not Implemented")	-- default
end

function ReceiverCom_StartScanRev()
	LogTrace("ReceiverCom_StartScanRev")
	LogInfo("Receiver StartScanRev Not Implemented")	-- default
end

function ReceiverCom_StopScanFwd()
	LogTrace("ReceiverCom_StopScanFwd")
	LogInfo("Receiver StopScanFwd Not Implemented")	-- default
end

function ReceiverCom_StopScanRev()
	LogTrace("ReceiverCom_StopScanRev")
	LogInfo("Receiver StopScanRev Not Implemented")	-- default
end

function ReceiverCom_StartLeft()
	LogTrace("ReceiverCom_StartLeft")
	LogInfo("Receiver StartLeft Not Implemented")	-- default
end

function ReceiverCom_StartRight()
	LogTrace("ReceiverCom_StartRight")
	LogInfo("Receiver StartRight Not Implemented")	-- default
end

function ReceiverCom_StartUp()
	LogTrace("ReceiverCom_StartUp")
	LogInfo("Receiver StartUp Not Implemented")	-- default
end

function ReceiverCom_StartDown()
	LogTrace("ReceiverCom_StartDown")
	LogInfo("Receiver StartDown Not Implemented")	-- default
end

function ReceiverCom_StopLeft()
	LogTrace("ReceiverCom_StopLeft")
	LogInfo("Receiver StopLeft Not Implemented")	-- default
end

function ReceiverCom_StopRight()
	LogTrace("ReceiverCom_StopRight")
	LogInfo("Receiver StopRight Not Implemented")	-- default
end

function ReceiverCom_StopUp()
	LogTrace("ReceiverCom_StopUp")
	LogInfo("Receiver StopUp Not Implemented")	-- default
end

function ReceiverCom_StopDown()
	LogTrace("ReceiverCom_StopDown")
	LogInfo("ReceiverCom_StopDown Not Implemented")	-- default
end




