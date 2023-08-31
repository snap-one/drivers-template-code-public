--[[=============================================================================
    File is: pool_device_class.lua

    Pool Device Class

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "common.c4_utils"
require "lib.c4_proxybase"
require "lib.c4_log"
require "pool_proxy.pool_proxy_commands"
require "pool_proxy.pool_proxy_notifies"


-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_device_class = "2022.11.28"
end

Pool = inheritsFrom(C4ProxyBase)

--[[=============================================================================
    Functions that are meant to be private to the class
===============================================================================]]

function Pool:construct(BindingID, InstanceName)
	self:super():construct(BindingID, self, InstanceName)

	self._PersistRecordName = string.format("Pool%dPersist", tonumber(BindingID))
	PersistData[self._PersistRecordName] = C4:PersistGetValue(self._PersistRecordName)

	if(PersistData[self._PersistRecordName] == nil) then
		PersistData[self._PersistRecordName] = {
			_Scale = GetProjectTemperatureScale(),
			_PoolSetpoint = 0,
			_SpaSetpoint = 0,
			_PumpMode = "",
			_SpaMode = "",
			_AuxDeviceMap = {},
		}
		
		self:PersistSave()
	end

	self._PoolTemperature = 0
	self._SpaTemperature = 0
	self._AirTemperature = 0

	self._PersistData = PersistData[self._PersistRecordName]
end

----------------------

function Pool:PersistSave()
	C4:PersistSetValue(self._PersistRecordName, PersistData[self._PersistRecordName])
end

----------------------

function Pool:InitialSetup()
	self:InitializeVariables()
end


function Pool:InitializeVariables()
end

function Pool:AddAuxItem(Id, AuxItemId)
	self._PersistData._AuxDeviceMap[Id] = AuxItemId
	self:PersistSave()
end

function Pool:RemoveAuxItem(Id, PersistIt)
	PersistIt = PersistIt or true
	self._PersistData._AuxDeviceMap[Id] = nil
	if(PersistIt) then
		self:PersistSave()
	end
end

function Pool:GetAuxItem(Id)
	return self._PersistData._AuxDeviceMap[Id]
end


function Pool:GetTemperatureScale()
	return self._PersistData._Scale
end

function Pool:SetTemperatureScale(NewScale)
	if((NewScale == "F") or (NewScale == "C")) then
		if(self._PersistData._Scale ~= NewScale) then
			self._PersistData._Scale = NewScale
			NOTIFY.SCALE_CHANGED(self._PersistData._Scale, self._BindingID)
		end
	else
		LogError('Invalid Temperature Scale Type: %s  (Should be "C" or "F")', tostring(NewScale))
	end
end


function Pool:GetPoolTemperature()
	return self._PoolTemperature
end

function Pool:SetPoolTemperature(NewTemperature)
	local NumTemperature = tonumber(NewTemperature)
	if(NumTemperature ~= nil) then
		if(self._PoolTemperature ~= NewTemperature) then
			self._PoolTemperature = NewTemperature
			NOTIFY.POOL_TEMP_CHANGED(self._PoolTemperature, self._BindingID)
		end
	else
		LogError('Invalid Pool Temperature: %s  (Should be a number)', tostring(NewTemperature))
	end
end


function Pool:GetSpaTemperature()
	return self._SpaTemperature
end

function Pool:SetSpaTemperature(NewTemperature)
	local NumTemperature = tonumber(NewTemperature)
	if(NumTemperature ~= nil) then
		if(self._SpaTemperature ~= NewTemperature) then
			self._SpaTemperature = NewTemperature
			NOTIFY.SPA_TEMP_CHANGED(self._SpaTemperature, self._BindingID)
		end
	else
		LogError('Invalid Spa Temperature: %s  (Should be a number)', tostring(NewTemperature))
	end
end

function Pool:GetAirTemperature()
	return self._AirTemperature
end

function Pool:SetAirTemperature(NewTemperature)
	local NumTemperature = tonumber(NewTemperature)
	if(NumTemperature ~= nil) then
		if(self._AirTemperature ~= NewTemperature) then
			self._AirTemperature = NewTemperature
			NOTIFY.AIR_TEMP_CHANGED(self._AirTemperature, self._BindingID)
		end
	else
		LogError('Invalid Air Temperature: %s  (Should be a number)', tostring(NewTemperature))
	end
end

function Pool:GetPoolSetpoint()
	return self._PersistData._PoolSetpoint
end

function Pool:SetPoolSetpoint(NewSetpoint)
	local NumSetpoint = tonumber(NumSetpoint)
	if(NumSetpoint ~= nil) then
		if(self._PersistData._PoolSetpoint ~= NumSetpoint) then
			self._PersistData._PoolSetpoint = NumSetpoint
			NOTIFY.POOL_SETPOINT_CHANGED(self._PersistData._PoolSetpoint, self._BindingID)
		end
	else
		LogError('Invalid Pool Setpoint: %s  (Should be a number)', tostring(NumSetpoint))
	end
end

function Pool:GetSpaSetpoint()
	return self._PersistData._SpaSetpoint
end

function Pool:SetSpaSetpoint(NewSetpoint)
	local NumSetpoint = tonumber(NumSetpoint)
	if(NumSetpoint ~= nil) then
		if(self._PersistData._SpaSetpoint ~= NumSetpoint) then
			self._PersistData._SpaSetpoint = NumSetpoint
			NOTIFY.SPA_SETPOINT_CHANGED(self._PersistData._SpaSetpoint, self._BindingID)
		end
	else
		LogError('Invalid Spa Setpoint: %s  (Should be a number)', tostring(NumSetpoint))
	end
end

function Pool:GetPumpMode()
	return self._PersistData._PumpMode
end

function Pool:SetPumpMode(NewPumpMode)
	if(NewPumpMode ~= nil) then
		if(self._PersistData._PumpMode ~= NewPumpMode) then
			self._PersistData._PumpMode = NewPumpMode
			NOTIFY.PUMP_MODE_CHANGED(self._PersistData._PumpMode, self._BindingID)
		end
	else
		LogError('Invalid Pump Mode: %s', tostring(NewPumpMode))
	end
end

function Pool:GetSpaMode()
	return self._PersistData._SpaMode
end

function Pool:SetSpaMode(NewSpaMode)
	if(NewSpaMode ~= nil) then
		if(self._PersistData._SpaMode ~= NewSpaMode) then
			self._PersistData._SpaMode = NewSpaMode
			NOTIFY.SPA_MODE_CHANGED(self._PersistData._SpaMode, self._BindingID)
		end
	else
		LogError('Invalid Spa Mode: %s', tostring(NewSpaMode))
	end
end

function Pool:getAvailAuxDevicesXml()

	local BuildStr = ""
	for auxId, v in pairs(self._PersistData._AuxDeviceMap) do
		local AddDevice = true



		
		if(AddDevice) then
			local DeviceStr = AddElemnt("id", tostring(auxId))
			DeviceStr = DeviceStr .. AddElement("item_text", C4:XmlEscapeString(v.name))
			DeviceStr = DeviceStr .. AddElement("type", v.listType)

			BuildStr = BuildStr .. AddElement("item", DeviceStr)
		end

	end

	return AddElement("avail_aux_list", AddElement("items", BuildStr))
end

--=============================================================================
--=============================================================================

function Pool:PrxGetStateHandled()
	GET_STATE_HANDLED()
end

function Pool:PrxSetAuxMode(tParams)
	local id = tParams["ID"]
	local mode = tParams["MODE"]
	local aux_id = self._AuxDeviceMap[id]

	if (aux_id ~= nil and mode ~= nil) then
		PoolCom_SetAuxMode(aux_id, mode)
	end
end

function Pool:PrxSetPoolHeatmode(tParams)
	local id = tParams["ID"]
	local mode = HEAT_MODES[tParams["MODE"]]

	if (id ~= nil and mode ~= nil) then
		PoolCom_SetPoolHeatmode(id, mode)
	end
end

function Pool:PrxSetSpaHeatemode(tParams)
	local id = tParams["ID"]
	local mode = HEAT_MODES[tParams["MODE"]]

	if (id ~= nil and mode ~= nil) then
		PoolCom_SetSpaHeatmode(id, mode)
	end
end

function Pool:PrxSetPoolSetpoint(tParams)
	local setpoint = tParams["SETPOINT"]

	if (setpoint ~= nil) then
		PoolCom_SetPoolSetpoint(setpoint)
	end
end

function Pool:PrxSetSpaSetpoint(tParams)
	local setpoint = tParams["SETPOINT"]

	if (setpoint ~= nil) then
		PoolCom_SetSpaSetpoint(setpoint)
	end
end

function Pool:PrxSetPoolPumpmode(tParams)
	local pumpMode = tParams["PUMPMODE"]

	if (pumpMode ~= nil) then
		PoolCom_SetPoolPumpmode(pumpMode)
	end
end

function Pool:PrxSetSpaPumpmode(tParams)
	local pumpMode = tParams["PUMPMODE"]

	if (pumpMode ~= nil) then
		PoolCom_SetSpaPumpmode(pumpMode)
	end
end

function Pool:PrxAuxItemAdded(tParams)
	local id = tParams["ID"]
	local aux_id = tParams["AUX_ID"]
	-- local itemText = tParams["ITEM_TEXT"]
	-- local itemType = tParams["TYPE"]

	self:AddAuxItem(id, aux_id)
end

function Pool:PrxAuxItemUpdated(tParams)
	local id = tParams["ID"]
	local new_id = tParams["NEW_ID"]
	local aux_id = self._AuxDeviceMap[id]

	self:RemoveAuxItem(id, false)
	self:AddAuxItem(new_id, aux_id)
end

function Pool:PrxAuxItemRemoved(tParams)
	local id = tParams["ID"]
	self:RemoveAuxItem(id, true)
end

--[[=============================================================================
    Pool Proxy UIRequests
===============================================================================]]
function Pool:ReqGetAuxList(tParams)
	return self:getAvailAuxDevicesXml()
end
