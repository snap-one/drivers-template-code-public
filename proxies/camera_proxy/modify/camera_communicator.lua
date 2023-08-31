--[[=============================================================================
    File is: camera_communicator.lua

    Copyright 2019 Control4 Corporation. All Rights Reserved.
===============================================================================]]

if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.camera_communicator = "2019.02.09"
end

PAKEDGE_PANTILT_INC = 7

--================================================================

function CameraCom_PanLeft()
	LogTrace("CameraCom_PanLeft")

end


function CameraCom_PanRight()
	LogTrace("CameraCom_PanRight")
	
end


function CameraCom_PanScan()
	LogTrace("CameraCom_PanScan")

end


function CameraCom_TiltUp()
	LogTrace("CameraCom_TiltUp")
	
end


function CameraCom_TiltDown()
	LogTrace("CameraCom_TiltDown")
	
end


function CameraCom_TiltScan()
	LogTrace("CameraCom_TiltScan")

end


function CameraCom_ZoomIn()
	LogTrace("CameraCom_ZoomIn")
	
end


function CameraCom_ZoomOut()
	LogTrace("CameraCom_ZoomOut")
	
end


function CameraCom_FocusNear()
	LogTrace("CameraCom_FocusNear")
	
end


function CameraCom_FocusFar()
	LogTrace("CameraCom_FocusFar")
	
end


function CameraCom_IrisOpen()
	LogTrace("CameraCom_IrisOpen")
	
end


function CameraCom_IrisClose()
	LogTrace("CameraCom_IrisClose")
	
end


function CameraCom_AutoFocus()
	LogTrace("CameraCom_AutoFocus")
	
end


function CameraCom_AutoIris()
	LogTrace("CameraCom_AutoIris")
	
end


function CameraCom_Home()
	LogTrace("CameraCom_Home")

end


function CameraCom_MoveTo(XPos, YPos, Width, Height)
	LogTrace("CameraCom_MoveTo  X:%d  Y:%d  W:%d H:%d", XPos, YPos, Width, Height)

end


function CameraCom_NightMode(IsNight)
	LogTrace("CameraCom_NightMode  Night:%s", tostring(IsNight))
	
end


function CameraCom_Preset(PresetIndex)
	LogTrace("CameraCom_Preset  Index: %d", PresetIndex)
	
end


function CameraCom_SetAddress(TargAddress)
	LogTrace("CameraCom_SetAddress")

end


function CameraCom_SetHttpPort(TargPort)
	LogTrace("CameraCom_SetHttpPort")

end


function CameraCom_SetRtspPort(TargPort)
	LogTrace("CameraCom_SetRtspPort")

end


function CameraCom_SetAuthenticationRequired(AuthRequired)
	LogTrace("CameraCom_SetAuthenticationRequired")

end


function CameraCom_SetAuthenticationType(AuthType)
	LogTrace("CameraCom_SetAuthenticationType")

end


function CameraCom_SetUsername(TargUserName)
	LogTrace("CameraCom_SetUsername")

end


function CameraCom_SetPassword(NewPassword)
	LogTrace("CameraCom_SetPassword")

end


function CameraCom_SetPubliclyAccessible(PublicAccess)
	LogTrace("CameraCom_SetPubliclyAccessible")

end



