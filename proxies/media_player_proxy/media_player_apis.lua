--[[=============================================================================
    File is: media_player_apis.lua

    Copyright 2021 Snap One LLC. All Rights Reserved.
	
	API calls for developers using MediaPlayer template code
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.media_player_apis = "2021.07.07"
end

--==================================================================


function MediaPlayerIsPowerOn(MediaPlayerIndex)
	return TheMediaPlayerList[MediaPlayerIndex or 1]:IsPowerOn()
end

function MediaPlayerIsGetChannel(MediaPlayerIndex)
	return TheMediaPlayerList[MediaPlayerIndex or 1]:GetCurrentChannel()
end



