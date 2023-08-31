--[[=============================================================================
	File is: url_device_specific.lua

    Copyright 2021 Control4 Corporation. All Rights Reserved.
===============================================================================]]

--[[=====================================================================
	Sample of a callback routine.

	A reference to the callback routines are sent as an optional parameter to
	UrlGet, UrlPut, and UrlPost.

	This routine will be called when the transfer completes

  The format of the functions is:
	function(ResponseCode, Data)
		ResponseCode is the status of the call e.g 200 means success, 401 means unauthorized
		Data is the information that was returned from the transfer callback

function Resp_XXX(ResponseCode, Data)
	LogTrace("Resp_XXX  ResponseCode is %d  Data is %s", tonumber(ResponseCode), tostring(Data))

	-- Handling code goes here

end

--]]


--------------------
