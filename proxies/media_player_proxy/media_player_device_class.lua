--[[=============================================================================
    MediaPlayer Device Class

    Copyright 2023 Snap One LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "media_player_proxy.media_player_proxy_commands"
require "media_player_proxy.media_player_proxy_notifies"


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.media_player_device_class = "2023.02.02"
end

MediaPlayerDevice = inheritsFrom(C4ProxyBase)

NextMediaPlayerIndex = 1



--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function MediaPlayerDevice:construct(BindingID)
	self:super():construct(BindingID, self)

	self._PowerOn = false
	self._CurrentChannel = "-"
	self._CurrentInput = 0
	self._PersistData = nil
	self._NextInputIndex = 1
	self._Inputs = {}

	self._MediaPlayerIndex = NextMediaPlayerIndex
	TheMediaPlayerList[self._MediaPlayerIndex] = self
	NextMediaPlayerIndex = NextMediaPlayerIndex + 1

end


function MediaPlayerDevice:InitialSetup()
	
	if(PersistData.MediaPlayerPersist == nil) then
		PersistData.MediaPlayerPersist = {}
	end

	if(PersistData.MediaPlayerPersist[self._MediaPlayerIndex] == nil) then
		self._PersistData = {}
		PersistData.MediaPlayerPersist[self._MediaPlayerIndex] = self._PersistData
		self._PersistData._Capabilities = {}
		self:InitializeCapabilities()
	else
		self._PersistData = PersistData.MediaPlayerPersist[self._MediaPlayerIndex]
	end
end


function MediaPlayerDevice:InitializeCapabilities()
--	PersistMediaPlayerData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
end

-------------

function MediaPlayerDevice:IsPowerOn()
	return self._PowerOn
end

function MediaPlayerDevice:SetPowerFlag(PowerFlag)
	if(PowerFlag ~= self._PowerOn) then
		self._PowerOn = PowerFlag
		
		if(self._PowerOn) then
			NOTIFY.MEDIAPLAYER_ON(self._BindingID)
		else
			NOTIFY.MEDIAPLAYER_OFF(self._BindingID)
		end
	end
end


--=============================================================================
--=============================================================================

function MediaPlayerDevice:PrxOn(tParams)
	LogTrace("MediaPlayerDevice:PrxOn")
	MediaPlayerCom_On(tParams)
end

function MediaPlayerDevice:PrxOff(tParams)
	LogTrace("MediaPlayerDevice:PrxOff")
	MediaPlayerCom_Off(tParams)
end

function MediaPlayerDevice:PrxPlay(tParams)
	LogTrace("MediaPlayerDevice:PrxPlay")
	MediaPlayerCom_Play(tParams)
end

function MediaPlayerDevice:PrxStop(tParams)
	LogTrace("MediaPlayerDevice:PrxStop")
	MediaPlayerCom_Stop(tParams)
end

function MediaPlayerDevice:PrxPause(tParams)
	LogTrace("MediaPlayerDevice:PrxPause")
	MediaPlayerCom_Pause(tParams)
end

function MediaPlayerDevice:PrxSkipFwd(tParams)
	LogTrace("MediaPlayerDevice:PrxSkipFwd")
	MediaPlayerCom_SkipForward(tParams)
end

function MediaPlayerDevice:PrxSkipRev(tParams)
	LogTrace("MediaPlayerDevice:PrxSkipRev")
	MediaPlayerCom_SkipReverse(tParams)
end

function MediaPlayerDevice:PrxScanFwd(tParams)
	LogTrace("MediaPlayerDevice:PrxScanFwd")
	MediaPlayerCom_ScanForward(tParams)
end

function MediaPlayerDevice:PrxScanRev(tParams)
	LogTrace("MediaPlayerDevice:PrxScanRev")
	MediaPlayerCom_ScanReverse(tParams)
end

function MediaPlayerDevice:PrxMenu(tParams)
	LogTrace("MediaPlayerDevice:PrxMenu")
	MediaPlayerCom_Menu(tParams)
end

function MediaPlayerDevice:PrxUp(tParams)
	LogTrace("MediaPlayerDevice:PrxUp")
	MediaPlayerCom_Up(tParams)
end

function MediaPlayerDevice:PrxDown(tParams)
	LogTrace("MediaPlayerDevice:PrxDown")
	MediaPlayerCom_Down(tParams)
end

function MediaPlayerDevice:PrxLeft(tParams)
	LogTrace("MediaPlayerDevice:PrxLeft")
	MediaPlayerCom_Left(tParams)
end

function MediaPlayerDevice:PrxRight(tParams)
	LogTrace("MediaPlayerDevice:PrxRight")
	MediaPlayerCom_Right(tParams)
end

function MediaPlayerDevice:PrxEnter(tParams)
	LogTrace("MediaPlayerDevice:PrxEnter")
	MediaPlayerCom_Enter(tParams)
end

function MediaPlayerDevice:PrxExit(tParams)
	LogTrace("MediaPlayerDevice:PrxExit")
	MediaPlayerCom_Exit(tParams)
end

function MediaPlayerDevice:PrxHome(tParams)
	LogTrace("MediaPlayerDevice:PrxHome")
	MediaPlayerCom_Home(tParams)
end

function MediaPlayerDevice:PrxSettings(tParams)
	LogTrace("MediaPlayerDevice:PrxSettings")
	MediaPlayerCom_Settings(tParams)
end

function MediaPlayerDevice:PrxClosedCaptioned(tParams)
	LogTrace("MediaPlayerDevice:PrxClosedCaptioned")
	MediaPlayerCom_ClosedCaptioned(tParams)
end

function MediaPlayerDevice:PrxNumber0(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber0")
	MediaPlayerCom_SendCharacter("0", tParams)
end

function MediaPlayerDevice:PrxNumber1(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber1")
	MediaPlayerCom_SendCharacter("1", tParams)
end

function MediaPlayerDevice:PrxNumber2(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber2")
	MediaPlayerCom_SendCharacter("2", tParams)
end

function MediaPlayerDevice:PrxNumber3(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber3")
	MediaPlayerCom_SendCharacter("3", tParams)
end

function MediaPlayerDevice:PrxNumber4(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber4")
	MediaPlayerCom_SendCharacter("4", tParams)
end

function MediaPlayerDevice:PrxNumber5(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber5")
	MediaPlayerCom_SendCharacter("5", tParams)
end

function MediaPlayerDevice:PrxNumber6(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber6")
	MediaPlayerCom_SendCharacter("6", tParams)
end

function MediaPlayerDevice:PrxNumber7(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber7")
	MediaPlayerCom_SendCharacter("7", tParams)
end

function MediaPlayerDevice:PrxNumber8(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber8")
	MediaPlayerCom_SendCharacter("8", tParams)
end

function MediaPlayerDevice:PrxNumber9(tParams)
	LogTrace("MediaPlayerDevice:PrxNumber9")
	MediaPlayerCom_SendCharacter("9", tParams)
end

function MediaPlayerDevice:PrxDash(tParams)
	LogTrace("MediaPlayerDevice:PrxDash")
	MediaPlayerCom_SendCharacter("-", tParams)
end

function MediaPlayerDevice:PrxStar(tParams)
	LogTrace("MediaPlayerDevice:PrxStar")
	MediaPlayerCom_SendCharacter("*", tParams)
end

function MediaPlayerDevice:PrxPound(tParams)
	LogTrace("MediaPlayerDevice:PrxPound")
	MediaPlayerCom_SendCharacter("#", tParams)
end

