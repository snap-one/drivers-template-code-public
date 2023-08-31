--[[=============================================================================
    File is: c4_metrics.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
	
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.av_metrics = "2022.05.05"
end

require "lib.c4_object"

C4Metrics = inheritsFrom(nil)

MINUTES_PER_DAY = 1440		-- 60 * 24

DataLakeMetrics = nil


function ON_DRIVER_INIT.DataLakeMetrics_init()
	DataLakeMetrics = C4Metrics:new()
end


function C4Metrics:construct()

	if(PersistData._DailyStats == nil) then
		PersistData._DailyStats = {
			MiniAppSelected = {},
			Counters = {},
			Gauges = {},
		}
	
	end

	if(PersistData._C4MetricsInfo == nil) then
		PersistData._C4MetricsInfo = {
			_UseSandbox = false,
			_Group = tostring (C4:GetDriverConfigInfo('name')),
			_Version = tostring(tonumber(C4:GetDriverConfigInfo('version'))),
			_Identifier = '',
		}
	
	end

	self._DailyStats = PersistData._DailyStats
	
	local driverName = C4Metrics.GetSafeString(C4:GetDriverConfigInfo ('name'))
	local driverId = C4Metrics.GetSafeString(tostring (C4:GetDeviceID ()))
	
	self:SetNamespaceInfo()
	
	self._DailyStatsTimer = CreateTimer("DailyStats", MINUTES_PER_DAY, "MINUTES", C4Metrics.DailyStatsCallback, false, self)

	local Now = os.date("*t")
	local MinutesLeftToday = MINUTES_PER_DAY - ((Now.hour * 60) + Now.min)
	local MinuteOffset = math.random(10, 45)		-- so that every project doesn't report at the same time
	self._DailyStatsTimer:StartTimer(MinutesLeftToday + MinuteOffset)

end


function C4Metrics:SetNamespaceInfo(group, version, identifier)

	if(group ~= nil) then
		PersistData._C4MetricsInfo._Group = tostring(group)
	end

	if(version ~= nil) then
		PersistData._C4MetricsInfo._Version = tostring(tonumber(version))
	end

	if(identifier ~= nil) then
		PersistData._C4MetricsInfo._Identifier = tostring(identifier)
	end

	local group = C4Metrics.GetSafeString(PersistData._C4MetricsInfo._Group)
	local version = C4Metrics.GetSafeString(PersistData._C4MetricsInfo._Version)
	local identifier = C4Metrics.GetSafeString(identifier, true)
	local driverName = C4Metrics.GetSafeString(C4:GetDriverConfigInfo('name'))
	local driverId = C4Metrics.GetSafeString(tostring (C4:GetDeviceID()))

	local namespace = {
		'drivers',
		group,
		version,
		identifier,
		driverName,
		driverId,
	}

	if(PersistData._C4MetricsInfo._UseSandbox) then
		table.insert (namespace, 1, 'sandbox')
	end

	self._NameSpace = table.concat (namespace, '.')
end


------------

function C4Metrics:SetCounter(key, value, sampleRate)
	if (not C4.StatsdCounter) then
		return
	end

	LogTrace("C4Metrics:SetCounter -> %s", tostring(key))
	value = value or 1
	if(	C4Metrics.VerifyIsString(key, "SetCounter key") and
		C4Metrics.VerifyIsNumber(value, "SetCounter value")) then
	   
		C4:StatsdCounter(self._NameSpace, C4Metrics.GetSafeString(key), value, (sampleRate or 0))
	end
end

function C4Metrics:SetGauge(key, value)
	if (not C4.StatsdGauge) then
		return
	end

	LogTrace("C4Metrics:SetGauge -> %s %d", tostring(key), tonumber(value))
	if(	C4Metrics.VerifyIsString(key, "SetGauge key") and
		C4Metrics.VerifyIsNumber(value, "SetGauge value")) then
	   
		C4:StatsdGauge(self._NameSpace, C4Metrics.GetSafeString(key), value)
	end
end

function C4Metrics:AdjustGauge(key, value)
	if (not C4.StatsdAdjustGauge) then
		return
	end

	LogTrace("C4Metrics:AdjustGauge -> %s %d", tostring(key), tonumber(value))
	if(	C4Metrics.VerifyIsString(key, "AdjustGauge key") and
		C4Metrics.VerifyIsNumber(value, "AdjustGauge value")) then
	   
		C4:StatsdAdjustGauge(self._NameSpace, C4Metrics.GetSafeString(key), value)
	end
end

function C4Metrics:SetTimer(key, value)
	if (not C4.StatsdTimer) then
		return
	end

	LogTrace("C4Metrics:SetTimer -> %s %d", tostring(key), tonumber(value))
	if(	C4Metrics.VerifyIsString(key, "SetTimer key") and
		C4Metrics.VerifyIsNumber(value, "SetTimer value")) then
	   
		C4:StatsdTimer(self._NameSpace, C4Metrics.GetSafeString(key), value)
	end
end

function C4Metrics:SetString(key, value)
	if (not C4.StatsdString) then
		return
	end

	LogTrace("C4Metrics:SetString -> %s %s", tostring(key), tostring(value))
	if(	C4Metrics.VerifyIsString(key, "SetString key") and
		C4Metrics.VerifyIsString(value, "SetString value")) then

		value = string.gsub (value, '[\r\n]+', '    ')
	   
		C4:StatsdString(self._NameSpace, C4Metrics.GetSafeString(key), value)
	end
end

function C4Metrics:SetJSONString(key, value)
	if (not C4.StatsdJSONObject) then
		return
	end

	LogTrace("C4Metrics:SetJSONString -> %s %s", tostring(key), tostring(value))
	if(	C4Metrics.VerifyIsString(key, "SetJSON key") and
		C4Metrics.VerifyIsString(value, "SetJSON value")) then

		value = string.gsub (value, '[\r\n]+', '    ')
	   
		C4:StatsdJSONObject(self._NameSpace, C4Metrics.GetSafeString(key), value)
	end
end

function C4Metrics:SetIncrementingMeter(key, value)
	if (not C4.StatsdIncrementMeter) then
		return
	end
	
	LogTrace("C4Metrics:SetIncrementingMeter -> %s %d", tostring(key), tonumber(value))
	if(	C4Metrics.VerifyIsString(key, "SetIncrementingMeter key") and
		C4Metrics.VerifyIsNumber(value, "SetIncrementingMeter value")) then
	   
		C4:StatsdIncrementMeter(self._NameSpace, C4Metrics.GetSafeString(key), value)
	end
end


--=================================================================

function C4Metrics.VerifyIsString(CheckVal, ErrorMsg)
	if(type(CheckVal) == 'string') then
		return true
	else
		LogWarn("%s Value must be string: %s", ErrorMsg, tostring(CheckVal))
		return false
	end
end

function C4Metrics.VerifyIsNumber(CheckVal, ErrorMsg)
	if(type(CheckVal) == 'number') then
		return true
	else
		LogWarn("%s Value must be number: %s", ErrorMsg, tostring(CheckVal))
		return false
	end
end

function C4Metrics.GetSafeString (s, ignoreUselessStrings)
	if (s == nil) then
		return ''
	end

	s = tostring (s)
	local p = '[^%w%-%_]+'
	local safe = string.gsub (s, p, '_')

	if (ignoreUselessStrings ~= true and string.gsub (safe, '_', '') == '') then
		LogWarn('C4Metrics.GetSafeString - generated a non-useful string')
	end

	return safe
end

--=================================================================
--  Daily Stats

function C4Metrics.DailyStatsCallback(MetricsInst)
	MetricsInst:DoDailyStats()
end

function C4Metrics:DoDailyStats()
	LogTrace("C4Metrics:DoDailyStats")
	LogInfo(self._DailyStats)
	local StatsStr = C4:JsonEncode(self._DailyStats)

	if string.len(StatsStr) >= 1485 then --json limit is 1500. 1485 approx metric name length + decoration + payload
		self:SetCounter('MetricsdJSONLimitError')
	else
		self:SetJSONString('DailyStats', StatsStr)
	end

	-- Clear to start next day
	self._DailyStats.MiniAppSelected = {}
	self._DailyStats.Counters = {}
	self._DailyStats.Gauges = {}

	self._DailyStatsTimer:StartTimer()
end

function C4Metrics:DailyStatsCounter(MetStr)
	if(self._DailyStats.Counters[MetStr] ~= nil) then
		self._DailyStats.Counters[MetStr] = self._DailyStats.Counters[MetStr] + 1
	else
		self._DailyStats.Counters[MetStr] = 1
	end
end

function C4Metrics:MetricsCounter(MetStr)
	self:SetCounter(MetStr)
	self:DailyStatsCounter(MetStr)
end

function C4Metrics:DailyStatsGauge(MetStr, Value)
	self._DailyStats.Gauges[MetStr] = Value
end

function C4Metrics:MetricsGauge(MetStr, Value)
	LogTrace("C4Metrics:MetricsGauge -> %s - %s", tostring(MetStr), tostring(Value))
	self:SetGauge(MetStr, Value)
	self:DailyStatsGauge(MetStr, Value)
end

function C4Metrics:DailyStatsMiniAppSelectedCounter(MetStr)
	if(self._DailyStats.MiniAppSelected[MetStr] ~= nil) then
		self._DailyStats.MiniAppSelected[MetStr] = self._DailyStats.MiniAppSelected[MetStr] + 1
	else
		self._DailyStats.MiniAppSelected[MetStr] = 1
	end
end

--==================================================

function GetMetricsNamespace()
	if (DataLakeMetrics ~= nil) then
		return DataLakeMetrics._NameSpace
	else
		LogWarn("GetMetricsNamespace DataLake Metrics not defined")
		return ""
	end
end

function SetMetricsNamespaceInfo(Group, Version, Identifier)
	if(DataLakeMetrics ~= nil) then
		DataLakeMetrics:SetNamespaceInfo(Group, Version, Identifier)
	else
		LogWarn("SetMetricsNamespaceInfo DataLake Metrics not defined")
	end
end


function GetMetricsDevelopmentFlag()
	return PersistData._UseMetricsSandbox
end

function SetMetricsDevelopmentFlag(UseSandbox)
	PersistData._C4MetricsInfo._UseSandbox = UseSandbox
	if(DataLakeMetrics ~= nil) then
		DataLakeMetrics:SetNamespaceInfo()
	end
end


--==================================================

