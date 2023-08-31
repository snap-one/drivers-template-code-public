---
--- Notification Functions
---
--- Copyright 2016 Control4 Corporation. All Rights Reserved.
---
require "common.c4_driver_declarations"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_notify = "2016.01.08"
end


---Forwards a notification to the proxy with a list of parameters
---
---@param notifyText string The function identifier for the proxy
---@param tParams table Table of key value pairs that hold the the parameters and their values used in the proxy function
---@param bindingID integer The requests binding id
function SendNotify(notifyText, tParams, bindingID)
	C4:SendToProxy(bindingID, notifyText, tParams, "NOTIFY")
end


---Forwards a notification to the proxy with no parameters
---
---@param notifyText string The function identifier for the proxy
---@param bindingID integer? Optional parameter containing the requests binding id, if not specified then the DEFAULT_PROXY_ID is given.
function SendSimpleNotify(notifyText, bindingID)
	C4:SendToProxy(bindingID or DEFAULT_PROXY_BINDINGID, notifyText, {}, "NOTIFY")
end