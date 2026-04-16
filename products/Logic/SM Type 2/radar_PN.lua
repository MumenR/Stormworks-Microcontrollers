-- Author: MumenR
-- GitHub: <GithubLink>
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
delay = 6
target_x, target_y, target_z, target_vx, target_vy, target_vz = 0, 0, 0, 0, 0, 0
target_lock_on = false

--生データ用テーブル
target_data = {}
--フィルター済みの位置と速度のテーブル
target_coordinate = {}
--[[
target_data = {
    {{x1, y1, z1, tick},...},
    {{x1, y1, z1, tick},...},
    ...
}

target_coordinate = {
    {x1, y1, z1, vx1, vy1, vz1},
    {x2, y2, z2, vx2, vy2, vz2},
    ...
}
]]
--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	local RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex)+math.sin(Ez)*math.sin(Ex))*Ly
	local RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex)+math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex)-math.cos(Ez)*math.sin(Ex))*Ly
	local RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX+Px, RetZ+Pz, RetY+Py
end

--g(t) = at^2 + bt + c を最小二乗法で求める
--xy = {{x1, y1}, {x2, y2},...}
function least_squares_method2(xy)
    local a, b, c, t, n, S1, S2, S3, S4, T0, T1, T2 = 0, 0, 0, xy[#xy][1], #xy, 0, 0, 0 ,0 ,0, 0, 0
    if #xy <= 5 then
        c = xy[n][2]
    else
        for i=1, n do
            S1 = S1 + xy[i][1]
            S2 = S2 + xy[i][1]^2
            S3 = S3 + xy[i][1]^3
            S4 = S4 + xy[i][1]^4
            T0 = T0 + xy[i][2]
            T1 = T1 + xy[i][1]*xy[i][2]
            T2 = T2 + (xy[i][1]^2)*xy[i][2]
        end
        d = 2*S1*S2*S3 + n*S2*S4 - S4*S1^2 - n*S3^2 - S2^3
        a = (n*S2*T2 - T2*S1^2 + S1*S2*T1 - n*S3*T1 + S1*S3*T0 - T0*S2^2)/d
        b = (S1*S2*T2 - n*S3*T2 + n*S4*T1 - T1*S2^2 + S2*S3*T0 - S1*S4*T0)/d
        c = (-T2*S2^2 + S1*S3*T2 - S1*S4*T1 + S2*S3*T1 - T0*S3^2 + S2*S4*T0)/d
    end
    return 2*a*t + b, a*t^2 + b*t + c
end

--t tick後の未来位置計算
function cal_future_position(x, y, z, vx, vy, vz, t)
    local future_x, future_y, future_z
    future_x = x + vx*t
    future_y = y + vy*t
    future_z = z + vz*t
    return future_x, future_y, future_z
end
--二点間の距離
function distance(x, y, z, a, b, c)
    return math.sqrt((x - a)^2 + (y - b)^2 + (z - c)^2)
end
-- テーブルの中から最小値とそのインデックスを返す関数
function find_Min_And_Index(t)
    local minValue = t[1]
    local minIndex = 1
    for i = 2, #t do
        if t[i] < minValue then
            minValue = t[i]
            minIndex = i
        end
    end
    return minValue, minIndex
end
-- 指定した値がリスト内にあるかどうかを確認する関数
function containsValue(list, value)
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end
    return false
end

function onTick()
    radar_on = INB(9)
    fcs_lock = INB(10)

    max_sample = INN(25)
    --情報を保存する最大tick
    t = math.floor(max_sample/2)

    manual_mode = INB(11)

    same_target_on = false
    OUN(7, 0)

    if radar_on then

        rotate_table = {}
        world_table = {}
        physics_x = INN(27)
        physics_y = INN(28)
        physics_z = INN(29)
        euler_x = INN(30)
        euler_y = INN(31)
        euler_z = INN(32)

        if manual_mode then
            target_x = INN(16)
            target_y = INN(20)
            target_z = INN(24)
        elseif fcs_lock then
            target_x = INN(4)
            target_y = INN(8)
            target_z = INN(12)
        end



        --目標をテーブルに読み込む
        for i = 1, 6 do
            if INB(i) then
                --rotate_table = {{distance1, rotate_x1, rotate_y1},...}
                table.insert(rotate_table, {INN(i*4 - 3), INN(i*4 - 2), INN(i*4 - 1)})
            end
        end

        for i = 1, #rotate_table do
            --ローカル座標に変換
            local_x = rotate_table[i][1]*math.cos(rotate_table[i][3]*2*math.pi)*math.sin(rotate_table[i][2]*2*math.pi)
            local_y = rotate_table[i][1]*math.cos(rotate_table[i][3]*2*math.pi)*math.cos(rotate_table[i][2]*2*math.pi)
            local_z = rotate_table[i][1]*math.sin(rotate_table[i][3]*2*math.pi)

            --ワールド座標に変換
            --world_table = {{world_x1, world_y1, world_z1, tick1},...}
            world_x, world_y, world_z = Local2World(local_x, local_y, local_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
            table.insert(world_table, {world_x, world_y, world_z, t})
        end

        --目標同定
        for i = 1, #target_data do
            local x, y, z
            x = target_data[i][#target_data[i]][1]
            y = target_data[i][#target_data[i]][2]
            z = target_data[i][#target_data[i]][3]
            
            same_error_range = 0.1*distance(x, y, z, physics_x, physics_z, physics_y)

            local j = 1
            while j <= #world_table do
                same_target_dist = distance(x, y, z, world_table[j][1], world_table[j][2], world_table[j][3])
                if same_target_dist <= same_error_range or same_target_dist < 20 then
                    table.insert(target_data[i], world_table[j])
                    table.remove(world_table, j)
                    same_target_on = true
                else
                    j = j + 1
                end
            end
        end

        --新規目標登録
        target_data_num = #target_data
        for i = 1, #world_table do
            --同時に同じ目標を複数検出した場合
            local same_signal = false
            for j = target_data_num + 1, #target_data do
                if #target_data[j] <= 8 then
                    local x, y, z
                    x = target_data[j][#target_data[j]][1]
                    y = target_data[j][#target_data[j]][2]
                    z = target_data[j][#target_data[j]][3]
                    same_error_range = 0.1*distance(x, y, z, physics_x, physics_z, physics_y)
                    same_target_dist = distance(x, y, z, world_table[i][1], world_table[i][2], world_table[i][3])
                    if same_target_dist <= same_error_range or same_target_dist < 10 then
                        table.insert(target_data[j], world_table[i])
                        same_signal = true
                        break
                    end
                end
            end

            if not same_signal then
                table.insert(target_data, {world_table[i]})
            end
        end

        --古いデータの削除
        do
            local i = 1
            while i <= #target_data do
                --一定データ量超過
                while #target_data[i] > max_sample do
                    table.remove(target_data[i], 1)
                end
                --一定時間経過
                if target_data[i][1][4] ~= nil then
                    while target_data[i][1][4] < -t do
                        table.remove(target_data[i], 1)
                        if #target_data[i] == 0 then
                            break
                        end
                    end
                end
                --nilテーブル削除
                if #target_data[i] == 0 then
                    table.remove(target_data, i)
                else
                    i = i + 1
                end
            end
        end

        --座標・速度計算
        target_coordinate = {}
        for i = 1, #target_data  do
            local x, y, z, vx, vy, vz
            xt, yt, zt = {}, {}, {}
            --最小二乗法用のテーブル作成
            for j = 1, #target_data[i] do
                table.insert(xt, {target_data[i][j][4], target_data[i][j][1]})
                table.insert(yt, {target_data[i][j][4], target_data[i][j][2]})
                table.insert(zt, {target_data[i][j][4], target_data[i][j][3]})
            end
            --最小二乗法
            vx, cx = least_squares_method2(xt)
            vy, cy = least_squares_method2(yt)
            vz, cz = least_squares_method2(zt)
            x = vx*delay + cx
            y = vy*delay + cy
            z = vz*delay + cz
            table.insert(target_coordinate, {x, y, z, vx, vy, vz})
        end

        --追尾目標判定
        --差分計算
        if #target_coordinate > 0 then
            if not same_target_on then
                target_lock_on = false
            end
            if target_lock_on then
                OUN(7, 1)
                for i = 1, 6 do
                    OUN(i, target_coordinate[lock_on_i][i])
                end
            else
                diff_distance_table = {}
                for i = 1, #target_coordinate do
                    diff_distance = distance(target_x, target_y, target_z, target_coordinate[i][1], target_coordinate[i][2], target_coordinate[i][3])
                    table.insert(diff_distance_table, diff_distance)
                end

                --誤差範囲計算
                local error_range
                if manual_mode then
                    error_range = 350
                else
                    error_range = 0.1*distance(target_x, target_y, target_z, physics_x, physics_z, physics_y)
                end

                --差分比較
                local min_distance, min_i = find_Min_And_Index(diff_distance_table)

                --誤差範囲内なら目標出力
                if min_distance <= error_range then
                    if manual_mode then
                        target_lock_on = false
                    else
                        target_lock_on = true
                    end
                    lock_on_i = min_i
                    OUN(7, 1)
                    for i = 1, 6 do
                        OUN(i, target_coordinate[min_i][i])
                    end
                else
                    OUN(7, 0)
                    for i = 1, 6 do
                        OUN(i, 0)
                    end
                end
            end
        else
            target_lock_on = false
        end

        --時間経過処理
        for i = 1, #target_data do
            for j = 1, #target_data[i] do
                target_data[i][j][4] = target_data[i][j][4] - 1
            end
        end
    else
        target_data = {}
        target_coordinate = {}
    end
end