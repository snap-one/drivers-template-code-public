--[[=============================================================================
    Notification Functions sent to the Lock proxy from the driver

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_notify"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_proxy_notifies = "2020.04.03"
end


function NOTIFY.LOCK_STATUS_INITIALIZE(LockStatus, BindingID)
	LogTrace("NOTIFY.LOCK_STATUS_INITIALIZE")

	LockStatusParms = {}
	LockStatusParms["LOCK_STATUS"] = tostring(LockStatus)

	SendNotify("LOCK_STATUS_INITIALIZE", LockStatusParms, BindingID)
end


function NOTIFY.LOCK_STATUS_CHANGED(LockStatus, LastAction, Source, Manual, BindingID)
	LogTrace("NOTIFY.LOCK_STATUS_CHANGED")

	LockStatusParms = {}
	LockStatusParms["LOCK_STATUS"] = tostring(LockStatus)
	LockStatusParms["LAST_ACTION_DESCRIPTION"] = tostring(LastAction)
	LockStatusParms["SOURCE"] = tostring(Source)
	LockStatusParms["MANUAL"] = Manual

	SendNotify("LOCK_STATUS_CHANGED", LockStatusParms, BindingID)
end


function NOTIFY.BATTERY_STATUS_CHANGED(NewBatteryStatus, BindingID)
	LogTrace("NOTIFY.BATTERY_STATUS_CHANGED")

	local BatteryStatusParams = {}
	BatteryStatusParams.BATTERY_STATUS = NewBatteryStatus

	SendNotify("BATTERY_STATUS_CHANGED", BatteryStatusParams, BindingID)
end


function NOTIFY.SETTINGS(AdminCode, AutoLockTime, LogItemCount, 
						 ScheduleLockoutEnabled, LockMode, LogFailedAttempts,
						 WrongCodeAttempts, ShutDownTime,
						 Language, Volume, OneTouchLockingEnabled,
						 BindingID)
	LogTrace("NOTIFY.SETTINGS")
	
	local SettingsXMLString = MakeXMLNode("lock_settings",
		MakeXMLNode("admin_code",				tostring(AdminCode)) ..
		MakeXMLNode("auto_lock_time",			tostring(AutoLockTime)) ..
		MakeXMLNode("log_item_count",			tostring(LogItemCount)) ..
		MakeXMLNode("schedule_lockout_enabled",	tostring(ScheduleLockoutEnabled)) ..
		MakeXMLNode("lock_mode",				tostring(LockMode)) ..
		MakeXMLNode("log_failed_attempts",		tostring(LogFailedAttempts)) ..
		MakeXMLNode("wrong_code_attempts",		tostring(WrongCodeAttempts)) ..
		MakeXMLNode("shutout_timer",			tostring(ShutDownTime)) ..
		MakeXMLNode("language",					tostring(Language)) ..
		MakeXMLNode("volume",					tostring(Volume)) ..
		MakeXMLNode("one_touch_locking",		tostring(OneTouchLockingEnabled))
	)
	
	SendNotify("SETTINGS", SettingsXMLString, BindingID)
end


function NOTIFY.CAPABILITY_CHANGED(CapabilityName, CapabilityValue, BindingID)
	LogTrace("NOTIFY.CAPABILITY_CHANGED")

	CapabilityParms = {}
	CapabilityParms["NAME"] = tostring(CapabilityName)
	CapabilityParms["VALUE"] = tostring(CapabilityValue)
	
	SendNotify("CAPABILITY_CHANGED", CapabilityParms, BindingID)
end



function NOTIFY.SETTING_CHANGED(SettingName, SettingValue, BindingID)
	LogTrace("NOTIFY.SETTING_CHANGED")

	LockSettingParms = {}
	LockSettingParms["NAME"] = tostring(SettingName)
	LockSettingParms["VALUE"] = tostring(SettingValue)
	
	SendNotify("SETTING_CHANGED", LockSettingParms, BindingID)
end


function NOTIFY.CUSTOM_SETTINGS(CustomSettingsXMLDataStr, BindingID)
	LogTrace("NOTIFY.CUSTOM_SETTINGS: %s", tostring(CustomSettingsXMLDataStr))
	SendNotify("CUSTOM_SETTINGS", CustomSettingsXMLDataStr, BindingID)
end


function NOTIFY.CUSTOM_SETTING_CHANGED(SettingName, SettingValue, BindingID)
	LogTrace("NOTIFY.CUSTOM_SETTING_CHANGED")

	CustomSettingParms = {}
	CustomSettingParms["NAME"] = tostring(SettingName)
	CustomSettingParms["VALUE"] = tostring(SettingValue)
	
	SendNotify("CUSTOM_SETTING_CHANGED", CustomSettingParms, BindingID)
end


function NOTIFY.HISTORY(HistorXMLDataStr, BindingID)
	LogTrace("NOTIFY.HISTORY: %s", HistorXMLDataStr)
	SendNotify("HISTORY", HistorXMLDataStr, BindingID)
end


function NOTIFY.USERS(UsersXMLDataStr, BindingID)
	LogTrace("NOTIFY.USERS")
--	LogDev(UsersXMLDataStr)
	
	SendNotify("USERS", UsersXMLDataStr, BindingID)
end


function NOTIFY.USER_CHANGED(	UserID, UserName, PassCode, 
								IsActive, ScheduleDays,
								StartDay, StartMonth, StartYear,
								EndDay, EndMonth, EndYear,
								StartTime, EndTime,
								ScheduleType, IsRestrictedSchedule,
								BindingID)
	LogTrace("NOTIFY.USER_CHANGED")
	
	UserChangeParms = {}
	UserChangeParms["USER_ID"] = UserID
	UserChangeParms["USER_NAME"] = UserName
	UserChangeParms["PASSCODE"] = PassCode
	UserChangeParms["IS_ACTIVE"] = IsActive
	UserChangeParms["SCHEDULED_DAYS"] = ScheduleDays
	UserChangeParms["START_DAY"] = StartDay
	UserChangeParms["START_MONTH"] = StartMonth
	UserChangeParms["START_YEAR"] = StartYear
	UserChangeParms["END_DAY"] = EndDay
	UserChangeParms["END_MONTH"] = EndMonth
	UserChangeParms["END_YEAR"] = EndYear
	UserChangeParms["START_TIME"] = StartTime
	UserChangeParms["END_TIME"] = EndTime
	UserChangeParms["SCHEDULE_TYPE"] = ScheduleType
	UserChangeParms["IS_RESTRICTED_SCHEDULE"] = IsRestrictedSchedule
--	LogDev(UserChangeParms)
	
	SendNotify("USER_CHANGED", UserChangeParms, BindingID)
end


function NOTIFY.USER_ADDED(	UserID, UserName, PassCode, 
							IsActive, ScheduleDays,
							StartDay, StartMonth, StartYear,
							EndDay, EndMonth, EndYear,
							StartTime, EndTime,
							ScheduleType, IsRestrictedSchedule,
							BindingID)
							
	LogTrace("NOTIFY.USER_ADDED")

	UserAddParms = {}
	UserAddParms["USER_ID"] = UserID
	UserAddParms["USER_NAME"] = UserName
	UserAddParms["PASSCODE"] = PassCode
	UserAddParms["IS_ACTIVE"] = IsActive
	UserAddParms["SCHEDULED_DAYS"] = ScheduleDays
	UserAddParms["START_DAY"] = StartDay
	UserAddParms["START_MONTH"] = StartMonth
	UserAddParms["START_YEAR"] = StartYear
	UserAddParms["END_DAY"] = EndDay
	UserAddParms["END_MONTH"] = EndMonth
	UserAddParms["END_YEAR"] = EndYear
	UserAddParms["START_TIME"] = StartTime
	UserAddParms["END_TIME"] = EndTime
	UserAddParms["SCHEDULE_TYPE"] = ScheduleType
	UserAddParms["IS_RESTRICTED_SCHEDULE"] = IsRestrictedSchedule

--	LogDev(UserAddParms)
	SendNotify("USER_ADDED", UserAddParms, BindingID)
end


function NOTIFY.USER_DELETED(UserID, UserName, BindingID)
	LogTrace("NOTIFY.USER_DELETED")

	UserDeleteParms = {}
	UserDeleteParms["USER_ID"] = UserID
	UserDeleteParms["USER_NAME"] = UserName
	
	SendNotify("USER_DELETED", UserDeleteParms, BindingID)
end



