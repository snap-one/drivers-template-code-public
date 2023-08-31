--[[=============================================================================
    Command Functions Received From Lock Proxy to the Driver

    Copyright 2021 Wirepath Home Systems LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.lock_proxy_commands = "2021.06.24"
end


---------------------------------------------------------------

function PRX_CMD.LOCK(idBinding, tParams)
	LogTrace("PRX_CMD.LOCK")
	ProxyInstance(idBinding):PrxLock()
end


function PRX_CMD.UNLOCK(idBinding, tParams)
	LogTrace("PRX_CMD.UNLOCK")
	ProxyInstance(idBinding):PrxUnlock()
end


function PRX_CMD.TOGGLE(idBinding, tParams)
	LogTrace("PRX_CMD.TOGGLE")
	ProxyInstance(idBinding):PrxToggle()
end


function PRX_CMD.REQUEST_CAPABILITIES(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_CAPABILITIES")
	ProxyInstance(idBinding):PrxRequestCapabilities()
end


function PRX_CMD.REQUEST_SETTINGS(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_SETTINGS")
	ProxyInstance(idBinding):PrxRequestSettings()
end


function PRX_CMD.REQUEST_CUSTOM_SETTINGS(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_CUSTOM_SETTINGS")
	ProxyInstance(idBinding):PrxRequestCustomSettings()
end


function PRX_CMD.REQUEST_HISTORY(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_HISTORY")
	ProxyInstance(idBinding):PrxRequestHistory()
end


function PRX_CMD.REQUEST_USERS(idBinding, tParams)
	LogTrace("PRX_CMD.REQUEST_USERS")
	ProxyInstance(idBinding):PrxRequestUsers()
end


function PRX_CMD.EDIT_USER(idBinding, tParams)
	LogTrace("PRX_CMD.EDIT_USER")
	ProxyInstance(idBinding):PrxEditUser(tParams)
end


function PRX_CMD.ADD_USER(idBinding, tParams)
	LogTrace("PRX_CMD.ADD_USER")
	ProxyInstance(idBinding):PrxAddUser(tParams)
end


function PRX_CMD.DELETE_USER(idBinding, tParams)
	LogTrace("PRX_CMD.DELETE_USER")
	ProxyInstance(idBinding):PrxDeleteUser(tParams)
end


function PRX_CMD.SET_ADMIN_CODE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_ADMIN_CODE")
	ProxyInstance(idBinding):PrxSetAdminCode(tParams)
end


function PRX_CMD.SET_SCHEDULE_LOCKOUT_ENABLED(idBinding, tParams)
	LogTrace("PRX_CMD.SET_SCHEDULE_LOCKOUT_ENABLED")
	ProxyInstance(idBinding):PrxSetScheduleLockoutEnabled(tParams)
end


function PRX_CMD.SET_NUMBER_LOG_ITEMS(idBinding, tParams)
	LogTrace("PRX_CMD.SET_NUMBER_LOG_ITEMS")
	ProxyInstance(idBinding):PrxSetNumberLogItems(tParams)
end


function PRX_CMD.SET_AUTO_LOCK_SECONDS(idBinding, tParams)
	LogTrace("PRX_CMD.SET_AUTO_LOCK_SECONDS")
	ProxyInstance(idBinding):PrxSetAutoLockSeconds(tParams)
end


function PRX_CMD.SET_LOCK_MODE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_LOCK_MODE")
	ProxyInstance(idBinding):PrxSetLockMode(tParams)
end


function PRX_CMD.SET_LOG_FAILED_ATTEMPTS(idBinding, tParams)
	LogTrace("PRX_CMD.SET_LOG_FAILED_ATTEMPTS")
	ProxyInstance(idBinding):PrxSetLogFailedAttempts(tParams)
end


function PRX_CMD.SET_WRONG_CODE_ATTEMPTS(idBinding, tParams)
	LogTrace("PRX_CMD.SET_WRONG_CODE_ATTEMPTS")
	ProxyInstance(idBinding):PrxSetWrongCodeAttempts(tParams)
end


function PRX_CMD.SET_SHUTOUT_TIMER(idBinding, tParams)
	LogTrace("PRX_CMD.SET_SHUTOUT_TIMER")
	ProxyInstance(idBinding):PrxSetShutoutTimer(tParams)
end


function PRX_CMD.SET_LANGUAGE(idBinding, tParams)
	LogTrace("PRX_CMD.SET_LANGUAGE")
	ProxyInstance(idBinding):PrxSetLanguage(tParams)
end


function PRX_CMD.SET_VOLUME(idBinding, tParams)
	LogTrace("PRX_CMD.SET_VOLUME")
	ProxyInstance(idBinding):PrxSetVolume(tParams)
end


function PRX_CMD.SET_ONE_TOUCH_LOCKING(idBinding, tParams)
	LogTrace("PRX_CMD.SET_ONE_TOUCH_LOCKING")
	ProxyInstance(idBinding):PrxSetOneTouchLocking(tParams)
end


function PRX_CMD.SET_CUSTOM_SETTING(idBinding, tParams)
	LogTrace("PRX_CMD.SET_CUSTOM_SETTING")
	ProxyInstance(idBinding):PrxSetCustomSetting(tParams)
end



