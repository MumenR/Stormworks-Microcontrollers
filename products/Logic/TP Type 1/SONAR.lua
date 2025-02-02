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

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

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

error_pre_x = 0
error_sum_x = 0
error_pre_z = 0
error_sum_z = 0

--PID制御
function PID(P, I, D, target, current, error_sum, error_pre)
    local error, error_diff, controll
    error = target - current
    error_sum = error_sum + error
    error_diff = error - error_pre
    controll = P*error + I*error_sum + D*error_diff
    return controll, error_sum, error
end

function onTick()
    sonar_table = {}
    compare_sonar = {}

    launch = (INN(29) == 1)
    terminal_guidance = (INN(30) == 2 or INN(30) == 4)
    sonar_on = (INN(30) == 3 or INN(30) == 4 )
    target_rotate_x = INN(31)
    target_rotate_z = INN(32)

    sonar_fov = property.getNumber("sonar fov")
    P = property.getNumber("P")
    I = property.getNumber("I")
    D = property.getNumber("D")

    if sonar_on then
        --情報読み込み
        for i = 1, 14 do
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
                lock_on_x = target_rotate_x
                lock_on_z = target_rotate_z
            else
                lock_on = true
                lock_on_x = sonar_table[min_i][1]
                lock_on_z = sonar_table[min_i][2]
            end
        else
            lock_on = false
        end
    else
        lock_on = false
    end

    --遅延対策のため、オン/オフを0 or 1に変換
    if lock_on then
        lock_on_num = 1
    else
        lock_on_num = 0
    end

    --出力値調整
    if launch and lock_on and terminal_guidance then
        guidance_x, error_sum_x, error_pre_x = PID(P, I, D, 0, -lock_on_x, error_sum_x, error_pre_x)
        guidance_z, error_sum_z, error_pre_z = PID(P, I, D, 0, -lock_on_z, error_sum_z, error_pre_z)
    else
        error_pre_x = 0
        error_sum_x = 0
        error_pre_z = 0
        error_sum_z = 0
        guidance_x = 0
        guidance_z = 0
    end

    guidance_x = clamp(guidance_x, -1, 1)
    guidance_z = clamp(guidance_z, -1, 1)

    OUN(1, guidance_x)
    OUN(2, guidance_z)
    OUN(3, lock_on_num)

end