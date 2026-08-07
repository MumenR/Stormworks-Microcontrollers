
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
max_velocity = 300 --m/s
max_accel = 300 --m/s*s

max_velocity = max_velocity/60
max_accel = max_accel/3600

min_dist = 50

lock_on = false

target_x, target_y, target_z = 0, 0, 0

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
end

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
        for _, DATA in pairs(data) do
            same = DATA.id == ID
            if same then
                ID = ID + 1
                break
            end
        end
    end
    return ID
end

function onTick()
    radar_on = INB(9)
    fcs_detected = INB(10)
    manual_mode = INB(11)

    --初期出力
    for i = 1, 7 do
        OUN(i, 0)
    end

    if radar_on then
        --フィジックス情報取り込み
        Px, Py, Pz = INN(27), INN(28), INN(29)
        Ex, Ey, Ez = INN(30), INN(31), INN(32)

        delay = INN(26)

        if manual_mode then
            target_x = INN(16)
            target_y = INN(20)
            target_z = INN(24)
        elseif fcs_detected then
            target_x = INN(4)
            target_y = INN(8)
            target_z = INN(12)
        end

        --[[
            data = {
                [ID] = {
                    position = {
                        {x = world X, y = world Y, z = world Z, t = tick},
                        ...
                    },
                    predict = {
                        x = {a = least ax, b = least bx, est = estimation},
                        y = {a = least ax, b = least bx, est = estimation},
                        z = {a = least ax, b = least bx, est = estimation},
                    },
                    id = data ID,
                    t_last = -last tick
                    t_out = output tick
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
            DATA.t_last = -DATA.position[#DATA.position].t
            DATA.t_out = DATA.t_out + 1

            --最大サンプル保持時間算出
            local distance = distance3(Px, Pz, Py, DATA.position[#DATA.position].x, DATA.position[#DATA.position].y, DATA.position[#DATA.position].z)
            t_max = clamp(150*distance/2000 + 10, 10, 300)
        
            --データ削除
            if DATA.t_last > t_max then
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

        --[[
            data_new = {
                [i] = {
                    x = World X
                    y = World Y
                    z = World Z
                    d = distance
                    t = 0
                }
            }
        ]]
        --データ取り込み
        data_new = {}
        for i = 1, 6 do
            local yaw, pitch, dist, Lx, Ly, Lz, Wx, Wy, Wz
            dist = INN(i*4 - 3)
            yaw = INN(i*4 - 2)
            pitch = INN(i*4 - 1)
            
            if INB(i) then
                --座標変換
                Lx, Ly, Lz = Polar2Rect(pitch, yaw, dist, false)
                Wx, Wy, Wz = Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)

                --追加
                table.insert(data_new, {x = Wx, y = Wy, z = Wz, d = dist, t = 0})
            end
        end

        --同時検出時にデータ統合
        for i = 1, #data_new do
            local A, B, same_data, error_range, sum_x, sum_y, sum_z, j
            A = data_new[i]
            if A == nil then
                break
            end
            error_range = 0.02*A.d + min_dist
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
                d = distance3(Px, Pz, Py, sum_x/#same_data, sum_y/#same_data, sum_z/#same_data),
                t = 0
            }
        end

        --目標同定
        for _, DATA in pairs(data) do
            local error, min_dist, min_i, x1, y1, z1, distance
            if #data_new == 0 then
                break
            end
            --最小距離データを探索
            min_dist = math.huge
            min_i = 0
            x1 = DATA.predict.x.a + DATA.predict.x.b
            y1 = DATA.predict.y.a + DATA.predict.y.b
            z1 = DATA.predict.z.a + DATA.predict.z.b
            for i, NEW in pairs(data_new) do
                distance = distance3(x1, y1, z1, NEW.x, NEW.y, NEW.z)
                if distance < min_dist then
                    min_dist = distance
                    min_i = i
                end
            end

            --許容誤差として最大移動ユークリッド距離を設定
            if #DATA.position <= 1 then
                error = max_velocity*DATA.t_last
            else
                error = max_accel*(DATA.t_last^2)/2
            end
            error = error + 0.02*data_new[min_i].d
            --データ追加
            if min_dist < error then
                data_new[min_i].d = nil
                DATA.t_out = math.huge
                table.insert(DATA.position, data_new[min_i])
                table.remove(data_new, min_i)
            end
        end

        --新規目標登録
        for _, NEW in pairs(data_new) do
            local ID = nextID()
            NEW.d = nil
            data[ID] = {
                position = {NEW},
                predict = {x = {}, y = {}, z = {}},
                id = ID,
                t_last = 0,
                t_out = math.huge
            }
        end

        --位置推定
        for _, DATA in pairs(data) do
            local table_x, table_y, table_z, ax, bx, ay, by, az, bz
            --テーブル作成
            table_x, table_y, table_z = {}, {}, {}
            for i = 1, #DATA.position do
                table.insert(table_x, {t = DATA.position[i].t, x = DATA.position[i].x})
                table.insert(table_y, {t = DATA.position[i].t, x = DATA.position[i].y})
                table.insert(table_z, {t = DATA.position[i].t, x = DATA.position[i].z})
            end
            --最小二乗法近似
            ax, bx = least_squares_method(table_x)
            ay, by = least_squares_method(table_y)
            az, bz = least_squares_method(table_z)
            DATA.predict = {
                x = {a = ax, b = bx, est = ax*delay + bx},
                y = {a = ay, b = by, est = ay*delay + by},
                z = {a = az, b = bz, est = az*delay + bz}
            }
        end

        --事前情報と最も近い標的を探索
        min_distance, min_ID = 500, 0
        for ID, DATA in pairs(data) do
            local distance = distance3(target_x, target_y, target_z, DATA.predict.x.est, DATA.predict.y.est, DATA.predict.z.est)
            if distance < min_distance then
                min_distance = distance
                min_ID = ID
            end
        end

        --出力
        if min_ID ~= 0 then
            OUN(1, data[min_ID].predict.x.est)
            OUN(2, data[min_ID].predict.y.est)
            OUN(3, data[min_ID].predict.z.est)
            OUN(4, data[min_ID].predict.x.a)
            OUN(5, data[min_ID].predict.y.a)
            OUN(6, data[min_ID].predict.z.a)
            OUN(7, 1)
        end
    end

    --デバッグ
    OUN(32, #data)
end