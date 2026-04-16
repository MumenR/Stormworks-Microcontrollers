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
        simulator:setInputBool(3, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(11, screenConnection.height)
        simulator:setInputNumber(2, screenConnection.touchX)
        simulator:setInputNumber(12, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))


        simulator:setInputNumber(1, simulator:getSlider(1))
        simulator:setInputNumber(2, simulator:getSlider(2))
        simulator:setInputNumber(3, simulator:getSlider(3))
        simulator:setInputNumber(4, 255)
        simulator:setInputNumber(5, 255)
        simulator:setInputNumber(6, 255)
        simulator:setInputNumber(7, simulator:getSlider(7))
        simulator:setInputNumber(8, simulator:getSlider(8))
        simulator:setInputNumber(9, simulator:getSlider(9))
        simulator:setInputNumber(13, simulator:getSlider(10))


    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
INB = input.getBool
toggle = false
gnd = false
air = false

function spdname(x)
    if x > 900 then
        y = "mm/s"
    elseif x > 190 then
        y = "fpm"
    elseif x > 50 then
        y = "m/min"
    elseif x > 3.5 then
        y = "km/h"
    elseif x > 3 then
        y = "fps"
    elseif x > 2 then
        y = "mph"
    elseif x > 1.5 then
        y = "kn"
    elseif x > 0.9 then
        y = "m/s"
    else
        y = "mpm"
    end
    return y
end

function altname(x)
    if x > 900 then
        y = "mm"
    elseif x > 90 then
        y = "cm"
    elseif x > 37 then
        y = "in"
    elseif x > 6 then
        y = "mi"
    elseif x > 3 then
        y = "ft"
    elseif x > 1.05 then
        y = "yd"
    elseif x > 0.9 then
        y = "m"
    elseif x > 0.0009 then
        y = "km"
	else
		y = "mi"
    end
    return y
end

function digits_number(x)
    local y = #tostring(x)
    return y
end

function onTick()
    v = INN(1)
    z = INN(3)

    spd = INN(13)
    alt = INN(2)
    gndalt = INN(9)
    
    R = INN(4)
    G = INN(5)
    B = INN(6)

    w0 = INN(7)
    h0 = INN(8)

    airspeed = INN(10)
    height = INN(11)
    touchY = INN(12)

    S = INB(1)
    A = INB(2)
    touch = INB(3)

    if touch and not toggle then
        if touchY < height/2 then
            air = not air
        else
            gnd = not gnd
        end
    end
    toggle = touch

    if air then
        spd = airspeed
    end
    if gnd then
        alt = gndalt
    end
end

function onDraw()
    w = screen.getWidth()
	h = screen.getHeight()
	screen.setColor(R, G, B)

    if S then
        spd = v*spd
	    spd = math.floor(spd)
        spdnam = spdname(v)
        airw = 0
        if air then
            spdnam = "air "..spdnam
            airw = 1
        end
        spdN = digits_number(spd)

        screen.drawText((w/2) - 2.5*spdN + w0, (h/2) - 13 - h0, spd)
        screen.drawText((w/2) - 2.5*#spdnam + w0 + airw, (h/2) - 6 - h0, spdnam) 
    end
	
    if A then
        alt = z*alt
        alt = math.floor(alt)
        altnam = altname(z) 
        gndw = 0
        if gnd then
            altnam = "gnd "..altnam
            gndw = 1
        end
        altN = digits_number(alt)

        screen.drawText((w/2) - 2.5*altN + w0, (h/2) + 3 - h0, alt)
	    screen.drawText((w/2) - 2.5*#altnam +w0 + gndw, (h/2) + 10 - h0, altnam)
    end
end

