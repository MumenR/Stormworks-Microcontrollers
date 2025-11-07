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
        simulator:setInputBool(3, simulator:getIsToggled(3))
        simulator:setInputBool(4, simulator:getIsToggled(4))
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
    thltCntTurn = INB(3)
    bowThlt = INB(4)
end

function onDraw()
    w, h = screen.getWidth(), screen.getHeight()

    --図形の描画領域(大きさ)
    x1 = 32
    y1 = 32
    
    --図形の位置
    x2 = 0
    y2 = h - y1

    zero = math.floor((y1 - 5)/2) + y2

    L_lev = math.floor(L_throttle*(y1 - 9)/200)
    R_lev = math.floor(R_throttle*(y1 - 9)/200)

    if L_reverse then
        screen.setColor(255, 0, 0)
        screen.drawRectF(x1/4 - 4 + x2, zero, 9, L_lev + 1)
        screen.setColor(0, 255, 0)
        screen.drawText(x1/4 - 2 + x2, zero + y1/8, "R")
    else
        screen.setColor(0, 255, 0)
        screen.drawRectF(x1/4 - 4 + x2, zero, 9, -L_lev)
    end

    if R_reverse then
        screen.setColor(255, 0, 0)
        screen.drawRectF(x1*3/4 - 4 + x2, zero, 9, R_lev + 1)
        screen.setColor(0, 255, 0)
        screen.drawText(x1*3/4 - 2 + x2, zero + y1/8, "R")
    else
        screen.setColor(0, 255, 0)
        screen.drawRectF(x1*3/4 - 4 + x2, zero, 9, -R_lev)
    end

    --零点棒
    screen.setColor(0, 255, 0)
    screen.drawLine(x1/4 - 5 + x2, zero, x1/4 + 5 + x2, zero)
    screen.drawLine(x1*3/4 - 5 + x2, zero, x1*3/4 + 5 + x2, zero)

    --縦線とデジタル
    screen.setColor(0, 255, 0)

    screen.drawText(x1/4 - #L_throttle*2.5 + x2, y1 - 6 + y2, L_throttle)
    screen.drawText(x1*3/4 - #R_throttle*2.5 + x2, y1 - 6 + y2, R_throttle)
    
    screen.drawLine(x1/4 - 5 + x2, 2 + y2, x1/4 - 5 + x2, y1 - 7 + y2)
    screen.drawLine(x1/4 + 5 + x2, 2 + y2, x1/4 + 5 + x2, y1 - 7 + y2)
    screen.drawLine(x1*3/4 - 5 + x2, 2 + y2, x1*3/4 - 5 + x2, y1 - 7 + y2)
    screen.drawLine(x1*3/4 + 5 + x2, 2 + y2, x1*3/4 + 5 + x2, y1 - 7 + y2)

    --スロットル制御旋回
    if thltCntTurn then
        screen.setColor(0, 255, 0)
        screen.drawRect(x2 + x1 + 1, zero - 10, 17, 8)
        screen.drawText(x2 + x1 + 3, zero - 8, "TCT")
    end

    --バウスラスター
    if bowThlt then
        screen.setColor(0, 255, 0)
        screen.drawRect(x2 + x1 + 1, zero + 2, 17, 8)
        screen.drawText(x2 + x1 + 3, zero + 4, "BOW")
    end
end



