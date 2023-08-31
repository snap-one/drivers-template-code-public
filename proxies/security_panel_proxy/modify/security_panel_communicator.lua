--[[=============================================================================
    File is: security_panel_communicator.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_panel_communicator = "2022.11.21"
end



--[[=============================================================================
    Re-read information from the panel hardware about partitions and zones
===============================================================================]]
function SecurityPanelCom_ReadPanelInfo()
	LogTrace("SecurityPanelCom_ReadPanelInfo")
	LogInfo("Security Panel  Read Panel Info Not Implemented")	-- default

end


--[[=============================================================================
    Convert the given date/time parameters into the format required by the security panel
===============================================================================]]
function SecurityPanelCom_SendDateAndTime(TargYear, TargMonth, TargDay, TargHour, TargMinute, TargSecond, InterfaceID)
	LogTrace("SecurityPanelCom_SendDateAndTime")
	LogInfo("Security Panel  Send Date And Time Not Implemented")	-- default

end


--[[=============================================================================
    Convert the given zone parameters into the format required by the panel
===============================================================================]]
function SecurityPanelCom_SendSetZoneInfo(ZoneID, ZoneName, ZoneType, InterfaceID)
	LogTrace("SecurityPanelCom_SendSetZoneInfo")
	LogInfo("Security Panel  Set Zone Info Not Implemented")	-- default

end


--[[=============================================================================
    Tell the panel to activate or de-activate a specific partition
===============================================================================]]
function SecurityPanelCom_SendPartitionEnabled(PartitionIndex, IsEnabled, InterfaceID)
	LogTrace("SecurityPanelCom_SendPartitionEnabled")
	LogInfo("Security Panel  Set Partition Enabled Not Implemented")	-- default

end

--[[=============================================================================
    Process additional info that was requested from the panel UI
===============================================================================]]
function SecurityPanelCom_ProcessAdditionalPanelInfo(InfoString, NewInfo, FunctionName, InterfaceID)
	LogTrace("SecurityPanelCom_ProcessAdditionalPanelInfo")
	LogInfo("Security Panel  Process Additional Panel Info Not Implemented")	-- default

end


