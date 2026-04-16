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
t = 0
delay = 7
target_x,target_y,target_z,target_vx,target_vy,target_vz=0,0,0,0,0,0
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
function World2Local(Wx,Wy,Wz,Px,Py,Pz,Ex,Ey,Ez)
	local Wx=Wx-Px
	local Wy=Wy-Pz
	local Wz=Wz-Py
	local a,b,c,d,e,f,g,h,i,j,k,l,x,z,y
	a=math.cos(Ez)*math.cos(Ey)
	b=math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex)
	c=math.cos(Ez)*math.sin(Ey)*math.cos(Ex)+math.sin(Ez)*math.sin(Ex)
	d=Wx
	e=math.sin(Ez)*math.cos(Ey)
	f=math.sin(Ez)*math.sin(Ey)*math.sin(Ex)+math.cos(Ez)*math.cos(Ex)
	g=math.sin(Ez)*math.sin(Ey)*math.cos(Ex)-math.cos(Ez)*math.sin(Ex)
	h=Wz
	i=-math.sin(Ey)
	j=math.cos(Ey)*math.sin(Ex)
	k=math.cos(Ey)*math.cos(Ex)
	l=Wy
	local Lower=((a*f-b*e)*k+(c*e-a*g)*j+(b*g-c*f)*i)
	x=0
	y=0
	z=0
	if Lower~=0 then
		x=((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j)/Lower
		y=-((a*g-c*e)*l+(d*e-a*h)*k+(c*h-d*g)*i)/Lower
		z=((a*f-b*e)*l+(d*e-a*h)*j+(b*h-d*f)*i)/Lower
	end
	return x,z,y
end
--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end
--g(x) = ax + bを最小二乗法で求める
--xy = {{x1, y1}, {x2, y2},...}
function least_squares_method(xy)
    local a,b,sum_x,sum_y,sum_xy,sum_x2=0,0,0,0,0,0
    if #xy<=5 then
        a=0
        b=xy[#xy][2]
    else
        for i=1, #xy do
            sum_x=sum_x+xy[i][1]
            sum_y=sum_y+xy[i][2]
            sum_xy=sum_xy+xy[i][1]*xy[i][2]
            sum_x2=sum_x2+xy[i][1]^2
        end
        a=(#xy*sum_xy-sum_x*sum_y)/(#xy*sum_x2-sum_x^2)
        b=(sum_x2*sum_y-sum_xy*sum_x)/(#xy*sum_x2-sum_x^2)
    end
    return a,b,#xy,sum_x,sum_y,sum_xy,sum_x2
end
--t tick後の未来位置計算
function cal_future_position(x,y,z,vx,vy,vz,t)
    future_x = x + vx*t
    future_y = y + vy*t
    future_z = z + vz*t
    return future_x,future_y,future_z
end
--二点間の距離
function distance2(x,y,z,a,b,c)
    return (x-a)^2+(y-b)^2+(z-c)^2
end
-- テーブルの中から最小値とそのインデックスを返す関数
function find_Min_And_Index(t)
    local minValue=t[1]
    local minIndex=1
    for i=2,#t do
        if t[i]<minValue then
            minValue=t[i]
            minIndex=i
        end
    end
    return minValue,minIndex
end
function ave(ave, x, num)
    return (ave*(num-1)+x)/num
end
--ターゲットマーカー描画
function drawtarget(x, y, z)
    if y > 0 then
        circle_x = h*math.atan(x, y)/(2*cam_fov)
        circle_y = h*math.atan(z, y)/(2*cam_fov)
        screen.drawCircle(w/2 + circle_x, h/2 - circle_y, 4)
    end
end

function onTick()
    radar_on = INB(9)
    autoaim = INB(10)
    laser_mode = INB(11)
    cam_fov = INN(31)
    radar_fov = INN(29)
    max_sample = INN(28)
    if radar_on then
        rotate_table, local_table, world_table = {}, {}, {}
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
        --同じデータなら合成
        --[[
        local i, j = 1, 2
        while i <= #world_table do
            total_num = 0
            while j <= #world_table do
                local distance = distance2(world_table[i][1], world_table[i][2], world_table[i][3], world_table[j][1], world_table[j][2], world_table[j][3])
                local error_range = 0.01*distance2(physics_x, physics_z, physics_y, world_table[i][1], world_table[i][2], world_table[i][3])
                if distance <= error_range or distance <= 100 then
                    total_num = total_num + 1
                    world_table[i][1], world_table[i][2], world_table[i][3] = ave(world_table[i][1], world_table[j][1], total_num), ave(world_table[i][2], world_table[j][2], total_num), ave(world_table[i][3], world_table[j][3], total_num)
                    table.remove(world_table, j)
                else
                    j = j + 1
                end
            end
            i = i + 1
        end
        ]]
        --目標同定
        for i = 1, #target_data do
            local x, y, z
            x = target_data[i][#target_data[i]][1]
            y = target_data[i][#target_data[i]][2]
            z = target_data[i][#target_data[i]][3]
            
            same_error_range = 0.01*distance2(x, y, z, physics_x, physics_z, physics_y)

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

        --if #world_table > 0 then
            --local x, y, z, vx, vy, vz = target_coordinate[i][1], target_coordinate[i][2], target_coordinate[i][3], target_coordinate[i][4], target_coordinate[i][5], target_coordinate[i][6]
            --local last_t = t - target_data[i][#target_data[i]][4]
        --[[
            --現在位置予測
            local now_x, now_y, now_z = cal_future_position(x, y, z, vx, vy, vz, last_t)
            --誤差範囲計算
            local error_range = 0.02*distance2(now_x, now_y, now_z, physics_x, physics_z, physics_y) + 1
            --予測現在位置と測定位置の距離
            now_to_raw_distance = {}
            for j = 1, #world_table do
                table.insert(now_to_raw_distance, distance2(now_x, now_y, now_z, world_table[j][1], world_table[j][2], world_table[j][3])) 
            end
            --距離比較
            local min_distance, min_i = find_Min_And_Index(now_to_raw_distance)
            OUN(28, min_distance)
            OUN(29, error_range)
            --測定値が予測値と近いならば、目標同定
            local j = 1
            while j <= #world_table do
                if now_to_raw_distance[j] <= error_range then
                    table.insert(target_data[i], world_table[j])
                    table.remove(world_table, j)
                else
                    j = j + 1
                end
            end
        end
        ]]
            
        end

        --新規目標登録
        for i = 1, #world_table do
            table.insert(target_data, {world_table[i]})
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
                    while target_data[i][1][4] < t - max_tracking_tick do
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
            vx, bx , xy_num, sum_x, sum_y, sum_xy, sum_x2= least_squares_method(xt)
            vy, by = least_squares_method(yt)
            vz, bz = least_squares_method(zt)
            x = vx*(t + delay) + bx
            y = vy*(t + delay) + by
            z = vz*(t + delay) + bz
            table.insert(target_coordinate, {x, y, z, vx, vy, vz})
        end
        --出力
        x, y, z, vx, vy, vz = 0, 0, 0, 0, 0, 0
        if laser_mode then
            --レーザー座標計算
            x, y, z = Local2World(0, laser_distance, 0, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
            detected = true
            detected_i = 1
        elseif #target_coordinate == 0 then
            --データなし
            detected = false
        elseif detected and autoaim then
            --自動追尾
            local aimtarget_distance = {}
            for i = 1, #target_coordinate do
                table.insert(aimtarget_distance, distance2(aimtarget[1], aimtarget[2], aimtarget[3], target_coordinate[i][1], target_coordinate[i][2], target_coordinate[i][3]))
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
                    table.insert(display_distance,(local_manual_z/local_manual_y)^2 + (local_manual_x/local_manual_y)^2)
                else
                    table.insert(display_distance, 999)
                end
            end
            min_display_distance, detected_i = find_Min_And_Index(display_distance)
            x, y, z, vx, vy, vz = target_coordinate[detected_i][1], target_coordinate[detected_i][2], target_coordinate[detected_i][3], target_coordinate[detected_i][4], target_coordinate[detected_i][5], target_coordinate[detected_i][6]
            detected = true
        end
        aimtarget = {x, y, z, vx, vy, vz}
        dist = math.sqrt(distance2(x, y, z, physics_x, physics_z, physics_y))
        speed = math.sqrt(vx^2 + vy^2 + vz^2)*60
        if #target_data > 0 then
            sample_num = #target_data[detected_i]
        elseif laser_mode then
            dist = laser_distance
        else
            sample_num = 0
            dist, speed = 0, 0
        end
        lock_on = (sample_num >= math.floor(max_sample))
        OUN(1,x + vx*4)
        OUN(2,y + vy*4)
        OUN(3,z + vz*4)
        OUN(4,vx)
        OUN(5,vy)
        OUN(6,vz)
        OUB(1,detected)
        t = t + 1
    else
        detected_i = 1
        detected = false
        lock_on = false
        t = 0
        target_data = {}
        target_coordinate = {}
        local_table = {}
        aimtarget = {0, 0, 0, 0, 0, 0}
        dist, speed = 0, 0
        sample_num = 0
        OUB(1,detected)
    end

    --[[
    for i = 1, #target_data do
        OUN(7 + i, #target_data[i])
        if i > 10 then
            break
        end
    end
    ]]
end
function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    --ターゲットマーカー
    screen.setColor(0, 255, 0, 200)
    for i = 1, #local_table do
        drawtarget(local_table[i][1], local_table[i][2], local_table[i][3])
    end

    --radar fov用矩形
    rect_h = h*math.tan(radar_fov*math.pi)/math.tan(cam_fov)
    screen.drawRect(w/2 - rect_h/2, h/2 - rect_h/2, rect_h, rect_h)

    --中心線
    screen.setColor(128, 128, 128, 128)
    screen.drawLine(0, h/2, w/2 - h/20, h/2)
    screen.drawLine(w, h/2, w/2 + h/20, h/2)
    screen.drawLine(w/2, h, w/2, h/2 + h/20)

    --ロックオン用表示
    screen.setColor(255, 0, 0)
    if detected then
        if lock_on or laser_mode then
            screen.drawText(1, 9, string.format("D=%dm", math.floor(dist)))
            screen.drawText(1, 15, string.format("V=%dm/s", math.floor(speed)))
            screen.drawText(1, 3, "LOCK ON")
        else
            screen.drawText(1, 3, "DETECTED")
        end
        if not laser_mode then
            screen.setColor(255, 0, 0)
            marker_local_x, marker_local_y, marker_local_z = World2Local(target_coordinate[detected_i][1], target_coordinate[detected_i][2], target_coordinate[detected_i][3], physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
            drawtarget(marker_local_x, marker_local_y, marker_local_z)
        end
    end
    screen.setColor(255, 255, 0)
    screen.drawLine(0, 0, w*sample_num/max_sample - 1, 0)
end