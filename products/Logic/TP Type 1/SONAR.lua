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
lock_on_x = 0
lock_on_z = 0
lock_on_x_table = {}
lock_on_z_table = {}

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

--y = ax + bを最小二乗法で求める
function least_squares_method(y)
    local ave_x, ave_y, Sx2, Sxy = 0, 0, 0, 0

    if #y > 4 then
        for i = 1, #y do
            ave_x = ave_x + i 
            ave_y = ave_y + y[i]
            Sx2 = Sx2 + (i - ave_x)^2
            Sxy = Sxy + (i - ave_x)*(y[i] - ave_y)
        end
    
        ave_x = ave_x/#y
        ave_y = ave_y/#y
        Sx2 = Sx2/#y
        Sxy = Sxy/#y
    
        a = Sxy/Sx2
        b = ave_y - a*ave_x
    elseif #y > 0 then
        a, b = 0, y[#y]
    else
        a, b = 0, 0
    end
    
    return a, b
end

--比例航法
function proportional_navigation(target_direction_x, target_direction_z)
    local target_direction_vx = target_direction_x - last_x
    local target_direction_vy = target_direction_z - last_z
    last_x = target_direction_x
    last_z = target_direction_z
    return target_direction_vx, target_direction_vy
end

function onTick()
    sonar_table = {}
    compare_sonar = {}

    sonar_fov = property.getNumber("sonar fov")
    sample_num = property.getNumber("number of samples")

    mode = INN(29)
    sonar_on = (INN(30) == 1)
    target_rotate_x = INN(31)
    target_rotate_z = INN(32)

    if sonar_on then
        --情報読み込み
        for i = 1, 14 do
            if INB(i) then
                table.insert(sonar_table, {INN(2*i - 1), INN(2*i)})

                --ロックオン中ならば追跡値との差を比較
                if lock_on then
                    table.insert(compare_sonar, math.sqrt((INN(2*i - 1) - lock_on_x)^2 + (INN(2*i) - lock_on_z)^2))
                --座標指定誘導なら目標座標との差を比較
                elseif mode == 1 then
                    table.insert(compare_sonar, math.sqrt((INN(2*i - 1) - target_rotate_x)^2 + (INN(2*i) - target_rotate_z)^2))
                --方位角指定なら方位との差を比較
                elseif mode == 2 then
                    table.insert(compare_sonar, math.abs(INN(2*i - 1) - target_rotate_x))
                end
            end
        end

        if #sonar_table >= 1 then
            min_i = find_Min_And_Index(compare_sonar)

            --設定視野内ならばテーブルに追加
            if math.abs(sonar_table[min_i][1]) <= sonar_fov/2 then
                table.insert(lock_on_x_table, sonar_table[min_i][1])
                table.insert(lock_on_z_table, sonar_table[min_i][2])
                lock_on = true
            else
                lock_on_x_table, lock_on_z_table = {}, {}
                lock_on = false
            end
        else
            lock_on_x_table, lock_on_z_table = {}, {}
            lock_on = false
        end

        --古いデータを削除
        if #lock_on_x_table > sample_num then
            table.remove(lock_on_x_table, 1)
        end
        if #lock_on_z_table > sample_num then
            table.remove(lock_on_z_table, 1)
        end
        
        ax, bx = least_squares_method(lock_on_x_table)
        az, bz = least_squares_method(lock_on_z_table)

        lock_on_x = ax*(sample_num + 1) + bx
        lock_on_z = az*(sample_num + 1) + bz
    else
        lock_on = false
        ax, az = 0, 0
    end

    --遅延対策のため、オン/オフを0 or 1に変換
    if lock_on then
        lock_on_num = 1
    else
        lock_on_num = 0
    end

    OUN(1, ax)
    OUN(2, az)
    OUN(3, lock_on_num)

end