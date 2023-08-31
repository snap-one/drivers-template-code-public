--[[==============================================================
	File is: unittest_lock_reports.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_reports'

c4test_LockReports = {}

function c4test_LockReports:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()
	TheLock = nil
	self._CurrentDevice = nil
end

function c4test_LockReports:tearDown()
	self._CurrentDevice = nil
end

function c4test_LockReports:CreateLockDeviceClassInst()
	self._CurrentDevice = LockDevice:new(DEFAULT_PROXY_BINDINGID)
	TheLock = self._CurrentDevice
	self._CurrentDevice:InitialSetup()
	return self._CurrentDevice
end

function c4test_LockReports:CreateUserInst(UserID)
	self._CurrentDevice:AddUser(UserID)
	return AllUsersInfo[UserID]
end

-----------------------------------------------------------------------------------

function c4test_LockReports:c4test_InitialLockStatus()
	LogTrace("c4test_LockMain:c4test_InitialLockStatus...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev._CurLockState,	LS_UNKNOWN)

	LockReport_InitialLockStatus(LS_LOCKED)
	lu.assertEquals(CurDev._CurLockState,	LS_LOCKED)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_INITIALIZE")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "locked")

	LockReport_InitialLockStatus(LS_UNLOCKED)
	lu.assertEquals(CurDev._CurLockState,	LS_UNLOCKED)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_INITIALIZE")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "unlocked")

	LockReport_InitialLockStatus(LS_FAULT)
	lu.assertEquals(CurDev._CurLockState,	LS_FAULT)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_INITIALIZE")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "fault")
end

function c4test_LockReports:c4test_LockStatusLock()
	LogTrace("c4test_LockMain:c4test_LockStatus...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev._CurLockState,	LS_UNKNOWN)

	LockReport_LockStatus(LS_LOCKED, "Unit Test Lock", "System", false)
	lu.assertEquals(CurDev._CurLockState,	LS_LOCKED)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "locked")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LAST_ACTION_DESCRIPTION, "Unit Test Lock")
	lu.assertFalse(C4NotificationMock:GetLastNotificationParams().MANUAL)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SOURCE, "System")
end

function c4test_LockReports:c4test_LockStatusUnlock()
	LogTrace("c4test_LockMain:c4test_LockStatusUnlock...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev._CurLockState,	LS_UNKNOWN)

	LockReport_LockStatus(LS_UNLOCKED, "Unit Test Unlock", "Tester", true)
	lu.assertEquals(CurDev._CurLockState,	LS_UNLOCKED)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "unlocked")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LAST_ACTION_DESCRIPTION, "Unit Test Unlock")
	lu.assertTrue(C4NotificationMock:GetLastNotificationParams().MANUAL)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SOURCE, "Tester")
end


function c4test_LockReports:c4test_LockStatusFault()
	LogTrace("c4test_LockMain:c4test_LockStatusFault...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev._CurLockState,	LS_UNKNOWN)

	LockReport_LockStatus(LS_FAULT, "Unit Test Fault", "Faulter", false)
	lu.assertEquals(CurDev._CurLockState,	LS_FAULT)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "fault")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LAST_ACTION_DESCRIPTION, "Unit Test Fault")
	lu.assertFalse(C4NotificationMock:GetLastNotificationParams().MANUAL)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SOURCE, "Faulter")
end

function c4test_LockReports:c4test_UnlockedBy()
	LogTrace("c4test_LockMain:c4test_UnlockedBy...")
	
	LockReport_UnlockedBy("Barbara")
	lu.assertEquals(Variables.LAST_UNLOCKED_BY, "Barbara")
end

function c4test_LockReports:c4test_BatteryStatus()
	LogTrace("c4test_LockMain:c4test_BatteryStatus...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	LockReport_BatteryStatus(LBS_WARNING)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().BATTERY_STATUS, LBS_WARNING)
	
	LockReport_BatteryStatus(LBS_CRITICAL)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().BATTERY_STATUS, LBS_CRITICAL)
	
	LockReport_BatteryStatus(LBS_NORMAL)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().BATTERY_STATUS, LBS_NORMAL)
	
	LockReport_BatteryStatus("Zappy")
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockDevice:SetBatteryStatus  Invalid Battery Status: Zappy")
end

function c4test_LockReports:c4test_AdminCode()
	LogTrace("c4test_LockMain:c4test_AdminCode...")
	local CurDev = self:CreateLockDeviceClassInst()

	LockReport_AdminCode("7654")
	lu.assertEquals(CurDev:GetAdminCode(), "7654")
end

function c4test_LockReports:c4test_CapabilityChanged()
	LogTrace("c4test_LockMain:c4test_CapabilityChanged...")
	local CurDev = self:CreateLockDeviceClassInst()

	LockReport_CapabilityChanged(CAP_MAX_USERS, 40)
	lu.assertEquals(CurDev:GetMaxUsers(), 40)
end

function c4test_LockReports:c4test_UpdateCurrentSetting()
	LogTrace("c4test_LockMain:c4test_UpdateCurrentSetting...")
	local CurDev = self:CreateLockDeviceClassInst()

	LockReport_UpdateCurrentSetting(ST_VOLUME, "silent")
	lu.assertEquals(CurDev:GetCurrentSetting(ST_VOLUME), "silent")
end

function c4test_LockReports:c4test_ReportAllUsers()
	LogTrace("c4test_LockMain:c4test_ReportAllUsers...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	LockReport_ReportAllUsers()
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : NOTIFY.USERS")
end

function c4test_LockReports:c4test_AddUser()
	LogTrace("c4test_LockMain:c4test_AddUser...")
	local CurDev = self:CreateLockDeviceClassInst()

	LockReport_AddUser(1)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : Lock_HistoryEventNow: Added New User 1 (User 1) Control4")
end

function c4test_LockReports:c4test_DeleteUser()
	LogTrace("c4test_LockMain:c4test_DeleteUser...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	LockReport_DeleteUser(1)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : NOTIFY.USER_DELETED")
end


function c4test_LockReports:c4test_UpdateUserInformation()
	LogTrace("c4test_LockMain:c4test_UpdateUserInformation...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	LockReport_UpdateUserInformation(	1, "Caleb", "5678",
										true, false
										-- rest of the parameters don't get used
									)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : NOTIFY.USER_CHANGED")

	LockReport_UpdateUserInformation(	2, "Daniel", "6543",
										true, false
										-- rest of the parameters don't get used
									)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockDevice:UpdateUserInformation  Invalid or Unused UserID: 2")
end

function c4test_LockReports:c4test_UserName()
	LogTrace("c4test_LockMain:c4test_UserName...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	LockReport_UserName(1, "Ephraim")
	lu.assertEquals(CurUser:GetName(), "Ephraim")
end

function c4test_LockReports:c4test_UserPasscode()
	LogTrace("c4test_LockMain:c4test_UserPasscode...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	LockReport_UserPassCode(1, "7878")
	lu.assertEquals(CurUser:GetPassCode(), "7878")
end

function c4test_LockReports:c4test_UserActiveFlag()
	LogTrace("c4test_LockMain:c4test_UserActiveFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	lu.assertTrue(CurUser:IsActive())
	LockReport_UserActiveFlag(1, false)
	lu.assertFalse(CurUser:IsActive())
	LockReport_UserActiveFlag(1, true)
	lu.assertTrue(CurUser:IsActive())
end

function c4test_LockReports:c4test_UserRestrictedScheduleFlag()
	LogTrace("c4test_LockMain:c4test_UserRestrictedScheduleFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	lu.assertFalse(CurUser:HasRestrictedSchedule())
	LockReport_UserRestrictedScheduleFlag(1, true)
	lu.assertTrue(CurUser:HasRestrictedSchedule())
	LockReport_UserRestrictedScheduleFlag(1, false)
	lu.assertFalse(CurUser:HasRestrictedSchedule())
end

function c4test_LockReports:c4test_UserDateRange()
	LogTrace("c4test_LockMain:c4test_UserDateRange...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	local SY1, SM1, SD1, EY1, EM1, ED1 = CurUser:GetDateRange()
	lu.assertEquals(SY1, 0)
	lu.assertEquals(SM1, 1)
	lu.assertEquals(SD1, 1)
	lu.assertEquals(EY1, 9999)
	lu.assertEquals(EM1, 12)
	lu.assertEquals(ED1, 31)

	LockReport_UserDateRange(1, 2020, 2, 3, 2021, 7, 8)

	local SY2, SM2, SD2, EY2, EM2, ED2 = CurUser:GetDateRange()
	lu.assertEquals(SY2, 2020)
	lu.assertEquals(SM2, 2)
	lu.assertEquals(SD2, 3)
	lu.assertEquals(EY2, 2021)
	lu.assertEquals(EM2, 7)
	lu.assertEquals(ED2, 8)
end

function c4test_LockReports:c4test_UserScheduleType()
	LogTrace("c4test_LockMain:c4test_UserScheduleType...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)

	LockReport_UserScheduleType(1, LST_DATE_RANGE)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DATE_RANGE)
	LockReport_UserScheduleType(1, LST_DAILY)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
	LockReport_UserScheduleType(1, "Some Nonsense")
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
end

function c4test_LockReports:c4test_UserScheduleDays()
	LogTrace("c4test_LockMain:c4test_UserScheduleDays...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	local Su1, Mo1, Tu1, We1, Th1, Fr1, Sa1 = CurUser:GetScheduleDays()
	lu.assertTrue(Su1)
	lu.assertTrue(Mo1)
	lu.assertTrue(Tu1)
	lu.assertTrue(We1)
	lu.assertTrue(Th1)
	lu.assertTrue(Fr1)
	lu.assertTrue(Sa1)

	LockReport_UserScheduleDays(1, false, true, false, false, true, true, false)
	local Su2, Mo2, Tu2, We2, Th2, Fr2, Sa2 = CurUser:GetScheduleDays()
	lu.assertFalse(Su2)
	lu.assertTrue(Mo2)
	lu.assertFalse(Tu2)
	lu.assertFalse(We2)
	lu.assertTrue(Th2)
	lu.assertTrue(Fr2)
	lu.assertFalse(Sa2)
end

function c4test_LockReports:c4test_UserScheduleDay()
	LogTrace("c4test_LockMain:c4test_UserScheduleDay...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	local Su1, Mo1, Tu1, We1, Th1, Fr1, Sa1 = CurUser:GetScheduleDays()
	lu.assertTrue(Su1)
	lu.assertTrue(Mo1)
	lu.assertTrue(Tu1)
	lu.assertTrue(We1)
	lu.assertTrue(Th1)
	lu.assertTrue(Fr1)
	lu.assertTrue(Sa1)

	LockReport_SetUserScheduleDay(1, "Mon", false)
	LockReport_SetUserScheduleDay(1, "Fri", false)
	local Su2, Mo2, Tu2, We2, Th2, Fr2, Sa2 = CurUser:GetScheduleDays()
	lu.assertFalse(Mo2)
	lu.assertFalse(Fr2)
end

function c4test_LockReports:c4test_UserRestritedTime()
	LogTrace("c4test_LockMain:c4test_UserRestritedTime...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = c4test_LockReports:CreateUserInst(1)

	local SH1, SM1, EH1, EM1 = CurUser:GetScheduleTime()
	lu.assertEquals(SH1, 0)
	lu.assertEquals(SM1, 0)
	lu.assertEquals(EH1, 23)
	lu.assertEquals(EM1, 59)
	
	LockReport_UserRestrictedTime(1, 615, 1240)
	local SH2, SM2, EH2, EM2 = CurUser:GetScheduleTime()
	lu.assertEquals(SH2, 10)
	lu.assertEquals(SM2, 15)
	lu.assertEquals(EH2, 20)
	lu.assertEquals(EM2, 40)
end

function c4test_LockReports:c4test_UpdateCustomSetting()
	LogTrace("c4test_LockMain:c4test_AddCustomSettingBoolean...")
	local CurDev = self:CreateLockDeviceClassInst()

	LockReport_UpdateCustomSetting("CustomB", true)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, "CustomB")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "true")
end


function c4test_LockReports:c4test_History()
	LogTrace("c4test_LockMain:c4test_History...")
	local CurDev = self:CreateLockDeviceClassInst()
	CurDev:UpdateCapability(CAP_HAS_INTERNAL_HISTORY, true)

	LockReport_HistoryEvent("First Event", "Report History Test")
	LockReport_HistoryEvent("Second Event", "Report History Test")

	lu.assertEquals(LockHistoryEvents[1]._EventName, "Second Event")
	lu.assertEquals(LockHistoryEvents[1]._EventSource, "Report History Test")
	lu.assertEquals(LockHistoryEvents[1]._HistoryID, 2)

	lu.assertEquals(LockHistoryEvents[2]._EventName, "First Event")
	lu.assertEquals(LockHistoryEvents[2]._EventSource, "Report History Test")
	lu.assertEquals(LockHistoryEvents[2]._HistoryID, 1)
	
	LockReport_HistoryClear()
	lu.assertEquals(LockHistoryEvents, {})
	
end

