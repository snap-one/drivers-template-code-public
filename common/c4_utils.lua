---
--- Helper functions
---
--- Copyright 2022 Snap One, LLC. All Rights Reserved.
---

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_utils = "2022.08.09"
end


---Convert an ascii string to a binary coded decimal. Each decimal digit is
---stored in one byte, with the lower four bits encoding the digit in BCD form.
---
---@param InString string Ascii string that is to be converted into bcd
---@return string bcdString The binary coded decimal
function AsciiToBCD(InString)
	local WorkVal = 0
	local RetValStr = ""
	local DoingHighNybble = false
	local WorkStr = ((#InString % 2) == 0) and (InString) or ("0" .. InString)	-- make sure length is an even number

	for CharCount = 1, #WorkStr do
		local NumVal = tonumber(WorkStr:sub(CharCount, CharCount))

		WorkVal = bit.lshift(WorkVal, 4) + NumVal
		if (DoingHighNybble) then
			RetValStr = RetValStr .. string.char(WorkVal)
			WorkVal = 0
		end

		DoingHighNybble = (not DoingHighNybble)
	end

	return RetValStr
end


---Convert an BCD string to an ascii string.
---
---@param InByte string Binary coded decimal that is to be converted into ascii
---@return string asciiString The ascii string
function BCDToAscii(InByte)
	return tostring(bit.rshift(InByte, 4)) .. tostring(bit.band(InByte, 0x0F))
end


---Create an Xml element
---
---@param Tag string The Xml elements name
---@param Value string The Xml elements value
---@return string xmlTag The xml element created for the specified value
function MakeXMLNode(Tag, Value)
	return "<" .. Tag .. ">" .. Value .. "</" .. Tag .. ">"
end


---Create an Xml element with an attribute
---
---@param Tag string The Xml elements name
---@param Value string The Xml elements value
---@param Attribute string The attribute to be added to the Xml element
---@param AttrValue string The value of the attribute to be added
---@return string xmlTag The xml element created for the specified value
function MakeXMLAttrNode(Tag, Value, Attribute, AttrValue)
    return "<" .. Tag .. " " .. Attribute .. "=\"" .. AttrValue .. "\">" .. Value .. "</" .. Tag .. ">"
end


---Pull the value from an XML string.  Won't work if there are nested values.
---This could definitely be made more robust.
---
---@param NodeStr string A string of the XML node
---@return string nodeValue A string of the value that was in the node.
function ExtractXMLValue(NodeStr)
	local SkipTagStart = string.find(NodeStr, ">")		-- Ugly. I know.
	local SkipTagEnd = string.find(NodeStr, "<", SkipTagStart)
	return (SkipTagEnd ~= nil) and string.sub(NodeStr, SkipTagStart + 1, SkipTagEnd - 1) or ""
end


---Convert a unicode string
---
---@param UnicodeString string The unicode string to be converted to ascii
---@return string asciiString The ascii representation of the unicode string
function StringFromUnicode(UnicodeString)
	local RetVal = ""

	-- extract every other byte from the unicode string
	for Index = 2, #UnicodeString, 2 do
		RetVal = RetVal .. string.sub(UnicodeString, Index, Index)
	end

	return RetVal
end


---Splits a string into multiple strings at an optionally specified delimiter
---If the delimiter is not specified, it will defalt to the space character
---
---@param s string The string that is to be split into several strings
---@param d string The delimiter to split the string on
---@return string[] stringTable A table of strings containing all the seperate values in the given string
function StringSplit(s, d)
	local delim = (d ~= nil) and d or " "
	local result = {}

	if s == nil or s == "" then
		return result
	end

	for match in (s..delim):gmatch("(.-)"..delim) do
		table.insert(result, match)
	end

	return result
end

--[[=============================================================================
    toboolean(s)

    Description


    Parameters



===============================================================================]]

---Returns a boolean representation of the given value
---
---Returns the value true or false based on the given value:
---
---- If the value is of type string the return true if the first letter is "T" or "t" or if the string is "1"
---- If the value is of type number the return true if the value is non-zero
---- If the value is already a boolean, just return it.
---
---@param val string|number|boolean val input value, may be of different types
---@return boolean
function toboolean(val)
	local rval = false;

	if type(val) == "string" and (string.lower(val) == 'true' or val == "1" or string.lower(val) == 'yes') then
		rval = true
	elseif type(val) == "number" and val ~= 0 then
		rval =  true
	elseif type(val) == "boolean" then
		rval = val
	end

	return rval
end


---Force a number or a string representation of a number to be an integer
---
---@param val string|number A number or a string representation of a number
---@return integer int The the rounded off integer value.
function tointeger(val)
	local nval = tonumber(val)
	return (nval >= 0) and math.floor(nval + 0.5) or math.ceil(nval - 0.5)
end


---Call a function with the given arguments if it exists or report the error
---
---@param to function|string The string to evaluate the boolean representation from
---@param err string The error to report if the function does not exist
---@param ... any Additional optional parameters for the function specified by the "to" parameter
---@return unknown|nil
function Go(to, err, ...)
	if (type(to) == "function") then
		return to(...)
	else
		LogTrace(err)
	end
end


---Identifies if the string given is nil or empty
---
---@param str string The string to evaluate for the empty condition
---@return boolean isEmpty True if the given value is empty, false otherwise
function IsEmpty(str)
	return str == nil or str == ""
end


---Reverse table entries (key=value, value=key)
---
---@param a table The table to reverse
---@return table reversedTable new reversed table
function ReverseTable(a)
	local b = {}
	for k,v in pairs(a) do b[v] = k end
	return b
end

---Deep clone a table.
---
---@param srcTab table
---@return table clonedTable
function CloneTable(srcTab)
	local dstTab = {}

    for k, v in pairs(srcTab) do
		if(type(v) == "table") then
			dstTab[k] = CloneTable(v)
		else
			dstTab[k] = v
		end
	end

	return dstTab
end


---@param str string
---@param base integer
---@return integer
function tonumber_loc(str, base)
    local s
    local num
    if type(str) == "string" then
        s = str:gsub(",", ".") -- Assume US Locale decimal separator
        num = tonumber(s, base)
        if (num == nil) then
                s = str:gsub("%.", ",") -- Non-US Locale decimal separator
                num = tonumber(s, base)
        end
    else
        num = tonumber(str, base)
    end
    return num
end


---Converts a string of Hex characters to a readable string of ASCII characters
---
---@param InString string The string to be converted
---@return string hexBytes A string showing the hex bytes of the InString
function HexToString(InString)
	local RetVal = ""

	if(InString ~= nil) then
		for Index = 1, #InString do
			RetVal = RetVal .. string.format("%02X ", InString:byte(Index))
		end
	end

	return RetVal
end


---Converts a string of ASCII characters to as string with the actual Hex bytes in them.
---Basically an array of hex bytes.
---
---@param InString string The string to be converted
---@return string hexString A string of hex bytes (really an array of hex values)
function StringToHex(InString)
	local RetVal = ""

	if(InString ~= nil) then
		for HexByteString in string.gfind(InString, "%x%x") do
			RetVal = RetVal .. string.char(tonumber(HexByteString, 16))
		end
	else
		LogWarn("StringToHex: InString was nil")
	end

	return RetVal
end


---Convert a value from scale to another
---
---@param inLevel number level value in terms of the input scale
---@param minInLevel number lower reference value on the input scale
---@param maxInLevel number upper reference value on the input scale
---@param minOutLevel number lower reference value on the output scale
---@param maxOutLevel number upper reference value on the output scale
---@return integer levelValue The level value in terms of the output scale
function ConvertScaleLevel(inLevel, minInLevel, maxInLevel, minOutLevel, maxOutLevel)
    local inScaled = (inLevel - minInLevel) / (maxInLevel - minInLevel)
    local outScaled = (inScaled * (maxOutLevel - minOutLevel)) + minOutLevel
	local outLevel = (outScaled < 0.0) and math.ceil(outScaled - 0.5) or math.floor(outScaled + 0.5)

    --LogDebug("ConvertScaleLevel(level in = %d  level out = %d)", inLevel, outLevel)

    return outLevel
end


---Get the master temperature scale defined for the project
---
---@return "F"|"C"|"Undefined" tempScale "F" for Fahrenheit, "C" for Celsius, or "Undefined" if somethinge went wrong and we can't get the value
function GetProjectTemperatureScale()
	local ProjectData = C4:GetProjectItems('LOCATIONS', 'LIMIT_DEVICE_DATA', 'NO_ROOT_TAGS')
	local ReadScale = string.match (ProjectData, '<scale>(.).-</scale>')
	return ReadScale or "Undefined"
end

--===============================================================================
--[[=============================================================================
    CheckOSVersion(minimalOSVersion)

    Description
    Checks the current OS version against the minimalOSVersion

    Parameters
    minimalOSVersion(string) - OS version in the following string format
    MAJOR[.]MINOR[.]PATCH[.]BUILD
    where [.] represents any non-number character.

    minimalOSVersion(table) - OS version table in the following format
    {MAJOR, MINOR, PATCH, BUILD}

    Subsequent version numbers can be omitted if you want to check against
    all of them e.g. "3.2" == "3.2.*".

    Returns
    True if the minimalOSVersion is lower than the current OS version.
===============================================================================]]
-- function CheckOSVersion(minimalOSVersion)
	-- if not minimalOSVersion then
		-- LogInfo("CheckOSVersion: No arguments passed. Specify "..
		-- "'MAJOR.MINOR.PATCH.BUILD' or {MAJOR, MINOR, PATCH, BUILD}")
		-- return false
	-- end
	-- function parseVersion(version)
		-- local result = {}
		-- for w in version:gmatch("(%d+)") do
			-- result[#result + 1] = w
		-- end
		-- return {result[1], result[2], result[3], result[4]}
	-- end
	-- if type(minimalOSVersion) == "string" then
		-- minimalOSVersion = parseVersion(minimalOSVersion)
	-- end
	-- if type(minimalOSVersion) ~= "table" or #minimalOSVersion == 0 then
		-- LogDebug("CheckOSVersion: Invalid format minimalOSVersion")
		-- return false
	-- end
	-- local currentOSVersion = parseVersion(C4:GetVersionInfo().version)
	-- for index, version in ipairs(minimalOSVersion) do
		-- if tonumber(version) > tonumber(currentOSVersion[index]) then
			-- LogFatal(string.format(
				-- "CheckOSVersion: The current driver is not supported on OS versions below %s%s",
				-- table.concat(minimalOSVersion, "."),
				-- #minimalOSVersion < 3 and ".*" or ""
			-- ))
			-- LogFatal(string.format(
				-- "CheckOSVersion: The current OS version is %s",
				-- table.concat(currentOSVersion, ".")
			-- ))
			-- return false
		-- elseif tonumber(version) < tonumber(currentOSVersion[index]) then
			-- return true
		-- end
	-- end
	-- return true
-- end

--===============================================================================
--from Will's lib.lua

---@param requires_version string
---@return boolean
function VersionCheck (requires_version)
	local curver = {}
	curver [1], curver [2], curver [3], curver [4] = string.match (C4:GetVersionInfo ().version, '^(%d*)%.?(%d*)%.?(%d*)%.?(%d*)')
	local reqver = {}
	reqver [1], reqver [2], reqver [3], reqver [4] = string.match (requires_version, '^(%d*)%.?(%d*)%.?(%d*)%.?(%d*)')

	for i = 1, 4 do
		local cur = tonumber (curver [i]) or 0
		local req = tonumber (reqver [i]) or 0
		if (cur > req) then
			return true
		end
		if (cur < req) then
			return false
		end
	end
	return true
end


---@param severity SeverityType
---@param eventType EventType
---@param category CategoryType
---@param subcategory string
---@param description string
function RecordHistory(severity, eventType, category, subcategory, description)
	C4:RecordHistory(severity, eventType, category, subcategory, description)
end


---@param eventType EventType
---@param category CategoryType
---@param subcategory string
---@param description string
function RecordCriticalHistory(eventType, category, subcategory, description)
	RecordHistory("Critical", eventType, category, subcategory, description)
end


---@param eventType EventType
---@param category CategoryType
---@param subcategory string
---@param description string
function RecordWarningHistory(eventType, category, subcategory, description)
	RecordHistory("Warning", eventType, category, subcategory, description)
end


---@param eventType EventType
---@param category CategoryType
---@param subcategory string
---@param description string
function RecordInfoHistory(eventType, category, subcategory, description)
	RecordHistory("Info", eventType, category, subcategory, description)
end


--===============================================================================


---@param id integer
---@return string|nil
function GetC4ZPath(id)
    local fn, ftype = (C4:GetProjectItems("LIMIT_DEVICE_DATA")
        :match('<id>'..id..'</id>.-</config_data_file>') or "")
        :match('<config_data_file>(.-)%.(c4.)</config_data_file>')

    if ftype == 'c4z' then
        return '/mnt/internal/c4z/' .. fn ..'/'
    else
        return nil
    end
end


--===============================================================================


---@param f function
---@param ... any
---@return true|false
---@return unknown
function pCallFunction(f,...)
	local status, retval = pcall(f,...)
	if not status then
		local msg = "pCallFunction failed, error: " .. retval
		C4:ErrorLog(msg)
		LogTrace(msg)
	end

    return status, retval
end


--===============================================================================
