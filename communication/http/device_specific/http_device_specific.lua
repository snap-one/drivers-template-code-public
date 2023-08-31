--[[=============================================================================
	File is: http_device_specific.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

--[[=====================================================================
	Sample of a callback routine.

function HandleXXXXResponse(strError, responseCode, tHeaders, data, context, url)
	if (strError) then
		LogTrace ('HTTP Error: %s', tostring(strError))
		return
	end 
	
	if (responseCode == 200) then 
		if (data.error) then
			LogTrace ('HTTP Data Error: %s', tostring(data.error[2]))
		return
		
		-- Put response handler code here.
	end
end

--]]

--------------------

