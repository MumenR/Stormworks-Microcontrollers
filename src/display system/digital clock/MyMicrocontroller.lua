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
        simulator:setInputNumber(1, simulator:getSlider(1))
        simulator:setInputBool(1, simulator:getIsToggled(1))
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
ticks = 0
function onTick()
    white_mode = input.getBool(1)

    ticks = (ticks + 1)%60
    time = 24*INN(1)

    hour = math.floor(time)
    min = math.floor(60*(time%1))

    formatmin = string.format("%02d", min)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(255, 255, 255)
    if white_mode then
        screen.drawClear()
        screen.setColor(0, 0, 0)
    end

    screen.drawText(w/2 - 5*#tostring(hour) - 2.5, h/2 - 3, hour)

    if ticks < 30 then
        screen.drawText(w/2 - 2.5, h/2 - 3, ":")
        screen.drawText(w/2 + 2.5, h/2 - 3, formatmin)
    else
        screen.drawText(w/2 + 2.5, h/2 - 3, formatmin)
    end
end



