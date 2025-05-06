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

data_pos = {}
data = {}
max_speed = 300

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--極座標から直交座標へ変換(Z軸優先)
function Polar2Rect(pitch, yaw, distance, radian_bool)
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

--三次元距離
function distance3(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

--x(t) = at + bを最小二乗法で求める
--ft = {{t = tick, x = X}, ...}
function least_squares_method(ft)
    local a, b, sum_t, sum_x, sum_tx, sum_t2 = 0, 0, 0, 0, 0, 0
    if #ft < 2 then
        a = 0
        b = ft[#ft].x
    else
        for _, FT in pairs(ft) do
            sum_t = sum_t + FT.t
            sum_x = sum_x + FT.x
            sum_tx = sum_tx + FT.t*FT.x
            sum_t2 = sum_t2 + FT.t^2
        end
        a = (#ft*sum_tx - sum_t*sum_x)/(#ft*sum_t2 - sum_t^2)
        b = (sum_t2*sum_x - sum_tx*sum_t)/(#ft*sum_t2 - sum_t^2)
    end
    return a, b
end

--ID生成
function nextID()
    local ID, same = 1, true
    while same do
        same = false
        for i = 1, #data do
            same = ID == data[i].id
            if same then
                ID = ID + 1
                break
            end
        end
    end
    return ID
end

function onTick()
    t_max = PRN("data lost tick")
    min_dist = PRN("Vehicle radius [m]")

    lock_on_ID = INN(31)
    select_ID = INN(32)

    --フィジックス情報取り込み
    --遅延生成
    table.insert(data_pos, {INN(25), INN(26), INN(27), INN(28), INN(29), INN(30)})
    while #data_pos > 6  do
        table.remove(data_pos, 1)
    end
    Px = data_pos[1][1]
    Py = data_pos[1][2]
    Pz = data_pos[1][3]
    Ex = data_pos[1][4]
    Ey = data_pos[1][5]
    Ez = data_pos[1][6]

    --[[
        data = {
            [ID] = {
                position = {
                    {x = world X, y = world Y, z = world Z, t = tick},
                    ...
                },
                trend = {
                    x = {a = least ax, b = least bx, est = estimation},
                    y = {a = least ax, b = least bx, est = estimation},
                    z = {a = least ax, b = least bx, est = estimation}
                },
                id = data ID,
                t_last = last tick
            },
            ...
        }
    ]]
    --時間経過とデータ削除
    for ID, DATA in pairs(data) do
        --時間経過
        for _, POS in pairs(DATA.position) do
            POS.t = POS.t - 1
        end
        DATA.t_last = DATA.position[#DATA.position].t
    
        --データ削除
        if -DATA.t_last > t_max then
            data[ID] = nil
        else
            local i = 1
            while i <= #DATA.position do
                if -DATA.position[i].t > t_max then
                    table.remove(DATA.position, i)
                else
                    i = i + 1
                end
            end
        end
    end

    --データ取り込み
    --[[
        data_new[i] = {
            x = World X
            y = World Y
            z = World Z
            d = distance
        }
    ]]
    data_new = {}
    for i = 1, 8 do
        local yaw, pitch, dist, Lx, Ly, Lz, Wx, Wy, Wz
        yaw = INN(i*3 - 2)
        pitch = INN(i*3 - 1)
        dist = INN(i*3)

        if INB(i) and dist >= min_dist then
            --座標変換
            Lx, Ly, Lz = Polar2Rect(pitch, yaw, dist, false)
            Wx, Wy, Wz = Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)

            --追加
            table.insert(data_new, {x = Wx, y = Wy, z = Wz, d = dist})
        end
    end

    --同時検出時にデータ統合
    --距離判定の基準を探索
    --[[
        data_new[i] = {
            x = World X
            y = World Y
            z = World Z
            t = 0
        }
    ]]
    for i = 1, #data_new do
        local A, B, same_data, error_range, sum_x, sum_y, sum_z, j
        A = data_new[i]
        if A == nil then
            break
        end
        error_range = 0.05*A.d
        same_data = {A}
        --距離を判定される側の探索
        j = i + 1
        while j <= #data_new do
            B = data_new[j]
            --規定値以下なら仮テーブルに追加し、元テーブルから削除
            if distance3(A.x, A.y, A.z, B.x, B.y, B.z) < error_range then
                table.insert(same_data, B)
                table.remove(data_new, j)
            else
                j = j + 1
            end
        end
        --仮テーブルから平均値を計算して値を更新
        --ついでにd→tへと定義を変更
        sum_x, sum_y, sum_z = 0, 0, 0
        for _, C in pairs(same_data) do
            sum_x = sum_x + C.x
            sum_y = sum_y + C.y
            sum_z = sum_z + C.z
        end
        data_new[i] = {
            x = sum_x/#same_data,
            y = sum_y/#same_data,
            z = sum_z/#same_data,
            t = 0
        }
    end


    --目標同定
    --data[座標, ID, 時間]
    max_movement = 100
    for i = 1, #data do
        local x1, y1, z1, x2, y2, z2
        x1 = data[i][1]
        y1 = data[i][2]
        z1 = data[i][3]
        for j = 1, #data_world do
            x2 = data_world[j][1]
            y2 = data_world[j][2]
            z2 = data_world[j][3]
            distance = distance3(x1, y1, z1, x2, y2, z2)
            if distance < max_movement then
                data[i] = {x2, y2, z2, data[i][4], 0}
                table.remove(data_world, j)
                break
            end
        end
    end


    --目標同定
    for i = 1, #data_new do
        for ID, DATA in pairs(data) do
            
        end
    end


    --新規目標登録
    for _, NEW in pairs(data_new) do
        local ID = nextID()
        data[ID] = {
            position = {NEW},
            trend = {x = {}, y = {}, z = {}},
            id = ID,
            t_last = 0
        }
    end

    --位置推定
    

    --初期出力
    for i = 1, 24 do
        OUN(i, 0)
    end

    --出力
    i = 0
    for j = 1, #data do
        if data[j][5] == 0 then
            if i < 6 then
                for k = 1, 4 do
                    local value = data[j][k]
                    if k == 4 then
                        if data[j][k] == select_ID and select_ID ~= 0 then
                            value = value + 10000
                        end
                        if data[j][k] == lock_on_ID and lock_on_ID ~= 0 then
                            value = value + 100000
                        end
                    end
                    OUN(4*i + k, value)
                end
                i = i + 1
            else
                data[j][5] = -1
            end
        end
    end

    --デバッグ
    OUN(30, #data)
end