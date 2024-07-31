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
lock_on_y = 0

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

function onTick()
    sonar_table = {}
    abs_sonar = {}

    sonar_fov = property.getNumber("sonar fov")

    --情報読み込み
    for i = 1, 16 do
        if INB(i) then
            table.insert(sonar_table, {INN(2*i - 1), INN(2*i)})

            --ロックオン中ならば前回値に最も近いもの、そうでなければ水平方向絶対値が最小のものを選択
            if lock_on then
                table.insert(abs_sonar, math.sqrt((INN(2*i - 1) - lock_on_x)^2 + (INN(2*i) - lock_on_y)^2))
            else
                table.insert(abs_sonar, math.abs(INN(2*i - 1)))
            end
        end
    end

    min_i = find_Min_And_Index(abs_sonar)

    --設定視野内ならば出力しロックオン
    if math.abs(sonar_table[min_i][1]) <= sonar_fov/2 then
        lock_on_x = sonar_table[min_i][1]
        lock_on_y = sonar_table[min_i][2]
        lock_on = true
    else
        lock_on_x, lock_on_y = 0, 0
        lock_on = false
    end

    --チック遅延対策のため、オン/オフを0 or 1に変換
    if lock_on then
        lock_on_num = 1
    else
        lock_on_num = 0
    end

    OUN(1, lock_on_x)
    OUN(2, lock_on_y)
    OUN(3, lock_on_num)

end