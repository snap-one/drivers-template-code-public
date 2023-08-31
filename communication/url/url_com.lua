--[[=============================================================================
	File is: url_com.lua
    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"
require "modules.encryption"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.url_com = "2022.11.07"
end

DEFAULT_URL_BINDING_ID = 6001
UrlCom = inheritsFrom(nil)

URL_COM_PERSIST_RECORD_NAME = "UrlComPersist"

function UrlCom:construct()
	self._NameAndPassword = '-:-'
	self._IsInitialized = false

end

function UrlCom:InitialSetup(UserName, Password, AuthRequired, AuthType, Address, HttpPort, RtspPort)

	PersistData[URL_COM_PERSIST_RECORD_NAME] = C4:PersistGetValue(URL_COM_PERSIST_RECORD_NAME)

	if(PersistData[URL_COM_PERSIST_RECORD_NAME] == nil) then
		PersistData[URL_COM_PERSIST_RECORD_NAME] = {
		
			ADDRESS					= Address,
			HTTP_PORT               = HttpPort,
			RTSP_PORT               = RtspPort,
			AUTHENTICATION_REQUIRED = tostring(AuthRequired),
			AUTHENTICATION_TYPE     = AuthType,
			USERNAME                = UserName,
			PASSWORD                = Encryption:AsciiEncryptIt(Password),
			ENCRYPTED_PASSWORD		= true,
		
			URL_BINDING_ID			= DEFAULT_URL_BINDING_ID,
		}
		
		self:PersistSave()

	--  DCC  04/28/2022  Do we still need to preserve backward compatibility??
	-- else
		-- -- check if this was persisted before we were encrypting the passwords.
		-- if(self._Persist.ENCRYPTED_PASSWORD == nil) then
			-- self._Persist.PASSWORD = Encryption:AsciiEncryptIt(self._Persist.PASSWORD)
			-- self._Persist.ENCRYPTED_PASSWORD		= true
		-- end
	end

	self._Persist = PersistData[URL_COM_PERSIST_RECORD_NAME]

	self._IsInitialized = true
	
	self:SetNameAndPassword()
end

----------------------

function UrlCom:PersistSave()
	C4:PersistSetValue(URL_COM_PERSIST_RECORD_NAME, PersistData[URL_COM_PERSIST_RECORD_NAME])
end


-------------

function UrlCom:GetUrlBindingID()
	return self._Persist.URL_BINDING_ID
end


function UrlCom:SetUrlBindingID(NewBindingId)
	self._Persist.URL_BINDING_ID = NewBindingId
	self:PersistSave()
end

-------------

function UrlCom:GetAddress()
	return self._Persist.ADDRESS
end

function UrlCom:SetAddress(NewAddress)
	LogTrace("UrlCom:SetAddress: %s", NewAddress)

	if (NewAddress ~= self._Persist.ADDRESS) then
		self._Persist.ADDRESS = NewAddress
		self:PersistSave()
	end
end

-------------

function UrlCom:GetHttpPort()
	return self._Persist.HTTP_PORT
end

function UrlCom:SetHttpPort(NewPort)
	LogTrace("UrlCom:SetHttpPort: %s", tostring(NewPort))

	if (NewPort ~= self._Persist.HTTP_PORT) then
		self._Persist.HTTP_PORT = NewPort
		self:PersistSave()
	end
end

-------------

function UrlCom:GetRtspPort()
	return self._Persist.RTSP_PORT
end

function UrlCom:SetRtspPort(NewPort)
	LogTrace("UrlCom:SetRtspPort: %s", tostring(NewPort))

	if (NewPort ~= self._Persist.RTSP_PORT) then
		self._Persist.RTSP_PORT = NewPort
		self:PersistSave()
	end
end

-------------

function UrlCom:IsAuthenticationRequired()
	return toboolean(self._Persist.AUTHENTICATION_REQUIRED)
end

function UrlCom:SetAuthenticationRequired(IsRequired)
	self._Persist.AUTHENTICATION_REQUIRED = tostring(IsRequired)
	self:PersistSave()
end

-------------

function UrlCom:GetAuthenticationType()
	return self._Persist.AUTHENTICATION_TYPE
end

function UrlCom:SetAuthenticationType(NewType)
	self._Persist.AUTHENTICATION_TYPE = NewType
	self:PersistSave()
end

function UrlCom:AuthIsBasic()
	return (self:GetAuthenticationType() == "BASIC")
end

function UrlCom:AuthIsDigest()
	return (self:GetAuthenticationType() == "DIGEST")
end

-------------

function UrlCom:GetUserName()
	return self._Persist.USERNAME
end

function UrlCom:SetUserName(NewName)
	LogTrace("UrlCom:SetUserName: %s", tostring(NewName))

	if (NewName ~= self._Persist.USERNAME) then
		self._Persist.USERNAME = NewName
		self:PersistSave()
		self:SetNameAndPassword()

	end
end

-------------

function UrlCom:GetPassword()
	return Encryption:AsciiDecryptIt(self._Persist.PASSWORD)
end

function UrlCom:SetPassword(NewPassword)
	LogTrace("UrlCom:SetPassword")
	LogDev("Set password to: %s", tostring(NewPassword))
	
	if(self._IsInitialized) then
		if (NewPassword ~= self:GetPassword()) then
			self._Persist.PASSWORD = Encryption:AsciiEncryptIt(NewPassword)
			self:PersistSave()
			self:SetNameAndPassword()
		end
	end
end

function UrlCom:SetNameAndPassword()
	self._NameAndPassword = string.format("%s:%s", self:GetUserName(), self:GetPassword())
end

-------------
--[[
	Build HTTP request URL using global address and HTTP port variables and provided query string.
--]]
function UrlCom:BuildHTTP(query_string)
	return string.format("http://%s:%s/%s", self:GetAddress(), self:GetHttpPort(), query_string)
end


function UrlCom:AuthHeader(Inheader)
	local http_headers = Inheader or {}

	if self:IsAuthenticationRequired() then
		if (self:AuthIsBasic()) then		-- BASIC
			http_headers["Authorization"] = string.format("Basic %s", C4:Base64Encode(self._NameAndPassword))
			
		end
	end

	return http_headers
end


function UrlCom:AuthURL(InUrl)
	local RetUrl = InUrl
	
	if (self:IsAuthenticationRequired() and self:AuthIsDigest()) then
		RetUrl = string.format("%s%s@%s", string.sub(InUrl, 1, 7), self._NameAndPassword, string.sub(InUrl, 8))
	end
	
	return RetUrl
end




--[[
	Perform URL 'Get'
--]]
function UrlCom:Get(url, CallbackFunction)
	
	local MyCallback = CallbackFunction
	local DataImage = {}
	
	C4:url()
		:OnDone(function(transfer, responses, errCode, errMsg)
					
					if(errCode == 0) then
						LogInfo("GET Transfer succeeded")
						
					elseif(errCode == 1) then
						LogError("GET Transfer was aborted")
						
					else
						LogError("GET Transfer failed with error %d: %s  (%d responses completed)", tonumber(errCode), errMsg, #responses)
					end

					local ResponseCode = 0
					local Body = ""
					if(#responses > 0) then
						local LastResponse = responses[#responses]
						
						ResponseCode = LastResponse.code
--						Body = LastResponse.body
						Body = table.concat(DataImage)
				
						-- local ResponseHeaders = LastResponse.headers
						-- LogDebug(ResponseHeaders)
					end
					
					if (MyCallback ~= nil and type(MyCallback == "function")) then -- Need to parse response
						MyCallback(ResponseCode, Body)
					else
						LogInfo("GET C4:url():OnDone  No Callback defined")
					end

				end
			  )

		:SetOptions(	{
							["fail_on_error"] = false,
							["timeout"] = 120,
							["connect_timeout"] = 20
					    }
				   )
		
		
		:OnBody(function(transfer, response)
					-- LogTrace("C4:url():OnBody")
				end
			   )
		
		:OnBodyChunk(function(transfer, response, chunk)
						--LogTrace("Get:OnBodyChunk")
						table.insert(DataImage, chunk)
					 end
					)
		
		:Get(self:AuthURL(url), self:AuthHeader())
end



--[[
	Perform URL 'Put'
--]]
function UrlCom:Put(url, data, header, CallbackFunction)
	
	local MyCallback = CallbackFunction

	C4:url()
		:OnDone(function(transfer, responses, errCode, errMsg)
					
					if(errCode == 0) then
						LogInfo("PUT Transfer succeeded")

					elseif(errCode == 1) then
						LogError("PUT Transfer was aborted")

					else
						LogError("PUT Transfer failed with error %d: %s  (%d responses completed)", tonumber(errCode), errMsg, #responses)
					end

					local ResponseCode = 0
					if(#responses > 0) then
						local LastResponse = responses[#responses]
						
						ResponseCode = LastResponse.code
						local ResponseHeaders = LastResponse.headers

						LogDev(ResponseHeaders)
					end
						
					if (MyCallback ~= nil and type(MyCallback == "function")) then -- Need to parse response
						MyCallback(ResponseCode)
					else
						LogInfo("PUT C4:url():OnDone  No Callback defined")
					end
						
				end
			  )

		:SetOptions(	{
							["fail_on_error"] = false,
							["timeout"] = 120,
							["connect_timeout"] = 20
					    }
				   )
					   
		:Put(self:AuthURL(BuildHTTPString(url)), data, self:AuthHeader(header))
end



--[[
	Perform URL 'Post'
--]]
function UrlCom:Post(url, data, header, CallbackFunction)
	self:PostRaw(self:AuthURL(BuildHTTPString(url)), data, self:AuthHeader(header), CallbackFunction)
end


function UrlCom:PostRaw(url, data, header, CallbackFunction)
	
	local MyCallback = CallbackFunction

	C4:url()
		:OnDone(function(transfer, responses, errCode, errMsg)
					LogTrace("C4:url():Post():OnDone()")
					LogDev(transfer)
					LogDev(responses)
					
					if(errCode == 0) then
						LogInfo("POST Transfer succeeded")

					elseif(errCode == 1) then
						LogError("POST Transfer was aborted")

					else
						LogError("POST Transfer failed with error %d: %s  (%d responses completed)", tonumber(errCode), errMsg, #responses)
					end

					local ResponseCode = 0
					local ResponseBody = {}
					if(#responses > 0) then
						local LastResponse = responses[#responses]
						
						ResponseCode = LastResponse.code
						ResponseBody = LastResponse.body
						local ResponseHeaders = LastResponse.headers

						LogDev(ResponseHeaders)
					end
						
					if (MyCallback ~= nil and type(MyCallback == "function")) then -- Need to parse response
						MyCallback(ResponseCode, ResponseBody)
					else
						LogInfo("POST C4:url():OnDone  No Callback defined")
					end
						
				end
			  )

		:SetOptions(	{
							["fail_on_error"] = false,
							["timeout"] = 120,
							["connect_timeout"] = 20
					    }
				   )
					   
		:Post(url, data, header)
end


