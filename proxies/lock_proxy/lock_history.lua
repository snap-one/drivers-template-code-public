--[[=============================================================================
    File is: lock_history.lua

    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"


gCurHistoryID = 1
function NextHistoryID()
	local RetVal = gCurHistoryID
	gCurHistoryID = gCurHistoryID + 1
	return RetVal
end


LockHistoryEvents = {}


function AddToLockHistoryEventTable(TargEvent)
	local TableMaxSize = TheLock:GetHistoryLogCount()

	local TopSlot = #LockHistoryEvents + 1
	if(TopSlot >= TableMaxSize) then
		TopSlot = TableMaxSize
	end
	
	for CurSlot = TopSlot, 2, -1 do
		-- shift everything up one notch
		LockHistoryEvents[CurSlot] = LockHistoryEvents[CurSlot - 1]	
	end

	-- put the most recently received event in slot one.
	LockHistoryEvents[1] = TargEvent
end



LockHistoryEvent = inheritsFrom(nil)


function LockHistoryEvent:construct(EventName, EventSource, EventYear, EventMonth, EventDay, EventHour, EventMinute)
	self._HistoryID = NextHistoryID()
	
	self._EventName = EventName
	self._EventSource = EventSource
	
	self._DateString = string.format("%02d/%02d/%04d", EventMonth, EventDay, EventYear)

	local UseHr = EventHour
	local Am_Pm = "AM"
	
	if(UseHr >= 12) then
		-- afternoon
		Am_Pm = "PM"
		if(UseHr > 12) then
			UseHr = UseHr - 12
		end
	else
		if(UseHr == 0) then
			UseHr = 12
		end
	end

	self._TimeString = string.format("%02d:%02d %s", UseHr, EventMinute, Am_Pm)
	AddToLockHistoryEventTable(self)
end


function LockHistoryEvent:destruct()
	LockHistoryEvents[self._HistoryID] = nil
end


function LockHistoryEvent:GetHistoryXML(ID)

	return MakeXMLNode	("history_item",	MakeXMLNode("history_id", tostring(ID)) ..
											MakeXMLNode("date", self._DateString) ..
											MakeXMLNode("time", self._TimeString) ..
											MakeXMLNode("message", self._EventName) ..
											MakeXMLNode("source", self._EventSource)
						)

end


function LockHistoryEvent:GetHistoryPrint(ID)
	return string.format("\n\t%d: %s on %s at %s\n", ID, self._EventName, self._DateString, self._TimeString)
end

--------------------------------------------------------------------------------------

function Lock_HistoryEventNow(Event, Source)
	LogTrace("Lock_HistoryEventNow: %s %s", tostring(Event), tostring(Source))

	if(HasInternalHistory()) then
		local TimeTable = os.date("*t", os.time())
		Source = Source or ""
		Lock_HistoryEvent(Event, Source, TimeTable.year, TimeTable.month, TimeTable.day, TimeTable.hour, TimeTable.min)
	end
end


function Lock_HistoryEvent(Event, Source, Year, Month, Day, Hour, Minute)
	if((Year == nil) or (Month == nil) or (Day == nil) or (Hour == nil) or (Minute == nil)) then
		Lock_HistoryEventNow(Event, Source)
	else
		LogTrace("Lock_HistoryEvent %s  %s  %04d.%02d.%02d %02d:%02d", Event, Source, Year, Month, Day, Hour, Minute)
		LockHistoryEvent:new(Event, Source, Year, Month, Day, Hour, Minute)
	end
end



function Lock_HistoryClear()
	LockHistoryEvents = {}
end


function TrimLockHistoryEventsTable()
	-- If we've made the size of the table smaller. Get rid of older entries
	local TableSizeMax = TheLock:GetHistoryLogCount()
	while(#LockHistoryEvents > TableSizeMax) do
		LockHistoryEvents[#LockHistoryEvents] = nil
	end
end


function GetHistoryXML()
	local HistoryXMLStr = ""
	
	TrimLockHistoryEventsTable()
	
	for EntryID, CurHistory in ipairs(LockHistoryEvents) do
		HistoryXMLStr = HistoryXMLStr .. CurHistory:GetHistoryXML(EntryID)
	end
	
	return MakeXMLNode("lock_history", HistoryXMLStr)
	
end


function GetHistoryPrint()
	local HistoryStringTbl = {}

	TrimLockHistoryEventsTable()

	table.insert(HistoryStringTbl, "\n\n\n--- Lock History ----\n")
	
	for EntryID, CurHistory in ipairs(LockHistoryEvents) do
		table.insert(HistoryStringTbl, CurHistory:GetHistoryPrint(EntryID))
	end

	return table.concat(HistoryStringTbl)

end

