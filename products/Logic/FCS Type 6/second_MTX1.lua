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

position_delay_buffer = {}
target_data = {}
lock_on_list = {}
is_locked_on = false
press_tick = 0
lock_on_ID = 0
next_MTX_ID = 1
IFFData = {}

SHORT_PRESS_MAX_TICKS = 15
IFF_LOST_TICK = 600
SAME_VEHICLE_RADIUS = 50

MAX_TARGET_SPEED = 300/60
MAX_TARGET_ACCEL = 300/(60*60)

PRECISION = 0.1     --valueの最小保証精度
NBITS = 24          --valueに割り当てるビット数
function encode(id, value)
	value = math.floor(value / PRECISION + 0.5)
	if value < 0 then
		value = (value + (1 << NBITS)) & ((1 << NBITS) - 1)
	end
	value = value | id << NBITS
	id = (id >> (24 - NBITS)) + 66
	if id >= 127 then
		id = id + 67
	end
	local x = ('f'):unpack(('I3B'):pack(value & 16777215, id & 255))
	return x
end

function decode(x)
	local value, id = ('I3B'):unpack(('f'):pack(x))
	if id >> 7 & 1 ~= 0 then
		id = id - 67
	end
	id = (id - 66) << (24 - NBITS) | (value >> NBITS)
	value = value & ((1 << NBITS) - 1)
	if value >> (NBITS - 1) & 1 ~= 0 then
		value = value - (1 << NBITS)
	end
	return id, value * PRECISION
end

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
    local maxminT = ft[1].t and (ft[#ft].t - ft[1].t)
    if #ft < 2 or maxminT < 30 then
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
    return a or 0, b or 0
end

--ID生成
function nextID()
    local ID, same = 1, true
    while same do
        same = false
        for _, DATA in pairs(target_data) do
            same = DATA.ID == ID
            if same then
                ID = ID + 1
                break
            end
        end
    end
    return ID
end

spawnTick = 0
function onTick()
    VEHICLE_RADIUS = PRN("Vehicle radius [m]")                          --自ビークルの半径。これ以下の場合補足されない。
    TARGET_DELAY = PRN("Delay [tick]")                                  --ノードなどによる遅延の補正に用いる時間
    MAX_TARGET_OUTPUT_TICK = PRN("Max target output time [sec]")*60     --ロックオンしたターゲットの最大出力時間
    DETECTION_INTERVAL = PRN("Detection interval [tick]")               --探知間隔
    FCS_MODE_ENABLE = PRB("Mode")

    if FCS_MODE_ENABLE then
        select_ID = INN(31)
    else
        select_ID = 0
    end

    is_press = INN(32) == 1

    --フィジックス情報取り込み
    --遅延生成
    table.insert(position_delay_buffer, {INN(25), INN(26), INN(27), INN(28), INN(29), INN(30)})
    while #position_delay_buffer > 6  do
        table.remove(position_delay_buffer, 1)
    end
    Px = position_delay_buffer[1][1]
    Py = position_delay_buffer[1][2]
    Pz = position_delay_buffer[1][3]
    Ex = position_delay_buffer[1][4]
    Ey = position_delay_buffer[1][5]
    Ez = position_delay_buffer[1][6]

    --[[
        target_data = {
            [ID] = {
                position = {
                    {x = world X, y = world Y, z = world Z, t = tick},
                    tは0が最新、過去データほど負に
                    ...
                },
                predict = {
                    x = {a = least ax, b = least bx, est = estimation},
                    y = {a = least ax, b = least bx, est = estimation},
                    z = {a = least ax, b = least bx, est = estimation},
                },
                IFF = {x = x, y = y, z = z, t = t_last},
                IFFExist = IFFに登録されているかどうか,
                ID = target ID,
                t_last = -last tick, 最後に更新してから経過した時間
                t_out = output tick,
            },
            ...
        }
    ]]
    --データベースの時間経過とデータ削除
    for ID, DATA in pairs(target_data) do
        --時間経過とIFFリセット
        DATA.t_out = DATA.t_out + 1
        if #DATA.position ~= 0 then
            for _, POS in pairs(DATA.position) do
                POS.t = POS.t - 1
            end
            DATA.t_last = -DATA.position[#DATA.position].t

            --最大サンプル保持時間算出
            local distance = distance3(Px, Pz, Py, DATA.position[#DATA.position].x, DATA.position[#DATA.position].y, DATA.position[#DATA.position].z)
            local t_max = clamp(120*distance/1000 + 10, 2.5*DETECTION_INTERVAL, math.huge)
            
            --データ削除
            if (DATA.t_last > t_max or DATA.t_last > DETECTION_INTERVAL*3) and not DATA.IFFExist then
                target_data[ID] = nil
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
        elseif not DATA.IFFExist then
            target_data[ID] = nil
        end
    end
    --MXT出力について時間経過と削除
    for index, TGT in pairs(lock_on_list) do
        TGT.t_out = TGT.t_out + 1
        TGT.t = TGT.t + 1
        if TGT.t > MAX_TARGET_OUTPUT_TICK or target_data[TGT.ID] == nil then
            lock_on_list[index] = nil
        end
    end
    --IFF情報について時間経過と削除
    for IFFID, IFF in pairs(IFFData) do
        --時間経過
        IFF.t = IFF.t + 1
        if IFF.t > IFF_LOST_TICK then
            IFFData[IFFID] = nil
        end
    end

    --IFF情報取り込み
    local xID, yID, zID, x, y, z, inIFFID
    xID, x = decode(INN(22))
    yID, y = decode(INN(23))
    zID, z = decode(INN(24))
    inIFFID = xID*100 + yID*10 + zID
    --IFF情報登録
    if inIFFID ~= 0 and spawnTick > 3 then
        IFFData[inIFFID] = {
            x = x,
            y = y,
            z = z,
            t = 0
        }
    end
    if spawnTick < 4 then
        spawnTick = spawnTick + 1
    end

    --データベースIFFリセット
    for _, DATA in pairs(target_data) do
        DATA.IFFExist = false
    end

    --データベースへIFF情報反映
    for IFFID, IFF in pairs(IFFData) do
        local IFFExist = true

        --最小距離の目標を探索
        local minDist, minID = math.huge, 0
        for ID, DATA in pairs(target_data) do
            if DATA.predict ~= nil and not DATA.IFFExist then
                local x1, y1, z1, dist
                x1 = DATA.predict.x.a + DATA.predict.x.b
                y1 = DATA.predict.y.a + DATA.predict.y.b
                z1 = DATA.predict.z.a + DATA.predict.z.b
                dist = distance3(x1, y1, z1, IFF.x, IFF.y, IFF.z)
                if dist < minDist then
                    minDist = dist
                    minID = ID
                end
            end
        end

        if minID ~= 0 then
            --許容誤差として最大移動ユークリッド距離を設定
            local error = MAX_TARGET_ACCEL*(DETECTION_INTERVAL^2)/2 + MAX_TARGET_SPEED*DETECTION_INTERVAL + 0.02*distance3(0, 0, 0, IFF.x, IFF.y, IFF.z) + SAME_VEHICLE_RADIUS

            --データ追加
            if minDist < error then
                IFFExist = false
                if target_data[IFFID] ~= nil then        --使いたいIDが既に占有されている場合
                    target_data[IFFID], target_data[minID] = target_data[minID], target_data[IFFID]
                    target_data[IFFID].ID, target_data[minID].ID = target_data[minID].ID, target_data[IFFID].ID
                else                                     --使いたいIDが空いている場合
                    target_data[IFFID], target_data[minID] = target_data[minID], nil
                end
                target_data[IFFID].IFF = IFF
                target_data[IFFID].IFFExist = true
            end
        end

        --新規登録
        if IFFExist then
            if target_data[IFFID] ~= nil then        --使いたいIDが既に占有されている場合移動させる
                local newID = nextID()
                target_data[IFFID].ID = newID
                target_data[newID], target_data[IFFID] = target_data[IFFID], nil
            end
            target_data[IFFID] = {
                position = {},
                predict = {x = {a = 0, b = IFF.x}, y = {a = 0, b = IFF.y}, z = {a = 0, b = IFF.z}},
                ID = IFFID,
                t_last = 0,
                t_out = math.huge,
                IFF = IFF,
                IFFExist = true
            }
        end
    end

    --[[
        new_target = {
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
    new_target = {}
    for i = 1, 7 do
        local yaw, pitch, dist, Lx, Ly, Lz, Wx, Wy, Wz
        dist = INN(i*3 - 2)
        yaw = INN(i*3 - 1)
        pitch = INN(i*3 - 0)
        
        if INB(i) and dist >= VEHICLE_RADIUS then
            --座標変換
            Lx, Ly, Lz = Polar2Rect(pitch, yaw, dist, false)
            Wx, Wy, Wz = Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)

            --追加
            table.insert(new_target, {x = Wx, y = Wy, z = Wz, d = dist, t = 0})
        end
    end

    --同時検出時にデータ統合
    for i = 1, #new_target do
        local A, B, same_data, error_range, sum_x, sum_y, sum_z, j
        A = new_target[i]
        if A == nil then
            break
        end
        error_range = 0.02*A.d + VEHICLE_RADIUS
        same_data = {A}
        --距離を判定される側の探索
        j = i + 1
        while j <= #new_target do
            B = new_target[j]
            --規定値以下なら仮テーブルに追加し、元テーブルから削除
            if distance3(A.x, A.y, A.z, B.x, B.y, B.z) < error_range then
                table.insert(same_data, B)
                table.remove(new_target, j)
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
        new_target[i] = {
            x = sum_x/#same_data,
            y = sum_y/#same_data,
            z = sum_z/#same_data,
            d = distance3(Px, Pz, Py, sum_x/#same_data, sum_y/#same_data, sum_z/#same_data),
            t = 0
        }
    end

    --目標同定
    for _, DATA in pairs(target_data) do
        local error, min_dist, min_i, x1, y1, z1, distance
        if #new_target == 0 then
            break
        end
        --最小距離データを探索
        min_dist = math.huge
        min_i = 0
        if #DATA.position == 0 then
            x1 = DATA.IFF.x
            y1 = DATA.IFF.y
            z1 = DATA.IFF.z
        else
            x1 = DATA.predict.x.a + DATA.predict.x.b
            y1 = DATA.predict.y.a + DATA.predict.y.b
            z1 = DATA.predict.z.a + DATA.predict.z.b
        end

        for i, NEW in pairs(new_target) do
            distance = distance3(x1, y1, z1, NEW.x, NEW.y, NEW.z)
            if distance < min_dist then
                min_dist = distance
                min_i = i
            end
        end

        --許容誤差として最大移動ユークリッド距離を設定
        if #DATA.position <= 1 then
            error = MAX_TARGET_SPEED*DATA.t_last
        else
            error = MAX_TARGET_ACCEL*(DATA.t_last^2)/2
        end
        error = error + 0.02*new_target[min_i].d + SAME_VEHICLE_RADIUS
        --データ追加
        if min_dist < error then
            new_target[min_i].d = nil
            DATA.t_out = math.huge
            table.insert(DATA.position, new_target[min_i])
            table.remove(new_target, min_i)
        end
    end

    --新規目標登録
    for _, NEW in pairs(new_target) do
        local ID = nextID()
        NEW.d = nil
        target_data[ID] = {
            position = {NEW},
            predict = {x = {}, y = {}, z = {}},
            ID = ID,
            t_last = 0,
            t_out = math.huge,
            IFF = {},
            IFFExist = false
        }
    end

    --位置推定
    for ID, DATA in pairs(target_data) do
        if #DATA.position ~= 0 then
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
            target_data[ID].predict = {
                x = {a = ax, b = bx, est = ax*TARGET_DELAY + bx},
                y = {a = ay, b = by, est = ay*TARGET_DELAY + by},
                z = {a = az, b = bz, est = az*TARGET_DELAY + bz}
            }
        else
            target_data[ID].predict = {
                x = {a = 0, b = DATA.IFF.x, est = DATA.IFF.x},
                y = {a = 0, b = DATA.IFF.y, est = DATA.IFF.y},
                z = {a = 0, b = DATA.IFF.z, est = DATA.IFF.z}
            }
        end
    end

    --短押し/長押し判定
    if is_press then
        press_tick = press_tick + 1
    end
    is_short_press = press_tick < SHORT_PRESS_MAX_TICKS and press_tick > 0 and not is_press
    is_long_press = press_tick >= SHORT_PRESS_MAX_TICKS and press_tick > 0 and not is_press
    if not is_press then
        press_tick = 0
    end

    --ロックオン切り替え
    if is_short_press and #target_data ~= 0 then
        is_locked_on = lock_on_ID ~= select_ID
    elseif #target_data == 0 or (target_data[lock_on_ID] == nil and lock_on_ID ~= 0) then
        is_locked_on = false
    end

    --ロックオンID更新
    if select_ID ~= 0 and is_locked_on and is_short_press and target_data[select_ID] and not target_data[select_ID].IFFExist then
        lock_on_ID = select_ID
    elseif not is_locked_on or (target_data[lock_on_ID] and target_data[lock_on_ID].IFFExist) then
        lock_on_ID = 0
        is_locked_on = false
    end

    --継続出力リストに追加
    --[[
        lock_on_list = {
            [index] = {
                ID = target data ID,
                MTX_ID = MTX ID,
                t = tick,
                t_out = output tick
            }
        }
    ]]
    if is_long_press and is_locked_on then
        local temp_lock_on_ID = {
            ID = lock_on_ID,
            MTX_ID = next_MTX_ID,
            t = 0,
            t_out = math.huge
        }
        table.insert(lock_on_list, temp_lock_on_ID)
        next_MTX_ID = next_MTX_ID + 1
    end

    --初期出力
    for i = 1, 32 do
        OUN(i, 0)
    end

    --t_out が大きい順に
    lock_on_list_sort = {}
    for index, data in pairs(lock_on_list) do
        table.insert(lock_on_list_sort, data)
        lock_on_list_sort[#lock_on_list_sort].index = index
    end
    table.sort(lock_on_list_sort, function(a, b) return a.t_out > b.t_out end)

    --最も最後に出力した値から出力
    for i = 1, 4 do
        if lock_on_list_sort[i] ~= nil then
            data_ID = lock_on_list_sort[i].ID
            OUN(i*7 - 6, target_data[data_ID].predict.x.est)
            OUN(i*7 - 5, target_data[data_ID].predict.y.est)
            OUN(i*7 - 4, target_data[data_ID].predict.z.est)
            OUN(i*7 - 3, target_data[data_ID].predict.x.a)
            OUN(i*7 - 2, target_data[data_ID].predict.y.a)
            OUN(i*7 - 1, target_data[data_ID].predict.z.a)
            OUN(i*7 - 0, lock_on_list_sort[i].MTX_ID)

            lock_on_list[lock_on_list_sort[i].index].t_out = 0
        end
    end

    --デバッグ
    OUN(32, #lock_on_list)
    OUN(31, #target_data)
end