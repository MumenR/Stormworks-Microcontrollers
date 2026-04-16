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
    simulator:setScreen(1, "1x1")
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
PRN = property.getNumber
touchPulse = false
AHR = true
mode = 1 -- 1:STD 2:CRZ 3:TOP 4:SEA

function onTick()
    local w = INN(1)
    local h = INN(2)
    touchX = INN(3)
    touchY = INN(4)
    isTouched = INB(1)

    if isTouched and not touchPulse then
        if  touchY > 8 and touchY < 16 then        --AHRボタン
            AHR = not AHR
        elseif touchY > 16 and touchY < 32 then    --モードセレクター
            if touchX > w/2 then
                if touchY > 24 then
                    mode = 4 -- SEA
                elseif touchY < 24 then
                    mode = 3 -- TOP
                end
            elseif touchX < w/2 then
                if touchY > 24 then
                    mode = 2 -- CRZ
                elseif touchY < 24 then
                    mode = 1 -- STD
                end
            end
        end
    end

    OUN(1, (AHR and 100 or 0) + mode)

    touchPulse = isTouched
end

function onDraw()
    local w, h = screen.getWidth(), screen.getHeight()
    --ライン
    screen.setColor(0, 0, 64)
    for i = 0, 3 do
        screen.drawLine(0, i*8, w, i*8)
    end
    screen.drawLine(w/2, 16, w/2, 32)

    --ボタン背景
    if AHR then
        screen.setColor(64, 64, 0)
        screen.drawRectF(0, 9, w, 7)
    end
    if mode == 1 then
        screen.setColor(64, 64, 0)
        screen.drawRectF(0, 17, w/2, 7)
    elseif mode == 2 then
        screen.setColor(64, 64, 0)
        screen.drawRectF(0, 25, w/2, 7)
    elseif mode == 3 then
        screen.setColor(64, 64, 0)
        screen.drawRectF(w/2 + 1, 17, w/2 - 1, 7)
    elseif mode == 4 then
        screen.setColor(64, 64, 0)
        screen.drawRectF(w/2 + 1, 25, w/2 - 1, 7)
    end

    --タイトル背景
    screen.setColor(48, 48, 128)
    screen.drawRectF(0, 1, w, 7)

    --文字
    screen.setColor(0, 0, 64)
    screen.drawText(w/2 - 10, 2, "SM 3")
    screen.setColor(255, 255, 255)
    screen.drawText(w/2 - 7, 10, "ARH")
    screen.drawText(1, 18, "STD")
    screen.drawText(1, 26, "CRZ")
    screen.drawText(w/2 + 1, 18, "TOP")
    screen.drawText(w/2 + 1, 26, "SEA")
end
