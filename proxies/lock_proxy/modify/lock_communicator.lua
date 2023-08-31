--[[=============================================================================
    File is: lock_communicator.lua

    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_communicator = "2018.08.16"
end

function LockCom_Lock()
	LogTrace("LockCom_Lock")

end

function LockCom_Unlock()
	LogTrace("LockCom_Unlock")

end


function LockCom_VerifySettings()
	LogTrace("LockCom_VerifySettings")

end


-- function LockCom_SetAdminCode(AdminCode)
	-- LogTrace("LockCom_SetAdminCode")
	-- LogDev("Code: %s", tostring(AdminCode))

-- end


function LockCom_VerifyAdminCode()
	LogTrace("LockCom_VerifyAdminCode")

end


function LockCom_SetScheduleLockoutEnabled(ScheduleLockoutFlag)
	LogTrace("LockCom_SetScheduleLockoutEnabled Set flag to: %s", tostring(ScheduleLockoutFlag))

end


function LockCom_SetNumberLogItems(LogItemsCount)
	LogTrace("LockCom_SetNumberLogItems Count: %d", LogItemsCount)

end


function LockCom_SetAutoLockSeconds(AutoLockSeconds)
	LogTrace("LockCom_SetAutoLockSeconds Seconds: %d", AutoLockSeconds)

end


function LockCom_SetLockMode(NewLockMode)
	LogTrace("LockCom_SetLockMode Mode: %s", tostring(NewLockMode))

end


function LockCom_SetLogFailedAttempts(LogAttempts)
	LogTrace("LockCom_SetLogFailedAttempts Flag: %s", tostring(LogAttempts))

end


function LockCom_SetWrongCodeAttempts(WrongAttempts)
	LogTrace("LockCom_SetWrongCodeAttempts WrongAttempts: %d", WrongAttempts)

end


function LockCom_SetShutoutTimer(ShutoutTimeSeconds)
	LogTrace("LockCom_SetShutoutTimer ShutoutTimeSeconds: %d", ShutoutTimeSeconds)

end


function LockCom_SetLanguage(TargetLanguage)
	LogTrace("LockCom_SetLanguage TargetLanguage: %s", tostring(TargetLanguage))

end


function LockCom_SetVolume(TargetVolume)
	LogTrace("LockCom_SetVolume TargetVolume: %s", tostring(TargetVolume))

end


function LockCom_AddUser(UserName, PassCode, ActiveFlag, RestrictedScheduleFlag, ScheduleType,
                          StartDateYear, StartDateMonth, StartDateDay, EndDateYear, EndDateMonth, EndDateDay,
						  StartTime, EndTime,
						  OnSunday, OnMonday, OnTuesday, OnWednesday, OnThursday, OnFriday, OnSaturday
						 )
	LogTrace("LockCom_AddUser: %s", tostring(UserName))

end


function LockCom_SetOneTouchLocking(AllowOneTouchLocking)
	LogTrace("LockCom_SetOneTouchLocking AllowOneTouchLocking: %s", tostring(AllowOneTouchLocking))

end


function LockCom_SetCustomSetting(SettingName, SettingValue)
	LogTrace("LockCom_SetCustomSetting  Set %s to %s", tostring(SettingName), tostring(SettingValue))

end


function LockCom_VerifyUsers()
	LogTrace("LockCom_VerifyUsers")

end


function LockCom_EditUser(UserID, UserName, PassCode, ActiveFlag, RestrictedScheduleFlag, ScheduleType,
                          StartDateYear, StartDateMonth, StartDateDay, EndDateYear, EndDateMonth, EndDateDay,
						  StartTime, EndTime,
						  OnSunday, OnMonday, OnTuesday, OnWednesday, OnThursday, OnFriday, OnSaturday
						 )
	LogTrace("LockCom_EditUser: %d", UserID)

end


function LockCom_DeleteUser(UserID)
	LogTrace("LockCom_DeleteUser: %d", UserID)

end


function LockCom_AddCustomSetting(CustomSettingName, CustomSettingValue)
	LogTrace("LockCom_AddCustomSetting: %s", tostring(CustomSettingName))

end


function LockCom_UpdateCustomSetting(CustomSettingName, CustomSettingValue)
	LogTrace("LockCom_UpdateCustomSetting: %s -> %s", tostring(CustomSettingName), tostring(CustomSettingValue))

end


function LockCom_DeleteCustomSetting(CustomSettingName)
	LogTrace("LockCom_DeleteCustomSetting: %s", tostring(CustomSettingName))

end

