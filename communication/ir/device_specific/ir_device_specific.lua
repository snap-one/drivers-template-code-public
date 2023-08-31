--[[=============================================================================
	File is: ir_device_specific.lua

    Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.ir_device_specific = "2022.04.04"
end

--------------------
----- IR COMMANDS -----
CMDS_IR = {
	--index:  Proxy Command Name
	--value:  IR Code ID
	--Power
	["ON"]				= "",
	["OFF"]				= "",

	--Input Toggle
	["INPUT_TOGGLE"]	= "",

	--Menu
	["INFO"]			= "",
	["GUIDE"]			= "",
	["MENU"]			= "",
	["CANCEL"]			= "",
	["UP"]				= "",
	["DOWN"]			= "",
	["LEFT"]			= "",
	["RIGHT"]			= "",
	["ENTER"]			= "",
	["RECALL"]			= "",
	["PREV"]			= "",

	--Digits
	["NUMBER_0"]		= "",
	["NUMBER_1"]		= "",
	["NUMBER_2"]		= "",
	["NUMBER_3"]		= "",
	["NUMBER_4"]		= "",
	["NUMBER_5"]		= "",
	["NUMBER_6"]		= "",
	["NUMBER_7"]		= "",
	["NUMBER_8"]		= "",
	["NUMBER_9"]		= "",
	["STAR"]			= "",
	["POUND"]			= "",

	--Volume
	["MUTE_ON"]			= "",
	["MUTE_OFF"]		= "",
	["MUTE_TOGGLE"]		= "",
	["PULSE_VOL_DOWN"]	= "",
	["PULSE_VOL_UP"]	= "",
	["SET_VOLUME_LEVEL"]	= "",

	--Tuning
	["SET_CHANNEL"]		= "",
	["PULSE_CH_UP"]		= "",
	["PULSE_CH_DOWN"]	= "",
	
	--Transport
	["PLAY"]			= "",
	["STOP"]			= "",
	["PAUSE"]			= "",
	["SKIP_FWD"]		= "",
	["SCAN_FWD"]		= "",
	["SKIP_REV"]		= "",
	["SCAN_REV"]		= "",
	["RECORD"]			= "",
	
	['CLOSED_CAPTIONED']	= "",
	['PROGRAM_A']		= "",  --RED
	['PROGRAM_B']		= "",  --GREEN
	['PROGRAM_C']		= "",  --YELLOW
	['PROGRAM_D']		= "",  --BLUE
	
}


--------------------

