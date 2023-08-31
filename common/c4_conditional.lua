---
--- Functions for handling conditionals in control4 project programming
---
--- Copyright 2017 Control4 Corporation. All Rights Reserved.
---

require "common.c4_driver_declarations"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_conditional = "2017.04.25"
end

function TestCondition(ConditionalName, tParams)
	LogTrace("TestCondition() : %s", tostring(ConditionalName))
--	LOG:Trace(tParams)

	local retVal = false
	local callSuccess = false
	local trimmedConditionalName = string.gsub(ConditionalName, " ", "")

	if (PROG_CONDITIONAL[ConditionalName] ~= nil and type(PROG_CONDITIONAL[ConditionalName]) == "function") then
		callSuccess, retVal = pcall(PROG_CONDITIONAL[ConditionalName], tParams)

		-- elseif trimmed function exists then execute
	elseif (PROG_CONDITIONAL[trimmedConditionalName] ~= nil and type(PROG_CONDITIONAL[trimmedConditionalName]) == "function") then
		callSuccess, retVal = pcall(PROG_CONDITIONAL[trimmedConditionalName], tParams)

	else
		LogInfo("TestCondition: Unhandled condition = %s", tostring(ConditionalName))
	end

	if (not callSuccess) then
		LogError("LUA_ERROR: %s", tostring(retVal))
	end

	LogTrace("Result = " .. tostring(retVal))
	return retVal
end

