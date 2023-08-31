--[[==============================================================
	File is: unittest_lock_main.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'

c4test_LockMain = {}

function c4test_LockMain:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()

	self._CurrentDevice = nil
end

function c4test_LockMain:tearDown()
	if(self._CurrentDevice ~= nil) then
		self._CurrentDevice:destruct()
	end
	
	self._CurrentDevice = nil
end


function c4test_LockMain:c4test_LockStrings()
	LogTrace("c4test_LockMain:c4test_LockStrings...")
	--local CurDev = self:CreateRoomDeviceInst()
	--LogInfo(self._CurrentDevice)
	
	lu.assertEquals(CAP_IS_MANAGEMENT_ONLY,				"is_management_only")
	lu.assertEquals(CAP_HAS_ADMIN_CODE,					"has_admin_code")
	lu.assertEquals(CAP_HAS_SCHEDULE_LOCKOUT,			"has_schedule_lockout")
	lu.assertEquals(CAP_HAS_AUTO_LOCK_TIME,				"has_auto_lock_time")
	lu.assertEquals(CAP_AUTO_LOCK_TIME_VALUES,			"auto_lock_time_values")
	lu.assertEquals(CAP_AUTO_LOCK_TIME_DISPLAY_VALUES,	"auto_lock_time_display_values")
	lu.assertEquals(CAP_HAS_LOG_ITEM_COUNT,				"has_log_item_count")
	lu.assertEquals(CAP_LOG_ITEM_COUNT_VALUES,			"log_item_count_values")
	lu.assertEquals(CAP_HAS_LOCK_MODES,					"has_lock_modes")
	lu.assertEquals(CAP_LOCK_MODES_VALUES,				"lock_modes_values")
	lu.assertEquals(CAP_HAS_LOG_FAILED_ATTEMPTS,		"has_log_failed_attempts")
	lu.assertEquals(CAP_HAS_WRONG_CODE_ATTEMPTS,		"has_wrong_code_attempts")
	lu.assertEquals(CAP_WRONG_CODE_ATTEMPTS_VALUES,		"wrong_code_attempts_values")
	lu.assertEquals(CAP_HAS_SHUTOUT_TIMER,				"has_shutout_timer")
	lu.assertEquals(CAP_SHUTOUT_TIMER_VALUES,			"shutout_timer_values")
	lu.assertEquals(CAP_SHUTOUT_TIMER_DISPLAY_VALUES,	"shutout_timer_display_values")
	lu.assertEquals(CAP_HAS_LANGUAGE,					"has_language")
	lu.assertEquals(CAP_LANGUAGE_VALUES,				"language_values")
	lu.assertEquals(CAP_HAS_VOLUME,						"has_volume")
	lu.assertEquals(CAP_HAS_ONE_TOUCH_LOCKING,			"has_one_touch_locking")
	lu.assertEquals(CAP_HAS_DAILY_SCHEDULE,				"has_daily_schedule")
	lu.assertEquals(CAP_HAS_DATE_RANGE_SCHEDULE,		"has_date_range_schedule")
	lu.assertEquals(CAP_MAX_USERS,						"max_users")
	lu.assertEquals(CAP_HAS_SETTINGS,					"has_settings")
	lu.assertEquals(CAP_HAS_CUSTOM_SETTINGS,			"has_custom_settings")
	lu.assertEquals(CAP_HAS_INTERNAL_HISTORY,			"has_internal_history")
	
	lu.assertEquals(ST_AUTO_LOCK_TIME,				"auto_lock_time")
	lu.assertEquals(ST_LOG_ITEM_COUNT,				"log_item_count")
	lu.assertEquals(ST_SCHEDULE_LOCKOUT_ENABLED,	"schedule_lockout_enabled")
	lu.assertEquals(ST_LOCK_MODE,					"lock_mode")
	lu.assertEquals(ST_LOG_FAILED_ATTEMPTS,			"log_failed_attempts")
	lu.assertEquals(ST_WRONG_CODE_ATTEMPTS,			"wrong_code_attempts")
	lu.assertEquals(ST_SHUTOUT_TIMER,				"shutout_timer")
	lu.assertEquals(ST_LANGUAGE,					"language")
	lu.assertEquals(ST_VOLUME,						"volume")
	lu.assertEquals(ST_ONE_TOUCH_LOCKING,			"one_touch_locking")
	
	lu.assertEquals(LS_UNKNOWN,		"unknown")
	lu.assertEquals(LS_LOCKED,		"locked")
	lu.assertEquals(LS_UNLOCKED,	"unlocked")
	lu.assertEquals(LS_FAULT,		"fault")
	
	lu.assertEquals(LST_DAILY,		"daily")
	lu.assertEquals(LST_DATE_RANGE,	"date_range")
	
	lu.assertEquals(LBS_NORMAL,		"normal")
	lu.assertEquals(LBS_WARNING,	"warning")
	lu.assertEquals(LBS_CRITICAL,	"critical")
end


function c4test_LockMain:c4test_LockSetup()
	LogTrace("c4test_LockMain:c4test_LockSetup...")

	ON_DRIVER_INIT.LockProxySupport()
	lu.assertNotEquals(TheLock,	nil)
	
end
