--[[=============================================================================
	File is: szl.lua
    Copyright 2018 Control4 Corporation. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.szl = "2018.05.17"
end

---------------------------------------------------------------------------------
-----------------------------------  SZL Start  -----------------------------------
---------------------------------------------------------------------------------
-- Control4 SZL - Simple Zigbee Library...
--    Methods: 

-- SZL.ReadAttributes(nClusterID, ...)
-- SZL.WriteAttributes(nClusterID, ...)
-- SZL.SendClusterCommand(nClusterID, idCmd, strData, Direction, disableDefaultResponse)  -- Sends Cluster Specific Command
-- SZL.SendCommand(nClusterID, idCmd, strData)             -- Doesn't set cluster specific header byte

-- SZL.Initialize(nProfileID, tValidClusterIDs, nGroupID, nSourceEndpoint, nDestEndpoint)
-- SZL.SetSendMode(bQueue, nWaitTime, nRetryTimes, bAllowDuplicates)
-- SZL.SetAttributeHandler(AttrHandler)
-- SZL.SetCmdHandler(CmdHandler)
-- SZL.SetDbgHandler(DbgHandler)

-- You also must call the following functions.
-- SZL.ProcessZigbee(strRawZigbee, idProfileID, idClusterID, idGroupID, sourceEndpoint, destinationEndpoint)  --   Should be called within the driver's OnZigbeePacketIn function
-- SZL.ResetSequenceNumber()		-- Should be called within the driver's OnZigbeeOnlineStatusChanged function
-- SZL.OnTimerExpired(idTimer)		-- Should be called within the driver's OnTimerExpired function
-- SZL.OnDriverDestroyed()				-- Should be called within the driver's OnDriverDestroyed function


SZL = {}  		-- Initialize library container

-- Set this to true if we need to act as an IDENTIFY server (for certification.  Otherwise, not used).
SZL.IDENTIFY_SERVER = false

function SZL.SetAttributeHandler(AttrHandler)
  SZL.AttrHandler = AttrHandler
end

function SZL.SetCommandHandler(CmdHandler)
  SZL.CmdHandler = CmdHandler
end

function SZL.SetDbgHandler(DbgHandler)
  SZL.DbgHandler = DbgHandler
end

function SZL.dbg(strDbg)
  if (SZL.DbgHandler ~= nil) then
    SZL.DbgHandler("SZL: " .. strDbg)
  end
end

-- From ZCL Spec Table 2.14, "Data Types"...
SZL.attrtype_to_name = {}
SZL.attrtype_to_name[0x00] = "Null"
SZL.attrtype_to_name[0x08] = "8-Bit Data"
SZL.attrtype_to_name[0x09] = "16-Bit Data"
SZL.attrtype_to_name[0x0a] = "24-Bit Data (*)" -- Not Supported (not implemented in lpack)
SZL.attrtype_to_name[0x0b] = "32-Bit Data"
SZL.attrtype_to_name[0x10] = "Boolean"
SZL.attrtype_to_name[0x18] = "8-Bit Bitmap"
SZL.attrtype_to_name[0x19] = "16-Bit Bitmap"
SZL.attrtype_to_name[0x1a] = "24-Bit Bitmap (*)" -- Not Supported (not implemented in lpack)
SZL.attrtype_to_name[0x1b] = "32-Bit Bitmap"
SZL.attrtype_to_name[0x20] = "Unsigned 8-Bit Integer"
SZL.attrtype_to_name[0x21] = "Unsigned 16-Bit Integer"
SZL.attrtype_to_name[0x22] = "Unsigned 24-Bit Integer (*)" -- Not Supported (not in lpack)
SZL.attrtype_to_name[0x23] = "Unsigned 32-Bit Integer"
SZL.attrtype_to_name[0x28] = "Signed 8-Bit Integer"
SZL.attrtype_to_name[0x29] = "Signed 16-Bit Integer"
SZL.attrtype_to_name[0x2a] = "Signed 24-Bit Integer (*)" -- Not Supported (not in lpack)
SZL.attrtype_to_name[0x2b] = "Signed 32-Bit Integer"
SZL.attrtype_to_name[0x30] = "8-Bit Enumeration"
SZL.attrtype_to_name[0x31] = "16-Bit Enumeration"
SZL.attrtype_to_name[0x38] = "Semi-Precision FP (*)"    -- Not Supported (not in lpack)
SZL.attrtype_to_name[0x39] = "Single-Precision FP"
SZL.attrtype_to_name[0x3a] = "Double-Precision FP"
SZL.attrtype_to_name[0x41] = "Octet String"
SZL.attrtype_to_name[0x42] = "Character String"
SZL.attrtype_to_name[0xe0] = "Time of Day"
SZL.attrtype_to_name[0xe1] = "Date"

SZL.name_to_attrtype = {}
for k,v in pairs(SZL.attrtype_to_name) do
  SZL.name_to_attrtype[v] = k
end

-- From ZCL Spec Table 2.8, "ZCL Command Frames"...
SZL.cmd_to_name = {}
SZL.cmd_to_name[0x00] = "Read attributes"
SZL.cmd_to_name[0x01] = "Read attributes response"
SZL.cmd_to_name[0x02] = "Write attributes"
SZL.cmd_to_name[0x03] = "Write attributes undivided"
SZL.cmd_to_name[0x04] = "Write attributes response"
SZL.cmd_to_name[0x05] = "Write attributes no response"
SZL.cmd_to_name[0x06] = "Configure reporting"
SZL.cmd_to_name[0x07] = "Configure reporting response"
SZL.cmd_to_name[0x08] = "Read reporting configuration"
SZL.cmd_to_name[0x09] = "Read reporting configuration response"
SZL.cmd_to_name[0x0a] = "Report attributes"
SZL.cmd_to_name[0x0b] = "Default response"
SZL.cmd_to_name[0x0c] = "Discover attributes"
SZL.cmd_to_name[0x0d] = "Discover attributes response"

-- From ZCL Spec Table 2.14, "Data Types"...
SZL.unpackstr = {}
SZL.unpackstr[0x08] = "b"
SZL.unpackstr[0x09] = "<H"
SZL.unpackstr[0x0b] = "<L"
SZL.unpackstr[0x10] = "b"
SZL.unpackstr[0x18] = "b"
SZL.unpackstr[0x19] = "<H"
SZL.unpackstr[0x1b] = "<L"
SZL.unpackstr[0x20] = "b"
SZL.unpackstr[0x21] = "<H"
SZL.unpackstr[0x23] = "<L"
SZL.unpackstr[0x28] = "b"
SZL.unpackstr[0x29] = "<h"
SZL.unpackstr[0x2b] = "<l"
SZL.unpackstr[0x30] = "b"
SZL.unpackstr[0x31] = "<H"
SZL.unpackstr[0x39] = "f"
SZL.unpackstr[0x3a] = "d"
SZL.unpackstr[0x41] = "p"
SZL.unpackstr[0x42] = "p"

-- Table of Analog values, used by Configure Reporting, which sends different params for analog types...
-- From ZCL Spec Table 2.14, "Data Types"...
SZL.IsAnalogType = {}
SZL.IsAnalogType[0x20] = true
SZL.IsAnalogType[0x21] = true
SZL.IsAnalogType[0x22] = true
SZL.IsAnalogType[0x23] = true
SZL.IsAnalogType[0x28] = true
SZL.IsAnalogType[0x29] = true
SZL.IsAnalogType[0x2a] = true
SZL.IsAnalogType[0x2b] = true
SZL.IsAnalogType[0x38] = true
SZL.IsAnalogType[0x39] = true
SZL.IsAnalogType[0x3a] = true
SZL.IsAnalogType[0xe0] = true
SZL.IsAnalogType[0xe1] = true


-- Frame Control bits to set
-- From ZCL Spec Figure 2.3, "Format of the Frame Control Field"...
-- bits 0-1
SZL.FrameTypeProfileWide      = 0x00
SZL.FrameTypeClusterSpecific = 0x01
-- bit 2
SZL.ManufacturerSpecific        = 0x04
-- bit 3
SZL.DirectionToServer             = 0x00
SZL.DirectionToClient             = 0x08
-- bit 4
SZL.DisableDefaultResponse             = 0x10

-- From ZCL Spec Table 2.2, "Clusters Specified by the General Functional Domain"...
SZL.Cluster = {}
SZL.Cluster[0x0000] = "Basic"
SZL.Cluster[0x0001] = "PowerConfig"
SZL.Cluster[0x0002] = "DeviceTemperatureConfiguration"
SZL.Cluster[0x0003] = "Identify"
SZL.Cluster[0x0004] = "Groups"
SZL.Cluster[0x0005] = "Scenes"
SZL.Cluster[0x0006] = "OnOff"
SZL.Cluster[0x0007] = "OnOffSwitchConfiguration"
SZL.Cluster[0x0008] = "LevelControl"
SZL.Cluster[0x0009] = "Alarms"
SZL.Cluster[0x000a] = "Time"
SZL.Cluster[0x000b] = "RSSILocation"

-- From ZCL Spec Tables 2.3-2.7, (Domain Specific Clusters)...

-- Closures
SZL.Cluster[0x0100] = "ShadeConfiguration"

-- HVAC
SZL.Cluster[0x0200] = "PumpConfigAndControl"
SZL.Cluster[0x0201] = "Thermostat"
SZL.Cluster[0x0202] = "FanControl"
SZL.Cluster[0x0203] = "DehumidifcationControl"
SZL.Cluster[0x0204] = "ThermostatUIConfiguration"

-- Lighting
SZL.Cluster[0x0300] = "ColorControl"
SZL.Cluster[0x0301] = "BallastConfiguration"

-- Measurement and Sensing
SZL.Cluster[0x0400] = "IlluminanceMeasurement"
SZL.Cluster[0x0401] = "IlluminanceLevelSensing"
SZL.Cluster[0x0402] = "TemperatureMeasurement"
SZL.Cluster[0x0403] = "PressureMeasurement"
SZL.Cluster[0x0404] = "FlowMeasurement"
SZL.Cluster[0x0405] = "RelativeHumidityMeasurement"
SZL.Cluster[0x0406] = "OccupancySensing"

-- Security and Safety
SZL.Cluster[0x0500] = "IASZone"
SZL.Cluster[0x0500] = "IASACE"
SZL.Cluster[0x0500] = "IASWD"

SZL.ClusterID = {}
for k,v in pairs(SZL.Cluster) do
  SZL.ClusterID[v] = k
end


-- From ZCL Spec Table 2.15, "Enumerated Status Values Used in the ZCL"...
SZL.AttrResponseStatus = {}
SZL.AttrResponseStatus[0x00] = "SUCCESS"
SZL.AttrResponseStatus[0x01] = "FAILURE"
SZL.AttrResponseStatus[0x80] = "MALFORMED_COMMAND"
SZL.AttrResponseStatus[0x81] = "UNSUP_CLUSTER_COMMAND"
SZL.AttrResponseStatus[0x82] = "UNSUP_GENERAL_COMMAND"
SZL.AttrResponseStatus[0x83] = "UNSUP_MANUF_CLUSTER_COMMAND"
SZL.AttrResponseStatus[0x84] = "UNSUP_MANUF_GENERAL_COMMAND"
SZL.AttrResponseStatus[0x85] = "INVALID_FIELD"
SZL.AttrResponseStatus[0x86] = "UNSUPPORTED_ATTRIBUTE"
SZL.AttrResponseStatus[0x87] = "INVALID_VALUE"
SZL.AttrResponseStatus[0x88] = "READ_ONLY"
SZL.AttrResponseStatus[0x89] = "INSUFFICIENT_SPACE"
SZL.AttrResponseStatus[0x8A] = "DUPLICATE_EXISTS"
SZL.AttrResponseStatus[0x8B] = "NOT_FOUND"
SZL.AttrResponseStatus[0x8C] = "UNREPORTABLE_ATTRIBUTE"
SZL.AttrResponseStatus[0x8D] = "INVALID_DATA_TYPE"
SZL.AttrResponseStatus[0xC0] = "HARDWARE_FAILURE"



function SZL.ResetSequenceNumber()
  SZL.gSequence = 0x01
end


function SZL.Initialize(nProfileID, tValidClusterIDs, nGroupID, nSourceEndpoint, nDestEndpoint)

  SZL.ResetSequenceNumber()
  math.randomseed(os.time())

  -- Fill in for your device...
  SZL.gMyProfileID = nProfileID

  SZL.gMyValidClusterIDs = {}
  for k,v in pairs(tValidClusterIDs) do 
    SZL.gMyValidClusterIDs[v] = k
  end

  SZL.gMyGroupID   = nGroupID
  SZL.gQueueRetryCount = 0

  -- Endpoints are usually by cluster, but these are the default if not set...
  SZL.gMySE        = nSourceEndpoint
  SZL.gMyDE       = nDestEndpoint
  
  SZL.IdentifyTimer = CreateTimer("SZL Identify Timer", 1, "SECONDS", SZL.OnIdentifyTimerExpired, true, "")
  SZL.QueueTimer = CreateTimer("SZL Queue Timer", 1, "SECONDS", SZL.OnQueueTimerExpired, true, "")
  SZL.gQueueRetryCount = 0
end

----------------------------------------------------------------------------------
-- ParseAttributes
--
-- Given the Zigbee Attributes received from a Read Attributes Response or
--  a Report Attributes command from the node, will return a table with
--  the type, value, and status for every attribute received:
--    table[1].type == attribute type
--    table[1].value == value
--    table[1].status == status (for READ ATTRIBUTES RESPONSE only)
--
-- NOTE: 24-bit data values and semi-precision FP are not parsed, just skipped.
----------------------------------------------------------------------------------
function SZL.ParseAttributes(strAttrs, attrsize, zclCmd)

  local attrs = {}
  local pos = 1
  local status, id, type, val

  while (pos < attrsize) do

    status = 0x00  -- Success by default, for Report Attributes, which has no status...

    -- If strAttrs length < 3, it's invalid, as it requires an ID (2 octets, and a status, 1 octet)...

    if (zclCmd == 0x01) then
      pos, id, status = string.unpack(strAttrs, "<Hb", pos)
    else
      pos, id = string.unpack(strAttrs, "<H", pos)
    end

    if (status == 0x00) then
      -- Status == SUCCESS... Get Type...
      pos, type = string.unpack(strAttrs, "b", pos)

      attrs[id] = {}
      attrs[id].status = status
      attrs[id].type = type

      local ut = SZL.unpackstr[type]

      if (ut ~= nil) then
        pos, val = string.unpack(strAttrs, ut, pos)
        attrs[id].value = val

        if attrs[id].type == "Boolean" then
          if (attrs[id].value == 0x01) then
            attrs[id].value = false
          else
            attrs[id].value = true
          end
        end

        -- SZL.dbg("ParseAttr -- pos: " .. pos .. " id: " .. id .. " type: " .. string.format("%02x", type) .. " unpack type: \"" .. ut .. "\"  val: " .. attrs[id].value)
      else
        if SZL.attrtype_to_name[attrs[id].type] == "Time of Day" then
          local hh, mm, ss, hs
          pos, hh, mm, ss, hs = string.unpack(strAttrs, "bbbb", pos)
          attrs[id].value = {}
          attrs[id].value["Hours"] = hh
          attrs[id].value["Minutes"] = mm
          attrs[id].value["Seconds"] = ss
          attrs[id].value["Hundredths"] = hs
        end
        if SZL.attrtype_to_name[attrs[id].type] == "Date" then
          local yy, mm, dd, dow
          pos, yy, mm, dd, dow = string.unpack(strAttrs, "bbbb", pos)
          attrs[id].value = {}
          attrs[id].value["Year"] = yy + 1990
          attrs[id].value["Month"] = mm
          attrs[id].value["Day"] = dd
          attrs[id].value["DOW"] = dow
        end
  
        -- Skip values we don't currently implement...
        if (id == 0x0a) or (id == 0x1a) or (id == 0x22) or (id == 0x2a) then
          -- 24-bit data values, skip the data (3 bytes)...
          pos = pos + 3
        end
        if (id == 0x38) then
          -- Semi-Precision FP, skip the data (2 bytes)... 
          pos = pos + 2
        end
      end
    else
      -- Status ~= 0x00 (SUCCESS)... Print out failure...
      SZL.dbg("Not Successful Status: " .. SZL.AttrResponseStatus[status] .. " (" .. status .. ")".. " for ID: " .. id)
   end  
  end

  return attrs
end


-- Parameters: Command ID, Cluster Specific, Manufacturer Specific, Manufacturer ID
function SZL.BuildZHeader(CmdID, bCS, bMS, ManufID, Direction, disableDefaultResponse)
  local fc = 0x00 -- Frame Control
  local hdr

  if (bCS) then fc = bit.bor(fc, SZL.FrameTypeClusterSpecific) end
  if (bMS) then fc = bit.bor(fc, SZL.ManufacturerSpecific) end
  
  if (disableDefaultResponse) then fc = bit.bor(fc, SZL.DisableDefaultResponse) end

  Direction = Direction or "ToServer" 
  if (Direction == "ToServer") then
    fc = bit.bor(fc, SZL.DirectionToServer)
  else
    fc = bit.bor(fc, SZL.DirectionToClient)
  end

  SZL.gSequence = SZL.gSequence + 1
  if (SZL.gSequence > 255) then SZL.gSequence = 0 end

  if (bMS == true) then
    hdr = string.pack("b<Hbb", fc, ManufID, SZL.gSequence, CmdID)
  else
    hdr = string.pack("bbb", fc, SZL.gSequence, CmdID)
  end

  return hdr
end


-- Send a ReadAttributes command to the node, using the IDs passed in
-- Example: SZL.ReadAttributes(nClusterID, 1, 2, 4, 5)
function SZL.ReadAttributes(nClusterID, ...)
  local pkt = SZL.BuildZHeader(0x00, false)   -- 0x00 is Read Attributes Command, not Cluster Specific...
  for i,v in ipairs(arg) do
    pkt = pkt .. string.pack("<H", v)  -- 2-Octet ID
  end
  SZL.SendZigbee(pkt, nClusterID)
end


-- Send a Configure Report Attributes command to the node, using the IDs passed in
-- Example: SZL.ConfigureReporting(nClusterID, {[1] = 0x41, [2] = 0x09})  -- Attribute ID, Type pairs...
function SZL.ConfigureReporting(nClusterID, tAttrs, nMinInterval, nMaxInterval, nTimeout, nReportableChange)
  -- Default Values if not passed in...
  nMinInterval = nMinInterval or 0x0000
  nMaxInterval = nMaxInterval or 0xFFFF
  nTimeout = nTimeout or 0x3C
  nReportableChange = nReportableChange or 0x01

  local pkt = SZL.BuildZHeader(0x06, false)   -- 0x06 is Configure Reporting Command, not Cluster Specific...
  for k,v in pairs(tAttrs) do    
    SZL.dbg("Configure Reporting attribute: " .. k .. " (" .. string.format("0x%04x", k) .. ") Type: " .. v .. " (" .. string.format("0x%02x", v) .. ")")

    if (SZL.IsAnalogType[v] ~= nil) then
      pkt = pkt .. string.pack("b<Hb<H<H" .. SZL.unpackstr[v] .. "<H", 0, k, v, nMinInterval, nMaxInterval, nReportableChange, nTimeout)
    else
      pkt = pkt .. string.pack("b<Hb<H<H<H", 0, k, v, nMinInterval, nMaxInterval, nTimeout)
    end
  end
  SZL.dbg("ConfigureReporting Packet: ")
  hexdump(pkt, SZL.dbg)
  SZL.SendZigbee(pkt, nClusterID)
end


-- Send a WriteAttributes Command to the node, attribute IDs, types, and values in the table
-- Example: WriteAttributes(nClusterID, {[ID] = {[type] = value}}, {[ID] = {[type] = value}}, etc...)
-- Example: SZL.WriteAttributes(nClusterID, {[1] = {[0x20] = 55}}) -- Write Attr 1, Type 0x20, Value 55...
--  Also, Type may be a type name as declared above...

function SZL.WriteAttributes(nClusterID, ...)
  local pkt = SZL.BuildZHeader(0x02, false)  -- 0x02 is Write Attributes Command, not Cluster Specific...
  for i,v in pairs(arg) do
    if (i ~= "n") then
      local id, t_v = next(v)
      local typ, val = next(t_v)

      typ = SZL.name_to_attrtype[typ] or typ
      local packtype = SZL.unpackstr[typ]

      if (packtype ~= nil) then
        pkt = pkt .. string.pack("<H", id)   -- 2-Octet ID
        pkt = pkt .. string.pack("b", typ)   -- 1-Octet Data Type
        pkt = pkt .. string.pack(packtype, val)   -- Variable-Length Data, depending on type...
      end
    end
  end
  SZL.SendZigbee(pkt, nClusterID)
end


SZL.ATTRS = {}
SZL.ATTRS.Basic = {}
SZL.ATTRS.Basic[0] = tohex("00 20 01")
SZL.ATTRS.Basic[7] = tohex("00 30 01")
-- Everything else should be 0x86 status, not 0x00


-- Parses Zigbee Header...
-- Returns: command, it's data, sequence #, frame type
function SZL.ParseZHeader(strRawZigbee)

  -- Parse it...
  local pos, fc = string.unpack(strRawZigbee, "b")

  -- Manufacturer-Specific?  If so, decode w/ manufacturer... If not, just rest...
  local ms = (bit.band(fc, 0x04) > 0)
  local ft = bit.band(fc, 0x03)
  if (ft == 0x01) then
    ft = 'Cluster Specific'
  else
    ft = 'acts Across Profile'
  end

  SZL.dbg("APS Frame Control: " .. string.format("%02x", fc) .. " Frame type: " .. ft)

  local mfg, seq, cmd = 0, 0, 0
  if (ms) then
    pos, mfg, seq, cmd = string.unpack(strRawZigbee, "<Hbb", pos)
  else
    pos, seq, cmd = string.unpack(strRawZigbee, "bb", pos)
  end

  data = string.sub(strRawZigbee, pos)

  -- If it's Cluster Specific, then it could be command response for Cluster Command, not Basic read attributes, etc...

  local cmdname = SZL.cmd_to_name[cmd] or ""

  if (ft == 'Cluster Specific') then
    cmdname = "Cluster Specific Cmd"
  end

  SZL.dbg("ParseZHeader -- Cmd: " .. cmd .. " (" .. cmdname .. ") Seq: " .. seq)
  hexdump(data, function(d) SZL.dbg("Data: " .. d) end)
  return cmd, data, seq, ft, ms, mfg
end

function SZL.PacketSuccess(packet, idProfileID, idClusterID, idGroupID, sourceEndpoint, destinationEndpoint)
  SZL.gCurPkt = SZL.gCurPkt or {}
  SZL.gCurPkt.data = "" -- Clear data, so next packets will be queued...
end

function SZL.PacketFailure(packet, idProfileID, idClusterID, idGroupID, sourceEndpoint, destinationEndpoint)
  SZL.FailResend()
end

function SZL.ProcessZigbee(strRawZigbee, idProfileID, idClusterID, idGroupID, sourceEndpoint, destinationEndpoint)
  local clustername = SZL.Cluster[idClusterID] or "Unknown Cluster"
  if (idProfileID ~= SZL.gMyProfileID) or (SZL.gMyValidClusterIDs[idClusterID] == nil) then
    SZL.dbg("Not my Profile / Cluster... ProfileID: " .. idProfileID .. " Cluster: " .. idClusterID .. " (" .. clustername .. ")")
    return
  end

  SZL.dbg("---------------------------------------------------")

  hexdump(strRawZigbee, function(strdump) SZL.dbg("SZL.ProcessZigbee -- Profile: " .. string.format("0x%x", idProfileID) .. " Cluster: " .. string.format("0x%x", idClusterID) .. " Data: " .. strdump) end)
  local cmd, data, seq, ft, ms, mfg = SZL.ParseZHeader(strRawZigbee)

  if (ft == 'Cluster Specific') then
    -- Basic Cluster doesn't support any commands...

    if (ms == true) then
      SZL.SendCommand(idClusterID, 0x0b, tohex(string.format("%02x", cmd) .. "83"), "ToClient")  -- Don't support manufacturer specific cluster command...
      return
    end

    if (idClusterID == 0x00) then
      -- Send Default response of 0x81 -- Unsupported Cluster Command.
      SZL.SendCommand(idClusterID, 0x0b, tohex(string.format("%02x", cmd) .. "81"), "ToClient")
      return
    end

    if ((idClusterID == SZL.ClusterID.Identify) and (SZL.IDENTIFY_SERVER)) then
      -- Start Identify command...
      if (cmd == 0x00) then
        -- Start identify timer...
--        if (SZL.IdentifyTimer ~= nil) then SZL.IdentifyTimer = C4:KillTimer(SZL.IdentifyTimer) end
		SZL.IdentifyTimer:KillTimer()
        _, SZL.IdentifyTime = string.unpack(data, "<H")

		SZL.IdentifyTimer:StartTimer()
--        SZL.IdentifyTimer = C4:AddTimer(1, "SECONDS", true)  -- one-second timer...
        print(SZL.IdentifyTime .. " second IDENTIFY STARTING...")
      end

      -- Identify Query command...
      if (cmd == 0x01) then
        SZL.IdentifyTime = SZL.IdentifyTime or 0
        if (SZL.IdentifyTime > 0) then 
          SZL.SendClusterCommand(SZL.ClusterID.Identify, 0x00, string.pack("<H", SZL.IdentifyTime), "ToClient")
        end
      end

      return
    end

     -- OTA Upgrade Cluster
     if (idClusterID == g_UpgradeCluster) then
       mmbOtaUpgradeIncomingCmdHandler(cmd, data)
     end


    SZL.dbg("Cluster Specific Command .. Sending to Handler...")
    if (SZL.CmdHandler ~= nil) then
      SZL.CmdHandler(idClusterID, cmd, data)
    end
    return
  end

  SZL.gCurPkt = SZL.gCurPkt or {}
  SZL.gCurPkt.data = "" -- Clear data, so next packets will be queued...

  if (data ~= nil) then
    -- Report Attributes (0x0a) or Read Attributes Response (0x01)
    if ((cmd == 0x0a) or (cmd == 0x01)) then
      local attrs = SZL.ParseAttributes(data, string.len(data), cmd)

      -- Debug Print the found attributes...
      for i,v in pairs(attrs) do
        local status = attrs[i].status or ""
        local val = attrs[i].value or ""
        local valhex = ""
        if (type(val) == "number") then
          valhex = string.format(" (0x%02x)", val)
        end
        if (type(val) ~= "table") then
          SZL.dbg("Response Attrs: attr[" .. i .. " (" .. string.format("0x%04x", i) .. ")] Type: " .. attrs[i].type .. " Value: " .. val .. valhex .. " Status: " .. status)
        else
          SZL.dbg("Response Attrs: attr[" .. i .. " (" .. string.format("0x%04x", i) .. ")] Type: " .. attrs[i].type .. " Status: " .. status)
          for k,v in pairs(val) do
            SZL.dbg(k .. ": " .. v)
          end
        end
      end

      if (SZL.AttrHandler ~= nil) then
        SZL.AttrHandler(idClusterID, attrs)
      end
    end
    -- ReadAttributes...
    if (cmd == 0x00) then
      local pos = 1
      resp_attr_data = ""
      -- Handle ReadAttributes command... Get each attribute, handle it separately...
      if (idClusterID == 0) then
        -- Get each attribute from data, return it, or an unsupported attributes (0x86) value...
        while (pos < #data) do
          pos, ID = string.unpack(data, "<H", pos)
          dbg("Found ID: " .. ID)
          if (SZL.ATTRS.Basic[ID] ~= nil) then
            resp_attr_data =  resp_attr_data .. string.pack("<H", ID)  .. SZL.ATTRS.Basic[ID]
          else
            resp_attr_data =  resp_attr_data .. string.pack("<H", ID) .. tohex("86")
          end
        end
      end
      if (idClusterID == SZL.ClusterID.Identify) then
        -- Get each attribute from data, return it, or an unsupported attributes (0x86) value...
        while (pos < #data) do
          pos, ID = string.unpack(data, "<H", pos)
          dbg("Found ID: " .. ID)
          if (ID == 0) then
            resp_attr_data =  resp_attr_data .. string.pack("<H", ID)  .. string.pack("<H", SZL.IdentifyTime)
          else
            resp_attr_data =  resp_attr_data .. string.pack("<H", ID) .. tohex("86")
          end
        end
      end
      if (resp_attr_data ~= "") then
        SZL.SendCommand(idClusterID, 0x01, resp_attr_data, "ToClient")
      end
    end

    -- WriteAttributes...
    if (cmd == 0x02) then
      if (ms == true) then
        SZL.SendCommand(idClusterID, 0x0b, tohex(string.format("%02x", cmd) .. "84"), "ToClient")
        return
      end
      local pos = 1
      resp_attr_data = ""
      -- Handle WriteAttributes command... Get each attribute, handle it separately...
      if (idClusterID == 0) then
        -- Get each attribute from data, return it, or an unsupported attributes (0x86) value...
        local attrs = SZL.ParseAttributes(data, string.len(data), 0x00)
        for k,v in pairs(attrs) do 
          if (SZL.ATTRS.Basic[k] ~= nil) then
            resp_attr_data =  resp_attr_data .. tohex("88") .. string.pack("<H", k)
          else
            resp_attr_data =  resp_attr_data .. tohex("86") .. string.pack("<H", k)
          end
        end
      end
      if (idClusterID == SZL.ClusterID.Identify) then
        -- Get each attribute from data, return it, or an unsupported attributes (0x86) value...
        local attrs = SZL.ParseAttributes(data, string.len(data), 0x00)
        for k,v in pairs(attrs) do 
          if (k == 0) then
            -- Start Timer, send success response.
            SZL.IdentifyTime = attrs[0].value 
            SZL.IdentifyTimer:StartTimer()		-- = C4:AddTimer(1)  -- one-second timer...
--            SZL.IdentifyTimer = C4:AddTimer(1)  -- one-second timer...
            print(SZL.IdentifyTime .. " second IDENTIFY STARTING...")
            resp_attr_data =  resp_attr_data .. tohex("00") .. string.pack("<H", k)
          else
            resp_attr_data =  resp_attr_data .. tohex("86") .. string.pack("<H", k)
          end
        end
      end
      if (resp_attr_data ~= "") then
        SZL.SendCommand(idClusterID, 0x04, resp_attr_data, "ToClient")
      end
    end
  end

  -- Send the next item in the queue...
  SZL.SendTop()

end


function SZL.SendClusterCommand(nClusterID, idCmd, strData, Direction, disableDefaultResponse)
  local pkt = SZL.BuildZHeader(idCmd, true, nil, nil, Direction, disableDefaultResponse)   -- Build Cluster-Specific Command
  pkt = pkt .. strData
  return SZL.SendZigbee(pkt, nClusterID)
end


function SZL.SendCommand(nClusterID, idCmd, strData, Direction)
  local pkt = SZL.BuildZHeader(idCmd, false, nil, nil, Direction)   -- Build Cluster-Specific Command
  pkt = pkt .. strData
  return SZL.SendZigbee(pkt, nClusterID)
end


-- bQueue == Use a Send Queue... If false, all Zigbee commands are sent immediately
-- nWaitTime == How long to wait for a response from a node.  If none comes, it will retry nRetryTimes Times, then drop it.
function SZL.SetSendMode(bQueue, nWaitTime, nRetryTimes, bAllowDuplicates)
  if (bAllowDuplicates == nil) then bAllowDuplicates = true end
  SZL.gAllowDuplicates = bAllowDuplicates
  SZL.gUseQueue = bQueue
  SZL.gQueueWaitTime = nWaitTime
  SZL.gQueueRetryTimes = nRetryTimes
end


-- If QueueCmds == true, then only send a single Zigbee Command, wait for the reply, and set the retry timer, etc.
-- Returns -1 if a duplicate in the queue...
function SZL.SendZigbee(pkt, nClusterID)

  SZL.Endpoints = SZL.Endpoints or {}
  local SE = SZL.Endpoints[nClusterID] or SZL.gMySE
  local DE = SZL.Endpoints[nClusterID] or SZL.gMyDE

  if (gZigbeeBound == false) then
    hexdump(pkt, function(strdump) SZL.dbg("Packet not sent, Zigbee device not bound: " .. strdump) end)
    return -2
  end

  if (SZL.gUseQueue) then
    SZL.gSendQueue = SZL.gSendQueue or {}
--    SZL.QueueTimer = SZL.QueueTimer or 0
    local PacketData = {}
    PacketData.data = pkt
    PacketData.clusterid = nClusterID

    if (SZL.gAllowDuplicates == false) then
      local dta = string.sub(pkt, 3)

      -- Check current 'in-flight' packet for duplicate...      
      if (SZL.gCurPkt ~= nil) then
        SZL.gCurPkt.data = SZL.gCurPkt.data or ""
        local pos, len = string.find(SZL.gCurPkt.data, dta)
        if (pos ~= nil) then
          if ((pos == 3) and (len == string.len(SZL.gCurPkt.data))) then
            SZL.dbg("Duplicate Packet Found in queue... Not Inserting...")
            return -1  -- Duplicate Found
          end
        end
      end

      -- Check queued packets for duplicate...      
      for k,v in pairs(SZL.gSendQueue) do
        local pos, len = string.find(v.data, dta)
        if (pos ~= nil) then
          if ((pos == 3) and (len == string.len(v.data))) then
            SZL.dbg("Duplicate Packet Found in queue... Not Inserting...")
            return -1  -- Duplicate Found
          end
        end
      end
    end
    table.insert(SZL.gSendQueue, PacketData)
    -- local addone = 0
    -- if (SZL.QueueTimer > 0) then
      -- addone = 1
    -- end
    -- hexdump(pkt, function(strdump) SZL.dbg("Queueing Packet..." .. "(" .. #SZL.gSendQueue + addone .. " in Queue): " .. strdump) end)
    if (SZL.QueueTimer:TimerStopped()) then
--    if (SZL.QueueTimer == 0) then
      SZL.SendTop()
    end
  else
--    hexdump(pkt, function(strdump) SZL.dbg("Sending Zigbee... Profile: " .. string.format("0x%x", SZL.gMyProfileID) .. " Cluster: " .. string.format("0x%x", nClusterID) .. " - " .. "SE/DE: " .. SE .. "/" .. DE .. " -- " .. strdump) end)
	SZL.gCurPkt = pkt
    C4:SendZigbeePacket(pkt, SZL.gMyProfileID, nClusterID, SZL.gMyGroupID, SE, DE)
  end
end


function SZL.NukeQueue()
  SZL.gSendQueue = {}
end

function SZL.SendTop()
  SZL.gSendQueue = SZL.gSendQueue or {}
  -- SZL.QueueTimer = SZL.QueueTimer or 0
  -- if (SZL.QueueTimer ~= 0) then
    -- SZL.QueueTimer = C4:KillTimer(SZL.QueueTimer)
  -- end
  SZL.QueueTimer:KillTimer()

  -- If packets in queue, send top...
  if (#SZL.gSendQueue >= 1) then
    SZL.gCurPkt = table.remove(SZL.gSendQueue, 1)

    hexdump(SZL.gCurPkt.data, function(strdump) SZL.dbg("Sending Queued Packet...(" .. #SZL.gSendQueue + 1 .. " left): " .. strdump) end)
    SZL.gQueueRetryCount = 0

    SZL.Endpoints = SZL.Endpoints or {}
    local SE = SZL.Endpoints[SZL.gCurPkt.clusterid] or SZL.gMySE
    local DE = SZL.Endpoints[SZL.gCurPkt.clusterid] or SZL.gMyDE

	LogDev("SZL.SendTop %s 0x%02X, %d, %d, %d, %d", HexToString(SZL.gCurPkt.data), SZL.gMyProfileID, SZL.gCurPkt.clusterid, SZL.gMyGroupID, SE, DE)
    C4:SendZigbeePacket(SZL.gCurPkt.data, SZL.gMyProfileID, SZL.gCurPkt.clusterid, SZL.gMyGroupID, SE, DE)
	SZL.QueueTimer:StartTimer(SZL.gQueueWaitTime)
--    SZL.QueueTimer = C4:AddTimer(SZL.gQueueWaitTime, "SECONDS")
  end
end


function SZL.FailResend()
  -- Must've not worked... failed send, so resend until max send count.
  SZL.gQueueRetryCount = SZL.gQueueRetryCount + 1
  if (SZL.gQueueRetryCount <= SZL.gQueueRetryTimes) then
    hexdump(SZL.gCurPkt.data, function(strdump) SZL.dbg("Retry Queued Packet...(" .. #SZL.gSendQueue + 1 .. " left): " .. strdump) end)

    SZL.Endpoints = SZL.Endpoints or {}
    local SE = SZL.Endpoints[SZL.gCurPkt.clusterid] or SZL.gMySE
    local DE = SZL.Endpoints[SZL.gCurPkt.clusterid] or SZL.gMyDE

    C4:SendZigbeePacket(SZL.gCurPkt.data, SZL.gMyProfileID, SZL.gCurPkt.clusterid, SZL.gMyGroupID, SE, DE)
	SZL.QueueTimer:StartTimer(SZL.gQueueWaitTime)
--    SZL.QueueTimer = C4:AddTimer(SZL.gQueueWaitTime, "SECONDS")
  else
    SZL.SendTop()
  end
end


function SZL.OnTimerExpired(idTimer)
  -- SZL's own OnTimerExpired.  This should be called in the driver's OnTimerExpired, so SZL can handle it's own timers.
  -- Returns true if it handled the timer, so the calling code can return.

  -- if (idTimer == SZL.IdentifyTimer) then
    -- SZL.IdentifyTime = SZL.IdentifyTime - 1
    -- print("IDENTIFY... " .. SZL.IdentifyTime)
    -- if (SZL.IdentifyTime < 1) then
      -- SZL.IdentifyTime = 0
      -- print("IDENTIFY ENDING...")
      -- SZL.IdentifyTimer = C4:KillTimer(SZL.IdentifyTimer)
    -- end
    -- return true
  -- end

  -- if (idTimer == SZL.QueueTimer) then
    -- SZL.QueueTimer = C4:KillTimer(SZL.QueueTimer)
    -- SZL.FailResend()
    -- return true
  -- end

  return false  -- Timer not handled...
end

function SZL.OnIdentifyTimerExpired()
   SZL.IdentifyTime = SZL.IdentifyTime - 1
--   print("IDENTIFY... " .. SZL.IdentifyTime)
   if (SZL.IdentifyTime < 1) then
     SZL.IdentifyTime = 0
--     print("IDENTIFY ENDING...")
     SZL.IdentifyTimer:KillTimer()
  end

end

function SZL.OnQueueTimerExpired()
	LogTrace("SZL.OnQueueTimerExpired")
	SZL.QueueTimer:KillTimer()
	SZL.FailResend()
end





function SZL.OnDriverDestroyed()
	SZL.QueueTimer:KillTimer()
	SZL.IdentifyTimer:KillTimer()
--  if (SZL.QueueTimer ~= nil) then SZL.QueueTimer = C4:KillTimer(SZL.QueueTimer) end
--  if (SZL.IdentifyTimer ~= nil) then SZL.IdentifyTimer = C4:KillTimer(SZL.IdentifyTimer) end
end


SZL.gUseQueue = false
SZL.gQueueWaitTime = 1
SZL.gQueueRetryTimes = 0

---------------------------------------------------------------------------------
-----------------------------------  SZL End  -----------------------------------
---------------------------------------------------------------------------------
