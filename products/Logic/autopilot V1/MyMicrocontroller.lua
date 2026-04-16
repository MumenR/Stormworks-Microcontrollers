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
        simulator:setInputBool(2, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(1, simulator:getIsClicked(1))

        simulator:setInputNumber(1, simulator:getSlider(1)*1000)
        simulator:setInputNumber(3, simulator:getSlider(2)*1000)
        simulator:setInputNumber(4, simulator:getSlider(3)*1000)
        simulator:setInputNumber(5, simulator:getSlider(4)*1000)

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

sin = math.sin
cos = math.cos
atan = math.atan
pi = math.pi
pi2 = 2*pi

togglebutton = false
toggletouch = false
zoom_i = 0

function atan2(x, y)
    if x >= 0 then
        z = atan(y/x)
    elseif y >= 0 then
        z = atan(y/x) + pi
    else
        z = atan(y/x) - pi
    end
    return z
end

function onTick()
    nowx = INN(1)
    nowy = INN(3)
    tgtx = INN(4)
    tgty = INN(5)
    nowdirection = INN(17)
    arrivaldistance = INN(6)
    button = INB(1)
    touch = INB(2)

    nowdirectionrad = nowdirection*pi*2
    zoom = {500, 1000, 2000, 4000, 8000, 16000, 32000, 50000}

    x = tgtx - nowx
    y = tgty - nowy

    tgtdirection = atan2(x, y)/pi2 - 0.25
    d = nowdirection - tgtdirection

    distance = (x^2 + y^2)^0.5

    if d >= 0.5 then
        direction = d - 1
    elseif d >= -0.5  then
        direction = d
    else
        direction = d + 1
    end

    if button and not togglebutton then
        autopilot = not autopilot
    end
    togglebutton = button

    if autopilot and distance < arrivaldistance then
        autopilot = false
    end

    yaw = 0
    if autopilot then
        yaw = -direction
    end

    if touch and (not toggletouch) then
        zoom_i = (zoom_i + 1)%8
    end
    toggletouch = touch
    km = zoom[zoom_i + 1]/1000

    OUN(1, yaw)
    OUB(1, autopilot)
end

function onDraw()
    w = 0.5*screen.getWidth()
    h = 0.5*screen.getHeight()
    
    screen.drawMap(nowx, nowy, km)

    pixelX, pixelY = map.mapToScreen(nowx, nowy, km, 2*w, 2*h, tgtx, tgty)

    x1 = w - 2*sin(nowdirectionrad)
    y1 = h - 2*cos(nowdirectionrad)
    x2 = w - 6*sin(nowdirectionrad)
    y2 = h - 6*cos(nowdirectionrad)

    screen.setColor(255, 0, 0)
    screen.drawCircleF(pixelX, pixelY, 1.5)
    screen.drawLine(w, h, pixelX, pixelY)
    screen.setColor(255, 127, 0)
    screen.drawText(1, 1, string.format("TGT %.1fkm", distance/1000))

    scale = string.format("%.1fkm", km)
    
    screen.setColor(0, 255, 0)
    screen.drawCircle(w, h, 2)
    screen.drawLine(x1, y1, x2, y2)
    screen.drawText(2*w - 5*#scale, 2*h - 5, scale)

end