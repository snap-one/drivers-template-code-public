--[[=============================================================================
    File is: ramp_timer.lua

    Copyright 2022 Snap One LLC.  All Rights Reserved.
===============================================================================]]

require "lib.c4_object"
require "lib.c4_timer"

RampTimer = inheritsFrom(nil)

RampTimer.DEFAULT_INTERVAL = 100		-- milliseconds
RampTimer.DEFAULT_UNITS = "MILLISECONDS"
RampTimer.DEFAULT_MAX_COUNT = 60

function RampTimer:construct(RampRoutine, Parent, Interval, IntervalUnits, RampMax)
	self._RampRoutine = RampRoutine
	self._Parent = Parent
	self._Interval = Interval or RampTimer.DEFAULT_INTERVAL
	self._IntervalUnits = IntervalUnits or RampTimer.DEFAULT_UNITS
	self._RampMax = RampMax or RampTimer.DEFAULT_MAX_COUNT	-- failsafe, don't let the ramping run away

	self._IsEnabled = true
	self._RampCount = 0
	self._RampParameter = nil
	self._Timer = CreateTimer("RampTimer", self._Interval, self._IntervalUnits, RampTimer.Callback, false, self)
end


function RampTimer:destruct()
	self:Kill()
end

function RampTimer:SetInterval(Interval)
	self._Interval = Interval
end

function RampTimer:GetInterval()
	return self._Interval
end

function RampTimer:SetRampMaxCount(MaxCount)
	self._RampMax = MaxCount
end

function RampTimer:GetRampMaxCount()
	return self._RampMax
end

function RampTimer:SetRampParameter(Param)
	self._RampParameter = Param
end

function RampTimer:SetEnableFlag(EnableIt)
	self._IsEnabled = EnableIt
end

function RampTimer:IsEnabled()
	return self._IsEnabled
end

function RampTimer:IsRamping()
	return self._Timer:TimerStarted()
end

function RampTimer:Start(TimeInterval)
	self._RampCount = 0
	if(self._IsEnabled) then
		self._Timer:StartTimer(TimeInterval or self._Interval)
	end
end

function RampTimer:Kill()
	self._Timer:KillTimer()
	self._RampCount = 0
	self._RampParameter = nil
end

function RampTimer:DoCallback()
	self._RampCount = self._RampCount + 1
	
	if(self._RampCount < self._RampMax) then
		if(self._RampRoutine ~= nil) then
			self._RampRoutine(self._Parent, self._RampParameter)
		else
			LogWarn("RampTimer:DoCallback  Ramp routine not defined")
		end
	else
		self:Kill()
	end
end


function RampTimer.Callback(Instance)
	Instance:DoCallback()
end


