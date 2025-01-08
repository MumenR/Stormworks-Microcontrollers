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
log = math.log
tan = math.tan
atan = math.atan
exp = math.exp
pi = math.pi
zoomrad = 0

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

function calspeed(x, gain, cam)
    speed = gain*x*tan(zoomrad)
    if cam then
        if speed >= 0 then
            speed = speed + 0.1
        else
            speed = speed - 0.1
        end
    end
    speed = string.format("%.5f", speed)
    return speed
end

function onTick()
    pitch = INN(1) -- -1 to 1
    yaw = INN(2)   -- -1 to 1
    zoom = INN(3)  -- 0 to 1
    gain = INN(4)
    minfov = INN(5)-- degrees
    maxfov = INN(6)-- degrees
    camS = INB(1)

    zoom = calzoom(zoom, minfov, maxfov)

    pitch = calspeed(pitch, gain, camS)
    yaw = calspeed(yaw, gain, camS)
    
    OUN(1, pitch)
    OUN(2, yaw)
    OUN(3, zoom)
end