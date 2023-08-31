--[[=============================================================================
    File is: lock_user_info.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_user_info = "2020.03.31"
end

LockUserInfo = inheritsFrom(nil)

AllUsersInfo = {}
AllUsersByPassCode = {}

LAST_MINUTE = ((24 * 60) - 1)


function LockUserInfo:construct(UserID)
	LogTrace("LockUserInfo:construct  UserID: %d", UserID)
	self._UserID = UserID
	AllUsersInfo[self._UserID] = self

	self._Active = true
	self._InfoChanged = false
	self._GatheringMultipleChanges = false

	self._IsValid = false
	self:ResetAllInfo()
	
	-- don't allow multiple history entries too close together
	self._AllowUpdateHistoryMessage = true
	self._HistoryBlockTimer = 
		CreateTimer("UserHistoryBlockTimer", 12, "SECONDS", LockUserInfo.UserHistoryBlockTimeTimerExpired, false, self)

end


function LockUserInfo:destruct()
	LockCom_DeleteUser(self._UserID)

	AllUsersInfo[self._UserID] = nil
	if(AllUsersByPassCode[self._PassCode] ~= nil) then
		AllUsersByPassCode[self._PassCode] = nil
	end
end


function LockUserInfo:ResetAllInfo()
	self._UserName = "User " .. tostring(self._UserID)
	self._PassCode = ""
	
	self:ResetScheduleInfo()
end


function LockUserInfo:ResetScheduleInfo()
	self._RestrictedSchedule = false
	self._ScheduleType = LST_DAILY
	self._ScheduledDays = { ["Sun"] = true, ["Mon"] = true, ["Tue"] = true, ["Wed"] = true, ["Thu"] = true, ["Fri"] = true, ["Sat"] = true }
	self._StartDateYear = 0
	self._StartDateMonth = 1
	self._StartDateDay = 1
	self._EndDateYear = 9999
	self._EndDateMonth = 12
	self._EndDateDay = 31
	self._StartTime = 0
	self._EndTime = LAST_MINUTE
end


function LockUserInfo:StartMultipleChanges()
	LogTrace("LockUserInfo:StartMultipleChanges for %d", self:GetUserID())
	self._GatheringMultipleChanges = true
end


function LockUserInfo:EndMultipleChanges(TargBindingID, AddToHistory)
	LogTrace("LockUserInfo:EndMultipleChanges for %d", self:GetUserID())
	self._GatheringMultipleChanges = false
	self:FinalizeChanges(TargBindingID, AddToHistory)
end


function LockUserInfo:SetValidFlag(ValidFlag)
	if(ValidFlag ~= nil) then
		if(self._IsValid ~= ValidFlag) then
			self._IsValid = ValidFlag
			
			if(self._IsValid) then
				Lock_HistoryEventNow(string.format("Added New User %d (%s)", self:GetUserID(), self:GetName()), "Control4")
				self:BlockHistory()
				self:ResetScheduleInfo()
			else
				Lock_HistoryEventNow(string.format("Deleted User %d (%s)", self:GetUserID(), self:GetName()), "Control4")

				if(AllUsersByPassCode[self._PassCode] ~= nil) then
					AllUsersByPassCode[self._PassCode] = nil
				end

				self:ResetAllInfo()	-- make sure old values are wiped out		
				-- don't leave old names and pass codes around
			end
			
			self:MarkChange()
		end
	end
end


function LockUserInfo:IsValid()
	return self._IsValid
end


function LockUserInfo:GetUserID()
	return self._UserID
end



function LockUserInfo:MarkChange()
	self._InfoChanged = true
end


function LockUserInfo:GetName()
	return self:IsValid() and self._UserName or ""
end


function LockUserInfo:SetName(NewName)
	if(NewName ~= nil) then
		if((self._UserName ~= tostring(NewName)) and (NewName ~= nil) and (NewName ~= "")) then
			self._UserName = tostring(NewName)
			self:MarkChange()
		end
	end
end


function LockUserInfo:GetPassCode()
	return self:IsValid() and self._PassCode or ""
end


function LockUserInfo:SetPassCode(NewPassCode)
	if(NewPassCode ~= nil) then
		if(self._PassCode ~= NewPassCode) then
			if(LockUserInfo.PassCodeAvailable(NewPassCode)) then
				if(AllUsersByPassCode[self._PassCode] ~= nil) then
					AllUsersByPassCode[self._PassCode] = nil
				end

				self._PassCode = NewPassCode
				AllUsersByPassCode[self._PassCode] = self
				self:MarkChange()
			else
				LogInfo("LockUserInfo:SetPassCode  PassCode Not Available for user %d: %s", self._UserID, tostring(NewPassCode))
			end
		end
	end
end


function LockUserInfo:SetActiveFlag(ActiveFlag)
	if(ActiveFlag ~= nil) then
		if(self._Active ~= ActiveFlag) then
			self._Active = ActiveFlag
			self:MarkChange()
		end
	end
end


function LockUserInfo:IsActive()
	return self._Active
end


function LockUserInfo:SetRestrictedScheduleFlag(RestrictFlag)
	if(RestrictFlag ~= nil) then
		if(self._RestrictedSchedule ~= RestrictFlag) then
			self._RestrictedSchedule = RestrictFlag
			self:MarkChange()
		end
	end
end


function LockUserInfo:HasRestrictedSchedule()
	return self._RestrictedSchedule
end


function LockUserInfo:SetRestrictedTime(StartTime, EndTime)
	if((StartTime ~= nil) and (EndTime ~= nil)) then
		local nStartTime = tonumber(StartTime)
		local nEndTime = tonumber(EndTime)
		LogTrace("LockUserInfo:SetRestrictedTime Start: %s  End: %s", tostring(nStartTime), tostring(nEndTime))
		
		if((self._StartTime ~= nStartTime) or (self._EndTime ~= nEndTime)) then
		
			if((nStartTime >= 0) and (nStartTime <= LAST_MINUTE) and 
			   (nEndTime >= 0) and (nEndTime <= LAST_MINUTE) and 
			   (nEndTime >= nStartTime)) then
				self:SetRestrictedScheduleFlag(true)
				self._StartTime = nStartTime
				self._EndTime = nEndTime
				self:MarkChange()
			end
		end
	end
end


function LockUserInfo:SetDateRange(StartYear, StartMonth, StartDay, EndYear, EndMonth, EndDay)
	if((StartYear ~= nil) and (StartMonth ~= nil) and (StartDay ~= nil) and (EndYear ~= nil) and (EndMonth ~= nil) and (EndDay ~= nil))then
		if((self._StartDateYear ~= StartYear) or (self._StartDateMonth ~= StartMonth) or (self._StartDateDay ~= StartDay) or
		   (self._EndDateYear ~= EndYear) or (self._EndDateMonth ~= EndMonth) or (self._EndDateDay ~= EndDay)) then

			if(LockUserInfo.DateIsValid(StartYear, StartMonth, StartDay) and 
			   LockUserInfo.DateIsValid(EndYear, EndMonth, EndDay)) then
				self:SetScheduleType(LST_DATE_RANGE)
				self._StartDateYear = StartYear
				self._StartDateMonth = StartMonth
				self._StartDateDay = StartDay
				self._EndDateYear = EndYear
				self._EndDateMonth = EndMonth
				self._EndDateDay = EndDay
				self:MarkChange()
			end
		end
	end
end


function LockUserInfo:GetDateRange()
	return self._StartDateYear, self._StartDateMonth, self._StartDateDay, self._EndDateYear, self._EndDateMonth, self._EndDateDay
end


function LockUserInfo:SetScheduleType(NewType)
	if(NewType ~= nil) then
		if(self._ScheduleType ~= NewType) then
			if((NewType == LST_DAILY) or (NewType == LST_DATE_RANGE)) then
				self:SetRestrictedScheduleFlag(true)
				self._ScheduleType = NewType
				self:MarkChange()
			end
		end
	end
end


function LockUserInfo:GetScheduleType()
	return self._ScheduleType
end


function LockUserInfo:SetScheduleDays(WeekTbl)
	if(WeekTbl ~= nil) then
		self:SetScheduleType(LST_DAILY)
		for DayOfWeek, Enabled in pairs(WeekTbl) do
			if(Enabled ~= nil) then
				self._ScheduledDays[DayOfWeek] = Enabled
				self:MarkChange()
				LogDebug("LockUserInfo:SetScheduleDays User: %d DoW: %s  En: %s", self:GetUserID(), tostring(DayOfWeek), tostring(Enabled))
			end
		end
	end
end


function LockUserInfo:GetScheduleDays()
	return	self._ScheduledDays["Sun"],
			self._ScheduledDays["Mon"],
			self._ScheduledDays["Tue"],
			self._ScheduledDays["Wed"],
			self._ScheduledDays["Thu"],
			self._ScheduledDays["Fri"],
			self._ScheduledDays["Sat"]
end


function LockUserInfo:GetScheduleDaysString()
	return	string.format("%s,%s,%s,%s,%s,%s,%s",
						  tostring(self._ScheduledDays["Sun"]),
						  tostring(self._ScheduledDays["Mon"]),
						  tostring(self._ScheduledDays["Tue"]),
						  tostring(self._ScheduledDays["Wed"]),
						  tostring(self._ScheduledDays["Thu"]),
						  tostring(self._ScheduledDays["Fri"]),
						  tostring(self._ScheduledDays["Sat"])
						 )
end


function LockUserInfo:GetScheduleTime()
	local StartHour = math.floor(self._StartTime / 60)
	local StartMinute = self._StartTime % 60
	local EndHour = math.floor(self._EndTime / 60)
	local EndMinute = self._EndTime % 60

	return StartHour, StartMinute, EndHour, EndMinute
end


function LockUserInfo:FinalizeChanges(TargBinding, AddToHistory)
	LogTrace("LockUserInfo:FinalizeChanges")
	AddToHistory = AddToHistory or true
	LogTrace("IsValid: %s  AddToHistory: %s", tostring(self:IsValid()), tostring(AddToHistory))
	if(not self._GatheringMultipleChanges) then
		if(self._InfoChanged) then
			NOTIFY.USER_CHANGED(	self._UserID, self._UserName, self._PassCode, 
									self._Active, self:GetScheduleDaysString(),
									self._StartDateDay, self._StartDateMonth, self._StartDateYear,
									self._EndDateDay, self._EndDateMonth, self._EndDateYear,
									self._StartTime, self._EndTime,
									self._ScheduleType, self._RestrictedSchedule,
									TargBinding)	

			if(self:IsValid() and AddToHistory) then
				if(self._AllowUpdateHistoryMessage) then
					Lock_HistoryEventNow(string.format("Updated User %d (%s)", self._UserID, self:GetName()), "Control4")
					self:BlockHistory()
				end
			end
			
			self._InfoChanged = false
		end
	else
		LogDebug("Still Gathering")
	end
end


function LockUserInfo:BlockHistory()
	self._AllowUpdateHistoryMessage = false
	self._HistoryBlockTimer:StartTimer()
end


function LockUserInfo:BlockHistoryTimerExpired()
	self._AllowUpdateHistoryMessage = true
end

------------------------------------------------------------

function LockUserInfo:GetXMLData()

	LogTrace("LockUserInfo:GetXMLData : %d", self._UserID)
	
	return MakeXMLNode("user",	MakeXMLNode("user_id", tostring(self._UserID)) ..
								MakeXMLNode("user_name", self._UserName) ..
								MakeXMLNode("passcode", self._PassCode) ..
								MakeXMLNode("is_active", tostring(self._Active)) ..
								MakeXMLNode("is_restricted_schedule", tostring(self._RestrictedSchedule)) ..
								MakeXMLNode("start_time", tostring(self._StartTime)) ..
								MakeXMLNode("end_time", tostring(self._EndTime)) ..
								MakeXMLNode("schedule_type", self._ScheduleType) ..
								MakeXMLNode("start_day", tostring(self._StartDateDay)) ..
								MakeXMLNode("start_month", tostring(self._StartDateMonth)) ..
								MakeXMLNode("start_year", tostring(self._StartDateYear)) ..
								MakeXMLNode("end_day", tostring(self._EndDateDay)) ..
								MakeXMLNode("end_month", tostring(self._EndDateMonth)) ..
								MakeXMLNode("end_year", tostring(self._EndDateYear)) ..
								MakeXMLNode("scheduled_days", self:GetScheduleDaysString())
					  )
end	

------------------------------------------------------------

function LockUserInfo.PassCodeAvailable(CheckPassCode)
	return (AllUsersByPassCode[CheckPassCode] == nil)
end


function LockUserInfo.DateIsValid(CheckYear, CheckMonth, CheckDay)
	local IsValid = false
	
	if((CheckMonth >= 1) and (CheckMonth <= 12)) then
		local DaysPerMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
		if((CheckDay >= 1) and (CheckDay <= DaysPerMonth[CheckMonth])) then
			IsValid = true
		else
				-- one last check for leap day
			if((CheckMonth == 2) and (CheckDay == 29)) then
				if((CheckYear % 100) == 0) then
					IsValid = ((CheckYear % 400) == 0)
				else
					IsValid = ((CheckYear % 4) == 0)
				end
			end
		end
	
	end
	
	return IsValid
end


function LockUserInfo.UserHistoryBlockTimeTimerExpired(WhichUser)
	LogTrace("LockUserInfo.UserHistoryBlockTimeTimerExpired")
	if (WhichUser ~= nil) then
		WhichUser:BlockHistoryTimerExpired()
	end
end


