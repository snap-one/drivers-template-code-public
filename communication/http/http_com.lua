--[[=============================================================================
	File is: http_com.lua
    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"

require "modules.encryption"
require "modules.c4_metrics"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.http_com = "2022.06.03"
end

HTTP_DEFAULT_NETWORK_BINDING_ID = 6001
HttpCom = inheritsFrom(nil)


function HttpCom:construct()
	if(PersistData._HttpPersist == nil) then
		PersistData._HttpPersist = {
			ENCRYPTED_PASSWORD		= true,
			_Current_MAC_Address = "",
		}
		
		PersistData._HttpPersist.NETWORK_BINDING_ID		= HTTP_DEFAULT_NETWORK_BINDING_ID
	else
		-- check if this was persisted before we were encrypting the passwords.
		if(PersistData._HttpPersist.ENCRYPTED_PASSWORD == nil) then
			PersistData._HttpPersist.PASSWORD = Encryption:AsciiEncryptIt(PersistData._HttpPersist.PASSWORD)
			PersistData._HttpPersist.ENCRYPTED_PASSWORD		= true
		end
	end

	self._Persist = PersistData._HttpPersist

	self._NameAndPassword = '-:-'
	self._IsInitialized = false

end

function HttpCom:InitialSetup(UserName, Password, AuthRequired, AuthType, Address, HttpPort, RtspPort)
	self.ADDRESS				= Address
	self.HTTP_PORT               = HttpPort
	self.RTSP_PORT               = RtspPort
	self.AUTHENTICATION_REQUIRED = tostring(AuthRequired)
	self.AUTHENTICATION_TYPE     = AuthType
	self.USERNAME                = UserName
	self.PASSWORD                = Encryption:AsciiEncryptIt(Password)

	self:ClearReceiveBuffer()
	self._IsInitialized = true
end

function HttpCom:ClearReceiveBuffer()
	self._ReceiveBuffer = ""
end

function HttpCom:IsInitialized()
	return self._IsInitialized
end

-------------

function HttpCom:GetNetworkBindingID()
	return self._Persist.NETWORK_BINDING_ID
end


function HttpCom:SetNetworkBindingID(NewBindingId)
	self._Persist.NETWORK_BINDING_ID = NewBindingId
end

-------------

function HttpCom:GetAddress()
	return self._Persist.ADDRESS
end

function HttpCom:SetAddress(NewAddress)
	LogTrace("HttpCom:SetAddress: %s", NewAddress)

	if (NewAddress ~= self._Persist.ADDRESS) then
		self._Persist.ADDRESS = NewAddress
	end
end

-------------

function HttpCom:GetHttpPort()
	return self._Persist.HTTP_PORT
end

function HttpCom:SetHttpPort(NewPort)
	LogTrace("HttpCom:SetHttpPort: %s", tostring(NewPort))

	if (NewPort ~= self._Persist.HTTP_PORT) then
		self._Persist.HTTP_PORT = NewPort
	end
end

-------------

function HttpCom:GetRtspPort()
	return self._Persist.RTSP_PORT
end

function HttpCom:SetRtspPort(NewPort)
	LogTrace("HttpCom:SetRtspPort: %s", tostring(NewPort))

	if (NewPort ~= self._Persist.RTSP_PORT) then
		self._Persist.RTSP_PORT = NewPort
	end
end

-------------

function HttpCom:IsAuthenticationRequired()
	return toboolean(self._Persist.AUTHENTICATION_REQUIRED)
end

function HttpCom:SetAuthenticationRequired(IsRequired)
	self._Persist.AUTHENTICATION_REQUIRED = tostring(IsRequired)
end

-------------

function HttpCom:GetAuthenticationType()
	return self._Persist.AUTHENTICATION_TYPE
end

function HttpCom:SetAuthenticationType(NewType)
	self._Persist.AUTHENTICATION_TYPE = NewType

end

function HttpCom:AuthIsBasic()
	return (self:GetAuthenticationType() == "BASIC")
end

function HttpCom:AuthIsDigest()
	return (self:GetAuthenticationType() == "DIGEST")
end

-------------

function HttpCom:GetUserName()
	return self._Persist.USERNAME
end

function HttpCom:SetUserName(NewName)
	LogTrace("HttpCom:SetUserName: %s", tostring(NewName))

	if (NewName ~= self._Persist.USERNAME) then
		self._Persist.USERNAME = NewName
		self:SetNameAndPassword()

	end
end

-------------

function HttpCom:GetPassword()
	return Encryption:AsciiDecryptIt(self._Persist.PASSWORD)
end

function HttpCom:SetPassword(NewPassword)
	LogTrace("HttpCom:SetPassword")
	LogDev("Set password to: %s", tostring(NewPassword))
	
	if(self._IsInitialized) then
		if (NewPassword ~= self:GetPassword()) then
			self._Persist.PASSWORD = Encryption:AsciiEncryptIt(NewPassword)
			self:SetNameAndPassword()
		end
	end
end

function HttpCom:SetNameAndPassword()
	self._NameAndPassword = string.format("%s:%s", self:GetUserName(), self:GetPassword())
end

-------------
--[[
	Build HTTP request HTTP using global address and HTTP port variables and provided query string.
--]]
function HttpCom:BuildHTTP(query_string)
	return string.format("http://%s:%s/%s", self:GetAddress(), self:GetHttpPort(), query_string)
end


function HttpCom:AuthHeader(Inheader)
	local http_headers = Inheader or {}

	if self:IsAuthenticationRequired() then
		if (self:AuthIsBasic()) then		-- BASIC
			http_headers["Authorization"] = string.format("Basic %s", C4:Base64Encode(self._NameAndPassword))
			
		end
	end

	return http_headers
end


function HttpCom:AuthHTTP(InHttp)
	local RetHttp = InHttp
	
	if (self:IsAuthenticationRequired() and self:AuthIsDigest()) then
		RetHttp = string.format("%s%s@%s", string.sub(InHttp, 1, 7), self._NameAndPassword, string.sub(InHttp, 8))
	end
	
	return RetHttp
end

function ReceivedAsync (ticketId, strData, responseCode, tHeaders, strError)
	for k, info in pairs (GlobalTicketHandlers) do
		if (info.TICKET == ticketId) then
			DataLakeMetrics:MetricsCounter ('RX')
			table.remove (GlobalTicketHandlers, k)
			TheHttpCom:ProcessResponse (strData, responseCode, tHeaders, strError, info)
		end
	end
end

function HttpCom:ProcessResponse (strData, responseCode, tHeaders, strError, info)

	local eTagHit
	local eTagURL

	if (ETag) then
		local tag
		for k, v in pairs (tHeaders) do
			if (string.upper (k) == 'ETAG') then
				tag = v
			end
		end

		local url = info.URL

		for k, v in pairs (ETag) do
			if (v.url == url) then
				eTagURL = k
			end
		end

		if (responseCode == 200 and strError == nil) then
			if (strData == nil) then
				strData = ''
			end

			if (eTagURL) then
				table.remove (ETag, eTagURL)
			end
			if (tag and info.METHOD ~= 'DELETE') then
				table.insert (ETag, 1, {url = url, strData = strData, tHeaders = tHeaders, tag = tag})
			end

		elseif (tag and responseCode == 304 and strError == nil) then
			if (eTagURL) then
				eTagHit = true
				strData = ETag [eTagURL].strData
				tHeaders = ETag [eTagURL].tHeaders
				table.remove (ETag, eTagURL)
				table.insert (ETag, 1, {url = url, strData = strData, tHeaders = tHeaders, tag = tag})
				responseCode = 200
			end
		end

		while (#ETag > MAX_CACHE) do
			table.remove (ETag, #ETag)
		end
	end

	local data, isJSON, len

	for k, v in pairs (tHeaders) do
		if (string.upper (k) == 'CONTENT-TYPE') then
			if (string.find (v, 'application/json')) then
				isJSON = true
			end
		end
		if (string.upper (k) == 'CONTENT-LENGTH') then
			len = tonumber (v) or 0
		end
	end

	if (isJSON and strError == nil) then
		data = C4:JsonDecode (strData)
		if (data == nil and len ~= 0) then
			print ('Content-Type indicated JSON but content is not valid JSON')

			DataLakeMetrics:MetricsCounter ('Error_RX_JSON')

			data = {strData}
		end
	else
		data = strData
	end


	if (strError) then
		DataLakeMetrics:SetString ('Error_RX', strError)
	end

	if (info.METHOD) then
		DataLakeMetrics:MetricsCounter ('RX_' .. info.METHOD)
	end

	if (info.CALLBACK and type (info.CALLBACK) == 'function') then
		success, ret = pcall (info.CALLBACK, strError, responseCode, tHeaders, data, info.CONTEXT, info.URL)
	end

	if (success == true) then
		return (ret)
	elseif (success == false) then
		DataLakeMetrics:MetricsCounter('Error_Callback')
		print ('URL response callback error: ', ret, info.URL)
	end
end

function HttpCom:UrlDo (method, url, data, headers, callback, context, options)
	local info = {}
	if (type (callback) == 'function') then
		info.CALLBACK = callback
	end

	if (context == nil) then
		context = {}
	end

	method = string.upper (method)

	info.CONTEXT = context
	info.URL = url
	info.METHOD = method

	headers = CopyTable(headers) or {}

	data = data or ''

	if (headers ['User-Agent'] == nil) then
		headers ['User-Agent'] = USER_AGENT
	end

	if (type (data) == 'table') then
		data = C4:JsonEncode(data)
		headers ['Content-Type'] = 'application/json'
	end

	for _, etag in pairs (ETag or {}) do
		if (etag.url == url) then
			headers ['If-None-Match'] = etag.tag
		end
	end

	if (USE_NEW_URL) then
		local t = C4:url ()

		local startTime
		if (C4.GetTime) then
			startTime = C4:GetTime ()
		else
			startTime = os.time () * 1000
		end

		options = CopyTable (options) or {}

		if (options ['cookies_enable'] == nil) then
			options ['cookies_enable'] = true
		end

		if (options ['fail_on_error'] == nil) then
			options ['fail_on_error'] = false
		end

		t:SetOptions(options)

		local _onDone = function (transfer, responses, errCode, errMsg)
			DataLakeMetrics:MetricsCounter ('RX')

			local endTime
			if (C4.GetTime) then
				endTime = C4:GetTime ()
			else
				endTime = os.time () * 1000
			end
			local interval = endTime - startTime
			DataLakeMetrics:SetTimer ('TXtoRX', interval)

			if (errCode == -1 and errMsg == nil) then
				errMsg = 'Transfer cancelled'
			end

			local strError = errMsg

			local strData, responseCode, tHeaders = '', 0, {}

			if (errCode == 0) then
				strData = responses [#responses].body
				responseCode = responses [#responses].code
				tHeaders = responses [#responses].headers
			end

			self:ProcessResponse (strData, responseCode, tHeaders, strError, info)

			local processTime
			if (C4.GetTime) then
				processTime = C4:GetTime ()
			else
				processTime = os.time () * 1000
			end
			local interval = processTime - startTime
			DataLakeMetrics:SetTimer('TXtoDone', interval)
		end

		t:OnDone (_onDone)

		DataLakeMetrics:MetricsCounter ('TX')

		if (method == 'GET') then
			t:Get (url, headers)
		elseif (method == 'POST') then
			t:Post (url, data, headers)
		elseif (method == 'PUT') then
			t:Put (url, data, headers)
		elseif (method == 'DELETE') then
			t:Delete (url, headers)
		else
			t:Custom (url, method, data, headers)
		end

		return t
	else
		local flags = CopyTable (options)

		if (flags == nil) then
			flags = {
				--response_headers_merge_redirects = false,
				cookies_enable = true
			}
		end

		DataLakeMetrics:MetricsCounter ('TX')

		if (method == 'GET') then
			info.TICKET = C4:urlGet (url)
		elseif (method == 'POST') then
			info.TICKET = C4:urlPost (url, data, headers, false, ReceivedAsync, flags)
		elseif (method == 'PUT') then
			info.TICKET = C4:urlPut (url, data, headers, false, ReceivedAsync, flags)
		elseif (method == 'DELETE') then
			info.TICKET = C4:urlDelete (url, headers, false, ReceivedAsync, flags)
		else
			info.TICKET = C4:urlCustom (url, method, data, headers, false, ReceivedAsync, flags)
		end

		if (info.TICKET and info.TICKET ~= 0) then
			table.insert (GlobalTicketHandlers, info)

		else
			DataLakeMetrics:MetricsCounter ('Error_TX')

			LogTrace ('C4.Curl error: ' .. info.METHOD .. ' ' .. url)
			if (callback) then
				pcall (callback, 'No ticket', nil, nil, '', context, url)
			end
		end

		return info
	end
end


--from Will's lib.lua
function CopyTable (t, shallowCopy)
	if (type (t) ~= 'table') then
		return
	end

	local seenTables = {}

	local r = {}
	for k, v in pairs (t) do
		if (type (v) == 'number' or type (v) == 'string' or type (v) == 'boolean') then
			r [k] = v
		elseif (type (v) == 'table') then
			if (shallowCopy ~= true) then
				if (seenTables [v]) then
					r [k] = seenTables [v]
				else
					r [k] = CopyTable (v)
					seenTables [v] = r [k]
				end
			end
		end
	end
	return (r)
end

--from Will's lib.lua
function Select (data, ...)
	if (type (data) ~= 'table') then
		return nil
	end

	local tablePack = function (...)
		return {
			n = select ('#', ...), ...
		}
	end

	local args = tablePack (...)

	local ret = data

	for i = 1, args.n do
		local index = args [i]
		if (index == nil or ret [index] == nil) then
			return nil
		end
		if (ret [index] ~= nil) then
			ret = ret [index]
		end
	end
	return ret
end

do	--Globals

	ETag = ETag or {}
	MAX_CACHE = 100
	GlobalTicketHandlers = GlobalTicketHandlers or {}
	USER_AGENT = 'Control4/' .. C4:GetVersionInfo ().version .. '/' .. C4:GetDriverConfigInfo ('model') .. '/' .. C4:GetDriverConfigInfo ('version')
	
	--use version check here instead of C4.url exists test. 2.10 version had bugs, so only want to use on 3.0 OS and later
	USE_NEW_URL = VersionCheck ('3.0.0')
	
end