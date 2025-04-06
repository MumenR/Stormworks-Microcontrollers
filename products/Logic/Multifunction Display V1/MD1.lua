--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "2x2")
    simulator:setProperty("ExampleNumberProperty", 123)

    simulator:setProperty("Distance units (Large)", 0.000539957)
    simulator:setProperty("Units text (Large)", "nm")
    simulator:setProperty("Distance units (Small)", 3.28084)
    simulator:setProperty("Units text (Small)", "ft")

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        simulator:setInputNumber(1, simulator:getSlider(1)*1000)
        simulator:setInputNumber(2, simulator:getSlider(2)*1000)
        simulator:setInputNumber(3, simulator:getSlider(3)*200)
        simulator:setInputNumber(4, simulator:getSlider(4)*200)
        simulator:setInputNumber(5, simulator:getSlider(5)*100000)
        simulator:setInputNumber(6, simulator:getSlider(6)*1000)
        simulator:setInputNumber(7, simulator:getSlider(7)*100)
        simulator:setInputNumber(8, simulator:getSlider(8)*10)

        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsClicked(2))
        
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

--[[
入れる情報
エンジン回転数
エンジン温度
燃料残量
燃費
航続距離
航続時間
SOS
]]

INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool
PRN = property.getNumber
PRB = property.getBool
PRT = property.getText

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
end

--時計用テキスト
function clock(x)
    local hour, min, sec, time
    hour = string.format("%d", math.floor(x/3600))
    sec = string.format("%02.0f", math.floor(x%60 + 0.5))

    if x >= 36000 or x < 0 then
        time = "-:--:--"
    elseif x < 3600 then
        min = string.format("%d", math.floor((x/60)%60))
        time = min..":"..sec
    else
        min = string.format("%02.0f", math.floor((x/60)%60))
        time = hour..":"..min..":"..sec
    end
    return time
end

--整数に四捨五入し、カンマ挿入
function round_txt(x)
    return format_number(math.floor(x + 0.5))
end

--距離フォーマット(x[m])
function format_distance(x, unitL, unitL_txt, unitS, unitS_txt)
    local x_txt, unit, unit_txt
    --単位選択
    if x*unitL < 1 then
        unit = unitS
        unit_txt = unitS_txt
    else
        unit = unitL
        unit_txt = unitL_txt
    end

    --桁フォーマット
    x = x*unit
    if x < 1 then
        x_txt = string.format("%.3f", x)..unit_txt
    elseif x < 10 then
        x_txt = string.format("%.2f", x)..unit_txt
    elseif x < 100 then
        x_txt = string.format("%.1f", x)..unit_txt
    else
        x_txt = string.format("%.0f", x)..unit_txt
    end
    return x_txt
end

--３桁ごとにカンマ
function format_number(n)
    local str = tostring(n)
    --符号、整数部分、小数部分に分解
    local sign, int, dec = str:match("([%-]?)(%d+)(%.?%d*)")
    --３桁ごとにカンマ挿入
    int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    --先頭のカンマを削除
    int = int:gsub("^,", "")
    return sign .. int .. dec
end

function white()
    screen.setColor(255, 255, 255)
end

function yellow()
    screen.setColor(255, 255, 32)
end

function onTick()

    unit_L = PRN("Distance units (Large)")
    unit_L_txt = PRT("Units text (Large)")
    unit_S = PRN("Distance units (Small)")
    unit_S_txt = PRT("Units text (Small)")

    ENGL_rpm = INN(1)
    ENGR_rpm = INN(2)
    ENGL_tmp = INN(3)
    ENGR_tmp = INN(4)
    fuel = INN(5)
    fuel_time = INN(6)*60   --min to sec
    fuel_dist = INN(7)*1000 --km to m
    fuel_econ = INN(8)      --m/L

    SOS_on = INB(1)
    SOS_pulse = INB(2)

    --sos計算
    if SOS_on then
        t = t + 1
        if SOS_pulse then
            sos = t*50 - 250
            t = 0
        end
    else
        sos = 0
        t = 0
    end

    --文字変換
    ENGL_rpm_txt= round_txt(ENGL_rpm)
    ENGR_rpm_txt = round_txt(ENGR_rpm)
    ENGL_tmp_txt = round_txt(ENGL_tmp)
    ENGR_tmp_txt = round_txt(ENGR_tmp)
    fuel_txt = round_txt(fuel)
    fuel_time_txt = clock(fuel_time)
    fuel_dist_txt = string.format("%.2f", fuel_dist*unit_L)
    fuel_econ_txt = string.format("%.2f", fuel_econ*unit_S)
    if SOS_on then
        sos_txt = round_txt(clamp(sos*unit_S, 0, math.huge))
    else
        sos_txt = "--"
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --ライン
    screen.setColor(0, 0, 64)
    screen.drawLine(0, 14, w, 14)
    screen.drawLine(0, 28, w, 28)
    screen.drawLine(0, 48, w, 48)
    screen.drawLine(0, 56, w, 56)

    --エンジン回転数
    y = 2
    yellow()
    screen.drawText(w/4 - 12, y, "RPM-L")
    screen.drawText(w*3/4 - 12, y, "RPM-R")

    y = y + 6
    white()
    screen.drawText(w/4 - 2.5*#ENGL_rpm_txt, y, ENGL_rpm_txt)
    screen.drawText(w*3/4 - 2.5*#ENGR_rpm_txt, y, ENGR_rpm_txt)

    --エンジン温度
    y = y + 8
    yellow()
    screen.drawText(w/4 - 12, y, "TMP-L")
    screen.drawText(w*3/4 - 12, y, "TMP-R")

    y = y + 6
    white()
    screen.drawText(w/4 - 2.5*#ENGL_tmp_txt, y, ENGL_tmp_txt)
    screen.drawText(w*3/4 - 2.5*#ENGR_tmp_txt, y, ENGR_tmp_txt)

    --燃料
    y = y + 8
    yellow()
    screen.drawText(1, y, "FU")
    screen.drawText(w - 5, y, "L")
    white()
    screen.drawText(w - 11 - 5*#fuel_txt, y, fuel_txt)

    --航続距離
    y = y + 6
    yellow()
    screen.drawText(2, y, "EL")
    screen.drawText(w - 10, y, unit_L_txt)
    white()
    screen.drawText(w - 11 - 5*#fuel_dist_txt, y, fuel_dist_txt)

    --航続時間
    y = y + 6
    screen.drawText(w - 11 - 5*#fuel_time_txt, y, fuel_time_txt)

    --燃費
    y = y + 8
    yellow()
    screen.drawText(1, y, "ECO")
    screen.drawText(w - 10, y, unit_S_txt)
    white()
    screen.drawText(w - 11 - 5*#fuel_econ_txt, y, fuel_econ_txt)

    --SOS
    y = y + 8
    yellow()
    screen.drawText(1, y, "SOS")
    screen.drawText(w - 10, y, unit_S_txt)
    white()
    screen.drawText(w - 11 - 5*#sos_txt, y, sos_txt)

end



