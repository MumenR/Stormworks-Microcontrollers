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
        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)

        simulator:setInputNumber(7, simulator:getSlider(1)*3)
        simulator:setInputNumber(8, simulator:getSlider(2)*1.5)
        simulator:setInputNumber(9, simulator:getSlider(3)*130)
        simulator:setInputNumber(10, simulator:getSlider(4)*4000)
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

log = math.log
tan = math.tan
atan = math.atan
exp = math.exp
abs = math.abs
pi = math.pi
zoomrad = 0

zoom = 0  -- 0 to 1

nightvision = false
laser = false
stabilizer = false
traking = false
touchlast = false

function rad(degrees)
    return pi*degrees/180
end

function deg(radians)
    return 180*radians/pi
end

cammaxrad = rad(135)/2  --FOV[rad] when input value is 0
camminrad = 0.025/2     --FOV[rad] when input value is 1

function calzoom(zoom, minfov, maxfov)
    minrad = rad(minfov)/2
    maxrad = rad(maxfov)/2

    zoomrad = (camminrad - cammaxrad)*zoom + cammaxrad
    
    a = log(tan(minrad)/tan(maxrad))/(camminrad - cammaxrad)
    C = log(tan(minrad)) - camminrad*a
    zoomrad = atan(exp(a*zoomrad + C))

    zoom = (zoomrad - cammaxrad)/(camminrad - cammaxrad)

    return zoom
end

function calspeed(x, gain)
    speed = gain*x*tan(zoomrad)
    
    if speed >= 0 then
        speed = speed + 0.1
    else
        speed = speed - 0.1
    end
    speed = string.format("%.5f", speed)
    return speed
end

function onTick()
    maxx = INN(1)
    maxy = INN(2)
    x = INN(3)
    y = INN(4)
    gain = INN(7)
    minfov = INN(8)-- degrees
    maxfov = INN(9)-- degrees
    distance = INN(10)
    direction = INN(11)

    touch = INB(1)

    distance = string.format("D:%dm", math.floor(distance))

    pitch = 0 -- -1 to 1
    yaw = 0   -- -1 to 1
    zoompulus = false
    zoomminus = false

    if touch then
        --pitch, yaw
        if abs(x - maxx/2) < (maxy/2 - 8) and abs(y - maxy/2) < (maxy/2 - 8) then
            yaw = (x - maxx/2)/(maxy/2 - 8)
            pitch = -(y - maxy/2)/(maxy/2 - 8)
        end

        --push bottun
        if y >= maxy - 7 and y <= maxy then
            if x >= maxx/2 - 27 and x <= maxx/2 - 21 then
                zoompulus = true
                if zoom <= 1 then
                    zoom = zoom + 0.5/60
                end
            end
            if x >= maxx/2 - 18 and x <= maxx/2 - 12 then
                zoomminus = true
                if zoom >= 0 then
                    zoom = zoom - 0.5/60
                end
            end
            
            --toggle bottun
            if touchlast == false then
                if x >= maxx/2 - 9 and x <= maxx/2 - 2 then
                    nightvision = not nightvision
                end
                if x >= maxx/2 and x <= maxx/2 + 7 then
                    laser = not laser
                end
                if x >= maxx/2 + 9 and x <= maxx/2 + 16 then
                    stabilizer = not stabilizer
                end
                if x >= maxx/2 + 18 and x <= maxx/2 + 25 then
                    traking = not traking
                end
            end
        end
        touchlast = true
    else
        touchlast = false
    end
    
    zoomcal = calzoom(zoom, minfov, maxfov)

    pitchcal = calspeed(pitch, gain)
    yawcal = direction*calspeed(yaw, gain)
    
    OUN(1, pitchcal)
    OUN(2, yawcal)
    OUN(3, zoomcal)
    OUB(1, nightvision)
    OUB(2, laser)
    OUB(3, stabilizer)
    OUB(4, traking)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(0, 255, 0, 200)
    screen.drawRect(w/2 - h/10, h/2 - h/10, h/5, h/5)
    if laser then
        screen.drawText(w/2 - 2.5*#distance, 1, distance)
    end
    screen.setColor(0, 255, 0, 128)
    screen.drawRect(w/2 - h/2 + 8, 8, h - 16, h - 16)

    screen.setColor(32, 32, 32)
    screen.drawRectF(w/2 - 28, h - 7, 55, 7)
    
    screen.setColor(128, 128, 128)
    for i = 0, 1 do
        screen.drawRectF(w/2 - 27 + i*9 , h - 6, 7, 5)
        screen.drawRectF(w/2 - 26 + i*9 , h - 7, 5, 7)
    end
    for i = 0, 3 do
        screen.drawRectF(w/2 - 9 + i*9 , h - 6, 8, 5)
        screen.drawRectF(w/2 - 8 + i*9 , h - 7, 6, 7)
    end
    screen.setColor(0, 255, 0)
    if zoompulus then
        screen.drawRectF(w/2 - 27, h - 6, 7, 5)
        screen.drawRectF(w/2 - 26, h - 7, 5, 7)
    end
    if zoomminus then
        screen.drawRectF(w/2 - 18, h - 6, 7, 5)
        screen.drawRectF(w/2 - 17, h - 7, 5, 7)
    end
    if nightvision then
        screen.drawRectF(w/2 - 9, h - 6, 8, 5)
        screen.drawRectF(w/2 - 8, h - 7, 6, 7)
    end
    if laser then
        screen.drawRectF(w/2, h - 6, 8, 5)
        screen.drawRectF(w/2 + 1, h - 7, 6, 7)
    end
    if stabilizer then
        screen.drawRectF(w/2 + 9, h - 6, 8, 5)
        screen.drawRectF(w/2 + 10, h - 7, 6, 7)
    end
    if traking then
        screen.drawRectF(w/2 + 18 , h - 6, 8, 5)
        screen.drawRectF(w/2 + 19 , h - 7, 6, 7)
    end

    list = {"+", "-", "N", "L", "S", "T"}
    screen.setColor(255, 255, 255)
    for i = 0, 5 do
        screen.drawText(w/2 - 25 + 9*i, h-6 ,list[i + 1])
    end
    
end
