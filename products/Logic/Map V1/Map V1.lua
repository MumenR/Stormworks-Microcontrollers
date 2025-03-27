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
S = screen
sin = math.sin
cos = math.cos
tan = math.tan
pi = 3.141592653589

zoom_i = 0

a = false

function onTick()
    x = INN(1)
    y = INN(3)
    com = 2*pi*INN(17)
    zoom = {INN(4), INN(5), INN(6), INN(7), INN(8), INN(9), INN(10), INN(11)}
    touch = INB(1)

    if touch and (not a) then
        zoom_i = (zoom_i + 1)%8
    end
    a = touch
    km = zoom[zoom_i + 1]/1000
end

function onDraw()
    w = 0.5*S.getWidth()
    h = 0.5*S.getHeight()
    
    x1 = w - 2*sin(com)
    y1 = h - 2*cos(com)
    x2 = w - 6*sin(com)
    y2 = h - 6*cos(com)

    scale = string.format("%.1fkm", km)

    S.drawMap(x, y, km)
    S.setColor(0, 255, 0)
    S.drawCircle(w, h, 2)
    S.drawLine(x1, y1, x2, y2)
    S.drawText(2*w - 5*#scale, 2*h - 5, scale)

end


