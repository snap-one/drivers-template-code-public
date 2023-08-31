--[[=============================================================================
    File is: retry_timer.lua

    Copyright 2022 Snap One LLC.  All Rights Reserved.
===============================================================================]]

require "lib.c4_object"
require "lib.c4_timer"

RetryTimer = inheritsFrom(nil)

function RetryTimer:construct(RetryMax, Interval, FallbackInterval, IntervalUnits, RetryRoutine, FailureRoutine, Parent)
	self._IsEnabled = true
	self._Interval = Interval
	self._FallbackInterval = FallbackInterval
	self._RetryRoutine = RetryRoutine
	self._FailureRoutine = FailureRoutine
	self._Parent = Parent
	self._RetryCount = 0
	self._RetryMax = RetryMax
	self._FulfillString = ""
	self._RetryParameter = nil
	self._Timer = CreateTimer("RetryTimer", self._Interval, IntervalUnits, RetryTimer.Callback, false, self)
end


function RetryTimer:destruct()
	self:Kill()
end

function RetryTimer:SetEnableFlag(EnableIt)
	self._IsEnabled = EnableIt
end

function RetryTimer:Enable()
	self._IsEnabled = true
end

function RetryTimer:Disable()
	self._IsEnabled = false
end

function RetryTimer:IsEnabled()
	return self._IsEnabled
end

function RetryTimer:IsStarted()
	return self._Timer:TimerStarted()
end

function RetryTimer:SetInterval(Interval)
	self._Interval = Interval
end

function RetryTimer:GetInterval()
	return self._Interval
end

function RetryTimer:SetFallbackInterval(Interval)
	self._FallbackInterval = Interval
end

function RetryTimer:GetFallbackInterval()
	return self._FallbackInterval
end

function RetryTimer:SetRetryMaxCount(MaxCount)
	self._RetryMax = MaxCount
end

function RetryTimer:GetRetryMaxCount()
	return self._RetryMax
end

function RetryTimer:SetRetryParameter(Param)
	self._RetryParameter = Param
end


function RetryTimer:Start(FulfillStr)
	if(self._IsEnabled) then
		self._FulfillString = FulfillStr
		self._Timer:StartTimer((self._RetryCount < 2) and self._Interval or self._FallbackInterval)
	end
end

function RetryTimer:Kill()
	self._Timer:KillTimer()
	self._RetryCount = 0
	self._FulfillString = ""
	self._RetryParameter = nil
end

function RetryTimer:Restart()
	if(self:IsStarted()) then
		self._RetryCount = 0
		self._Timer:StartTimer(self._Interval)
	end
end


function RetryTimer:Fulfill(FulfillStr)
	-- only kill the timer if the correct target was reached
	if(FulfillStr == self._FulfillString) then
		self:Kill()
	end
end

function RetryTimer:DoCallback()
	self._RetryCount = self._RetryCount + 1
	
	if(self._RetryCount <= self._RetryMax) then
		--LogDebug("RetryTimer:DoCallback Retry Count is %d  Do retry...", self._RetryCount)
		self._RetryRoutine(self._Parent, self._RetryParameter)
	else
		--LogDebug("RetryTimer:DoCallback Retry Count exceeded.  Call fail routine...")
		self._FailureRoutine(self._Parent, self._RetryParameter)
		self:Kill()
	end
end


function RetryTimer.Callback(Instance)
	Instance:DoCallback()
end


