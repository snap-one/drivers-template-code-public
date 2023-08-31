--[[=============================================================================
    Command Functions Received From Satellite Proxy to the Driver

    Copyright 2022 Snap One, LLC. All Rights Reserved.
===============================================================================]]

require "lib.c4_log"

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.satellite_proxy_commands = "2022.05.12"
end


---------------------------------------------------------------

function PRX_CMD.ON(idBinding, tParams)
	LogTrace("PRX_CMD.ON")
	ProxyInstance(idBinding):PrxOn(tParams)
end

function PRX_CMD.OFF(idBinding, tParams)
	LogTrace("PRX_CMD.OFF")
	ProxyInstance(idBinding):PrxOff(tParams)
end

function PRX_CMD.PLAY(idBinding, tParams)
	LogTrace("PRX_CMD.PLAY")
	ProxyInstance(idBinding):PrxPlay(tParams)
end

function PRX_CMD.STOP(idBinding, tParams)
	LogTrace("PRX_CMD.STOP")
	ProxyInstance(idBinding):PrxStop(tParams)
end

function PRX_CMD.PAUSE(idBinding, tParams)
	LogTrace("PRX_CMD.PAUSE")
	ProxyInstance(idBinding):PrxPause(tParams)
end

function PRX_CMD.SKIP_FWD(idBinding, tParams)
	LogTrace("PRX_CMD.SKIP_FWD")
	ProxyInstance(idBinding):PrxSkipFwd(tParams)
end

function PRX_CMD.SKIP_REV(idBinding, tParams)
	LogTrace("PRX_CMD.SKIP_REV")
	ProxyInstance(idBinding):PrxSkipRev(tParams)
end

function PRX_CMD.SCAN_FWD(idBinding, tParams)
	LogTrace("PRX_CMD.SCAN_FWD")
	ProxyInstance(idBinding):PrxScanFwd(tParams)
end

function PRX_CMD.SCAN_REV(idBinding, tParams)
	LogTrace("PRX_CMD.SCAN_REV")
	ProxyInstance(idBinding):PrxScanRev(tParams)
end

function PRX_CMD.MENU(idBinding, tParams)
	LogTrace("PRX_CMD.MENU")
	ProxyInstance(idBinding):PrxMenu(tParams)
end

function PRX_CMD.UP(idBinding, tParams)
	LogTrace("PRX_CMD.UP")
	ProxyInstance(idBinding):PrxUp(tParams)
end

function PRX_CMD.DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.DOWN")
	ProxyInstance(idBinding):PrxDown(tParams)
end

function PRX_CMD.LEFT(idBinding, tParams)
	LogTrace("PRX_CMD.LEFT")
	ProxyInstance(idBinding):PrxLeft(tParams)
end

function PRX_CMD.RIGHT(idBinding, tParams)
	LogTrace("PRX_CMD.RIGHT")
	ProxyInstance(idBinding):PrxRight(tParams)
end

function PRX_CMD.ENTER(idBinding, tParams)
	LogTrace("PRX_CMD.ENTER")
	ProxyInstance(idBinding):PrxEnter(tParams)
end

function PRX_CMD.EXIT(idBinding, tParams)
	LogTrace("PRX_CMD.EXIT")
	ProxyInstance(idBinding):PrxExit(tParams)
end

function PRX_CMD.HOME(idBinding, tParams)
	LogTrace("PRX_CMD.HOME")
	ProxyInstance(idBinding):PrxHome(tParams)
end

function PRX_CMD.SETTINGS(idBinding, tParams)
	LogTrace("PRX_CMD.SETTINGS")
	ProxyInstance(idBinding):PrxSettings(tParams)
end

function PRX_CMD.SET_CHANNEL(idBinding, tParams)
	LogTrace("PRX_CMD.SET_CHANNEL")
	ProxyInstance(idBinding):PrxSetChannel(tParams)
end

function PRX_CMD.START_CH_UP(idBinding, tParams)
	LogTrace("PRX_CMD.START_CH_UP")
	ProxyInstance(idBinding):PrxStartChUp(tParams)
end

function PRX_CMD.STOP_CH_UP(idBinding, tParams)
	LogTrace("PRX_CMD.STOP_CH_UP")
	ProxyInstance(idBinding):PrxStopChUp(tParams)
end

function PRX_CMD.START_CH_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.START_CH_DOWN")
	ProxyInstance(idBinding):PrxStartChDown(tParams)
end

function PRX_CMD.STOP_CH_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.STOP_CH_DOWN")
	ProxyInstance(idBinding):PrxStopChDown(tParams)
end

function PRX_CMD.PULSE_CH_UP(idBinding, tParams)
	LogTrace("PRX_CMD.PULSE_CH_UP")
	ProxyInstance(idBinding):PrxPulseChUp(tParams)
end

function PRX_CMD.PULSE_CH_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.PULSE_CH_DOWN")
	ProxyInstance(idBinding):PrxPulseChDown(tParams)
end

function PRX_CMD.RECORD(idBinding, tParams)
	LogTrace("PRX_CMD.RECORD")
	ProxyInstance(idBinding):PrxRecord(tParams)
end

function PRX_CMD.PAGE_UP(idBinding, tParams)
	LogTrace("PRX_CMD.PAGE_UP")
	ProxyInstance(idBinding):PrxPageUp(tParams)
end

function PRX_CMD.PAGE_DOWN(idBinding, tParams)
	LogTrace("PRX_CMD.PAGE_DOWN")
	ProxyInstance(idBinding):PrxPageDown(tParams)
end

function PRX_CMD.TV_VIDEO(idBinding, tParams)
	LogTrace("PRX_CMD.TV_VIDEO")
	ProxyInstance(idBinding):PrxTvVideo(tParams)
end

function PRX_CMD.INFO(idBinding, tParams)
	LogTrace("PRX_CMD.INFO")
	ProxyInstance(idBinding):PrxInfo(tParams)
end

function PRX_CMD.CANCEL(idBinding, tParams)
	LogTrace("PRX_CMD.CANCEL")
	ProxyInstance(idBinding):PrxCancel(tParams)
end

function PRX_CMD.RECALL(idBinding, tParams)
	LogTrace("PRX_CMD.RECALL")
	ProxyInstance(idBinding):PrxRecall(tParams)
end

function PRX_CMD.PVR(idBinding, tParams)
	LogTrace("PRX_CMD.PVR")
	ProxyInstance(idBinding):PrxPVR(tParams)
end

function PRX_CMD.GUIDE(idBinding, tParams)
	LogTrace("PRX_CMD.GUIDE")
	ProxyInstance(idBinding):PrxGuide(tParams)
end

function PRX_CMD.NUMBER_0(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_0")
	ProxyInstance(idBinding):PrxNumber0(tParams)
end

function PRX_CMD.NUMBER_1(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_1")
	ProxyInstance(idBinding):PrxNumber1(tParams)
end

function PRX_CMD.NUMBER_2(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_2")
	ProxyInstance(idBinding):PrxNumber2(tParams)
end

function PRX_CMD.NUMBER_3(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_3")
	ProxyInstance(idBinding):PrxNumber3(tParams)
end

function PRX_CMD.NUMBER_4(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_4")
	ProxyInstance(idBinding):PrxNumber4(tParams)
end

function PRX_CMD.NUMBER_5(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_5")
	ProxyInstance(idBinding):PrxNumber5(tParams)
end

function PRX_CMD.NUMBER_6(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_6")
	ProxyInstance(idBinding):PrxNumber6(tParams)
end

function PRX_CMD.NUMBER_7(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_7")
	ProxyInstance(idBinding):PrxNumber7(tParams)
end

function PRX_CMD.NUMBER_8(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_8")
	ProxyInstance(idBinding):PrxNumber8(tParams)
end

function PRX_CMD.NUMBER_9(idBinding, tParams)
	LogTrace("PRX_CMD.NUMBER_9")
	ProxyInstance(idBinding):PrxNumber9(tParams)
end

function PRX_CMD.HYPHEN(idBinding, tParams)
	LogTrace("PRX_CMD.HYPHEN")
	ProxyInstance(idBinding):PrxHyphen(tParams)
end

function PRX_CMD.STAR(idBinding, tParams)
	LogTrace("PRX_CMD.STAR")
	ProxyInstance(idBinding):PrxStar(tParams)
end

function PRX_CMD.POUND(idBinding, tParams)
	LogTrace("PRX_CMD.POUND")
	ProxyInstance(idBinding):PrxPound(tParams)
end

function PRX_CMD.DVR(idBinding, tParams)
	LogTrace("PRX_CMD.DVR")
	ProxyInstance(idBinding):PrxDVR(tParams)
end

function PRX_CMD.CLOSED_CAPTIONED(idBinding, tParams)
	LogTrace("PRX_CMD.CLOSED_CAPTIONED")
	ProxyInstance(idBinding):PrxClosedCaptioned(tParams)
end

function PRX_CMD.PROGRAM_A(idBinding, tParams)
	LogTrace("PRX_CMD.PROGRAM_A")
	ProxyInstance(idBinding):PrxProgramA(tParams)
end

function PRX_CMD.PROGRAM_B(idBinding, tParams)
	LogTrace("PRX_CMD.PROGRAM_B")
	ProxyInstance(idBinding):PrxProgramB(tParams)
end

function PRX_CMD.PROGRAM_C(idBinding, tParams)
	LogTrace("PRX_CMD.PROGRAM_C")
	ProxyInstance(idBinding):PrxProgramC(tParams)
end

function PRX_CMD.PROGRAM_D(idBinding, tParams)
	LogTrace("PRX_CMD.PROGRAM_D")
	ProxyInstance(idBinding):PrxProgramD(tParams)
end





