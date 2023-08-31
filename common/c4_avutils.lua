---
---	File is: c4_avutils.lua
---
--- Copyright 2022 Snap One LLC. All Rights Reserved.
---
---	Common helper routines used by AV proxies
---


---Convert a volume level from a device to a percentage value that can be used by C4 proxies
---
---@param volume number The volume value from the device
---@param minDeviceLevel number The minimum device volume level
---@param maxDeviceLevel number The maximum device volume level
---@return integer volumeLevel The C4 usable volume level (0 to 100)
function ConvertVolumeToC4(volume, minDeviceLevel, maxDeviceLevel)
	volume = math.max(volume, minDeviceLevel)
	volume = math.min(volume, maxDeviceLevel)
    return ConvertScaleLevel(volume, minDeviceLevel, maxDeviceLevel, 0, 100)
end


---Convert a volume percentage from a C4 proxy to a numeric level used by a device.
---
---@param volume number The volume value from the c4 proxy (0 to 100)
---@param minDeviceLevel number The minimum device volume level
---@param maxDeviceLevel number The maximum device volume level
---@return integer usableVolumeLevel The device usable volume level (minDeviceLevel to maxDeviceLevel)
function ConvertVolumeToDevice(volume, minDeviceLevel, maxDeviceLevel)
	volume = math.max(volume, 0)
	volume = math.min(volume, 100)
    return ConvertScaleLevel(volume, 0, 100, minDeviceLevel, maxDeviceLevel)
end


