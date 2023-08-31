--[[=============================================================================
    AVSwitch Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "avswitch_proxy.avswitch_proxy_commands"
require "avswitch_proxy.avswitch_proxy_notifies"
require "modules.c4_metrics"
require "modules.retry_timer"
require "modules.ramp_timer"


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.avswitch_device_class = "2023.05.25"
end

AVSwitchDevice = inheritsFrom(C4ProxyBase)

--==========================================================================

AVSwitchConnectionInfo = inheritsFrom(nil)

function AVSwitchConnectionInfo:construct(BindingID, Name, Parent)
	self._BindingID = BindingID
	self._Parent = Parent
	self._Name = Name
	self._IsBound = false
	self._Classes = {}
end

function AVSwitchConnectionInfo:GetBindingID()
	return self._BindingID
end

function AVSwitchConnectionInfo:GetName()
	return self._Name
end

function AVSwitchConnectionInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
	end
end

function AVSwitchConnectionInfo:SetBoundFlag(IsBound)
	self._IsBound = IsBound
	--	DCC 09/21/21  This doesn't seem useful.  Add a call to the communicator if there is ever a need for it.
end

function AVSwitchConnectionInfo:IsBound()
	return self._IsBound
end

--==========================================================================

AVSwitchOutputInfo = inheritsFrom(AVSwitchConnectionInfo)

function AVSwitchOutputInfo:construct(BindingID, InputName, Parent, ChildRef)
	self:super():construct(BindingID, InputName, Parent)

	self._ChildRef = ChildRef
	
	local InputRetryInfo = Parent:GetInputRetryInfo()
	self._InputRetryTimer = RetryTimer:new(	InputRetryInfo.RetryMax, 
											InputRetryInfo.Interval, InputRetryInfo.FallbackInterval, InputRetryInfo.IntervalUnits,
											AVSwitchOutputInfo.InputRetry, AVSwitchOutputInfo.InputRetryFail, 
											self._ChildRef)
											
	self._FulfillStr = ""
	
end

function AVSwitchOutputInfo:EnableRetries()
	self._InputRetryTimer:Enable()
end

function AVSwitchOutputInfo:DisableRetries()
	self._InputRetryTimer:Disable()
end

function AVSwitchOutputInfo:SetRetryInterval(NewInterval)
	self._InputRetryTimer:SetInterval(NewInterval)
end

function AVSwitchOutputInfo:SetRetryMaxCount(NewCount)
	self._InputRetryTimer:SetRetryMaxCount(NewCount)
end



function AVSwitchOutputInfo:StartRetries(FStr)
	self._InputRetryTimer:Start(FStr)
end

function AVSwitchOutputInfo:RetryFulfill(FulfillStr)
	self._InputRetryTimer:Fulfill(FulfillStr)
end


function AVSwitchOutputInfo:InputRetry(Param)
	LogInfo("AVSwitchOutputInfo:InputRetry  %s -> %s", self:GetName(), Param.WhichInput:GetName())
	DataLakeMetrics:MetricsCounter('SelectInputRetry')
	self:SetInput(Param.WhichInput, Param.ExtraInfo, true, false, true)
end


function AVSwitchOutputInfo:InputRetryFail(Param)
	LogInfo("AVSwitchOutputInfo:InputRetryFail %s -> %s", self:GetName(), Param.WhichInput:GetName())
	if(Param.SourceType == 'MiniApp') then
		DataLakeMetrics:MetricsCounter('SelectMiniAppFailed')
	else
		DataLakeMetrics:MetricsCounter('SelectDeviceInputFailed')
	end
end


--==========================================================================

AVSwitchAudioInputInfo = inheritsFrom(AVSwitchConnectionInfo)

function AVSwitchAudioInputInfo:construct(BindingID, InputName, Parent)
	self:super():construct(BindingID, InputName, Parent)

end

--==========================================================================

AVSwitchAudioOutputInfo = inheritsFrom(AVSwitchOutputInfo)

function AVSwitchAudioOutputInfo:construct(BindingID, OutputName, Parent)
	self:super():construct(BindingID, OutputName, Parent, self)

	self._CurrentInput = Parent:GetDummyAudioInput()

	self._CurrentVolume = 0
	self._CurrentBass = 0
	self._CurrentTreble = 0
	self._CurrentBalance = 0
	self._CurrentMuted = false
	self._CurrentLoudnessOn = false

	self._RampTimers = {}
	self._RampTimers.VolumeUp		= RampTimer:new(AVSwitchAudioOutputInfo.StartVolumeUp, self)
	self._RampTimers.VolumeDown		= RampTimer:new(AVSwitchAudioOutputInfo.StartVolumeDown, self)
	self._RampTimers.BassUp			= RampTimer:new(AVSwitchAudioOutputInfo.StartBassUp, self)
	self._RampTimers.BassDown		= RampTimer:new(AVSwitchAudioOutputInfo.StartBassDown, self)
	self._RampTimers.TrebleUp		= RampTimer:new(AVSwitchAudioOutputInfo.StartTrebleUp, self)
	self._RampTimers.TrebleDown		= RampTimer:new(AVSwitchAudioOutputInfo.StartTrebleDown, self)
	self._RampTimers.BalanceUp		= RampTimer:new(AVSwitchAudioOutputInfo.StartBalanceUp, self)
	self._RampTimers.BalanceDown	= RampTimer:new(AVSwitchAudioOutputInfo.StartBalanceDown, self)
		
	for TimerName, TimerInst in pairs(self._RampTimers) do
		local CurInfo = Parent._RampTimerInfo[TimerName]
		TimerInst:SetEnableFlag(CurInfo.Enabled)
		TimerInst:SetInterval(CurInfo.Interval)
	end
end

-------

function AVSwitchAudioOutputInfo:EnableRampTimers()
	for TimerName, _ in pairs(self._RampTimers) do
		self:EnableRampTimer(TimerName)
	end
end

function AVSwitchAudioOutputInfo:DisableRampTimers()
	for TimerName, _ in pairs(self._RampTimers) do
		self:DisableRampTimer(TimerName)
	end
end


function AVSwitchAudioOutputInfo:StartRampTimer(TimerName, CallbackParam)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetRampParameter(CallbackParam)
		TargTimer:Start()
	else
		LogWarn("AVSwitchAudioOutputInfo:StartRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchAudioOutputInfo:StopRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:Kill()
	else
		LogWarn("AVSwitchAudioOutputInfo:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchAudioOutputInfo:IsRamping(TimerName)
	local RampingFlag = false
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		RampingFlag = TargTimer:IsRamping()
	else
		LogWarn("AVSwitchAudioOutputInfo:IsRamping  Undefined Ramp Timer: %s", tostring(TimerName))
	end
	
	return RampingFlag
end

function AVSwitchAudioOutputInfo:EnableRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetEnableFlag(true)
		self._RampTimerInfo[TimerName].Enabled = true
	else
		LogWarn("AVSwitchAudioOutputInfo:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchAudioOutputInfo:DisableRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetEnableFlag(false)
		self._RampTimerInfo[TimerName].Enabled = false
	else
		LogWarn("AVSwitchAudioOutputInfo:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchAudioOutputInfo:SetRampTimerInterval(TimerName, Interval)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetInterval(Interval)
		self._RampTimerInfo[TimerName].Interval = Interval
	else
		LogWarn("AVSwitchAudioOutputInfo:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchAudioOutputInfo:SetAllRampTimerIntervals(Interval)
	for TimerName, _ in pairs(self._RampTimers) do
		self:SetRampTimerInterval(TimerName, Interval)
	end
end


-------

function AVSwitchAudioOutputInfo:SetInput(TargInput, ConnectExtraInfo, SendToDevice, SendNotify, IsRetry)
	self._CurrentInput = TargInput or self._Parent:GetDummyAudioInput()
	if(SendToDevice) then
		if(not IsRetry) then
			DataLakeMetrics:MetricsCounter(string.format("AVSwitch Audio SetInput: %s", self:GetName()))
		end

		local tRetryParams = {
			WhichInput = self._CurrentInput,
			ExtraInfo = ConnectExtraInfo
		}

		self._InputRetryTimer:SetRetryParameter(tRetryParams)
		self._InputRetryTimer:Start(self._CurrentInput:GetName())
		AVSwitchCom_SetInput(self:GetName(), self._CurrentInput:GetName(), "Audio", ConnectExtraInfo)
	end
	
	if(SendNotify) then
		if(self._InputRetryTimer:IsStarted()) then
			self._InputRetryTimer:Fulfill(self._CurrentInput:GetName())
		end
		
		NOTIFY.AVS_INPUT_OUTPUT_CHANGED(self._CurrentInput:GetBindingID(), self:GetBindingID(), true, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:ConnectOutput(ExtraInfo, tParams)
	AVSwitchCom_ConnectOutput(self:GetName(), "Audio", ExtraInfo, tParams)
end

function AVSwitchAudioOutputInfo:DisconnectOutput(ExtraInfo, tParams)
	AVSwitchCom_DisconnectOutput(self:GetName(), "Audio", ExtraInfo, tParams)
end


----

function AVSwitchAudioOutputInfo:GetCurrentVolume()
	return self._CurrentVolume
end

function AVSwitchAudioOutputInfo:SetVolume(NewVolume)
	if(self._CurrentVolume ~= NewVolume) then
		self._CurrentVolume = NewVolume
		NOTIFY.AVS_VOLUME_LEVEL_CHANGED(self._CurrentVolume, self._BindingID, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:SendVolumeLevel(VolumeLevel, tParams)
	DataLakeMetrics:MetricsCounter(string.format("AVSwitch SetVolume %s", self:GetName()))
	AVSwitchCom_SetCurrentVolume(self:GetName(), VolumeLevel, tParams)
end

function AVSwitchAudioOutputInfo:PulseVolumeUp(tParams)
	DataLakeMetrics:MetricsCounter(string.format("AVSwitch PulseVolume %s", self:GetName()))
	AVSwitchCom_PulseVolumeUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartVolumeUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartVolumeUp")
	self:StartRampTimer("VolumeUp", tParams)
	AVSwitchCom_StartVolumeUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopVolumeUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopVolumeUp")
	self:StopRampTimer("VolumeUp")
	AVSwitchCom_StopVolumeUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:PulseVolumeDown(tParams)
	DataLakeMetrics:MetricsCounter(string.format("AVSwitch PulseVolume %s", self:GetName()))
	AVSwitchCom_PulseVolumeDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartVolumeDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartVolumeDown")
	self:StartRampTimer("VolumeDown", tParams)
	AVSwitchCom_StartVolumeDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopVolumeDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopVolumeDown")
	self:StopRampTimer("VolumeDown")
	AVSwitchCom_StopVolumeDown(self:GetName(), tParams)
end

----

function AVSwitchAudioOutputInfo:GetCurrentTrebleLevel()
	return self._CurrentTreble
end

function AVSwitchAudioOutputInfo:SetTrebleLevel(NewTrebleLevel)
	if(self._CurrentTreble ~= NewTrebleLevel) then
		self._CurrentTreble = NewTrebleLevel
		NOTIFY.AVS_TREBEL_LEVEL_CHANGED(self._CurrentTreble, self._BindingID, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:SendTrebleLevel(NewTreble, tParams)
	AVSwitchCom_SetCurrentTreble(self:GetName(), NewTreble, tParams)
end

function AVSwitchAudioOutputInfo:PulseTrebleUp(tParams)
	AVSwitchCom_PulseTrebleUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartTrebleUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartTrebleUp")
	self:StartRampTimer("TrebleUp", tParams)
	AVSwitchCom_StartTrebleUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopTrebleUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopTrebleUp")
	self:StopRampTimer("TrebleUp")
	AVSwitchCom_StopTrebleUp(self:GetName(), tParams)
end


function AVSwitchAudioOutputInfo:PulseTrebleDown(tParams)
	AVSwitchCom_PulseTrebleDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartTrebleDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartTrebleDown")
	self:StartRampTimer("TrebleDown", tParams)
	AVSwitchCom_StartTrebleDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopTrebleDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopTrebleDown")
	self:StopRampTimer("TrebleDown")
	AVSwitchCom_StopTrebleDown(self:GetName(), tParams)
end

----

function AVSwitchAudioOutputInfo:GetCurrentBassLevel()
	return self._CurrentBass
end

function AVSwitchAudioOutputInfo:SetBassLevel(NewBassLevel)
	if(self._CurrentBass ~= NewBassLevel) then
		self._CurrentBass = NewBassLevel
		NOTIFY.AVS_BASS_LEVEL_CHANGED(self._CurrentBass, self._BindingID, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:SendBassLevel(NewBass, tParams)
	AVSwitchCom_SetCurrentBass(self:GetName(), NewBass, tParams)
end

function AVSwitchAudioOutputInfo:PulseBassUp(tParams)
	AVSwitchCom_PulseBassUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartBassUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartBassUp")
	self:StartRampTimer("BassUp", tParams)
	AVSwitchCom_StartBassUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopBassUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopBassUp")
	self:StopRampTimer("BassUp")
	AVSwitchCom_StopBassUp(self:GetName(), tParams)
end


function AVSwitchAudioOutputInfo:PulseBassDown(tParams)
	AVSwitchCom_PulseBassDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartBassDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartBassDown")
	self:StartRampTimer("BassDown", tParams)
	AVSwitchCom_StartBassDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopBassDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopBassDown")
	self:StopRampTimer("BassDown")
	AVSwitchCom_StopBassDown(self:GetName(), tParams)
end

----

function AVSwitchAudioOutputInfo:GetCurrentBalanceLevel()
	return self._CurrentBalance
end

function AVSwitchAudioOutputInfo:SetBalance(NewBalanceLevel)
	if(self._CurrentBalance ~= NewBalanceLevel) then
		self._CurrentBalance = NewBalanceLevel
		NOTIFY.AVS_BALANCE_LEVEL_CHANGED(self._CurrentBass, self._BindingID, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:SendBalance(NewBass, tParams)
	AVSwitchCom_SetCurrentBalance(self:GetName(), NewBass, tParams)
end

function AVSwitchAudioOutputInfo:PulseBalanceUp(tParams)
	AVSwitchCom_PulseBalanceUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartBalanceUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartBalanceUp")
	self:StartRampTimer("BalanceUp", tParams)
	AVSwitchCom_StartBalanceUp(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopBalanceUp(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopBalanceUp")
	self:StopRampTimer("BalanceUp")
	AVSwitchCom_StopBalanceUp(self:GetName(), tParams)
end


function AVSwitchAudioOutputInfo:PulseBalanceDown(tParams)
	AVSwitchCom_PulseBalanceDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StartBalanceDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StartBalanceDown")
	self:StartRampTimer("BalanceDown", tParams)
	AVSwitchCom_StartBalanceDown(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:StopBalanceDown(tParams)
	LogTrace("AVSwitchAudioOutputInfo:StopBalanceDown")
	self:StopRampTimer("BalanceDown")
	AVSwitchCom_StopBalanceDown(self:GetName(), tParams)
end

----

function AVSwitchAudioOutputInfo:SetMuteFlag(MuteFlag)
	if(MuteFlag ~= self._CurrentMuted) then
		self._CurrentMuted = MuteFlag
		NOTIFY.AVS_MUTE_CHANGED(self._CurrentMuted, self._BindingID, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:GetMuteFlag()
	return self._CurrentMuted
end

function AVSwitchAudioOutputInfo:SendMuteOn(tParams)
	AVSwitchCom_MuteOn(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:SendMuteOff(tParams)
	AVSwitchCom_MuteOff(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:SendMuteToggle(tParams)
	AVSwitchCom_MuteToggle(self:GetName(), tParams)
end

----
function AVSwitchAudioOutputInfo:SetLoudnessFlag(LoudnessFlag)
	if(LoudnessFlag ~= self._CurrentLoudness) then
		self._CurrentLoudness = LoudnessFlag
		NOTIFY.AVS_LOUDNESS_CHANGED(self._CurrentLoudness, self._BindingID, self._Parent:GetBindingID())
	end
end

function AVSwitchAudioOutputInfo:GetLoudnessFlag()
	return self._CurrentLoudness
end

function AVSwitchAudioOutputInfo:SendLoudnessOn(tParams)
	AVSwitchCom_LoudnessOn(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:SendLoudnessOff(tParams)
	AVSwitchCom_LoudnessOff(self:GetName(), tParams)
end

function AVSwitchAudioOutputInfo:SendLoudnessToggle(tParams)
	AVSwitchCom_LoudnessToggle(self:GetName(), tParams)
end

----
--===========================================================================

AVSwitchVideoInputInfo = inheritsFrom(AVSwitchConnectionInfo)

function AVSwitchVideoInputInfo:construct(BindingID, InputName, Parent)
	self:super():construct(BindingID, InputName, Parent)

	self._IsMiniApp = false
end

function AVSwitchVideoInputInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
		if(CurClass.class == "RF_MINI_APP") then
			self._IsMiniApp = true
		end
	end
end

function AVSwitchVideoInputInfo:IsMiniAppBinding()
	return self._IsMiniApp
end

--==========================================================================
--==========================================================================

AVSwitchVideoOutputInfo = inheritsFrom(AVSwitchOutputInfo)

function AVSwitchVideoOutputInfo:construct(BindingID, OutputName, Parent)
	self:super():construct(BindingID, OutputName, Parent, self)

	self._CurrentInput = Parent:GetDummyVideoInput()
end


function AVSwitchVideoOutputInfo:SetInput(TargInput, ConnectExtraInfo, SendToDevice, SendNotify, IsRetry)
	self._CurrentInput = TargInput or self._Parent:GetDummyVideoInput()
	local ConnectType = "Video"
	ConnectExtraInfo = ConnectExtraInfo or {}
	
	if(self._CurrentInput:IsMiniAppBinding()) then
		ConnectType = "MiniApp"
		local AppProxyID = C4:GetBoundProviderDevice(self._Parent:GetProxyDeviceID(), self._CurrentInput:GetBindingID())
		local AppID = C4:GetBoundProviderDevice(AppProxyID, DEFAULT_PROXY_BINDINGID)
		for _, v in pairs(C4:GetDeviceVariables (AppID)) do
			ConnectExtraInfo[v.name] = v.value
		end
	end
	
	if(SendToDevice) then
		if(not IsRetry) then
			DataLakeMetrics:MetricsCounter(string.format("AVSwitch Video SetInput: %s", self:GetName()))
		end

		local tRetryParams = {
			WhichInput = self._CurrentInput,
			ExtraInfo = ConnectExtraInfo,
		}

		self._InputRetryTimer:SetRetryParameter(tRetryParams)
		self._InputRetryTimer:Start(self._CurrentInput:GetName())

		AVSwitchCom_SetInput(self:GetName(), self._CurrentInput:GetName(), ConnectType, ConnectExtraInfo)
	end
	
	if(SendNotify) then
		if(self._InputRetryTimer:IsStarted()) then
			self._InputRetryTimer:Fulfill(self._CurrentInput:GetName())
		end
		
		NOTIFY.AVS_INPUT_OUTPUT_CHANGED(self._CurrentInput:GetBindingID(), self:GetBindingID(), false, self._Parent:GetBindingID())
	end
end


function AVSwitchVideoOutputInfo:ConnectOutput(ExtraInfo, tParams, ConnectionType)
	AVSwitchCom_ConnectOutput(self:GetName(), ConnectionType or "Video", ExtraInfo, tParams)
end

function AVSwitchVideoOutputInfo:DisconnectOutput(ExtraInfo, tParams, ConnectionType)
	AVSwitchCom_DisconnectOutput(self:GetName(), ConnectionType or "Video", ExtraInfo, tParams)
end


----

AVSwitchRoomBindingInfo = inheritsFrom(AVSwitchConnectionInfo)

function AVSwitchRoomBindingInfo:construct(BindingID, RoomBindingName, Parent)
	self:super():construct(BindingID, RoomBindingName, Parent)

	self._RoomName = ""
end

function AVSwitchRoomBindingInfo:SetRoomName(RoomName)
	self._RoomName = RoomName
	--	LogInfo("AVSwitchRoomBindingInfo:SetRoomName %s -> %s", self:GetName(), self._RoomName)
	--	DCC 09/21/21  This doesn't seem useful.  Add a call to the communicator if there is ever a need for it.
end

function AVSwitchRoomBindingInfo:GetRoomName()
	return self._RoomName
end



--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]

function AVSwitchDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._PersistRecordName = string.format("AVSwitch%dPersist", tonumber(BindingID))
	PersistData[self._PersistRecordName] = C4:PersistGetValue(self._PersistRecordName)

	if(PersistData[self._PersistRecordName] == nil) then
		PersistData[self._PersistRecordName] = {

			_RetryTimerInfo = {
				Input =		{ Enabled = true,	Interval = 2000,	FallbackInterval = 2000,	IntervalUnits = "MILLISECONDS",	RetryMax = 4 },
			},

			_RampTimerInfo = {
				VolumeUp =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				VolumeDown =	{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				Up =			{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				Down =			{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				Left =			{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				Right =			{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				BassUp =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				BassDown =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				TrebleUp =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				TrebleDown =	{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				BalanceUp =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				BalanceDown =	{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				ScanFwd =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				ScanRev =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
			}
		}
		
		self:PersistSave()
	end

	self._PersistData = PersistData[self._PersistRecordName]
	self._RetryTimerInfo = self._PersistData._RetryTimerInfo
	self._RampTimerInfo = self._PersistData._RampTimerInfo
	
	self._AVSwitchOutputs = {}
	self._AVSwitchInputs = {}
	self._AllConnections = {}

	self._DummyAudioInput = nil
	self._DummyVideoInput = nil

	self._RampTimers = {}
	self._RampTimers.Up				= RampTimer:new(AVSwitchDevice.PrxStartUp, self)
	self._RampTimers.Down			= RampTimer:new(AVSwitchDevice.PrxStartDown, self)
	self._RampTimers.Left			= RampTimer:new(AVSwitchDevice.PrxStartLeft, self)
	self._RampTimers.Right			= RampTimer:new(AVSwitchDevice.PrxStartRight, self)
	self._RampTimers.ScanFwd		= RampTimer:new(AVSwitchDevice.PrxStartScanFwd, self)
	self._RampTimers.ScanRev		= RampTimer:new(AVSwitchDevice.PrxStartScanRev, self)
	
	for TimerName, TimerInst in pairs(self._RampTimers) do
		local CurInfo = self._RampTimerInfo[TimerName]
		TimerInst:SetEnableFlag(CurInfo.Enabled)
		TimerInst:SetInterval(CurInfo.Interval)
	end

end

----------------------

function AVSwitchDevice:PersistSave()
	C4:PersistSetValue(self._PersistRecordName, PersistData[self._PersistRecordName])
end

----------------------

function AVSwitchDevice:EnableRetryTimer()

	for _, CurOutput in pairs(self._AVSwitchOutputs) do
		CurOutput:EnableRetries()
	end

	self._RetryTimerInfo.Input.Enabled = true
	self:PersistSave()
end

function AVSwitchDevice:DisableRetryTimer()

	for _, CurOutput in pairs(self._AVSwitchOutputs) do
		CurOutput:DisableRetries()
	end

	self._RetryTimerInfo.Input.Enabled = false
	self:PersistSave()
end

function AVSwitchDevice:SetRetryTimerInterval(Interval)

	for _, CurOutput in pairs(self._AVSwitchOutputs) do
		CurOutput:SetRetryInterval(Interval)
	end

	self._RetryTimerInfo.Input.Interval = Interval
	self:PersistSave()
end

function AVSwitchDevice:SetRetryTimerMaxCount(Count)

	for _, CurOutput in pairs(self._AVSwitchOutputs) do
		CurOutput:SetRetryMaxCount(Count)
	end

	self._RetryTimerInfo.Input.RetryMax = Count
	self:PersistSave()
end

function AVSwitchDevice:GetInputRetryInfo()
	return self._RetryTimerInfo.Input
end

----------------------
function AVSwitchDevice:EnableRampTimers()
	for TimerName, _ in pairs(self._RampTimers) do
		self:EnableRampTimer(TimerName)
	end
end

function AVSwitchDevice:DisableRampTimers()
	for TimerName, _ in pairs(self._RampTimers) do
		self:DisableRampTimer(TimerName)
	end
end


function AVSwitchDevice:StartRampTimer(TimerName, CallbackParam)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetRampParameter(CallbackParam)
		TargTimer:Start()
	else
		LogWarn("AVSwitchDevice:StartRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchDevice:StopRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:Kill()
	else
		LogWarn("AVSwitchDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchDevice:IsRamping(TimerName)
	local RampingFlag = false
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		RampingFlag = TargTimer:IsRamping()
	else
		LogWarn("AVSwitchDevice:IsRamping  Undefined Ramp Timer: %s", tostring(TimerName))
	end
	
	return RampingFlag
end

function AVSwitchDevice:EnableRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetEnableFlag(true)
		self._RampTimerInfo[TimerName].Enabled = true
		self:PersistSave()
	else
		LogWarn("AVSwitchDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchDevice:DisableRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetEnableFlag(false)
		self._RampTimerInfo[TimerName].Enabled = false
		self:PersistSave()
	else
		LogWarn("AVSwitchDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchDevice:SetRampTimerInterval(TimerName, Interval)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetInterval(Interval)
		self._RampTimerInfo[TimerName].Interval = Interval
		self:PersistSave()
	else
		LogWarn("AVSwitchDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function AVSwitchDevice:SetAllRampTimerIntervals(Interval)
	for TimerName, _ in pairs(self._RampTimers) do
		self:SetRampTimerInterval(TimerName, Interval)
	end
end

-------

function AVSwitchDevice.FixAudName(InName)
	return string.format("A_%s", tostring(InName))
end

function AVSwitchDevice.FixVidName(InName)
	return string.format("V_%s", tostring(InName))
end

function AVSwitchDevice.MakeAudioKey(BindingVal)
	local KeyIndex = tonumber(BindingVal) % 1000
	return string.format("A_%03d", KeyIndex)
end

function AVSwitchDevice.MakeVideoKey(BindingVal)
	local KeyIndex = tonumber(BindingVal) % 1000
	return string.format("V_%03d", KeyIndex)
end


function AVSwitchDevice:GetDummyAudioInput()
	return self._DummyAudioInput
end

function AVSwitchDevice:GetDummyVideoInput()
	return self._DummyVideoInput
end

function AVSwitchDevice:PowerSetting(IsOn)
	if(IsOn) then
		NOTIFY.AVS_ON(self._BindingID)
	else
		NOTIFY.AVS_OFF(self._BindingID)
	end
end

function AVSwitchDevice:InitialSetup()
	
	AVSwitchDevice.UpdateRetryProperties(self._RetryTimerInfo)
	
	if(PersistData.AVSwitchPersist == nil) then
		PersistAVSwitchData = {}
		PersistData.AVSwitchPersist = PersistAVSwitchData
		
		PersistAVSwitchData._Capabilities = {}
		self:InitializeCapabilities()

	else
		PersistAVSwitchData = PersistData.AVSwitchPersist
	end

	self._DummyAudioInput = AVSwitchAudioInputInfo:new(-1, "", self)
	self._DummyVideoInput = AVSwitchVideoInputInfo:new(-1, "", self)

	-- Populate Audio and Video Inputs and Outputs
	local AllBindingTab = C4:GetBindingsByDevice(self:GetProxyDeviceID()).bindings
	for _, CurBindingInfo in pairs(AllBindingTab) do
		LogInfo("Get info for binding: %s  %s", tostring(CurBindingInfo.bindingid), CurBindingInfo.name)
		if(CurBindingInfo.type == 6) then	-- audio binding
			if(CurBindingInfo.provider) then
				local NewAudioOutput = AVSwitchAudioOutputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
				NewAudioOutput:GetNeededInfo(CurBindingInfo)
				self._AVSwitchOutputs[AVSwitchDevice.MakeAudioKey(CurBindingInfo.bindingid)] = NewAudioOutput
				self._AVSwitchOutputs[AVSwitchDevice.FixAudName(CurBindingInfo.name)] = NewAudioOutput
				self._AllConnections[tostring(CurBindingInfo.bindingid)] = NewAudioOutput
--				LogInfo(NewAudioOutput)
			else
				local NewAudioInput = AVSwitchAudioInputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
				NewAudioInput:GetNeededInfo(CurBindingInfo)
				self._AVSwitchInputs[AVSwitchDevice.MakeAudioKey(CurBindingInfo.bindingid)] = NewAudioInput
				self._AVSwitchInputs[AVSwitchDevice.FixAudName(CurBindingInfo.name)] = NewAudioInput
				self._AllConnections[tostring(CurBindingInfo.bindingid)] = NewAudioInput
--				LogInfo(NewAudioInput)
			end
			
		elseif(CurBindingInfo.type == 5) then	-- video binding
			if(CurBindingInfo.provider) then
				local NewVideoOutput = AVSwitchVideoOutputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
				NewVideoOutput:GetNeededInfo(CurBindingInfo)
				self._AVSwitchOutputs[AVSwitchDevice.MakeVideoKey(CurBindingInfo.bindingid)] = NewVideoOutput
				self._AVSwitchOutputs[AVSwitchDevice.FixVidName(CurBindingInfo.name)] = NewVideoOutput
				self._AllConnections[tostring(CurBindingInfo.bindingid)] = NewVideoOutput
--				LogInfo(NewVideoOutput)
			else
				local NewVideoInput = AVSwitchVideoInputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
				NewVideoInput:GetNeededInfo(CurBindingInfo)
				self._AVSwitchInputs[AVSwitchDevice.MakeVideoKey(CurBindingInfo.bindingid)] = NewVideoInput
				self._AVSwitchInputs[AVSwitchDevice.FixVidName(CurBindingInfo.name)] = NewVideoInput
				self._AllConnections[tostring(CurBindingInfo.bindingid)] = NewVideoInput
--				LogInfo(NewVideoInput)
			end
			
		elseif(CurBindingInfo.type == 7) then	-- room binding
			local NewRoomConnection = AVSwitchRoomBindingInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name, self)
			NewRoomConnection:GetNeededInfo(CurBindingInfo)
			self._AllConnections[tostring(CurBindingInfo.bindingid)] = NewRoomConnection
--			LogInfo(NewRoomConnection)
			
		end
	end

	if(self._RetryTimerInfo.Input.Enabled) then
		self:EnableRetryTimer()
	else
		self:DisableRetryTimer()
	end
end


function AVSwitchDevice:InitializeCapabilities()
--	PersistAVSwitchData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
end



-------------

function AVSwitchDevice:GetAVSwitchAudioOutput(OutputID)
	return self._AVSwitchOutputs[AVSwitchDevice.MakeAudioKey(OutputID)]
end

function AVSwitchDevice:GetAVSwitchVideoOutput(OutputID)
	return self._AVSwitchOutputs[AVSwitchDevice.MakeVideoKey(OutputID)]
end

function AVSwitchDevice:GetAudioOutputFromName(OutputName)
	return self._AVSwitchOutputs[AVSwitchDevice.FixAudName(OutputName)]
end

function AVSwitchDevice:GetAudioInputFromName(OutputName)
	return self._AVSwitchInputs[AVSwitchDevice.FixAudName(OutputName)]
end

function AVSwitchDevice:GetVideoOutputFromName(OutputName)
	return self._AVSwitchOutputs[AVSwitchDevice.FixVidName(OutputName)]
end

function AVSwitchDevice:GetVideoInputFromName(OutputName)
	return self._AVSwitchInputs[AVSwitchDevice.FixVidName(OutputName)]
end



function AVSwitchDevice:AssignInputOutput(OutputName, InputName, DoAudio, DoVideo)
	LogTrace("AVSwitchDevice:AssignInputOutput %s -> %s", InputName, OutputName)
	local AudIn = self:GetAudioInputFromName(InputName) or self:GetDummyAudioInput()
	local AudOut = self:GetAudioOutputFromName(OutputName)
	local VidIn = self:GetVideoInputFromName(InputName) or self:GetDummyVideoInput()
	local VidOut = self:GetVideoOutputFromName(OutputName)
	
	if(DoAudio) then
		if(AudOut ~= nil) then
			AudOut:SetInput(AudIn, {}, false, true, false)
		else
			LogDebug("AVSwitchDevice:AssignInputOutput No Audio %s", tostring(OutputName))
		end
	end

	if(DoVideo) then
		if(VidOut ~= nil) then
			VidOut:SetInput(VidIn, {}, false, true, false)
		else
			LogDebug("AVSwitchDevice:AssignInputOutput No Video %s", tostring(OutputName))
		end
	end
end



function AVSwitchDevice:GetCurrentVolume(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentVolume()
end

function AVSwitchDevice:SetVolumeLevel(OutputName, TargVolLevel)
	self:GetAudioOutputFromName(OutputName):SetVolume(TargVolLevel)
end


function AVSwitchDevice:IsMuted(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetMuteFlag()
end

function AVSwitchDevice:SetMuteState(OutputName, MuteFlag)
	self:GetAudioOutputFromName(OutputName):SetMuteFlag(MuteFlag)
end

function AVSwitchDevice:IsLoudnessOn(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetLoudnessFlag()
end

function AVSwitchDevice:SetLoudnessState(OutputName, LoudnessFlag)
	self:GetAudioOutputFromName(OutputName):SetLoudnessFlag(LoudnessFlag)
end


function AVSwitchDevice:GetCurrentTrebleLevel(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentTrebleLevel()
end

function AVSwitchDevice:SetTrebleLevel(OutputName, Level)
	self:GetAudioOutputFromName(OutputName):SetTrebleLevel(Level)
end


function AVSwitchDevice:GetCurrentBassLevel(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentBassLevel()
end

function AVSwitchDevice:SetBassLevel(OutputName, Level)
	self:GetAudioOutputFromName(OutputName):SetBassLevel(Level)
end

function AVSwitchDevice:GetCurrentBalanceLevel(OutputName)
	return self:GetAudioOutputFromName(OutputName):GetCurrentBalanceLevel()
end

function AVSwitchDevice:SetBalanceLevel(OutputName, Level)
	self:GetAudioOutputFromName(OutputName):SetBalanceLevel(Level)
end


--=============================================================================
--=============================================================================

function AVSwitchDevice:PrxOn(tParams)
	LogTrace("AVSwitchDevice:PrxOn")
	AVSwitchCom_On(tParams)
end

function AVSwitchDevice:PrxOff(tParams)
	LogTrace("AVSwitchDevice:PrxOff")
	AVSwitchCom_Off(tParams)
end


function AVSwitchDevice:PrxSetInput(tParams, IsRetry)
	LogTrace("AVSwitchDevice:PrxSetInput")
	LogInfo(tParams)

	local DoAudio = toboolean(tParams.AUDIO)
	local DoVideo = toboolean(tParams.VIDEO)

	local VideoInputKey = AVSwitchDevice.MakeVideoKey(tParams.INPUT)
	local VideoOutputKey = AVSwitchDevice.MakeVideoKey(tParams.OUTPUT)
	local AudioInputKey = AVSwitchDevice.MakeAudioKey(tParams.INPUT)
	local AudioOutputKey = AVSwitchDevice.MakeAudioKey(tParams.OUTPUT)

	local VideoInput = self._AVSwitchInputs[VideoInputKey]
	local VideoOutput = self._AVSwitchOutputs[VideoOutputKey]
	local AudioInput = self._AVSwitchInputs[AudioInputKey]
	local AudioOutput = self._AVSwitchOutputs[AudioOutputKey]

	-- Pass along all the parameters except for the INPUT and OUTPUT names
	local OtherParams = {}
	for k, v in pairs(tParams) do
		if((k ~= "INPUT") and (k ~= "OUTPUT")) then
			OtherParams[k] = v
		end
	end

	if(DoVideo) then
		if((VideoOutput ~= nil) and (VideoInput ~= nil)) then
			VideoOutput:SetInput(VideoInput, OtherParams, true, false, false)
		else
			LogDebug("Video binding command not sent %s <- %s", tostring(VideoOutputKey), tostring(VideoInputKey))
		end
	end

	if(DoAudio) then
		if((AudioOutput ~= nil) and (AudioInput ~= nil)) then
			AudioOutput:SetInput(AudioInput, OtherParams, true, false, false)
		else
			LogDebug("Audio binding command not sent  %s <- %s", tostring(AudioOutputKey), tostring(AudioInputKey))
		end
	end
end


function AVSwitchDevice:PrxConnectOutput(tParams)
	LogTrace("AVSwitchDevice:PrxConnectOutput")
	LogInfo(tParams)
	-- pass along all the parameters that aren't being handled here
	local ExtraInfo = {}
	for k, v in pairs(tParams) do
		if((k ~= "OUTPUT") and (k ~= "VIDEO") and (k ~= "AUDIO")) then
			ExtraInfo[k] = v
		end
	end

	if(toboolean(tParams.VIDEO)) then
		local TargOutput = self:GetAVSwitchVideoOutput(tParams.OUTPUT)
		if(TargOutput) then
			TargOutput:ConnectOutput(ExtraInfo, tParams)
		else
			LogWarn("PrxConnectOutput Video Output instance not defined for %s", tostring(tParams.OUTPUT))
		end
	
	elseif(toboolean(tParams.AUDIO)) then
		local TargOutput = self:GetAVSwitchAudioOutput(tParams.OUTPUT)
		if(TargOutput) then
			TargOutput:ConnectOutput(ExtraInfo, tParams)
		else
			-- Kludge Alert!  Handle the case where HDMI is being used for audio-only streaming, but there
			-- is no audio connection specifically defined
			if(tParams.CLASS == "HDMI") then
				TargOutput = self:GetAVSwitchVideoOutput(tParams.OUTPUT)
				if(TargOutput) then
					TargOutput:ConnectOutput(ExtraInfo, tParams, "Audio")
				else
					LogWarn("PrxConnectOutput Video Output instance not defined for HDMI %s", tostring(tParams.OUTPUT))
				end
		
			else
				LogWarn("PrxConnectOutput Audio Output instance not defined for %s", tostring(tParams.OUTPUT))
			end
		end
	
	else
		LogError("AVSwitchDevice:PrxConnectOutput  Unhandled Class Type: %s", tostring(tParams.CLASS))
	end
end

function AVSwitchDevice:PrxDisconnectOutput(tParams)
	LogTrace("AVSwitchDevice:PrxDisconnectOutput")
	LogInfo(tParams)
	-- pass along all the parameters that aren't being handled here
	local ExtraInfo = {}
	for k, v in pairs(tParams) do
		if((k ~= "OUTPUT") and (k ~= "VIDEO") and (k ~= "AUDIO")) then
			ExtraInfo[k] = v
		end
	end
	
	if(toboolean(tParams.VIDEO)) then
		local TargOutput = self:GetAVSwitchVideoOutput(tParams.OUTPUT)
		if(TargOutput) then
			TargOutput:DisconnectOutput(ExtraInfo, tParams)
		else
			LogDebug("PrxDisconnectOutput Video Output instance not defined for %s", tostring(tParams.OUTPUT))
		end
	
	elseif(toboolean(tParams.AUDIO)) then
		local TargOutput = self:GetAVSwitchAudioOutput(tParams.OUTPUT)
		if(TargOutput) then
			TargOutput:DisconnectOutput(ExtraInfo, tParams)
		else
			-- Kludge Alert!  Handle the case where HDMI is being used for audio-only streaming, but there
			-- is no audio connection specifically defined
			if(tParams.CLASS == "HDMI") then
				TargOutput = self:GetAVSwitchVideoOutput(tParams.OUTPUT)
				if(TargOutput) then
					TargOutput:DisconnectOutput(ExtraInfo, tParams, "Audio")
				else
					LogWarn("PrxDisconnectOutput Video Output instance not defined for HDMI %s", tostring(tParams.OUTPUT))
				end
		
			else
				LogWarn("PrxDisconnectOutput Audio Output instance not defined for %s", tostring(tParams.OUTPUT))
			end
		end
	
	else
		LogError("AVSwitchDevice:PrxDisconnectOutput  Unhandled Class Type: %s", tostring(tParams.CLASS))
	end
end


function AVSwitchDevice:PrxBindingChangeAction(tParams)
	LogTrace("AVSwitchDevice:PrxBindingChangeAction")
	LogInfo(tParams)
	self._AllConnections[tostring(tParams.BINDING_ID)]:SetBoundFlag(toboolean(tParams.IS_BOUND))
end

function AVSwitchDevice:PrxSetRoomBindingName(tParams)
	LogTrace("AVSwitchDevice:PrxSetRoomBindingName")
	LogInfo(tParams)
	self._AllConnections[tostring(tParams.OUTPUT)]:SetRoomName(tParams.PartnerDevice)

end


function AVSwitchDevice:PrxSetVolumeLevel(tParams)
	LogTrace("AVSwitchDevice:PrxSetVolumeLevel")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendVolumeLevel(tParams.LEVEL, tParams)
end


function AVSwitchDevice:PrxPulseVolumeUp(tParams)
	LogTrace("AVSwitchDevice:PrxPulseVolumeUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseVolumeUp(tParams)
end

function AVSwitchDevice:PrxStartVolumeUp(tParams)
	LogTrace("AVSwitchDevice:PrxStartVolumeUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartVolumeUp(tParams)
end

function AVSwitchDevice:PrxStopVolumeUp(tParams)
	LogTrace("AVSwitchDevice:PrxStopVolumeUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopVolumeUp(tParams)
end


function AVSwitchDevice:PrxPulseVolumeDown(tParams)
	LogTrace("AVSwitchDevice:PrxPulseVolumeDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseVolumeDown(tParams)
end

function AVSwitchDevice:PrxStartVolumeDown(tParams)
	LogTrace("AVSwitchDevice:PrxStartVolumeDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartVolumeDown(tParams)
end

function AVSwitchDevice:PrxStopVolumeDown(tParams)
	LogTrace("AVSwitchDevice:PrxStopVolumeDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopVolumeDown(tParams)
end


function AVSwitchDevice:PrxSetTrebleLevel(tParams)
	LogTrace("AVSwitchDevice:PrxSetTrebleLevel")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendTrebleLevel(tParams.LEVEL, tParams)
end

function AVSwitchDevice:PrxPulseTrebleUp(tParams)
	LogTrace("AVSwitchDevice:PrxPulseTrebleUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseTrebleUp(tParams)
end

function AVSwitchDevice:PrxStartTrebleUp(tParams)
	LogTrace("AVSwitchDevice:PrxStartTrebleUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartTrebleUp(tParams)
end

function AVSwitchDevice:PrxStopTrebleUp(tParams)
	LogTrace("AVSwitchDevice:PrxStopTrebleUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopTrebleUp(tParams)
end


function AVSwitchDevice:PrxPulseTrebleDown(tParams)
	LogTrace("AVSwitchDevice:PrxPulseTrebleDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseTrebleDown(tParams)
end

function AVSwitchDevice:PrxStartTrebleDown(tParams)
	LogTrace("AVSwitchDevice:PrxStartTrebleDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartTrebleDown(tParams)
end

function AVSwitchDevice:PrxStopTrebleDown(tParams)
	LogTrace("AVSwitchDevice:PrxStopTrebleDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopTrebleDown(tParams)
end


function AVSwitchDevice:PrxSetBassLevel(tParams)
	LogTrace("AVSwitchDevice:PrxSetBassLevel")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendBassLevel(tParams.LEVEL, tParams)
end

function AVSwitchDevice:PrxPulseBassUp(tParams)
	LogTrace("AVSwitchDevice:PrxPulseBassUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseBassUp(tParams)
end

function AVSwitchDevice:PrxStartBassUp(tParams)
	LogTrace("AVSwitchDevice:PrxStartBassUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartBassUp(tParams)
end

function AVSwitchDevice:PrxStopBassUp(tParams)
	LogTrace("AVSwitchDevice:PrxStopBassUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopBassUp(tParams)
end


function AVSwitchDevice:PrxPulseBassDown(tParams)
	LogTrace("AVSwitchDevice:PrxPulseBassDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseBassDown(tParams)
end

function AVSwitchDevice:PrxStartBassDown(tParams)
	LogTrace("AVSwitchDevice:PrxStartBassDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartBassDown(tParams)
end

function AVSwitchDevice:PrxStopBassDown(tParams)
	LogTrace("AVSwitchDevice:PrxStopBassDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopBassDown(tParams)
end

function AVSwitchDevice:PrxSetBalance(tParams)
	LogTrace("AVSwitchDevice:PrxSetBalance")
	LogInfo(tParams)
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendBalance(tParams.LEVEL, tParams)
end

function AVSwitchDevice:PrxPulseBalanceUp(tParams)
	LogTrace("AVSwitchDevice:PrxPulseBalanceUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseBalanceUp(tParams)
end

function AVSwitchDevice:PrxStartBalanceUp(tParams)
	LogTrace("AVSwitchDevice:PrxStartBalanceUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartBalanceUp(tParams)
end

function AVSwitchDevice:PrxStopBalanceUp(tParams)
	LogTrace("AVSwitchDevice:PrxStopBalanceUp")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopBalanceUp(tParams)
end


function AVSwitchDevice:PrxPulseBalanceDown(tParams)
	LogTrace("AVSwitchDevice:PrxPulseBalanceDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):PulseBalanceDown(tParams)
end

function AVSwitchDevice:PrxStartBalanceDown(tParams)
	LogTrace("AVSwitchDevice:PrxStartBalanceDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StartBalanceDown(tParams)
end

function AVSwitchDevice:PrxStopBalanceDown(tParams)
	LogTrace("AVSwitchDevice:PrxStopBalanceDown")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):StopBalanceDown(tParams)
end


function AVSwitchDevice:PrxMuteOn(tParams)
	LogTrace("AVSwitchDevice:PrxMuteOn")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendMuteOn(tParams)
end

function AVSwitchDevice:PrxMuteOff(tParams)
	LogTrace("AVSwitchDevice:PrxMuteOff")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendMuteOff(tParams)
end

function AVSwitchDevice:PrxMuteToggle(tParams)
	LogTrace("AVSwitchDevice:PrxMuteToggle")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendMuteToggle(tParams)
end

function AVSwitchDevice:PrxLoudnessOn(tParams)
	LogTrace("AVSwitchDevice:PrxLoudnessOn")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendLoudnessOn(tParams)
end

function AVSwitchDevice:PrxLoudnessOff(tParams)
	LogTrace("AVSwitchDevice:PrxLoudnessOff")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendLoudnessOff(tParams)
end

function AVSwitchDevice:PrxLoudnessToggle(tParams)
	LogTrace("AVSwitchDevice:PrxLoudnessToggle")
	self:GetAVSwitchAudioOutput(tParams.OUTPUT):SendLoudnessToggle(tParams)
end


function AVSwitchDevice:PrxNumber0(tParams)
	LogTrace("AVSwitchDevice:PrxNumber0")
	AVSwitchCom_Number0(tParams)
end

function AVSwitchDevice:PrxNumber1(tParams)
	LogTrace("AVSwitchDevice:PrxNumber1")
	AVSwitchCom_Number1(tParams)
end

function AVSwitchDevice:PrxNumber2(tParams)
	LogTrace("AVSwitchDevice:PrxNumber2")
	AVSwitchCom_Number2(tParams)
end

function AVSwitchDevice:PrxNumber3(tParams)
	LogTrace("AVSwitchDevice:PrxNumber3")
	AVSwitchCom_Number3(tParams)
end

function AVSwitchDevice:PrxNumber4(tParams)
	LogTrace("AVSwitchDevice:PrxNumber4")
	AVSwitchCom_Number4(tParams)
end

function AVSwitchDevice:PrxNumber5(tParams)
	LogTrace("AVSwitchDevice:PrxNumber5")
	AVSwitchCom_Number5(tParams)
end

function AVSwitchDevice:PrxNumber6(tParams)
	LogTrace("AVSwitchDevice:PrxNumber6")
	AVSwitchCom_Number6(tParams)
end

function AVSwitchDevice:PrxNumber7(tParams)
	LogTrace("AVSwitchDevice:PrxNumber7")
	AVSwitchCom_Number7(tParams)
end

function AVSwitchDevice:PrxNumber8(tParams)
	LogTrace("AVSwitchDevice:PrxNumber8")
	AVSwitchCom_Number8(tParams)
end

function AVSwitchDevice:PrxNumber9(tParams)
	LogTrace("AVSwitchDevice:PrxNumber9")
	AVSwitchCom_Number9(tParams)
end

function AVSwitchDevice:PrxStar(tParams)
	LogTrace("AVSwitchDevice:PrxStar")
	AVSwitchCom_Star(tParams)
end

function AVSwitchDevice:PrxPound(tParams)
	LogTrace("AVSwitchDevice:PrxPound")
	AVSwitchCom_Pound(tParams)
end




function AVSwitchDevice:PrxInfo(tParams)
	LogTrace("AVSwitchDevice:PrxInfo")
	AVSwitchCom_Info(tParams)
end

function AVSwitchDevice:PrxGuide(tParams)
	LogTrace("AVSwitchDevice:PrxGuide")
	AVSwitchCom_Guide(tParams)
end

function AVSwitchDevice:PrxMenu(tParams)
	LogTrace("AVSwitchDevice:PrxMenu")
	AVSwitchCom_Menu(tParams)
end

function AVSwitchDevice:PrxCancel(tParams)
	LogTrace("AVSwitchDevice:PrxCancel")
	AVSwitchCom_Cancel(tParams)
end

function AVSwitchDevice:PrxUp(tParams)
	LogTrace("AVSwitchDevice:PrxUp")
	AVSwitchCom_Up(tParams)
end

function AVSwitchDevice:PrxDown(tParams)
	LogTrace("AVSwitchDevice:PrxDown")
	AVSwitchCom_Down(tParams)
end

function AVSwitchDevice:PrxLeft(tParams)
	LogTrace("AVSwitchDevice:PrxLeft")
	AVSwitchCom_Left(tParams)
end

function AVSwitchDevice:PrxRight(tParams)
	LogTrace("AVSwitchDevice:PrxRight")
	AVSwitchCom_Right(tParams)
end

function AVSwitchDevice:PrxStartDown(tParams)
	LogTrace("AVSwitchDevice:PrxStartDown")
	self:StartRampTimer("Down", tParams)
	AVSwitchCom_StartDown(tParams)
end

function AVSwitchDevice:PrxStartUp(tParams)
	LogTrace("AVSwitchDevice:PrxStartUp")
	self:StartRampTimer("Up", tParams)
	AVSwitchCom_StartUp(tParams)
end

function AVSwitchDevice:PrxStartLeft(tParams)
	LogTrace("AVSwitchDevice:PrxStartLeft")
	self:StartRampTimer("Left", tParams)
	AVSwitchCom_StartLeft(tParams)
end

function AVSwitchDevice:PrxStartRight(tParams)
	LogTrace("AVSwitchDevice:PrxStartRight")
	self:StartRampTimer("Right", tParams)
	AVSwitchCom_StartRight(tParams)
end

function AVSwitchDevice:PrxStopDown(tParams)
	LogTrace("AVSwitchDevice:PrxStopDown")
	self:StopRampTimer("Down")
	AVSwitchCom_StopDown(tParams)
end

function AVSwitchDevice:PrxStopUp(tParams)
	LogTrace("AVSwitchDevice:PrxStopUp")
	self:StopRampTimer("Up")
	AVSwitchCom_StopUp(tParams)
end

function AVSwitchDevice:PrxStopLeft(tParams)
	LogTrace("AVSwitchDevice:PrxStopLeft")
	self:StopRampTimer("Left")
	AVSwitchCom_StopLeft(tParams)
end

function AVSwitchDevice:PrxStopRight(tParams)
	LogTrace("AVSwitchDevice:PrxStopRight")
	self:StopRampTimer("Right")
	AVSwitchCom_StopRight(tParams)
end

function AVSwitchDevice:PrxEnter(tParams)
	LogTrace("AVSwitchDevice:PrxEnter")
	AVSwitchCom_Enter(tParams)
end

function AVSwitchDevice:PrxExit(tParams)
	LogTrace("AVSwitchDevice:PrxExit")
	AVSwitchCom_Exit(tParams)
end

function AVSwitchDevice:PrxHome(tParams)
	LogTrace("AVSwitchDevice:PrxHome")
	AVSwitchCom_Home(tParams)
end

function AVSwitchDevice:PrxSettings(tParams)
	LogTrace("AVSwitchDevice:PrxSettings")
	AVSwitchCom_Settings(tParams)
end

function AVSwitchDevice:PrxPlay(tParams)
	LogTrace("AVSwitchDevice:PrxPlay")
	AVSwitchCom_Play(tParams)
end

function AVSwitchDevice:PrxStop(tParams)
	LogTrace("AVSwitchDevice:PrxStop")
	AVSwitchCom_Stop(tParams)
end

function AVSwitchDevice:PrxPause(tParams)
	LogTrace("AVSwitchDevice:PrxPause")
	AVSwitchCom_Pause(tParams)
end

function AVSwitchDevice:PrxRecord(tParams)
	LogTrace("AVSwitchDevice:PrxRecord")
	AVSwitchCom_Record(tParams)
end

function AVSwitchDevice:PrxSkipFwd(tParams)
	LogTrace("AVSwitchDevice:PrxSkipFwd")
	AVSwitchCom_SkipFwd(tParams)
end

function AVSwitchDevice:PrxSkipRev(tParams)
	LogTrace("AVSwitchDevice:PrxSkipRev")
	AVSwitchCom_SkipRev(tParams)
end

function AVSwitchDevice:PrxScanFwd(tParams)
	LogTrace("AVSwitchDevice:PrxScanFwd")
	AVSwitchCom_ScanFwd(tParams)
end

function AVSwitchDevice:PrxScanRev(tParams)
	LogTrace("AVSwitchDevice:PrxScanRev")
	AVSwitchCom_ScanRev(tParams)
end



function AVSwitchDevice:PrxRecall(tParams)
	LogTrace("AVSwitchDevice:PrxRecall")
	AVSwitchCom_Recall(tParams)
end

function AVSwitchDevice:PrxClose(tParams)
	LogTrace("AVSwitchDevice:PrxClose")
	AVSwitchCom_Close(tParams)
end

function AVSwitchDevice:PrxProgramA(tParams)
	LogTrace("AVSwitchDevice:PrxProgramA")
	AVSwitchCom_ProgramA(tParams)
end

function AVSwitchDevice:PrxProgramB(tParams)
	LogTrace("AVSwitchDevice:PrxProgramB")
	AVSwitchCom_ProgramB(tParams)
end

function AVSwitchDevice:PrxProgramC(tParams)
	LogTrace("AVSwitchDevice:PrxProgramC")
	AVSwitchCom_ProgramC(tParams)
end

function AVSwitchDevice:PrxProgramD(tParams)
	LogTrace("AVSwitchDevice:PrxProgramD")
	AVSwitchCom_ProgramD(tParams)
end

function AVSwitchDevice:PrxPageUp(tParams)
	LogTrace("AVSwitchDevice:PrxPageUp")
	AVSwitchCom_PageUp(tParams)
end

function AVSwitchDevice:PrxPageDown(tParams)
	LogTrace("AVSwitchDevice:PrxPageDown")
	AVSwitchCom_PageDown(tParams)
end

function AVSwitchDevice:PrxStartScanFwd(tParams)
	LogTrace("AVSwitchDevice:PrxStartScanFwd")
	self:StartRampTimer("ScanFwd", tParams)
	AVSwitchCom_StartScanFwd(tParams)
end

function AVSwitchDevice:PrxStartScanRev(tParams)
	LogTrace("AVSwitchDevice:PrxStartScanRev")
	self:StartRampTimer("ScanRev", tParams)
	AVSwitchCom_StartScanRev(tParams)
end

function AVSwitchDevice:PrxStopScanFwd(tParams)
	LogTrace("AVSwitchDevice:PrxStopScanFwd")
	self:StopRampTimer("ScanFwd")
	AVSwitchCom_StopScanFwd(tParams)
end

function AVSwitchDevice:PrxStopScanRev(tParams)
	LogTrace("AVSwitchDevice:PrxStopScanRev")
	self:StopRampTimer("ScanRev")
	AVSwitchCom_StopScanRev(tParams)
end


function AVSwitchDevice:PrxPassthrough(tParams)
	LogTrace("AVSwitchDevice:PrxPassthrough")
	LogInfo(tParams)
	
	local PassThroughCmd = tParams.PASSTHROUGH_COMMAND
	if(AVSwitchDevice._PassThroughCommandRoutines[PassThroughCmd] ~= nil) then
		AVSwitchDevice._PassThroughCommandRoutines[PassThroughCmd](self, tParams)
	else
		LogInfo("AVSwitchDevice:PrxPassthrough  Unhandled Command: %s", PassThroughCmd)
	end
end

--======================================================

AVSwitchDevice._PassThroughCommandRoutines = {
	['LEFT']		= AVSwitchDevice.PrxLeft,
	['RIGHT']		= AVSwitchDevice.PrxRight,
	['UP']			= AVSwitchDevice.PrxUp,
	['DOWN']		= AVSwitchDevice.PrxDown,
	['MENU']		= AVSwitchDevice.PrxMenu,
	['CANCEL']		= AVSwitchDevice.PrxCancel,
	['INFO']		= AVSwitchDevice.PrxInfo,
	['EJECT']		= AVSwitchDevice.PrxEject,
	['ENTER']		= AVSwitchDevice.PrxEnter,

	['PLAY']			= AVSwitchDevice.PrxPlay,
	['STOP']			= AVSwitchDevice.PrxStop,
	['PAUSE']			= AVSwitchDevice.PrxPause,
	['RECORD']			= AVSwitchDevice.PrxRecord,
	['SKIP_FWD']		= AVSwitchDevice.PrxSkipFwd,
	['SKIP_REV']		= AVSwitchDevice.PrxSkipRev,
	['SCAN_FWD']		= AVSwitchDevice.PrxScanFwd,
	['SCAN_REV']		= AVSwitchDevice.PrxScanRev,
	
	['PROGRAM_A']		= AVSwitchDevice.PrxProgramA,
	['PROGRAM_B']		= AVSwitchDevice.PrxProgramB,
	['PROGRAM_C']		= AVSwitchDevice.PrxProgramC,
	['PROGRAM_D']		= AVSwitchDevice.PrxProgramD,
	['PAGE_UP']			= AVSwitchDevice.PrxPageUp,
	['PAGE_DOWN']		= AVSwitchDevice.PrxPageDown,
	['NUMBER_0']		= AVSwitchDevice.PrxNumber0,
	['NUMBER_1']		= AVSwitchDevice.PrxNumber1,
	['NUMBER_2']		= AVSwitchDevice.PrxNumber2,
	['NUMBER_3']		= AVSwitchDevice.PrxNumber3,
	['NUMBER_4']		= AVSwitchDevice.PrxNumber4,
	['NUMBER_5']		= AVSwitchDevice.PrxNumber5,
	['NUMBER_6']		= AVSwitchDevice.PrxNumber6,
	['NUMBER_7']		= AVSwitchDevice.PrxNumber7,
	['NUMBER_8']		= AVSwitchDevice.PrxNumber8,
	['NUMBER_9']		= AVSwitchDevice.PrxNumber9,
	['STAR']			= AVSwitchDevice.PrxStar,
	['POUND']			= AVSwitchDevice.PrxPound,
	['START_SCAN_FWD']  = AVSwitchDevice.PrxStartScanFwd,
	['START_SCAN_REV']  = AVSwitchDevice.PrxStartScanRev,
	['STOP_SCAN_FWD']   = AVSwitchDevice.PrxStopScanFwd,
	['STOP_SCAN_REV']   = AVSwitchDevice.PrxStopScanRev,
	['START_LEFT']      = AVSwitchDevice.PrxStartLeft,
	['START_RIGHT']     = AVSwitchDevice.PrxStartRight,
	['START_UP']        = AVSwitchDevice.PrxStartUp,
	['START_DOWN']      = AVSwitchDevice.PrxStartDown,
	['STOP_LEFT']       = AVSwitchDevice.PrxStopLeft,
	['STOP_RIGHT']      = AVSwitchDevice.PrxStopRight,
	['STOP_UP']         = AVSwitchDevice.PrxStopUp,
	['STOP_DOWN']       = AVSwitchDevice.PrxStopDown,
	
}


