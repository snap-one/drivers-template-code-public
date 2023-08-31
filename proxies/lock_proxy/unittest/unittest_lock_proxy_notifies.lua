--[[==============================================================
	File is: unittest_lock_proxy_notifies.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_reports'

c4test_LockProxyNotifies = {}

function c4test_LockProxyNotifies:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()
end

function c4test_LockProxyNotifies:tearDown()
end


-----------------------------------------------------------------------------------

function c4test_LockProxyNotifies:c4test_LockStatusInitialize()
	LogTrace("c4test_LockProxyNotifies:c4test_LockStatusInitialize...")

	NOTIFY.LOCK_STATUS_INITIALIZE(LS_LOCKED, DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_INITIALIZE")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "locked")
end

function c4test_LockProxyNotifies:c4test_LockStatusChanged()
	LogTrace("c4test_LockProxyNotifies:c4test_LockStatusChanged...")

	NOTIFY.LOCK_STATUS_CHANGED(LS_UNLOCKED, "Manual Unlock", "TestSys", true, DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "LOCK_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LOCK_STATUS, "unlocked")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().LAST_ACTION_DESCRIPTION, "Manual Unlock")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SOURCE, "TestSys")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().MANUAL, true)
end

function c4test_LockProxyNotifies:c4test_BatteryStatusChanged()
	LogTrace("c4test_LockProxyNotifies:c4test_BatteryStatusChanged...")

	NOTIFY.BATTERY_STATUS_CHANGED("Super Charged", DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "BATTERY_STATUS_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().BATTERY_STATUS, "Super Charged")
end

function c4test_LockProxyNotifies:c4test_Settings()
	LogTrace("c4test_LockProxyNotifies:c4test_Settings...")

	NOTIFY.SETTINGS("8787", 35, 15, 			-- AdminCode, AutoLockTime, LogItemCount, 
					true, "lenient", true,		-- ScheduleLockoutEnabled, LockMode, LogFailedAttempts,
					8, 45,						-- WrongCodeAttempts, ShutDownTime,
					"Martian", "medium", true,	-- Language, Volume, OneTouchLockingEnabled,
					DEFAULT_PROXY_BINDINGID)
					
	local SettingsRefStr = 
		"<lock_settings>" ..
			"<admin_code>8787</admin_code>" ..
			"<auto_lock_time>35</auto_lock_time>" ..
			"<log_item_count>15</log_item_count>" ..
			"<schedule_lockout_enabled>true</schedule_lockout_enabled>" ..
			"<lock_mode>lenient</lock_mode>" ..
			"<log_failed_attempts>true</log_failed_attempts>" ..
			"<wrong_code_attempts>8</wrong_code_attempts>" ..
			"<shutout_timer>45</shutout_timer>" ..
			"<language>Martian</language>" ..
			"<volume>medium</volume>" ..
			"<one_touch_locking>true</one_touch_locking>" ..
		"</lock_settings>"
						 
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "SETTINGS")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), SettingsRefStr)
	-- C4LogMock:PrintAllLines()
	-- LogInfo(C4NotificationMock:GetAllNotifications())
end

function c4test_LockProxyNotifies:c4test_CapabilityChanged()
	LogTrace("c4test_LockProxyNotifies:c4test_CapabilityChanged...")

	NOTIFY.CAPABILITY_CHANGED(CAP_MAX_USERS, 50, DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CAPABILITY_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, CAP_MAX_USERS)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "50")
end

function c4test_LockProxyNotifies:c4test_SettingChanged()
	LogTrace("c4test_LockProxyNotifies:c4test_SettingChanged...")

	NOTIFY.SETTING_CHANGED(ST_LANGUAGE, "Romulan", DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, ST_LANGUAGE)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "Romulan")
end

function c4test_LockProxyNotifies:c4test_CustomSettings()
	LogTrace("c4test_LockProxyNotifies:c4test_CustomSettings...")

	local CustomSettingsXMLStr = 
		"<lock_custom_settings>" ..
		"</lock_custom_settings>"

	NOTIFY.CUSTOM_SETTINGS(CustomSettingsXMLStr, DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTINGS")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), CustomSettingsXMLStr)
end

function c4test_LockProxyNotifies:c4test_CustomSettingChanged()
	LogTrace("c4test_LockProxyNotifies:c4test_CustomSettingChanged...")

	NOTIFY.CUSTOM_SETTING_CHANGED("Mascot", "Lemmings", DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, "Mascot")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "Lemmings")
end

function c4test_LockProxyNotifies:c4test_History()
	LogTrace("c4test_LockProxyNotifies:c4test_History...")

	local HistoryXMLStr = 
		"<lock_history>" ..
		"</lock_history>"

	NOTIFY.HISTORY(HistoryXMLStr, DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "HISTORY")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), HistoryXMLStr)
end

function c4test_LockProxyNotifies:c4test_Users()
	LogTrace("c4test_LockProxyNotifies:c4test_Users...")

	local UsersXMLStr = 
		"<lock_users>" ..
		"</lock_users>"

	NOTIFY.USERS(UsersXMLStr, DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USERS")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), UsersXMLStr)
end

function c4test_LockProxyNotifies:c4test_UserChanged()
	LogTrace("c4test_LockProxyNotifies:c4test_UserChanged...")


	NOTIFY.USER_CHANGED(	2, "Maxwell", "3838",		-- UserID, UserName, PassCode, 
							true, "Sun,Mon,Tue",		-- IsActive, ScheduleDays,
							31, 10, 2010,				-- StartDay, StartMonth, StartYear,
							30, 4, 2012,				-- EndDay, EndMonth, EndYear,
							600, 1200,					-- StartTime, EndTime,
							LST_DATE_RANGE, true,		-- ScheduleType, IsRestrictedSchedule,
							DEFAULT_PROXY_BINDINGID)
	
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USER_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_ID, 2)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_NAME, "Maxwell")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().PASSCODE, "3838")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().IS_ACTIVE, true)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SCHEDULED_DAYS, "Sun,Mon,Tue")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_DAY, 31)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_MONTH, 10)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_YEAR, 2010)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_DAY, 30)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_MONTH, 4)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_YEAR, 2012)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_TIME, 600)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_TIME, 1200)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SCHEDULE_TYPE, LST_DATE_RANGE)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().IS_RESTRICTED_SCHEDULE, true)
end

function c4test_LockProxyNotifies:c4test_UserAdded()
	LogTrace("c4test_LockProxyNotifies:c4test_UserAdded...")

	NOTIFY.USER_ADDED(	6, "Nancy", "4646", 	-- UserID, UserName, PassCode, 
						true, "Wed,Thu,Fri", 	-- IsActive, ScheduleDays,
						31, 7, 2013,			-- StartDay, StartMonth, StartYear,
						28, 2, 2014,			-- EndDay, EndMonth, EndYear,
						700, 1400,				-- StartTime, EndTime,
						LST_DAILY, true,		-- ScheduleType, IsRestrictedSchedule,
						DEFAULT_PROXY_BINDINGID)	

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USER_ADDED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_ID, 6)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_NAME, "Nancy")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().PASSCODE, "4646")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().IS_ACTIVE, true)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SCHEDULED_DAYS, "Wed,Thu,Fri")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_DAY, 31)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_MONTH, 7)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_YEAR, 2013)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_DAY, 28)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_MONTH, 2)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_YEAR, 2014)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().START_TIME, 700)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().END_TIME, 1400)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().SCHEDULE_TYPE, LST_DAILY)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().IS_RESTRICTED_SCHEDULE, true)
end

function c4test_LockProxyNotifies:c4test_UserDeleted()
	LogTrace("c4test_LockProxyNotifies:c4test_UserDeleted...")

	NOTIFY.USER_DELETED(5, "Oraville", DEFAULT_PROXY_BINDINGID)

	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USER_DELETED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_ID, 5)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().USER_NAME, "Oraville")
end

