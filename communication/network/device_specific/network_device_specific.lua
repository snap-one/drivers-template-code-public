--[[=============================================================================
    File is: network_device_specific.lua
    Copyright 2022  Snap One, LLC. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.network_device_specific = "2022.11.10"
end


function ExtractNetworkMessage(MsgBuffer)
	local BytesConsumed = 0

	-----------------------------------------------
	-- Extract and use the next valid message from the buffer if one exists
	--
	-- Return the number of bytes used from the buffer.
	-- If there was no valid message return a 0
	-----------------------------------------------

	return BytesConsumed
end

--------------------

CMDS_IP = {
	--index:  Proxy Command Name
	--value:  Protocol Command Data

	--Power
	['ON']					= "",
	['OFF']					= "",

	--Input Toggle
	['INPUT_TOGGLE']		= "",

	--Menu
	['INFO']				= "",
	['GUIDE']				= "",
	['MENU']				= "",
	['CANCEL']				= "",
	['UP']					= "",
	['DOWN']				= "",
	['LEFT']				= "",
	['RIGHT']				= "",
	['ENTER']				= "",
	['RECALL']				= "",
	['PREV']				= "",

	--Digits
	['NUMBER_0']			= "",
	['NUMBER_1']			= "",
	['NUMBER_2']			= "",
	['NUMBER_3']			= "",
	['NUMBER_4']			= "",
	['NUMBER_5']			= "",
	['NUMBER_6']			= "",
	['NUMBER_7']			= "",
	['NUMBER_8']			= "",
	['NUMBER_9']			= "",
	['STAR']				= "",
	['POUND']				= "",

	--Volume
	['MUTE_ON']				= "",
	['MUTE_OFF']			= "",
	['MUTE_TOGGLE']			= "",
	['PULSE_VOL_DOWN']		= "",
	['PULSE_VOL_UP']		= "",
	['SET_VOLUME_LEVEL']	= "",

	--Tuning
	['SET_CHANNEL']			= "",
	['PULSE_CH_UP']			= "",
	['SKIP_FWD']			= "",
	['SCAN_FWD']			= "",
	['PULSE_CH_DOWN']		= "",
	['SKIP_REV']			= "",
	['SCAN_REV']			= "",

	--Status Query
	['GET_VOLUME_STATUS']	= "",
	['GET_MUTE_STATUS']		= "",
	['GET_POWER_STATUS']	= "",

	['CLOSED_CAPTIONED']	= "",
	['PROGRAM_A']			= "",  --RED
	['PROGRAM_B']			= "",  --GREEN
	['PROGRAM_C']			= "",  --YELLOW
	['PROGRAM_D']			= "",  --BLUE

	['PLAY']				= "",
	['PAUSE']				= "",
	['STOP']				= "",
	['RECORD']				= "",
	['PVR']					= "",

	-- Additional Device specific commands
--	['']					= "",

}

