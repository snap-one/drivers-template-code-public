--[[=============================================================================
    Command Functions Received From Security Proxy to the Driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
==============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.security_proxy_commands = "2021.06.23"
end


function PRX_CMD.KEY_PRESS(idBinding, tParams)
	LogTrace("PRX_CMD.KEY_PRESS")
	ProxyInstance(idBinding):PrxKeyPress(tParams)
end

function PRX_CMD.PARTITION_ARM(idBinding, tParams)
	LogTrace("PRX_CMD.PARTITION_ARM")
	ProxyInstance(idBinding):PrxPartitionArm(tParams)
end

function PRX_CMD.PARTITION_DISARM(idBinding, tParams)
	LogTrace("PRX_CMD.PARTITION_DISARM")
	ProxyInstance(idBinding):PrxPartitionDisarm(tParams)
end

function PRX_CMD.ARM_CANCEL(idBinding, tParams)
	LogTrace("PRX_CMD.ARM_CANCEL")
	ProxyInstance(idBinding):PrxArmCancel(tParams)
end

function PRX_CMD.EXECUTE_EMERGENCY(idBinding, tParams)
	LogTrace("PRX_CMD.EXECUTE_EMERGENCY")
	ProxyInstance(idBinding):PrxExecuteEmergency(tParams)
end

function PRX_CMD.EXECUTE_FUNCTION(idBinding, tParams)
	LogTrace("PRX_CMD.EXECUTE_FUNCTION")
	ProxyInstance(idBinding):PrxExecuteFunction(tParams)
end

function PRX_CMD.ADDITIONAL_INFO(idBinding, tParams)
	LogTrace("PRX_CMD.ADDITIONAL_INFO %s", tostring(idBinding))
	ProxyInstance(idBinding):PrxAdditionalInfo(tParams)
end

function PRX_CMD.SET_DEFAULT_USER_CODE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_DEFAULT_USER_CODE")
	ProxyInstance(idBinding):PrxSetDefaultUserCode(tParams)
end

function PRX_CMD.SEND_CONFIRMATION(idBinding, tParams)
	LogTrace("PRX_CMD.SEND_CONFIRMATION")
	ProxyInstance(idBinding):PrxSendConfirmation(tParams)
end



