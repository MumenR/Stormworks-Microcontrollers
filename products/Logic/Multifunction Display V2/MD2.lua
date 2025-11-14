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
    simulator:setScreen(1, "9x5")
    simulator:setProperty("ExampleNumberProperty", 123)

    simulator:setProperty("Distance units (Large)", 0.000539957)
    simulator:setProperty("Units text (Large)", "nm")
    simulator:setProperty("Distance units (Small)", 3.28084)
    simulator:setProperty("Units text (Small)", "ft")

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        simulator:setInputNumber(1, simulator:getSlider(1)*2000)
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

t = 0

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
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

--円描画
function drawCircle(x, y, r, start_degree, stop_degree)
    for i = start_degree, stop_degree - 10, 10 do
        local x1, y1, x2, y2
        x1, y1 = r*math.cos(math.pi*i/180), r*math.sin(math.pi*i/180)
        x2, y2 = r*math.cos(math.pi*(i + 10)/180), r*math.sin(math.pi*(i + 10)/180)
        screen.drawLine(x + x1, y - y1, x + x2, y - y2)
    end
end

--x, yの基準は左上
function drawDial(value, unitTxt, min, max, x, y, w, h)
    --テキスト化
    if value > 10 then
        valueTxt = string.format("%.0f", value)
    else
        valueTxt = string.format("%.1f", value)
    end


    --円弧
    screen.setColor(255, 255, 255)
    drawCircle(w/2 + x, h/2 + y, h/2 - 1, -30, 210)

    --目盛
    num = math.abs(max - min)/5
    i = 0
    while num >= 10 do
        num = num/10
        i = i + 1 
    end
    --目盛幅の計算
    if num < 1.5 then
        scale = 1
    elseif num < 3.5 then
        scale = 2
    elseif num < 7.5 then
        scale = 5
    else
        scale = 10
    end
    scale = scale*10^i

    --目盛描画(プラス)
    scale_line = 0
    screen.setColor(255, 255, 255)
    while scale_line <= max do
        scale_rad = (math.pi*4/3)*(scale_line - min)/(max - min) - 7*math.pi/6
        if scale_line >= min then
            screen.drawLine(w/2 + (h/2 - 1)*math.cos(scale_rad) + x, h/2 + (h/2 - 1)*math.sin(scale_rad) + y, w/2 + (h/2 - 5)*math.cos(scale_rad) + x, h/2 + (h/2 - 5)*math.sin(scale_rad) + y)
        end
        scale_line = scale_line + scale
    end

    --目盛描画(マイナス)
    scale_line = 0
    while scale_line >= min do
        scale_rad = (math.pi*4/3)*(scale_line - min)/(max - min) - 7*math.pi/6
        if scale_line >= min then
            screen.drawLine(w/2 + (h/2 - 1)*math.cos(scale_rad) + x, h/2 + (h/2 - 1)*math.sin(scale_rad) + y, w/2 + (h/2 - 5)*math.cos(scale_rad) + x, h/2 + (h/2 - 5)*math.sin(scale_rad) + y)
        end
        scale_line = scale_line - scale
    end

    --文字
    screen.drawText(w/2 - #valueTxt*2.5 + x, (h/2 - 1)*math.sin(math.pi/6) + h/2 - 4 + y, valueTxt)
    screen.drawText(w/2 - #unitTxt*2.5 + 1 + x, (h/2 - 1)*math.sin(math.pi/6) + h/2 + 2 + y, unitTxt)

    --針
    --角度計算
    rad = (math.pi*4/3)*(value - min)/(max - min) - 7*math.pi/6
    screen.setColor(0, 255, 0)
    screen.drawLine(w/2 + x, h/2 + y, w/2 + (h/2 - 1)*math.cos(rad) + x, h/2 + (h/2 - 1)*math.sin(rad) + y)
    screen.drawTriangleF(w/2 + (h/2 - 1)*math.cos(rad) + x, h/2 + (h/2 - 1)*math.sin(rad) + y, w/2 + 2*math.cos(rad + math.pi*2/3) + x, h/2 + 2*math.sin(rad + math.pi*2/3) + y, w/2 + 2*math.cos(rad + math.pi*4/3) + x, h/2 + 2*math.sin(rad + math.pi*4/3) + y)
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
    fuel = INN(5)/1000              --x1000L
    fuel_time = INN(6)*60           --min to sec
    fuel_dist = INN(7)*1000*unit_L  --km to m to nm
    fuel_econ = INN(8)*unit_S       --ft/L
    fuelDelta = INN(21)             --L/s
    geneENGRPML = INN(9)
    geneENGRPMR = INN(10)
    geneENGTMPL = INN(11)
    geneENGTMPR = INN(12)
    batteryL = INN(13)
    batteryR = INN(14)
    shaftRPML = INN(15)*60
    shaftRPMR = INN(16)*60
    generationL = INN(17)
    generationR = INN(18)
    geneRPML = INN(19)*60
    geneRPMR = INN(20)*60

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
    if SOS_on then
        sos_txt = round_txt(clamp(sos*unit_S, 0, math.huge))
    else
        sos_txt = "--"
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(1, 1, 1)
    for i = 32, h, 32 do
        screen.drawLine(0, i, w, i)
    end
    for i = 32, w, 32 do
        screen.drawLine(i, 0, i, h)
    end


    --ライン
    screen.setColor(0, 0, 64)
    screen.drawLine(0, h/2, 129, h/2)
    screen.drawLine(64, 0, 64, h)
    screen.drawLine(65, 40, 65 + 64, 40)
    screen.drawLine(129, 0, 129, h)
    screen.drawLine(195, 0, 195, h)
    screen.drawLine(129, 128, 195, 128)

    x, y = 0, 1

    --メインエンジン
    white()
    screen.drawText(x + 32 - #"ENG"*2.5, y, "ENG")
    y = y + 5
    drawDial(ENGL_rpm, "L-RPM", 0, 1000, x, y, 32, 32)
    drawDial(ENGR_rpm, "R-RPM", 0, 1000, x + 32, y, 32, 32)

    y = y + 32 + 10

    drawDial(ENGL_tmp, "L-TMP", 0, 120, x, y, 32, 32)
    drawDial(ENGR_tmp, "R-TMP", 0, 120, x + 32, y, 32, 32)

    --発電機
    y = h/2 + 2
    white()
    screen.drawText(x + 32 - #"GENE ENG"*2.5, y, "GENE ENG")
    y = y + 5
    drawDial(geneENGRPML, "L-RPM", 0, 1000, x, y, 32, 32)
    drawDial(geneENGRPMR, "R-RPM", 0, 1000, x + 32, y, 32, 32)

    y = y + 32 + 9

    drawDial(geneENGTMPL, "L-TMP", 0, 120, x, y, 32, 32)
    drawDial(geneENGTMPR, "R-TMP", 0, 120, x + 32, y, 32, 32)


    --縦列終わり--

    x, y = x + 64 + 1, 1

    --シャフト
    white()
    screen.drawText(x + 32 - #"SHAFT"*2.5, y, "SHAFT")
    y = y + 5
    drawDial(shaftRPML, "L-RPM", -4000, 4000, x, y, 32, 32)
    drawDial(shaftRPMR, "R-RPM", -4000, 4000, x + 32, y, 32, 32)

    y = y + 32 + 5

    --バッテリー
    white()
    screen.drawText(x + 32 - #"BATTERY"*2.5, y, "BATTERY")
    y = y + 5
    drawDial(batteryL, "L-RPM", 0, 100, x, y, 32, 32)
    drawDial(batteryR, "R-RPM", 0, 100, x + 32, y, 32, 32)

    --発電
    y = h/2 + 2
    white()
    screen.drawText(x + 32 - #"GENERATOR"*2.5, y, "GENERATOR")
    y = y + 5
    drawDial(geneRPML, "L-RPM", 0, 10000, x, y, 32, 32)
    drawDial(geneRPMR, "R-RPM", 0, 10000, x + 32, y, 32, 32)

    y = y + 32 + 9

    drawDial(generationL, "L-STW", 0, 1000, x, y, 32, 32)
    drawDial(generationR, "R-STW", 0, 1000, x + 32, y, 32, 32)


    --縦列終わり--

    x, y =  x + 64 + 1, 1

    --燃料
    white()
    screen.drawText(x + 32 - #"FUEL"*2.5, y, "FUEL")
    y = y + 5
    drawDial(fuel, "L", 0, 250000, x, y, 64, 64)

    y = y + 56
    drawDial(fuelDelta, "L/s", 0, 100, x, y, 32, 32)
    drawDial(fuel_econ, "ft/L", 0, 10, x + 32, y, 32, 32)

    y = y + 32

    drawDial(fuel_dist, "nm", 0, 150, x, y, 32, 32)
    drawDial(fuel_time, "min", 0, 600, x + 32, y, 32, 32)

    y = y + 32 + 5

    --SOS
    white()
    screen.drawText(x + 32 - #"SOS"*2.5, y, "SOS")
    y = y + 7
    screen.drawRect(x + 32 - 24, y, 20, 10)
    screen.drawRect(x + 32 + 3, y, 20, 10)

    if SOS_on then
        screen.setColor(0, 255, 0)
        screen.drawRectF(x + 32 - 23, y + 1, 19, 9)
        screen.setColor(0, 0, 0)
        screen.drawText(x + 16 - 3, y + 3, "ON")
    else
        screen.drawText(x + 16 - 4, y + 3, "OFF")
    end

    if SOS_pulse then
        screen.setColor(0, 255, 0)
        screen.drawRectF(x + 32 + 4, y + 1, 19, 9)
        screen.setColor(0, 0, 0)
        screen.drawText(x + 48 - 9, y + 3, "DTC")
    else
        white()
        screen.drawText(x + 48 - 9, y + 3, "DCT")
    end

    y = y + 15
    white()
    screen.drawText(x - (#sos_txt + 2)*5 + 50, y, sos_txt.." "..unit_S_txt)


    --ダメコン

end



