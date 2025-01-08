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

        simulator:setProperty("label1", "TMP")
        simulator:setProperty("label2", "RPM")

        simulator:setInputNumber(1, simulator:getSlider(1)*1000)
        simulator:setInputNumber(2, simulator:getSlider(2)*1000)
        simulator:setInputNumber(3, simulator:getSlider(3)*1000)
        simulator:setInputNumber(4, simulator:getSlider(4)*1000)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
INB = input.getBool
PRT = property.getText

function align_digit(x)
    return string.format("%.0f", x)
end

function onTick()
    label = {PRT("label1"), PRT("label2")}

    value = {}
    for i = 1, 4 do
        table.insert(value, align_digit(INN(i)))
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(0, 128, 255)

    screen.drawLine(w/2, h/4 + 1, w/2, h/2)
    screen.drawLine(w/2, h*3/4 + 1, w/2, h)

    for i = 1, 4 do
        screen.drawLine(0, h*(i - 1)/4, w, h*(i - 1)/4)
    end
    
    for i = 1, 2 do
        screen.setColor(255, 255, 255)
        screen.drawText(w/2 - math.floor(2.5*#label[i]), h*(2*i - 1)/4 - 6, label[i])
        screen.setColor(0, 255, 0)
        screen.drawText(w/4 - math.floor(2.5*#value[2*i - 1]), h*(2*i - 1)/4 + 2, value[2*i - 1])
        screen.drawText(w*3/4 - math.floor(2.5*#value[2*i]) + 1, h*(2*i - 1)/4 + 2, value[2*i])
    end
    
end



