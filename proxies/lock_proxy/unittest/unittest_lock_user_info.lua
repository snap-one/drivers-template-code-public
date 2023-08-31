--[[==============================================================
	File is: unittest_lock_user_info.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_reports'

c4test_LockUserInfo = {}

function c4test_LockUserInfo:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()
	TheLock = nil
	self._CurrentUser = nil
end

function c4test_LockUserInfo:tearDown()
	self._CurrentUser = nil
	TheLock = nil
end

function c4test_LockUserInfo:CreateUserInstRaw(UserID)
	TheLock = LockDevice:new(DEFAULT_PROXY_BINDINGID)
	TheLock:InitialSetup()
	
	self._CurrentUser = LockUserInfo:new(UserID)
	return self._CurrentUser
end

function c4test_LockUserInfo:CreateUserInst(UserID)
	local CurUser = self:CreateUserInstRaw(UserID)
	CurUser:SetValidFlag(true)
	CurUser._AllowUpdateHistoryMessage = true
	return CurUser
end

-----------------------------------------------------------------------------------

function c4test_LockUserInfo:c4test_Construct()
	LogTrace("c4test_LockUserInfo:c4test_Construct...")
	local CurUser = self:CreateUserInstRaw(1)
	
	lu.assertEquals(CurUser._UserID, 1)
	lu.assertEquals(AllUsersInfo[CurUser._UserID], CurUser)
	lu.assertEquals(CurUser._Active, true)
	lu.assertEquals(CurUser._IsValid, false)
	lu.assertEquals(CurUser._InfoChanged, false)
	lu.assertEquals(CurUser._GatheringMultipleChanges, false)
	lu.assertEquals(CurUser._AllowUpdateHistoryMessage, true)

	lu.assertEquals(CurUser._UserName, "User 1")
	lu.assertEquals(CurUser._PassCode, "")

	lu.assertEquals(CurUser._RestrictedSchedule, false)
	lu.assertEquals(CurUser._ScheduleType, LST_DAILY)
	lu.assertTrue(CurUser._ScheduledDays.Sun)
	lu.assertTrue(CurUser._ScheduledDays.Mon)
	lu.assertTrue(CurUser._ScheduledDays.Tue)
	lu.assertTrue(CurUser._ScheduledDays.Wed)
	lu.assertTrue(CurUser._ScheduledDays.Thu)
	lu.assertTrue(CurUser._ScheduledDays.Fri)
	lu.assertTrue(CurUser._ScheduledDays.Sat)
	lu.assertEquals(CurUser._StartDateYear, 0)
	lu.assertEquals(CurUser._StartDateMonth, 1)
	lu.assertEquals(CurUser._StartDateDay, 1)
	lu.assertEquals(CurUser._EndDateYear, 9999)
	lu.assertEquals(CurUser._EndDateMonth, 12)
	lu.assertEquals(CurUser._EndDateDay, 31)
	lu.assertEquals(CurUser._StartTime, 0)
	lu.assertEquals(CurUser._EndTime, LAST_MINUTE)
end

function c4test_LockUserInfo:c4test_SetValidFlag()
	LogTrace("c4test_LockUserInfo:c4test_SetValidFlag...")
	local CurUser = self:CreateUserInstRaw(1)

	lu.assertFalse(CurUser:IsValid())

	CurUser:SetValidFlag(true)
	lu.assertTrue(CurUser:IsValid())

	CurUser:SetPassCode("3333")
	lu.assertEquals(AllUsersByPassCode["3333"], CurUser)
	CurUser:SetValidFlag(false)
	lu.assertEquals(AllUsersByPassCode["3333"], nil)
end

function c4test_LockUserInfo:c4test_MultipleChanges()
	LogTrace("c4test_LockUserInfo:c4test_MultipleChanges...")
	local CurUser = self:CreateUserInst(1)

	lu.assertFalse(CurUser._GatheringMultipleChanges)
	CurUser:StartMultipleChanges()
	lu.assertTrue(CurUser._GatheringMultipleChanges)
	
	CurUser:SetName("Frank")
	CurUser:SetPassCode("2345")

	lu.assertTrue(CurUser._InfoChanged)
	lu.assertEquals(CurUser:GetName(), "Frank")
	lu.assertEquals(CurUser:GetPassCode(), "2345")
	
	CurUser:EndMultipleChanges(100, true)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USER_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_NAME, "Frank")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().PASSCODE, "2345")

	lu.assertFalse(CurUser._GatheringMultipleChanges)
	lu.assertFalse(CurUser._InfoChanged)
end

function c4test_LockUserInfo:c4test_GetUserID()
	LogTrace("c4test_LockUserInfo:c4test_GetUserID...")
	local CurUser = self:CreateUserInst(1)

	lu.assertEquals(CurUser:GetUserID(), 1)
end

function c4test_LockUserInfo:c4test_GetName()
	LogTrace("c4test_LockUserInfo:c4test_GetName...")
	local CurUser = self:CreateUserInst(1)

	lu.assertEquals(CurUser:GetName(), "User 1")
	
	CurUser:SetName("Gideon")
	lu.assertEquals(CurUser:GetName(), "Gideon")
	
	-- LogInfo(C4NotificationMock:GetAllNotifications())
	-- C4LogMock:PrintAllLines()
end

function c4test_LockUserInfo:c4test_PassCode()
	LogTrace("c4test_LockUserInfo:c4test_GetName...")
	local CurUser = self:CreateUserInst(1)
	local CurUser2 = self:CreateUserInst(2)

	lu.assertEquals(CurUser:GetPassCode(), "")
	lu.assertEquals(CurUser2:GetPassCode(), "")
	
	CurUser:SetPassCode("4444")
	lu.assertEquals(CurUser:GetPassCode(), "4444")
	lu.assertEquals(AllUsersByPassCode["4444"], CurUser)
	
	CurUser2:SetPassCode("4444")
	lu.assertEquals(CurUser2:GetPassCode(), "")
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockUserInfo:SetPassCode  PassCode Not Available for user 2: 4444")
	lu.assertEquals(AllUsersByPassCode["4444"], CurUser)
	
	CurUser:SetPassCode("5555")
	lu.assertEquals(CurUser:GetPassCode(), "5555")
	lu.assertEquals(AllUsersByPassCode["5555"], CurUser)
	lu.assertEquals(AllUsersByPassCode["4444"], nil)
	
	-- LogInfo(C4NotificationMock:GetAllNotifications())
	-- C4LogMock:PrintAllLines()
end

function c4test_LockUserInfo:c4test_SetActiveFlag()
	LogTrace("c4test_LockUserInfo:c4test_SetActiveFlag...")
	local CurUser = self:CreateUserInst(1)

	lu.assertTrue(CurUser:IsActive())

	CurUser:SetActiveFlag(false)
	lu.assertFalse(CurUser:IsActive())
	
	CurUser:SetActiveFlag(true)
	lu.assertTrue(CurUser:IsActive())
end

function c4test_LockUserInfo:c4test_RestrictedSchedule()
	LogTrace("c4test_LockUserInfo:c4test_RestrictedSchedule...")
	local CurUser = self:CreateUserInst(1)

	lu.assertFalse(CurUser:HasRestrictedSchedule())

	CurUser:SetRestrictedScheduleFlag(true)
	lu.assertTrue(CurUser:HasRestrictedSchedule())
	
	CurUser:SetRestrictedScheduleFlag(false)
	lu.assertFalse(CurUser:HasRestrictedSchedule())
end

function c4test_LockUserInfo:c4test_RestrictedTime()
	LogTrace("c4test_LockUserInfo:c4test_RestrictedTime...")
	local CurUser = self:CreateUserInst(1)

	local SH1, SM1, EH1, EM1 = CurUser:GetScheduleTime()
	lu.assertEquals(SH1, 0)
	lu.assertEquals(SM1, 0)
	lu.assertEquals(EH1, 23)
	lu.assertEquals(EM1, 59)
	lu.assertFalse(CurUser:HasRestrictedSchedule())
	
	CurUser:SetRestrictedTime(425, 1290)
	local SH2, SM2, EH2, EM2 = CurUser:GetScheduleTime()
	lu.assertEquals(SH2, 7)
	lu.assertEquals(SM2, 5)
	lu.assertEquals(EH2, 21)
	lu.assertEquals(EM2, 30)
	lu.assertTrue(CurUser:HasRestrictedSchedule())
end

function c4test_LockUserInfo:c4test_DateRange()
	LogTrace("c4test_LockUserInfo:c4test_DateRange...")
	local CurUser = self:CreateUserInst(1)

	local SY1, SM1, SD1, EY1, EM1, ED1 = CurUser:GetDateRange()
	lu.assertEquals(SY1, 0)
	lu.assertEquals(SM1, 1)
	lu.assertEquals(SD1, 1)
	lu.assertEquals(EY1, 9999)
	lu.assertEquals(EM1, 12)
	lu.assertEquals(ED1, 31)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
	
	CurUser:SetDateRange(2004, 8, 15, 2023, 5, 16)
	local SY2, SM2, SD2, EY2, EM2, ED2 = CurUser:GetDateRange()
	lu.assertEquals(SY2, 2004)
	lu.assertEquals(SM2, 8)
	lu.assertEquals(SD2, 15)
	lu.assertEquals(EY2, 2023)
	lu.assertEquals(EM2, 5)
	lu.assertEquals(ED2, 16)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DATE_RANGE)
end

function c4test_LockUserInfo:c4test_ScheduleType()
	LogTrace("c4test_LockUserInfo:c4test_ScheduleType...")
	local CurUser = self:CreateUserInst(1)

	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
	
	CurUser:SetScheduleType(LST_DATE_RANGE)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DATE_RANGE)
	
	CurUser:SetScheduleType(LST_DAILY)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)

	CurUser:SetScheduleType("Something Else")
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
end

function c4test_LockUserInfo:c4test_ScheduleDays()
	LogTrace("c4test_LockUserInfo:c4test_ScheduleDays...")
	local CurUser = self:CreateUserInst(1)

	CurUser:SetScheduleType(LST_DATE_RANGE)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DATE_RANGE)
	local Su1, Mo1, Tu1, We1, Th1, Fr1, Sa1 = CurUser:GetScheduleDays()
	lu.assertTrue(Su1)
	lu.assertTrue(Mo1)
	lu.assertTrue(Tu1)
	lu.assertTrue(We1)
	lu.assertTrue(Th1)
	lu.assertTrue(Fr1)
	lu.assertTrue(Sa1)

	local DayTable = {
		Sun = true,
		Mon = false,
		Wed = false,
		Fri = true,
		Sat = true,
	}

	CurUser:SetScheduleDays(DayTable)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
	local Su2, Mo2, Tu2, We2, Th2, Fr2, Sa2 = CurUser:GetScheduleDays()
	lu.assertTrue(Su2)
	lu.assertFalse(Mo2)
	lu.assertTrue(Tu2)
	lu.assertFalse(We2)
	lu.assertTrue(Th2)
	lu.assertTrue(Fr2)
	lu.assertTrue(Sa2)

	local SchedDayRefStr = 
		"true," ..
		"false," ..
		"true," ..
		"false," ..
		"true," ..
		"true," ..
		"true"
	lu.assertEquals(CurUser:GetScheduleDaysString(), SchedDayRefStr)
end

function c4test_LockUserInfo:c4test_BlockHistory()
	LogTrace("c4test_LockUserInfo:c4test_BlockHistory...")
	local CurUser = self:CreateUserInst(1)

	lu.assertTrue(CurUser._AllowUpdateHistoryMessage)
	
	CurUser:BlockHistory()
	lu.assertFalse(CurUser._AllowUpdateHistoryMessage)

	CurUser:BlockHistoryTimerExpired()
	lu.assertTrue(CurUser._AllowUpdateHistoryMessage)
end

function c4test_LockUserInfo:c4test_GetXMLData()
	LogTrace("c4test_LockUserInfo:c4test_GetXMLData...")
	local CurUser = self:CreateUserInst(1)

	local UserXMLRef = 
		"<user>" ..
			"<user_id>1</user_id>" ..
			"<user_name>User 1</user_name>" ..
			"<passcode></passcode>" ..
			"<is_active>true</is_active>" ..
			"<is_restricted_schedule>false</is_restricted_schedule>" ..
			"<start_time>0</start_time>" ..
			"<end_time>1439</end_time>" ..
			"<schedule_type>daily</schedule_type>" ..
			"<start_day>1</start_day>" ..
			"<start_month>1</start_month>" ..
			"<start_year>0</start_year>" ..
			"<end_day>31</end_day>" ..
			"<end_month>12</end_month>" ..
			"<end_year>9999</end_year>" ..
			"<scheduled_days>true,true,true,true,true,true,true</scheduled_days>" ..
		"</user>"

	lu.assertEquals(CurUser:GetXMLData(), UserXMLRef)
end

function c4test_LockUserInfo:c4test_PassCodeAvailable()
	LogTrace("c4test_LockUserInfo:c4test_PassCodeAvailable...")
	local CurUser = self:CreateUserInst(1)
	
	local TestPassCode = "8888"
	
	lu.assertTrue(LockUserInfo.PassCodeAvailable(TestPassCode))
	CurUser:SetPassCode(TestPassCode)
	lu.assertFalse(LockUserInfo.PassCodeAvailable(TestPassCode))
end


function c4test_LockUserInfo:c4test_DateIsValid()
	LogTrace("c4test_LockUserInfo:c4test_ScheduleType...")
	
	lu.assertTrue(LockUserInfo.DateIsValid(1990, 1, 16))
	lu.assertTrue(LockUserInfo.DateIsValid(1991, 2, 23))
	lu.assertTrue(LockUserInfo.DateIsValid(1992, 3, 15))
	lu.assertTrue(LockUserInfo.DateIsValid(1993, 4, 29))
	lu.assertTrue(LockUserInfo.DateIsValid(1994, 6, 13))
	lu.assertTrue(LockUserInfo.DateIsValid(1995, 6, 28))
	lu.assertTrue(LockUserInfo.DateIsValid(1996, 8, 2))
	lu.assertTrue(LockUserInfo.DateIsValid(1997, 12, 1))

	lu.assertTrue(LockUserInfo.DateIsValid(2020, 2, 28))
	lu.assertTrue(LockUserInfo.DateIsValid(2020, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2020, 2, 30))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2000, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2100, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2200, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2300, 2, 29))
	lu.assertTrue(LockUserInfo.DateIsValid(2000, 2, 29))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2024, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2025, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2026, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2027, 2, 29))
	lu.assertTrue(LockUserInfo.DateIsValid(2028, 2, 29))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 1, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 1, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 1, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 2, 28))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 2, 29))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 2, 30))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 2, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 2, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 3, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 3, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 3, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 4, 30))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 4, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 4, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 5, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 5, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 5, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 6, 30))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 6, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 6, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 7, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 7, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 7, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 8, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 8, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 8, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 9, 30))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 9, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 9, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 10, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 10, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 10, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 11, 30))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 11, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 11, 32))
	
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 12, 30))
	lu.assertTrue(LockUserInfo.DateIsValid(2021, 12, 31))
	lu.assertFalse(LockUserInfo.DateIsValid(2021, 12, 32))

	lu.assertFalse(LockUserInfo.DateIsValid(2021, 13, 5))
	
end
