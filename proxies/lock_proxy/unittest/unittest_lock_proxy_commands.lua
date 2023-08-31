--[[==============================================================
	File is: unittest_lock_proxy_commands.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'
--require 'lock_device_class'

c4test_LockProxyCommands = {}

function c4test_LockProxyCommands:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()
	TheLock = LockDevice:new(DEFAULT_PROXY_BINDINGID)
	TheLock:InitialSetup()
end


function c4test_LockProxyCommands:tearDown()
	TheLock = nil
end

function c4test_LockProxyCommands:CreateUserInst(UserID)
	TheLock:AddUser(UserID)
	return AllUsersInfo[UserID]
end


-------------------------------------------------------------------------------------------------

function c4test_LockProxyCommands:c4test_PrxCmdLock()
	LogTrace("c4test_LockProxyCommands:c4test_PrxCmdLock...")

	PRX_CMD.LOCK(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Lock")
end

function c4test_LockProxyCommands:c4test_PrxCmdUnlock()
	LogTrace("c4test_LockProxyCommands:c4test_PrxCmdUnlock...")

	PRX_CMD.UNLOCK(DEFAULT_PROXY_BINDINGID, {})

	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Unlock")
end

function c4test_LockProxyCommands:c4test_PrxCmdToggle()
	LogTrace("c4test_LockProxyCommands:c4test_PrxCmdToggle...")

	PRX_CMD.TOGGLE(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Lock")

	TheLock:SetLockInitialState(LS_LOCKED)

	PRX_CMD.TOGGLE(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_Unlock")
end

function c4test_LockProxyCommands:c4test_PrxRequestCapabilities()
	LogTrace("c4test_LockProxyCommands:c4test_PrxRequestCapabilities...")

	PRX_CMD.REQUEST_CAPABILITIES(DEFAULT_PROXY_BINDINGID, {})
	
	local AllNotificationTab = C4NotificationMock:GetAllNotifications()
	lu.assertEquals(#AllNotificationTab, 27)
	
	local CapabilityRefTab = {
		{ Name = "has_daily_schedule", Value = "true" }, 
		{ Name = "has_admin_code", Value = "true" }, 
		{ Name = "shutout_timer_values", Value = "" }, 
		{ Name = "has_wrong_code_attempts", Value = "false" }, 
		{ Name = "has_schedule_lockout", Value = "false" }, 
		{ Name = "has_custom_settings", Value = "false" }, 
		{ Name = "log_item_count_values", Value = "" }, 
		{ Name = "has_lock_modes", Value = "false" }, 
		{ Name = "has_internal_history", Value = "false" }, 
		{ Name = "is_management_only", Value = "false" }, 
		{ Name = "has_settings", Value = "false" }, 
		{ Name = "has_log_item_count", Value = "false" }, 
		{ Name = "lock_modes_values", Value = "" }, 
		{ Name = "auto_lock_time_values", Value = "" }, 
		{ Name = "has_one_touch_locking", Value = "false" }, 
		{ Name = "has_log_failed_attempts", Value = "false" }, 
		{ Name = "max_users", Value = "32" }, 
		{ Name = "auto_lock_time_display_values", Value = "" }, 
		{ Name = "has_language", Value = "false" }, 
		{ Name = "shutout_timer_display_values", Value = "" }, 
		{ Name = "has_auto_lock_time", Value = "false" }, 
		{ Name = "wrong_code_attempts_values", Value = "" }, 
		{ Name = "has_volume", Value = "false" }, 
		{ Name = "language_values", Value = "" }, 
		{ Name = "has_date_range_schedule", Value = "false" }, 
		{ Name = "has_shutout_timer", Value = "false" }, 
	}
	
	for CIndex = 1, 26 do
		CurNotify = AllNotificationTab[CIndex]
		CurRef = CapabilityRefTab[CIndex]

		lu.assertEquals(CurNotify.Message, "CAPABILITY_CHANGED")
		lu.assertEquals(CurNotify.Params.NAME, CurRef.Name)
		lu.assertEquals(CurNotify.Params.VALUE, CurRef.Value)
	end
	
	lu.assertEquals(AllNotificationTab[27].Message, "SETTING_CHANGED")
	lu.assertEquals(AllNotificationTab[27].Params.NAME, "admin_code")
	lu.assertEquals(AllNotificationTab[27].Params.VALUE, "")
end


function c4test_LockProxyCommands:c4test_PrxRequestSettings()
	LogTrace("c4test_LockProxyCommands:c4test_PrxRequestSettings...")

	PRX_CMD.REQUEST_SETTINGS(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "SETTINGS")

	local SettingsRefStr = 
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

	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), SettingsRefStr)
end

function c4test_LockProxyCommands:c4test_PrxRequestCustomSettings()
	LogTrace("c4test_LockProxyCommands:c4test_PrxRequestCustomSettings...")

	PRX_CMD.REQUEST_CUSTOM_SETTINGS(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTINGS")

	local CustomSettingsRefStr = 
		"<lock_custom_settings>" ..
		"</lock_custom_settings>"

	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), CustomSettingsRefStr)
end

function c4test_LockProxyCommands:c4test_PrxRequestHistory()
	LogTrace("c4test_LockProxyCommands:c4test_PrxRequestHistory...")

	PRX_CMD.REQUEST_HISTORY(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "HISTORY")

	local HistoryRefStr = 
		"<lock_history>" ..
		"</lock_history>"

	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), HistoryRefStr)
end

function c4test_LockProxyCommands:c4test_PrxRequestUsers()
	LogTrace("c4test_LockProxyCommands:c4test_PrxRequestUsers...")

	self:CreateUserInst(1)

	PRX_CMD.REQUEST_USERS(DEFAULT_PROXY_BINDINGID, {})
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "USERS")

	local UserRefStr = 
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

	lu.assertEquals(C4NotificationMock:GetLastNotificationParams(), UserRefStr)
	
	-- C4LogMock:PrintAllLines()
	-- LogInfo(C4NotificationMock:GetAllNotifications())
end

function c4test_LockProxyCommands:c4test_PrxEditUser()
	LogTrace("c4test_LockProxyCommands:c4test_PrxEditUser...")

	local EditUserTab = {
		USER_ID = 1,
		USER_NAME = "Kate",
		-- other things could be here
	}

	PRX_CMD.EDIT_USER(DEFAULT_PROXY_BINDINGID, EditUserTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_EditUser: 1")
end

function c4test_LockProxyCommands:c4test_PrxAddUser()
	LogTrace("c4test_LockProxyCommands:c4test_PrxAddUser...")

	local AddUserTab = {
		USER_NAME = "Louis",
		PASSCODE = "9090",
		IS_ACTIVE = "true",
		-- other things could be here
	}

	PRX_CMD.ADD_USER(DEFAULT_PROXY_BINDINGID, AddUserTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_AddUser: Louis")
end

function c4test_LockProxyCommands:c4test_PrxDeleteUser()
	LogTrace("c4test_LockProxyCommands:c4test_PrxDeleteUser...")

	local DeleteUserTab = {
		USER_ID = 1,
	}

	PRX_CMD.DELETE_USER(DEFAULT_PROXY_BINDINGID, DeleteUserTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_DeleteUser: 1")
end

function c4test_LockProxyCommands:c4test_PrxSetAdminCode()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetAdminCode...")

	local AdminCodeTab = {
		PASSCODE = "4545",
	}

	PRX_CMD.SET_ADMIN_CODE(SET_ADMIN_CODE, AdminCodeTab)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, "admin_code")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "4545")
end

function c4test_LockProxyCommands:c4test_PrxSetScheduleLockoutEnabled()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetScheduleLockoutEnabled...")

	local ScheduleLockoutTab = {
		ENABLED = "true",
	}

	PRX_CMD.SET_SCHEDULE_LOCKOUT_ENABLED(DEFAULT_PROXY_BINDINGID, ScheduleLockoutTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetScheduleLockoutEnabled Set flag to: true")
end

function c4test_LockProxyCommands:c4test_PrxSetNumberLogItems()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetNumberLogItems...")

	local NumberLogItemsTab = {
		COUNT = "10",
	}

	PRX_CMD.SET_NUMBER_LOG_ITEMS(DEFAULT_PROXY_BINDINGID, NumberLogItemsTab)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, "log_item_count")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "10")
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetNumberLogItems Count: 10")
end

function c4test_LockProxyCommands:c4test_PrxSetAutoLockSeconds()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetAutoLockSeconds...")

	local AutoLockSecondsTab = {
		SECONDS = "25",
	}

	PRX_CMD.SET_AUTO_LOCK_SECONDS(DEFAULT_PROXY_BINDINGID, AutoLockSecondsTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetAutoLockSeconds Seconds: 25")
end

function c4test_LockProxyCommands:c4test_PrxSetLockMode()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetLockMode...")

	local LockModeTab = {
		MODE = "Paranoid",
	}

	PRX_CMD.SET_LOCK_MODE(DEFAULT_PROXY_BINDINGID, LockModeTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetLockMode Mode: Paranoid")
end

function c4test_LockProxyCommands:c4test_PrxSetLogFailedAttempts()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetLogFailedAttempts...")

	local FailedAttemptsTab = {
		ENABLED = "true",
	}

	PRX_CMD.SET_LOG_FAILED_ATTEMPTS(DEFAULT_PROXY_BINDINGID, FailedAttemptsTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetLogFailedAttempts Flag: true")
end

function c4test_LockProxyCommands:c4test_PrxSetWrongCodeAttempts()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetWrongCodeAttempts...")

	local WrongCodeAttemptsTab = {
		COUNT = "19",
	}

	PRX_CMD.SET_WRONG_CODE_ATTEMPTS(DEFAULT_PROXY_BINDINGID, WrongCodeAttemptsTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetWrongCodeAttempts WrongAttempts: 19")
end

function c4test_LockProxyCommands:c4test_PrxSetShutoutTimer()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetShutoutTimer...")

	local ShutoutTimerTab = {
		SECONDS = "33",
	}

	PRX_CMD.SET_SHUTOUT_TIMER(DEFAULT_PROXY_BINDINGID, ShutoutTimerTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetShutoutTimer ShutoutTimeSeconds: 33")
end


function c4test_LockProxyCommands:c4test_PrxSetLanguage()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetLanguage...")

	local LanguageTab = {
		LANGUAGE = "Klingon",
	}

	PRX_CMD.SET_LANGUAGE(DEFAULT_PROXY_BINDINGID, LanguageTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetLanguage TargetLanguage: Klingon")
end

function c4test_LockProxyCommands:c4test_PrxSetVolume()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetVolume...")

	local VolumeTab = {
		VOLUME = "Quiet",
	}

	PRX_CMD.SET_VOLUME(DEFAULT_PROXY_BINDINGID, VolumeTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetVolume TargetVolume: Quiet")
end

function c4test_LockProxyCommands:c4test_PrxSetOneTouchLocking()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetOneTouchLocking...")

	local OneTouchLockingTab = {
		ENABLED = "true",
	}

	PRX_CMD.SET_ONE_TOUCH_LOCKING(DEFAULT_PROXY_BINDINGID, OneTouchLockingTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetOneTouchLocking AllowOneTouchLocking: true")
end

function c4test_LockProxyCommands:c4test_PrxSetCustomSetting()
	LogTrace("c4test_LockProxyCommands:c4test_PrxSetCustomSetting...")

	local CustomSettingTab = {
		NAME = "ArtMode",
		VALUE = "Deco",
	}

	PRX_CMD.SET_CUSTOM_SETTING(DEFAULT_PROXY_BINDINGID, CustomSettingTab)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCom_SetCustomSetting  Set ArtMode to Deco")
end



