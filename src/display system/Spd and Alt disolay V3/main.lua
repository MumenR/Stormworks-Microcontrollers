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

        simulator:setInputNumber(1, simulator:getSlider(1)*50)
        simulator:setInputNumber(2, simulator:getSlider(2)*60)   -- set input 32 to the value from slider 2 * 50
        simulator:setInputNumber(3, 1.94384)
        simulator:setInputNumber(4, 1.94384)
        simulator:setInputNumber(5, simulator:getSlider(3)*(-100))
        simulator:setInputNumber(6, simulator:getSlider(4)*100)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
INB = input.getBool
PRT = property.getText
toggle = false
touch_pulse = false

function onTick()

    value1 = INN(1)*INN(3)
    value2 = INN(2)*INN(4)
    unit1 = PRT("Value 1 unit")
    unit2 = PRT("Value 2 unit")
    min = INN(5)
    max = INN(6)

    touch = INB(1)

    if touch and not touch_pulse then
        toggle = not toggle
    end
    touch_pulse = touch

    if toggle then
        display_value = string.format("%.0f", value2)
        display_unit = unit2
    else
        display_value = string.format("%.0f", value1)
        display_unit = unit1
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --円弧
    screen.setColor(255, 255, 255)
    screen.drawCircle(w/2, h/2, h/2 - 1)
    screen.setColor(0, 0, 0)
    screen.drawRectF(0, (h/2 - 1)*math.sin(math.pi/6) + h/2, w, h)

    --目盛
    num = math.abs(max - min)/5
    i = 0
    while num >= 10 do
        num = num/10
        i = i + 1 
    end
    --目盛幅の計算
    if num < 1.5 then
        scale = 1
    elseif num < 3.5 then
        scale = 2
    elseif num < 7.5 then
        scale = 5
    else
        scale = 10
    end
    scale = scale*10^i

    --目盛描画(プラス)
    scale_line = 0
    screen.setColor(255, 255, 255)
    while scale_line <= max do
        scale_rad = (math.pi*4/3)*(scale_line - min)/(max - min) - 7*math.pi/6
        if scale_line >= min then
            screen.drawLine(w/2 + (h/2 - 2)*math.cos(scale_rad), h/2 + (h/2 - 2)*math.sin(scale_rad), w/2 + (h/2 - 5)*math.cos(scale_rad), h/2 + (h/2 - 5)*math.sin(scale_rad))
        end
        scale_line = scale_line + scale
    end

    --目盛描画(マイナス)
    scale_line = 0
    screen.setColor(255, 255, 255)
    while scale_line >= min do
        scale_rad = (math.pi*4/3)*(scale_line - min)/(max - min) - 7*math.pi/6
        if scale_line >= min then
            screen.drawLine(w/2 + (h/2 - 2)*math.cos(scale_rad), h/2 + (h/2 - 2)*math.sin(scale_rad), w/2 + (h/2 - 5)*math.cos(scale_rad), h/2 + (h/2 - 5)*math.sin(scale_rad))
        end
        scale_line = scale_line - scale
    end

    --文字
    screen.setColor(255, 255, 255)
    screen.drawText(w/2 - #display_value*2.5 , (h/2 - 1)*math.sin(math.pi/6) + h/2 - 4, display_value)
    screen.setColor(255, 255, 255)
    screen.drawText(w/2 - #display_unit*2.5 + 1, h - 6, display_unit)

    --針
    --角度計算
    rad = (math.pi*4/3)*(display_value - min)/(max - min) - 7*math.pi/6
    screen.setColor(0, 255, 0)
    screen.drawLine(w/2, h/2, w/2 + (h/2 - 1)*math.cos(rad), h/2 + (h/2 - 1)*math.sin(rad))
    screen.drawTriangleF(w/2 + (h/2 - 1)*math.cos(rad), h/2 + (h/2 - 1)*math.sin(rad), w/2 + 2*math.cos(rad + math.pi*2/3), h/2 + 2*math.sin(rad + math.pi*2/3), w/2 + 2*math.cos(rad + math.pi*4/3), h/2 + 2*math.sin(rad + math.pi*4/3))
end



