--[[==============================================================
	File is: unittest_lock_history.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_device_class'

c4test_LockHistory = {}

function c4test_LockHistory:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()
	TheLock = LockDevice:new(DEFAULT_PROXY_BINDINGID)
	TheLock:InitialSetup()
	TheLock:UpdateCapability(CAP_HAS_INTERNAL_HISTORY, true)
end


function c4test_LockHistory:tearDown()
	TheLock = nil
	LockHistoryEvents = {}
end

-------------------------------------------------------------------------------------------------

function c4test_LockHistory:c4test_Construct()
	LogTrace("c4test_LockHistory:c4test_Construct...")

	local Event1 = LockHistoryEvent:new("Event1Name", "Event1Source", 2020, 3, 4, 5, 6)
	lu.assertEquals(Event1._EventName, "Event1Name")
	lu.assertEquals(Event1._EventSource, "Event1Source")
	lu.assertEquals(Event1._DateString, "03/04/2020")
	lu.assertEquals(Event1._TimeString, "05:06 AM")
	lu.assertEquals(LockHistoryEvents[1], Event1)
	
	local Event2 = LockHistoryEvent:new("Event2Name", "Event2Source", 2021, 8, 23, 18, 19)
	lu.assertEquals(Event2._EventName, "Event2Name")
	lu.assertEquals(Event2._EventSource, "Event2Source")
	lu.assertEquals(Event2._DateString, "08/23/2021")
	lu.assertEquals(Event2._TimeString, "06:19 PM")
	lu.assertEquals(LockHistoryEvents[1], Event2)
	lu.assertEquals(LockHistoryEvents[2], Event1)
	
	local Event3 = LockHistoryEvent:new("Event3Name", "Event3Source", 2022, 11, 5, 0, 3)
	lu.assertEquals(Event3._EventName, "Event3Name")
	lu.assertEquals(Event3._EventSource, "Event3Source")
	lu.assertEquals(Event3._DateString, "11/05/2022")
	lu.assertEquals(Event3._TimeString, "12:03 AM")
	lu.assertEquals(LockHistoryEvents[1], Event3)
	lu.assertEquals(LockHistoryEvents[2], Event2)
	lu.assertEquals(LockHistoryEvents[3], Event1)
	
	local Event4 = LockHistoryEvent:new("Event4Name", "Event4Source", 2023, 1, 31, 12, 38)
	lu.assertEquals(Event4._EventName, "Event4Name")
	lu.assertEquals(Event4._EventSource, "Event4Source")
	lu.assertEquals(Event4._DateString, "01/31/2023")
	lu.assertEquals(Event4._TimeString, "12:38 PM")
	lu.assertEquals(LockHistoryEvents[1], Event4)
	lu.assertEquals(LockHistoryEvents[2], Event3)
	lu.assertEquals(LockHistoryEvents[3], Event2)
	lu.assertEquals(LockHistoryEvents[4], Event1)
	
	local Event5 = LockHistoryEvent:new("Event5Name", "Event5Source", 2024, 12, 23, 0, 0)
	lu.assertEquals(Event5._EventName, "Event5Name")
	lu.assertEquals(Event5._EventSource, "Event5Source")
	lu.assertEquals(Event5._DateString, "12/23/2024")
	lu.assertEquals(Event5._TimeString, "12:00 AM")
	lu.assertEquals(LockHistoryEvents[1], Event5)
	lu.assertEquals(LockHistoryEvents[2], Event4)
	lu.assertEquals(LockHistoryEvents[3], Event3)
	lu.assertEquals(LockHistoryEvents[4], Event2)
	lu.assertEquals(LockHistoryEvents[5], Event1)
	
	local Event6 = LockHistoryEvent:new("Event6Name", "Event6Source", 2025, 6, 6, 12, 0)
	lu.assertEquals(Event6._EventName, "Event6Name")
	lu.assertEquals(Event6._EventSource, "Event6Source")
	lu.assertEquals(Event6._DateString, "06/06/2025")
	lu.assertEquals(Event6._TimeString, "12:00 PM")
	lu.assertEquals(LockHistoryEvents[1], Event6)
	lu.assertEquals(LockHistoryEvents[2], Event5)
	lu.assertEquals(LockHistoryEvents[3], Event4)
	lu.assertEquals(LockHistoryEvents[4], Event3)
	lu.assertEquals(LockHistoryEvents[5], Event2)
	lu.assertEquals(LockHistoryEvents[6], nil)
end

function c4test_LockHistory:c4test_GetHistoryXML()
	LogTrace("c4test_LockHistory:c4test_GetHistoryXML...")
	local CurEvent = LockHistoryEvent:new("TestXMLEventName", "TestXMLEventSource", 2020, 4, 3, 2, 1)
	
	local EventXMLRefStr = 
		"<history_item>" ..
			"<history_id>1</history_id>" ..
			"<date>04/03/2020</date>" ..
			"<time>02:01 AM</time>" ..
			"<message>TestXMLEventName</message>" ..
			"<source>TestXMLEventSource</source>" ..
		"</history_item>"

	lu.assertEquals(CurEvent:GetHistoryXML(1), EventXMLRefStr)
end

function c4test_LockHistory:c4test_GetHistoryPrint()
	LogTrace("c4test_LockHistory:c4test_GetHistoryPrint...")
	local CurEvent = LockHistoryEvent:new("TestPrintEventName", "TestPrintEventSource", 2021, 11, 12, 13, 14)
	
	local EventPrintRefStr = 
		"\n\t1: TestPrintEventName on 11/12/2021 at 01:14 PM\n"

	lu.assertEquals(CurEvent:GetHistoryPrint(1), EventPrintRefStr)
end

function c4test_LockHistory:c4test_GetHistoryEventNow()
	LogTrace("c4test_LockHistory:c4test_GetHistoryEventNow...")
	
	Lock_HistoryEventNow("TestNowEvent", "TestNowSource")

	local TestEvent = LockHistoryEvents[1]
	lu.assertEquals(TestEvent._EventName, "TestNowEvent")
	lu.assertEquals(TestEvent._EventSource, "TestNowSource")
	lu.assertEquals(TestEvent._HistoryID, 1)
	lu.assertNotNil(TestEvent._DateString)
	lu.assertNotNil(TestEvent._TimeString)
end

function c4test_LockHistory:c4test_GetHistoryEvent()
	LogTrace("c4test_LockHistory:c4test_GetHistoryEvent...")
	
	Lock_HistoryEvent("TestHistoryEvent", "TestHistorySource", 1990, 8, 12, 14, 43)

	local TestEvent = LockHistoryEvents[1]
	lu.assertEquals(TestEvent._EventName, "TestHistoryEvent")
	lu.assertEquals(TestEvent._EventSource, "TestHistorySource")
	lu.assertEquals(TestEvent._HistoryID, 1)
	lu.assertEquals(TestEvent._DateString, "08/12/1990")
	lu.assertEquals(TestEvent._TimeString, "02:43 PM")
end

function c4test_LockHistory:c4test_HistoryClear()
	LogTrace("c4test_LockHistory:c4test_HistoryClear...")
	
	Lock_HistoryEvent("Event1", "Source1")
	lu.assertEquals(#LockHistoryEvents, 1)
	Lock_HistoryEvent("Event2", "Source2")
	lu.assertEquals(#LockHistoryEvents, 2)
	Lock_HistoryEvent("Event3", "Source3")
	lu.assertEquals(#LockHistoryEvents, 3)

	Lock_HistoryClear()
	lu.assertEquals(#LockHistoryEvents, 0)
end

function c4test_LockHistory:c4test_TrimLockHistoryEventsTable()
	LogTrace("c4test_LockHistory:c4test_TrimLockHistoryEventsTable...")
	
	Lock_HistoryEvent("Event1", "Source1")
	Lock_HistoryEvent("Event2", "Source2")
	Lock_HistoryEvent("Event3", "Source3")
	Lock_HistoryEvent("Event4", "Source4")
	Lock_HistoryEvent("Event5", "Source5")
	Lock_HistoryEvent("Event6", "Source6")
	Lock_HistoryEvent("Event7", "Source7")

	lu.assertEquals(#LockHistoryEvents, 5)
	lu.assertEquals(LockHistoryEvents[1]._EventName, "Event7")
	lu.assertEquals(LockHistoryEvents[2]._EventName, "Event6")
	lu.assertEquals(LockHistoryEvents[3]._EventName, "Event5")
	lu.assertEquals(LockHistoryEvents[4]._EventName, "Event4")
	lu.assertEquals(LockHistoryEvents[5]._EventName, "Event3")
	
	TheLock:UpdateCurrentSetting(ST_LOG_ITEM_COUNT, 3)
	TrimLockHistoryEventsTable()
	
	lu.assertEquals(#LockHistoryEvents, 3)
	lu.assertEquals(LockHistoryEvents[1]._EventName, "Event7")
	lu.assertEquals(LockHistoryEvents[2]._EventName, "Event6")
	lu.assertEquals(LockHistoryEvents[3]._EventName, "Event5")
	lu.assertNil(LockHistoryEvents[4])
	lu.assertNil(LockHistoryEvents[5])
end

function c4test_LockHistory:c4test_GetHistoryXMLAll()
	LogTrace("c4test_LockHistory:c4test_GetHistoryXMLAll...")
	
	Lock_HistoryEvent("Event1", "Source1", 1991, 2, 3, 4, 5)
	Lock_HistoryEvent("Event2", "Source2", 1996, 6, 8, 9, 10)

	local HistoryRefXMLStr = 
		"<lock_history>" ..
			"<history_item>" ..
				"<history_id>1</history_id>" ..
				"<date>06/08/1996</date>" ..
				"<time>09:10 AM</time>" ..
				"<message>Event2</message>" ..
				"<source>Source2</source>" ..
			"</history_item>" ..
			"<history_item>" ..
				"<history_id>2</history_id>" ..
				"<date>02/03/1991</date>" ..
				"<time>04:05 AM</time>" ..
				"<message>Event1</message>" ..
				"<source>Source1</source>" ..
			"</history_item>" ..
		"</lock_history>"

	lu.assertEquals(GetHistoryXML(), HistoryRefXMLStr)
end

function c4test_LockHistory:c4test_GetHistoryPrintAll()
	LogTrace("c4test_LockHistory:c4test_GetHistoryPrintAll...")
	
	Lock_HistoryEvent("Event1", "Source1", 2005, 6, 7, 8, 9)
	Lock_HistoryEvent("Event2", "Source2", 2010, 11, 12, 13, 14)

	local HistoryRefPrintStr = 
		"\n\n\n--- Lock History ----\n" ..
		"\n\t1: Event2 on 11/12/2010 at 01:14 PM\n" ..
		"\n\t2: Event1 on 06/07/2005 at 08:09 AM\n"

	lu.assertEquals(GetHistoryPrint(), HistoryRefPrintStr)
end

