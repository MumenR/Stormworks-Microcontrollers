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
OUN = output.setNumber
Fueltable = {}
Speedtable = {}

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

function onTick()

    Fuel = INN(1)
    Speed = INN(13)
    n = INN(2)
    table.insert(Fueltable, Fuel)
    table.insert(Speedtable, Speed)

    if #Fueltable > n then
        table.remove(Fueltable, 1)
    end

    a, b = least_squares_method(Fueltable)
    Fueldelta = math.abs(a*60)

    if #Speedtable > n then
        table.remove(Speedtable, 1)
    end

    speed_ave = 0    
    for i = 1, #Speedtable do
        speed_ave = speed_ave + Speedtable[i]
    end
    speed_ave = speed_ave/#Speedtable

    if Fueldelta > 0.005 then
        Fuelsec = Fuel/Fueldelta
    else
        Fuelsec = 0
    end
    Crusingdistance = Fuelsec*speed_ave/1000
    Fueleconomy = Crusingdistance/Fuel

    OUN(1, Fuel)
    OUN(2, Fueldelta)
    OUN(3, Fuelsec/60)
    OUN(4, Crusingdistance)
    OUN(5, Fueleconomy)
end


