--[[=============================================================================
	File is: network_main.lua
	Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "network.network_apis"
require "network.network_com"
require "network_device_specific"		-- in the home directory

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.network_main = "2022.04.27"
end

TheNetworkCom = nil

NetworkCom.PROP_POLLING_INTERVAL_SECONDS	= "Polling Interval Seconds"
NetworkCom.PROP_MAC_ADDRESS	= "MAC Address"

function ON_DRIVER_INIT.NetworkCommunicationSupport(strDit)

	TheNetworkCom = NetworkCom:new()

	if(TheNetworkCom == nil) then
		LogFatal("ON_DRIVER_INIT.NetworkCommunicationSupport  Failed to instantiate Network Communication")
	end
end


function ReceivedFromNetwork(idBinding, nPort, sData)
	TheNetworkCom:ReceivedData(nPort, sData)
end

function OnConnectionStatusChanged(idBinding, nPort, sStatus)
	LogTrace('OnConnectionStatusChanged(): idBinding = %s  nPort = %s  sStatus == %s', tostring(idBinding), tostring(nPort), tostring(sStatus))
	
	if(idBinding == TheNetworkCom:GetNetworkBindingID()) then
		if((DeviceCommunicationStatusChanged ~= nil) and (type(DeviceCommunicationStatusChanged) == "function")) then
			DeviceCommunicationStatusChanged("Network", sStatus == "ONLINE")
		end
	end
end

function OnNetworkBindingChanged(idBinding, bIsBound)
	LogTrace('OnNetworkBindingChanged() idBinding: %s  IsBound: %s', tostring(idBinding), tostring(bIsBound))

    if(idBinding == TheNetworkCom:GetNetworkBindingID()) then
        if((DeviceNetworkBindingChanged ~= nil) and (type(DeviceNetworkBindingChanged) == "function")) then
            DeviceNetworkBindingChanged(idBinding, bIsBound)
        end

		if(bIsBound) then
			TheNetworkCom:getMAC()
		end
	end
end


ON_PROPERTY_CHANGED[NetworkCom.PROP_POLLING_INTERVAL_SECONDS] = function (propertyValue)
	if(TheNetworkCom ~= nil) then
		TheNetworkCom:SetPollingInterval(tonumber(propertyValue))
	end
end

ON_PROPERTY_CHANGED[NetworkCom.PROP_MAC_ADDRESS] = function (propertyValue)
	if(TheNetworkCom ~= nil) then
		TheNetworkCom:SetMACAddress(propertyValue)
	end
end

