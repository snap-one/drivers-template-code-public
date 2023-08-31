---
--- File is: c4_proxybase.lua
---
--- Copyright 2021 Snap One, LLC. All Rights Reserved.
---

require "lib.c4_object"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_proxybase = "2021.09.23"
end

---@class C4ProxyBase: c4_object
C4ProxyBase = inheritsFrom(nil)

C4ProxyBase.AllProxiesList = {}


function C4ProxyBase:construct(BindingID, ChildRef, InstanceName)
	self._BindingID = BindingID
	self._ChildRef = ChildRef
	self._InstanceName = InstanceName or ("Proxy_" .. tostring(BindingID))

	self._PersistData = {}

	C4ProxyBase.AllProxiesList[self._BindingID] = self._ChildRef
	C4ProxyBase.AllProxiesList[self._InstanceName] = self._ChildRef

	self._ProxyDeviceID, _ = next (C4:GetBoundConsumerDevices (C4:GetDeviceID(), self:GetBindingID()))
end

function C4ProxyBase:InitialSetup()
	-- override as needed
end


function C4ProxyBase:GetBindingID()
	return self._BindingID
end

function C4ProxyBase:GetProxyDeviceID()
	return self._ProxyDeviceID
end

function C4ProxyBase:GetTrueSelf()
	return self._ChildRef
end

function C4ProxyBase:GetProxyName()
	return self._InstanceName
end

----------------------------------------------------

function ProxyExists(BindingID)
	return (C4ProxyBase.AllProxiesList[BindingID] ~= nil)
end

function ProxyInstance(BindingID)
	return C4ProxyBase.AllProxiesList[BindingID]
end

---------------------------------------------------

