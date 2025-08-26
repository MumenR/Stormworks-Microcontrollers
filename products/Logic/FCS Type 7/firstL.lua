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

tgt_raw = {}
tgt_filted = {}

max_t = 1
t = 0

function atan2(x, y)
    if x >= 0 then
        ans = math.atan(y/x)
    elseif y >= 0 then
        ans = math.atan(y/x) + math.pi
    else
        ans = math.atan(y/x) - math.pi
    end
    return ans
end

--最小値と最大値でフィルタリング
function maxMin(table)
    --最小値と最大値を探索
    local max, min = table[1], table[1]
    for i = 2, #table do
        if table[i] > max then
            max = table[i]
        elseif table[i] < min then
            min = table[i]
        end
    end
    return (max + min)/2
end

--直交座標から極座標へ変換
function rect2Polar(x, y, z, radian_bool)
    local distance, yaw, pitch
    distance = math.sqrt(x^2 + y^2 + z^2)
    yaw = atan2(y, x)
    pitch = math.asin(z/distance)
    if radian_bool then
        return distance, yaw, pitch
    else
        return distance, yaw/(math.pi*2), pitch/(math.pi*2)
    end
end

--極座標から直交座標へ変換(Z軸優先)
function polar2Rect(distance, yaw, pitch, radian_bool)
    local x, y, z
    if not radian_bool then
        pitch = pitch*math.pi*2
        yaw = yaw*math.pi*2
    end
    x = distance*math.cos(pitch)*math.sin(yaw)
    y = distance*math.cos(pitch)*math.cos(yaw)
    z = distance*math.sin(pitch)
    return x, y, z
end

--ヨーとピッチを交代(左に傾いている場合)
function swapYawPitchL(distance, yaw, pitch)
    local Lx, Ly, Lz
    Lz, Ly, Lx = polar2Rect(distance, yaw, pitch, false)
    return rect2Polar(-Lx, Ly, Lz, false)
end

function onTick()
    --データ取り込み
    --tgt_raw[時間][チャンネル][極座標]
    polar_table = {}
    for i = 1, 8 do
        if INB(i) then
            table.insert(polar_table, {INN(i*4 - 3), INN(i*4 - 2), INN(i*4 - 1), INN(i*4)})
            if INN(i*4) + 1 > max_t then
                max_t = INN(i*4) + 1
            end
        end
    end
    
    --データ追加と削除
    if #polar_table > 0 then
        if polar_table[1][4] == 0 then
            tgt_raw = {}
        end
        table.insert(tgt_raw, polar_table)
    else
        tgt_raw = {}
    end

    --フィルタリング
    --tgt_filted[チャンネル][極座標]
    if #tgt_raw == max_t then
        tgt_filted = {}
        --チャンネル
        for i = 1, #tgt_raw[1] do
            --座標要素
            local tmp2 = {}
            for j = 1, 3 do
                --時間
                local tmp1 = {}
                for k = 1, #tgt_raw do
                    table.insert(tmp1, tgt_raw[k][i][j])
                end
                table.insert(tmp2, maxMin(tmp1))
            end
            table.insert(tgt_filted, tmp2)
        end
        t = 1
    end

    --出力なし用の値
    for i = 1, 24 do
        OUN(i, 0)
        OUB(i, false)
    end

    --出力      
    if t <= max_t then

        for i = 1, #tgt_filted do
            local distance, yaw, pitch = swapYawPitchL(tgt_filted[i][1], tgt_filted[i][2], tgt_filted[i][3])
            OUB(i, true)
            OUN(3*i - 2, distance)
            OUN(3*i - 2, yaw)
            OUN(3*i - 0, pitch)
        end

        --デバッグ用
        OUN(32, t)
        t = t + 1
    else
        tgt_filted = {}
    end
end