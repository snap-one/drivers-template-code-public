--[[=============================================================================
    File is: camera_reports.lua

    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

---------------------------------------------------------------------------------------


function CameraReport_PropertyDefaults()
	TheCamera:ReportPropertyDefaults()
end


function CameraReport_AddressChanged(NewAddress)
	TheCamera:ReportAddressChanged(NewAddress)
end


function CameraReport_HttpPortChanged(NewPort)
	TheCamera:ReportHttpPortChanged(NewPort)
end




