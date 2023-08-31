--[[=============================================================================
    Command Functions Received From Camera Proxy to the Driver

    Copyright 2017 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_proxy_commands = "2021.06.24"
end


---------------------------------------------------------------


function PRX_CMD.PAN_LEFT(idBinding, tParams)
	LogTrace("PRX_CMD.PAN_LEFT")
	ProxyInstance(idBinding):PrxPanLeft(tParams)
end


function PRX_CMD.PAN_RIGHT(idBinding, tParams)
	LogTrace("PRX_CMD.PAN_RIGHT")
	ProxyInstance(idBinding):PrxPanRight(tParams)
end


function PRX_CMD.PAN_SCAN(idBinding, tParams)
	LogTrace("PRX_CMD.PAN_SCAN")
	ProxyInstance(idBinding):PrxPanScan(tParams)
end


function PRX_CMD.TILT_UP(idBinding, tParams)
	LogTrace("PRX_CMD.TILT_UP")
	ProxyInstance(idBinding):PrxTiltUp(tParams)
end


function PRX_CMD.TILT_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.TILT_DOWN")
	ProxyInstance(idBinding):PrxTiltDown(tParams)
end


function PRX_CMD.TILT_SCAN(idBinding, tParams)
	LogTrace("PRX_CMD.TILT_SCAN")
	ProxyInstance(idBinding):PrxTiltScan(tParams)
end


function PRX_CMD.ZOOM_IN(idBinding, tParams)
	LogTrace("PRX_CMD.ZOOM_IN")
	ProxyInstance(idBinding):PrxZoomIn(tParams)
end


function PRX_CMD.ZOOM_OUT(idBinding, tParams)
	LogTrace("PRX_CMD.ZOOM_OUT")
	ProxyInstance(idBinding):PrxZoomOut(tParams)
end


function PRX_CMD.FOCUS_NEAR(idBinding, tParams)
	LogTrace("PRX_CMD.FOCUS_NEAR")
	ProxyInstance(idBinding):PrxFocusNear(tParams)
end


function PRX_CMD.FOCUS_FAR(idBinding, tParams)
	LogTrace("PRX_CMD.FOCUS_FAR")
	ProxyInstance(idBinding):PrxFocusFar(tParams)
end


function PRX_CMD.IRIS_OPEN(idBinding, tParams)
	LogTrace("PRX_CMD.IRIS_OPEN")
	ProxyInstance(idBinding):PrxIrisOpen(tParams)
end


function PRX_CMD.IRIS_CLOSE(idBinding, tParams)
	LogTrace("PRX_CMD.IRIS_CLOSE")
	ProxyInstance(idBinding):PrxIrisClose(tParams)
end


function PRX_CMD.AUTO_FOCUS(idBinding, tParams)
	LogTrace("PRX_CMD.AUTO_FOCUS")
	ProxyInstance(idBinding):PrxAutoFocus(tParams)
end


function PRX_CMD.AUTO_IRIS(idBinding, tParams)
	LogTrace("PRX_CMD.AUTO_IRIS")
	ProxyInstance(idBinding):PrxAutoIris(tParams)
end


function PRX_CMD.HOME(idBinding, tParams)
	LogTrace("PRX_CMD.HOME")
	ProxyInstance(idBinding):PrxHome(tParams)
end


function PRX_CMD.MOVE_TO(idBinding, tParams)
	LogTrace("PRX_CMD.")
	ProxyInstance(idBinding):PrxMoveTo(tParams)
end


function PRX_CMD.NIGHT_MODE(idBinding, tParams)
	LogTrace("PRX_CMD.NIGHT_MODE")
	ProxyInstance(idBinding):PrxNightMode(tParams)
end


function PRX_CMD.PRESET(idBinding, tParams)
	LogTrace("PRX_CMD.PRESET")
	ProxyInstance(idBinding):PrxPreset(tParams)
end


function PRX_CMD.SET_ADDRESS(idBinding, tParams)
	LogTrace("PRX_CMD.SET_ADDRESS")
	ProxyInstance(idBinding):PrxSetAddress(tParams)
end


function PRX_CMD.SET_HTTP_PORT(idBinding, tParams)
	LogTrace("PRX_CMD.SET_HTTP_PORT")
	ProxyInstance(idBinding):PrxSetHttpPort(tParams)
end


function PRX_CMD.SET_RTSP_PORT(idBinding, tParams)
	LogTrace("PRX_CMD.SET_RTSP_PORT")
	ProxyInstance(idBinding):PrxSetRtspPort(tParams)
end


function PRX_CMD.SET_AUTHENTICATION_REQUIRED(idBinding, tParams)
	LogTrace("PRX_CMD.SET_AUTHENTICATION_REQUIRED")
	ProxyInstance(idBinding):PrxSetAuthenticationRequired(tParams)
end


function PRX_CMD.SET_AUTHENTICATION_TYPE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_AUTHENTICATION_TYPE")
	ProxyInstance(idBinding):PrxSetAuthenticationType(tParams)
end


function PRX_CMD.SET_USERNAME(idBinding, tParams)
	LogTrace("PRX_CMD.SET_USERNAME")
	ProxyInstance(idBinding):PrxSetUserName(tParams)
end


function PRX_CMD.SET_PASSWORD(idBinding, tParams)
	LogTrace("PRX_CMD.SET_PASSWORD")
	ProxyInstance(idBinding):PrxSetPassword(tParams)
end


function PRX_CMD.SET_PUBLICLY_ACCESSIBLE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_PUBLICLY_ACCESSIBLE")
	ProxyInstance(idBinding):PrxSetPubliclyAccessible(tParams)
end

---------------------------------------------------------------
---------------------------------------------------------------

function UI_REQ.GET_SNAPSHOT_QUERY_STRING(tParams)
	if (TheCamera) then
		return TheCamera:ReqGetSnapshotQueryString(tParams)
	else
		LogError("UI_REQ.GET_SNAPSHOT_QUERY_STRING  Camera not defined")
		return ""
	end
end

--[[
	Return the query string required for an HTTP image push URL request.
--]]
function UI_REQ.GET_MJPEG_QUERY_STRING(tParams)
	if (TheCamera) then
		return TheCamera:ReqGetMjpegQueryString(tParams)
	else
		LogError("UI_REQ.GET_MJPEG_QUERY_STRING  Camera not defined")
		return ""
	end
end

--[[
	Return the query string required to establish Rtsp connection. May be empty string.
--]]
function UI_REQ.GET_RTSP_H264_QUERY_STRING(tParams)
	if (TheCamera) then
		return TheCamera:ReqGetRtspH264QueryString(tParams)
	else
		LogError("UI_REQ.GET_RTSP_H264_QUERY_STRING  Camera not defined")
		return ""
	end
end





