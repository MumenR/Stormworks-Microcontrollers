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

--y = ax + b を求める
--y[i] = {y1, y2, y3...}
function least_squares_method(y)
    local ave_x = 0
    local ave_y = 0

    for i = 1, #y do
        ave_x = ave_x + i 
        ave_y = ave_y + y[i]
    end

    ave_x = ave_x/#y
    ave_y = ave_y/#y

    local Sx2 = 0
    local Sxy = 0

    for i = 1, #y do
        Sx2 = Sx2 + (i - ave_x)^2
        Sxy = Sxy + (i - ave_x)*(y[i] - ave_y)
    end

    Sx2 = Sx2/#y
    Sxy = Sxy/#y

    local a = Sxy/Sx2
    local b = ave_y - a*ave_x

    return a, b
end

speed_table = {}
fuel_flow_table = {}

function onTick()
    fuel = INN(1)
    sample_num = INN(2)
    fuel_flow_raw = INN(3)
    speed_raw = INN(13)

    --平均化テーブルに追加
    table.insert(speed_table, speed_raw)
    table.insert(fuel_flow_table, fuel_flow_raw)

    --サンプルが多ければ削除
    while #speed_table > sample_num do
        table.remove(speed_table, 1)
    end
    while #fuel_flow_table > sample_num do
        table.remove(fuel_flow_table, 1)
    end

    --最小二乗法
    speed_a, speed_b = least_squares_method(speed_table)
    fuel_flow_a, fuel_flow_b = least_squares_method(fuel_flow_table)
    
    --平均の算出
    speed = speed_a*(sample_num/2) + speed_b
    fuel_flow = fuel_flow_a*(sample_num/2) + fuel_flow_b

    --その他計算
    voyage_time = (fuel/fuel_flow)/60
    crusing_distance = (voyage_time*60)*speed/1000
    fuel_economy = (crusing_distance*1000)/fuel

    if fuel_flow <= 0 then
        fuel_flow = 0
        voyage_time = 0
        crusing_distance = 0
        fuel_economy = 0
    end

    OUN(1, fuel)            --L
    OUN(2, fuel_flow)       --L/s
    OUN(3, voyage_time)     --min
    OUN(4, crusing_distance)--km
    OUN(5, fuel_economy)    --m/L
end