--[[=============================================================================
    File is: tuner_reports.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
	
	Routines to report information that we have received from the device.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.tuner_reports = "2022.04.18"
end


---------------------------------------------------------------------------------------


function TunerReport_PowerOn(TunerName)
	ProxyInstance(TunerName or TunerDevice.DefaultProxyName):SetPowerFlag(true)
end

function TunerReport_PowerOff(TunerName)
	ProxyInstance(TunerName or TunerDevice.DefaultProxyName):SetPowerFlag(false)
end


function TunerReport_Channel(Channel, TunerName)
	ProxyInstance(TunerName or TunerDevice.DefaultProxyName):SetCurrentChannel(Channel)
end


function TunerReport_Input(InputName, TunerName)
	ProxyInstance(TunerName or TunerDevice.DefaultProxyName):SetCurrentInput(InputName)
end

function TunerReport_ProgramStationName(StationName, TunerName)
	ProxyInstance(TunerName or TunerDevice.DefaultProxyName):SetProgramStationName(StationName)
end

function TunerReport_RadioText(RadioText, TunerName)
	ProxyInstance(TunerName or TunerDevice.DefaultProxyName):SetRadioText(RadioText)
end
