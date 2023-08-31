--[[==============================================================
	File is: unittest_lock_custom_settings.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
=================================================================]]

require 'lock_main'

c4test_LockCustomSettings = {}

function c4test_LockCustomSettings:setUp()
	CreateC4Mocks()
	MockSetupLockCommon()

	LockCustomSettings._BindingID = 0
	LockCustomSettings._SettingsList = {}
end


function c4test_LockCustomSettings:tearDown()
	LockCustomSettings._SettingsList = {}
end

-------------------------------------------------------------------------------------------------

function c4test_LockCustomSettings:c4test_LockCustomSettingBoolean()
	LogTrace("c4test_LockCustomSettings:LockCustomSettingBoolean...")

	local TestBoolName = "BoolTest1"
	local TestBoolSetting = LockCustomSettingBoolean:new(TestBoolName, true)

	lu.assertEquals(LockCustomSettings._SettingsList[TestBoolName], TestBoolSetting)
	lu.assertEquals(TestBoolSetting:GetName(), TestBoolName)
	lu.assertTrue(TestBoolSetting:GetValue())

	local TrueBoolXMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>BOOLEAN</type>" ..
			"<value>true</value>" ..
		"</custom_setting>", 
		TestBoolName)

	lu.assertEquals(TestBoolSetting:GetSettingXML(), TrueBoolXMLRef)

	TestBoolSetting:SetValue(false)
	lu.assertFalse(TestBoolSetting:GetValue())
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, TestBoolName)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, "false")

	local FalseBoolXMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>BOOLEAN</type>" ..
			"<value>false</value>" ..
		"</custom_setting>", 
		TestBoolName)

	lu.assertEquals(TestBoolSetting:GetSettingXML(), FalseBoolXMLRef)
end

function c4test_LockCustomSettings:c4test_LockCustomSettingString()
	LogTrace("c4test_LockCustomSettings:c4test_LockCustomSettingString...")

	local TestStringName = "StringTest1"
	local TestStringValue = "Happy String"
	local TestStringSetting = LockCustomSettingString:new(TestStringName, TestStringValue)

	lu.assertEquals(LockCustomSettings._SettingsList[TestStringName], TestStringSetting)
	lu.assertEquals(TestStringSetting:GetName(), TestStringName)
	lu.assertEquals(TestStringSetting:GetValue(), TestStringValue)

	local TestString1XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>STRING</type>" ..
			"<value>%s</value>" ..
		"</custom_setting>", 
		TestStringName, TestStringValue)

	lu.assertEquals(TestStringSetting:GetSettingXML(), TestString1XMLRef)

	local TestStringValue2 = "Sad String"

	TestStringSetting:SetValue(TestStringValue2)
	lu.assertEquals(TestStringSetting:GetValue(), TestStringValue2)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, TestStringName)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, TestStringValue2)

	local TestString2XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>STRING</type>" ..
			"<value>%s</value>" ..
		"</custom_setting>", 
		TestStringName, TestStringValue2)

	lu.assertEquals(TestStringSetting:GetSettingXML(), TestString2XMLRef)
end


function c4test_LockCustomSettings:c4test_LockCustomSettingList()
	LogTrace("c4test_LockCustomSettings:c4test_LockCustomSettingList...")

	local TestListName = "ListTest1"
	local TestListValue = "Item2"
	local TestListValidValues = "Item1,Item2,Item3"
	local TestListSetting = LockCustomSettingList:new(TestListName, TestListValue, TestListValidValues)

	lu.assertEquals(LockCustomSettings._SettingsList[TestListName], TestListSetting)
	lu.assertEquals(TestListSetting:GetName(), TestListName)
	lu.assertEquals(TestListSetting:GetValue(), TestListValue)

	local TestList1XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>LIST</type>" ..
			"<items>" ..
				"<item>Item1</item>" ..
				"<item>Item2</item>" ..
				"<item>Item3</item>" ..
			"</items>" ..
			"<value>%s</value>" ..
		"</custom_setting>", 
		TestListName, TestListValue)

	lu.assertEquals(TestListSetting:GetSettingXML(), TestList1XMLRef)

	local TestListValue2 = "Item3"

	TestListSetting:SetValue(TestListValue2)
	lu.assertEquals(TestListSetting:GetValue(), TestListValue2)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, TestListName)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, TestListValue2)

	local TestList2XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>LIST</type>" ..
			"<items>" ..
				"<item>Item1</item>" ..
				"<item>Item2</item>" ..
				"<item>Item3</item>" ..
			"</items>" ..
			"<value>%s</value>" ..
		"</custom_setting>", 
		TestListName, TestListValue2)

	lu.assertEquals(TestListSetting:GetSettingXML(), TestList2XMLRef)

	local BogusValue = "Item4"
	TestListSetting:SetValue(BogusValue)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCustomSettingList:SetValue  Value not in valid list: Item4")
end


function c4test_LockCustomSettings:c4test_LockCustomSettingInteger()
	LogTrace("c4test_LockCustomSettings:c4test_LockCustomSettingInteger...")

	local TestIntegerName = "IntegerTest1"
	local TestIntegerValue = 19
	local TestIntegerMinValue = 1
	local TestIntegerMaxValue = 50
	local TestIntegerSetting = LockCustomSettingInteger:new(TestIntegerName, TestIntegerValue, TestIntegerMinValue, TestIntegerMaxValue)

	lu.assertEquals(LockCustomSettings._SettingsList[TestIntegerName], TestIntegerSetting)
	lu.assertEquals(TestIntegerSetting:GetName(), TestIntegerName)
	lu.assertEquals(TestIntegerSetting:GetValue(), TestIntegerValue)

	local TestInteger1XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>RANGED_INTEGER</type>" ..
			"<minimum>%d</minimum>" ..
			"<maximum>%d</maximum>" ..
			"<value>%d</value>" ..
		"</custom_setting>", 
		TestIntegerName, TestIntegerMinValue, TestIntegerMaxValue, TestIntegerValue)

	lu.assertEquals(TestIntegerSetting:GetSettingXML(), TestInteger1XMLRef)

	local TestIntegerValue2 = 23

	TestIntegerSetting:SetValue(TestIntegerValue2)
	lu.assertEquals(TestIntegerSetting:GetValue(), TestIntegerValue2)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, TestIntegerName)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, tostring(TestIntegerValue2))

	local TestInteger2XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>RANGED_INTEGER</type>" ..
			"<minimum>%d</minimum>" ..
			"<maximum>%d</maximum>" ..
			"<value>%d</value>" ..
		"</custom_setting>", 
		TestIntegerName, TestIntegerMinValue, TestIntegerMaxValue, TestIntegerValue2)

	lu.assertEquals(TestIntegerSetting:GetSettingXML(), TestInteger2XMLRef)

	local BogusValue = 79
	TestIntegerSetting:SetValue(BogusValue)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCustomSettingInteger:SetValue  Value out of range: 79")
end


function c4test_LockCustomSettings:c4test_LockCustomSettingFloat()
	LogTrace("c4test_LockCustomSettings:c4test_LockCustomSettingFloat...")

	local TestFloatName = "FloatTest1"
	local TestFloatValue = 3.14
	local TestFloatMinValue = 0.05
	local TestFloatMaxValue = 11.93
	local TestFloatSetting = LockCustomSettingFloat:new(TestFloatName, TestFloatValue, TestFloatMinValue, TestFloatMaxValue)

	lu.assertEquals(LockCustomSettings._SettingsList[TestFloatName], TestFloatSetting)
	lu.assertEquals(TestFloatSetting:GetName(), TestFloatName)
	lu.assertEquals(TestFloatSetting:GetValue(), TestFloatValue)

	local TestFloat1XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>RANGED_FLOAT</type>" ..
			"<minimum>%0.2f</minimum>" ..
			"<maximum>%0.2f</maximum>" ..
			"<value>%0.2f</value>" ..
		"</custom_setting>", 
		TestFloatName, TestFloatMinValue, TestFloatMaxValue, TestFloatValue)

	lu.assertEquals(TestFloatSetting:GetSettingXML(), TestFloat1XMLRef)

	local TestFloatValue2 = 7.099

	TestFloatSetting:SetValue(TestFloatValue2)
	lu.assertEquals(TestFloatSetting:GetValue(), TestFloatValue2)
	lu.assertEquals(C4NotificationMock:GetLastNotificationMessage(), "CUSTOM_SETTING_CHANGED")
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().NAME, TestFloatName)
	lu.assertEquals(C4NotificationMock:GetLastNotificationParams().VALUE, tostring(TestFloatValue2))

	local TestFloat2XMLRef = string.format(
		"<custom_setting>" ..
			"<name>%s</name>" ..
			"<type>RANGED_FLOAT</type>" ..
			"<minimum>%0.2f</minimum>" ..
			"<maximum>%0.2f</maximum>" ..
			"<value>%0.2f</value>" ..
		"</custom_setting>", 
		TestFloatName, TestFloatMinValue, TestFloatMaxValue, TestFloatValue2)

	lu.assertEquals(TestFloatSetting:GetSettingXML(), TestFloat2XMLRef)

	local BogusValue = 22.22
	TestFloatSetting:SetValue(BogusValue)
	lu.assertEquals(C4LogMock:GetLastLine(), "UnitTest : LockCustomSettingFloat:SetValue  Value out of range: 22.22")
end

function c4test_LockCustomSettings:c4test_Lock_AddCustomSettingBoolean()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_AddCustomSettingBoolean...")
	
	local B1 = Lock_AddCustomSettingBoolean("BoolTest1", true)
	local B2 = Lock_AddCustomSettingBoolean("BoolTest2", false)

	lu.assertEquals(LockCustomSettings._SettingsList["BoolTest1"], B1)
	lu.assertEquals(LockCustomSettings._SettingsList["BoolTest2"], B2)
end

function c4test_LockCustomSettings:c4test_Lock_AddCustomSettingString()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_AddCustomSettingString...")
	
	local S1 = Lock_AddCustomSettingBoolean("StringTest1", "Mares eat oats and does eat oats")
	local S2 = Lock_AddCustomSettingBoolean("StringTest2", "and little lambs eat ivy")

	lu.assertEquals(LockCustomSettings._SettingsList["StringTest1"], S1)
	lu.assertEquals(LockCustomSettings._SettingsList["StringTest2"], S2)
end

function c4test_LockCustomSettings:c4test_Lock_AddCustomSettingList()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_AddCustomSettingList...")
	
	local L1 = Lock_AddCustomSettingList("ListTest1", "L1A", "L1A,L1B,L1C")
	local L2 = Lock_AddCustomSettingList("ListTest2", "L2A", "L2A,L2B,L2C")

	lu.assertEquals(LockCustomSettings._SettingsList["ListTest1"], L1)
	lu.assertEquals(LockCustomSettings._SettingsList["ListTest2"], L2)
end

function c4test_LockCustomSettings:c4test_Lock_AddCustomSettingRangedInteger()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_AddCustomSettingRangedInteger...")
	
	local I1 = Lock_AddCustomSettingRangedInteger("IntTest1", 8, 1, 20)
	local I2 = Lock_AddCustomSettingRangedInteger("IntTest2", 25, 10, 70)

	lu.assertEquals(LockCustomSettings._SettingsList["IntTest1"], I1)
	lu.assertEquals(LockCustomSettings._SettingsList["IntTest2"], I2)
end

function c4test_LockCustomSettings:c4test_Lock_AddCustomSettingRangedFloat()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_AddCustomSettingRangedFloat...")
	
	local F1 = Lock_AddCustomSettingRangedFloat("FloatTest1", 5.67, 2.0, 10.5)
	local F2 = Lock_AddCustomSettingRangedFloat("FloatTest2", 33.3333, 20.0, 52.7)

	lu.assertEquals(LockCustomSettings._SettingsList["FloatTest1"], F1)
	lu.assertEquals(LockCustomSettings._SettingsList["FloatTest2"], F2)
end

function c4test_LockCustomSettings:c4test_Lock_UpdateCustomSetting()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_UpdateCustomSetting...")

	local B1 = Lock_AddCustomSettingBoolean("Bool1", true)
	local S1 = Lock_AddCustomSettingString("Str1", "String1 Init")
	local L1 = Lock_AddCustomSettingList("List1", "LA", "LA,LB,LC")
	local I1 = Lock_AddCustomSettingRangedInteger("Int1", 30, 20, 60)
	local F1 = Lock_AddCustomSettingRangedFloat("Float1", 10.2, 5.25, 17.75)

	lu.assertEquals(B1:GetValue(), true)
	lu.assertEquals(S1:GetValue(), "String1 Init")
	lu.assertEquals(L1:GetValue(), "LA")
	lu.assertEquals(I1:GetValue(), 30)
	lu.assertEquals(F1:GetValue(), 10.2)

	Lock_UpdateCustomSetting("Bool1", false)
	Lock_UpdateCustomSetting("Str1", "String1 Changed")
	Lock_UpdateCustomSetting("List1", "LB")
	Lock_UpdateCustomSetting("Int1", 40)
	Lock_UpdateCustomSetting("Float1", 12.5)
	
	lu.assertEquals(B1:GetValue(), false)
	lu.assertEquals(S1:GetValue(), "String1 Changed")
	lu.assertEquals(L1:GetValue(), "LB")
	lu.assertEquals(I1:GetValue(), 40)
	lu.assertEquals(F1:GetValue(), 12.5)
end

function c4test_LockCustomSettings:c4test_Lock_DeleteCustomSetting()
	LogTrace("c4test_LockCustomSettings:c4test_Lock_UpdateCustomSetting...")

	Lock_AddCustomSettingBoolean("Bool1", true)
	Lock_AddCustomSettingString("Str1", "String1 Init")
	Lock_AddCustomSettingList("List1", "LA", "LA,LB,LC")
	Lock_AddCustomSettingRangedInteger("Int1", 30, 20, 60)
	Lock_AddCustomSettingRangedFloat("Float1", 10.2, 5.25, 17.75)

	lu.assertNotNil(LockCustomSettings._SettingsList["Bool1"])
	lu.assertNotNil(LockCustomSettings._SettingsList["Str1"])
	lu.assertNotNil(LockCustomSettings._SettingsList["List1"])
	lu.assertNotNil(LockCustomSettings._SettingsList["Int1"])
	lu.assertNotNil(LockCustomSettings._SettingsList["Float1"])
	
	Lock_DeleteCustomSetting("Bool1")
	lu.assertNil(LockCustomSettings._SettingsList["Bool1"])
	
	Lock_DeleteCustomSetting("Str1")
	lu.assertNil(LockCustomSettings._SettingsList["Str1"])
	
	Lock_DeleteCustomSetting("List1")
	lu.assertNil(LockCustomSettings._SettingsList["List1"])
	
	Lock_DeleteCustomSetting("Int1")
	lu.assertNil(LockCustomSettings._SettingsList["Int1"])
	
	Lock_DeleteCustomSetting("Float1")
	lu.assertNil(LockCustomSettings._SettingsList["Float1"])
end
	

