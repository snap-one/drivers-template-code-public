--[[=============================================================================
    Receiver Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "receiver_proxy.receiver_proxy_commands"
require "receiver_proxy.receiver_proxy_notifies"


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.receiver_device_class = "2023.02.02"
end

ReceiverDevice = inheritsFrom(C4ProxyBase)

--==========================================================================

ReceiverAudioInputInfo = inheritsFrom(nil)

function ReceiverAudioInputInfo:construct(BindingID, InputName)
	self._BindingID = BindingID
	self._InputName = InputName
	self._Classes = {}
end

function ReceiverAudioInputInfo:GetBindingID()
	return self._BindingID
end

function ReceiverAudioInputInfo:GetInputName()
	return self._InputName
end

function ReceiverAudioInputInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
	end
end

--==========================================================================

ReceiverAudioOutputInfo = inheritsFrom(nil)

function ReceiverAudioOutputInfo:construct(BindingID, OutputName, Parent)
	self._BindingID = BindingID
	self._OutputName = OutputName
	self._Parent = Parent

	self._CurrentChannel = "-"
	self._CurrentInput = nil
	self._CurrentVolume = 0
	self._CurrentBass = 0
	self._CurrentTreble = 0
	self._CurrentBalance = 0
	self._CurrentMuted = false
	self._CurrentLoudnessOn = false
	self._CurrentSurroundMode = ""
	
	self._Classes = {}
end

function ReceiverAudioOutputInfo:GetBindingID()
	return self._BindingID
end

function ReceiverAudioOutputInfo:GetOutputName()
	return self._OutputName
end

function ReceiverAudioOutputInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
	end
end

function ReceiverAudioOutputInfo:SetInput(TargInput, SendToDevice, SendNotify)
	self._CurrentInput = TargInput
	if(SendToDevice) then
		ReceiverCom_SetInput(self:GetOutputName(), self._CurrentInput:GetInputName(), "Audio", {})
	end
	
	if(SendNotify) then
		NOTIFY.REC_INPUT_OUTPUT_CHANGED(self._CurrentInput:GetBindingID(), self:GetBindingID(), self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:ConnectOutput(tParams)
	ReceiverCom_ConnectOutput(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:DisconnectOutput(tParams)
	ReceiverCom_DisconnectOutput(self:GetOutputName(), tParams)
end


----

function ReceiverAudioOutputInfo:GetVolume()
	return self._CurrentVolume
end

function ReceiverAudioOutputInfo:SetVolume(NewVolume)
	if(self._CurrentVolume ~= NewVolume) then
		self._CurrentVolume = NewVolume
		NOTIFY.REC_VOLUME_LEVEL_CHANGED(self._CurrentVolume, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:SendVolumeLevel(VolumeLevel, tParams)
	ReceiverCom_SetCurrentVolume(self:GetOutputName(), VolumeLevel, tParams)
end

function ReceiverAudioOutputInfo:PulseVolumeUp(tParams)
	ReceiverCom_PulseVolumeUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartVolumeUp(tParams)
	ReceiverCom_StartVolumeUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopVolumeUp(tParams)
	ReceiverCom_StopVolumeUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:PulseVolumeDown(tParams)
	ReceiverCom_PulseVolumeDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartVolumeDown(tParams)
	ReceiverCom_StartVolumeDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopVolumeDown(tParams)
	ReceiverCom_StopVolumeDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:GetCurrentVolume()
	return self._CurrentVolume
end

----

function ReceiverAudioOutputInfo:GetCurrentTrebleLevel()
	return self._CurrentTreble
end

function ReceiverAudioOutputInfo:SetTrebleLevel(NewTrebleLevel)
	if(self._CurrentTreble ~= NewTrebleLevel) then
		self._CurrentTreble = NewTrebleLevel
		NOTIFY.REC_TREBEL_LEVEL_CHANGED(self._CurrentTreble, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:SendTrebleLevel(NewTreble, tParams)
	ReceiverCom_SetCurrentTreble(self:GetOutputName(), NewTreble, tParams)
end

function ReceiverAudioOutputInfo:PulseTrebleUp(tParams)
	ReceiverCom_PulseTrebleUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:PulseTrebleDown(tParams)
	ReceiverCom_PulseTrebleDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartTrebleUp(tParams)
	ReceiverCom_StartTrebleUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopTrebleUp(tParams)
	ReceiverCom_StopTrebleUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartTrebleDown(tParams)
	ReceiverCom_StartTrebleDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopTrebleDown(tParams)
	ReceiverCom_StopTrebleDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:GetCurrentTreble()
	return self._CurrentTreble
end

----

function ReceiverAudioOutputInfo:GetCurrentBassLevel()
	return self._CurrentBass
end

function ReceiverAudioOutputInfo:SetBassLevel(NewBassLevel)
	if(self._CurrentBass ~= NewBassLevel) then
		self._CurrentBass = NewBassLevel
		NOTIFY.REC_BASS_LEVEL_CHANGED(self._CurrentBass, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:SendBassLevel(NewBass, tParams)
	ReceiverCom_SetCurrentBass(self:GetOutputName(), NewBass, tParams)
end

function ReceiverAudioOutputInfo:PulseBassUp(tParams)
	ReceiverCom_PulseBassUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:PulseBassDown(tParams)
	ReceiverCom_PulseBassDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartBassUp(tParams)
	ReceiverCom_StartBassUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopBassUp(tParams)
	ReceiverCom_StopBassUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartBassDown(tParams)
	ReceiverCom_StartBassDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopBassDown(tParams)
	ReceiverCom_StopBassDown(self:GetOutputName(), tParams)
end

----

function ReceiverAudioOutputInfo:GetCurrentBalanceLevel()
	return self._CurrentBalance
end

function ReceiverAudioOutputInfo:SetBalanceLevel(NewBalanceLevel)
	if(self._CurrentBalance ~= NewBalanceLevel) then
		self._CurrentBalance = NewBalanceLevel
		NOTIFY.REC_BALANCE_LEVEL_CHANGED(self._CurrentBalance, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:SendBalanceLevel(NewBalance, tParams)
	ReceiverCom_SetCurrentBalance(self:GetOutputName(), NewBalance, tParams)
end

function ReceiverAudioOutputInfo:PulseBalanceUp(tParams)
	ReceiverCom_PulseBalanceUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:PulseBalanceDown(tParams)
	ReceiverCom_PulseBalanceDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartBalanceUp(tParams)
	ReceiverCom_StartBalanceUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopBalanceUp(tParams)
	ReceiverCom_StopBalanceUp(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StartBalanceDown(tParams)
	ReceiverCom_StartBalanceDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:StopBalanceDown(tParams)
	ReceiverCom_StopBalanceDown(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:GetCurrentBalance()
	return self._CurrentBalance
end

----

function ReceiverAudioOutputInfo:SetMuteFlag(MuteFlag)
	if(MuteFlag ~= self._CurrentMuted) then
		self._CurrentMuted = MuteFlag
		NOTIFY.REC_MUTE_CHANGED(self._CurrentMuted, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:GetMuteFlag()
	return self._CurrentMuted
end

function ReceiverAudioOutputInfo:SendMuteOn(tParams)
	ReceiverCom_MuteOn(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:SendMuteOff(tParams)
	ReceiverCom_MuteOff(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:SendMuteToggle(tParams)
	ReceiverCom_MuteToggle(self:GetOutputName(), tParams)
end

----

function ReceiverAudioOutputInfo:SetLoudnessFlag(LoudnessFlag)
	if(LoudnessFlag ~= self._CurrentLoudnessOn) then
		self._CurrentLoudnessOn = LoudnessFlag
		NOTIFY.REC_LOUDNESS_CHANGED(self._CurrentLoudnessOn, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:GetLoudnessFlag()
	return self._CurrentLoudnessOn
end

function ReceiverAudioOutputInfo:SendLoudnessOn(tParams)
	ReceiverCom_LoudnessOn(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:SendLoudnessOff(tParams)
	ReceiverCom_LoudnessOff(self:GetOutputName(), tParams)
end

function ReceiverAudioOutputInfo:SendLoudnessToggle(tParams)
	ReceiverCom_LoudnessToggle(self:GetOutputName(), tParams)
end


function ReceiverAudioOutputInfo:SetSurroundMode(NewSurroundMode)
	local NewSurroundModeStr = tostring(NewSurroundMode)
	if(self._CurrentSurroundMode ~= NewSurroundModeStr) then
		self._CurrentSurroundMode = NewSurroundModeStr
		NOTIFY.REC_SURROUND_MODE_CHANGED(self._CurrentSurroundMode, self._BindingID, self._Parent:GetBindingID())
	end
end

function ReceiverAudioOutputInfo:GetSurroundMode()
	return self._CurrentSurroundMode
end

function ReceiverAudioOutputInfo:SendSurroundMode(TargSurroundMode, tParams)
	ReceiverCom_SetSurroundMode(self:GetOutputName(), TargSurroundMode, tParams)
end


--===========================================================================

ReceiverVideoInputInfo = inheritsFrom(nil)

function ReceiverVideoInputInfo:construct(BindingID, InputName)
	self._BindingID = BindingID
	self._InputName = InputName
	self._IsMiniApp = false

	self._Classes = {}
end

function ReceiverVideoInputInfo:GetBindingID()
	return self._BindingID
end

function ReceiverVideoInputInfo:GetInputName()
	return self._InputName
end

function ReceiverVideoInputInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
		if(CurClass.class == "RF_MINI_APP") then
			self._IsMiniApp = true
		end
	end
end

function ReceiverVideoInputInfo:IsMiniAppBinding()
	return self._IsMiniApp
end


--==========================================================================
--==========================================================================

ReceiverVideoOutputInfo = inheritsFrom(nil)

function ReceiverVideoOutputInfo:construct(BindingID, OutputName, Parent)
	self._BindingID = BindingID
	self._OutputName = OutputName
	self._Parent = Parent

	self._CurrentInput = nil
	self._Classes = {}
end

function ReceiverVideoOutputInfo:GetBindingID()
	return self._BindingID
end

function ReceiverVideoOutputInfo:GetOutputName()
	return self._OutputName
end

function ReceiverVideoOutputInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
	end
end

function ReceiverVideoOutputInfo:SetInput(TargInput, SendToDevice, SendNotify)
	self._CurrentInput = TargInput
	local ConnectType = "Video"
	local ConnectExtraInfo = {}
	
	if(TargInput:IsMiniAppBinding()) then
		ConnectType = "MiniApp"
		local AppProxyID = C4:GetBoundProviderDevice(self._Parent:GetProxyDeviceID(), TargInput:GetBindingID())
		local AppID = C4:GetBoundProviderDevice(AppProxyID, DEFAULT_PROXY_BINDINGID)
		for _, v in pairs(C4:GetDeviceVariables (AppID)) do
			ConnectExtraInfo[v.name] = v.value
		end
	end
	
	if(SendToDevice) then
		ReceiverCom_SetInput(self:GetOutputName(), self._CurrentInput:GetInputName(), ConnectType, ConnectExtraInfo)
	end
	
	if(SendNotify) then
		NOTIFY.REC_INPUT_OUTPUT_CHANGED(self._CurrentInput:GetBindingID(), self:GetBindingID(), self._Parent:GetBindingID())
	end
end

----


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]

function ReceiverDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._PowerOn = false
	self._ReceiverOutputs = {}
	self._ReceiverInputs = {}

	self._DefaultAudioOutput = nil
end

function ReceiverDevice.FixAudName(InName)
	return string.format("A_%s", tostring(InName))
end

function ReceiverDevice.FixVidName(InName)
	return string.format("V_%s", tostring(InName))
end

function ReceiverDevice.MakeAudioKey(BindingVal)
	local KeyIndex = tonumber(BindingVal) % 1000
	return string.format("A_%03d", KeyIndex)
end

function ReceiverDevice.MakeVideoKey(BindingVal)
	local KeyIndex = tonumber(BindingVal) % 1000
	return string.format("V_%03d", KeyIndex)
end


function ReceiverDevice:InitialSetup()
	
	if(PersistData.ReceiverPersist == nil) then
		PersistReceiverData = {}
		PersistData.ReceiverPersist = PersistReceiverData
		
		PersistReceiverData._Capabilities = {}
		self:InitializeCapabilities()

	else
		PersistReceiverData = PersistData.ReceiverPersist
	end

	-- Populate Audio and Video Inputs and Outputs
	local AllBindingTab = C4:GetBindingsByDevice(self:GetProxyDeviceID()).bindings
	for _, CurBindingInfo in pairs(AllBindingTab) do
		LogInfo("Get info for binding: %s  %s", tostring(CurBindingInfo.bindingid), CurBindingInfo.name)
		if(CurBindingInfo.type == 6) then	-- audio binding
			if(CurBindingInfo.provider) then
				local NewAudioOutput = ReceiverAudioOutputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
				NewAudioOutput:GetNeededInfo(CurBindingInfo)
				self._ReceiverOutputs[ReceiverDevice.MakeAudioKey(CurBindingInfo.bindingid)] = NewAudioOutput
				self._ReceiverOutputs[ReceiverDevice.FixAudName(CurBindingInfo.name)] = NewAudioOutput
				if(self._DefaultAudioOutput == nil) then
					self._DefaultAudioOutput = NewAudioOutput		-- first one created gets to be the default
				end
--				LogInfo(NewAudioOutput)
			else
				local NewAudioInput = ReceiverAudioInputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name)
				NewAudioInput:GetNeededInfo(CurBindingInfo)
				self._ReceiverInputs[ReceiverDevice.MakeAudioKey(CurBindingInfo.bindingid)] = NewAudioInput
				self._ReceiverInputs[ReceiverDevice.FixAudName(CurBindingInfo.name)] = NewAudioInput
--				LogInfo(NewAudioInput)
			end
			
		elseif(CurBindingInfo.type == 5) then	-- video binding
			if(CurBindingInfo.provider) then
				local NewVideoOutput = ReceiverVideoOutputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
				NewVideoOutput:GetNeededInfo(CurBindingInfo)
				self._ReceiverOutputs[ReceiverDevice.MakeVideoKey(CurBindingInfo.bindingid)] = NewVideoOutput
				self._ReceiverOutputs[ReceiverDevice.FixVidName(CurBindingInfo.name)] = NewVideoOutput
--				LogInfo(NewVideoOutput)
			else
				local NewVideoInput = ReceiverVideoInputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name)
				NewVideoInput:GetNeededInfo(CurBindingInfo)
				self._ReceiverInputs[ReceiverDevice.MakeVideoKey(CurBindingInfo.bindingid)] = NewVideoInput
				self._ReceiverInputs[ReceiverDevice.FixVidName(CurBindingInfo.name)] = NewVideoInput
--				LogInfo(NewVideoInput)
			end
			
		end
	end

end



function ReceiverDevice:InitializeCapabilities()
--	PersistReceiverData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
end



-------------

function ReceiverDevice:IsPowerOn()
	return self._PowerOn
end

function ReceiverDevice:PowerFlagIs(PowerFlag)
	if(PowerFlag ~= self._PowerOn) then
		self._PowerOn = PowerFlag
		
		if(self._PowerOn) then
			NOTIFY.REC_ON(self._BindingID)
		else
			NOTIFY.REC_OFF(self._BindingID)
		end
	end
end


function ReceiverDevice:GetReceiverAudioOutput(OutputID)
	-- Kludge alert!  Some of the commands don't send the output binding like they should
	--  default to a common one.
	return (type(tonumber(OutputID)) == "number") and self._ReceiverOutputs[ReceiverDevice.MakeAudioKey(OutputID)] or self._DefaultAudioOutput
end

function ReceiverDevice:GetAudioOutputFromName(OutputName)
	return self._ReceiverOutputs[ReceiverDevice.FixAudName(OutputName)]
end

function ReceiverDevice:GetAudioInputFromName(OutputName)
	return self._ReceiverInputs[ReceiverDevice.FixAudName(OutputName)]
end

function ReceiverDevice:GetVideoOutputFromName(OutputName)
	return self._ReceiverOutputs[ReceiverDevice.FixVidName(OutputName)]
end

function ReceiverDevice:GetVideoInputFromName(OutputName)
	return self._ReceiverInputs[ReceiverDevice.FixVidName(OutputName)]
end



function ReceiverDevice:AssignInputOutput(OutputName, InputName)
	LogTrace("ReceiverDevice:AssignInputOutput %s -> %s", InputName, OutputName)
	local AudIn = self:GetAudioInputFromName(InputName)
	local AudOut = self:GetAudioOutputFromName(OutputName)
	local VidIn = self:GetVideoInputFromName(InputName)
	local VidOut = self:GetVideoOutputFromName(OutputName)
	
	if((AudIn ~= nil) and (AudOut ~= nil)) then
		AudOut:SetInput(AudIn, false, true)
	end

	if((VidIn ~= nil) and (VidOut ~= nil)) then
		VidOut:SetInput(VidIn, false, true)
	end
end



function ReceiverDevice:GetCurrentVolume(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetVolume()
end

function ReceiverDevice:SetVolumeLevel(OutputName, TargVolLevel)
	self:GetAudioOutputFromName(OutputName):SetVolume(TargVolLevel)
end


function ReceiverDevice:IsMuted(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetMuteFlag()
end

function ReceiverDevice:SetMuteState(OutputName, MuteFlag)
	self:GetAudioOutputFromName(OutputName):SetMuteFlag(MuteFlag)
end


function ReceiverDevice:IsLoudnessOn(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetLoudnessFlag()
end

function ReceiverDevice:SetLoudnessState(OutputName, LoudnessFlag)
	self:GetAudioOutputFromName(OutputName):SetLoudnessFlag(LoudnessFlag)
end


function ReceiverDevice:GetCurrentTrebleLevel(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentTrebleLevel()
end

function ReceiverDevice:SetTrebleLevel(OutputName, Level)
	self:GetAudioOutputFromName(OutputName):SetTrebleLevel(Level)
end


function ReceiverDevice:GetCurrentBassLevel(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentBassLevel()
end

function ReceiverDevice:SetBassLevel(OutputName, Level)
	self:GetAudioOutputFromName(OutputName):SetBassLevel(Level)
end


function ReceiverDevice:GetCurrentBalanceLevel(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentBalanceLevel()
end

function ReceiverDevice:SetBalanceLevel(OutputName, Level)
	self:GetAudioOutputFromName(OutputName):SetBalanceLevel(Level)
end

function ReceiverDevice:SetSurroundMode(OutputName, SurMode)
	self:GetAudioOutputFromName(OutputName):SetSurroundMode(SurMode)
end


--=============================================================================
--=============================================================================

function ReceiverDevice:PrxOn(tParams)
	LogTrace("ReceiverDevice:PrxOn")
	ReceiverCom_On(tParams)
end

function ReceiverDevice:PrxOff(tParams)
	LogTrace("ReceiverDevice:PrxOff")
	ReceiverCom_Off(tParams)
end

function ReceiverDevice:PrxSetInput(tParams)
	LogTrace("ReceiverDevice:PrxSetInput")
	LogInfo(tParams)
	
	local VideoInputKey = ReceiverDevice.MakeVideoKey(tParams.INPUT)
	local VideoOutputKey = ReceiverDevice.MakeVideoKey(tParams.OUTPUT)
	local AudioInputKey = ReceiverDevice.MakeAudioKey(tParams.INPUT)
	local AudioOutputKey = ReceiverDevice.MakeAudioKey(tParams.OUTPUT)

	local VideoInput = self._ReceiverInputs[VideoInputKey]
	local VideoOutput = self._ReceiverOutputs[VideoOutputKey]
	local AudioInput = self._ReceiverInputs[AudioInputKey]
	local AudioOutput = self._ReceiverOutputs[AudioOutputKey]

	local NeedsToBeSent = true
	
	if((VideoOutput ~= nil) and (VideoInput ~= nil)) then
		VideoOutput:SetInput(VideoInput, NeedsToBeSent, false)
		NeedsToBeSent = false
	else
		LogDebug("Video binding command not sent %s <- %s", tostring(VideoOutputKey), tostring(VideoInputKey))
	end

	if((AudioOutput ~= nil) and (AudioInput ~= nil)) then
		AudioOutput:SetInput(AudioInput, NeedsToBeSent, false)
	else
		LogDebug("Audio binding command not sent  %s <- %s", tostring(AudioOutputKey), tostring(AudioInputKey))
	end
end


function ReceiverDevice:PrxConnectOutput(tParams)
	LogTrace("ReceiverDevice:PrxConnectOutput")
	-- LogInfo(tParams)
	self:GetReceiverAudioOutput(tParams.OUTPUT):ConnectOutput(tParams)

end

function ReceiverDevice:PrxDisconnectOutput(tParams)
	LogTrace("ReceiverDevice:PrxDisconnectOutput")
	-- LogInfo(tParams)
	self:GetReceiverAudioOutput(tParams.OUTPUT):DisconnectOutput(tParams)
end

function ReceiverDevice:PrxSetSurroundMode(tParams)
	LogTrace("ReceiverDevice:PrxSetSurroundMode")
--	LogInfo(tParams)
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendSurroundMode(tParams.SURROUND_MODE, tParams)
end

function ReceiverDevice:PrxPulseSurUp(tParams)
	LogTrace("ReceiverDevice:PrxPulseSurUp")
	-- TODO  Not sure what this is.
end


function ReceiverDevice:PrxSetVolumeLevel(tParams)
	LogTrace("ReceiverDevice:PrxSetVolumeLevel")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendVolumeLevel(tParams.LEVEL, tParams)
end

function ReceiverDevice:PrxStartVolumeUp(tParams)
	LogTrace("ReceiverDevice:PrxStartVolumeUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartVolumeUp(tParams)
end

function ReceiverDevice:PrxStopVolumeUp(tParams)
	LogTrace("ReceiverDevice:PrxStopVolumeUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopVolumeUp(tParams)
end

function ReceiverDevice:PrxStartVolumeDown(tParams)
	LogTrace("ReceiverDevice:PrxStartVolumeDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartVolumeDown(tParams)
end

function ReceiverDevice:PrxStopVolumeDown(tParams)
	LogTrace("ReceiverDevice:PrxStopVolumeDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopVolumeDown(tParams)
end

function ReceiverDevice:PrxPulseVolumeUp(tParams)
	LogTrace("ReceiverDevice:PrxPulseVolumeUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseVolumeUp(tParams)
end

function ReceiverDevice:PrxPulseVolumeDown(tParams)
	LogTrace("ReceiverDevice:PrxPulseVolumeDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseVolumeDown(tParams)
end



function ReceiverDevice:PrxSetTrebleLevel(tParams)
	LogTrace("ReceiverDevice:PrxSetTrebleLevel")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendTrebleLevel(tParams.LEVEL, tParams)
end

function ReceiverDevice:PrxPulseTrebleUp(tParams)
	LogTrace("ReceiverDevice:PrxStartTrebleUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseTrebleUp(tParams)
end

function ReceiverDevice:PrxPulseTrebleDown(tParams)
	LogTrace("ReceiverDevice:PrxStartTrebleDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseTrebleDown(tParams)
end

function ReceiverDevice:PrxStartTrebleUp(tParams)
	LogTrace("ReceiverDevice:PrxStartTrebleUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartTrebleUp(tParams)
end

function ReceiverDevice:PrxStopTrebleUp(tParams)
	LogTrace("ReceiverDevice:PrxStopTrebleUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopTrebleUp(tParams)
end

function ReceiverDevice:PrxStartTrebleDown(tParams)
	LogTrace("ReceiverDevice:PrxStartTrebleDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartTrebleDown(tParams)
end

function ReceiverDevice:PrxStopTrebleDown(tParams)
	LogTrace("ReceiverDevice:PrxStopTrebleDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopTrebleDown(tParams)
end


function ReceiverDevice:PrxSetBassLevel(tParams)
	LogTrace("ReceiverDevice:PrxSetBassLevel")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendBassLevel(tParams.LEVEL, tParams)
end

function ReceiverDevice:PrxPulseBassUp(tParams)
	LogTrace("ReceiverDevice:PrxStartBassUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseBassUp(tParams)
end

function ReceiverDevice:PrxPulseBassDown(tParams)
	LogTrace("ReceiverDevice:PrxStartBassDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseBassDown(tParams)
end

function ReceiverDevice:PrxStartBassUp(tParams)
	LogTrace("ReceiverDevice:PrxStartBassUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartBassUp(tParams)
end

function ReceiverDevice:PrxStopBassUp(tParams)
	LogTrace("ReceiverDevice:PrxStopBassUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopBassUp(tParams)
end

function ReceiverDevice:PrxStartBassDown(tParams)
	LogTrace("ReceiverDevice:PrxStartBassDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartBassDown(tParams)
end

function ReceiverDevice:PrxStopBassDown(tParams)
	LogTrace("ReceiverDevice:PrxStopBassDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopBassDown(tParams)
end


function ReceiverDevice:PrxSetBalanceLevel(tParams)
	LogTrace("ReceiverDevice:PrxSetBalanceLevel")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendBalanceLevel(tParams.LEVEL, tParams)
end

function ReceiverDevice:PrxPulseBalanceUp(tParams)
	LogTrace("ReceiverDevice:PrxStartBalanceUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseBalanceUp(tParams)
end

function ReceiverDevice:PrxPulseBalanceDown(tParams)
	LogTrace("ReceiverDevice:PrxStartBalanceDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):PulseBalanceDown(tParams)
end

function ReceiverDevice:PrxStartBalanceUp(tParams)
	LogTrace("ReceiverDevice:PrxStartBalanceUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartBalanceUp(tParams)
end

function ReceiverDevice:PrxStopBalanceUp(tParams)
	LogTrace("ReceiverDevice:PrxStopBalanceUp")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopBalanceUp(tParams)
end

function ReceiverDevice:PrxStartBalanceDown(tParams)
	LogTrace("ReceiverDevice:PrxStartBalanceDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StartBalanceDown(tParams)
end

function ReceiverDevice:PrxStopBalanceDown(tParams)
	LogTrace("ReceiverDevice:PrxStopBalanceDown")
	self:GetReceiverAudioOutput(tParams.OUTPUT):StopBalanceDown(tParams)
end


function ReceiverDevice:PrxMuteOn(tParams)
	LogTrace("ReceiverDevice:PrxMuteOn")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendMuteOn(tParams)
end

function ReceiverDevice:PrxMuteOff(tParams)
	LogTrace("ReceiverDevice:PrxMuteOff")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendMuteOff(tParams)
end

function ReceiverDevice:PrxMuteToggle(tParams)
	LogTrace("ReceiverDevice:PrxMuteToggle")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendMuteToggle(tParams)
end

function ReceiverDevice:PrxLoudnessOn(tParams)
	LogTrace("ReceiverDevice:PrxLoudnessOn")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendLoudnessOn(tParams)
end

function ReceiverDevice:PrxLoudnessOff(tParams)
	LogTrace("ReceiverDevice:PrxLoudnessOff")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendLoudnessOff(tParams)
end

function ReceiverDevice:PrxLoudnessToggle(tParams)
	LogTrace("ReceiverDevice:PrxLoudnessToggle")
	self:GetReceiverAudioOutput(tParams.OUTPUT):SendLoudnessToggle(tParams)
end



function ReceiverDevice:PrxNumber0(tParams)
	LogTrace("ReceiverDevice:PrxNumber0")
	ReceiverCom_Number0(tParams)
end

function ReceiverDevice:PrxNumber1(tParams)
	LogTrace("ReceiverDevice:PrxNumber1")
	ReceiverCom_Number1(tParams)
end

function ReceiverDevice:PrxNumber2(tParams)
	LogTrace("ReceiverDevice:PrxNumber2")
	ReceiverCom_Number2(tParams)
end

function ReceiverDevice:PrxNumber3(tParams)
	LogTrace("ReceiverDevice:PrxNumber3")
	ReceiverCom_Number3(tParams)
end

function ReceiverDevice:PrxNumber4(tParams)
	LogTrace("ReceiverDevice:PrxNumber4")
	ReceiverCom_Number4(tParams)
end

function ReceiverDevice:PrxNumber5(tParams)
	LogTrace("ReceiverDevice:PrxNumber5")
	ReceiverCom_Number5(tParams)
end

function ReceiverDevice:PrxNumber6(tParams)
	LogTrace("ReceiverDevice:PrxNumber6")
	ReceiverCom_Number6(tParams)
end

function ReceiverDevice:PrxNumber7(tParams)
	LogTrace("ReceiverDevice:PrxNumber7")
	ReceiverCom_Number7(tParams)
end

function ReceiverDevice:PrxNumber8(tParams)
	LogTrace("ReceiverDevice:PrxNumber8")
	ReceiverCom_Number8(tParams)
end

function ReceiverDevice:PrxNumber9(tParams)
	LogTrace("ReceiverDevice:PrxNumber9")
	ReceiverCom_Number9(tParams)
end

function ReceiverDevice:PrxDash(tParams)
	LogTrace("ReceiverDevice:PrxDash")
	ReceiverCom_Dash(tParams)
end

function ReceiverDevice:PrxStar(tParams)
	LogTrace("ReceiverDevice:PrxStar")
	ReceiverCom_Star(tParams)
end

function ReceiverDevice:PrxPound(tParams)
	LogTrace("ReceiverDevice:PrxPound")
	ReceiverCom_Pound(tParams)
end



function ReceiverDevice:PrxPlay(tParams)
	LogTrace("ReceiverDevice:PrxPlay")
	ReceiverCom_Play(tParams)
end

function ReceiverDevice:PrxStop(tParams)
	LogTrace("ReceiverDevice:PrxStop")
	ReceiverCom_Stop(tParams)
end

function ReceiverDevice:PrxPause(tParams)
	LogTrace("ReceiverDevice:PrxPause")
	ReceiverCom_Pause(tParams)
end

function ReceiverDevice:PrxRecord(tParams)
	LogTrace("ReceiverDevice:PrxRecord")
	ReceiverCom_Record(tParams)
end

function ReceiverDevice:PrxEject(tParams)
	LogTrace("ReceiverDevice:PrxEject")
	ReceiverCom_Eject(tParams)
end

function ReceiverDevice:PrxClose(tParams)
	LogTrace("ReceiverDevice:PrxClose")
	ReceiverCom_Close(tParams)
end

function ReceiverDevice:PrxInfo(tParams)
	LogTrace("ReceiverDevice:PrxInfo")
	ReceiverCom_Info(tParams)
end

function ReceiverDevice:PrxGuide(tParams)
	LogTrace("ReceiverDevice:PrxGuide")
	ReceiverCom_Guide(tParams)
end

function ReceiverDevice:PrxMenu(tParams)
	LogTrace("ReceiverDevice:PrxMenu")
	ReceiverCom_Menu(tParams)
end

function ReceiverDevice:PrxCancel(tParams)
	LogTrace("ReceiverDevice:PrxCancel")
	ReceiverCom_Cancel(tParams)
end

function ReceiverDevice:PrxUp(tParams)
	LogTrace("ReceiverDevice:PrxUp")
	ReceiverCom_Up(tParams)
end

function ReceiverDevice:PrxDown(tParams)
	LogTrace("ReceiverDevice:PrxDown")
	ReceiverCom_Down(tParams)
end

function ReceiverDevice:PrxLeft(tParams)
	LogTrace("ReceiverDevice:PrxLeft")
	ReceiverCom_Left(tParams)
end

function ReceiverDevice:PrxRight(tParams)
	LogTrace("ReceiverDevice:PrxRight")
	ReceiverCom_Right(tParams)
end

function ReceiverDevice:PrxStartDown(tParams)
	LogTrace("ReceiverDevice:PrxStartDown")
	ReceiverCom_StartDown(tParams)
end

function ReceiverDevice:PrxStartUp(tParams)
	LogTrace("ReceiverDevice:PrxStartUp")
	ReceiverCom_StartUp(tParams)
end

function ReceiverDevice:PrxStartLeft(tParams)
	LogTrace("ReceiverDevice:PrxStartLeft")
	ReceiverCom_StartLeft(tParams)
end

function ReceiverDevice:PrxStartRight(tParams)
	LogTrace("ReceiverDevice:PrxStartRight")
	ReceiverCom_StartRight(tParams)
end

function ReceiverDevice:PrxStopDown(tParams)
	LogTrace("ReceiverDevice:PrxStopDown")
	ReceiverCom_StopDown(tParams)
end

function ReceiverDevice:PrxStopUp(tParams)
	LogTrace("ReceiverDevice:PrxStopUp")
	ReceiverCom_StopUp(tParams)
end

function ReceiverDevice:PrxStopLeft(tParams)
	LogTrace("ReceiverDevice:PrxStopLeft")
	ReceiverCom_StopLeft(tParams)
end

function ReceiverDevice:PrxStopRight(tParams)
	LogTrace("ReceiverDevice:PrxStopRight")
	ReceiverCom_StopRight(tParams)
end

function ReceiverDevice:PrxEnter(tParams)
	LogTrace("ReceiverDevice:PrxEnter")
	ReceiverCom_Enter(tParams)
end

function ReceiverDevice:PrxExit(tParams)
	LogTrace("ReceiverDevice:PrxExit")
	ReceiverCom_Exit(tParams)
end

function ReceiverDevice:PrxHome(tParams)
	LogTrace("ReceiverDevice:PrxHome")
	ReceiverCom_Home(tParams)
end

function ReceiverDevice:PrxSettings(tParams)
	LogTrace("ReceiverDevice:PrxSettings")
	ReceiverCom_Settings(tParams)
end

function ReceiverDevice:PrxRecall(tParams)
	LogTrace("ReceiverDevice:PrxRecall")
	ReceiverCom_Recall(tParams)
end

function ReceiverDevice:PrxClose(tParams)
	LogTrace("ReceiverDevice:PrxClose")
	ReceiverCom_Close(tParams)
end

function ReceiverDevice:PrxSkipFwd(tParams)
	LogTrace("ReceiverDevice:PrxSkipFwd")
	ReceiverCom_SkipFwd(tParams)
end

function ReceiverDevice:PrxSkipRev(tParams)
	LogTrace("ReceiverDevice:PrxSkipRev")
	ReceiverCom_SkipRev(tParams)
end

function ReceiverDevice:PrxScanFwd(tParams)
	LogTrace("ReceiverDevice:PrxScanFwd")
	ReceiverCom_ScanFwd(tParams)
end

function ReceiverDevice:PrxScanRev(tParams)
	LogTrace("ReceiverDevice:PrxScanRev")
	ReceiverCom_ScanRev(tParams)
end

function ReceiverDevice:PrxProgramA(tParams)
	LogTrace("ReceiverDevice:PrxProgramA")
	ReceiverCom_ProgramA(tParams)
end

function ReceiverDevice:PrxProgramB(tParams)
	LogTrace("ReceiverDevice:PrxProgramB")
	ReceiverCom_ProgramB(tParams)
end

function ReceiverDevice:PrxProgramC(tParams)
	LogTrace("ReceiverDevice:PrxProgramC")
	ReceiverCom_ProgramC(tParams)
end

function ReceiverDevice:PrxProgramD(tParams)
	LogTrace("ReceiverDevice:PrxProgramD")
	ReceiverCom_ProgramD(tParams)
end

function ReceiverDevice:PrxPageUp(tParams)
	LogTrace("ReceiverDevice:PrxPageUp")
	ReceiverCom_PageUp(tParams)
end

function ReceiverDevice:PrxPageDown(tParams)
	LogTrace("ReceiverDevice:PrxPageDown")
	ReceiverCom_PageDown(tParams)
end


function ReceiverDevice:PrxStartScanFwd(tParams)
	LogTrace("ReceiverDevice:PrxStartScanFwd")
	ReceiverCom_StartScanFwd(tParams)
end

function ReceiverDevice:PrxStartScanRev(tParams)
	LogTrace("ReceiverDevice:PrxStartScanRev")
	ReceiverCom_StartScanRev(tParams)
end

function ReceiverDevice:PrxStopScanFwd(tParams)
	LogTrace("ReceiverDevice:PrxStopScanFwd")
	ReceiverCom_StopScanFwd(tParams)
end

function ReceiverDevice:PrxStopScanRev(tParams)
	LogTrace("ReceiverDevice:PrxStopScanRev")
	ReceiverCom_StopScanRev(tParams)
end

function ReceiverDevice:PrxStartLeft(tParams)
	LogTrace("ReceiverDevice:PrxStartLeft")
	ReceiverCom_StartLeft(tParams)
end

function ReceiverDevice:PrxStartRight(tParams)
	LogTrace("ReceiverDevice:PrxStartRight")
	ReceiverCom_StartRight(tParams)
end

function ReceiverDevice:PrxStartUp(tParams)
	LogTrace("ReceiverDevice:PrxStartUp")
	ReceiverCom_StartUp(tParams)
end

function ReceiverDevice:PrxStartDown(tParams)
	LogTrace("ReceiverDevice:PrxStartDown")
	ReceiverCom_StartDown(tParams)
end

function ReceiverDevice:PrxStopLeft(tParams)
	LogTrace("ReceiverDevice:PrxStopLeft")
	ReceiverCom_StopLeft(tParams)
end

function ReceiverDevice:PrxStopRight(tParams)
	LogTrace("ReceiverDevice:PrxStopRight")
	ReceiverCom_StopRight(tParams)
end

function ReceiverDevice:PrxStopUp(tParams)
	LogTrace("ReceiverDevice:PrxStopUp")
	ReceiverCom_StopUp(tParams)
end

function ReceiverDevice:PrxStopDown(tParams)
	LogTrace("ReceiverDevice:PrxStopDown")
	ReceiverCom_StopDown(tParams)
end



function ReceiverDevice:PrxPassthrough(tParams)
	LogTrace("ReceiverDevice:PrxPassthrough")
	LogInfo(tParams)
	
	local PassThroughCmd = tParams.PASSTHROUGH_COMMAND
	if(ReceiverDevice._PassThroughCommandRoutines[PassThroughCmd] ~= nil) then
		ReceiverDevice._PassThroughCommandRoutines[PassThroughCmd](self, tParams)
	else
		LogInfo("ReceiverDevice:PrxPassthrough  Unhandled Command: %s", PassThroughCmd)
	end
end

--======================================================

ReceiverDevice._PassThroughCommandRoutines = {
	['LEFT']			= ReceiverDevice.PrxLeft,
	['RIGHT']			= ReceiverDevice.PrxRight,
	['UP']				= ReceiverDevice.PrxUp,
	['DOWN']			= ReceiverDevice.PrxDown,
	['MENU']			= ReceiverDevice.PrxMenu,
	['CANCEL']			= ReceiverDevice.PrxCancel,
	['INFO']			= ReceiverDevice.PrxInfo,
	['EJECT']			= ReceiverDevice.PrxEject,
	['ENTER']			= ReceiverDevice.PrxEnter,
	['PLAY']			= ReceiverDevice.PrxPlay,
	['STOP']			= ReceiverDevice.PrxStop,
	['PAUSE']			= ReceiverDevice.PrxPause,
	['RECORD']			= ReceiverDevice.PrxRecord,
	['SKIP_FWD']		= ReceiverDevice.PrxSkipFwd,
	['SKIP_REV']		= ReceiverDevice.PrxSkipRev,
	['SCAN_FWD']		= ReceiverDevice.PrxScanFwd,
	['SCAN_REV']		= ReceiverDevice.PrxScanRev,
	['PROGRAM_A']		= ReceiverDevice.PrxProgramA,
	['PROGRAM_B']		= ReceiverDevice.PrxProgramB,
	['PROGRAM_C']		= ReceiverDevice.PrxProgramC,
	['PROGRAM_D']		= ReceiverDevice.PrxProgramD,
	['PAGE_UP']			= ReceiverDevice.PrxPageUp,
	['PAGE_DOWN']		= ReceiverDevice.PrxPageDown,
	['NUMBER_0']		= ReceiverDevice.PrxNumber0,
	['NUMBER_1']		= ReceiverDevice.PrxNumber1,
	['NUMBER_2']		= ReceiverDevice.PrxNumber2,
	['NUMBER_3']		= ReceiverDevice.PrxNumber3,
	['NUMBER_4']		= ReceiverDevice.PrxNumber4,
	['NUMBER_5']		= ReceiverDevice.PrxNumber5,
	['NUMBER_6']		= ReceiverDevice.PrxNumber6,
	['NUMBER_7']		= ReceiverDevice.PrxNumber7,
	['NUMBER_8']		= ReceiverDevice.PrxNumber8,
	['NUMBER_9']		= ReceiverDevice.PrxNumber9,
	['STAR']			= ReceiverDevice.PrxStar,
	['POUND']			= ReceiverDevice.PrxPound,
	['START_SCAN_FWD']  = ReceiverDevice.PrxStartScanFwd,
	['START_SCAN_REV']  = ReceiverDevice.PrxStartScanRev,
	['STOP_SCAN_FWD']   = ReceiverDevice.PrxStopScanFwd,
	['STOP_SCAN_REV']   = ReceiverDevice.PrxStopScanRev,
	['START_LEFT']      = ReceiverDevice.PrxStartLeft,
	['START_RIGHT']     = ReceiverDevice.PrxStartRight,
	['START_UP']        = ReceiverDevice.PrxStartUp,
	['START_DOWN']      = ReceiverDevice.PrxStartDown,
	['STOP_LEFT']       = ReceiverDevice.PrxStopLeft,
	['STOP_RIGHT']      = ReceiverDevice.PrxStopRight,
	['STOP_UP']         = ReceiverDevice.PrxStopUp,
	['STOP_DOWN']       = ReceiverDevice.PrxStopDown,
	
}


