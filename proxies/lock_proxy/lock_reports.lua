--[[=============================================================================
    File is: lock_reports.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_reports = "2020.03.30"
end

--- Lock Status ------------------------------------------------------------------------------------

function LockReport_InitialLockStatus(Status)
--[[
	Status: New state of the lock, possible values:
		LS_UNKNOWN
		LS_LOCKED
		LS_UNLOCKED
		LS_FAULT
]]
	LogTrace("LockReport_InitialLockStatus  Status: %s", tostring(Status))
	TheLock:SetLockInitialState(Status)
end


function LockReport_LockStatus(Status, Description, Source, ManualCaused)
--[[
	Status: New state of the lock, possible values:
		LS_UNKNOWN
		LS_LOCKED
		LS_UNLOCKED
		LS_FAULT

	Description:
		string to show up on the navigator screens and in the logging
		e.g. "Lock: unlocked"
		
	Source:
		string to indicate which driver is sending the message
		e.g. "Yale 1234"
		
	ManualCaused: boolean  to indicate if the state change was caused by a manual
		action (user turned a key or a physical lever)
		true if caused by a manual action
		false if caused by an automatic action
]]
	LogTrace("LockReport_LockStatus  Status: %s  Description: %s  Source: %s  ManualCaused: %s",
			tostring(Status), tostring(Description), tostring(Source), tostring(ManualCaused))
	TheLock:SetLockState(Status, ManualCaused, Description, Source)
end


function LockReport_UnlockedBy(Unlocker)
	C4:SetVariable("LAST_UNLOCKED_BY", Unlocker)
end

--- Battery Status ---------------------------------------------------------------------------------

function LockReport_BatteryStatus(BStatus)
--[[ 
	possible values for BStatus:
		LBS_NORMAL
		LBS_WARNING
		LBS_CRITICAL
]]
	LogTrace("LockReport_BatteryStatus  Status: %s", tostring(BStatus))
	TheLock:SetBatteryStatus(BStatus)
end

--- Settings ---------------------------------------------------------------------------------------

function LockReport_AdminCode(CurAdminCode)
	LogTrace("LockReport_AdminCode: %s", tostring(CurAdminCode))
	TheLock:SetAdminCode(CurAdminCode)
end

function LockReport_CapabilityChanged(CapabilityName, CapabilityValue)
	LogTrace("LockReport_CapabilityChanged  %s -> %s", tostring(CapabilityName), tostring(CapabilityValue))
--[[
legal capabilities and values:

CAP_IS_MANAGEMENT_ONLY				-> true | false
CAP_HAS_ADMIN_CODE					-> true | false
CAP_HAS_SCHEDULE_LOCKOUT			-> true | false
CAP_HAS_AUTO_LOCK_TIME				-> true | false
CAP_AUTO_LOCK_TIME_VALUES			-> comma delimited list of increasing integer values (e.g. "0, 30, 300")
CAP_AUTO_LOCK_TIME_DISPLAY_VALUES	-> comma delimited list of strings correlating to the integer values (e.g. "OFF, 30sec, 5min")
CAP_HAS_LOG_ITEM_COUNT				-> true | false
CAP_LOG_ITEM_COUNT_VALUES			-> comma delimited list of increasing integer values (e.g. "5, 10, 20, 50")
CAP_HAS_LOCK_MODES					-> true | false
CAP_LOCK_MODE_VALUES				-> comma delimited strings listing lock modes (e.g. "normal, vacation, privacy")
CAP_HAS_LOG_FAILED_ATTEMPTS			-> true | false
CAP_HAS_WRONG_CODE_ATTEMPTS			-> true | false
CAP_WRONG_CODE_ATTEMPTS_VALUES		-> comma delimited list of increasing integer values (e.g. "1, 2, 3, 4, 5, 6, 7")
CAP_HAS_SHUTOUT_TIME				-> true | false
CAP_SHUTOUT_TIMER_VALUES			-> comma delimited list of increasing integer values (e.g. "10, 30, 120")
CAP_SHUTOUT_TIMER_DISPLAY_VALUES	-> comma delimited list of strings correlating to the integer values (e.g. "10sec 30sec, 2min")
CAP_HAS_LANGUAGE					-> true | false
CAP_LANGUAGE_VALUES					-> comma delimited strings listing supported languages (e.g. "English, Spanish, German")
CAP_HAS_VOLUME						-> true | false
CAP_HAS_ONE_TOUCH_LOCKING			-> true | false
CAP_HAS_DAILY_SCHEDULE				-> true | false
CAP_HAS_DATE_RANGE_SCHEDULE			-> true | false
CAP_MAX_USERS						-> integer value (e.g. 50)
CAP_HAS_SETTINGS					-> true | false
CAP_HAS_CUSTOM_SETTINGS				-> true | false
CAP_HAS_INTERNAL_HISTORY			-> true | false
]]
	TheLock:UpdateCapability(CapabilityName, CapabilityValue)
end


function LockReport_UpdateCurrentSetting(SettingName, SettingValue)
	LogTrace("LockReport_UpdateCurrentSetting  %s -> %s", tostring(SettingName), tostring(SettingValue))
--[[
legal settings and values:

ST_AUTO_LOCK_TIME			-> One of the integers listed in the CAP_AUTO_LOCK_TIME_VALUES capability list
ST_LOG_ITEM_COUNT			-> One of the integers listed in the CAP_LOG_ITEM_COUNT_VALUES capability list
ST_SCHEDULE_LOCKOUT_ENABLED	-> true | false
ST_LOCK_MODE				-> One of the string values listed in the CAP_LOCK_MODE_VALUES capability list
ST_LOG_FAILED_ATTEMPTS		-> true | false
ST_WRONG_CODE_ATTEMPTS		-> One of the integers listed in the CAP_WRONG_CODE_ATTEMPTS_VALUES capability list
ST_SHUTOUT_TIMER			-> One of the integers listed in the CAP_SHUTOUT_TIMER_VALUES capability list
ST_LANGUAGE					-> One of the string values listed in the CAP_LANGUAGE_VALUES capability list
ST_VOLUME					-> "high" | "low" | "silent"
ST_ONE_TOUCH_LOCKING		-> true | false
]]
	TheLock:UpdateCurrentSetting(SettingName, SettingValue)
end

--- Users ------------------------------------------------------------------------------------------

function LockReport_ReportAllUsers()
	-- force an updated user list to the UIs
	LogTrace("LockReport_ReportAllUsers")
	TheLock:PrxRequestUsers()	-- pretend they asked for the list
end


function LockReport_AddUser(UserID)
	LogTrace("LockReport_AddUser %s", tostring(UserID))
	TheLock:AddUser(UserID)
end


function LockReport_DeleteUser(UserID)
	LogTrace("LockReport_DeleteUser: %s", tostring(UserID))
	TheLock:DeleteUser(UserID)
end


function LockReport_UpdateUserInformation(	UserID, UserName, UserPassCode,
											IsActive, IsRestrictedSchedule, ScheduleType,
											StartTime, EndTime,
											StartYear, StartMonth, StartDay,
											EndYear, EndMonth, EndDay,
											ActiveSunday, ActiveMonday, ActiveTuesday, ActiveWednesday,
											ActiveThursday, ActiveFriday, ActiveSaturday
										 )
	LogTrace("LockReport_UpdateUserInformation  User: %d", UserID)
	TheLock:UpdateUserInformation(	UserID, UserName, UserPassCode,
									IsActive, IsRestrictedSchedule, ScheduleType,
									StartTime, EndTime,
									StartYear, StartMonth, StartDay,
									EndYear, EndMonth, EndDay,
									ActiveSunday, ActiveMonday, ActiveTuesday, ActiveWednesday,
									ActiveThursday, ActiveFriday, ActiveSaturday
								 )
end


function LockReport_UserName(UserID, UserName)
	LogTrace("LockReport_UserName")
	TheLock:SetUserName(UserID, UserName)
end


function LockReport_UserPassCode(UserID, UserPassCode)
	LogTrace("LockReport_UserPassCode")
	TheLock:SetUserPassCode(UserID, UserPassCode)
end


function LockReport_UserActiveFlag(UserID, ActiveFlag)
	LogTrace("LockReport_UserActiveFlag")
	TheLock:SetUserActiveFlag(UserID, ActiveFlag)
end


function LockReport_UserRestrictedScheduleFlag(UserID, RestrictedScheduleFlag)
	LogTrace("LockReport_UserRestrictedScheduleFlag")
	TheLock:SetUserRestrictedScheduleFlag(UserID, RestrictedScheduleFlag)
end


function LockReport_UserDateRange(UserID, StartYear, StartMonth, StartDay, EndYear, EndMonth, EndDay)
	LogTrace("LockReport_UserDateRange")
	TheLock:SetUserDateRange(UserID, StartYear, StartMonth, StartDay, EndYear, EndMonth, EndDay)
end


function LockReport_UserScheduleType(UserID, ScheduleType)
	LogTrace("LockReport_UserScheduleType")
	TheLock:SetUserScheduleType(UserID, ScheduleType)
end


function LockReport_UserScheduleDays(UserID, SunEn, MonEn, TueEn, WedEn, ThuEn, FriEn, SatEn)
	LogTrace("LockReport_UserScheduleDays")
	TheLock:SetUserScheduleDays(UserID, SunEn, MonEn, TueEn, WedEn, ThuEn, FriEn, SatEn)
end


function LockReport_SetUserScheduleDay(UserID, DayOfWeek, IsEnabled)
	-- Set the enable/disable flag for a single day of the week
	-- Designate DayOfWeek by "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
	LogTrace("LockReport_SetUserScheduleDay")
	TheLock:SetUserScheduleDay(UserID, DayOfWeek, IsEnabled)
end



function LockReport_UserRestrictedTime(UserID, StartTime, EndTime)
	LogTrace("LockReport_UserRestrictedTime")
	TheLock:SetUserRestrictedTime(UserID, StartTime, EndTime)
end


--- Custom Settings --------------------------------------------------------------------------------

function LockReport_UpdateCustomSetting(CustomSettingName, CustomSettingValue)
	LogTrace("LockReport_UpdateCustomSetting: %s", tostring(CustomSettingName))
	NOTIFY.CUSTOM_SETTING_CHANGED(CustomSettingName, CustomSettingValue, LockCustomSettings:GetBindingID())
end


--- History ----------------------------------------------------------------------------------------

function LockReport_HistoryEvent(Event, Source, Year, Month, Day, Hour, Minute)
	LogTrace("LockReport_HistoryEvent: %s", tostring(Event))
	Lock_HistoryEvent(Event, Source, Year, Month, Day, Hour, Minute)
end


function LockReport_HistoryClear()
	LogTrace("LockReport_HistoryClear")
	Lock_HistoryClear()
end



