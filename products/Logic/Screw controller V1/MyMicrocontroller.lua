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

        -- NEW! button/slider options from the UI

        simulator:setInputNumber(1, simulator:getSlider(1))        -- set input 31 to the value of slider 1
        simulator:setInputNumber(2, simulator:getSlider(2))

        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))-- make button 2 a toggle, for input.getBool(32)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
INB = input.getBool

function onTick()
    L_throttle = string.format("%.0f", INN(1)*100)
    R_throttle = string.format("%.0f", INN(2)*100)
    L_reverse = INB(1)
    R_reverse = INB(2)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    zero = math.floor((h - 5)/2)

    L_lev = math.floor(L_throttle*(h - 9)/200)
    R_lev = math.floor(R_throttle*(h - 9)/200)

    if L_reverse then
        screen.setColor(255, 0, 0)
        screen.drawRectF(w/4 - 4, zero, 9, L_lev + 1)
    else
        screen.setColor(0, 255, 0)
        screen.drawRectF(w/4 - 4, zero, 9, -L_lev)
    end

    if R_reverse then
        screen.setColor(255, 0, 0)
        screen.drawRectF(w*3/4 - 4, zero, 9, R_lev + 1)
    else
        screen.setColor(0, 255, 0)
        screen.drawRectF(w*3/4 - 4, zero, 9, -R_lev)
    end

    --零点棒
    screen.setColor(128, 128, 128)
    screen.drawLine(w/4 - 5, zero, w/4 + 5, zero)
    screen.drawLine(w*3/4 - 5, zero, w*3/4 + 5, zero)

    --縦線とデジタル
    screen.setColor(255, 255, 255)

    screen.drawText(w/4 - #L_throttle*2.5, h - 6, L_throttle)
    screen.drawText(w*3/4 - #R_throttle*2.5, h - 6, R_throttle)
    
    screen.drawLine(w/4 - 5, 2, w/4 - 5, h - 7)
    screen.drawLine(w/4 + 5, 2, w/4 + 5, h - 7)
    screen.drawLine(w*3/4 - 5, 2, w*3/4 - 5, h - 7)
    screen.drawLine(w*3/4 + 5, 2, w*3/4 + 5, h - 7)
end



