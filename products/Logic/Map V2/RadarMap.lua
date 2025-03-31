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
PRB = property.getBool

data = {}
SR_map_x, SR_map_y = 0, 0

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
    map_x = INN(25)
    map_y = INN(26)
    zoom = INN(27)
    Px = INN(28)
    Pz = INN(29)

    delete_tick = PRN("Radar delete tick")
    dist_circle = PRB("Distance circle")
    dist_circle_max = math.floor(PRN("Distance circle max range [km]"))
    centerline = PRB("Map centerline")
    dark_mode = PRB("Map dark mode")

    --時間経過
    for ID, tgt in pairs(data) do
        tgt.t = tgt.t + 1
    end

    --データ取り込み
    --data[ID]{x, y, z, t}
    for i = 0, 5 do
        ID = INN(i*4 + 4)
        if ID ~= 0 then
            data[ID] = {
                x = INN(i*4 + 1),
                y = INN(i*4 + 2),
                z = INN(i*4 + 3),
                t = 0
            }
        end
    end

    --一定時間以上で削除
    for ID, tgt in pairs(data) do
        if tgt.t > delete_tick then
            data[ID] = nil
        end
    end

    --デバッグ用
    OUN(30, #data)
    OUN(31, SR_map_x)
    OUN(32, SR_map_y)
end

function onDraw()
    local w, h
    w = screen.getWidth()
    h = screen.getHeight()

    --マップ描画
    if dark_mode then
        screen.setMapColorOcean(12,12,12,255)
        screen.setMapColorShallows(30,30,30,255)
        screen.setMapColorLand(78,78,78,255)
        screen.setMapColorGrass(40,40,40,255)
        screen.setMapColorSand(90,90,90,255)
        screen.setMapColorSnow(200,200,200,255)
    end
    screen.drawMap(map_x, map_y, zoom)

    --等距離円
    if dist_circle then
        screen.setColor(255, 255, 255, 64)
        circle_x, circle_y = map.mapToScreen(map_x, map_y, zoom, w, h, Px, Pz)
        for i = 1, dist_circle_max do
            --半径計算
            r = map.mapToScreen(0, 0, zoom, w, h, i*1000, 0)
            screen.drawCircle(circle_x, circle_y, r - w/2)
        end
    end

    --センターライン
    if centerline then
        screen.setColor(255, 255, 255, 64)
        screen.drawLine(0, h/2, w/2 - 5, h/2)
        screen.drawLine(w, h/2, w/2 + 5, h/2)
        screen.drawLine(w/2, 0, w/2, h/2 - 5)
        screen.drawLine(w/2, h, w/2, h/2 + 5)
    end

    --レーダー反応
    for ID, tgt in pairs(data) do
        --座標変換
        SR_map_x, SR_map_y = map.mapToScreen(map_x, map_y, zoom, w, h, tgt.x, tgt.y)
        SR_map_x = math.floor(SR_map_x)
        SR_map_y = math.floor(SR_map_y)
        --色
        alpha = clamp(510*(delete_tick - tgt.t)/delete_tick, 0, 255)
        if tgt.z > 50 then
            screen.setColor(255, 200, 0, alpha)
        else
            screen.setColor(0, 200, 255, alpha)
        end
        --表示
        screen.drawLine(SR_map_x - 2, SR_map_y, SR_map_x + 3, SR_map_y)
        screen.drawLine(SR_map_x, SR_map_y - 2, SR_map_x, SR_map_y + 3)
        screen.drawText(SR_map_x + 3, SR_map_y - 6, ID)
    end
end
