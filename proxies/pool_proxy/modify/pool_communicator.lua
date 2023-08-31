--[[=============================================================================
    File is: pool_communicator.lua

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.pool_communicator = "2022.11.23"
end


--============================================================================

function PoolCom_SetAuxMode(AuxId, Mode)
	LogTrace("PoolCom_SetAuxMode  %s -> %s", tostring(AuxId), tostring(Mode))
	LogInfo("Pool  Set Aux Mode Not Implemented")	-- default

end

function PoolCom_SetPoolHeatmode(HeaterID, Mode)
	LogTrace("PoolCom_SetPoolHeatmode  %s -> %s", tostring(HeaterID), tostring(Mode))
	LogInfo("Pool  Set Pool Heatmode Not Implemented")	-- default

end

function PoolCom_SetSpaHeatmode(HeaterID, Mode)
	LogTrace("PoolCom_SetSpaHeatmode  %s -> %s", tostring(HeaterID), tostring(Mode))
	LogInfo("Pool  Set Spa Heatmode Not Implemented")	-- default

end

function PoolCom_SetPoolSetpoint(Setpoint)
	LogTrace("PoolCom_SetPoolSetpoint  %s", tostring(Setpoint))
	LogInfo("Pool  Set Pool Setpoint Not Implemented")	-- default

end

function PoolCom_SetSpaSetpoint(Setpoint)
	LogTrace("PoolCom_SetSpaSetpoint  %s", tostring(Setpoint))
	LogInfo("Pool  Set Spa Setpoint Not Implemented")	-- default

end

function PoolCom_SetPoolPumpmode(PumpMode)
	LogTrace("PoolCom_SetPoolPumpmode  %s", tostring(PumpMode))
	LogInfo("Pool  Set Pool Pumpmode Not Implemented")	-- default

end

function PoolCom_SetSpaPumpmode(PumpMode)
	LogTrace("PoolCom_SetSpaPumpmode  %s", tostring(PumpMode))
	LogInfo("Pool  Set Spa Pumpmode Not Implemented")	-- default

end

