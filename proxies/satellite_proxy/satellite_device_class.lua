--[[=============================================================================
    Satellite Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "satellite_proxy.satellite_proxy_commands"
require "satellite_proxy.satellite_proxy_notifies"


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.satellite_device_class = "2023.02.02"
end

SatelliteDevice = inheritsFrom(C4ProxyBase)

SAT_STATE_STOP		= "sat_state_stop"
SAT_STATE_PLAY		= "sat_state_play"
SAT_STATE_PAUSE		= "sat_state_pause"
SAT_STATE_RECORD	= "sat_state_record"

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function SatelliteDevice:construct(BindingID)
	self:super():construct(BindingID, self)

	self._PowerOn = false
	self._CurrentState = SAT_STATE_STOP
	self._CurrentChannel = "-"
	self._CurrentMediaInfo = ""
end


function SatelliteDevice:InitialSetup()
	
	if(PersistData.SatellitePersist == nil) then
		PersistSatelliteData = {}
		PersistData.SatellitePersist = PersistSatelliteData
		
		PersistSatelliteData._Capabilities = {}
		self:InitializeCapabilities()

	else
		PersistSatelliteData = PersistData.SatellitePersist
	end

end


function SatelliteDevice:InitializeCapabilities()
--	PersistSatelliteData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
end

-------------

function SatelliteDevice:IsPowerOn()
	return self._PowerOn
end

function SatelliteDevice:SetPowerOnFlag(OnFlag)
	if(OnFlag ~= self._PowerOn) then
		self._PowerOn = OnFlag
		
		if(self._PowerOn) then
			NOTIFY.ON(self._BindingID)
		else
			NOTIFY.OFF(self._BindingID)
		end
	end
end

-------------

function SatelliteDevice:IsPlaying()
	return (self:GetCurrentState() == SAT_STATE_PLAY)
end

function SatelliteDevice:IsStopped()
	return (self:GetCurrentState() == SAT_STATE_STOP)
end

function SatelliteDevice:IsPaused()
	return (self:GetCurrentState() == SAT_STATE_PAUSE)
end

function SatelliteDevice:IsRecording()
	return (self:GetCurrentState() == SAT_STATE_RECORD)
end

function SatelliteDevice:GetCurrentState()
	return self._CurrentState
end

function SatelliteDevice:SetCurrentState(NewState)
	if(NewState ~= self._CurrentState) then
		
		if(NewState == SAT_STATE_STOP) then
			self._CurrentState = SAT_STATE_STOP
			NOTIFY.STOP(self._BindingID)

		elseif(NewState == SAT_STATE_PLAY) then
			self._CurrentState = SAT_STATE_PLAY
			NOTIFY.PLAY(self._BindingID)
			
		elseif(NewState == SAT_STATE_PAUSE) then
			self._CurrentState = SAT_STATE_PAUSE
			NOTIFY.PAUSE(self._BindingID)

		elseif(NewState == SAT_STATE_RECORD) then
			self._CurrentState = SAT_STATE_RECORD
			NOTIFY.RECORD(self._BindingID)
		
		else
			LogWarn("SatelliteDevice:SetState  Undefined State: %s", tostring(NewState))
		end
	end
end

-------------

function SatelliteDevice:GetCurrentChannel()
	return self._CurrentChannel
end

function SatelliteDevice:SetCurrentChannel(NewChannel)
	if(NewChannel ~= self._CurrentChannel) then
		self._CurrentChannel = NewChannel
		NOTIFY.CHANNEL_CHANGED(self._CurrentChannel, self._BindingID)
	end
end

-------------

function SatelliteDevice:GetCurrentMediaInfo()
	return self._CurrentMediaInfo
end

function SatelliteDevice:SetCurrentMediaInfo(NewMediaInfo)
	if(NewMediaInfo ~= self._CurrentMediaInfo) then
		self._CurrentMediaInfo = NewMediaInfo
		NOTIFY.UPDATE_MEDIA_INFO(self._CurrentMediaInfo, self._BindingID)
	end
end



--=============================================================================
--=============================================================================

function SatelliteDevice:PrxOn(tParams)
	LogTrace("SatelliteDevice:PrxOn")
	SatelliteCom_On(tParams)
end

function SatelliteDevice:PrxOff(tParams)
	LogTrace("SatelliteDevice:PrxOff")
	SatelliteCom_Off(tParams)
end

function SatelliteDevice:PrxPlay(tParams)
	LogTrace("SatelliteDevice:PrxPlay")
	SatelliteCom_Play(tParams)
end

function SatelliteDevice:PrxStop(tParams)
	LogTrace("SatelliteDevice:PrxStop")
	SatelliteCom_Stop(tParams)
end

function SatelliteDevice:PrxPause(tParams)
	LogTrace("SatelliteDevice:PrxPause")
	SatelliteCom_Pause(tParams)
end

function SatelliteDevice:PrxSkipFwd(tParams)
	LogTrace("SatelliteDevice:PrxSkipFwd")
	SatelliteCom_SkipForward(tParams)
end

function SatelliteDevice:PrxSkipRev(tParams)
	LogTrace("SatelliteDevice:PrxSkipRev")
	SatelliteCom_SkipReverse(tParams)
end

function SatelliteDevice:PrxScanFwd(tParams)
	LogTrace("SatelliteDevice:PrxScanFwd")
	SatelliteCom_ScanForward(tParams)
end

function SatelliteDevice:PrxScanRev(tParams)
	LogTrace("SatelliteDevice:PrxScanRev")
	SatelliteCom_ScanReverse(tParams)
end

function SatelliteDevice:PrxMenu(tParams)
	LogTrace("SatelliteDevice:PrxMenu")
	SatelliteCom_Menu(tParams)
end

function SatelliteDevice:PrxUp(tParams)
	LogTrace("SatelliteDevice:PrxUp")
	SatelliteCom_Up(tParams)
end

function SatelliteDevice:PrxDown(tParams)
	LogTrace("SatelliteDevice:PrxDown")
	SatelliteCom_Down(tParams)
end

function SatelliteDevice:PrxLeft(tParams)
	LogTrace("SatelliteDevice:PrxLeft")
	SatelliteCom_Left(tParams)
end

function SatelliteDevice:PrxRight(tParams)
	LogTrace("SatelliteDevice:PrxRight")
	SatelliteCom_Right(tParams)
end

function SatelliteDevice:PrxEnter(tParams)
	LogTrace("SatelliteDevice:PrxEnter")
	SatelliteCom_Enter(tParams)
end

function SatelliteDevice:PrxExit(tParams)
	LogTrace("SatelliteDevice:PrxExit")
	SatelliteCom_Exit(tParams)
end

function SatelliteDevice:PrxHome(tParams)
	LogTrace("SatelliteDevice:PrxHome")
	SatelliteCom_Home(tParams)
end

function SatelliteDevice:PrxSettings(tParams)
	LogTrace("SatelliteDevice:PrxSettings")
	SatelliteCom_Settings(tParams)
end

function SatelliteDevice:PrxSetChannel(tParams)
	LogTrace("SatelliteDevice:PrxSetChannel")
	SatelliteCom_SetChannel(tostring(tParams.CHANNEL), tParams)
end

function SatelliteDevice:PrxStartChUp(tParams)
	LogTrace("SatelliteDevice:PrxStartChUp")
	SatelliteCom_StartChannelUp(tParams)
end

function SatelliteDevice:PrxStopChUp(tParams)
	LogTrace("SatelliteDevice:PrxStopChUp")
	SatelliteCom_StopChannelUp(tParams)
end

function SatelliteDevice:PrxStartChDown(tParams)
	LogTrace("SatelliteDevice:PrxStartChDown")
	SatelliteCom_StartChannelDown(tParams)
end

function SatelliteDevice:PrxStopChDown(tParams)
	LogTrace("SatelliteDevice:PrxStopChDown")
	SatelliteCom_StopChannelDown(tParams)
end

function SatelliteDevice:PrxPulseChUp(tParams)
	LogTrace("SatelliteDevice:PrxPulseChUp")
	SatelliteCom_PulseChannelUp(tParams)
end

function SatelliteDevice:PrxPulseChDown(tParams)
	LogTrace("SatelliteDevice:PrxPulseChDown")
	SatelliteCom_PulseChannelDown(tParams)
end

function SatelliteDevice:PrxRecord(tParams)
	LogTrace("SatelliteDevice:PrxRecord")
	SatelliteCom_Record(tParams)
end

function SatelliteDevice:PrxPageUp(tParams)
	LogTrace("SatelliteDevice:PrxPageUp")
	SatelliteCom_PageUp(tParams)
end

function SatelliteDevice:PrxPageDown(tParams)
	LogTrace("SatelliteDevice:PrxPageDown")
	SatelliteCom_PageDown(tParams)
end

function SatelliteDevice:PrxTvVideo(tParams)
	LogTrace("SatelliteDevice:PrxTvVideo")
	SatelliteCom_TvVideo(tParams)
end

function SatelliteDevice:PrxInfo(tParams)
	LogTrace("SatelliteDevice:PrxInfo")
	SatelliteCom_Info(tParams)
end

function SatelliteDevice:PrxCancel(tParams)
	LogTrace("SatelliteDevice:PrxCancel")
	SatelliteCom_Cancel(tParams)
end

function SatelliteDevice:PrxRecall(tParams)
	LogTrace("SatelliteDevice:PrxRecall")
	SatelliteCom_Recall(tParams)
end

function SatelliteDevice:PrxPVR(tParams)
	LogTrace("SatelliteDevice:PrxPVR")
	SatelliteCom_PVR(tParams)
end

function SatelliteDevice:PrxGuide(tParams)
	LogTrace("SatelliteDevice:PrxGuide")
	SatelliteCom_Guide(tParams)
end

function SatelliteDevice:PrxNumber0(tParams)
	LogTrace("SatelliteDevice:PrxNumber0")
	SatelliteCom_Number0(tParams)
end

function SatelliteDevice:PrxNumber1(tParams)
	LogTrace("SatelliteDevice:PrxNumber1")
	SatelliteCom_Number1(tParams)
end

function SatelliteDevice:PrxNumber2(tParams)
	LogTrace("SatelliteDevice:PrxNumber2")
	SatelliteCom_Number2(tParams)
end

function SatelliteDevice:PrxNumber3(tParams)
	LogTrace("SatelliteDevice:PrxNumber3")
	SatelliteCom_Number3(tParams)
end

function SatelliteDevice:PrxNumber4(tParams)
	LogTrace("SatelliteDevice:PrxNumber4")
	SatelliteCom_Number4(tParams)
end

function SatelliteDevice:PrxNumber5(tParams)
	LogTrace("SatelliteDevice:PrxNumber5")
	SatelliteCom_Number5(tParams)
end

function SatelliteDevice:PrxNumber6(tParams)
	LogTrace("SatelliteDevice:PrxNumber6")
	SatelliteCom_Number6(tParams)
end

function SatelliteDevice:PrxNumber7(tParams)
	LogTrace("SatelliteDevice:PrxNumber7")
	SatelliteCom_Number7(tParams)
end

function SatelliteDevice:PrxNumber8(tParams)
	LogTrace("SatelliteDevice:PrxNumber8")
	SatelliteCom_Number8(tParams)
end

function SatelliteDevice:PrxNumber9(tParams)
	LogTrace("SatelliteDevice:PrxNumber9")
	SatelliteCom_Number9(tParams)
end

function SatelliteDevice:PrxHyphen(tParams)
	LogTrace("SatelliteDevice:PrxHyphen")
	SatelliteCom_Hyphen(tParams)
end

function SatelliteDevice:PrxStar(tParams)
	LogTrace("SatelliteDevice:PrxStar")
	SatelliteCom_Star(tParams)
end

function SatelliteDevice:PrxPound(tParams)
	LogTrace("SatelliteDevice:PrxPound")
	SatelliteCom_Pound(tParams)
end

function SatelliteDevice:PrxDVR(tParams)
	LogTrace("SatelliteDevice:PrxDVR")
	SatelliteCom_DVR(tParams)
end

function SatelliteDevice:PrxClosedCaptioned(tParams)
	LogTrace("SatelliteDevice:PrxClosedCaptioned")
	SatelliteCom_ClosedCaptioned(tParams)
end

function SatelliteDevice:PrxProgramA(tParams)
	LogTrace("SatelliteDevice:PrxProgramA")
	SatelliteCom_ProgramA(tParams)
end

function SatelliteDevice:PrxProgramB(tParams)
	LogTrace("SatelliteDevice:PrxProgramB")
	SatelliteCom_ProgramB(tParams)
end

function SatelliteDevice:PrxProgramC(tParams)
	LogTrace("SatelliteDevice:PrxProgramC")
	SatelliteCom_ProgramC(tParams)
end

function SatelliteDevice:PrxProgramD(tParams)
	LogTrace("SatelliteDevice:PrxProgramD")
	SatelliteCom_ProgramD(tParams)
end


--=============================================================================
--=============================================================================
