--[[=============================================================================
    Camera Device Class

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "camera_proxy.camera_proxy_commands"
require "camera_proxy.camera_proxy_notifies"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.camera_device_class = "2021.06.24"
end

CameraDevice = inheritsFrom(C4ProxyBase)


--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function CameraDevice:construct(BindingID)
	self:super():construct(BindingID, self)
end


function CameraDevice:InitialSetup()
	
	if(PersistData.CameraPersist == nil) then
		PersistCameraData = {}
		PersistData.CameraPersist = PersistCameraData
		
		PersistCameraData._Capabilities = {}
		self:InitializeCapabilities()

		-- Current Settings
		PersistCameraData.CAMERA_ID = 1
		PersistCameraData.PTZ_INCREMENT		= C4:GetCapability("default_ptz_increment")	or 7
		PersistCameraData.HAS_EPTZ = false
		PersistCameraData.HAS_AUTOFOCUS = false

	else
		PersistCameraData = PersistData.CameraPersist
	end

	self:ReportPropertyDefaults()
end


function CameraDevice:InitializeCapabilities()
--	PersistCameraData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
end

function CameraDevice:GetID()
	return PersistCameraData.CAMERA_ID
end

function CameraDevice:SetID(NewID)
	PersistCameraData.CAMERA_ID = NewID
end

-------------

function CameraDevice:GetPTZIncrement()
	return PersistCameraData.PTZ_INCREMENT
end

function CameraDevice:SetPTZIncrement(NewIncrement)
	PersistCameraData.PTZ_INCREMENT = NewIncrement
end

-------------

function CameraDevice:HasEPTZ()
	return PersistCameraData.HAS_EPTZ
end

function CameraDevice:SetEPTZ(NewFlag)
	PersistCameraData.HAS_EPTZ = NewFlag
end

-------------

function CameraDevice:HasAutoFocus()
	return PersistCameraData.HAS_AUTOFOCUS
end

function CameraDevice:SetAutoFocus(NewFlag)
	PersistCameraData.HAS_AUTOFOCUS = NewFlag
end


--=============================================================================
--=============================================================================

function CameraDevice:PrxPanLeft(tParams)
	LogTrace("")
	CameraCom_PanLeft()
end


function CameraDevice:PrxPanRight(tParams)
	LogTrace("")
	CameraCom_PanRight()
end


function CameraDevice:PrxPanScan(tParams)
	LogTrace("")
	CameraCom_PanScan()
end


function CameraDevice:PrxTiltUp(tParams)
	LogTrace("")
	CameraCom_TiltUp()
end


function CameraDevice:PrxTiltDown(tParams)
	LogTrace("")
	CameraCom_TiltDown()
end


function CameraDevice:PrxTiltScan(tParams)
	LogTrace("")
	CameraCom_TiltScan()
end


function CameraDevice:PrxZoomIn(tParams)
	LogTrace("")
	CameraCom_ZoomIn()
end


function CameraDevice:PrxZoomOut(tParams)
	LogTrace("")
	CameraCom_ZoomOut()
end


function CameraDevice:PrxFocusNear(tParams)
	LogTrace("")
	CameraCom_FocusNear()
end


function CameraDevice:PrxFocusFar(tParams)
	LogTrace("")
	CameraCom_FocusFar()
end


function CameraDevice:PrxIrisOpen(tParams)
	LogTrace("")
	CameraCom_IrisOpen()
end


function CameraDevice:PrxIrisClose(tParams)
	LogTrace("")
	CameraCom_IrisClose()
end


function CameraDevice:PrxAutoFocus(tParams)
	LogTrace("")
	CameraCom_AutoFocus()
end


function CameraDevice:PrxAutoIris(tParams)
	LogTrace("")
	CameraCom_AutoIris()
end


function CameraDevice:PrxHome(tParams)
	LogTrace("")
	CameraCom_Home()
end


function CameraDevice:PrxMoveTo(tParams)
	LogTrace("")
	
    local width = tonumber(tParams["WIDTH"]) or 0
    local height = tonumber(tParams["HEIGHT"]) or 0
	local x_index = tonumber(tParams["X_INDEX"]) or 0
	local y_index = tonumber(tParams["Y_INDEX"]) or 0

	-- local XPos = math.ceil((x_index / width) * 255)
	-- local YPos = math.ceil((y_index / height) * 255)
	
	CameraCom_MoveTo(x_index, y_index, width, height)
end


function CameraDevice:PrxNightMode(tParams)
	LogTrace("")
	local IsNight = false
	CameraCom_NightMode(IsNight)
end


function CameraDevice:PrxPreset(tParams)
	LogTrace("")
	local PresetIndex = tonumber(tParams["INDEX"])
	CameraCom_Preset(PresetIndex)
end


function CameraDevice:PrxSetAddress(tParams)
	LogTrace("CameraDevice:PrxSetAddress")
	local TargAddress = tParams["ADDRESS"]
	CameraCom_SetAddress(TargAddress)
end


function CameraDevice:PrxSetHttpPort(tParams)
	LogTrace("CameraDevice:PrxSetHttpPort")
	local TargPort = tonumber(tParams["PORT"])
	CameraCom_SetHttpPort(TargPort)
end


function CameraDevice:PrxSetRtspPort(tParams)
	LogTrace("CameraDevice:PrxSetRtspPort")
	local TargPort = tonumber(tParams["PORT"])
	CameraCom_SetRtspPort(TargPort)
end


function CameraDevice:PrxSetAuthenticationRequired(tParams)
	LogTrace("CameraDevice:PrxSetAuthenticationRequired")
	local AuthRequired = toboolean(tParams["REQUIRED"])
	CameraCom_SetAuthenticationRequired(AuthRequired)
end


function CameraDevice:PrxSetAuthenticationType(tParams)
	LogTrace("CameraDevice:PrxSetAuthenticationType")
	local AuthType = tParams["TYPE"]
	CameraCom_SetAuthenticationType(AuthType)
end


function CameraDevice:PrxSetUserName(tParams)
	LogTrace("CameraDevice:PrxSetUserName")
	local TargUserName = tParams["USERNAME"]
	CameraCom_SetUsername(TargUserName)
end


function CameraDevice:PrxSetPassword(tParams)
	LogTrace("CameraDevice:PrxSetPassword")
	local PassWord = tParams["PASSWORD"]
	CameraCom_SetPassword(PassWord)
end


function CameraDevice:PrxSetPubliclyAccessible(tParams)
	LogTrace("CameraDevice:PrxSetPubliclyAccessible")
	local PublicAccess = toboolean(tParams["PUBLICLY_ACCESSEIBLE"])
	CameraCom_SetPubliclyAccessible(PublicAccess)
end

--=============================================================================
--=============================================================================

function CameraDevice:ReqGetSnapshotQueryString(tParams)
	return MakeXMLNode("snapshot_query_string", CameraReq_SnapshotQueryString(tParams))
end


function CameraDevice:ReqGetMjpegQueryString(tParams)
	return MakeXMLNode("mjpeg_query_string", CameraReq_MjpegQueryString(tParams))
end


function CameraDevice:ReqGetRtspH264QueryString(tParams)
	return MakeXMLNode("rtsp_h264_query_string", CameraReq_RtspH264QueryString(tParams))
end



--=============================================================================
--=============================================================================


function CameraDevice:ReportPropertyDefaults()
	LogTrace("CameraDevice:ReportPropertyDefaults")
	
	NOTIFY.PROPERTY_DEFAULTS(UrlGetHttpPort(), 
							 UrlGetRtspPort(),
							 UrlIsAuthenticationRequired(),
							 UrlGetAuthenticationType(),
							 UrlGetUserName(),
							 UrlGetPassword(),
							 self._BindingID)
end


function CameraDevice:ReportAddressChanged()
	LogTrace("CameraDevice:ReportAddressChanged -> %s", tostring(UrlGetAddress()))
	NOTIFY.ADDRESS_CHANGED(UrlGetAddress(), self._BindingID)
end


function CameraDevice:ReportHttpPortChanged()
	LogTrace("CameraDevice:ReportHttpPortChanged -> %s", tostring(UrlGetHttpPort()))
	NOTIFY.HTTP_PORT_CHANGED(UrlGetHttpPort(), self._BindingID)
end



