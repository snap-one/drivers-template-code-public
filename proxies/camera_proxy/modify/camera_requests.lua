--[[=============================================================================
    File is: camera_requests.lua

    Copyright 2019 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.camera_requests = "2019.02.08"
end
	
	
--================================================================

function CameraReq_SnapshotQueryString(tParams)
	LogTrace("CameraReq_SnapshotQueryString")
							 -- )
	tParams = tParams or {}
	local size_x = tonumber(tParams["SIZE_X"]) or 640
	local size_y = tonumber(tParams["SIZE_Y"]) or 480

	-- Build up the string here
	local SnapQueryString = "Sample Snapshot Query String"

	LogDebug("SnapQueryString is: %s", SnapQueryString)
	return SnapQueryString
end


function CameraReq_MjpegQueryString(tParams)
	tParams = tParams or {}
    local size_x = tonumber(tParams["SIZE_X"]) or 640
    local size_y = tonumber(tParams["SIZE_Y"]) or 480
	local delay = tonumber(tParams["DELAY"]) or 200

	-- Build up the string here
	local MjpegQueryString = "Sample MJpeg Query String"
	
	LogDebug("MjpegQueryString is: %s", MjpegQueryString)
	return MjpegQueryString
end


function CameraReq_RtspH264QueryString(tParams)
	tParams = tParams or {}

	local size_x = tonumber(tParams["SIZE_X"]) or 720
	local size_y = tonumber(tParams["SIZE_Y"]) or 480
	local delay = tonumber(tParams["DELAY"]) or 50

	-- Build up the string here
	local H264QueryString = C4:XmlEscapeString("Sample RTSP H264 Query String")
	LogDebug("H264QueryString is: %s", H264QueryString)
	return H264QueryString
	
end




