--[[=============================================================================
    File is: lock_apis.lua

    Copyright 2021 Snap One, LLC. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_apis = "2021.10.25"
end


function IsLocked()
	return TheLock:IsLocked()
end

function GetCurrentLockState()
	return TheLock:CurLockState()
end

function GetCurrentAdminCode()
	return TheLock:GetAdminCode()
end


function GetCurrentSetting(SettingName)
	return TheLock:GetCurrentSetting(SettingName)
end


function GetAutoLockTime()
	return GetCurrentSetting(ST_AUTO_LOCK_TIME)
end


function GetMaxUsers()
	return tonumber(TheLock:GetMaxUsers())
end


function GetCapabilityValue(CapabilityName)
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
	return TheLock:GetCapability(CapabilityName)
end


function IsUserDefined(UserID)
	return (AllUsersInfo[UserID] ~= nil)
end

function IsUserValid(UserID)
	local TargUser = AllUsersInfo[UserID]
	return (TargUser ~= nil) and TargUser:IsValid() or false
end
	
function GetUserName(UserID)
	local TargUser = AllUsersInfo[UserID]
	return (TargUser ~= nil) and TargUser:GetName() or ("User " .. tostring(UserID))
end


function GetUserPassCode(UserID)
	local TargUser = AllUsersInfo[UserID]
	return (TargUser ~= nil) and TargUser:GetPassCode() or ""
end


function GetUserActiveFlag(UserID)
	local TargUser = AllUsersInfo[UserID]
	return (TargUser ~= nil) and TargUser:IsActive() or false
end


function GetUserRestrictedScheduleFlag(UserID)
	local TargUser = AllUsersInfo[UserID]
	return (TargUser ~= nil) and TargUser:HasRestrictedSchedule() or false
end


function GetUserDateRange(UserID)
	local TargUser = AllUsersInfo[UserID]
	if (TargUser ~= nil) then 
		return TargUser:GetDateRange()
	else
		return 2000, 1, 1, 2999, 12, 31
	end
end


function GetUserScheduleType(UserID)
	local TargUser = AllUsersInfo[UserID]
	return (TargUser ~= nil) and TargUser:GetScheduleType() or LST_DAILY
end


function GetUserScheduleDays(UserID)
	local TargUser = AllUsersInfo[UserID]
	if (TargUser ~= nil) then 
		return TargUser:GetScheduleDays()
	else
		return true, true, true, true, true, true, true
	end
end


function GetUserScheduleTime(UserID)
	local TargUser = AllUsersInfo[UserID]
	if (TargUser ~= nil) then 
		return TargUser:GetScheduleTime()
	else
		return 00, 00, 23, 59
	end
end


function HasInternalHistory()
	return TheLock:HasInternalHistory()
end


function StartUserMultipleChanges(UserID)
	local TargUser = AllUsersInfo[UserID]
	if (TargUser ~= nil) then 
		TargUser:StartMultipleChanges()
	end
end


function EndUserMultipleChanges(UserID)
	local TargUser = AllUsersInfo[UserID]
	if (TargUser ~= nil) then 
		TargUser:EndMultipleChanges(TheLock:GetBindingID())
	end
end


function GetUserIDFromCode(CheckUserCode)
	if(AllUsersByPassCode[CheckUserCode] ~= nil) then
		return AllUsersByPassCode[CheckUserCode]:GetUserID()
	else
		return 0
	end
end

