--[[=============================================================================
	File is: ota_update.lua
	
    Copyright 2017 Control4 Corporation. All Rights Reserved.
===============================================================================]]

---------------------------------------------------------------------------------
-----------------------------------  OTA Upgrade Start --------------------------
---------------------------------------------------------------------------------

------- Global Variable for OTA Upgrade
OTA_UG_BLOB_NAME = "BlobBdDoorLock"
OTA_UG_HW_VERSION = 0x0003

OTA_DELAY_BOOTLOAD_TIME_IN_SEC = 0

gLastOnlineFirmwareVersion = 0

otaDriverTriggerReleaseLock = false
otaUgGotLockFromC4Director = false
otaUgWaitForDataCounter = 0
MAX_BLOCK_WAIT_FOR_DATA_COUNT_BEFORE_ABORT = 4
OTA_WAIT_FOR_DATA_TIMER_IN_SECOND_MIN = 10
OTA_WAIT_FOR_DATA_TIMER_IN_SECOND_MAX = 3600

otaFileHQ_fileId, otaFileHQ_headerVersion, otaFileHQ_headerLen, otaFileHQ_headerFc = 0, 0, 0, 0
otaFileHQ_mfgCode, otaFileHQ_imageType, otaFileHQ_fileVersion, otaFileHQ_zStackVersion = 0, 0, 0, 0
otaProcessPercentage = 0

SZL.otaUgCmd = {}
SZL.otaUgCmd[0x00] = "Image Notify"
SZL.otaUgCmd[0x01] = "Query Next Image Request"
SZL.otaUgCmd[0x02] = "Query Next Image Response"
SZL.otaUgCmd[0x03] = "Image Block Request"
SZL.otaUgCmd[0x04] = "Image Page Request"
SZL.otaUgCmd[0x05] = "Image Block Response"
SZL.otaUgCmd[0x06] = "Upgrade End Request"
SZL.otaUgCmd[0x07] = "Upgrade End Response"
SZL.otaUgCmd[0x08] = "Query Specific File Request"
SZL.otaUgCmd[0x09] = "Query Specific File Response"

------- Macro Define for OTA Upgrade Cluster Version
OTA_IMAGE_REQ_PAYLOAD_LEN = 9
OTA_IMAGE_REQ_PAYLOAD_LEN_HV = 11
OTA_BLOCK_REQ_PAYLOAD_LEN = 14
OTA_BLOCK_REQ_PAYLOAD_LEN_IEEE = 22
OTA_END_REQ_PAYLOAD_LEN = 9

OTA_STATUS_SUCCESS = "00"
OTA_STATUS_MALFORMED_CMD = "80"
OTA_STATUS_ABORT = "95"
OTA_STATUS_WAIT_FOR_DATA = "97"
OTA_STATUS_NO_IMAGE_AVAILABLE = "98"

------- General Incoming Message Handler for OTA Upgrade Cmd
function mmbOtaUpgradeIncomingCmdHandler(cmd, data)
	
	---- temp junk  DCC 07/17/17   Not sure what this routine is about.  Just skip it.

  -- if (SZL.otaUgCmd[cmd] == "Query Next Image Request") then
    -- otaDbgStatus(SZL.otaUgCmd[cmd])
    -- mmbOtaUpgradeQueryNextImageRequestHandler(data)
  -- elseif (SZL.otaUgCmd[cmd] == "Image Block Request") then
    -- otaDbgStatus(SZL.otaUgCmd[cmd])
    -- mmbOtaUpgradeImageBlockRequestHandler(data)
  -- -- not implemented on rapidse esp server
  -- elseif (SZL.otaUgCmd[cmd] == "Image Page Request") then
    -- otaDbgStatus(SZL.otaUgCmd[cmd])
  -- elseif (SZL.otaUgCmd[cmd] == "Upgrade End Request") then
    -- otaDbgStatus(SZL.otaUgCmd[cmd])
    -- mmbOtaUpgradeEndRequestHandler(data)
  -- -- not implemented on rapidse esp server
  -- elseif (SZL.otaUgCmd[cmd] == "Query Specific File Request") then
    -- otaDbgStatus(SZL.otaUgCmd[cmd])
  -- end
end

------- Image Request: Cmd Id 0x01
function mmbOtaUpgradeQueryNextImageRequestHandler(otaUpgradPayload)
  local status = OTA_STATUS_NO_IMAGE_AVAILABLE
  local pos, fc = string.unpack(otaUpgradPayload, "b")
  local hwvPresent = (bit.band(fc, 0x01) > 0)

  local mfgCode, imageType, fileVersion, hardwareVersion = 0, 0, 0, 0
  
  SZL.otaGetBlobImageInfo()
  
  if ((hwvPresent) and (otaUpgradPayload:len() ~= OTA_IMAGE_REQ_PAYLOAD_LEN_HV)) or ((not hwvPresent) and (otaUpgradPayload:len() ~= OTA_IMAGE_REQ_PAYLOAD_LEN))then
    status = OTA_STATUS_MALFORMED_CMD
  end 
  
  if (status == OTA_STATUS_NO_IMAGE_AVAILABLE) then
    if (hwvPresent) then
      pos, mfgCode, imageType, fileVersion, hardwareVersion = string.unpack(otaUpgradPayload, "<H<H<L<H", pos)
    else
      pos, mfgCode, imageType, fileVersion = string.unpack(otaUpgradPayload, "<H<H<L", pos)
    end
    
    if (otaFileHQ_mfgCode == mfgCode) and (otaFileHQ_imageType == imageType) and (fileVersion < otaFileHQ_fileVersion) then
      if (not hwvPresent) then
        status = OTA_STATUS_SUCCESS
      elseif (hwvPresent) and (hardwareVersion == OTA_UG_HW_VERSION) then
        status = OTA_STATUS_SUCCESS
      end
    end
  end
  
  mmbOtaUpgradeQueryNextImageResponse(status)
end

------- Image Response: Cmd Id 0x02
function mmbOtaUpgradeQueryNextImageResponse(status)
  otaDbgStatus("mmbOtaUpgradeQueryNextImageResponse status " .. status)
  if (status == OTA_STATUS_SUCCESS) then
    mmbOtaUpgradeProcessStart()
    SendOtaUpgradeCommand(0x02, string.pack("b<H<H<L<L", status, otaFileHQ_mfgCode, otaFileHQ_imageType, otaFileHQ_fileVersion, C4:GetBlobByName(OTA_UG_BLOB_NAME):len()))
  else
    SendOtaUpgradeCommand(0x02, tohex(status))
  end
end

------- Block Request: Cmd Id 0x03
function mmbOtaUpgradeImageBlockRequestHandler(otaUpgradPayload)
  local status = OTA_STATUS_NO_IMAGE_AVAILABLE
  local pos, fc = string.unpack(otaUpgradPayload, "b")
  local ieeePresent = (bit.band(fc, 0x01) > 0)
  
  local mfgCode, imageType, fileVersion = 0, 0, 0
  if ((ieeePresent) and (otaUpgradPayload:len() ~= OTA_BLOCK_REQ_PAYLOAD_LEN_IEEE)) or ((not ieeePresent) and (otaUpgradPayload:len() ~= OTA_BLOCK_REQ_PAYLOAD_LEN))then
    status = OTA_STATUS_MALFORMED_CMD
  end 
  
  if (status == OTA_STATUS_NO_IMAGE_AVAILABLE) then
    --Ignore ieee address
    pos, mfgCode, imageType, fileVersion = string.unpack(otaUpgradPayload, "<H<H<L", pos)
    if (otaFileHQ_mfgCode == mfgCode) and (otaFileHQ_imageType == imageType) and (fileVersion == otaFileHQ_fileVersion) then
        status = OTA_STATUS_SUCCESS
    end
  end
  
  mmbOtaUpgradeImageBlockResponse(status, otaUpgradPayload, pos)
end

------- Block Response: Cmd Id 0x05
function mmbOtaUpgradeImageBlockResponse(status, otaUpgradPayload, pos)
  otaDbgStatus("mmbOtaUpgradeImageBlockResponse status " .. status)
  if (status == OTA_STATUS_SUCCESS) then
    if (otaUgGotLockFromC4Director == true) then 
      pos, fileOffset, maxDataSize = string.unpack(otaUpgradPayload, "<Lb", pos)
      local returnPkg = string.sub(C4:GetBlobByName(OTA_UG_BLOB_NAME), fileOffset+1, fileOffset+maxDataSize)
      SendOtaUpgradeCommand(0x05, tohex(OTA_STATUS_SUCCESS)..(string.pack("<H<H<L<Lb", otaFileHQ_mfgCode, otaFileHQ_imageType, otaFileHQ_fileVersion, fileOffset, returnPkg:len()))..returnPkg)
      C4:KeepReflashLock()
      
      -- update the ota upgrade progress percentage
      local percentage = fileOffset * 100 / C4:GetBlobByName(OTA_UG_BLOB_NAME):len()
      if ( (percentage - otaProcessPercentage) > 10 ) then
        otaProcessPercentage = math.floor(percentage) 
        C4:UpdateProperty("OTA Upgrade Status", "OTA Upgrade Started - " .. otaProcessPercentage .. " % - " .. os.date("%c"))
      end
      
    else -- don't have premission from director
      if (otaUgWaitForDataCounter <= MAX_BLOCK_WAIT_FOR_DATA_COUNT_BEFORE_ABORT) then
        -- WAIT FOR DATA time delay is alternating from a short delay and a long delay
        -- the short duration is used to RequestReflashLock() while the long duration is the actual delay time
        local timeDelay = OTA_WAIT_FOR_DATA_TIMER_IN_SECOND_MAX
        if (otaUgWaitForDataCounter % 2 == 0) then 
          timeDelay = OTA_WAIT_FOR_DATA_TIMER_IN_SECOND_MIN
          C4:RequestReflashLock()
        else -- long delay
          timeDelay = OTA_WAIT_FOR_DATA_TIMER_IN_SECOND_MAX
          otaDriverTriggerReleaseLock = true
          C4:ReleaseReflashLock()
          otaDbgStatus("OTA Upgrade Process Paused for ".. timeDelay .. " seconds")
          C4:UpdateProperty("OTA Upgrade Status", "OTA Upgrade Process Paused for " .. timeDelay .. " seconds - " .. os.date("%c"))
        end
        -- time is relative here, current time set to 0 and request time set to delay time in seconds
        SendOtaUpgradeCommand(0x05, tohex(OTA_STATUS_WAIT_FOR_DATA)..string.pack("<L<L", 0, timeDelay))
        otaUgWaitForDataCounter = otaUgWaitForDataCounter + 1
      else
        -- abort 
        SendOtaUpgradeCommand(0x05, tohex(OTA_STATUS_ABORT))
        mmbOtaUpgradeProcessStop(OTA_STATUS_ABORT)
      end
    end
  else
    SendOtaUpgradeCommand(0x05, tohex(status))
  end
end

------- End Request: Cmd Id 0x06
function mmbOtaUpgradeEndRequestHandler(otaUpgradPayload)
  local status = OTA_STATUS_NO_IMAGE_AVAILABLE

  local mfgCode, imageType, fileVersion = 0, 0, 0
  if (otaUpgradPayload:len() ~= OTA_END_REQ_PAYLOAD_LEN)then
    status = OTA_STATUS_MALFORMED_CMD
  end 
  
  if (status == OTA_STATUS_NO_IMAGE_AVAILABLE) then
    pos, status, mfgCode, imageType, fileVersion = string.unpack(otaUpgradPayload, "b<H<H<L")
    if (status == 0x00) and (otaFileHQ_mfgCode == mfgCode) and (otaFileHQ_imageType == imageType) and (fileVersion == otaFileHQ_fileVersion) then
        status = OTA_STATUS_SUCCESS
    else
        status = OTA_STATUS_ABORT
        mmbOtaUpgradeProcessStop(OTA_STATUS_ABORT)
    end
  end
  
  if (status == OTA_STATUS_SUCCESS) then
    mmbOtaUpgradeEndResponse(status)
  else
    otaDbgStatus("mmbOtaUpgradeEndRequest status ".. status)
    --todo send default response
  end
end

-- End Response: Cmd Id 0x07
function mmbOtaUpgradeEndResponse(status)
  otaDbgStatus("mmbOtaUpgradeEndResponse status " .. status)
  if (status == OTA_STATUS_SUCCESS) then
    SendOtaUpgradeCommand(0x07, string.pack("<H<H<L<L<L", otaFileHQ_mfgCode, otaFileHQ_imageType, otaFileHQ_fileVersion, 0, OTA_DELAY_BOOTLOAD_TIME_IN_SEC))
    --hexdump(string.pack("<H<H<L<L<L", otaFileHQ_mfgCode, otaFileHQ_imageType, otaFileHQ_fileVersion, 0, OTA_DELAY_BOOTLOAD_TIME_IN_SEC))
    mmbOtaUpgradeProcessStop(OTA_STATUS_SUCCESS)
  end
end

-----------------------------------
------- Function Keep Track of the Upgrade Process
-----------------------------------
function mmbOtaUpgradeProcessStart()
  otaDbgStatus("mmbOtaUpgradeProcessStart")
  mmbOTaUgradeResetDirectorLockVariable()
  --get lock from director to process with ota upgrade
  C4:RequestReflashLock()
end

function mmbOtaUpgradeProcessStop(status)
  if (status == OTA_STATUS_SUCCESS) then
    otaDbgStatus("mmbOtaUpgradeProcessCompleted")
    C4:UpdateProperty("OTA Upgrade Status", "OTA Upgrade Process Completed - " .. os.date("%c"))
    -- assume ota serial bootload will happen successfull & immediately
    SZL.otaGetBlobImageInfo()
    local fVersion = string.format("%X", otaFileHQ_fileVersion)
    if (otaFileHQ_fileVersion > 0x0FFFFFFF) then
            C4:UpdateProperty("Firmware Version", string.sub(fVersion,1,2) .. "." .. string.sub(fVersion,3,4) .. "." .. string.sub(fVersion,5,6))
    else
      C4:UpdateProperty("Firmware Version", "0"..string.sub(fVersion,1,1) .. "." .. string.sub(fVersion,2,3) .. "." .. string.sub(fVersion,4,5))
    end
  else
    otaDbgStatus("mmbOtaUpgradeProcessAborted")
    C4:UpdateProperty("OTA Upgrade Status", "OTA Upgrade Process Aborted - " .. os.date("%c"))
    -- revert the firwmare version to the last known online verion
    C4:UpdateProperty("Firmware Version", gLastOnlineFirmwareVersion)
  end
  
  mmbOTaUgradeResetDirectorLockVariable()
  otaDriverTriggerReleaseLock = true
  C4:ReleaseReflashLock()
end

function mmbOTaUgradeResetDirectorLockVariable()
  SZL.SetSendMode(true, 15, 1, false)  -- Use Queue, wait for 15 seconds, 1 retry, Don't Allow Duplicate commands in queue...
  otaUgGotLockFromC4Director = false
  otaDriverTriggerReleaseLock = false
  otaUgWaitForDataCounter = 0
  otaProcessPercentage = 0
end

function OnReflashLockGranted()
  otaDbgStatus("OnReflashLockGranted")
  otaUgGotLockFromC4Director = true
  SZL.SetSendMode(false)
  C4:UpdateProperty("OTA Upgrade Status", "OTA Upgrade Started - 0 % - " .. os.date("%c"))
  C4:UpdateProperty("Firmware Version", "OTA Firmware Upgrade in Progress ...")
end 

function OnReflashLockRevoked()
  if (otaUgGotLockFromC4Director == true) then
    otaDbgStatus("OnReflashLockRevoked")
  end
  
  -- if the driver didnot trigger the release lock, the process was stopped unexpectly
  -- revert the firwmare version to the last known online verion
  if  (otaDriverTriggerReleaseLock == false) then
    C4:UpdateProperty("Firmware Version", gLastOnlineFirmwareVersion)
    C4:UpdateProperty("OTA Upgrade Status", "OTA Upgrade Process Aborted - " .. os.date("%c"))
  end
  
  mmbOTaUgradeResetDirectorLockVariable()
end

-----------------------------------
------- OTA Helper Function -------
-----------------------------------
function SZL.otaGetBlobImageInfo()
  otaUgFileHeaderBlock = C4:GetBlobByName(OTA_UG_BLOB_NAME)
  pos, otaFileHQ_fileId, otaFileHQ_headerVersion, otaFileHQ_headerLen, otaFileHQ_headerFc = string.unpack(otaUgFileHeaderBlock, "<L<H<H<H")
  pos, otaFileHQ_mfgCode, otaFileHQ_imageType, otaFileHQ_fileVersion, otaFileHQ_zStackVersion = string.unpack(otaUgFileHeaderBlock, "<H<H<L<H", pos)
end

function SendOtaUpgradeCommand(cmd, strData)
  strData = strData or ""
  local ret = SZL.SendClusterCommand(g_UpgradeCluster, cmd, strData, "ToClient", true) or "nil"
  if (ret == -1) then
    otaDbgStatus("Duplicate Command: " .. SZL.otaUgCmd[cmd])
  else
    otaDbgStatus("Queued Command: " .. SZL.otaUgCmd[cmd])
  end
end

function otaDbgStatus(strStatus)
  LogDebug("-----> ota Status: " .. strStatus)
end

---------------------------------------------------------------------------------
-----------------------------------  OTA Upgrade End  ---------------------------
---------------------------------------------------------------------------------
