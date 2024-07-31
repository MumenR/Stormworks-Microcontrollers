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

        simulator:setInputNumber(4, simulator:getSlider(1)*5)
        simulator:setInputNumber(11, simulator:getSlider(2)*10000)
        simulator:setInputNumber(5, simulator:getSlider(3)*10000)
        simulator:setInputNumber(12, simulator:getSlider(4)*10000)
        simulator:setInputNumber(13, simulator:getSlider(5)*10000)
        simulator:setInputNumber(8, simulator:getSlider(6)*10000)

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

t = 0
danger = true
function onTick()
    pressure = INN(4)
    O2 = INN(11)
    CO2 = INN(5)
    N2 = INN(12)
    H2 = INN(13)
    Steam = INN(8)
    air = O2 + CO2 + N2 + H2 + Steam
    O2_ratio = 100*O2/air
    CO2_ratio = 100*CO2/air

    if pressure > 3.5 or pressure < 0.2 or O2_ratio < 17 or CO2_ratio > 8 then
        danger = true
    else
        danger = false
    end

    OUN(1, O2_ratio)
    OUN(2, CO2_ratio)
    t = t + 1
end

function onDraw()
    h = screen.getHeight()
    w = screen.getWidth()

    if danger then
        screen.setColor(255, 0, 0)
        screen.drawClear()
    end

    draw_pressure = string.format("%.2f", pressure)
    draw_O2_ratio = string.format("%.1f%%", O2_ratio)
    draw_CO2_ratio = string.format("%.2f%%", CO2_ratio)
    
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



