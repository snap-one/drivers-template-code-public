--[[=============================================================================
	File is: ip_server_main.lua
	Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require 'ip_server.ip_server_com'
require 'ip_server_device_specific'		-- in home directory


function SetupIPServer()
	C4:CreateServer (0)
end

