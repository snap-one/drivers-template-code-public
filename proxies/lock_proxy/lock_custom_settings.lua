--[[=============================================================================
    File is: lock_custom_settings.lua

    Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_object"
require "lib.c4_log"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_custom_settings = "2020.04.06"
end

LockCustomSettings = {
	_BindingID = 0,
	_SettingsList = {}
}


function LockCustomSettings:SetBindingID(BindingID)
	self._BindingID = BindingID
end

function LockCustomSettings:GetBindingID()
	return self._BindingID
end

-------------------------------------------------------------------

LockCustomSettingBase = inheritsFrom(nil)

function LockCustomSettingBase:construct(SettingName, SettingValue, ChildRef)
	self._Name = tostring(SettingName)
	self._Value = SettingValue
	
	LockCustomSettings._SettingsList[self._Name] = ChildRef
end


function LockCustomSettingBase:destruct()
	LockCustomSettings._SettingsList[self._Name] = nil
end


function LockCustomSettingBase:GetName()
	return self._Name
end

function LockCustomSettingBase:GetValue()
	return self._Value
end


function LockCustomSettingBase:SetValue(NewValue)
	self._Value = NewValue
	
	LockReport_UpdateCustomSetting(self:GetName(), tostring(self:GetValue()))
end


-------------------------------------------------------------------------------------

LockCustomSettingBoolean = inheritsFrom(LockCustomSettingBase)

function LockCustomSettingBoolean:construct(SettingName, SettingValue)
	self:super():construct(SettingName, toboolean(SettingValue), self)
end


function LockCustomSettingBoolean:GetSettingXML()
	return MakeXMLNode("custom_setting",	MakeXMLNode("name", self:GetName()) ..
											MakeXMLNode("type", "BOOLEAN") ..
											MakeXMLNode("value", tostring(self:GetValue()))
					  )
end


function LockCustomSettingBoolean:SetValue(NewValue)
	self:super():SetValue(toboolean(NewValue))
end

-------------------------------------------------------------------------------------

LockCustomSettingString = inheritsFrom(LockCustomSettingBase)

function LockCustomSettingString:construct(SettingName, SettingValue)
	self:super():construct(SettingName, tostring(SettingValue), self)
end


function LockCustomSettingString:GetSettingXML()
	return MakeXMLNode("custom_setting",	MakeXMLNode("name", self:GetName()) ..
											MakeXMLNode("type", "STRING") ..
											MakeXMLNode("value", self:GetValue())
					  )
end


function LockCustomSettingString:SetValue(NewValue)
	self:super():SetValue(tostring(NewValue))
end

-------------------------------------------------------------------------------------

LockCustomSettingList = inheritsFrom(LockCustomSettingBase)

function LockCustomSettingList:construct(SettingName, SettingValue, ListValues)
	self:super():construct(SettingName, tostring(SettingValue), self)
	
	local ValuesWorkTable = StringSplit(ListValues, ",")
	
	self._ValuesList = {}
	self._ListItemsXMLStr = ""

	for _, CurItem in ipairs(ValuesWorkTable) do
		self._ValuesList[CurItem] = true
		self._ListItemsXMLStr = self._ListItemsXMLStr .. MakeXMLNode("item", CurItem)
	end
end


function LockCustomSettingList:GetSettingXML()

	return MakeXMLNode("custom_setting",	MakeXMLNode("name", self:GetName()) ..
											MakeXMLNode("type", "LIST") ..
											MakeXMLNode("items", self._ListItemsXMLStr) ..
											MakeXMLNode("value", self:GetValue())
					  )
end


function LockCustomSettingList:SetValue(NewValue)
	local sNewValue = tostring(NewValue)
	if(self._ValuesList[sNewValue]) then
		self:super():SetValue(sNewValue)
	else
		LogError("LockCustomSettingList:SetValue  Value not in valid list: %s", sNewValue)
	end
end

-------------------------------------------------------------------------------------

LockCustomSettingInteger = inheritsFrom(LockCustomSettingBase)

function LockCustomSettingInteger:construct(SettingName, SettingValue, MinValue, MaxValue)
	self:super():construct(SettingName, tointeger(SettingValue), self)
	
	self._MaxValue = tointeger(MaxValue)
	self._MinValue = tointeger(MinValue)
end


function LockCustomSettingInteger:GetSettingXML()
	return MakeXMLNode("custom_setting",	MakeXMLNode("name", self:GetName()) ..
											MakeXMLNode("type", "RANGED_INTEGER") ..
											MakeXMLNode("minimum", tostring(self._MinValue)) ..
											MakeXMLNode("maximum", tostring(self._MaxValue)) ..
											MakeXMLNode("value", tostring(self:GetValue()))
					  )
end


function LockCustomSettingInteger:SetValue(NewValue)
	local nNewValue = tointeger(NewValue)

	if((nNewValue >= self._MinValue) and (nNewValue <= self._MaxValue)) then
		self:super():SetValue(tointeger(NewValue))
	else
		LogError("LockCustomSettingInteger:SetValue  Value out of range: %d", nNewValue)
	end
end

-------------------------------------------------------------------------------------

LockCustomSettingFloat = inheritsFrom(LockCustomSettingBase)

function LockCustomSettingFloat:construct(SettingName, SettingValue, MinValue, MaxValue)
	self:super():construct(SettingName, tonumber(SettingValue), self)
	
	self._MaxValue = tonumber(MaxValue)
	self._MinValue = tonumber(MinValue)
end


function LockCustomSettingFloat:GetSettingXML()
	return MakeXMLNode("custom_setting",	MakeXMLNode("name", self:GetName()) ..
											MakeXMLNode("type", "RANGED_FLOAT") ..
											MakeXMLNode("minimum", string.format("%0.2f", self._MinValue)) ..
											MakeXMLNode("maximum", string.format("%0.2f", self._MaxValue)) ..
											MakeXMLNode("value", string.format("%0.2f", self:GetValue()))
					  )
end


function LockCustomSettingFloat:SetValue(NewValue)
	local nNewValue = tonumber(NewValue)

	if((nNewValue >= self._MinValue) and (nNewValue <= self._MaxValue)) then
		self:super():SetValue(tonumber(NewValue))
	else
		LogError("LockCustomSettingFloat:SetValue  Value out of range: %0.2f", nNewValue)
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

function Lock_AddCustomSettingBoolean(SettingName, SettingValue)
	LogTrace("Lock_AddCustomSettingBoolean  %s  %s", tostring(SettingName), tostring(SettingValue))
	return LockCustomSettingBoolean:new(SettingName, toboolean(SettingValue))
end


function Lock_AddCustomSettingString(SettingName, SettingValue)
	LogTrace("Lock_AddCustomSettingString  %s  %s", tostring(SettingName), tostring(SettingValue))
	return LockCustomSettingString:new(tostring(SettingName), tostring(SettingValue))
end


function Lock_AddCustomSettingList(SettingName, SettingValue, ListValues)
	LogTrace("Lock_AddCustomSettingList  %s  %s %s", tostring(SettingName), tostring(SettingValue), tostring(ListValues))
	return LockCustomSettingList:new(tostring(SettingName), SettingValue, tostring(ListValues))
end


function Lock_AddCustomSettingRangedInteger(SettingName, SettingValue, MinValue, MaxValue)
	LogTrace("Lock_AddCustomSettingList  %s  %d  Min: %d  Max: %d", tostring(SettingName), tonumber(SettingValue), tonumber(MinValue), tonumber(MaxValue))
	return LockCustomSettingInteger:new(tostring(SettingName), SettingValue, MinValue, MaxValue)
end


function Lock_AddCustomSettingRangedFloat(SettingName, SettingValue, MinValue, MaxValue)
	LogTrace("Lock_AddCustomSettingRangedFloat  %s  %0.2f  Min: %0.2f  Max: %0.2f", tostring(SettingName), tonumber(SettingValue), tonumber(MinValue), tonumber(MaxValue))
	return LockCustomSettingFloat:new(tostring(SettingName), SettingValue, MinValue, MaxValue)
end


function Lock_UpdateCustomSetting(SettingName, SettingValue)
	LogTrace("Lock_UpdateCustomSetting  %s  %s", tostring(SettingName), tostring(SettingValue))
	if(LockCustomSettings._SettingsList[SettingName] ~= nil) then
		LockCustomSettings._SettingsList[SettingName]:SetValue(SettingValue)
	else
		LogInfo("Lock_UpdateCustomSetting  Undefined Setting: %s", tostring(SettingName))
	end
end


function Lock_DeleteCustomSetting(SettingName)
	LogTrace("Lock_DeleteCustomSetting  %s", tostring(SettingName))

	if(LockCustomSettings._SettingsList[SettingName] ~= nil) then
		LockCustomSettings._SettingsList[SettingName]:destruct()
	else
		LogInfo("Lock_DeleteCustomSetting  Undefined Setting: %s", tostring(SettingName))
	end
end


function GetAllCustomSettingsXML()
	local AllSettingsStr = ""
	
	for _, CurCustomSetting in pairs(LockCustomSettings._SettingsList) do
		AllSettingsStr = AllSettingsStr .. CurCustomSetting:GetSettingXML()
	end
	
	return MakeXMLNode("lock_custom_settings", AllSettingsStr)
end


