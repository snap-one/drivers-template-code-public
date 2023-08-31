--[[=============================================================================
	File is: network_com.lua
	Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"

require "modules.encryption"
require "modules.c4_metrics"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.network_com = "2022.04.29"
end


NetworkCom = inheritsFrom(nil)

NETWORK_COM_PERSIST_RECORD_NAME = "NetworkComPersist"

function NetworkCom:construct()

	PersistData[NETWORK_COM_PERSIST_RECORD_NAME] = C4:PersistGetValue(NETWORK_COM_PERSIST_RECORD_NAME)

	if(PersistData[NETWORK_COM_PERSIST_RECORD_NAME] == nil) then
		PersistData[NETWORK_COM_PERSIST_RECORD_NAME] = {
			_PollingTimerIsEnabled = true,
			_PollingTimerInterval = 30,
			_Current_MAC_Address = "",
		}
		
		self:PersistSave()
	end
	self._Persist = PersistData[NETWORK_COM_PERSIST_RECORD_NAME]

	self._NetworkBindingID = 0
	self._NetworkBindingPort = 0

	self._PollingRoutine = nil
	
	self._IsInitialized = false
	self._IsOnline = false

	self._MissedCheckinCount = 0
	self._PollingTimer = CreateTimer("PollingTimer", self._Persist._PollingTimerInterval, "SECONDS", NetworkCom.OnPollingTimerExpired, false, self)
	self._NetworkReconnectFailureTimer = CreateTimer("NetworkReconnectFailureTimer", 3, "SECONDS",  NetworkCom.OnNetworkReconnectFailureTimerExpired, false, self)

end


function NetworkCom:InitialSetup(NetBindingID, NetPort, PollingRoutine)
	self:SetNetworkBindingID(NetBindingID)
	self:SetNetworkBindingPort(NetPort)
	self._PollingRoutine = PollingRoutine
	self:PersistSave()
	self:ClearReceiveBuffer()

	self:SetMACAddress(self._Persist._Current_MAC_Address)
	self:SetPollingInterval(self._Persist._PollingTimerInterval)
	self._IsInitialized = true
end


function NetworkCom:ClearReceiveBuffer()
	self._ReceiveBuffer = ""
end


function NetworkCom:IsInitialized()
	return self._IsInitialized
end


function NetworkCom:IsOnline()
	return self._IsOnline
end

----------------------

function NetworkCom:PersistSave()
	C4:PersistSetValue(NETWORK_COM_PERSIST_RECORD_NAME, PersistData[NETWORK_COM_PERSIST_RECORD_NAME])
end


-------------

function NetworkCom:GetNetworkBindingID()
	return self._NetworkBindingID
end


function NetworkCom:SetNetworkBindingID(NewBindingId)
	self._NetworkBindingID = NewBindingId
end


function NetworkCom:GetNetworkBindingPort()
	return self._NetworkBindingPort
end


function NetworkCom:SetNetworkBindingPort(NewPortId)
	self._NetworkBindingPort = NewPortId
end


function NetworkCom:GoOnline()
	self._IsOnline = true
	self._MissedCheckinCount = 0
	self:getMAC()
	self:StartPollingTimer()
	self._NetworkReconnectFailureTimer:KillTimer()
end

function NetworkCom:GoOffline()
	self._IsOnline = false
	self:KillPollingTimer()
end

-------------

function NetworkCom:IsPollingTimerEnabled()
	return self._PollingTimerIsEnabled
end

function NetworkCom:SetPollingTimerEnabled(EnableIt)
	self._PollingTimerIsEnabled = EnableIt
	if(self._PollingTimerIsEnabled) then
		self:StartPollingTimer()
	else
		self:KillPollingTimer()
	end
end

function NetworkCom:StartPollingTimer()
	if(self._PollingTimerIsEnabled and self._IsOnline) then
		self._PollingTimer:StartTimer(self._Persist._PollingTimerInterval)
	end
end

function NetworkCom:KillPollingTimer()
	self._PollingTimer:KillTimer()
	self._MissedCheckinCount = 0
end

function NetworkCom:SetPollingInterval(NewInterval)
	self._Persist._PollingTimerInterval = NewInterval
	self:PersistSave()
	UpdateProperty(NetworkCom.PROP_POLLING_INTERVAL_SECONDS, self._Persist._PollingTimerInterval)
	self:StartPollingTimer()
end


function NetworkCom:HandlePolling()
	self._MissedCheckinCount = self._MissedCheckinCount + 1

	if(self._MissedCheckinCount > 2) then
		if(self._IsOnline) then
			-- Director says we're still online, but we can't seem to communicate.
			-- Try going offline and then back on again.
			C4:NetDisconnect(NETWORK_BINDING_ID, NETWORK_PORT)
			OneShotTimerAdd(1, "SECONDS",
							function()
								C4:NetConnect(NETWORK_BINDING_ID, NETWORK_PORT)
								self._NetworkReconnectFailureTimer:StartTimer()
							end,
							"Network Reconnect")
		end
	end

	if(self._PollingRoutine ~= nil) then
		self._PollingRoutine()
	end

	self._PollingTimer:StartTimer(self._Persist._PollingTimerInterval)
end


function NetworkCom.OnPollingTimerExpired(NetworkComInst)
	NetworkComInst:HandlePolling()
end

function NetworkCom:HandleReconnectFailure()
	DataLakeMetrics:MetricsCounter('NetworkReconnectFailed')
	self._NetworkReconnectFailureTimer:KillTimer()
	self._PollingTimer:KillTimer()
end

function NetworkCom.OnNetworkReconnectFailureTimerExpired(NetworkComInst)
	NetworkComInst:HandleReconnectFailure()
end

-------------

function NetworkCom:SendNetworkMessage(msg)
	if(self._IsOnline) then
		C4:SendToNetwork(self._NetworkBindingID, self._NetworkBindingPort, msg)
	else
		LogWarn("Message not sent.  Device offline")
	end
end

function NetworkCom:ReceivedData(PortNum, InData)

	-- Save messages coming in until we have a full message
	self._ReceiveBuffer = self._ReceiveBuffer .. InData

	local MsgBytesUsed = 0
	local ExtractedMessage = ""
	self._MissedCheckinCount = 0
	repeat
		local MsgBytesUsed, ExtractedMessage = ExtractNetworkMessage(self._ReceiveBuffer)
		--LogInfo("NetworkCom:ReceivedData")
		if(MsgBytesUsed > 0) then
			-- move past the bytes that were just used
			self._ReceiveBuffer = string.sub(self._ReceiveBuffer, MsgBytesUsed+1)
		end
	until (MsgBytesUsed == 0)
end

-------------

function NetworkCom:sendWOL()
	LogTrace("[----> DEV ]: Sending WOL")
	
	if(self._Persist._Current_MAC_Address ~= "") then
		if (C4.SendWOL) then	--C4:SendWOL() added in OS 2.10
			for i = 1,5 do	   
				C4:SendWOL(self._Persist._Current_MAC_Address, BROADCAST_PORT)
			end

			DataLakeMetrics:MetricsCounter('WakeOnLan')
		else
			C4:CreateNetworkConnection (BROADCAST_BINDING_ID, "255.255.255.255", BROADCAST_PORT) --create network connection BROADCAST_BINDING_ID for Wake on Lan
			C4:NetConnect(BROADCAST_BINDING_ID, BROADCAST_PORT, "UDP") --connect to connection BROADCAST_BINDING_ID and make it UDP for Wake On Lan
		   
			local mac_hex = self:format_mac_hex()
			local packet = string.rep(string.char(255), 6) .. string.rep(mac_hex, 16) -- Build 'magic packet'. 
			--hexdump (packet) 
			
			for i = 1,5 do	  
				C4:SendToNetwork (BROADCAST_BINDING_ID, BROADCAST_PORT, packet)
			end
			
			DataLakeMetrics:MetricsCounter('WakeOnLanPre210')
		end
	else
		DataLakeMetrics:MetricsCounter('WOLAbortedNoMACAddressValue')
	end
end

function NetworkCom:format_mac_string()
    -- local mac = Properties['MAC Address'] or ''
	-- local mac_string = ''
	-- if (mac ~= nil and mac ~= "") then
		-- mac_string = mac:gsub("%X", "")
	-- end

	-- return mac_string
	return self._Persist._Current_MAC_Address
end

function NetworkCom:format_mac_hex()
--    local mac = Properties['MAC Address'] or ''
--	local mac_string = mac:gsub("%X", " ")

	return tohex(self._Persist._Current_MAC_Address)
end

function NetworkCom:getMAC()
	if (C4.GetDeviceMAC) then	--C4:GetDeviceMAC() added in OS 2.10
		local mac = C4:GetDeviceMAC(NETWORK_BINDING_ID)
		if (mac ~= nil and mac ~= "") then
			self:SetMACAddress(mac) 

			if (self._Persist._Current_MAC_Address == "") then
				DataLakeMetrics:MetricsCounter('MacAddressInitialized')

			elseif (self._Persist._Current_MAC_Address ~= mac) then
				DataLakeMetrics:MetricsCounter('MacAddressChanged')

			end
			
			self._Persist._Current_MAC_Address = mac
			self:PersistSave()
			
		else
			DataLakeMetrics:MetricsCounter('C4GetDeviceMACFailed')
		end
	else
		if (self._Persist._Current_MAC_Address == "") then
			DataLakeMetrics:MetricsCounter('NoMACAddressValuePre210')
		end
	end

	return self._Persist._Current_MAC_Address
end


function NetworkCom:SetMACAddress(NewMac)
	self._Persist._Current_MAC_Address = NewMac or ""
	self:PersistSave()
	UpdateProperty(NetworkCom.PROP_MAC_ADDRESS,	self._Persist._Current_MAC_Address)
end

function NetworkCom:GetMACAddress()
	return self._Persist._Current_MAC_Address
end



