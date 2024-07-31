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

delay = 4
target_x,target_y,target_z,target_vx,target_vy,target_vz=0,0,0,0,0,0
laser_pulse = false
detected = false
--生データ用テーブル
target_data={}
--フィルター済みの位置と速度のテーブル
target_coordinate={}
local_table = {}
speed, dist = 0, 0
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
--ワールド座標からローカル座標へ
function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
	local Wx, Wy, Wz = Wx-Px, Wy-Pz, Wz-Py
	local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y
	a = math.cos(Ez)*math.cos(Ey)
	b = math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex)
	c = math.cos(Ez)*math.sin(Ey)*math.cos(Ex)+math.sin(Ez)*math.sin(Ex)
	d = Wx
	e = math.sin(Ez)*math.cos(Ey)
	f = math.sin(Ez)*math.sin(Ey)*math.sin(Ex)+math.cos(Ez)*math.cos(Ex)
	g = math.sin(Ez)*math.sin(Ey)*math.cos(Ex)-math.cos(Ez)*math.sin(Ex)
	h = Wz
	i = -math.sin(Ey)
	j = math.cos(Ey)*math.sin(Ex)
	k = math.cos(Ey)*math.cos(Ex)
	l = Wy
	local Lower = ((a*f - b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
	x, y, z = 0, 0, 0
	if Lower ~= 0 then
		x = ((b*g - c*f)*l + (d*f - b*h)*k + (c*h - d*g)*j)/Lower
		y = -((a*g - c*e)*l + (d*e - a*h)*k + (c*h - d*g)*i)/Lower
		z = ((a*f - b*e)*l + (d*e - a*h)*j + (b*h - d*f)*i)/Lower
	end
	return x, z, y
end

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--x(t) = at^2 + bt + cを最小二乗法で求める
--xy = {{t1, x1}, {t2, x2},...}
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

--二点間の距離
function distance2(x, y, z, a, b, c)
    return (x - a)^2 + (y - b)^2 + (z - c)^2
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

function onTick()

    radar_on = INB(9)
    autoaim = INB(10)
    laser_mode = INB(11)
    cam_fov = INN(31)
    max_sample = INN(28)
    t = math.floor(max_sample/2)

    x, y, z, vx, vy, vz = 0, 0, 0, 0, 0, 0

    if radar_on then

        rotate_table, local_table, world_table, target_coordinate = {}, {}, {}, {}

        physics_x = INN(4)
        physics_y = INN(8)
        physics_z = INN(12)
        euler_x = INN(16)
        euler_y = INN(20)
        euler_z = INN(24)
        max_tracking_tick = INN(30)
        laser_distance = INN(32)

        --目標をテーブルに読み込む
        for i = 1, 7 do
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
            table.insert(local_table, {local_x, local_y, local_z})
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
            
            same_error_range = 0.005*distance2(x, y, z, physics_x, physics_z, physics_y)

            local j = 1
            while j <= #world_table do
                same_target_dist = distance2(x, y, z, world_table[j][1], world_table[j][2], world_table[j][3])
                if same_target_dist <= same_error_range or same_target_dist < 100 then
                    table.insert(target_data[i], world_table[j])
                    table.remove(world_table, j)
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
                    same_error_range = 0.01*distance2(x, y, z, physics_x, physics_z, physics_y)
                    same_target_dist = distance2(x, y, z, world_table[i][1], world_table[i][2], world_table[i][3])
                    if same_target_dist <= same_error_range or same_target_dist < 100 then
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

        --出力
        if laser_mode then

            --レーザー座標固定
            if not autoaim or not laser_pulse then
                --レーザー座標計算
                x, y, z = Local2World(0, laser_distance, 0, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
                laser_x, laser_y, laser_z = x, y, z
            else
                x, y, z = laser_x, laser_y, laser_z
            end

            detected = true
            detected_i = 1

        elseif #target_coordinate == 0 then
            --データなし
            detected = false
        elseif detected and autoaim then
            --自動追尾
            local aimtarget_distance = {}
            for i = 1, #target_coordinate do
                table.insert(aimtarget_distance, distance2(aimtarget[1], aimtarget[2], aimtarget[3], target_coordinate[i][1], target_coordinate[i][2], target_coordinate[i][3]) + distance2(aimtarget[4], aimtarget[5], aimtarget[6], target_coordinate[i][4], target_coordinate[i][5], target_coordinate[i][6]))
            end
            min_aimtarget, detected_i = find_Min_And_Index(aimtarget_distance)
            x, y, z, vx, vy, vz = target_coordinate[detected_i][1], target_coordinate[detected_i][2], target_coordinate[detected_i][3], target_coordinate[detected_i][4], target_coordinate[detected_i][5], target_coordinate[detected_i][6]
            detected = true
        else
            --手動操作
            display_distance = {}
            for i = 1, #target_coordinate do
                local_manual_x, local_manual_y, local_manual_z = World2Local(target_coordinate[i][1], target_coordinate[i][2], target_coordinate[i][3], physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
                if local_y >= 0 then
                    table.insert(display_distance, (local_manual_z/local_manual_y)^2 + (local_manual_x/local_manual_y)^2)
                else
                    table.insert(display_distance, math.huge)
                end
            end
            min_display_distance, detected_i = find_Min_And_Index(display_distance)
            x, y, z, vx, vy, vz = target_coordinate[detected_i][1], target_coordinate[detected_i][2], target_coordinate[detected_i][3], target_coordinate[detected_i][4], target_coordinate[detected_i][5], target_coordinate[detected_i][6]
            detected = true
        end

        aimtarget = {x, y, z, vx, vy, vz}

        if #target_data > 0 then
            sample_num = #target_data[detected_i]
        else
            sample_num = 0
        end

        lock_on = (sample_num >= math.floor(max_sample))

        --時間経過処理
        for i = 1, #target_data do
            for j = 1, #target_data[i] do
                target_data[i][j][4] = target_data[i][j][4] - 1
            end
        end
    else
        detected_i = 1
        detected = false
        lock_on = false
        target_data = {}
        local_table = {}
        target_coordinate = {}
        aimtarget = {0, 0, 0, 0, 0, 0}
        sample_num = 0
    end

    laser_pulse = laser_mode

    OUN(1, x + vx*4)
    OUN(2, y + vy*4)
    OUN(3, z + vz*4)
    OUN(4, vx)
    OUN(5, vy)
    OUN(6, vz)
    OUB(1, detected)
    OUB(2, lock_on)

    OUN(7, #target_coordinate)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    --ターゲットマーカー
    screen.setColor(0, 255, 0, 200)
    for i = 1, #local_table do
        if local_table[i][2] > 0 then
            circle_x = h*math.atan(local_table[i][1], local_table[i][2])/(2*cam_fov)
            circle_y = h*math.atan(local_table[i][3], local_table[i][2])/(2*cam_fov)
            screen.drawCircle(w/2 + circle_x, h/2 - circle_y, 4)
        end
    end
    screen.setColor(255, 255, 0)
    screen.drawLine(0, 0, w*sample_num/max_sample, 0)
end