--[[==============================================================
	File is: unittest_lock_apis.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_reports'

c4test_LockApis = {}

function c4test_LockApis:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()

	TheLock = nil
	self._CurrentDevice = nil
end


function c4test_LockApis:tearDown()
	self._CurrentDevice = nil
end

function c4test_LockApis:CreateLockDeviceClassInst()
	self._CurrentDevice = LockDevice:new(DEFAULT_PROXY_BINDINGID)
	TheLock = self._CurrentDevice
	self._CurrentDevice:InitialSetup()
	return self._CurrentDevice
end

function c4test_LockApis:CreateUserInst(UserID)
	self._CurrentDevice:AddUser(UserID)
	return AllUsersInfo[UserID]
end

-----------------------------------------------------------------------------------

function c4test_LockApis:c4test_IsLocked()
	LogTrace("c4test_LockApis:c4test_IsLocked...")
	local CurDev = self:CreateLockDeviceClassInst()

	CurDev:SetLockInitialState(LS_LOCKED)
	lu.assertTrue(IsLocked())

	CurDev:SetLockInitialState(LS_UNLOCKED)
	lu.assertFalse(IsLocked())

	CurDev:SetLockInitialState(LS_FAULT)
	lu.assertFalse(IsLocked())
end

function c4test_LockApis:c4test_AdminCode()
	LogTrace("c4test_LockApis:c4test_AdminCode...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(GetCurrentAdminCode(), "")

	CurDev:SetAdminCode("6789")
	lu.assertEquals(GetCurrentAdminCode(), "6789")
end

function c4test_LockApis:c4test_GetCurrentSetting()
	LogTrace("c4test_LockApis:c4test_GetCurrentSetting...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(GetCurrentSetting(ST_AUTO_LOCK_TIME), 0)
	lu.assertEquals(GetCurrentSetting(ST_LOG_ITEM_COUNT), 5)
	lu.assertEquals(GetCurrentSetting(ST_SCHEDULE_LOCKOUT_ENABLED), false)
	lu.assertEquals(GetCurrentSetting(ST_LOCK_MODE), "normal")
	lu.assertEquals(GetCurrentSetting(ST_LOG_FAILED_ATTEMPTS), false)
	lu.assertEquals(GetCurrentSetting(ST_WRONG_CODE_ATTEMPTS), 5)
	lu.assertEquals(GetCurrentSetting(ST_SHUTOUT_TIMER), 30)
	lu.assertEquals(GetCurrentSetting(ST_LANGUAGE), "English")
	lu.assertEquals(GetCurrentSetting(ST_VOLUME), "high")
	lu.assertEquals(GetCurrentSetting(ST_ONE_TOUCH_LOCKING), false)
	lu.assertEquals(GetCurrentSetting("Something Bogus"), nil)

end

function c4test_LockApis:c4test_GetAutoLockTime()
	LogTrace("c4test_LockApis:c4test_GetAutoLockTime...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(GetAutoLockTime(), 0)
end

function c4test_LockApis:c4test_GetMaxUsers()
	LogTrace("c4test_LockApis:c4test_GetMaxUsers...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(GetMaxUsers(), 32)
end

function c4test_LockApis:c4test_GetCapabilityValues()
	LogTrace("c4test_LockApis:c4test_GetCapabilityValues...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(GetCapabilityValue(CAP_IS_MANAGEMENT_ONLY), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_ADMIN_CODE), true)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_SCHEDULE_LOCKOUT), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_AUTO_LOCK_TIME), false)
	lu.assertEquals(GetCapabilityValue(CAP_AUTO_LOCK_TIME_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_AUTO_LOCK_TIME_DISPLAY_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_HAS_LOG_ITEM_COUNT), false)
	lu.assertEquals(GetCapabilityValue(CAP_LOG_ITEM_COUNT_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_HAS_LOCK_MODES), false)
	lu.assertEquals(GetCapabilityValue(CAP_LOCK_MODES_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_HAS_LOG_FAILED_ATTEMPTS), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_WRONG_CODE_ATTEMPTS), false)
	lu.assertEquals(GetCapabilityValue(CAP_WRONG_CODE_ATTEMPTS_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_HAS_SHUTOUT_TIMER), false)
	lu.assertEquals(GetCapabilityValue(CAP_SHUTOUT_TIMER_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_SHUTOUT_TIMER_DISPLAY_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_HAS_LANGUAGE), false)
	lu.assertEquals(GetCapabilityValue(CAP_LANGUAGE_VALUES), "")
	lu.assertEquals(GetCapabilityValue(CAP_HAS_VOLUME), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_ONE_TOUCH_LOCKING), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_DAILY_SCHEDULE), true)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_DATE_RANGE_SCHEDULE), false)
	lu.assertEquals(GetCapabilityValue(CAP_MAX_USERS), 32)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_SETTINGS), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_CUSTOM_SETTINGS), false)
	lu.assertEquals(GetCapabilityValue(CAP_HAS_INTERNAL_HISTORY), false)
end

function c4test_LockApis:c4test_IsUserDefined()
	LogTrace("c4test_LockApis:c4test_IsUserDefined...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertTrue(IsUserDefined(1))
	lu.assertFalse(IsUserDefined(2))
end

function c4test_LockApis:c4test_IsUserValid()
	LogTrace("c4test_LockApis:c4test_IsUserValid...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertTrue(IsUserValid(1))
	lu.assertFalse(IsUserValid(2))
	
	CurUser:SetValidFlag(false)
	lu.assertFalse(IsUserValid(1))
end

function c4test_LockApis:c4test_GetUserName()
	LogTrace("c4test_LockApis:c4test_GetUserName...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertEquals(GetUserName(1), "User 1")

	CurUser:SetName("Izzy")
	lu.assertEquals(GetUserName(1), "Izzy")
end

function c4test_LockApis:c4test_GetUserPassCode()
	LogTrace("c4test_LockApis:c4test_GetUserPassCode...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertEquals(GetUserPassCode(1), "")

	CurUser:SetPassCode("9898")
	lu.assertEquals(GetUserPassCode(1), "9898")

	lu.assertEquals(GetUserPassCode(2), "")
end

function c4test_LockApis:c4test_GetUserActiveFlag()
	LogTrace("c4test_LockApis:c4test_GetUserActiveFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertTrue(GetUserActiveFlag(1))
	lu.assertFalse(GetUserActiveFlag(2))

	CurUser:SetActiveFlag(false)
	lu.assertFalse(GetUserActiveFlag(1))
end

function c4test_LockApis:c4test_GetUserRestrictedScheduleFlag()
	LogTrace("c4test_LockApis:c4test_GetUserRestrictedScheduleFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertFalse(GetUserRestrictedScheduleFlag(1))
	lu.assertFalse(GetUserRestrictedScheduleFlag(2))

	CurUser:SetRestrictedScheduleFlag(true)
	lu.assertTrue(GetUserRestrictedScheduleFlag(1))
end

function c4test_LockApis:c4test_GetUserDateRange()
	LogTrace("c4test_LockApis:c4test_GetUserDateRange...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	local SY1, SM1, SD1, EY1, EM1, ED1 = GetUserDateRange(1)
	lu.assertEquals(SY1, 0)
	lu.assertEquals(SM1, 1)
	lu.assertEquals(SD1, 1)
	lu.assertEquals(EY1, 9999)
	lu.assertEquals(EM1, 12)
	lu.assertEquals(ED1, 31)

	local SY2, SM2, SD2, EY2, EM2, ED2 = GetUserDateRange(2)
	lu.assertEquals(SY2, 2000)
	lu.assertEquals(SM2, 1)
	lu.assertEquals(SD2, 1)
	lu.assertEquals(EY2, 2999)
	lu.assertEquals(EM2, 12)
	lu.assertEquals(ED2, 31)

	CurUser:SetDateRange(2023, 11, 17, 2024, 2, 29)
	local SY3, SM3, SD3, EY3, EM3, ED3 = GetUserDateRange(1)
	lu.assertEquals(SY3, 2023)
	lu.assertEquals(SM3, 11)
	lu.assertEquals(SD3, 17)
	lu.assertEquals(EY3, 2024)
	lu.assertEquals(EM3, 2)
	lu.assertEquals(ED3, 29)
end

function c4test_LockApis:c4test_GetUserScheduleType()
	LogTrace("c4test_LockApis:c4test_GetUserScheduleType...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	lu.assertEquals(GetUserScheduleType(1), LST_DAILY)
	lu.assertEquals(GetUserScheduleType(2), LST_DAILY)

	CurUser:SetScheduleType(LST_DATE_RANGE)
	lu.assertEquals(GetUserScheduleType(1), LST_DATE_RANGE)
end

function c4test_LockApis:c4test_GetUserScheduleDays()
	LogTrace("c4test_LockApis:c4test_GetUserScheduleDays...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	local Su1, Mo1, Tu1, We1, Th1, Fr1, Sa1 = GetUserScheduleDays(1)
	lu.assertTrue(Su1)
	lu.assertTrue(Mo1)
	lu.assertTrue(Tu1)
	lu.assertTrue(We1)
	lu.assertTrue(Th1)
	lu.assertTrue(Fr1)
	lu.assertTrue(Sa1)

	local Su2, Mo2, Tu2, We2, Th2, Fr2, Sa2 = GetUserScheduleDays(2)
	lu.assertTrue(Su2)
	lu.assertTrue(Mo2)
	lu.assertTrue(Tu2)
	lu.assertTrue(We2)
	lu.assertTrue(Th2)
	lu.assertTrue(Fr2)
	lu.assertTrue(Sa2)
	
	local DayChangeTbl = {
		Sun = true,
		Mon = false,
		Wed = false,
		Thu = false,
	}
	
	CurUser:SetScheduleDays(DayChangeTbl)
	local Su1, Mo1, Tu1, We1, Th1, Fr1, Sa1 = GetUserScheduleDays(1)
	lu.assertTrue(Su1)
	lu.assertFalse(Mo1)
	lu.assertTrue(Tu1)
	lu.assertFalse(We1)
	lu.assertFalse(Th1)
	lu.assertTrue(Fr1)
	lu.assertTrue(Sa1)
end

function c4test_LockApis:c4test_GetUserScheduleTime()
	LogTrace("c4test_LockApis:c4test_GetUserScheduleTime...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	local SH1, SM1, EH1, EM1 = GetUserScheduleTime(1)
	lu.assertEquals(SH1, 0)
	lu.assertEquals(SM1, 0)
	lu.assertEquals(EH1, 23)
	lu.assertEquals(EM1, 59)

	local SH2, SM2, EH2, EM2 = GetUserScheduleTime(2)
	lu.assertEquals(SH2, 0)
	lu.assertEquals(SM2, 0)
	lu.assertEquals(EH2, 23)
	lu.assertEquals(EM2, 59)

	CurUser:SetRestrictedTime(308, 950)
	local SH3, SM3, EH3, EM3 = GetUserScheduleTime(1)
	lu.assertEquals(SH3, 5)
	lu.assertEquals(SM3, 8)
	lu.assertEquals(EH3, 15)
	lu.assertEquals(EM3, 50)
end

function c4test_LockApis:c4test_HasInternalHistory()
	LogTrace("c4test_LockApis:c4test_HasInternalHistory...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertFalse(HasInternalHistory())
	
	CurDev:UpdateCapability(CAP_HAS_INTERNAL_HISTORY, true)
	lu.assertTrue(HasInternalHistory())
end

function c4test_LockApis:c4test_MultipleChanges()
	LogTrace("c4test_LockApis:c4test_MultipleChanges...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	StartUserMultipleChanges(1)
	CurUser:SetName("Jasper")
	CurUser:SetPassCode("5454")
	EndUserMultipleChanges(1)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USER_CHANGED")
end

function c4test_LockApis:c4test_GetUserIDFromCode()
	LogTrace("c4test_LockApis:c4test_GetUserIDFromCode...")
	local CurDev = self:CreateLockDeviceClassInst()
	local CurUser = self:CreateUserInst(1)

	CurUser:SetPassCode("2222")
	lu.assertEquals(GetUserIDFromCode("2222"), 1)
	lu.assertEquals(GetUserIDFromCode("1111"), 0)
end


