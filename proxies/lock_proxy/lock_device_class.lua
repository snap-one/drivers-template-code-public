--[[=============================================================================
    Lock Device Class

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "lock_proxy.lock_proxy_commands"
require "lock_proxy.lock_proxy_notifies"
require "lock_proxy.lock_user_info"
require "lock_proxy.lock_custom_settings"
require "lock_proxy.lock_history"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_device_class = "2021.06.23"
end

LockDevice = inheritsFrom(C4ProxyBase)

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]
function LockDevice:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	C4:AddVariable("LAST_UNLOCKED_BY", "-", "STRING", true)
end


function LockDevice:InitialSetup()
	self._CurLockState = LS_UNKNOWN
	self._ActionDescription = ""
	self._BatteryStatus = LBS_NORMAL
	self._GatheringInfo = false
	
	if(PersistData.LockPersist == nil) then
		PersistLockData = {}
		PersistData.LockPersist = PersistLockData
		
		PersistLockData._Capabilities = {}
		self:InitializeCapabilities()

		-- Current Settings
		PersistLockData._Settings = {
										[ST_AUTO_LOCK_TIME] = 0,
										[ST_LOG_ITEM_COUNT] = 5,
										[ST_SCHEDULE_LOCKOUT_ENABLED] = false,
										[ST_LOCK_MODE] = "normal",
										[ST_LOG_FAILED_ATTEMPTS] = false,
										[ST_WRONG_CODE_ATTEMPTS] = 5,
										[ST_SHUTOUT_TIMER] = 30,
										[ST_LANGUAGE] = "English",
										[ST_VOLUME] = "high",
										[ST_ONE_TOUCH_LOCKING] = false
									}

		PersistLockData._AdminCode = ""
		
	else
		PersistLockData = PersistData.LockPersist
	end
	
end


function LockDevice:InitializeCapabilities()

	PersistLockData._Capabilities[CAP_IS_MANAGEMENT_ONLY]				= C4:GetCapability(CAP_IS_MANAGEMENT_ONLY)				or false
	PersistLockData._Capabilities[CAP_HAS_ADMIN_CODE]					= C4:GetCapability(CAP_HAS_ADMIN_CODE)					or false
	PersistLockData._Capabilities[CAP_HAS_SCHEDULE_LOCKOUT]				= C4:GetCapability(CAP_HAS_SCHEDULE_LOCKOUT)			or false
	PersistLockData._Capabilities[CAP_HAS_AUTO_LOCK_TIME]				= C4:GetCapability(CAP_HAS_AUTO_LOCK_TIME)				or false
	PersistLockData._Capabilities[CAP_AUTO_LOCK_TIME_VALUES]			= C4:GetCapability(CAP_AUTO_LOCK_TIME_VALUES)			or ""
	PersistLockData._Capabilities[CAP_AUTO_LOCK_TIME_DISPLAY_VALUES]	= C4:GetCapability(CAP_AUTO_LOCK_TIME_DISPLAY_VALUES)	or ""
	PersistLockData._Capabilities[CAP_HAS_LOG_ITEM_COUNT]				= C4:GetCapability(CAP_HAS_LOG_ITEM_COUNT)				or false
	PersistLockData._Capabilities[CAP_LOG_ITEM_COUNT_VALUES]			= C4:GetCapability(CAP_LOG_ITEM_COUNT_VALUES)			or ""
	PersistLockData._Capabilities[CAP_HAS_LOCK_MODES]					= C4:GetCapability(CAP_HAS_LOCK_MODES)					or false
	PersistLockData._Capabilities[CAP_LOCK_MODES_VALUES]				= C4:GetCapability(CAP_LOCK_MODES_VALUES)				or ""
	PersistLockData._Capabilities[CAP_HAS_LOG_FAILED_ATTEMPTS]			= C4:GetCapability(CAP_HAS_LOG_FAILED_ATTEMPTS)			or false
	PersistLockData._Capabilities[CAP_HAS_WRONG_CODE_ATTEMPTS]			= C4:GetCapability(CAP_HAS_WRONG_CODE_ATTEMPTS)			or false
	PersistLockData._Capabilities[CAP_WRONG_CODE_ATTEMPTS_VALUES]		= C4:GetCapability(CAP_WRONG_CODE_ATTEMPTS_VALUES)		or ""
	PersistLockData._Capabilities[CAP_HAS_SHUTOUT_TIMER]				= C4:GetCapability(CAP_HAS_SHUTOUT_TIMER)				or false
	PersistLockData._Capabilities[CAP_SHUTOUT_TIMER_VALUES]				= C4:GetCapability(CAP_SHUTOUT_TIMER_VALUES)			or ""
	PersistLockData._Capabilities[CAP_SHUTOUT_TIMER_DISPLAY_VALUES]		= C4:GetCapability(CAP_SHUTOUT_TIMER_DISPLAY_VALUES)	or ""
	PersistLockData._Capabilities[CAP_HAS_LANGUAGE]						= C4:GetCapability(CAP_HAS_LANGUAGE)					or false
	PersistLockData._Capabilities[CAP_LANGUAGE_VALUES]					= C4:GetCapability(CAP_LANGUAGE_VALUES)					or ""
	PersistLockData._Capabilities[CAP_HAS_VOLUME]						= C4:GetCapability(CAP_HAS_VOLUME)						or false
	PersistLockData._Capabilities[CAP_HAS_ONE_TOUCH_LOCKING]			= C4:GetCapability(CAP_HAS_ONE_TOUCH_LOCKING)			or false
	PersistLockData._Capabilities[CAP_HAS_DAILY_SCHEDULE]				= C4:GetCapability(CAP_HAS_DAILY_SCHEDULE)				or false
	PersistLockData._Capabilities[CAP_HAS_DATE_RANGE_SCHEDULE]			= C4:GetCapability(CAP_HAS_DATE_RANGE_SCHEDULE)			or false
	PersistLockData._Capabilities[CAP_MAX_USERS]						= C4:GetCapability(CAP_MAX_USERS)						or 1
	PersistLockData._Capabilities[CAP_HAS_SETTINGS]						= C4:GetCapability(CAP_HAS_SETTINGS)					or false
	PersistLockData._Capabilities[CAP_HAS_CUSTOM_SETTINGS]				= C4:GetCapability(CAP_HAS_CUSTOM_SETTINGS)				or false
	PersistLockData._Capabilities[CAP_HAS_INTERNAL_HISTORY]				= C4:GetCapability(CAP_HAS_INTERNAL_HISTORY)			or false
end


function LockDevice:GetBindingID()
	return self._BindingID
end


function LockDevice:CurLockState()
	return self._CurLockState
end


function LockDevice:IsLocked()
	return (self._CurLockState == LS_LOCKED)
end


function LockDevice:GetMaxUsers()
	return PersistLockData._Capabilities[CAP_MAX_USERS]
end


function LockDevice:GetCapability(CapabilityName)
	return PersistLockData._Capabilities[CapabilityName]
end


function LockDevice:SetLockInitialState(TargState)
	if(LockDevice.IsValidState(TargState)) then
		self._CurLockState = TargState
		NOTIFY.LOCK_STATUS_INITIALIZE(self._CurLockState, self._BindingID)
	end
end


function LockDevice:SetLockState(TargState, ManuallySet, ActionDescription, ActionSource)
	if(self:CurLockState() ~= TargState) then
		if(LockDevice.IsValidState(TargState)) then
			self._CurLockState = TargState
			self._ActionDescription = ActionDescription
			NOTIFY.LOCK_STATUS_CHANGED(self._CurLockState, ActionDescription, ActionSource, ManuallySet, self._BindingID)
			Lock_HistoryEventNow(ActionDescription, ActionSource)
		end
	end
end


function LockDevice.IsValidState(CheckState)
	return ((CheckState == LS_UNKNOWN) or (CheckState == LS_LOCKED) or 
			(CheckState == LS_UNLOCKED) or (CheckState == LS_FAULT))
end


function LockDevice:SetBatteryStatus(BStatus)
	if(BStatus ~= self._BatteryStatus) then
		if((BStatus == LBS_NORMAL) or (BStatus == LBS_WARNING) or (BStatus == LBS_CRITICAL)) then
			self._BatteryStatus = BStatus
			NOTIFY.BATTERY_STATUS_CHANGED(self._BatteryStatus, self._BindingID)
		else
			LogWarn("LockDevice:SetBatteryStatus  Invalid Battery Status: %s", tostring(BStatus))
		end
	end
end


function LockDevice:UpdateCapability(CapName, CapValue)
	LogTrace("LockDevice:UpdateCapability  %s -> %s", tostring(CapName), tostring(CapValue))
	if(PersistLockData._Capabilities[CapName] ~= nil) then
		if(PersistLockData._Capabilities[CapName] ~= CapValue) then
			PersistLockData._Capabilities[CapName] = CapValue
			NOTIFY.CAPABILITY_CHANGED(CapName, CapValue, self._BindingID)
		end
	end
end


function LockDevice:GetHistoryLogCount()
	return tonumber(PersistLockData._Settings[ST_LOG_ITEM_COUNT])
end


function LockDevice:SetAdminCode(NewAdminCode)
	LogTrace("LockDevice:SetAdminCode")
	LogDev("SetAdminCode  Old: |%s|  New: |%s|", PersistLockData._AdminCode, NewAdminCode)
	if(LockDevice:GetAdminCode() ~= NewAdminCode) then
		PersistLockData._AdminCode = NewAdminCode
		
		if(not self._GatheringInfo) then
			NOTIFY.SETTING_CHANGED("admin_code", PersistLockData._AdminCode, self._BindingID)
			Lock_HistoryEventNow("Changed Admin Code", "Control4")
		end
	end
end


function LockDevice:GetAdminCode()
	return PersistLockData._AdminCode
end


function LockDevice:HasInternalHistory()
	return PersistLockData._Capabilities[CAP_HAS_INTERNAL_HISTORY]
end


function LockDevice:UpdateCurrentSetting(SettingName, SettingValue)
	LogTrace("LockDevice:UpdateCurrentSetting  %s -> %s", tostring(SettingName), tostring(SettingValue))
	if(PersistLockData._Settings[SettingName] ~= nil) then
		if(PersistLockData._Settings[SettingName] ~= SettingValue) then
			PersistLockData._Settings[SettingName] = SettingValue
			
			if(not self._GatheringInfo) then
				NOTIFY.SETTING_CHANGED(SettingName, SettingValue, self._BindingID)
			end
		end
	end
end


function LockDevice:GetCurrentSetting(SettingName)
	LogTrace("LockDevice:GetCurrentSetting  %s", tostring(SettingName))
	return PersistLockData._Settings[SettingName]
end


function LockDevice:DeleteUser(UserID)
	UserID = tonumber(UserID)
	LogTrace("LockDevice:DeleteUser  -> %d", UserID)
	local TargUser = AllUsersInfo[UserID]
	if(TargUser ~= nil) then
		local U_ID = TargUser:GetUserID()
		local U_Name = TargUser:GetName()
	
		TargUser:SetValidFlag(false)
		NOTIFY.USER_DELETED(U_ID, U_Name, self._BindingID)
	end
end


function LockDevice:AddUser(UserID)
	UserID = tonumber(UserID)
	LogTrace("LockDevice:AddUser -> %d", UserID)
	local TargUser = AllUsersInfo[UserID]
	if(TargUser == nil) then
		TargUser = LockUserInfo:new(UserID)
	end
	TargUser:SetValidFlag(true)
end


function LockDevice:UpdateUserInformation(	UserID, UserName, UserPassCode,
											IsActive, IsRestrictedSchedule, ScheduleType,
											StartTime, EndTime,
											StartYear, StartMonth, StartDay,
											EndYear, EndMonth, EndDay,
											ActiveSunday, ActiveMonday, ActiveTuesday, ActiveWednesday,
											ActiveThursday, ActiveFriday, ActiveSaturday
										 )
	
	LogTrace("LockDevice:UpdateUserInformation  ID : %d", UserID)
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetValidFlag(true)
		TargUser:SetName(UserName)
		TargUser:SetPassCode(UserPassCode)
		TargUser:SetActiveFlag(IsActive)
		TargUser:SetRestrictedScheduleFlag(IsRestrictedSchedule)
		TargUser:SetScheduleType(ScheduleType)
		TargUser:SetRestrictedTime(StartTime, EndTime)
		TargUser:SetDateRange(StartYear, StartMonth, StartDay, EndYear, EndMonth, EndDay)
		TargUser:SetScheduleDays( { ["Sun"] = ActiveSunday, 
									["Mon"] = ActiveMonday,
									["Tue"] = ActiveTuesday, 
									["Wed"] = ActiveWednesday, 
									["Thu"] = ActiveThursday, 
									["Fri"] = ActiveFriday, 
									["Sat"] = ActiveSaturday
								} )
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogError("LockDevice:UpdateUserInformation  Invalid or Unused UserID: %s", tostring(UserID))
	end									 

end


function LockDevice:SetUserName(UserID, UserName)
	LogTrace("LockDevice:SetUserName  User: %s  Name: %s", tostring(UserID), tostring(UserName))
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetName(UserName)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserName  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserPassCode(UserID, UserPassCode)
--	LogTrace("LockDevice:SetUserPassCode  User: %s  Code: %s", tostring(UserID), tostring(UserPassCode))
	LogTrace("LockDevice:SetUserPassCode  User: %s", tostring(UserID))
	LogDev("Code: %s", tostring(UserPassCode))
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetPassCode(UserPassCode)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserPassCode  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserActiveFlag(UserID, ActiveFlag)
	LogTrace("LockDevice:SetUserActiveFlag  User: %s  Flag: %s", tostring(UserID), tostring(ActiveFlag))
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetActiveFlag(ActiveFlag)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserActiveFlag  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserRestrictedScheduleFlag(UserID, RestrictedScheduleFlag)
	LogTrace("LockDevice:SetUserRestrictedScheduleFlag  User: %s  Flag: %s", tostring(UserID), tostring(RestrictedScheduleFlag))
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetRestrictedScheduleFlag(RestrictedScheduleFlag)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserRestrictedScheduleFlag  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserDateRange(UserID, StartYear, StartMonth, StartDay, EndYear, EndMonth, EndDay)
	LogTrace("LockDevice:SetUserDateRange  User: %s  Start: %s.%s.%s  End: %s.%s.%s", tostring(UserID),
			tostring(StartYear), tostring(StartMonth), tostring(StartDay),
			tostring(EndYear), tostring(EndMonth), tostring(EndDay))

	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetDateRange(StartYear, StartMonth, StartDay, EndYear, EndMonth, EndDay)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserDateRange  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserScheduleType(UserID, ScheduleType)
	LogTrace("LockDevice:SetUserScheduleType  User: %s  ScheduleType: %s", tostring(UserID), tostring(ScheduleType))
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetScheduleType(ScheduleType)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserScheduleType  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserScheduleDays(UserID, SunEn, MonEn, TueEn, WedEn, ThuEn, FriEn, SatEn)
	LogTrace("LockDevice:SetUserScheduleDays  User: %s  Su: %s  Mo: %s  Tu: %s  We: %s  Th: %s  Fr: %s  Sa: %s", tostring(UserID),
			tostring(SunEn), tostring(MonEn), tostring(TueEn), tostring(WedEn), tostring(ThuEn), tostring(FriEn), tostring(SatEn))
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetScheduleDays( { ["Sun"] = SunEn, 
									["Mon"] = MonEn,
									["Tue"] = TueEn, 
									["Wed"] = WedEn, 
									["Thu"] = ThuEn, 
									["Fri"] = FriEn, 
									["Sat"] = SatEn
								} )
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserScheduleDays  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserScheduleDay(UserID, DoW, IsEnabled)
	-- set the schedule flag for a single day of the week
	LogTrace("LockDevice:SetUserScheduleDay  User: %s  Day: %s  Enabled: %s", tostring(UserID), tostring(DoW), tostring(IsEnabled))

	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetScheduleDays( { [DoW] = IsEnabled } )
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserScheduleDays  Invalid or Unused UserID: %s", tostring(UserID))
	end
end


function LockDevice:SetUserRestrictedTime(UserID, StartTime, EndTime)
	LogTrace("LockDevice:SetUserScheduleTime  UserID: %d  Start: %04d  End: %04d", UserID, StartTime, EndTime)
	local TargUser = AllUsersInfo[tonumber(UserID)]
	if(TargUser ~= nil) then
		TargUser:SetRestrictedTime(StartTime, EndTime)
		TargUser:FinalizeChanges(self._BindingID)
	else
		LogWarn("LockDevice:SetUserScheduleTime  Invalid or Unused UserID: %s", tostring(UserID))
	end
end



--[[=============================================================================
    Functions for handling request from the Partition Proxy
===============================================================================]]


function LockDevice:PrxLock()
	LogTrace("LockDevice:PrxLock")
	LockCom_Lock()
end


function LockDevice:PrxUnlock()
	LogTrace("LockDevice:PrxUnlock")
	LockCom_Unlock()
end


function LockDevice:PrxToggle()
	LogTrace("LockDevice:PrxToggle")
	if(self:IsLocked()) then
		LockCom_Unlock()
	else
		LockCom_Lock()
	end
end


function LockDevice:PrxRequestCapabilities()
	LogTrace("LockDevice:PrxRequestCapabilities")

	for  CName, CValue in pairs(PersistLockData._Capabilities) do
		NOTIFY.CAPABILITY_CHANGED(CName, CValue, self._BindingID)
	end

	-- ...and the admin code for good measure
	NOTIFY.SETTING_CHANGED("admin_code", PersistLockData._AdminCode, self._BindingID)
end


function LockDevice:PrxRequestSettings()
	LogTrace("LockDevice:PrxRequestSettings")

	self._GatheringInfo = true
	LockCom_VerifySettings()
	self._GatheringInfo = false
	
	NOTIFY.SETTINGS(PersistLockData._AdminCode,
					PersistLockData._Settings[ST_AUTO_LOCK_TIME],
					PersistLockData._Settings[ST_LOG_ITEM_COUNT],
					PersistLockData._Settings[ST_SCHEDULE_LOCKOUT_ENABLED],
					PersistLockData._Settings[ST_LOCK_MODE],
					PersistLockData._Settings[ST_LOG_FAILED_ATTEMPTS],
					PersistLockData._Settings[ST_WRONG_CODE_ATTEMPTS],
					PersistLockData._Settings[ST_SHUTOUT_TIMER],
					PersistLockData._Settings[ST_LANGUAGE],
					PersistLockData._Settings[ST_VOLUME],
					PersistLockData._Settings[ST_ONE_TOUCH_LOCKING],
					self._BindingID)
end


function LockDevice:PrxRequestCustomSettings()
	LogTrace("LockDevice:PrxRequestCustomSettings")
	
	NOTIFY.CUSTOM_SETTINGS(GetAllCustomSettingsXML(), self._BindingID)
end


function LockDevice:PrxRequestHistory()
	LogTrace("LockDevice:PrxRequestHistory")
	LockCom_VerifySettings()
	NOTIFY.HISTORY(GetHistoryXML(), self._BindingID)
end


function LockDevice:PrxRequestUsers()
	LogTrace("LockDevice:PrxRequestUsers")
	LockCom_VerifyUsers()
	
	local AllUsersXML = ""
	
	for CurID, CurUserInfo in pairs(AllUsersInfo) do
		if(CurUserInfo:IsValid()) then
			AllUsersXML = AllUsersXML .. CurUserInfo:GetXMLData()
		end
	end
	
	NOTIFY.USERS(MakeXMLNode("lock_users", AllUsersXML), self._BindingID)
end


function LockDevice:PrxEditUser(tParams)
	LogTrace("LockDevice:PrxEditUser")
	
	local UserID = tonumber(tParams.USER_ID)
	local UserName = tParams.USER_NAME
	local PassCode = tParams.PASSCODE
	local IsActive = toboolean(tParams.IS_ACTIVE)
	local ScheduledDays = StringSplit(tParams.SCHEDULED_DAYS, ",")
	local StartDateYear = tonumber(tParams.START_YEAR)
	local StartDateMonth = tonumber(tParams.START_MONTH)
	local StartDateDay = tonumber(tParams.START_DAY)
	local EndDateYear = tonumber(tParams.END_YEAR)
	local EndDateMonth = tonumber(tParams.END_MONTH)
	local EndDateDay = tonumber(tParams.END_DAY)
	local StartTime = tonumber(tParams.START_TIME)
	local EndTime = tonumber(tParams.END_TIME)
	local ScheduleType = tParams.SCHEDULE_TYPE
	local IsRestrictedSchedule = toboolean(tParams.IS_RESTRICTED_SCHEDULE)

	LockCom_EditUser(UserID, UserName, PassCode, IsActive, IsRestrictedSchedule, ScheduleType,
					StartDateYear, StartDateMonth, StartDateDay,
					EndDateYear, EndDateMonth, EndDateDay,
					StartTime, EndTime,
					toboolean(ScheduledDays[1]), toboolean(ScheduledDays[2]), toboolean(ScheduledDays[3]), toboolean(ScheduledDays[4]), 
					toboolean(ScheduledDays[5]), toboolean(ScheduledDays[6]), toboolean(ScheduledDays[7]))
	
end


function LockDevice:PrxAddUser(tParams)
	LogTrace("LockDevice:PrxAddUser")

	local UserName = tParams.USER_NAME
	local PassCode = tParams.PASSCODE
	local IsActive = toboolean(tParams.IS_ACTIVE)
	local ScheduledDays = StringSplit(tParams.SCHEDULED_DAYS, ",")
	local StartDateYear = tonumber(tParams.START_YEAR)
	local StartDateMonth = tonumber(tParams.START_MONTH)
	local StartDateDay = tonumber(tParams.START_DAY)
	local EndDateYear = tonumber(tParams.END_YEAR)
	local EndDateMonth = tonumber(tParams.END_MONTH)
	local EndDateDay = tonumber(tParams.END_DAY)
	local StartTime = tonumber(tParams.START_TIME)
	local EndTime = tonumber(tParams.END_TIME)
	local ScheduleType = tParams.SCHEDULE_TYPE
	local IsRestrictedSchedule = toboolean(tParams.IS_RESTRICTED_SCHEDULE)

	LockCom_AddUser(UserName, PassCode, IsActive, IsRestrictedSchedule, ScheduleType, 
					StartDateYear, StartDateMonth, StartDateDay, EndDateYear, EndDateMonth, EndDateDay,
					StartTime, EndTime,
					toboolean(ScheduledDays[1]), toboolean(ScheduledDays[2]), toboolean(ScheduledDays[3]), toboolean(ScheduledDays[4]), 
					toboolean(ScheduledDays[5]), toboolean(ScheduledDays[6]), toboolean(ScheduledDays[7]))
	
end


function LockDevice:PrxDeleteUser(tParams)
	LogTrace("LockDevice:PrxDeleteUser")
	local UserID = tonumber(tParams.USER_ID)
	
	LockCom_DeleteUser(UserID)
end


function LockDevice:PrxSetAdminCode(tParams)
	LogTrace("LockDevice:PrxSetAdminCode")
	local NewAdminCode = tostring(tParams.PASSCODE)
	self:SetAdminCode(NewAdminCode)
end


function LockDevice:PrxSetScheduleLockoutEnabled(tParams)
	LogTrace("LockDevice:PrxSetScheduleLockoutEnabled")
	local LockoutFlag = toboolean(tParams.ENABLED)
	LockCom_SetScheduleLockoutEnabled(LockoutFlag)
end


function LockDevice:PrxSetNumberLogItems(tParams)
	LogTrace("LockDevice:PrxSetNumberLogItems")
	local LogItemsCount = tonumber(tParams.COUNT)
	LockReport_UpdateCurrentSetting(ST_LOG_ITEM_COUNT, LogItemsCount)
	LockCom_SetNumberLogItems(LogItemsCount)
end


function LockDevice:PrxSetAutoLockSeconds(tParams)
	LogTrace("LockDevice:PrxSetAutoLockSeconds")
	local AutoLockSeconds = tonumber(tParams.SECONDS)
	LockCom_SetAutoLockSeconds(AutoLockSeconds)
end


function LockDevice:PrxSetLockMode(tParams)
	LogTrace("LockDevice:PrxSetLockMode")
	local LockMode = tostring(tParams.MODE)
	LockCom_SetLockMode(LockMode)
end


function LockDevice:PrxSetLogFailedAttempts(tParams)
	LogTrace("LockDevice:PrxSetLogFailedAttempts")
	local LogFailAttempts = toboolean(tParams.ENABLED)
	LockCom_SetLogFailedAttempts(LogFailAttempts)
end


function LockDevice:PrxSetWrongCodeAttempts(tParams)
	LogTrace("LockDevice:PrxSetWrongCodeAttempts")
	local WrongCodeAttempts = tonumber(tParams.COUNT)
	LockCom_SetWrongCodeAttempts(WrongCodeAttempts)
end


function LockDevice:PrxSetShutoutTimer(tParams)
	LogTrace("LockDevice:PrxSetShutoutTimer")
	local ShutoutTime = tonumber(tParams.SECONDS)
	LockCom_SetShutoutTimer(ShutoutTime)
end


function LockDevice:PrxSetLanguage(tParams)
	LogTrace("LockDevice:PrxSetLanguage")
	local NewLanguage = tostring(tParams.LANGUAGE)
	LockCom_SetLanguage(NewLanguage)
end


function LockDevice:PrxSetVolume(tParams)
	LogTrace("LockDevice:PrxSetVolume")
	local TargVolume = tostring(tParams.VOLUME)
	LockCom_SetVolume(TargVolume)
end


function LockDevice:PrxSetOneTouchLocking(tParams)
	LogTrace("LockDevice:PrxSetOneTouchLocking")
	local OneTouchLocking = toboolean(tParams.ENABLED)
	LockCom_SetOneTouchLocking(OneTouchLocking)
end


function LockDevice:PrxSetCustomSetting(tParams)
	LogTrace("LockDevice:PrxSetCustomSetting")
	local SettingName = tParams.NAME
	local SettingValue = tParams.VALUE
	LockCom_SetCustomSetting(SettingName, SettingValue)
end



