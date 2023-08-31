--[[==============================================================
	File is: unittest.lua
	Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
	Generic unit test base
=================================================================]]

package.path = 
	"./?.lua;" ..
	"../modify/?.lua;" ..
	"../?.lua;" ..
	"../../?.lua;" ..
	"../../../?.lua;" ..
	"../../../../UnitTestCom/?.lua;"
	
require 'lua_unittest_common'

--================================================================

function MockSetupLockCommon()
	___AddVariable:whenCalled{with={"LAST_UNLOCKED_BY", "-", "STRING", true}, thenReturn={}}
	
	___GetCapability:whenCalled{with={"is_management_only"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_admin_code"}, thenReturn={true}}
	___GetCapability:whenCalled{with={"has_schedule_lockout"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_auto_lock_time"}, thenReturn={}}
	___GetCapability:whenCalled{with={"auto_lock_time_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"auto_lock_time_display_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_log_item_count"}, thenReturn={}}
	___GetCapability:whenCalled{with={"log_item_count_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_lock_modes"}, thenReturn={}}
	___GetCapability:whenCalled{with={"lock_modes_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_log_failed_attempts"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_wrong_code_attempts"}, thenReturn={}}
	___GetCapability:whenCalled{with={"wrong_code_attempts_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_shutout_timer"}, thenReturn={}}
	___GetCapability:whenCalled{with={"shutout_timer_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"shutout_timer_display_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_language"}, thenReturn={}}
	___GetCapability:whenCalled{with={"language_values"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_volume"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_one_touch_locking"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_daily_schedule"}, thenReturn={true}}
	___GetCapability:whenCalled{with={"has_date_range_schedule"}, thenReturn={}}
	___GetCapability:whenCalled{with={"max_users"}, thenReturn={32}}
	___GetCapability:whenCalled{with={"has_settings"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_custom_settings"}, thenReturn={}}
	___GetCapability:whenCalled{with={"has_internal_history"}, thenReturn={}}

	C4NotificationMock:Reset()
	C4LogMock:Reset()

	___AddTimer = function(...)	end
	
	PersistData = {}
	AllUsersInfo = {}
	AllUsersByPassCode = {}
	LockHistoryEvents = {}
	gCurHistoryID = 1

end

require 'unittest_lock_main'
require 'unittest_lock_device_class'
require 'unittest_lock_reports'
require 'unittest_lock_user_info'
require 'unittest_lock_apis'
require 'unittest_lock_history'
require 'unittest_lock_proxy_commands'
require 'unittest_lock_proxy_notifies'
require 'unittest_lock_custom_settings'
--================================================================

RunExecution()


