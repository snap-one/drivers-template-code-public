---
---	File is: c4_dev_log.lua
---
--- Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
---

require "common.c4_driver_declarations"
require "lib.c4_object"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_dev_log = "2020.06.05"
end

gC4DevLogger = nil

---@class c4_dev_log: c4_object
c4_dev_log = inheritsFrom(nil)

function c4_dev_log:construct()
	self:ClearAll()
end

function c4_dev_log:destruct()

end

function c4_dev_log:LogEntry(LogLevel, LogText, ...)

	if (type(LogText) == "string") then
		LogText = string.format(LogText, ...)
	end

	table.insert(self._DevLogTable, { Level = LogLevel, TimeStamp = tostring(os.time()), Msg = LogText })
	self._LogEntryCount = self._LogEntryCount + 1
end

function c4_dev_log:ClearAll()
	self._DevLogTable = {}
	self._LogEntryCount = 0
end

function c4_dev_log:PrintLogEntries(Level)
	if(Level == nil) then
		Level = 6
	end

	for k, v in pairs(self._DevLogTable) do
		if(v.Level <= Level) then
			print(string.format("%02d -> %s -> %s", k, v.TimeStamp, tostring(v.Msg)))
		end
	end
end



--==========================================================

function EnableDevLog()
	gC4DevLogger = c4_dev_log:new()
end

function DevLogError(LogStr, ...)
	gC4DevLogger:LogEntry(1, LogStr, ...)
end

function DevLogWarn(LogStr, ...)
	gC4DevLogger:LogEntry(2, LogStr, ...)
end

function DevLogInfo(LogStr, ...)
	gC4DevLogger:LogEntry(3, LogStr, ...)
end

function DevLogDebug(LogStr, ...)
	gC4DevLogger:LogEntry(4, LogStr, ...)
end

function DevLogTrace(LogStr, ...)
	gC4DevLogger:LogEntry(5, LogStr, ...)
end

function GetDevLogHistory()
	return gC4DevLogger._DevLogTable
end

function GetDevLogEntryCount()
	return gC4DevLogger._LogEntryCount
end

function PrintDevLog(Level)
	gC4DevLogger:PrintLogEntries(Level)
end

function ClearDevLog()
	c4_dev_log:ClearAll()
end

