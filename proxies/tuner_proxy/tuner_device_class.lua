--[[=============================================================================
    Tuner Device Class

    Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "tuner_proxy.tuner_proxy_commands"
require "tuner_proxy.tuner_proxy_notifies"
require "modules.c4_metrics"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tuner_device_class = "2023.02.02"
end

TunerDevice = inheritsFrom(C4ProxyBase)

TunerDevice.DefaultProxyName = ""


--[[=============================================================================
    Tuner Input Class
===============================================================================]]
TunerInput = inheritsFrom(nil)

TunerInput.AMBandStr = "AMBand"
TunerInput.FMBandStr = "FMBand"
TunerInput.XMBandStr = "XMBand"


TunerInput.AM9BandInfo = {
	MinChannel = "531",
	MaxChannel = "1611",
	ChannelSpacing = "9",
}

TunerInput.AM10BandInfo = {
	MinChannel = "530",
	MaxChannel = "1710",
	ChannelSpacing = "10",
}

TunerInput.FM50BandInfo = {
	MinChannel = "8750",
	MaxChannel = "10800",
	ChannelSpacing = "5",
}

TunerInput.FM100BandInfo = {
	MinChannel = "7600",
	MaxChannel = "9000",
	ChannelSpacing = "10",
}

TunerInput.FM101BandInfo = {
	MinChannel = "8750",
	MaxChannel = "10800",
	ChannelSpacing = "10",
}

TunerInput.FM200BandInfo = {
	MinChannel = "8750",
	MaxChannel = "10790",
	ChannelSpacing = "20",
}

TunerInput.XMBandInfo = {
	MinChannel = "1",
	MaxChannel = "255",
	ChannelSpacing = "1",
}


TunerInput.BandInfo = {
	[TunerInput.AMBandStr] = TunerInput.AM10BandInfo,
	[TunerInput.FMBandStr] = TunerInput.FM200BandInfo,
	[TunerInput.XMBandStr] = TunerInput.XMBandInfo,
}

function TunerInput:construct(BindingID, BandType, InputName)
	self._BindingID = BindingID
	self._BandType = BandType
	self._Name = InputName
	self._BandInfo = TunerInput.BandInfo[BandType]
end

function TunerInput:GetBindingID()
	return self._BindingID
end

function TunerInput:GetBandType()
	return self._BandType
end

function TunerInput:GetName()
	return self._Name
end

function TunerInput:GetMinChannel()
	return self._BandInfo.MinChannel
end

function TunerInput:GetMaxChannel()
	return self._BandInfo.MaxChannel
end

function TunerInput:GetChannelSpacing()
	return self._BandInfo.ChannelSpacing
end


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function TunerDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._PowerOn = false
	self._CurrentChannel = "-"
	self._CurrentInput = nil
	self._PersistData = nil
	self._InputsByBinding = {}
	self._InputsByName = {}
	self._CurrentRadioText = ""
	self._CurrentProgramStationName = ""
	self._DefaultInput = nil

	-- first one in gets to be the default
	if(TunerDevice.DefaultProxyName == "") then
		TunerDevice.DefaultProxyName = self:GetProxyName()
	end
end


function TunerDevice:InitialSetup()
	
	if(PersistData.TunerPersist == nil) then
		PersistData.TunerPersist = {}
	end

	if(PersistData.TunerPersist[self:GetProxyName()] == nil) then
		self._PersistData = {}
		PersistData.TunerPersist[self:GetProxyName()] = self._PersistData
		self._PersistData._Capabilities = {}
		self:InitializeCapabilities()
	else
		self._PersistData = PersistData.TunerPersist[self:GetProxyName()]
	end
	
	-- Find the antenna inputs
	local AllBindingTab = C4:GetBindingsByDevice(self:GetProxyDeviceID()).bindings
	for _, CurBindingInfo in pairs(AllBindingTab) do
		LogInfo("Get info for binding: %s  %s", tostring(CurBindingInfo.bindingid), CurBindingInfo.name)
--		LogInfo(CurBindingInfo)
		for _, CurBindClass in pairs(CurBindingInfo.bindingclasses) do
			if(CurBindClass.class == "RF_AM") then
				self:AddAMInput(CurBindingInfo.bindingid, CurBindingInfo.name)
				LogInfo(CurBindClass)
				
			elseif(CurBindClass.class == "RF_FM") then
				self:AddFMInput(CurBindingInfo.bindingid, CurBindingInfo.name)
				LogInfo(CurBindClass)
			
			elseif(CurBindClass.class == "RF_XM") then
				self:AddXMInput(CurBindingInfo.bindingid, CurBindingInfo.name)
			
			end
		end
	end
end


function TunerDevice:InitializeCapabilities()
--	PersistTunerData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
end

-------------

function TunerDevice:AddInputToLists(BindingID, BandStr, InputName)
	local NewInput = TunerInput:new(BindingID, BandStr, InputName)
	self._InputsByBinding[BindingID] = NewInput
	self._InputsByName[InputName] = NewInput

	if(self._DefaultInput == nil) then
		self._DefaultInput = NewInput		-- first one created gets to be the default
	end
end

function TunerDevice:AddAMInput(BindingID, InputName)
	self:AddInputToLists(BindingID, TunerInput.AMBandStr, InputName)
end

function TunerDevice:AddFMInput(BindingID, InputName)
	self:AddInputToLists(BindingID, TunerInput.FMBandStr, InputName)
end

function TunerDevice:AddXMInput(BindingID, InputName)
	self:AddInputToLists(BindingID, TunerInput.XMBandStr, InputName)
end


function TunerDevice:IsPowerOn()
	return self._PowerOn
end

function TunerDevice:SetPowerFlag(PowerFlag)
	if(PowerFlag ~= self._PowerOn) then
		self._PowerOn = PowerFlag
		
		if(self._PowerOn) then
			NOTIFY.TUNER_ON(self._BindingID)
		else
			NOTIFY.TUNER_OFF(self._BindingID)
		end
	end
end


function TunerDevice:GetCurrentChannel()
	return self._CurrentChannel
end

function TunerDevice:SetCurrentChannel(TargChannel)
	if(TargChannel ~= self._CurrentChannel) then
		self._CurrentChannel = TargChannel
		NOTIFY.TUNER_CHANNEL_CHANGED(self._CurrentChannel, self._BindingID)
	end
end

function TunerDevice:SetCurrentInput(TargInputName)
	local CurInputName = self._CurrentInput and self._CurrentInput:GetName() or ""

	if(TargInputName ~= CurInputName) then
		self._CurrentInput = self._InputsByName[TargInputName]
		
		if(self._CurrentInput ~= nil) then
			NOTIFY.TUNER_INPUT_CHANGED(	self._CurrentInput:GetBandType(), 
										self._CurrentInput:GetBindingID(),
										self._CurrentInput:GetMinChannel(),
										self._CurrentInput:GetMaxChannel(),
										self._CurrentInput:GetChannelSpacing(),
										self._BindingID
									  )
		else
			LogWarn("TunerDevice:SetCurrentInput  Undefined input name: %s", tostring(TargInputName))
		end
	end
end


function TunerDevice:SetProgramStationName(TargStationName)
	self._CurrentProgramStationName = TargStationName
	NOTIFY.TUNER_PSN_CHANGED(self._CurrentProgramStationName, self._BindingID)
end

function TunerDevice:GetProgramStationName()
	return self._CurrentProgramStationName
end

function TunerDevice:SetRadioText(NewText)
	self._CurrentRadioText = NewText
	NOTIFY.TUNER_RADIO_TEXT_CHANGED(self._CurrentRadioText, self._BindingID)
end

function TunerDevice:GetRadioText()
	return self._CurrentRadioText
end


--=============================================================================
--=============================================================================

function TunerDevice:PrxOn(tParams)
	LogTrace("TunerDevice:PrxOn")
	DataLakeMetrics:MetricsCounter('Tuner RequestPowerOn')
	TunerCom_On(self:GetProxyName(), tParams)
end

function TunerDevice:PrxOff(tParams)
	LogTrace("TunerDevice:PrxOff")
	DataLakeMetrics:MetricsCounter('Tuner RequestPowerOff')
	TunerCom_Off(self:GetProxyName(), tParams)
end


function TunerDevice:PrxPresetUp(tParams)
	LogTrace("TunerDevice:PrxPresetUp")
	TunerCom_PresetUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxPresetDown(tParams)
	LogTrace("TunerDevice:PrxPresetDown")
	TunerCom_PresetDown(self:GetProxyName(), tParams)
end

function TunerDevice:PrxSetPreset(tParams)
	LogTrace("TunerDevice:PrxSetPreset")
	-- parameter is 0 based, convert to 1 based
	TunerCom_SetPreset(tonumber(tParams.PRESET) + 1, self:GetProxyName(), tParams)
end

function TunerDevice:PrxSkipFwd(tParams)
	LogTrace("TunerDevice:PrxSkipFwd")
	TunerCom_SkipForward(self:GetProxyName(), tParams)
end

function TunerDevice:PrxSkipRev(tParams)
	LogTrace("TunerDevice:PrxSkipRev")
	TunerCom_SkipReverse(self:GetProxyName(), tParams)
end

function TunerDevice:PrxScanFwd(tParams)
	LogTrace("TunerDevice:PrxScanFwd")
	TunerCom_ScanForward(self:GetProxyName(), tParams)
end

function TunerDevice:PrxScanRev(tParams)
	LogTrace("TunerDevice:PrxScanRev")
	TunerCom_ScanReverse(self:GetProxyName(), tParams)
end

function TunerDevice:PrxSetInput(tParams)
	LogTrace("TunerDevice:PrxSetInput")
	TunerCom_SetInput(self._InputsByBinding[tonumber(tParams.INPUT)]:GetName(), self:GetProxyName(), tParams)
end

function TunerDevice:PrxInputToggle(tParams)
	LogTrace("TunerDevice:PrxInputToggle")
	TunerCom_InputToggle(self:GetProxyName(), tParams)
end

function TunerDevice:PrxSetChannel(tParams)
	LogTrace("TunerDevice:PrxSetChannel %s %s", tostring(tParams.CHANNEL), tostring(tParams.INPUT))
	local TargChannel = tostring(tParams.CHANNEL)
	tParams.INPUT = tParams.INPUT or self._DefaultInput:GetBindingID()	-- if not specified, use the default
	local TargBand = self._InputsByBinding[tonumber(tParams.INPUT)]:GetBandType()
	TunerCom_SetChannel(TargChannel, TargBand, self:GetProxyName(), tParams)
end

function TunerDevice:PrxStartChUp(tParams)
	LogTrace("TunerDevice:PrxStartChUp")
	TunerCom_StartChannelUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStopChUp(tParams)
	LogTrace("TunerDevice:PrxStopChUp")
	TunerCom_StopChannelUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStartChDown(tParams)
	LogTrace("TunerDevice:PrxStartChDown")
	TunerCom_StartChannelDown(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStopChDown(tParams)
	LogTrace("TunerDevice:PrxStopChDown")
	TunerCom_StopChannelDown(self:GetProxyName(), tParams)
end

function TunerDevice:PrxPulseChUp(tParams)
	LogTrace("TunerDevice:PrxPulseChUp")
	TunerCom_PulseChannelUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxPulseChDown(tParams)
	LogTrace("TunerDevice:PrxPulseChDown")
	TunerCom_PulseChannelDown(self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber0(tParams)
	LogTrace("TunerDevice:PrxNumber0")
	TunerCom_SendCharacter("0", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber1(tParams)
	LogTrace("TunerDevice:PrxNumber1")
	TunerCom_SendCharacter("1", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber2(tParams)
	LogTrace("TunerDevice:PrxNumber2")
	TunerCom_SendCharacter("2", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber3(tParams)
	LogTrace("TunerDevice:PrxNumber3")
	TunerCom_SendCharacter("3", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber4(tParams)
	LogTrace("TunerDevice:PrxNumber4")
	TunerCom_SendCharacter("4", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber5(tParams)
	LogTrace("TunerDevice:PrxNumber5")
	TunerCom_SendCharacter("5", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber6(tParams)
	LogTrace("TunerDevice:PrxNumber6")
	TunerCom_SendCharacter("6", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber7(tParams)
	LogTrace("TunerDevice:PrxNumber7")
	TunerCom_SendCharacter("7", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber8(tParams)
	LogTrace("TunerDevice:PrxNumber8")
	TunerCom_SendCharacter("8", self:GetProxyName(), tParams)
end

function TunerDevice:PrxNumber9(tParams)
	LogTrace("TunerDevice:PrxNumber9")
	TunerCom_SendCharacter("9", self:GetProxyName(), tParams)
end

function TunerDevice:PrxHyphen(tParams)
	LogTrace("TunerDevice:PrxHyphen")
	TunerCom_SendCharacter("-", self:GetProxyName(), tParams)
end

function TunerDevice:PrxStar(tParams)
	LogTrace("TunerDevice:PrxStar")
	TunerCom_SendCharacter("*", self:GetProxyName(), tParams)
end

function TunerDevice:PrxPound(tParams)
	LogTrace("TunerDevice:PrxPound")
	TunerCom_SendCharacter("#", self:GetProxyName(), tParams)
end


function TunerDevice:PrxInfo(tParams)
	LogTrace("TunerDevice:PrxInfo")
	TunerCom_Info(self:GetProxyName(), tParams)
end

function TunerDevice:PrxGuide(tParams)
	LogTrace("TunerDevice:PrxGuide")
	TunerCom_Guide(self:GetProxyName(), tParams)
end

function TunerDevice:PrxMenu(tParams)
	LogTrace("TunerDevice:PrxMenu")
	TunerCom_Menu(self:GetProxyName(), tParams)
end

function TunerDevice:PrxCancel(tParams)
	LogTrace("TunerDevice:PrxCancel")
	TunerCom_Cancel(self:GetProxyName(), tParams)
end

function TunerDevice:PrxUp(tParams)
	LogTrace("TunerDevice:PrxUp")
	TunerCom_Up(self:GetProxyName(), tParams)
end

function TunerDevice:PrxDown(tParams)
	LogTrace("TunerDevice:PrxDown")
	TunerCom_Down(self:GetProxyName(), tParams)
end

function TunerDevice:PrxLeft(tParams)
	LogTrace("TunerDevice:PrxLeft")
	TunerCom_Left(self:GetProxyName(), tParams)
end

function TunerDevice:PrxRight(tParams)
	LogTrace("TunerDevice:PrxRight")
	TunerCom_Right(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStartDown(tParams)
	LogTrace("TunerDevice:PrxStartDown")
	TunerCom_StartDown(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStartUp(tParams)
	LogTrace("TunerDevice:PrxStartUp")
	TunerCom_StartUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStartLeft(tParams)
	LogTrace("TunerDevice:PrxStartLeft")
	TunerCom_StartLeft(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStartRight(tParams)
	LogTrace("TunerDevice:PrxStartRight")
	TunerCom_StartRight(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStopDown(tParams)
	LogTrace("TunerDevice:PrxStopDown")
	TunerCom_StopDown(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStopUp(tParams)
	LogTrace("TunerDevice:PrxStopUp")
	TunerCom_StopUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStopLeft(tParams)
	LogTrace("TunerDevice:PrxStopLeft")
	TunerCom_StopLeft(self:GetProxyName(), tParams)
end

function TunerDevice:PrxStopRight(tParams)
	LogTrace("TunerDevice:PrxStopRight")
	TunerCom_StopRight(self:GetProxyName(), tParams)
end

function TunerDevice:PrxEnter(tParams)
	LogTrace("TunerDevice:PrxEnter")
	TunerCom_Enter(self:GetProxyName(), tParams)
end

function TunerDevice:PrxExit(tParams)
	LogTrace("TunerDevice:PrxExit")
	TunerCom_Exit(self:GetProxyName(), tParams)
end

function TunerDevice:PrxHome(tParams)
	LogTrace("TunerDevice:PrxHome")
	TunerCom_Home(tParams)
end

function TunerDevice:PrxSettings(tParams)
	LogTrace("TunerDevice:PrxSettings")
	TunerCom_Settings(tParams)
end

function TunerDevice:PrxRecall(tParams)
	LogTrace("TunerDevice:PrxRecall")
	TunerCom_Recall(self:GetProxyName(), tParams)
end

function TunerDevice:PrxClose(tParams)
	LogTrace("TunerDevice:PrxClose")
	TunerCom_Close(self:GetProxyName(), tParams)
end

function TunerDevice:PrxProgramA(tParams)
	LogTrace("TunerDevice:PrxProgramA")
	TunerCom_ProgramA(self:GetProxyName(), tParams)
end

function TunerDevice:PrxProgramB(tParams)
	LogTrace("TunerDevice:PrxProgramB")
	TunerCom_ProgramB(self:GetProxyName(), tParams)
end

function TunerDevice:PrxProgramC(tParams)
	LogTrace("TunerDevice:PrxProgramC")
	TunerCom_ProgramC(self:GetProxyName(), tParams)
end

function TunerDevice:PrxProgramD(tParams)
	LogTrace("TunerDevice:PrxProgramD")
	TunerCom_ProgramD(self:GetProxyName(), tParams)
end

function TunerDevice:PrxPageUp(tParams)
	LogTrace("TunerDevice:PrxPageUp")
	TunerCom_PageUp(self:GetProxyName(), tParams)
end

function TunerDevice:PrxPageDown(tParams)
	LogTrace("TunerDevice:PrxPageDown")
	TunerCom_PageDown(self:GetProxyName(), tParams)
end

