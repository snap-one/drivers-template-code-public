--[[=============================================================================
    TV Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "tv_proxy.tv_proxy_commands"
require "tv_proxy.tv_proxy_notifies"
require "modules.c4_metrics"
require "modules.retry_timer"
require "modules.ramp_timer"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tv_device_class = "2023.07.20"
end

TvDevice = inheritsFrom(C4ProxyBase)

--==========================================================================
--==========================================================================

TvVideoInputInfo = inheritsFrom(nil)

function TvVideoInputInfo:construct(BindingID, InputName)
	self._BindingID = BindingID
	self._InputName = InputName
	self._IsMiniApp = false

	self._Classes = {}
end

function TvVideoInputInfo:GetBindingID()
	return self._BindingID
end

function TvVideoInputInfo:GetInputName()
	return self._InputName
end

function TvVideoInputInfo:GetNeededInfo(BindingInfo)
	for _, CurClass in ipairs(BindingInfo.bindingclasses) do
		table.insert(self._Classes, CurClass.class)
		if(	(CurClass.class == "RF_MINI_APP") or
			(CurClass.class == "RF_SAMSUNG_TV_APP") or	-- Keep these two special cases around for backward
			(CurClass.class == "RF_LG_TV_APP")) then	-- compatibility. Hopefully, no more will be added.
			self._IsMiniApp = true
		end
	end
end

function TvVideoInputInfo:IsMiniAppBinding()
	return self._IsMiniApp
end

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function TvDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._PersistRecordName = string.format("Tv%dPersist", tonumber(BindingID))
	PersistData[self._PersistRecordName] = C4:PersistGetValue(self._PersistRecordName)
	
	if(PersistData[self._PersistRecordName] == nil) then
		PersistData[self._PersistRecordName] = {
			_PowerOn = false,
			_CurrentChannel = "-",
			_CurrentVolume = 0,
			_CurrentBass = 0,
			_CurrentTreble = 0,
			_CurrentBalance = 0,
			_CurrentMuted = false,
			_CurrentLoudnessOn = false,

			_RetryTimerInfo = {
				PowerOn =	{ Enabled = true,	Interval = 4,		FallbackInterval = 4,		IntervalUnits = "SECONDS",		RetryMax = 3 },
				PowerOff =	{ Enabled = true,	Interval = 4,		FallbackInterval = 4,		IntervalUnits = "SECONDS",		RetryMax = 3 },
				Input =		{ Enabled = true,	Interval = 2000,	FallbackInterval = 4000,	IntervalUnits = "MILLISECONDS",	RetryMax = 4 },
				Channel =	{ Enabled = true,	Interval = 2000,	FallbackInterval = 4000,	IntervalUnits = "MILLISECONDS",	RetryMax = 4 },
			},
			
			_RampTimerInfo = {
				VolumeUp =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				VolumeDown =	{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				ChannelUp =		{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
				ChannelDown =	{ Enabled = true, Interval = RampTimer.DEFAULT_INTERVAL },
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
			
			},
		}
		
		self:PersistSave()
	end

	self._PersistData = PersistData[self._PersistRecordName]
	self._RetryTimerInfo = self._PersistData._RetryTimerInfo
	self._RampTimerInfo = self._PersistData._RampTimerInfo

	self._TvInputs = {}
	self._CurrentInput = nil

	self._RetryTimers = {}
	local POnRetryInfo = self._RetryTimerInfo.PowerOn
	self._RetryTimers.PowerOn = RetryTimer:new(	POnRetryInfo.RetryMax,
												POnRetryInfo.Interval, POnRetryInfo.FallbackInterval, POnRetryInfo.IntervalUnits,
												TvDevice.PowerOnRetry, TvDevice.PowerOnRetryFail, self)
	local POffRetryInfo = self._RetryTimerInfo.PowerOff
	self._RetryTimers.PowerOff = RetryTimer:new(POffRetryInfo.RetryMax,
												POffRetryInfo.Interval, POffRetryInfo.FallbackInterval, POffRetryInfo.IntervalUnits,
												TvDevice.PowerOffRetry, TvDevice.PowerOffRetryFail, self)
	local InputRetryInfo = self._RetryTimerInfo.Input
	self._RetryTimers.Input = RetryTimer:new(	InputRetryInfo.RetryMax,
												InputRetryInfo.Interval, InputRetryInfo.FallbackInterval, InputRetryInfo.IntervalUnits,
												TvDevice.InputRetry, TvDevice.InputRetryFail, self)
	local ChannelRetryInfo = self._RetryTimerInfo.Channel
	self._RetryTimers.Channel = RetryTimer:new(	ChannelRetryInfo.RetryMax,
												ChannelRetryInfo.Interval, ChannelRetryInfo.FallbackInterval, ChannelRetryInfo.IntervalUnits,
												TvDevice.ChannelRetry, TvDevice.ChannelRetryFail, self)

	for TimerName, TimerInst in pairs(self._RetryTimers) do
		local CurInfo = self._RetryTimerInfo[TimerName]
		TimerInst:SetEnableFlag(CurInfo.Enabled)
		TimerInst:SetInterval(CurInfo.Interval)
		TimerInst:SetFallbackInterval(CurInfo.FallbackInterval)
	end
												
	
	self._RampTimers = {}
	self._RampTimers.VolumeUp		= RampTimer:new(TvDevice.PrxStartVolumeUp, self)
	self._RampTimers.VolumeDown		= RampTimer:new(TvDevice.PrxStartVolumeDown, self)
	self._RampTimers.ChannelUp		= RampTimer:new(TvDevice.PrxStartChUp, self)
	self._RampTimers.ChannelDown	= RampTimer:new(TvDevice.PrxStartChDown, self)
	self._RampTimers.Up				= RampTimer:new(TvDevice.PrxStartUp, self)
	self._RampTimers.Down			= RampTimer:new(TvDevice.PrxStartDown, self)
	self._RampTimers.Left			= RampTimer:new(TvDevice.PrxStartLeft, self)
	self._RampTimers.Right			= RampTimer:new(TvDevice.PrxStartRight, self)
	self._RampTimers.BassUp			= RampTimer:new(TvDevice.PrxStartBassUp, self)
	self._RampTimers.BassDown		= RampTimer:new(TvDevice.PrxStartBassDown, self)
	self._RampTimers.TrebleUp		= RampTimer:new(TvDevice.PrxStartTrebleUp, self)
	self._RampTimers.TrebleDown		= RampTimer:new(TvDevice.PrxStartTrebleDown, self)
	self._RampTimers.BalanceUp		= RampTimer:new(TvDevice.PrxStartBalanceUp, self)
	self._RampTimers.BalanceDown	= RampTimer:new(TvDevice.PrxStartBalanceDown, self)
	self._RampTimers.ScanFwd		= RampTimer:new(TvDevice.PrxStartScanFwd, self)
	self._RampTimers.ScanRev		= RampTimer:new(TvDevice.PrxStartScanRev, self)

	for TimerName, TimerInst in pairs(self._RampTimers) do
		local CurInfo = self._RampTimerInfo[TimerName]
		TimerInst:SetEnableFlag(CurInfo.Enabled)
		TimerInst:SetInterval(CurInfo.Interval)
	end
end


----------------------

function TvDevice:PersistSave()
	C4:PersistSetValue(self._PersistRecordName, PersistData[self._PersistRecordName])
end

----------------------

function TvDevice:EnableRetries()
	for CurTimerName, _ in pairs(self._RetryTimers) do
		self:EnableRetryTimer(CurTimerName)
	end
end

function TvDevice:DisableRetries()
	for CurTimerName, _ in pairs(self._RetryTimers) do
		self:DisableRetryTimer(CurTimerName)
	end
end

function TvDevice:EnableRetryTimer(TimerName)
	self._RetryTimers[TimerName]:Enable()
	self._RetryTimerInfo[TimerName].Enabled = true
	self:PersistSave()
end

function TvDevice:DisableRetryTimer(TimerName)
	self._RetryTimers[TimerName]:Disable()
	self._RetryTimerInfo[TimerName].Enabled = false
	self:PersistSave()
end

function TvDevice:AbortRetryTimer(TimerName)
	if(self._RetryTimers[TimerName] ~= nil) then
		self._RetryTimers[TimerName]:Kill()
	else
		LogWarn("TvDevice:AbortRetryTimer No timer defined for %s", tostring(TimerName))
	end
end

function TvDevice:SetRetryTimerInterval(TimerName, Interval)
	self._RetryTimers[TimerName]:SetInterval(Interval)
	self._RetryTimerInfo[TimerName].Interval = Interval
	self:PersistSave()
end

function TvDevice:SetRetryTimerFallbackInterval(TimerName, Interval)
	self._RetryTimers[TimerName]:SetFallbackInterval()
	self._RetryTimerInfo[TimerName].FallbackInterval = Interval
	self:PersistSave()
end

function TvDevice:SetRetryTimerMaxCount(TimerName, Count)
	self._RetryTimers[TimerName]:SetRetryMaxCount(Count)
	self._RetryTimerInfo[TimerName].RetryMax = Count
	self:PersistSave()
end

function TvDevice:IsRetryTimerStarted(TimerName)
	return self._RetryTimers[TimerName]:IsStarted()
end

-------

function TvDevice:PowerOnRetry(Param)
	LogInfo("TvDevice:PowerOnRetry")
	DataLakeMetrics:MetricsCounter('Tv PowerOnRetry')
	self:PrxOn(Param or {}, true)
end

function TvDevice:PowerOnRetryFail(Param)
	LogInfo("TvDevice:PowerOnRetryFail")
	DataLakeMetrics:MetricsCounter('Tv PowerOnFail')
end

-------

function TvDevice:PowerOffRetry(Param)
	LogInfo("TvDevice:PowerOffRetry")
	DataLakeMetrics:MetricsCounter('Tv PowerOffRetry')
	self:PrxOff(Param or {}, true)
end

function TvDevice:PowerOffRetryFail(Param)
	LogInfo("TvDevice:PowerOffRetryFail")
	DataLakeMetrics:MetricsCounter('Tv PowerOffFail')
end

-------

function TvDevice:InputRetry(Param)
	LogInfo("TvDevice:InputRetry")
	DataLakeMetrics:MetricsCounter('Tv SelectInputRetry')
	self:PrxSetInput(Param, true)
end

function TvDevice:InputRetryFail(Param)
	LogInfo("TvDevice:InputRetryFail")
	if(Param.SourceType == 'MiniApp') then
		DataLakeMetrics:MetricsCounter('Tv SelectMiniAppFailed')
	else
		DataLakeMetrics:MetricsCounter('Tv SelectDeviceInputFailed')
	end
end

-------

function TvDevice:ChannelRetry(Param)
	LogInfo("TvDevice:ChannelRetry")
	DataLakeMetrics:MetricsCounter('Tv ChannelRetry')
	self:PrxSetChannel(Param, true)
end

function TvDevice:ChannelRetryFail(Param)
	LogInfo("TvDevice:ChannelRetryFail")
	DataLakeMetrics:MetricsCounter('Tv SetChannelFailed')
end

-------

function TvDevice:EnableRampTimers()
	for TimerName, _ in pairs(self._RampTimers) do
		self:EnableRampTimer(TimerName)
	end
end

function TvDevice:DisableRampTimers()
	for TimerName, _ in pairs(self._RampTimers) do
		self:DisableRampTimer(TimerName)
	end
end


function TvDevice:StartRampTimer(TimerName, CallbackParam)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetRampParameter(CallbackParam)
		TargTimer:Start()
	else
		LogWarn("TvDevice:StartRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function TvDevice:StopRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:Kill()
	else
		LogWarn("TvDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function TvDevice:IsRamping(TimerName)
	local RampingFlag = false
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		RampingFlag = TargTimer:IsRamping()
	else
		LogWarn("TvDevice:IsRamping  Undefined Ramp Timer: %s", tostring(TimerName))
	end
	
	return RampingFlag
end

function TvDevice:EnableRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetEnableFlag(true)
		self._RampTimerInfo[TimerName].Enabled = true
		self:PersistSave()
	else
		LogWarn("TvDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function TvDevice:DisableRampTimer(TimerName)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetEnableFlag(false)
		self._RampTimerInfo[TimerName].Enabled = false
		self:PersistSave()
	else
		LogWarn("TvDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function TvDevice:SetRampTimerInterval(TimerName, Interval)
	local TargTimer = self._RampTimers[TimerName]

	if(TargTimer ~= nil) then
		TargTimer:SetInterval(Interval)
		self._RampTimerInfo[TimerName].Interval = Interval
		self:PersistSave()
	else
		LogWarn("TvDevice:StopRampTimer  Undefined Ramp Timer: %s", tostring(TimerName))
	end
end

function TvDevice:SetAllRampTimerIntervals(Interval)
	for TimerName, _ in pairs(self._RampTimers) do
		self:SetRampTimerInterval(TimerName, Interval)
	end
end


-------

function TvDevice:InitialSetup()

	TvDevice.UpdateRetryProperties(self._RetryTimerInfo, self._RampTimerInfo)

	local AllBindingTab = C4:GetBindingsByDevice(self:GetProxyDeviceID()).bindings
	for _, CurBindingInfo in pairs(AllBindingTab) do
		LogInfo("Get info for binding: %s  %s", tostring(CurBindingInfo.bindingid), CurBindingInfo.name)
		if(CurBindingInfo.type == 5) then	-- video binding
			if(not CurBindingInfo.provider) then
				local NewVideoInput = TvVideoInputInfo:new(CurBindingInfo.bindingid, CurBindingInfo.name)
				NewVideoInput:GetNeededInfo(CurBindingInfo)
				self._TvInputs[CurBindingInfo.bindingid] = NewVideoInput
				self._TvInputs[CurBindingInfo.name] = NewVideoInput
--				LogInfo(NewVideoInput)
			end
			
		end
	end

	-- go through the bindings list again to see if there are audio bindings that should piggy-back
	-- on previously created video bindings
	for _, CurBindingInfo in pairs(AllBindingTab) do
		LogInfo("Get info for binding: %s  %s", tostring(CurBindingInfo.bindingid), CurBindingInfo.name)
		if(CurBindingInfo.type == 6) then	-- audio binding
			if(not CurBindingInfo.provider) then
				if(self._TvInputs[CurBindingInfo.name] ~= nil) then
					self._TvInputs[CurBindingInfo.bindingid] = self._TvInputs[CurBindingInfo.name]
				end
			end
			
		end
	end
	
end


-------------

function TvDevice:IsPowerOn()
	return self._PersistData._PowerOn
end

function TvDevice:PowerFlagIs(PowerFlag)
	if(PowerFlag ~= self._PersistData._PowerOn) then
		self._PersistData._PowerOn = PowerFlag
		self:PersistSave()
		
		if(self._PersistData._PowerOn) then
			DataLakeMetrics:MetricsCounter('Tv PowerOnSuccess')
			NOTIFY.TV_ON(self._BindingID)
			
			--shorten the interval of the timer(s) that are running to improve the performance during the power on sequence...
			self._RetryTimers.Input:Restart()
			self._RetryTimers.Channel:Restart()
		else
			DataLakeMetrics:MetricsCounter('Tv PowerOffSuccess')
			NOTIFY.TV_OFF(self._BindingID)
		end
	end

	local PowerStr = PowerFlag and "On" or "Off"
	self._RetryTimers.PowerOn:Fulfill(PowerStr)
	self._RetryTimers.PowerOff:Fulfill(PowerStr)
end


function TvDevice:SetInput(TargInputName)
	local TargInputInfo = self._TvInputs[TargInputName]
	if(TargInputInfo ~= self._CurrentInput) then
		self._CurrentInput = TargInputInfo
		NOTIFY.TV_INPUT_CHANGED(self._CurrentInput:GetBindingID(), self._BindingID)
	end

	self._RetryTimers.Input:Fulfill(TargInputName)
end


function TvDevice:GetCurrentInputName()
	return (self._CurrentInput ~= nil) and self._CurrentInput:GetInputName() or ""
end

function TvDevice:GetCurrentInputBindingId()
	return (self._CurrentInput ~= nil) and self._CurrentInput:GetBindingID() or 0
end

function TvDevice:IsCurrentInputMiniApp()
	return (self._CurrentInput ~= nil) and self._CurrentInput:IsMiniAppBinding() or false
end



function TvDevice:GetCurrentChannel()
	return self._PersistData._CurrentChannel
end

function TvDevice:CurrentChannelIs(TargChannel)
	if(TargChannel ~= self._PersistData._CurrentChannel) then
		self._PersistData._CurrentChannel = TargChannel
		self:PersistSave()
		NOTIFY.TV_CHANNEL_CHANGED(self._PersistData._CurrentChannel, "", self._BindingID)
	end

	self._RetryTimers.Channel:Fulfill(tostring(TargChannel))
end


function TvDevice:GetCurrentVolume()
	return self._PersistData._CurrentVolume
end

function TvDevice:VolumeLevelIs(TargVolLevel)
	if(TargVolLevel ~= self._PersistData._CurrentVolume) then
		self._PersistData._CurrentVolume = TargVolLevel
		self:PersistSave()
		NOTIFY.TV_VOLUME_LEVEL_CHANGED(self._PersistData._CurrentVolume, self._BindingID)
	end
end


function TvDevice:IsMuted()
	return self._PersistData._CurrentMuted
end

function TvDevice:MuteStateIs(MuteFlag)
	if(MuteFlag ~= self._PersistData._CurrentMuted) then
		self._PersistData._CurrentMuted = MuteFlag
		self:PersistSave()
		NOTIFY.TV_MUTE_CHANGED(self._PersistData._CurrentMuted, self._BindingID)
	end
end

function TvDevice:IsLoudnessOn()
	return self._PersistData._CurrentLoudnessOn
end

function TvDevice:LoudnessStateIs(LoudnessFlag)
	if(LoudnessFlag ~= self._PersistData._CurrentLoudnessOn) then
		self._PersistData._CurrentLoudnessOn = LoudnessFlag
		self:PersistSave()
		NOTIFY.TV_LOUDNESS_CHANGED(self._PersistData._CurrentLoudnessOn, self._BindingID)
	end
end

function TvDevice:GetCurrentBassLevel()
	return self._PersistData._CurrentBass
end

function TvDevice:BassLevelIs(BassLevel)
	if(BassLevel ~= self._PersistData._CurrentBass) then
		self._PersistData._CurrentBass = BassLevel
		self:PersistSave()
		NOTIFY.TV_BASS_LEVEL_CHANGED(self._PersistData._CurrentBass, self._BindingID)
	end
end

function TvDevice:GetCurrentTrebleLevel()
	return self._PersistData._CurrentTreble
end

function TvDevice:TrebleLevelIs(TrebleLevel)
	if(TrebleLevel ~= self._PersistData._CurrentTreble) then
		self._PersistData._CurrentTreble = TrebleLevel
		self:PersistSave()
		NOTIFY.TV_TREBEL_LEVEL_CHANGED(self._PersistData._CurrentTreble, self._BindingID)
	end
end

function TvDevice:GetCurrentBalanceLevel()
	return self._PersistData._CurrentBalance
end

function TvDevice:BalanceLevelIs(BalanceLevel)
	if(BalanceLevel ~= self._PersistData._CurrentBalance) then
		self._PersistData._CurrentBalance = BalanceLevel
		self:PersistSave()
		NOTIFY.TV_BALANCE_LEVEL_CHANGED(self._PersistData._CurrentBalance, self._BindingID)
	end
end



--=============================================================================
--=============================================================================

function TvDevice:PrxOn(tParams, IsRetry)
	LogTrace("TvDevice:PrxOn")
	if(not IsRetry) then
		DataLakeMetrics:MetricsCounter('Tv RequestPowerOn')
	end
	
	self._RetryTimers.PowerOn:SetRetryParameter(tParams)
	self._RetryTimers.PowerOn:Start("On")
	TvCom_On(tParams)
end

function TvDevice:PrxOff(tParams, IsRetry)
	LogTrace("TvDevice:PrxOff")
	if(not IsRetry) then
		DataLakeMetrics:MetricsCounter('Tv RequestPowerOff')
	end
	
	self._RetryTimers.PowerOff:SetRetryParameter(tParams)
	self._RetryTimers.PowerOff:Start("Off")
	TvCom_Off(tParams)
end

function TvDevice:PrxSetInput(tParams, IsRetry)
	LogTrace("TvDevice:PrxSetInput")
	LogInfo(tParams)
	local TargInput = self._TvInputs[tonumber(tParams.INPUT)]
	ConnectType = "Video"
	ConnectExtraInfo = {}
	
	if(TargInput:IsMiniAppBinding()) then
		ConnectType = "MiniApp"
		local AppProxyID = C4:GetBoundProviderDevice(self:GetProxyDeviceID(), TargInput:GetBindingID())
		local AppID = C4:GetBoundProviderDevice(AppProxyID, DEFAULT_PROXY_BINDINGID)
		for _, v in pairs(C4:GetDeviceVariables (AppID)) do
			ConnectExtraInfo[v.name] = v.value
		end

		if(not IsRetry) then
			DataLakeMetrics:MetricsCounter('Tv MiniAppSelected')
            DataLakeMetrics:DailyStatsMiniAppSelectedCounter(ConnectExtraInfo.APP_NAME)
		end

		tParams.SourceType = 'MiniApp'
	else
		tParams.SourceType = 'Device'
	end

	if(not IsRetry) then
		DataLakeMetrics:MetricsCounter('Tv SetInput')
	end
	
	self._RetryTimers.Input:SetRetryParameter(tParams)
	self._RetryTimers.Input:Start(TargInput:GetInputName())
	TvCom_SetInput(TargInput:GetInputName(), ConnectType, ConnectExtraInfo)
end

function TvDevice:PrxInputToggle(tParams)
	LogTrace("TvDevice:PrxInputToggle")
	LogInfo(tParams)
	-- DCC 02/02/2023  What is this supposed to do?
end

function TvDevice:PrxMenu(tParams)
	LogTrace("TvDevice:PrxMenu")
	TvCom_Menu(tParams)
end

function TvDevice:PrxUp(tParams)
	LogTrace("TvDevice:PrxUp")
	TvCom_Up(tParams)
end

function TvDevice:PrxStartUp(tParams)
	LogTrace("TvDevice:PrxStartUp")
	self:StartRampTimer("Up", tParams)
	TvCom_StartUp(tParams)
end

function TvDevice:PrxStopUp(tParams)
	LogTrace("TvDevice:PrxStopUp")
	self:StopRampTimer("Up")
	TvCom_StopUp(tParams)
end

function TvDevice:PrxDown(tParams)
	LogTrace("TvDevice:PrxDown")
	TvCom_Down(tParams)
end

function TvDevice:PrxStartDown(tParams)
	LogTrace("TvDevice:PrxStartDown")
	self:StartRampTimer("Down", tParams)
	TvCom_StartDown(tParams)
end

function TvDevice:PrxStopDown(tParams)
	LogTrace("TvDevice:PrxStopDown")
	self:StopRampTimer("Down")
	TvCom_StopDown(tParams)
end

function TvDevice:PrxLeft(tParams)
	LogTrace("TvDevice:PrxLeft")
	TvCom_Left(tParams)
end

function TvDevice:PrxStartLeft(tParams)
	LogTrace("TvDevice:PrxStartLeft")
	self:StartRampTimer("Left", tParams)
	TvCom_StartLeft(tParams)
end

function TvDevice:PrxStopLeft(tParams)
	LogTrace("TvDevice:PrxStopLeft")
	self:StopRampTimer("Left")
	TvCom_StopLeft(tParams)
end

function TvDevice:PrxRight(tParams)
	LogTrace("TvDevice:PrxRight")
	TvCom_Right(tParams)
end

function TvDevice:PrxStartRight(tParams)
	LogTrace("TvDevice:PrxStartRight")
	self:StartRampTimer("Right", tParams)
	TvCom_StartRight(tParams)
end

function TvDevice:PrxStopRight(tParams)
	LogTrace("TvDevice:PrxStopRight")
	self:StopRampTimer("Right")
	TvCom_StopRight(tParams)
end

function TvDevice:PrxEnter(tParams)
	LogTrace("TvDevice:PrxEnter")
	TvCom_Enter(tParams)
end

function TvDevice:PrxExit(tParams)
	LogTrace("TvDevice:PrxExit")
	TvCom_Exit(tParams)
end

function TvDevice:PrxHome(tParams)
	LogTrace("TvDevice:PrxHome")
	TvCom_Home(tParams)
end

function TvDevice:PrxSettings(tParams)
	LogTrace("TvDevice:PrxSettings")
	TvCom_Settings(tParams)
end

function TvDevice:PrxSetVolumeLevel(tParams)
	LogTrace("TvDevice:PrxSetVolumeLevel")
	local LevelParam = tostring(tParams.LEVEL)
	DataLakeMetrics:MetricsCounter('Tv SetVolume')
	TvCom_SetVolumeLevel(LevelParam, tParams)
end

function TvDevice:PrxStartVolumeUp(tParams)
	LogTrace("TvDevice:PrxStartVolumeUp")
	self:StartRampTimer("VolumeUp", tParams)
	TvCom_StartVolumeUp(tParams)
end

function TvDevice:PrxStopVolumeUp(tParams)
	LogTrace("TvDevice:PrxStopVolumeUp")
	self:StopRampTimer("VolumeUp")
	TvCom_StopVolumeUp(tParams)
end

function TvDevice:PrxStartVolumeDown(tParams)
	LogTrace("TvDevice:PrxStartVolumeDown")
	self:StartRampTimer("VolumeDown", tParams)
	TvCom_StartVolumeDown(tParams)
end

function TvDevice:PrxStopVolumeDown(tParams)
	LogTrace("TvDevice:PrxStopVolumeDown")
	self:StopRampTimer("VolumeDown")
	TvCom_StopVolumeDown(tParams)
end

function TvDevice:PrxPulseVolumeUp(tParams)
	LogTrace("TvDevice:PrxVolumeChUp")
	DataLakeMetrics:MetricsCounter("Tv PulseVolume")
	TvCom_PulseVolumeUp(tParams)
end

function TvDevice:PrxPulseVolumeDown(tParams)
	LogTrace("TvDevice:PrxPulseVolumeDown")
	DataLakeMetrics:MetricsCounter("Tv PulseVolume")
	TvCom_PulseVolumeDown(tParams)
end

function TvDevice:PrxSetChannel(tParams, IsRetry)
	LogTrace("TvDevice:PrxSetChannel")
	if(not IsRetry) then
		DataLakeMetrics:MetricsCounter('Tv SetChannel')
	end
	
	self._RetryTimers.Channel:SetRetryParameter(tParams)
	self._RetryTimers.Channel:Start(tostring(tParams.CHANNEL))

	TvCom_SetChannel(tostring(tParams.CHANNEL), tParams)
end

function TvDevice:PrxStartChUp(tParams)
	LogTrace("TvDevice:PrxStartChUp")
	self:StartRampTimer("ChannelUp", tParams)
	TvCom_StartChannelUp(tParams)
end

function TvDevice:PrxStopChUp(tParams)
	LogTrace("TvDevice:PrxStopChUp")
	self:StopRampTimer("ChannelUp")
	TvCom_StopChannelUp(tParams)
end

function TvDevice:PrxStartChDown(tParams)
	LogTrace("TvDevice:PrxStartChDown")
	self:StartRampTimer("ChannelDown", tParams)
	TvCom_StartChannelDown(tParams)
end

function TvDevice:PrxStopChDown(tParams)
	LogTrace("TvDevice:PrxStopChDown")
	self:StopRampTimer("ChannelDown")
	TvCom_StopChannelDown(tParams)
end

function TvDevice:PrxPulseChUp(tParams)
	LogTrace("TvDevice:PrxPulseChUp")
	DataLakeMetrics:MetricsCounter('Tv TuningPulseChannel')
	TvCom_PulseChannelUp(tParams)
end

function TvDevice:PrxPulseChDown(tParams)
	LogTrace("TvDevice:PrxPulseChDown")
	DataLakeMetrics:MetricsCounter('Tv TuningPulseChannel')
	TvCom_PulseChannelDown(tParams)
end

function TvDevice:PrxTvVideo(tParams)
	LogTrace("TvDevice:PrxTvVideo")
	TvCom_TvVideo(tParams)
end

function TvDevice:PrxInfo(tParams)
	LogTrace("TvDevice:PrxInfo")
	TvCom_Info(tParams)
end

function TvDevice:PrxCancel(tParams)
	LogTrace("TvDevice:PrxCancel")
	TvCom_Cancel(tParams)
end

function TvDevice:PrxRecall(tParams)
	LogTrace("TvDevice:PrxRecall")
	TvCom_Recall(tParams)
end

function TvDevice:PrxGuide(tParams)
	LogTrace("TvDevice:PrxGuide")
	TvCom_Guide(tParams)
end

function TvDevice:PrxClosedCaptioned(tParams)
	LogTrace("TvDevice:PrxClosedCaptioned")
	TvCom_ClosedCaptioned(tParams)
end

function TvDevice:PrxPageUp(tParams)
	LogTrace("TvDevice:PrxPageUp")
	TvCom_PageUp(tParams)
end

function TvDevice:PrxPageDown(tParams)
	LogTrace("TvDevice:PrxPageDown")
	TvCom_PageDown(tParams)
end

function TvDevice:PrxProgramA(tParams)
	LogTrace("TvDevice:PrxProgramA")
	TvCom_ProgramA(tParams)
end

function TvDevice:PrxProgramB(tParams)
	LogTrace("TvDevice:PrxProgramB")
	TvCom_ProgramB(tParams)
end

function TvDevice:PrxProgramC(tParams)
	LogTrace("TvDevice:PrxProgramC")
	TvCom_ProgramC(tParams)
end

function TvDevice:PrxProgramD(tParams)
	LogTrace("TvDevice:PrxProgramD")
	TvCom_ProgramD(tParams)
end


function TvDevice:PrxNumber0(tParams)
	LogTrace("TvDevice:PrxNumber0")
	TvCom_Number0(tParams)
end

function TvDevice:PrxNumber1(tParams)
	LogTrace("TvDevice:PrxNumber1")
	TvCom_Number1(tParams)
end

function TvDevice:PrxNumber2(tParams)
	LogTrace("TvDevice:PrxNumber2")
	TvCom_Number2(tParams)
end

function TvDevice:PrxNumber3(tParams)
	LogTrace("TvDevice:PrxNumber3")
	TvCom_Number3(tParams)
end

function TvDevice:PrxNumber4(tParams)
	LogTrace("TvDevice:PrxNumber4")
	TvCom_Number4(tParams)
end

function TvDevice:PrxNumber5(tParams)
	LogTrace("TvDevice:PrxNumber5")
	TvCom_Number5(tParams)
end

function TvDevice:PrxNumber6(tParams)
	LogTrace("TvDevice:PrxNumber6")
	TvCom_Number6(tParams)
end

function TvDevice:PrxNumber7(tParams)
	LogTrace("TvDevice:PrxNumber7")
	TvCom_Number7(tParams)
end

function TvDevice:PrxNumber8(tParams)
	LogTrace("TvDevice:PrxNumber8")
	TvCom_Number8(tParams)
end

function TvDevice:PrxNumber9(tParams)
	LogTrace("TvDevice:PrxNumber9")
	TvCom_Number9(tParams)
end

function TvDevice:PrxHyphen(tParams)
	LogTrace("TvDevice:PrxHyphen")
	TvCom_Hyphen(tParams)
end

function TvDevice:PrxStar(tParams)
	LogTrace("TvDevice:PrxStar")
	TvCom_Star(tParams)
end

function TvDevice:PrxPound(tParams)
	LogTrace("TvDevice:PrxPound")
	TvCom_Pound(tParams)
end


function TvDevice:PrxSetBassLevel(tParams)
	LogTrace("TvDevice:PrxSetBassLevel")
	TvCom_SetBassLevel(tostring(tParams.LEVEL), tParams)
end

function TvDevice:PrxStartBassUp(tParams)
	LogTrace("TvDevice:PrxStartBassUp")
	self:StartRampTimer("BassUp", tParams)
	TvCom_StartBassUp(tParams)
end

function TvDevice:PrxStopBassUp(tParams)
	LogTrace("TvDevice:PrxStopBassUp")
	self:StopRampTimer("BassUp")
	TvCom_StopBassUp(tParams)
end

function TvDevice:PrxStartBassDown(tParams)
	LogTrace("TvDevice:PrxStartBassDown")
	self:StartRampTimer("BassDown", tParams)
	TvCom_StartBassDown(tParams)
end

function TvDevice:PrxStopBassDown(tParams)
	LogTrace("TvDevice:PrxStopBassDown")
	self:StopRampTimer("BassDown")
	TvCom_StopBassDown(tParams)
end

function TvDevice:PrxPulseBassUp(tParams)
	LogTrace("TvDevice:PrxPulseBassUp")
	TvCom_PulseBassUp(tParams)
end

function TvDevice:PrxPulseBassDown(tParams)
	LogTrace("TvDevice:PrxPulseBassDown")
	TvCom_PulseBassDown(tParams)
end

function TvDevice:PrxSetTrebleLevel(tParams)
	LogTrace("TvDevice:PrxSetTrebleLevel")
	TvCom_SetTrebleLevel(tostring(tParams.LEVEL), tParams)
end

function TvDevice:PrxStartTrebleUp(tParams)
	LogTrace("TvDevice:PrxStartTrebleUp")
	self:StartRampTimer("TrebleUp", tParams)
	TvCom_StartTrebleUp(tParams)
end

function TvDevice:PrxStopTrebleUp(tParams)
	LogTrace("TvDevice:PrxStopTrebleUp")
	self:StopRampTimer("TrebleUp")
	TvCom_StopTrebleUp(tParams)
end

function TvDevice:PrxStartTrebleDown(tParams)
	LogTrace("TvDevice:PrxStartTrebleDown")
	self:StartRampTimer("TrebleDown", tParams)
	TvCom_StartTrebleDown(tParams)
end

function TvDevice:PrxStopTrebleDown(tParams)
	LogTrace("TvDevice:PrxStopTrebleDown")
	self:StopRampTimer("TrebleDown")
	TvCom_StopTrebleDown(tParams)
end

function TvDevice:PrxPulseTrebleUp(tParams)
	LogTrace("TvDevice:PrxPulseTrebleUp")
	TvCom_PulseTrebleUp(tParams)
end

function TvDevice:PrxPulseTrebleDown(tParams)
	LogTrace("TvDevice:PrxPulseTrebleDown")
	TvCom_PulseTrebleDown(tParams)
end


function TvDevice:PrxSetBalanceLevel(tParams)
	LogTrace("TvDevice:PrxSetBalanceLevel")
	TvCom_SetBalanceLevel(tostring(tParams.LEVEL), tParams)
end

function TvDevice:PrxStartBalanceUp(tParams)
	LogTrace("TvDevice:PrxStartBalanceUp")
	self:StartRampTimer("BalanceUp", tParams)
	TvCom_StartBalanceUp(tParams)
end

function TvDevice:PrxStopBalanceUp(tParams)
	LogTrace("TvDevice:PrxStopBalanceUp")
	self:StopRampTimer("BalanceUp")
	TvCom_StopBalanceUp(tParams)
end

function TvDevice:PrxStartBalanceDown(tParams)
	LogTrace("TvDevice:PrxStartBalanceDown")
	self:StartRampTimer("BalanceDown", tParams)
	TvCom_StartBalanceDown(tParams)
end

function TvDevice:PrxStopBalanceDown(tParams)
	LogTrace("TvDevice:PrxStopBalanceDown")
	self:StopRampTimer("BalanceDown")
	TvCom_StopBalanceDown(tParams)
end

function TvDevice:PrxPulseBalanceUp(tParams)
	LogTrace("TvDevice:PrxPulseBalanceUp")
	TvCom_PulseBalanceUp(tParams)
end

function TvDevice:PrxPulseBalanceDown(tParams)
	LogTrace("TvDevice:PrxPulseBalanceDown")
	TvCom_PulseBalanceDown(tParams)
end

function TvDevice:PrxMuteOn(tParams)
	LogTrace("TvDevice:PrxMuteOn")
	TvCom_MuteOn(tParams)
end

function TvDevice:PrxMuteOff(tParams)
	LogTrace("TvDevice:PrxMuteOff")
	TvCom_MuteOff(tParams)
end

function TvDevice:PrxMuteToggle(tParams)
	LogTrace("TvDevice:PrxMuteToggle")
	TvCom_MuteToggle(tParams)
end

function TvDevice:PrxLoudnessOn(tParams)
	LogTrace("TvDevice:PrxLoudnessOn")
	TvCom_LoudnessOn(tParams)
end

function TvDevice:PrxLoudnessOff(tParams)
	LogTrace("TvDevice:PrxLoudnessOff")
	TvCom_LoudnessOff(tParams)
end

function TvDevice:PrxLoudnessToggle(tParams)
	LogTrace("TvDevice:PrxLoudnessToggle")
	TvCom_LoudnessToggle(tParams)
end

function TvDevice:PrxEject(tParams)
	LogTrace("TvDevice:PrxEject")
	TvCom_Eject(tParams)
end

function TvDevice:PrxPlay(tParams)
	LogTrace("TvDevice:PrxPlay")
	TvCom_Play(tParams)
end

function TvDevice:PrxStop(tParams)
	LogTrace("TvDevice:PrxStop")
	TvCom_Stop(tParams)
end

function TvDevice:PrxPause(tParams)
	LogTrace("TvDevice:PrxPause")
	TvCom_Pause(tParams)
end

function TvDevice:PrxRecord(tParams)
	LogTrace("TvDevice:PrxRecord")
	TvCom_Record(tParams)
end

function TvDevice:PrxSkipFwd(tParams)
	LogTrace("TvDevice:PrxSkipFwd")
	TvCom_SkipFwd(tParams)
end

function TvDevice:PrxSkipRev(tParams)
	LogTrace("TvDevice:PrxSkipRev")
	TvCom_SkipRev(tParams)
end

function TvDevice:PrxScanFwd(tParams)
	LogTrace("TvDevice:PrxScanFwd")
	TvCom_ScanFwd(tParams)
end

function TvDevice:PrxScanRev(tParams)
	LogTrace("TvDevice:PrxScanRev")
	TvCom_ScanRev(tParams)
end

function TvDevice:PrxStartScanFwd(tParams)
	LogTrace("TvDevice:PrxStartScanFwd")
	self:StartRampTimer("ScanFwd", tParams)
	TvCom_StartScanFwd(tParams)
end

function TvDevice:PrxStartScanRev(tParams)
	LogTrace("TvDevice:PrxStartScanRev")
	self:StartRampTimer("ScanRev", tParams)
	TvCom_StartScanRev(tParams)
end

function TvDevice:PrxStopScanFwd(tParams)
	LogTrace("TvDevice:PrxStopScanFwd")
	self:StopRampTimer("ScanFwd")
	TvCom_StopScanFwd(tParams)
end

function TvDevice:PrxStopScanRev(tParams)
	LogTrace("TvDevice:PrxStopScanRev")
	self:StopRampTimer("ScanRev")
	TvCom_StopScanRev(tParams)
end


function TvDevice:PrxPassthrough(tParams)
	LogTrace("TvDevice:PrxPassthrough")
	LogInfo(tParams)
	
	local PassThroughCmd = tParams.PASSTHROUGH_COMMAND
	if(TvDevice._PassThroughCommandRoutines[PassThroughCmd] ~= nil) then
		TvDevice._PassThroughCommandRoutines[PassThroughCmd](self, tParams)
	else
		LogInfo("TvDevice:PrxPassthrough  Unhandled Command: %s", PassThroughCmd)
	end
end

TvDevice._PassThroughCommandRoutines = {
	['LEFT']			= TvDevice.PrxLeft,
	['RIGHT']			= TvDevice.PrxRight,
	['UP']				= TvDevice.PrxUp,
	['DOWN']			= TvDevice.PrxDown,
	['MENU']			= TvDevice.PrxMenu,
	['CANCEL']			= TvDevice.PrxCancel,
	['INFO']			= TvDevice.PrxInfo,
	['EJECT']			= TvDevice.PrxEject,
	['ENTER']			= TvDevice.PrxEnter,
	['PLAY']			= TvDevice.PrxPlay,
	['STOP']			= TvDevice.PrxStop,
	['PAUSE']			= TvDevice.PrxPause,
	['RECORD']			= TvDevice.PrxRecord,
	['SKIP_FWD']		= TvDevice.PrxSkipFwd,
	['SKIP_REV']		= TvDevice.PrxSkipRev,
	['SCAN_FWD']		= TvDevice.PrxScanFwd,
	['SCAN_REV']		= TvDevice.PrxScanRev,	
	['PROGRAM_A']		= TvDevice.PrxProgramA,
	['PROGRAM_B']		= TvDevice.PrxProgramB,
	['PROGRAM_C']		= TvDevice.PrxProgramC,
	['PROGRAM_D']		= TvDevice.PrxProgramD,
	['PAGE_UP']			= TvDevice.PrxPageUp,
	['PAGE_DOWN']		= TvDevice.PrxPageDown,
	['NUMBER_0']		= TvDevice.PrxNumber0,
	['NUMBER_1']		= TvDevice.PrxNumber1,
	['NUMBER_2']		= TvDevice.PrxNumber2,
	['NUMBER_3']		= TvDevice.PrxNumber3,
	['NUMBER_4']		= TvDevice.PrxNumber4,
	['NUMBER_5']		= TvDevice.PrxNumber5,
	['NUMBER_6']		= TvDevice.PrxNumber6,
	['NUMBER_7']		= TvDevice.PrxNumber7,
	['NUMBER_8']		= TvDevice.PrxNumber8,
	['NUMBER_9']		= TvDevice.PrxNumber9,
	['STAR']			= TvDevice.PrxStar,
	['POUND']			= TvDevice.PrxPound,
	['START_SCAN_FWD']  = TvDevice.PrxStartScanFwd,
	['START_SCAN_REV']  = TvDevice.PrxStartScanRev,
	['STOP_SCAN_FWD']   = TvDevice.PrxStopScanFwd,
	['STOP_SCAN_REV']   = TvDevice.PrxStopScanRev,
	['START_LEFT']      = TvDevice.PrxStartLeft,
	['START_RIGHT']     = TvDevice.PrxStartRight,
	['START_UP']        = TvDevice.PrxStartUp,
	['START_DOWN']      = TvDevice.PrxStartDown,
	['STOP_LEFT']       = TvDevice.PrxStopLeft,
	['STOP_RIGHT']      = TvDevice.PrxStopRight,
	['STOP_UP']         = TvDevice.PrxStopUp,
	['STOP_DOWN']       = TvDevice.PrxStopDown,
}



