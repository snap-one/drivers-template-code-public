--[[=============================================================================
	File is: encryption.lua
	Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.encryption = "2021.10.07"		-- was DGC
end

AES_CIPHER_TYPE = "AES-128-ECB"
AES_CIPHER_OPTIONS = {
	["return_encoding"] = "NONE",
	["key_encoding"] = "NONE",
	["iv_encoding"] = "NONE",
	["data_encoding"] = "NONE",
	["padding"] = false,
}

function ON_DRIVER_EARLY_INIT.Encryption(strDit)
	if(DRIVER_ENCRYPTION_KEY ~= nil) then
		Encryption:SetEncryptionKey(DRIVER_ENCRYPTION_KEY)
	end
end


Encryption = {
	_EncryptKey = string.char(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)

}




function Encryption:SetEncryptionKey(KeyStr)
	self._EncryptKey = KeyStr
end


function Encryption:AsciiEncryptIt(PlainText)
	-- prepend two bytes that are the string length so when we unwind it, we know how much data we care about
	local RawEnc = self:EncryptIt(string.char((#PlainText / 256), (#PlainText % 256)) .. PlainText)
	-- convert to ascii hex chars and squeeze the spaces out
	return string.gsub(HexToString(RawEnc), "%s+", "")
end

function Encryption:AsciiDecryptIt(CipherText)
	-- convert the ascii string of hex values to an array of hex bytes and send it off
	local WorkStr = self:DecryptIt(StringToHex(CipherText))

	-- extract the length
	local Length = (string.byte(WorkStr) * 256) + string.byte(WorkStr, 2)

	-- skip the first two bytes that were the length and then return the string starting a byte 3 and
	-- continuing for as many bytes as the length says we should
	return string.sub(WorkStr, 3, 2 + Length)
end


function Encryption:EncryptIt(PlainText)
	local PaddedText = PlainText
	local PaddingLength = 16 - (#PlainText % 16)
	for pcount = 1, PaddingLength, 1 do
		PaddedText = PaddedText .. string.char(math.random(0, 255))
	end

	return C4:Encrypt(AES_CIPHER_TYPE, self._EncryptKey, "", PaddedText, AES_CIPHER_OPTIONS)
end


function Encryption:DecryptIt(CipherText)
	return C4:Decrypt(AES_CIPHER_TYPE, self._EncryptKey, "", CipherText, AES_CIPHER_OPTIONS)
end

-------------------------------------------------------------------

function EncryptionTest()
	local EncStr = Encryption:AsciiEncryptIt("AbCd 123")
	print(string.format("Encrypted String is: %s", EncStr))
	local DecStr = Encryption:AsciiDecryptIt(EncStr)
	print(string.format("Decrypted String is: %s", DecStr))
end


