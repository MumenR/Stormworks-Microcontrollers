-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
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
        simulator:setInputBool(30, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))
        simulator:setInputBool(3, simulator:getIsToggled(3))
        simulator:setInputBool(32, simulator:getIsToggled(4))
        simulator:setInputBool(31, simulator:getIsToggled(5))
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

function onTick()
    distance = INN(32)
    laser = INB(3)
    nightvision = INB(2)
    stabilizer = INB(32)
    tracker = INB(31)
    upper_bottun = INB(30)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    if upper_bottun then
        upper_offset_bottun = -h + 7
        upper_offset_distance = 7
    else
        upper_offset_bottun, upper_offset_distance = 0, 0
    end

    --中心線
    screen.setColor(64, 64, 64, 128)
    local line_margin = math.floor(h/20)
    screen.drawLine(0, h/2, w/2 - line_margin, h/2)
    screen.drawLine(w/2 + line_margin + 1, h/2, w, h/2)
    screen.drawLine(w/2, 0, w/2, h/2 - line_margin)
    screen.drawLine(w/2, h/2 + line_margin + 1, w/2, h)

    --距離計
    if laser then
        distance_char = string.format("D:%dm", math.floor(distance))
        distance_char_lengh = math.floor(2.5*#distance_char)
        screen.setColor(0, 0, 0, 200)
        screen.drawRectF(w/2 - distance_char_lengh - 1, upper_offset_distance, 2*distance_char_lengh + 1, 7)
        screen.setColor(0, 200, 0)
        screen.drawText(w/2 - distance_char_lengh, 1 + upper_offset_distance, distance_char)
    end

    --ボタン下地
    screen.setColor(32, 32, 32)
    screen.drawRectF(w/2 - 18, h - 7 + upper_offset_bottun, 37, 7)
    
    --ボタン四角
    screen.setColor(128, 128, 128)
    for i = 0, 3 do
        screen.drawRectF(w/2 - 17 + i*9 , h - 6 + upper_offset_bottun, 8, 5)
        screen.drawRectF(w/2 - 16 + i*9 , h - 7 + upper_offset_bottun, 6, 7)
    end

    --ボタンオンの場合
    screen.setColor(0, 200, 0)
    if nightvision then
        screen.drawRectF(w/2 - 17, h - 6 + upper_offset_bottun, 8, 5)
        screen.drawRectF(w/2 - 16, h - 7 + upper_offset_bottun, 6, 7)
    end
    if laser then
        screen.drawRectF(w/2 - 8, h - 6 + upper_offset_bottun, 8, 5)
        screen.drawRectF(w/2 - 7, h - 7 + upper_offset_bottun, 6, 7)
    end
    if stabilizer then
        screen.drawRectF(w/2 + 1, h - 6 + upper_offset_bottun, 8, 5)
        screen.drawRectF(w/2 + 2, h - 7 + upper_offset_bottun, 6, 7)
    end
    if tracker then
        screen.drawRectF(w/2 + 10 , h - 6 + upper_offset_bottun, 8, 5)
        screen.drawRectF(w/2 + 11 , h - 7 + upper_offset_bottun, 6, 7)
    end

    --ボタン文字
    list = {"N", "L", "S", "T"}
    screen.setColor(255, 255, 255)
    for i = 0, 3 do
        screen.drawText(w/2 - 15 + 9*i, h - 6 + upper_offset_bottun ,list[i + 1])
    end
end