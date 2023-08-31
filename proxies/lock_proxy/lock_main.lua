--[[=============================================================================
    File is: lock_main.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lock_proxy.lock_device_class"
require "lock_proxy.lock_reports"
require "lock_proxy.lock_apis"
require "lock_communicator"	

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_main = "2021.09.22"
end

-- defined capabilities
CAP_IS_MANAGEMENT_ONLY				= "is_management_only"
CAP_HAS_ADMIN_CODE					= "has_admin_code"
CAP_HAS_SCHEDULE_LOCKOUT			= "has_schedule_lockout"
CAP_HAS_AUTO_LOCK_TIME				= "has_auto_lock_time"
CAP_AUTO_LOCK_TIME_VALUES			= "auto_lock_time_values"
CAP_AUTO_LOCK_TIME_DISPLAY_VALUES	= "auto_lock_time_display_values"
CAP_HAS_LOG_ITEM_COUNT				= "has_log_item_count"
CAP_LOG_ITEM_COUNT_VALUES			= "log_item_count_values"
CAP_HAS_LOCK_MODES					= "has_lock_modes"
CAP_LOCK_MODES_VALUES				= "lock_modes_values"
CAP_HAS_LOG_FAILED_ATTEMPTS			= "has_log_failed_attempts"
CAP_HAS_WRONG_CODE_ATTEMPTS			= "has_wrong_code_attempts"
CAP_WRONG_CODE_ATTEMPTS_VALUES		= "wrong_code_attempts_values"
CAP_HAS_SHUTOUT_TIMER				= "has_shutout_timer"
CAP_SHUTOUT_TIMER_VALUES			= "shutout_timer_values"
CAP_SHUTOUT_TIMER_DISPLAY_VALUES	= "shutout_timer_display_values"
CAP_HAS_LANGUAGE					= "has_language"
CAP_LANGUAGE_VALUES					= "language_values"
CAP_HAS_VOLUME						= "has_volume"
CAP_HAS_ONE_TOUCH_LOCKING			= "has_one_touch_locking"
CAP_HAS_DAILY_SCHEDULE				= "has_daily_schedule"
CAP_HAS_DATE_RANGE_SCHEDULE			= "has_date_range_schedule"
CAP_MAX_USERS						= "max_users"
CAP_HAS_SETTINGS					= "has_settings"
CAP_HAS_CUSTOM_SETTINGS				= "has_custom_settings"
CAP_HAS_INTERNAL_HISTORY			= "has_internal_history"


-- defined settings
ST_AUTO_LOCK_TIME			= "auto_lock_time"
ST_LOG_ITEM_COUNT			= "log_item_count"
ST_SCHEDULE_LOCKOUT_ENABLED	= "schedule_lockout_enabled"
ST_LOCK_MODE				= "lock_mode"
ST_LOG_FAILED_ATTEMPTS		= "log_failed_attempts"
ST_WRONG_CODE_ATTEMPTS		= "wrong_code_attempts"
ST_SHUTOUT_TIMER			= "shutout_timer"
ST_LANGUAGE					= "language"
ST_VOLUME					= "volume"
ST_ONE_TOUCH_LOCKING		= "one_touch_locking"

-- possible lock states
LS_UNKNOWN = "unknown"
LS_LOCKED = "locked"
LS_UNLOCKED = "unlocked"
LS_FAULT = "fault"

-- Schedule Types
LST_DAILY = "daily"
LST_DATE_RANGE = "date_range"


-- possible battery statuses
LBS_NORMAL = "normal"
LBS_WARNING = "warning"
LBS_CRITICAL = "critical"

TheLock = nil		-- can only have one lock in a driver for now.  This could change


function CreateLockProxy(BindingID, ProxyInstanceName)
	if(TheLock == nil) then
		TheLock = LockDevice:new(BindingID, ProxyInstanceName)
		LockCustomSettings:SetBindingID(BindingID)
		
		if(TheLock ~= nil) then
			TheLock:InitialSetup()

			local MaxUserCount = TheLock:GetMaxUsers()
			for UserIndex = 1, MaxUserCount do
				LockUserInfo:new(UserIndex)
			end
		else
			LogFatal("CreateLockProxy  Failed to instantiate lock on binding %d", BindingID)
		end
	end
end

