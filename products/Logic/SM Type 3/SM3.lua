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


detonate = false
step1 = false
step2 = false
step3 = false
AR_lock_on = false
terminal_guidance = false

data_pos = {}
data = {}
max_velocity = 300 --m/s
max_accel = 300 --m/s*s

max_velocity = max_velocity/60
max_accel = max_accel/3600

min_dist = 50

lock_on = false

Tx, Ty, Tz, Tvx, Tvy, Tvz = 0, 0, 0, 0, 0, 0
radar_x, radar_y, radar_z, radar_vx, radar_vy, radar_vz = 0, 0, 0, 0, 0, 0
t = 0

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
end

function atan2(x, y)
    local z
    if x >= 0 then
        z = math.atan(y/x)
    elseif y >= 0 then
        z = math.atan(y/x) + math.pi
    else
        z = math.atan(y/x) - math.pi
    end
    return z
end

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--ワールド座標からローカル座標へ変換(physics sensor使用)
function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
	
	local Wx = Wx - Px
	local Wy = Wy - Pz
	local Wz = Wz - Py
	
	local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y
	a = math.cos(Ez)*math.cos(Ey)
	b = math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex)
	c = math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex)
	d = Wx
	e = math.sin(Ez)*math.cos(Ey)
	f = math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex)
	g = math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex)
	h = Wz
	i = -math.sin(Ey)
	j = math.cos(Ey)*math.sin(Ex)
	k = math.cos(Ey)*math.cos(Ex)
	l = Wy
	
	local Lower = ((a*f-b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
	x = 0
	y = 0
	z = 0
	
	if Lower ~= 0 then
		x = ((b*g - c*f)*l + (d*f - b*h)*k + (c*h - d*g)*j)/Lower
		y = -((a*g - c*e)*l + (d*e - a*h)*k + (c*h - d*g)*i)/Lower
		z = ((a*f - b*e)*l + (d*e - a*h)*j + (b*h - d*f)*i)/Lower
	end
	
	return x, z, y
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

--PID制御
ESx, ERx = 0, 0
ESy, ERy = 0, 0
function PID(P, I, D, target, current, error_sum_pre, error_pre, min, max)
    local error, error_diff, controll
    error = target - current
    error_sum = error_sum_pre + error
    error_diff = error - error_pre
    controll = P*error + I*error_sum + D*error_diff

    if controll > max or controll < min then
        error_sum = error_sum_pre
        controll = P*error + I*error_sum + D*error_diff
    end
    return clamp(controll, min, max), error_sum, error
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

--t tick後の未来位置計算
function cal_future_position(x, y, z, vx, vy, vz, t)
    local future_x, future_y, future_z
    future_x = x + vx*t
    future_y = y + vy*t
    future_z = z + vz*t
    return future_x, future_y, future_z
end

--速度の平均
speedlist = {}
function speed_average(v)
    table.insert(speedlist, v)
    if #speedlist > 60 then
        table.remove(speedlist, 1)
    end
    local sum_v = 0
    for i = 1, #speedlist do
        sum_v = sum_v + speedlist[i]
    end
    return sum_v/#speedlist
end

--衝突位置予測
function cal_collision_location(Tx, Ty, Tz, Tvx, Tvy, Tvz, Px, Pz, Py, v, d, delay)
    Tx, Ty, Tz = cal_future_position(Tx, Ty, Tz, Tvx, Tvy, Tvz, delay)
    local Tv, theta, tick, tick_plus, tick_minus, future_x, future_y, future_z
    local vector_x, vector_y, vector_z = Px - Tx, Pz - Ty, Py - Tz 
    theta = math.acos((Tvx*vector_x + Tvy*vector_y + Tvz*vector_z)/math.sqrt((Tvx^2 + Tvy^2 + Tvz^2)*(vector_x^2 + vector_y^2 + vector_z)))
    Tv = math.sqrt(Tvx^2 + Tvy^2 + Tvz^2)
    if Tv == v then
        if math.cos(theta) > 0 then
            tick = d/(v*math.cos(theta))
        else
            tick = 0
        end
    else
        if v/Tv > math.abs(math.sin(theta)) then
            tick_plus = d*(Tv*math.cos(theta) + math.sqrt(v^2 - (Tv^2)*(math.sin(theta)^2)))/(Tv^2 - v^2)
            tick_minus = d*(Tv*math.cos(theta) - math.sqrt(v^2 - (Tv^2)*(math.sin(theta)^2)))/(Tv^2 - v^2)
            if tick_plus > 0 and tick_minus > 0 then
                if tick_plus > tick_minus then
                    tick = tick_minus
                else
                    tick = tick_plus
                end
            elseif tick_plus > 0 and tick_minus <= 0 then
                tick = tick_plus
            elseif tick_minus > 0 and tick_plus <= 0 then
                tick = tick_minus
            else
                tick = 0
            end
        elseif v/Tv == math.abs(math.sin(theta)) then
            tick = d*Tv*math.cos(theta)/(Tv^2 - v^2)
        else
            tick = 0
        end
    end
    future_x, future_y, future_z = cal_future_position(Tx, Ty, Tz, Tvx, Tvy, Tvz, tick)
    return future_x, future_y, future_z
end

--指定高度巡航
--delay(m)離れた点に向かって飛ぶ
function cruise(Tx, Ty, Px, Pz, delay)
    local x, y, a, x_plus, x_minus
    if Tx == Px then
        x = Tx
        if Ty > Pz then
            y = Pz + delay
        else
            y = Pz - delay
        end
    elseif Ty == Pz then
        y = Ty
        if Tx > Px then
            x = Px + delay
        else
            x = Px - delay
        end
    else
        a = (Pz - Ty)/(Px - Tx)
        x_plus = (delay/math.sqrt(1 + a^2)) + Px
        x_minus = -(delay/math.sqrt(1 + a^2)) + Px
        if Tx > Px then
            x = x_plus
        else
            x = x_minus
        end
        y = a*(x - Px) + Pz
    end
    return x, y
end

function onTick()
    Px, Py, Pz = INN(26), INN(27), INN(28)
    Ex, Ey, Ez = INN(29), INN(30), INN(31)

    radar_delay = PRN("radar delay [tick]")
    deto_delay = PRN("detonation delay [tick]")
    P, I, D = PRN("P"), PRN("I"), PRN("D")
    type = PRN("Type")

    mode = INN(25)%10
    terminal_guidance = INN(25)%100 > 10
    manual_mode = INN(25)%1000 > 100

    launch = INB(9)
    fcs_detected = INB(10)

    abs_v = INN(32)/60

    wpn_model_no = PRN("Weapon Model No.")

    --無線からの目標情報
    input_coor = (manual_mode and not launch) or (not manual_mode and fcs_detected)
    if input_coor then
        Tx = INN(4)
        Ty = INN(8)
        Tz = INN(12)
        Tvx = INN(16)
        Tvy = INN(20)
        Tvz = INN(24)
    end

    if launch then
        --アクティブレーダー
        if terminal_guidance then
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
                    x = {a = ax, b = bx, est = radar_delay*ax + bx},
                    y = {a = ay, b = by, est = radar_delay*ay + by},
                    z = {a = az, b = bz, est = radar_delay*az + bz}
                }
            end

            --事前情報と最も近い標的を探索
            min_distance, min_ID = math.huge, 0
            for ID, DATA in pairs(data) do
                local distance = distance3(Tx, Ty, Tz, DATA.predict.x.est, DATA.predict.y.est, DATA.predict.z.est)
                if distance < min_distance then
                    min_distance = distance
                    min_ID = ID
                end
            end

            --出力
            AR_lock_on = min_ID ~= 0
            if AR_lock_on then
                radar_x = data[min_ID].predict.x.est
                radar_y = data[min_ID].predict.y.est
                radar_z = data[min_ID].predict.z.est
                radar_vx = data[min_ID].predict.x.a
                radar_vy = data[min_ID].predict.y.a
                radar_vz = data[min_ID].predict.z.a
            end
        end


        --ミサイルコントロール

        ave_v = speed_average(abs_v)
        target_distance = distance3(Tx, Ty, Tz, Px, Pz, Py)

        --destinationに目的地のワールド座標を入れる
        --最低高度まで上昇
        if step1 == false then
            --VLS
            if type == 1 then
                destination_x, destination_y, destination_z = Px, Pz, Py + 1000
                if Py >= 25 and Py > launch_z + 25 then
                    step1 = true
                end
            --ランチャー
            elseif type == 2 then
                destination_x, destination_y, destination_z = Local2World(0, 1000, 0, Px, Py, Pz, Ex, Ey, Ez)
                t = t + 1
                if t > 60 then
                    step1 = true
                end
            end
        --巡航
        elseif step2 == false then
            cruise_target_x, cruise_target_y, cruise_target_z = cal_collision_location(Tx, Ty, Tz, Tvx, Tvy, Tvz, Px, Pz, Py, ave_v, target_distance, 2)
            --ダイレクトアタック
            if mode == 1 then
                step2 = true
            --ノーマル巡航
            elseif mode == 2 then
                destination_x, destination_y = cruise(cruise_target_x, cruise_target_y, Px, Pz, 500)
                destination_z = 100 + cruise_target_z
                if target_distance < 500 then
                    step2 = true
                end
            --トップアタック
            elseif mode == 3 then
                destination_x, destination_y = cruise(cruise_target_x, cruise_target_y, Px, Pz, 500)
                destination_z = 1000 + cruise_target_z
                if target_distance < (Py - Tz)/math.cos(math.pi/9) then
                    step2 = true
                end
            --シースキミング
            elseif mode == 4 then
                destination_x, destination_y = cruise(cruise_target_x, cruise_target_y, Px, Pz, 200)
                destination_z = 5
                if target_distance < 200 then
                    step2 = true
                end
            end
        --終末誘導
        elseif step3 == false then
            radar_target_distance = distance3(radar_x, radar_y, radar_z, Px, Pz, Py)
            if terminal_guidance and target_distance < 800 and AR_lock_on then
                destination_x, destination_y, destination_z = cal_collision_location(radar_x, radar_y, radar_z, radar_vx, radar_vy, radar_vz, Px, Pz, Py, ave_v, radar_target_distance, 0)
            else
                destination_x, destination_y, destination_z = cal_collision_location(Tx, Ty, Tz, Tvx, Tvy, Tvz, Px, Pz, Py, ave_v, target_distance, 2)
            end

            --爆破タイミング
            destination_distance = distance3(destination_x, destination_y, destination_z, Px, Pz, Py)
            if destination_distance/ave_v < deto_delay then
                detonate = true
            end

            OUN(31, destination_distance/ave_v)

        end

        --動翼出力変換
        local Lx, Ly, Lz = World2Local(destination_x, destination_y, destination_z, Px, Py, Pz, Ex, Ey, Ez)
        surface_x = -PID(P, I, D, 0, atan2(Ly, Lx), ESx, ERx, -2, 2)
        surface_y = -PID(P, I, D, 0, atan2(Ly, Lz), ESy, ERy, -2, 2)
    else
        ESx, ERx = 0, 0
        ESy, ERy = 0, 0
        surface_x, surface_y = 0, 0
        launch_z = Py
    end


    OUN(1, surface_x)
    OUN(2, surface_y)

    OUB(1, detonate)

    OUN(32, wpn_model_no)
end