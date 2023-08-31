---
--- Functions for handling and executing commands and actions
---
--- Copyright 2019 Control4 Corporation. All Rights Reserved.
---
require "common.c4_driver_declarations"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_command = "2019.05.31"
end


---Function called by Director when a command is received for this DriverWorks
---driver. This includes commands created in Composer programming.
---
---@param sCommand string Command to be sent
---@param tParams table Lua table of parameters for the sent command
---@return unknown
function ExecuteCommand(sCommand, tParams)
	LogTrace("ExecuteCommand(" .. sCommand .. ")")
	LogDev(tParams)

	-- Remove any spaces (trim the command)
	local trimmedCommand = string.gsub(sCommand, " ", "")
	local status, ret

	-- if function exists then execute (non-stripped)
	if (EX_CMD[sCommand] ~= nil and type(EX_CMD[sCommand]) == "function") then
		status, ret = pcall(EX_CMD[sCommand], tParams)
	-- elseif trimmed function exists then execute
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		status, ret = pcall(EX_CMD[trimmedCommand], tParams)
	else
		LogInfo("ExecuteCommand: Unhandled command = " .. sCommand)
		status = true
	end

	if (not status) then
		LogError("LUA_ERROR: " .. ret)
	end

	return ret -- Return whatever the function returns because it might be xml, a return code, and so on
end


---Function called for any actions executed by the user from the Actions Tab in Composer.
---
---@param tParams table Lua table of parameters for the command option
function EX_CMD.LUA_ACTION(tParams)
	if (tParams ~= nil) then
		for cmd, cmdv in pairs(tParams) do
			if (cmd == "ACTION" and cmdv ~= nil) then
				local status, err = pcall(LUA_ACTION[cmdv], tParams)
				if (not status) then
					LogError("LUA_ERROR: " .. err)
				end
				break
			end
		end
	end
end


---Function called for any actions executed by the user from the Actions Tab in Composer.
---
---@param idBinding integer Binding ID of the proxy that sent a BindMessage to the DriverWorks driver.
---@param sCommand string Command that was sent
---@param tParams table Lua table of received command parameters
function ReceivedFromProxy(idBinding, sCommand, tParams)

	if (sCommand ~= nil) then

		-- initial table variable if nil
		if (tParams == nil) then
			tParams = {}
		end

		LogTrace("ReceivedFromProxy(): " .. sCommand .. " on binding " .. idBinding .. "; Call Function PRX_CMD." .. sCommand .. "()")
--		LogInfo(tParams)

		if ((PRX_CMD[sCommand]) ~= nil) then
			local status, err = pcall(PRX_CMD[sCommand], idBinding, tParams)
			if (not status) then
				LogError("LUA_ERROR: " .. err)
			end
		else
			LogInfo("ReceivedFromProxy: Unhandled command = " .. sCommand)
		end
	end
end

function PRX_CMD.PROTOCOL_COMMAND(idBinding, tParams)
	LogTrace("PRX_CMD.PROTOCOL_COMMAND")
	if(#tParams > 0) then
		LogInfo(tParams)
	end
end


---This function is called when a UI (Navigator) requests data, and
---calls the function requested.
---
---If you want to have an action that happens when the request isn't defined, implement
---a function called 'UIRequestDefault'
---
---@param sRequest string
---@param tParams table
---@return string
function UIRequest(sRequest, tParams)
	local ret = ""

	if (sRequest ~= nil) then
		tParams = tParams or {}   -- initial table variable if nil
		LogTrace("UIRequest(): " .. sRequest .. "; Call Function UI_REQ." .. sRequest .. "()")
		LogDev(tParams)

		if (UI_REQ[sRequest]) ~= nil then
			ret = UI_REQ[sRequest](tParams)
		else
			LogWarn("UIRequest: Unhandled request = " .. sRequest)

			-- Call the default function if it exists
			if (UIRequestDefault ~= nil and type(UIRequestDefault) == "function") then
				ret = UIRequestDefault(sRequest, tParams)
			end
		end
	end

	return ret
end
