--[[=============================================================================
	File is: serial_com.lua
	Copyright 2023 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.serial_com = "2023.01.31"
end


SerialCom = inheritsFrom(nil)


function SerialCom:construct()
	self._IsInitialized = false
	self._BindingID = 0
	self._MonitorTraffic = false
	self:ClearReceiveBuffer()
end

function SerialCom:InitialSetup(BindingID)
	LogTrace("SerialCom:InitialSetup")
	
	self._BindingID = BindingID
	self:ClearReceiveBuffer()

	self._IsInitialized = true
end


function SerialCom:ClearReceiveBuffer()
	self._ReceiveBuf = ""
end


function SerialCom:DataIn(DataStr)

	-- Save messages coming in until we have a full message
	self._ReceiveBuf = self._ReceiveBuf .. DataStr

	local MsgBytesUsed = 0
	local ExtractedMessage = ""
	repeat
		local MsgBytesUsed, ExtractedMessage = ExtractSerialMessage(self._ReceiveBuf)
		if(MsgBytesUsed > 0) then
			-- move past the bytes that were just used
			self._ReceiveBuf = string.sub(self._ReceiveBuf, MsgBytesUsed+1)
		end
	until (MsgBytesUsed == 0)
	
end


function SerialCom:GetBindingID()
	return self._BindingID
end


function SerialCom:IsInitialized()
	return self._IsInitialized
end


function SerialCom:SendSerialData(DataStr)
	if(self._MonitorTraffic) then
		LogDev("=>=>=>=>=> %s", HexToString(DataStr))
	end
	
	C4:SendToSerial(self._BindingID, DataStr)
end

function SerialCom:MonitorIt(MonitorFlag)
	self._MonitorTraffic = MonitorFlag
end


-------------

function ReceivedFromSerial(idBinding, strData)
	DoSerialInputLog(strData)
	if(TheSerialCom._MonitorTraffic) then
		LogDev("<<<<<<<<<< %s", HexToString(strData))
	end
	
	if(idBinding == TheSerialCom:GetBindingID()) then
		TheSerialCom:DataIn(strData)
	end
end

SerialInputLogEnabled = false
SerialInputLog = {}
SERIAL_INPUT_LOG_COUNT = 25

function DoSerialInputLog(InByteData)
	if(SerialInputLogEnabled) then
		if(#SerialInputLog >= SERIAL_INPUT_LOG_COUNT) then
			for LogIndex = 1, SERIAL_INPUT_LOG_COUNT - 1 do
				SerialInputLog[LogIndex] = SerialInputLog[LogIndex + 1]
			end
			
			SerialInputLog[SERIAL_INPUT_LOG_COUNT] = nil
		end
		
		SerialInputLog[#SerialInputLog + 1] = HexToString(InByteData)
	end
end

function SeeSerialInputLog()
	for LogIndex = 1, #SerialInputLog do
		print(string.format("%02d --> %s", LogIndex, SerialInputLog[LogIndex]))
	end
end

function EnableSerialInputLog()
	SerialInputLogEnabled = true
end

function DisableSerialInputLog()
	SerialInputLogEnabled = false
end


