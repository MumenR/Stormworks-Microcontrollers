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
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- NEW! button/slider options from the UI
        simulator:setInputNumber(18, simulator:getSlider(1)*0.25)
        simulator:setInputNumber(19, simulator:getSlider(2)*0.25)

        simulator:setInputNumber(25, simulator:getSlider(3)*150000)
        simulator:setInputNumber(26, simulator:getSlider(4)*35999)
        simulator:setInputNumber(27, simulator:getSlider(5))
        simulator:setInputNumber(28, simulator:getSlider(10))

        simulator:setInputNumber(21, simulator:getSlider(6)*30000)
        simulator:setInputNumber(2, simulator:getSlider(7)*30000)
        simulator:setInputNumber(13, simulator:getSlider(8)*999)
        simulator:setInputNumber(20, simulator:getSlider(9)*999)
        
        simulator:setProperty("air speed", true)
        simulator:setProperty("ground speed", true)
        simulator:setProperty("main speed", true)
        simulator:setProperty("air altitude", true)
        simulator:setProperty("ground altitude", true)
        simulator:setProperty("magnetic heading", true)
        simulator:setProperty("attitude bars", true)
        simulator:setProperty("horizon line", true)
        simulator:setProperty("center marker", true)
        simulator:setProperty("laser direction", true)
        simulator:setProperty("waypoint marker", true)
        simulator:setProperty("waypoint marker label", true)
        simulator:setProperty("waypoint marker distance", true)
        simulator:setProperty("waypoint distance", true)
        simulator:setProperty("waypoint arrival time", true)

        simulator:setProperty("Speed Units", 1)
        simulator:setProperty("Altitude Units", 0.001)
        simulator:setProperty("Distance Units", 0.0005)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("required")
require("math.math")
require("math.coordTrans")
require("screen.coordTrans")
require("screen.draw")

FOV_H = (58/360)*pi2

function maxDigits(maxNum, unit)
    return #tostring(math.floor(maxNum*unit + 0.5))
end

function onTick()
    --inputs prop
    do
        spd_unit = PRN("Speed Units")
        alt_unit = PRN("Altitude Units")
        dist_unit = PRN("Distance Units")

        show_air_speed = PRB("air speed")
        show_gnd_speed = PRB("ground speed")
        gnd_main = PRB("main speed")
        show_air_alt = PRB("air altitude")
        show_gnd_alt = PRB("ground altitude")
        show_azimuth = PRB("magnetic heading")
        show_attitude = PRB("Pitch ladder")
        show_bank = PRB("Bank angle indicator")
        show_horizon = PRB("horizon line")
        show_center = PRB("Aircraft symbol (w)")
        show_VVS = PRB("Velocity vector symbol")
        show_VVS_heli = PRB("Velocity vector for helicopter")
        hide_VVS_heli = PRB("If high speed, hide vector (heli)")
        laser_direction = PRB("laser direction")
        show_WPmk = PRB("waypoint marker")
        show_WPmk_label = PRB("waypoint marker label")
        show_WPmk_dist = PRB("waypoint marker distance")
        show_WP_dist = PRB("waypoint distance")
        show_WP_time = PRB("waypoint arrival time")
        
        attitudeMinAngle = math.floor(PRN("Minimum angle of pitch ladder"))
    end

    do
        spdMaxDigits = maxDigits(500, spd_unit)
        altMaxDigits = maxDigits(30000, alt_unit)
        distMaxDigits = clamp(maxDigits(150000, dist_unit), 3, 100)

        seatQt = euler2Qt(INN(4), INN(5), INN(6))
        pos = offset("Eye offset xyz", {INN(1), INN(3), INN(2)}, seatQt)
        Vxyz = {INN(7), INN(8), INN(11)}

        eyeQt = euler2Qt(-INN(10)*pi2, INN(9)*pi2, 0)

        gndAlt = INN(21)*alt_unit
        airAlt = INN(2)*alt_unit
        
        gndSpd = INN(13)*spd_unit
        airSpd = INN(20)*spd_unit

        compass = INN(17)*pi2
        
        WPxyz = {INN(22), INN(23), INN(24)}   --ウェイポイント座標
        WPDist = INN(25)*dist_unit
        WPTime = INN(26)
        WPDetected = INN(27) == 1
        AP = INN(28) == 1
    end

    --レーザー方向補正
    if laser_direction then
        Lpi, Lya = rect2Polar(world2Local(world2Local({0, 0, -1}, ZERO3, seatQt), ZERO3, euler2QtR(-pi2/4, 0, 0)), false)
        OUN(1, Lya*8)
        OUN(2, Lpi*8)
    end
end

function onDraw()
    setParam(FOV_H)

    green()

    --中心線(Wマーク)
    if show_center or show_VVS_heli then
        x1, y1, forward1 = localRect2Display({0, 1, 0}, eyeQt)
        if forward1 then
            screen.drawLine(x1, y1, x1 + 3, y1 + 4)
            screen.drawLine(x1, y1, x1 - 3, y1 + 4)
            screen.drawLine(x1 + 3, y1 + 4, x1 + 6, y1)
            screen.drawLine(x1 - 3, y1 + 4, x1 - 6, y1)
            screen.drawLine(x1 + 6, y1, x1 + 11, y1)
            screen.drawLine(x1 - 6, y1, x1 - 11, y1)
        end
    end

    --速度ベクトル
    if show_VVS and math.abs(gndSpd/spd_unit) > 0.05 then
        x1, y1, forward1 = localRect2Display(Vxyz, eyeQt)
        if forward1 then
            screen.drawCircle(x1, y1, 3)
            screen.drawLine(x1 + 3, y1, x1 + 10, y1)
            screen.drawLine(x1 - 3, y1, x1 - 10, y1)
            screen.drawLine(x1, y1 - 3, x1, y1 - 8)
        end
    end

    --速度ベクトル(ヘリ用)
    if show_VVS_heli and math.abs(gndSpd/spd_unit) > 0.05 and not (hide_VVS_heli and gndSpd > 30) then
        x1, y1, forward1 = localRect2Display({0, 1, 0}, eyeQt)
        x2, y2 = clamp(Vxyz[1], -30, 30), clamp(-Vxyz[3], -30, 30)
        if forward1 then
            screen.drawLine(x1, y1, x1 + x2, y1 + y2)
        end
    end

    --水平線
    optionQt = euler2QtR(0, 0, -compass)
    if show_horizon or show_VVS then
        local start_deg = 5
        if not show_center then
            start_deg = 0
        end
        
        for i = start_deg, 180, 45 do
            --左右
            for j = -1, 1, 2 do
                x1, y1, forward1 = worldPolar2Display(0, j*i/360, optionQt, seatQt, eyeQt)
                x2, y2, forward2 = worldPolar2Display(0, j*(i + 45)/360, optionQt, seatQt, eyeQt)
        
                if forward1 and forward2 then
                    screen.drawLine(x1, y1, x2, y2)
                end
            end
        end
    elseif show_attitude then   --最低限の水平儀
        --左右
        for j = -1, 1, 2 do
            x1, y1, forward1 = worldPolar2Display(0, j*5/360, optionQt, seatQt, eyeQt)
            x2, y2, forward2 = worldPolar2Display(0, j*15/360, optionQt, seatQt, eyeQt)
    
            if forward1 and forward2 then
                screen.drawLine(x1, y1, x2, y2)
            end
        end
    end

    --ピッチ角度線
    if show_attitude then
        --ピッチ角の刻み
        for i = attitudeMinAngle, 175, attitudeMinAngle do
            --左右対称
            for j = -1, 1, 2 do
                --上下対称
                for k = -1, 1, 2 do
                    optionQt = euler2QtR(pi2*k*i/360, 0, -compass)
                    --線
                    x1, y1, forward1, drawable1 = worldPolar2Display(0, j*12/360, optionQt, seatQt, eyeQt)
                    x2, y2, forward2, drawable2 = worldPolar2Display(0, j*5/360, optionQt, seatQt, eyeQt)
                    x3, y3, forward3, drawable3 = worldPolar2Display(0, j*12/360, euler2QtR(pi2*k*(i - 1)/360, 0, -compass), seatQt, eyeQt)
                    --角度
                    x4, y4, forward4, drawable4 = worldPolar2Display(0, j*16/360, optionQt, seatQt, eyeQt)
            
                    if forward1 and forward2 and forward3 and forward4 then
                        if drawable1 or drawable2 then
                            if k == 1 then
                                screen.drawLine(x1, y1, x2, y2)
                            else
                                drawDottedLine(x2, y2, x1, y1)
                            end
                        end
                        if drawable1 or drawable3 then
                            screen.drawLine(x1, y1, x3, y3)
                        end
                        if drawable4 then
                            screen.drawText(x4 - 2.5*#tostring(k*i), y4 - 3, k*i)
                        end
                    end
                end
            end
        end
    end

    --方位角
    if show_azimuth then
        Wx, Wy = TUP(local2World(local2World({0, 1, 0}, ZERO3, eyeQt), ZERO3, seatQt))      --視点方向の方位角
        eyeAz = -math.atan(Wx, Wy)/pi2
        _, _, Wz = TUP(local2World(local2World({0, 0, 1}, ZERO3, eyeQt), ZERO3, seatQt))    --視点方向のZ軸成分

        j = Wz > 0 and 1 or -1

        for i = 0, j*355, j*5 do
            x1, y1, forward1 = local2Display(polar2Rect(19.5/360, i/360 + j*eyeAz, 1, false))
            
            if forward1 then
                screen.drawLine(x1, y1 + 2, x1, y1 - 2)
                if i%10 == 0 then
                    screen.drawText(x1 - 4, y1 - 7, string.format("%02d", j*i/10))
                end
            end
        end

        --方位角数値
        x1 = math.floor(w/2)
        eyeAz = string.format("%03.0f", 360*((-compass/pi2)%1))
        black()
        screen.drawRectF(x1 - 10, 9, 20, 11)
        green()
        screen.drawRect(x1 - 9, 10, 17, 8)
        screen.drawTextBox(x1 - 8, 11, 16, 7, eyeAz, 0, 0)
    end

    --バンク角
    if show_bank then
        --バンク角計算
        Wx, Wy, Wz = TUP(local2World(local2World({1, 0, 0}, ZERO3, seatQt), ZERO3, euler2QtR(0, 0, -compass)))
        bank = math.acos(Wx)
        bank = Wz > 0 and bank or -bank

        --三角
        x1, y1, forward1 = localRect2Display({0, 1, 0}, eyeQt)
        x2, y2 = x1 + 50*math.sin(-bank), y1 + 50*math.cos(-bank)
        x3, y3 = x1 + 45*math.sin(-bank + 0.05), y1 + 45*math.cos(-bank + 0.05)
        x4, y4 = x1 + 45*math.sin(-bank - 0.05), y1 + 45*math.cos(-bank - 0.05)
        if forward1 then
            screen.drawTriangle(x2, y2, x3, y3, x4, y4)
        end

        --ゲージ
        for i = -50, 50, 10 do
            x2, y2 = x1 + 51*math.sin(pi2*i/360), y1 + 51*math.cos(pi2*i/360)
            x3, y3 = x1 + 56*math.sin(pi2*i/360), y1 + 56*math.cos(pi2*i/360)
            if forward1 then
                if i == 0 then
                    screen.drawText(x2 - 1, y2 + 1, "0")
                else
                    screen.drawLine(x2, y2, x3, y3)
                end
            end
        end
    end

    --ウェイポイント
    if WPDetected then
        --距離数値
        if WPDist >= 10 then
            WPd = string.format("%.0f", math.floor(WPDist + 0.5))
        else
            WPd = string.format("%.1f", math.floor(WPDist*10 + 0.5)/10)
        end

        --ウェイポイントマーカー
        if show_WPmk then
            --ディスプレイ座標へ変換
            x1, y1, forward1 = localRect2Display(world2Local(WPxyz, pos, seatQt), eyeQt)
            if forward1 then
                green()
                screen.drawCircle(x1, y1, 5)
                if show_WPmk_label then
                    screen.drawText(x1 - 4, y1 - 11, "WP")
                end
                if show_WPmk_dist then
                    screen.drawText(x1 + 1 - 2.5*#WPd, y1 + 7, WPd)
                end
            end
        end

        --距離描画
        if show_WP_dist then
            x1, y1 = math.floor(w/5), math.floor(3*h/5)
            black()
            screen.drawRectF(x1 - 5 - 5*distMaxDigits, y1, 13 + 5*distMaxDigits, 7)
            green()
            screen.drawText(x1 - 4 - 5*distMaxDigits, y1 + 1, "WP")
            screen.drawText(x1 + 8 - 5*#WPd, y1 + 1, WPd)
        end

        --到達時間
        if show_WP_time then
            x1, y1 = math.floor(w/5), math.floor(3*h/5)
            WP_hou = string.format("%d", math.floor(WPTime/3600))
            WP_sec = string.format("%02.0f", math.floor(WPTime%60 + 0.5))
            if WPTime < 3600 then
                WP_min = string.format("%d", math.floor((WPTime/60)%60))
                WPt = WP_min..":"..WP_sec
            elseif WPTime >= 36000 then
                WPt = "-:--:--"
            else
                WP_min = string.format("%02.0f", math.floor((WPTime/60)%60))
                WPt = WP_hou..":"..WP_min..":"..WP_sec
            end
            black()
            screen.drawRectF(x1 + 7 - 5*#WPt, y1 + 7, 5*#WPt + 1, 7)
            green()
            screen.drawText(x1 + 8 - 5*#WPt, y1 + 8, WPt)
        end
    end

    --オートパイロット表示
    if AP then
        x1, y1 = math.floor(w/5), math.floor(3*h/5)
        black()
        screen.drawRectF(x1 - 5 - 5*distMaxDigits, y1 - 7, 11, 7)
        green()
        screen.drawText(x1 - 4 - 5*distMaxDigits, y1 - 6, "AP")
    end

    --速度数値
    if gnd_main then
        main_speed = gndSpd
        sub_speed = airSpd
        sub_tag = "AS"
    else
        main_speed = airSpd
        sub_speed = gndSpd
        sub_tag = "GS"
    end

    --メイン速度
    if (gnd_main and show_gnd_speed) or (not gnd_main and show_air_speed) then
        x1, y1 = math.floor(w/5), math.floor(h/3)
        spd = string.format("%d", math.floor(main_speed + 0.5))
        black()
        screen.drawRectF(x1 + 5 - 5*spdMaxDigits, y1, 5*spdMaxDigits + 5, 11)
        green()
        screen.drawRect(x1 + 6 - 5*spdMaxDigits, y1 + 1, 5*spdMaxDigits + 2, 8)
        screen.drawText(x1 + 8 - 5*#spd, y1 + 3, spd)
    end

    --サブ速度
    if (gnd_main and show_air_speed) or (not gnd_main and show_gnd_speed) then
        --大気速度数値
        spd = string.format("%d", math.floor(sub_speed + 0.5))
        black()
        screen.drawRectF(x1 - 5 - 5*spdMaxDigits, y1 + 10, 5*spdMaxDigits + 13, 7)
        green()
        screen.drawText(x1 - 4 - 5*spdMaxDigits, y1 + 11, sub_tag)
        screen.drawText(x1 + 8 - 5*#spd, y1 + 11, spd)
    end

    --高度数値
    if show_air_alt then
        x1, y1 = math.floor(4*w/5), math.floor(h/3)
        alt = string.format("%d", math.floor(airAlt + 0.5))
        ofst = 2*altMaxDigits
        black()
        screen.drawRectF(x1 - ofst, y1, 5 + 5*altMaxDigits, 11)
        green()
        screen.drawRect(x1 + 1 - ofst, y1 + 1, 2 + 5*altMaxDigits, 8)
        screen.drawText(x1 + 3 + 1.5*ofst - 5*#alt, y1 + 3, alt)
    end

    --対地高度数値
    if show_gnd_alt then
        x1, y1 = math.floor(4*w/5), math.floor(2*h/3)
        alt = string.format("%d", math.floor(gndAlt + 0.5))
        ofst = 2*altMaxDigits
        black()
        screen.drawRectF(x1 - 5 - ofst, y1, 15 + 5*altMaxDigits, 11)
        green()
        screen.drawText(x1 - 4 - ofst, y1 + 3, "AG")
        screen.drawRect(x1 + 6 - ofst, y1 + 1, 2 + 5*altMaxDigits, 8)
        screen.drawText(x1 + 8 + 1.5*ofst - 5*#alt, y1 + 3, alt)
    end
end



