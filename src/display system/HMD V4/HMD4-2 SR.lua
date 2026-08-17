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
require("math.vector")

data = {}
FOV_H = (58/360)*pi2

function onTick()
    seatQt = euler2Qt(INN(30), INN(31), INN(32))
    pos = offset("Eye offset xyz", INN(27), INN(29), INN(28), seatQt)
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
    --data[ID]{xyz, rawID, t, drawTick}
    for i = 0, 5 do
        local j = i > 1 and 2 or 0
        local rawID = INN(i*4 + 4 + j)
        local ID = rawID%1000
        if ID ~= 0 then
            data[ID] = {
                xyz = {INN(i*4 + 1 + j), INN(i*4 + 2 + j), INN(i*4 + 3 + j)},
                rawID = rawID,
                t = 0,
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
        x1 = (x1 + 0.5)//1
        y1 = (y1 + 0.5)//1
        if forward1 then
            drawSRD3(x1, y1, tgt.rawID, tgt.drawTick)

            --ID
            if show_radar_id then
                local TGTid = tostring(ID)
                screen.drawText(x1 + 1 - 2.5*#TGTid, y1 - 10, TGTid)
            end

            --距離数値
            if show_radar_dist then
                local tgt_dist = vecDist(pos, tgt.xyz)*dist_unit
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
