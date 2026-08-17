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
    simulator:setProperty("Eye offset xyz", "0,0,0")

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        simulator:setInputNumber(1, 0)
        simulator:setInputNumber(2, 100)
        simulator:setInputNumber(3, 0)
        simulator:setInputNumber(4, 0001*10^3 + 0001)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("required")
require("math.math")
require("math.coordTrans")
require("screen.coordTrans")
require("screen.draw")

data = {}
FOV_H = (58/360)*pi2


--距離
function distance3(a, b)
    local dx, dy, dz = a[1] - b[1], a[2] - b[2], a[3] - b[3]
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

--SRD3マーク描画用関数
function drawSRD3(pixX, pixY, shapeNo, colorNo, addStaticNo, addDynamicNo, t)
    local drawShape, drawAddStatic
    
    drawShape = function(x, y, r, dottedEnable)   --形
        local drawLine = dottedEnable and drawDottedLine or screen.drawLine
        local drawRect = dottedEnable and drawDottedRect or screen.drawRect
        local drawTriangle = dottedEnable and drawDottedTriangle or screen.drawTriangle
        local drawCircle = dottedEnable and drawDottedCircle or screen.drawCircle

        if shapeNo == 0 then        --四角
            drawRect(x - r, y - r, r*2, r*2)
        elseif shapeNo <= 2 then    --菱形
            drawLine(x - r, y, x, y + r)
            drawLine(x, y + r, x + r, y)
            drawLine(x + r, y, x, y - r)
            drawLine(x, y - r, x - r, y)
            if shapeNo == 2 then    --四角+菱形
                r = (r == 3) and (r + 1) or r
                drawRect(x - r, y - r, r*2, r*2)
            end
        elseif shapeNo == 3 then    --三角
            drawTriangle(pixX, pixY - r, pixX + r/2*3^0.5, pixY + r/2, pixX - r/2*3^0.5, pixY + r/2)
        elseif shapeNo == 4 then    --円
            drawCircle(pixX, pixY, r)
        elseif shapeNo == 5 then    --四角の端だけ
            if r == 3 then
                drawLine(x - r, y - r, x - r, y - r + 1)
                drawLine(x - r, y + r, x - r, y + r + 1)
                drawLine(x + r, y - r, x + r, y - r + 1)
                drawLine(x + r, y + r, x + r, y + r + 1)
            else
                drawLine(x - r, y - r, x - r/2, y - r)
                drawLine(x - r, y - r, x - r, y - r/2)
                drawLine(x - r, y + r, x - r/2, y + r)
                drawLine(x - r, y + r, x - r, y + r/2)
                drawLine(x + r, y - r, x + r/2, y - r)
                drawLine(x + r, y - r, x + r, y - r/2)
                drawLine(x + r, y + r, x + r/2, y + r)
                drawLine(x + r, y + r, x + r, y + r/2)
            end
        elseif shapeNo == 6 then    --菱形の隅だけ
            if r == 3 then
                drawLine(x - r, y, x - r, y + 1)
                drawLine(x, y + r, x, y + r + 1)
                drawLine(x + r, y, x + r, y + 1)
                drawLine(x, y - r, x, y - r + 1)
            else
                drawLine(x - r, y, x - r/2, y + r/2)
                drawLine(x - r, y, x - r/2, y - r/2)
                drawLine(x, y + r, x + r/2, y + r/2)
                drawLine(x, y + r, x - r/2, y + r/2)
                drawLine(x + r, y, x + r/2, y + r/2)
                drawLine(x + r, y, x + r/2, y - r/2)
                drawLine(x, y - r, x + r/2, y - r/2)
                drawLine(x, y - r, x - r/2, y - r/2)
            end
        end
    end

    drawAddStatic = function ()         --静的追加機能
        if addStaticNo == 1 then        --太
            drawShape(pixX, pixY, 3, addStaticNo == 2)
        elseif addStaticNo == 3 then    --中央点
            screen.drawLine(pixX - 1, pixY, pixX + 2, pixY)
            screen.drawLine(pixX, pixY - 1, pixX, pixY + 2)
        elseif addStaticNo == 4 then    --十字
            screen.drawLine(pixX + 4, pixY, pixX - 5, pixY)
            screen.drawLine(pixX, pixY + 4, pixX, pixY - 5)
        elseif addStaticNo == 5 then    --クロス十字
            screen.drawLine(pixX - 4, pixY - 4, pixX + 5, pixY + 5)
            screen.drawLine(pixX + 4, pixY - 4, pixX - 5, pixY + 5)
        elseif addStaticNo == 6 then    --中央空き十字
            screen.drawLine(pixX + 4, pixY, pixX + 1, pixY)
            screen.drawLine(pixX - 4, pixY, pixX - 1, pixY)
            screen.drawLine(pixX, pixY + 4, pixX, pixY + 1)
            screen.drawLine(pixX, pixY - 4, pixX, pixY - 1)
        elseif addStaticNo == 7 then    --中央空きクロス十字
            screen.drawLine(pixX - 4, pixY - 4, pixX - 1, pixY - 1)
            screen.drawLine(pixX + 4, pixY + 4, pixX + 1, pixY + 1)
            screen.drawLine(pixX + 4, pixY - 4, pixX + 1, pixY - 1)
            screen.drawLine(pixX - 4, pixY + 4, pixX - 1, pixY + 1)
        end
    end

    --色設定
    local colorNoData = {
        {0, 255, 0},
        {16, 16, 255},
        {255, 0, 0},
        {255, 255, 0},
        {0, 255, 255},
        {255, 0, 255},
        {0, 255, 0},
        {0, 255, 0},
        {0, 255, 0},
        {255, 255, 255}
    }
    if colorNoData[colorNo + 1] then
        screen.setColor(colorNoData[colorNo + 1][1], colorNoData[colorNo + 1][2], colorNoData[colorNo + 1][3])
    else
        screen.setColor(0, 255, 0)
    end

    --動的追加機能
    if addDynamicNo == 1 then       --点滅(高速)
        if t%12 >= 6 then
            drawShape(pixX, pixY, 4, addStaticNo == 2)
            drawAddStatic()
        end
    elseif addDynamicNo == 2 then   --点滅(低速)
        if t%30 >= 15 then
            drawShape(pixX, pixY, 4, addStaticNo == 2)
            drawAddStatic()
        end
    elseif addDynamicNo == 3 then   --ゲーミング
        screen.setColor(127*math.sin(t/30) + 128, 127*math.cos(t/30) + 128, 127*math.sin(t/15) + 128)
        drawShape(pixX, pixY, 4, addStaticNo == 2)
        drawAddStatic()
    else
        drawShape(pixX, pixY, 4, addStaticNo == 2)
        drawAddStatic()
    end
end

function onTick()
    seatQt = euler2Qt(INN(30), INN(31), INN(32))
    pos = offset("Eye offset xyz", {INN(27), INN(29), INN(28)}, seatQt)
    eyeQt = euler2Qt(-INN(10)*pi2, INN(9)*pi2, 0)

    delete_tick = PRN("Radar delete tick")
    dist_unit = PRN("Distance Units")

    show_radar_id = PRB("radar ID")
    show_radar_dist = PRB("radar distance")

    --時間経過
    for ID, tgt in pairs(data) do
        tgt.t = tgt.t + 1
        tgt.drawTick = tgt.drawTick + 1
        if tgt.drawTick > 60^3*10 then
            tgt.drawTick = 0
        end
    end

    --データ取り込み
    --data[ID]{xyz, t, shapeNo, colorNo, addStaticNo, addDynamicNo, drawTick}
    for i = 0, 5 do
        local j = i > 1 and 2 or 0
        local rawID = INN(i*4 + 4 + j)
        local ID = rawID%1000
        if ID ~= 0 then
            data[ID] = {
                xyz = {INN(i*4 + 1 + j), INN(i*4 + 2 + j), INN(i*4 + 3 + j)},
                t = 0,
                shapeNo = math.floor(rawID/(10^3))%10,
                colorNo = math.floor(rawID/(10^4))%10,
                addStaticNo = math.floor(rawID/(10^5))%10,
                addDynamicNo = math.floor(rawID/(10^6))%10,
                drawTick = (data[ID] and data[ID].drawTick) or 0
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
    local targetCount = 0
    for _ in pairs(data) do
        targetCount = targetCount + 1
    end
    OUN(30, targetCount)
end

function onDraw()
    setParam(FOV_H)

    --レーダー反応描画
    for ID, tgt in pairs(data) do
        local x1, y1, forward1 = localRect2Display(world2Local(tgt.xyz, pos, seatQt), eyeQt)
        x1 = math.floor(x1)
        y1 = math.floor(y1)
        if forward1 then
            drawSRD3(x1, y1, tgt.shapeNo, tgt.colorNo, tgt.addStaticNo, tgt.addDynamicNo, tgt.drawTick)

            --ID
            if show_radar_id then
                local TGTid = tostring(ID)
                screen.drawText(x1 + 1 - 2.5*#TGTid, y1 - 10, TGTid)
            end

            --距離数値
            if show_radar_dist then
                local tgt_dist = distance3(pos, tgt.xyz)*dist_unit
                local TGTd
                if tgt_dist >= 10 then
                    TGTd = string.format("%.0f", math.floor(tgt_dist + 0.5))
                else
                    TGTd = string.format("%.1f", math.floor(tgt_dist*10 + 0.5)/10)
                end
                screen.drawText(x1 + 1 - 2.5*#TGTd, y1 + 6, TGTd)
            end
        end
    end
end
