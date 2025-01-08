-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
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

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool

lock_on = false
PN_toggle = false
lock_on_x = 0
lock_on_z = 0
lock_on_x_table = {}
lock_on_z_table = {}
t = 0

rawtable = {}
filtertable = {}

-- テーブルの中から最小値のインデックスを返す関数
function find_Min_And_Index(t)
    local minValue = t[1]
    local minIndex = 1
    for i = 2, #t do
        if t[i] < minValue then
            minValue = t[i]
            minIndex = i
        end
    end
    return minIndex
end

function least_squares_method2(xy)
    local a, b, c, n, S1, S2, S3, S4, T0, T1, T2 = 0, 0, 0, #xy, 0, 0, 0 ,0 ,0, 0, 0
    if n <= 5 and n > 0 then
        c = xy[n]
    else
        for i=1, n do
            S1 = S1 + i
            S2 = S2 + i^2
            S3 = S3 + i^3
            S4 = S4 + i^4
            T0 = T0 + xy[i]
            T1 = T1 + i*xy[i]
            T2 = T2 + (i^2)*xy[i]
        end
        local d = 2*S1*S2*S3 + n*S2*S4 - S4*S1^2 - n*S3^2 - S2^3
        a = (n*S2*T2 - T2*S1^2 + S1*S2*T1 - n*S3*T1 + S1*S3*T0 - T0*S2^2)/d
        b = (S1*S2*T2 - n*S3*T2 + n*S4*T1 - T1*S2^2 + S2*S3*T0 - S1*S4*T0)/d
        c = (-T2*S2^2 + S1*S3*T2 - S1*S4*T1 + S2*S3*T1 - T0*S3^2 + S2*S4*T0)/d
    end
    return a, b, c
end

function onTick()
    sonar_table = {}
    compare_sonar = {}
    target_x = 0
    target_z = 0

    sonar_fov = property.getNumber("sonar fov")
    sample_num = INN(29)

    sonar_on = (INN(30) == 1)
    target_rotate_x = INN(31)
    target_rotate_z = INN(32)

    sonar_pn_x = INN(27)
    sonar_pn_z = INN(28)

    if sonar_on then
        --情報読み込み
        for i = 1, 13 do
            if INB(i) then
                table.insert(sonar_table, {INN(2*i - 1), INN(2*i)})

                --ロックオン中ならば追跡値との差を比較
                if lock_on then
                    table.insert(compare_sonar, math.sqrt((INN(2*i - 1) - lock_on_x)^2 + (INN(2*i) - lock_on_z)^2))
                --そうでなければ目標座標との差を比較
                else
                    table.insert(compare_sonar, math.sqrt((INN(2*i - 1) - target_rotate_x)^2 + (INN(2*i) - target_rotate_z)^2))
                end
            end
        end

        if #sonar_table >= 1 then
            min_i = find_Min_And_Index(compare_sonar)

            --設定視野内ならば追跡値を上書き
            --視野範囲外の後方部分を円形とし、計算・判定
            if math.abs(sonar_table[min_i][1]) > sonar_fov/2 and (math.sin(sonar_table[min_i][2]*2*math.pi))^2 + (math.cos(sonar_table[min_i][2]*2*math.pi)*math.sin(sonar_table[min_i][1]*2*math.pi))^2 < (math.sin(sonar_fov*2*math.pi))^2 then
                lock_on = false
                PN_toggle = false
                lock_on_x = target_rotate_x
                lock_on_z = target_rotate_z
                lock_on_x_table, lock_on_z_table = {}, {}
            else
                lock_on = true

                table.insert(lock_on_x_table, sonar_table[min_i][1])
                table.insert(lock_on_z_table, sonar_table[min_i][2])

                target_x = sonar_table[min_i][1]
                target_z = sonar_table[min_i][2]
                lock_on_x = sonar_table[min_i][1]
                lock_on_z = sonar_table[min_i][2]
            end
        else
            lock_on = false
        end

        --#サンプル数を一定値に保つ
        while #lock_on_x_table > sample_num do
            table.remove(lock_on_x_table, 1)
        end
        while #lock_on_z_table > sample_num do
            table.remove(lock_on_z_table, 1)
        end

        --最小二乗法
        ax, bx, cx = least_squares_method2(lock_on_x_table)
        az, bz, cz = least_squares_method2(lock_on_z_table)

        --距離が近い()
        if t >= 180 and #lock_on_x_table >= sample_num then
            PN_toggle = true
        elseif lock_on then
            t = t + 1
        else
            t = 0
            PN_toggle = false
        end

        --[[
        
        if PN_toggle then
            target_x = ax*60
            target_z = az*60
        end

        ]]
    else
        lock_on = false
        ax, az = 0, 0
        bx, bz = 0, 0
        cx, cz = 0, 0
    end

    --遅延対策のため、オン/オフを0 or 1に変換
    if lock_on then
        lock_on_num = 1
    else
        lock_on_num = 0
    end

    OUN(1, target_x)
    OUN(2, target_z)
    OUN(3, lock_on_num)

    --グラフ描画用
    table.insert(rawtable, target_x)
    table.insert(filtertable, ax*(sample_num^2) + bx*sample_num + cx)
    
    max_sample = 288
    if #rawtable > max_sample then
        table.remove(rawtable, 1)
    end
    if #filtertable > max_sample then
        table.remove(filtertable, 1)
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(255, 255, 255)
    screen.drawLine(0, h/2, w, h/2)

    screen.setColor(255, 255, 255, 128)
    for i = 1, 9 do
        line = math.floor(h*i/10)
        screen.drawLine(0, line, w, line)
        text = string.format("%.3f", 0.01 - 0.002*i)
        screen.drawText(w - #text*5, line - 6, text)
    end
    
    for i = 1, #rawtable do
        screen.setColor(255, 255, 0)
        glaph = math.floor(-rawtable[i]*(h/2)*100 + h/2)
        screen.drawLine(w - #rawtable + i, glaph, w - #rawtable + i + 1, glaph)

        screen.setColor(255, 0, 0)
        glaph = math.floor(-filtertable[i]*(h/2)*100 + h/2)
        screen.drawLine(w - #filtertable + i, glaph, w - #filtertable + i + 1, glaph)
    end
end