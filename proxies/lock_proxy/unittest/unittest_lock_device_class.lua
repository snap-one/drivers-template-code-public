--[[==============================================================
	File is: unittest_lock_device_class.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_device_class'

c4test_LockDeviceClass = {}

function c4test_LockDeviceClass:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()

	TheLock = nil
	self._CurrentDevice = nil
end


function c4test_LockDeviceClass:tearDown()
	self._CurrentDevice = nil
end

function c4test_LockDeviceClass:CreateLockDeviceClassInst()
	self._CurrentDevice = LockDevice:new(DEFAULT_PROXY_BINDINGID)
	TheLock = self._CurrentDevice
	self._CurrentDevice:InitialSetup()
	return self._CurrentDevice
end

function c4test_LockDeviceClass:CreateUserInst(UserID)
	self._CurrentDevice:AddUser(UserID)
	return AllUsersInfo[UserID]
end

-------------------------------------------------------------------------------------------------

function c4test_LockDeviceClass:c4test_Construct()
	LogTrace("c4test_LockMain:c4test_Construct...")
	local CurDev = self:CreateLockDeviceClassInst()
	--LogInfo(CurDev)
	
	lu.assertEquals(CurDev._CurLockState,	LS_UNKNOWN)
	lu.assertEquals(CurDev._ActionDescription,	"")
	lu.assertEquals(CurDev._BatteryStatus,	LBS_NORMAL)
	lu.assertEquals(CurDev._GatheringInfo,	false)

	lu.assertEquals(PersistLockData._Settings[ST_AUTO_LOCK_TIME], 0)
	lu.assertEquals(PersistLockData._Settings[ST_LOG_ITEM_COUNT], 5)
	lu.assertEquals(PersistLockData._Settings[ST_SCHEDULE_LOCKOUT_ENABLED], false)
	lu.assertEquals(PersistLockData._Settings[ST_LOCK_MODE], "normal")
	lu.assertEquals(PersistLockData._Settings[ST_LOG_FAILED_ATTEMPTS], false)
	lu.assertEquals(PersistLockData._Settings[ST_WRONG_CODE_ATTEMPTS], 5)
	lu.assertEquals(PersistLockData._Settings[ST_SHUTOUT_TIMER], 30)
	lu.assertEquals(PersistLockData._Settings[ST_LANGUAGE], "English")
	lu.assertEquals(PersistLockData._Settings[ST_VOLUME], "high")
	lu.assertEquals(PersistLockData._Settings[ST_ONE_TOUCH_LOCKING], false)

	lu.assertEquals(PersistLockData._AdminCode, "")
end


function c4test_LockDeviceClass:c4test_GetBindingID()
	LogTrace("c4test_LockMain:c4test_GetBindingID...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev:GetBindingID(), 5001)
end

function c4test_LockDeviceClass:c4test_InitialLockState()
	LogTrace("c4test_LockMain:c4test_InitialLockState...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev:CurLockState(), LS_UNKNOWN)
	lu.assertFalse(CurDev:IsLocked())

	CurDev:SetLockInitialState(LS_LOCKED)
	lu.assertTrue(CurDev:IsLocked())
	lu.assertEquals(CurDev:CurLockState(), LS_LOCKED)
	
	CurDev:SetLockInitialState(LS_UNLOCKED)
	lu.assertFalse(CurDev:IsLocked())
	lu.assertEquals(CurDev:CurLockState(), LS_UNLOCKED)
	
	CurDev:SetLockInitialState(LS_FAULT)
	lu.assertFalse(CurDev:IsLocked())
	lu.assertEquals(CurDev:CurLockState(), LS_FAULT)
	
end

function c4test_LockDeviceClass:c4test_LockState()
	LogTrace("c4test_LockMain:c4test_LockState...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev:CurLockState(), LS_UNKNOWN)
	lu.assertFalse(CurDev:IsLocked())
	lu.assertTrue(LockDevice.IsValidState(CurDev:CurLockState()))

	CurDev:SetLockState(LS_LOCKED, true, "Manually Locked", "System")
	lu.assertTrue(CurDev:IsLocked())
	lu.assertEquals(CurDev:CurLockState(), LS_LOCKED)
	lu.assertTrue(LockDevice.IsValidState(CurDev:CurLockState()))
	
	CurDev:SetLockState(LS_UNLOCKED, true, "Manually UnLocked", "System")
	lu.assertFalse(CurDev:IsLocked())
	lu.assertEquals(CurDev:CurLockState(), LS_UNLOCKED)
	lu.assertTrue(LockDevice.IsValidState(CurDev:CurLockState()))
	
	CurDev:SetLockState(LS_FAULT, true, "Manuall Fault", "System")
	lu.assertFalse(CurDev:IsLocked())
	lu.assertEquals(CurDev:CurLockState(), LS_FAULT)
	lu.assertTrue(LockDevice.IsValidState(CurDev:CurLockState()))

	CurDev._CurLockState = "Bogus"
	lu.assertFalse(LockDevice.IsValidState(CurDev:CurLockState()))
end


function c4test_LockDeviceClass:c4test_MaxUsers()
	LogTrace("c4test_LockMain:c4test_MaxUsers...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev:GetMaxUsers(), 32)
end


function c4test_LockDeviceClass:c4test_GetCapability()
	LogTrace("c4test_LockMain:c4test_GetCapability...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev:GetCapability(CAP_IS_MANAGEMENT_ONLY), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_ADMIN_CODE), true)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_SCHEDULE_LOCKOUT), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_AUTO_LOCK_TIME), false)
	lu.assertEquals(CurDev:GetCapability(CAP_AUTO_LOCK_TIME_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_AUTO_LOCK_TIME_DISPLAY_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_LOG_ITEM_COUNT), false)
	lu.assertEquals(CurDev:GetCapability(CAP_LOG_ITEM_COUNT_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_LOCK_MODES), false)
	lu.assertEquals(CurDev:GetCapability(CAP_LOCK_MODES_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_LOG_FAILED_ATTEMPTS), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_WRONG_CODE_ATTEMPTS), false)
	lu.assertEquals(CurDev:GetCapability(CAP_WRONG_CODE_ATTEMPTS_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_SHUTOUT_TIMER), false)
	lu.assertEquals(CurDev:GetCapability(CAP_SHUTOUT_TIMER_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_SHUTOUT_TIMER_DISPLAY_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_LANGUAGE), false)
	lu.assertEquals(CurDev:GetCapability(CAP_LANGUAGE_VALUES), "")
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_VOLUME), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_ONE_TOUCH_LOCKING), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_DAILY_SCHEDULE), true)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_DATE_RANGE_SCHEDULE), false)
	lu.assertEquals(CurDev:GetCapability(CAP_MAX_USERS),32)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_SETTINGS), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_CUSTOM_SETTINGS), false)
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_INTERNAL_HISTORY), false)
end

function c4test_LockDeviceClass:c4test_BatteryStatus()
	LogTrace("c4test_LockMain:c4test_BatteryStatus...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(CurDev._BatteryStatus, LBS_NORMAL)

	CurDev:SetBatteryStatus(LBS_WARNING)
	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).BATTERY_STATUS, LBS_WARNING)
	lu.assertEquals(CurDev._BatteryStatus, LBS_WARNING)

	CurDev:SetBatteryStatus(LBS_CRITICAL)
	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(2), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(2).BATTERY_STATUS, LBS_CRITICAL)
	lu.assertEquals(CurDev._BatteryStatus, LBS_CRITICAL)

	CurDev:SetBatteryStatus(LBS_NORMAL)
	lu.assertEquals(CurDev._BatteryStatus, LBS_NORMAL)
	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(3), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(3).BATTERY_STATUS, LBS_NORMAL)
end

function c4test_LockDeviceClass:c4test_UpdateCapability()
	LogTrace("c4test_LockMain:c4test_UpdateCapability...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	lu.assertEquals(CurDev:GetCapability(CAP_HAS_VOLUME), false)
	CurDev:UpdateCapability(CAP_HAS_VOLUME, true)

	lu.assertEquals(CurDev:GetCapability(CAP_HAS_VOLUME), true)

	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "CAPABILITY_CHANGED")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).NAME, "has_volume")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).VALUE, "true")
end

function c4test_LockDeviceClass:c4test_GetHistoryLogCount()
	LogTrace("c4test_LockMain:c4test_GetHistoryLogCount...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(CurDev:GetHistoryLogCount(), 5)
end

function c4test_LockDeviceClass:c4test_AdminCode()
	LogTrace("c4test_LockMain:c4test_AdminCode...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(CurDev:GetAdminCode(), "")
	
	CurDev:SetAdminCode("1234")
	lu.assertEquals(CurDev:GetAdminCode(), "1234")
	
	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).NAME, "admin_code")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).VALUE, "1234")
end

function c4test_LockDeviceClass:c4test_HasInternalHistory()
	LogTrace("c4test_LockMain:c4test_HasInternalHistory...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertFalse(HasInternalHistory())
end

function c4test_LockDeviceClass:c4test_CurrentSetting()
	LogTrace("c4test_LockMain:c4test_CurrentSetting...")
	local CurDev = self:CreateLockDeviceClassInst()

	lu.assertEquals(CurDev:GetCurrentSetting(ST_VOLUME), "high")

	CurDev:UpdateCurrentSetting(ST_VOLUME, "low")
	lu.assertEquals(CurDev:GetCurrentSetting(ST_VOLUME), "low")
	
	LogInfo(C4NotificationMock:GetAllNotifications())
	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).NAME, "volume")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).VALUE, "low")
end

function c4test_LockDeviceClass:c4test_AddDeleteUser()
	LogTrace("c4test_LockMain:c4test_AddDeleteUser...")
	local CurDev = self:CreateLockDeviceClassInst()

	CurDev:AddUser(3)
	lu.assertNotNil(AllUsersInfo[3])
	lu.assertTrue(AllUsersInfo[3]:IsValid())

	CurDev:DeleteUser(3)
	lu.assertFalse(AllUsersInfo[3]:IsValid())

end

function c4test_LockDeviceClass:c4test_UpdateUserInformationNoRest()
	LogTrace("c4test_LockMain:c4test_UpdateUserInformation...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)

	CurDev:UpdateUserInformation(TestUserID, "George", "9876", true, false)
					
	lu.assertEquals(CurUser:GetName(), "George")
	lu.assertEquals(CurUser:GetPassCode(), "9876")
	lu.assertTrue(CurUser:IsValid())
	lu.assertFalse(CurUser:HasRestrictedSchedule())
end

function c4test_LockDeviceClass:c4test_UpdateUserInformationRest()
	LogTrace("c4test_LockMain:c4test_UpdateUserInformation...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)

	CurDev:UpdateUserInformation(TestUserID, "Fred", "5678", true, true, LST_DAILY,
					60, 1380,
					2020, 01, 01,
					2021, 12, 31,
					true, true, true, true, true, true, true)
					
	lu.assertEquals(CurUser:GetName(), "Fred")
	lu.assertEquals(CurUser:GetPassCode(), "5678")
	lu.assertTrue(CurUser:IsValid())
	lu.assertTrue(CurUser:HasRestrictedSchedule())
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
	local StYr, StMo, StDy, EnYr, EnMo, EnDy = CurUser:GetDateRange()
	lu.assertEquals(StYr, 2020)
	lu.assertEquals(StMo, 1)
	lu.assertEquals(StDy, 1)
	lu.assertEquals(EnYr, 2021)
	lu.assertEquals(EnMo, 12)
	lu.assertEquals(EnDy, 31)
end

function c4test_LockDeviceClass:c4test_UserName()
	LogTrace("c4test_LockMain:c4test_UserName...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)
	
	lu.assertEquals(CurUser:GetName(), "User 1")
	CurDev:SetUserName(TestUserID, "Ron")
	lu.assertEquals(CurUser:GetName(), "Ron")
end

function c4test_LockDeviceClass:c4test_PassCode()
	LogTrace("c4test_LockMain:c4test_PassCode...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)
	
	lu.assertEquals(CurUser:GetPassCode(), "")
	CurDev:SetUserPassCode(TestUserID, "3456")
	lu.assertEquals(CurUser:GetPassCode(), "3456")
end

function c4test_LockDeviceClass:c4test_ActiveFlag()
	LogTrace("c4test_LockMain:c4test_ActiveFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)
	
	lu.assertTrue(CurUser:IsActive())
	CurDev:SetUserActiveFlag(TestUserID, false)
	lu.assertFalse(CurUser:IsActive())
	CurDev:SetUserActiveFlag(TestUserID, true)
	lu.assertTrue(CurUser:IsActive())
end

function c4test_LockDeviceClass:c4test_RestrictedScheduleFlag()
	LogTrace("c4test_LockMain:c4test_RestrictedScheduleFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)
	
	lu.assertFalse(CurUser:HasRestrictedSchedule())
	CurDev:SetUserRestrictedScheduleFlag(TestUserID, true)
	lu.assertTrue(CurUser:HasRestrictedSchedule())
	CurDev:SetUserRestrictedScheduleFlag(TestUserID, false)
	lu.assertFalse(CurUser:HasRestrictedSchedule())
end

function c4test_LockDeviceClass:c4test_SetUserDateRange()
	LogTrace("c4test_LockMain:c4test_SetUserDateRange...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)
	
	local StYr, StMo, StDy, EnYr, EnMo, EnDy = CurUser:GetDateRange()
	lu.assertEquals(StYr, 0)
	lu.assertEquals(StMo, 1)
	lu.assertEquals(StDy, 1)
	lu.assertEquals(EnYr, 9999)
	lu.assertEquals(EnMo, 12)
	lu.assertEquals(EnDy, 31)
	
	CurDev:SetUserDateRange(TestUserID, 2022, 3, 4, 2023, 5, 6)
	local StYr2, StMo2, StDy2, EnYr2, EnMo2, EnDy2 = CurUser:GetDateRange()
	lu.assertEquals(StYr2, 2022)
	lu.assertEquals(StMo2, 3)
	lu.assertEquals(StDy2, 4)
	lu.assertEquals(EnYr2, 2023)
	lu.assertEquals(EnMo2, 5)
	lu.assertEquals(EnDy2, 6)
end

function c4test_LockDeviceClass:c4test_SetScheduleType()
	LogTrace("c4test_LockMain:c4test_SetScheduleType...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)
	
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
	CurDev:SetUserScheduleType(TestUserID, LST_DATE_RANGE)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DATE_RANGE)
	CurDev:SetUserScheduleType(TestUserID, LST_DAILY)
	lu.assertEquals(CurUser:GetScheduleType(), LST_DAILY)
end

function c4test_LockDeviceClass:c4test_SetScheduleDays()
	LogTrace("c4test_LockMain:c4test_RestrictedScheduleFlag...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)

	local Su, Mo, Tu, We, Th, Fr, Sa = CurUser:GetScheduleDays()
	lu.assertTrue(Su)
	lu.assertTrue(Mo)
	lu.assertTrue(Tu)
	lu.assertTrue(We)
	lu.assertTrue(Th)
	lu.assertTrue(Fr)
	lu.assertTrue(Sa)

	CurDev:SetUserScheduleDays(TestUserID, true, false, true, false, true, false, true)
	local Su2, Mo2, Tu2, We2, Th2, Fr2, Sa2 = CurUser:GetScheduleDays()
	lu.assertTrue(Su2)
	lu.assertFalse(Mo2)
	lu.assertTrue(Tu2)
	lu.assertFalse(We2)
	lu.assertTrue(Th2)
	lu.assertFalse(Fr2)
	lu.assertTrue(Sa2)

end

function c4test_LockDeviceClass:c4test_SetScheduleDayOfWeek()
	LogTrace("c4test_LockMain:c4test_SetScheduleDayOfWeek...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)

	local Su, Mo, Tu, We, Th, Fr, Sa = CurUser:GetScheduleDays()
	lu.assertTrue(Su)
	lu.assertTrue(Mo)
	lu.assertTrue(Tu)
	lu.assertTrue(We)
	lu.assertTrue(Th)
	lu.assertTrue(Fr)
	lu.assertTrue(Sa)

	CurDev:SetUserScheduleDay(TestUserID, "Tue", false)
	CurDev:SetUserScheduleDay(TestUserID, "Thu", false)
	local Su2, Mo2, Tu2, We2, Th2, Fr2, Sa2 = CurUser:GetScheduleDays()
	lu.assertTrue(Su2)
	lu.assertTrue(Mo2)
	lu.assertFalse(Tu2)
	lu.assertTrue(We2)
	lu.assertFalse(Th2)
	lu.assertTrue(Fr2)
	lu.assertTrue(Sa2)
end

function c4test_LockDeviceClass:c4test_SetUserRestrictedTime()
	LogTrace("c4test_LockMain:c4test_SetUserRestrictedTime...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)

	local SHr, SMi, EHr, EMi = CurUser:GetScheduleTime()
	lu.assertEquals(SHr, 0)
	lu.assertEquals(SMi, 0)
	lu.assertEquals(EHr, 23)
	lu.assertEquals(EMi, 59)
	
	CurDev:SetUserRestrictedTime(TestUserID, 90, 1125)
	local SHr2, SMi2, EHr2, EMi2 = CurUser:GetScheduleTime()
	lu.assertEquals(SHr2, 1)
	lu.assertEquals(SMi2, 30)
	lu.assertEquals(EHr2, 18)
	lu.assertEquals(EMi2, 45)
	
end

function c4test_LockDeviceClass:c4test_PrxLock()
	LogTrace("c4test_LockMain:c4test_PrxLock...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	CurDev:PrxLock()
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Lock")
end

function c4test_LockDeviceClass:c4test_PrxUnlock()
	LogTrace("c4test_LockMain:c4test_PrxUnlock...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	CurDev:PrxUnlock()
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Unlock")
end

function c4test_LockDeviceClass:c4test_PrxToggle()
	LogTrace("c4test_LockMain:c4test_PrxToggle...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	CurDev:SetLockInitialState(LS_UNLOCKED)
	CurDev:PrxToggle()
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Lock")

	CurDev:SetLockInitialState(LS_LOCKED)
	CurDev:PrxToggle()
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Unlock")
end


function c4test_LockDeviceClass:c4test_PrxRequestCapabilities()
	LogTrace("c4test_LockMain:c4test_PrxRequestCapabilities...")
	local CurDev = self:CreateLockDeviceClassInst()

	CurDev:PrxRequestCapabilities()

	lu.assertEquals(C4NotificationMock:GetNotificationCount(), 27)
	
	for NotifyCount = 1, 26 do
		lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(NotifyCount), "CAPABILITY_CHANGED")
	end

	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(27), "SETTING_CHANGED")

	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).NAME, "has_daily_schedule")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1).VALUE, "true")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(2).NAME, "has_admin_code")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(2).VALUE, "true")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(3).NAME, "shutout_timer_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(3).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(4).NAME, "has_wrong_code_attempts")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(4).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(5).NAME, "has_schedule_lockout")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(5).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(6).NAME, "has_custom_settings")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(6).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(7).NAME, "log_item_count_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(7).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(8).NAME, "has_lock_modes")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(8).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(9).NAME, "has_internal_history")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(9).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(10).NAME, "is_management_only")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(10).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(11).NAME, "has_settings")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(11).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(12).NAME, "has_log_item_count")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(12).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(13).NAME, "lock_modes_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(13).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(14).NAME, "auto_lock_time_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(14).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(15).NAME, "has_one_touch_locking")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(15).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(16).NAME, "has_log_failed_attempts")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(16).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(17).NAME, "max_users")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(17).VALUE, "32")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(18).NAME, "auto_lock_time_display_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(18).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(19).NAME, "has_language")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(19).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(20).NAME, "shutout_timer_display_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(20).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(21).NAME, "has_auto_lock_time")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(21).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(22).NAME, "wrong_code_attempts_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(22).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(23).NAME, "has_volume")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(23).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(24).NAME, "language_values")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(24).VALUE, "")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(25).NAME, "has_date_range_schedule")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(25).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(26).NAME, "has_shutout_timer")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(26).VALUE, "false")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(27).NAME, "admin_code")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(27).VALUE, "")
end


function c4test_LockDeviceClass:c4test_PrxRequestSettings()
	LogTrace("c4test_LockMain:c4test_PrxRequestSettings...")
	local CurDev = self:CreateLockDeviceClassInst()

	CurDev:PrxRequestSettings()

	local SettingsXMLStringRef = 
		"<lock_settings>" ..
			"<admin_code></admin_code>" ..
			"<auto_lock_time>0</auto_lock_time>" ..
			"<log_item_count>5</log_item_count>" ..
			"<schedule_lockout_enabled>false</schedule_lockout_enabled>" ..
			"<lock_mode>normal</lock_mode>" ..
			"<log_failed_attempts>false</log_failed_attempts>" ..
			"<wrong_code_attempts>5</wrong_code_attempts>" ..
			"<shutout_timer>30</shutout_timer>" ..
			"<language>English</language>" ..
			"<volume>high</volume>" ..
			"<one_touch_locking>false</one_touch_locking>" ..
		"</lock_settings>"

	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "SETTINGS")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1), SettingsXMLStringRef)
end


function c4test_LockDeviceClass:c4test_PrxRequestCustomSettings()
	LogTrace("c4test_LockMain:c4test_PrxRequestCustomSettings...")
	local CurDev = self:CreateLockDeviceClassInst()

	CurDev:PrxRequestCustomSettings()

	local CustomSettingsXMLStringRef = 
		"<lock_custom_settings>" ..
		"</lock_custom_settings>"

	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "CUSTOM_SETTINGS")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1), CustomSettingsXMLStringRef)
end

function c4test_LockDeviceClass:c4test_PrxRequestHistory()
	LogTrace("c4test_LockMain:c4test_PrxRequestHistory...")
	local CurDev = self:CreateLockDeviceClassInst()

	CurDev:PrxRequestHistory()

	local LockHistoryXMLStringRef = 
		"<lock_history>" ..
		"</lock_history>"

	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "HISTORY")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1), LockHistoryXMLStringRef)
end

function c4test_LockDeviceClass:c4test_PrxRequestUsers()
	LogTrace("c4test_LockMain:c4test_PrxRequestUsers...")
	local CurDev = self:CreateLockDeviceClassInst()
	local TestUserID = 1
	local CurUser = self:CreateUserInst(TestUserID)

	CurDev:PrxRequestUsers()

	local UsersXMLStringRef = 
		"<lock_users>" ..
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
			"</user>" ..
		"</lock_users>"

	lu.assertEquals(C4NotificationMock:GetTargNotificationMessage(1), "USERS")
	lu.assertEquals(C4NotificationMock:GetTargNotificationParams(1), UsersXMLStringRef)
end

function c4test_LockDeviceClass:c4test_PrxEditUser()
	LogTrace("c4test_LockMain:c4test_PrxEditUser...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	local EditUserInfo = {
		USER_ID = 1,
		USER_NAME = "Adam",
		PASSCODE = "7890",
	}
	
	CurDev:PrxEditUser(EditUserInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_EditUser: 1")
end

function c4test_LockDeviceClass:c4test_PrxAddUser()
	LogTrace("c4test_LockMain:c4test_PrxAddUser...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	local AddUserInfo = {
		USER_NAME = "Benjamin",
		PASSCODE = "6789",
	}
	
	CurDev:PrxAddUser(AddUserInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_AddUser: Benjamin")
end

function c4test_LockDeviceClass:c4test_PrxDeleteUser()
	LogTrace("c4test_LockMain:c4test_PrxDeleteUser...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	local DelUserInfo = {
		USER_ID = 3,
	}
	
	CurDev:PrxDeleteUser(DelUserInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_DeleteUser: 3")
end

function c4test_LockDeviceClass:c4test_PrxSetAdminCode()
	LogTrace("c4test_LockMain:c4test_PrxSetAdminCode...")
	local CurDev = self:CreateLockDeviceClassInst()
	
	local AdminCodeInfo = {
		PASSCODE = "2345",
	}
	
	CurDev:PrxSetAdminCode(AdminCodeInfo)

	lu.assertEquals(CurDev:GetAdminCode(), "2345")
	
	lu.assertEquals(C4LogMock:GetLine(4), "UnitTest : SetAdminCode  Old: ||  New: |2345|")
end

function c4test_LockDeviceClass:c4test_PrxScheduleLockoutEnabled()
	LogTrace("c4test_LockMain:c4test_PrxScheduleLockoutEnabled...")
	local CurDev = self:CreateLockDeviceClassInst()

	local EnableInfoT = {
		ENABLED = true,
	}
	
	CurDev:PrxSetScheduleLockoutEnabled(EnableInfoT)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetScheduleLockoutEnabled Set flag to: true")

	local EnableInfoF = {
		ENABLED = false,
	}
	
	CurDev:PrxSetScheduleLockoutEnabled(EnableInfoF)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetScheduleLockoutEnabled Set flag to: false")
end

function c4test_LockDeviceClass:c4test_PrxSetNumberLogItems()
	LogTrace("c4test_LockMain:c4test_PrxSetNumberLogItems...")
	local CurDev = self:CreateLockDeviceClassInst()

	local NumberLogInfo = {
		COUNT = 10,
	}
	
	CurDev:PrxSetNumberLogItems(NumberLogInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetNumberLogItems Count: 10")
end


function c4test_LockDeviceClass:c4test_PrxSetAutoLockSeconds()
	LogTrace("c4test_LockMain:c4test_PrxSetAutoLockSeconds...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockoutSecondsInfo = {
		SECONDS = 25,
	}
	
	CurDev:PrxSetAutoLockSeconds(LockoutSecondsInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetAutoLockSeconds Seconds: 25")
end


function c4test_LockDeviceClass:c4test_PrxSetLockMode()
	LogTrace("c4test_LockMain:c4test_PrxSetLockMode...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockModeInfo = {
		MODE = "High Security",
	}
	
	CurDev:PrxSetLockMode(LockModeInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetLockMode Mode: High Security")
end


function c4test_LockDeviceClass:c4test_PrxSetLogFailedAttempts()
	LogTrace("c4test_LockMain:c4test_PrxSetLogFailedAttempts...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockFailedAttemptsInfo = {
		ENABLED = true,
	}
	
	CurDev:PrxSetLogFailedAttempts(LockFailedAttemptsInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetLogFailedAttempts Flag: true")
end


function c4test_LockDeviceClass:c4test_PrxSetWrongCodeAttempts()
	LogTrace("c4test_LockMain:c4test_PrxSetWrongCodeAttempts...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockWrongAttemptsInfo = {
		COUNT = 15,
	}
	
	CurDev:PrxSetWrongCodeAttempts(LockWrongAttemptsInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetWrongCodeAttempts WrongAttempts: 15")
end


function c4test_LockDeviceClass:c4test_PrxSetShutoutTimer()
	LogTrace("c4test_LockMain:c4test_PrxSetShutoutTimer...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockShutoutTimerInfo = {
		SECONDS = 28,
	}
	
	CurDev:PrxSetShutoutTimer(LockShutoutTimerInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetShutoutTimer ShutoutTimeSeconds: 28")
end

function c4test_LockDeviceClass:c4test_PrxSetLanguage()
	LogTrace("c4test_LockMain:c4test_PrxSetLanguage...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockLanguageInfo = {
		LANGUAGE = "Swahili",
	}
	
	CurDev:PrxSetLanguage(LockLanguageInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetLanguage TargetLanguage: Swahili")
end

function c4test_LockDeviceClass:c4test_PrxSetVolume()
	LogTrace("c4test_LockMain:c4test_PrxSetVolume...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockVolumeInfo = {
		VOLUME = "Low",
	}
	
	CurDev:PrxSetVolume(LockVolumeInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetVolume TargetVolume: Low")
end


function c4test_LockDeviceClass:c4test_PrxSetOneTouchLocking()
	LogTrace("c4test_LockMain:c4test_PrxSetOneTouchLocking...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockOneTouchInfo = {
		ENABLED = "true",
	}
	
	CurDev:PrxSetOneTouchLocking(LockOneTouchInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetOneTouchLocking AllowOneTouchLocking: true")
end


function c4test_LockDeviceClass:c4test_PrxSetCustomSetting()
	LogTrace("c4test_LockMain:c4test_PrxSetCustomSetting...")
	local CurDev = self:CreateLockDeviceClassInst()

	local LockCustomSettingInfo = {
		NAME = "Cover Pattern",
		VALUE = "Plaid",
	}
	
	CurDev:PrxSetCustomSetting(LockCustomSettingInfo)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetCustomSetting  Set Cover Pattern to Plaid")
end


