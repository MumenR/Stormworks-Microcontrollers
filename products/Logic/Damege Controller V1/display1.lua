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
PRN = property.getNumber
PRB = property.getBool
PRT = property.getText
t = 0
deltaCO2Tick = 300      --最小二乗法のサンプル数
danger = false
draining = false
CO2RatioTable = {}

function onTick()
    fire = INB(1)
    
    pressure = INN(3)
    O2 = INN(11)
    CO2 = INN(5)
    N2 = INN(12)
    H2 = INN(13)
    Steam = INN(8)
    air = O2 + CO2 + N2 + H2 + Steam
    O2Ratio = 100*O2/air
    CO2Ratio = 100*CO2/air

    water = INN(1)
    waterCapacity = INN(2)
    waterRatio = 100*water/waterCapacity

    canEnter = PRB("The type of custome tank")
    useO2 = PRB("Use O2 tanks")

    --危険表示
    if pressure >= 4 or pressure <= 0.12 or O2Ratio <= 15 or CO2Ratio >= 10 then
        danger = true
    else
        danger = false
    end

    --浸水対策
    if waterRatio > 1  then
        draining = true
    elseif waterRatio < 0.1 then
        draining = false
    end

    --気圧設定
    if canEnter and draining then
        targetAtm = 3.8
    elseif canEnter then
        targetAtm = 1
    else
        targetAtm = 40
    end

    OUN(1, O2Ratio)
    OUN(2, CO2Ratio)
    OUN(3, pressure)

    OUB(5, pressure - targetAtm < 0.05)     --air in
    OUB(6, pressure - targetAtm > 0.05)     --air out
    OUB(7, draining)                        --water out

    t = t + 1

    --debug
    OUN(32, deltaCO2)
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()

    if danger then
        screen.setColor(255, 0, 0)
        screen.drawClear()
    end

    draw_pressure = string.format("%.2f", pressure)
    draw_O2_ratio = string.format("%.1f%%", O2Ratio)
    draw_CO2_ratio = string.format("%.2f%%", CO2Ratio)
    
    screen.setColor(0, 255, 0)
    screen.drawText(w/2 - 7, h/2 - 14, "atm")
    screen.setColor(255, 255, 255)
    screen.drawText(w/2 - #draw_pressure*2.5, h/2 - 7, draw_pressure)

    screen.setColor(0, 255, 0)
    if t%360 < 180 then
        screen.drawText(w/2 - 5, h/2 + 1, "o2")
        screen.setColor(255, 255, 255)
        screen.drawText(w/2 - #draw_O2_ratio*2.5, h/2 + 8, draw_O2_ratio)
    else
        screen.drawText(w/2 - 7, h/2 + 1, "co2")
        screen.setColor(255, 255, 255)
        screen.drawText(w/2 - #draw_CO2_ratio*2.5, h/2 + 8, draw_CO2_ratio)
    end
end