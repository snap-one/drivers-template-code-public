--[[=============================================================================
	File is: server_com.lua
	Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]


ServerBuffer = {}

gServerPort = 0

function OnServerStatusChanged (nPort, strStatus)
	LogTrace("ServerStatusChanged(" .. nPort .. ") now " .. strStatus)
	gServerPort = nPort
end


function OnServerConnectionStatusChanged(nHandle, nPort, strStatus)
	if (strStatus == 'ONLINE') then
		ServerBuffer [nHandle] = ''
	elseif (strStatus == 'OFFLINE') then
		C4:ServerCloseClient (nHandle)
		ServerBuffer [nHandle] = nil
	end
	
	if(DeviceOnlineStatusChanged ~= nil) then
		DeviceOnlineStatusChanged(strStatus == 'ONLINE')
	end
end


function OnServerDataIn(nHandle, strData)

	LogTrace("OnServerDataIn %d == %s ==", tonumber(nHandle), tostring(strData))

	local function ProcessHTTP (idBinding, isServer)
		local Buffer = Buffer
		if (isServer) then Buffer = ServerBuffer end

		local i, _, HTTP_Header, HTTP_Content = string.find (Buffer [idBinding], '(.-\r\n)\r\n(.*)')

		if (i == nil) then	-- no <cr><lf><cr><lf> received yet
			return
		end

		local rcvHeaders = {}

		string.gsub (HTTP_Header, '([^%s:]+):?%s?([^\r\n]*)\r\n', function (a, b) rcvHeaders [string.upper (a)] = b return '' end)

		if (rcvHeaders ['CONTENT-LENGTH'] and HTTP_Content:len() < tonumber (rcvHeaders ['CONTENT-LENGTH'])) then	-- Packet not complete yet, still waiting for content to arrive
			return
		end

		if (rcvHeaders ['TRANSFER-ENCODING'] and string.find (rcvHeaders ['TRANSFER-ENCODING'], 'chunked')) then	--what about a stream? Do we need to deal with that?
			local result = ''
			local lastChunk = false

			while (not lastChunk) do
				local _, chunkStart, chunkLen = string.find (HTTP_Content, '^%W-(%x+).-\r\n')	--allow for chunk extensions between HEX and crlf
				if (not chunkLen) then return end --waiting for more HTTP chunks  	--waiting for more to come in?
				chunkLen = tonumber (chunkLen, 16)

				if (chunkLen == 0 or chunkLen == nil) then
					lastChunk = true
				else
					result = result .. string.sub (HTTP_Content, chunkStart + 1, chunkStart + chunkLen)

					HTTP_Content = string.sub (HTTP_Content, chunkStart + chunkLen + 1)
				end
			end

			HTTP_Content = result
		end

		-- if (rcvHeaders ['CONTENT-ENCODING'] and rcvHeaders ['CONTENT-ENCODING'] == 'gzip') then
			-- HTTP_Content = Helper.Deflate (HTTP_Content)
		-- end

		Buffer [idBinding] = ''

		if (HTTP_Content == nil) then HTTP_Content = '' end

		return HTTP_Content, rcvHeaders
	end


	if (ServerBuffer and ServerBuffer [nHandle]) then
		ServerBuffer [nHandle] = ServerBuffer [nHandle] .. strData
		local content, headers = ProcessHTTP (nHandle, true)

		if (headers and content) then
			C4:ServerSend (nHandle, 'HTTP/1.1 200 OK\r\n\r\n')

			HandleServerDataIn(headers, content)

			if (not (headers.CONNECTION and headers.CONNECTION == 'Keep-Alive')) then
				C4:ServerCloseClient (nHandle)
			end
		end
	end
end

