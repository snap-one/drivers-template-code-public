--[[=============================================================================
    File is: tuner_apis.lua

    Copyright 2022 Wirepath Home Systems LLC. All Rights Reserved.
	
	API calls for developers using Tuner template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tuner_apis = "2022.04.18"
end

--==================================================================


function TunerIsPowerOn(TunerName)
	return ProxyInstance(TunerName or TunerDevice.DefaultProxyName):IsPowerOn()
end

function TunerGetChannel(TunerName)
	return ProxyInstance(TunerName or TunerDevice.DefaultProxyName):GetCurrentChannel()
end


function TunerGetProgramStationName(TunerName)
	return ProxyInstance(TunerName or TunerDevice.DefaultProxyName):GetProgramStationName()
end

function TunerGetRadioText(TunerName)
	return ProxyInstance(TunerName or TunerDevice.DefaultProxyName):GetRadioText()
end

