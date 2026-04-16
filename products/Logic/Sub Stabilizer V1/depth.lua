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
        simulator:setInputNumber(1, simulator:getSlider(1)*2 - 1)
        simulator:setInputNumber(2, simulator:getSlider(2)*-300)
        simulator:setInputNumber(3, simulator:getSlider(3)*-300)

        simulator:setInputBool(1, simulator:getIsClicked(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))

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

depthmax = 0
depthmin = -999
setdepth = 0
updown_gain = 0.03

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
end

function onTick()
    manual = INN(1)
    key = INN(2)
    depth = INN(3)
    speed = INN(4)
    keyset = INB(1)
    emg_surface = INB(2)

    if emg_surface then
        setdepth = 0
    elseif keyset then
        setdepth = key
    elseif manual == 1 and setdepth < depthmax then
        setdepth = setdepth + updown_gain
    elseif manual == -1 and setdepth > depthmin then
        setdepth = setdepth - updown_gain
    end

    diff_depth = setdepth - depth

    if speed > 5 then
        pitch_trim = 0.03*clamp(diff_depth/10, -1, 1)/clamp(math.abs(speed/30), 1, 100)
    elseif speed < -5 then
        pitch_trim = -0.03*clamp(diff_depth/10, -1, 1)/clamp(math.abs(speed/30), 1, 100)
    else
        pitch_trim = 0
    end

    OUN(1, setdepth)
    OUN(2, diff_depth)
    OUN(3, pitch_trim)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    if setdepth <= -100 then
        draw_setdepth = string.format("%.0fm", setdepth)
    else
        draw_setdepth = string.format("%.1fm", setdepth)
    end

    if depth <= -100 then
        draw_depth = string.format("%.0fm", depth)
    else
        draw_depth = string.format("%.1fm", depth)
    end
    
    screen.setColor(0, 255, 0)
    screen.drawText(w/2 - 7, h/2 - 14, "set")
    screen.drawText(w/2 - #draw_setdepth*2.5, h/2 - 7, draw_setdepth)

    screen.setColor(255, 255, 255)
    screen.drawText(w/2 - 7, h/2 + 1, "now")
    screen.drawText(w/2 - #draw_depth*2.5, h/2 + 8, draw_depth)
end



