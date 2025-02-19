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

--初速と風影響度
--WI = wind influence
V0 = 0
WI = 0
g = 30/3600
rocket_a = 600/3600
tick = 0

infty = 10000
error_range = 1 --degree

parameter = {
    {600, 0.0005, 2400, 0.105}, --Bertha
    {700, 0.001, 2400, 0.11},   --Artillery
    {800, 0.002, 1500, 0.12},   --Battle
    {900, 0.005, 600, 0.125},   --Heavy Auto
    {1000, 0.01, 300, 0.13},    --Rotary Auto
    {1000, 0.02, 150, 0.135},   --Light Auto
    {800, 0.025, 120, 0.15},    --Machine Gun
    {50, 0.003, 3600, 0.125}    --Rocket Launcher
}

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

--ワールド座標からローカル座標へ(physics sensor使用)
function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
	Wx, Wy, Wz = Wx-Px, Wy-Pz, Wz-Py
	a_WL = math.cos(Ez)*math.cos(Ey)
	b_WL = math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex)
	c_WL = math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex)
	d_WL = Wx
	e_WL = math.sin(Ez)*math.cos(Ey)
	f_WL = math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex)
	g_WL = math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex)
	h_WL = Wz
	i_WL = -math.sin(Ey)
	j_WL = math.cos(Ey)*math.sin(Ex)
	k_WL = math.cos(Ey)*math.cos(Ex)
	l_WL = Wy
	Lower = ((a_WL*f_WL - b_WL*e_WL)*k_WL + (c_WL*e_WL - a_WL*g_WL)*j_WL + (b_WL*g_WL - c_WL*f_WL)*i_WL)
	x_WL, y_WL, z_WL = 0, 0, 0
	if Lower ~= 0 then
		x_WL = ((b_WL*g_WL - c_WL*f_WL)*l_WL + (d_WL*f_WL - b_WL*h_WL)*k_WL + (c_WL*h_WL - d_WL*g_WL)*j_WL)/Lower
		y_WL = -((a_WL*g_WL - c_WL*e_WL)*l_WL + (d_WL*e_WL - a_WL*h_WL)*k_WL + (c_WL*h_WL - d_WL*g_WL)*i_WL)/Lower
		z_WL = ((a_WL*f_WL - b_WL*e_WL)*l_WL + (d_WL*e_WL - a_WL*h_WL)*j_WL + (b_WL*h_WL - d_WL*f_WL)*i_WL)/Lower
	end
	return x_WL, z_WL, y_WL
end

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--等加速度直線運動で時間から位置を求める
--V0: 初速, a: 加速度, t: 時間, K:抵抗値
-- -(1/math.log(1 - K))*((V0 + a/math.log(1 - K))*(1 - (1 - K)^t) + a*t)
function cal_Trajectory(V0, a, t)
    return ((V0 - a/K)*(1 - math.exp(-K*t)) + a*t)/K
end

--等加速度直線運動で時間から速度を求める
function cal_Trajectory_v(V0, a, t)
    return (V0 - a/K)*math.exp(-K*t) + a/K
end

--等加速度直線運動で速度０となる時間を求める
function cal_Trajectory_t(V0, a)
    return math.log(1 - K*V0/a)/K
end

--二分法
--到達チックをy方向から逆算
function dichotomy(tick_min, tick_max, tick, V0, a, target_y, reverse)
    local y
    for i = 1, 15 do
        y = cal_Trajectory(V0, a, tick)
        if y*reverse > target_y*reverse then
            tick_max = tick
            tick = (tick + tick_min)/2
        else
            tick_min = tick
            tick = (tick + tick_max)/2
        end
    end
    return tick, y
end

--風速をワールド風速に変換
function wind_local2world(local_wind_v, local_wind_direc, physics_vx, physics_vz, euler_x, euler_y, euler_z)
    local local_wind_vx, local_wind_vy, x, y, z, e_x, e_y, e_z, wind_direc, wind_v
    --ローカル風速
    local_wind_vx = local_wind_v*math.sin(local_wind_direc*math.pi*2) - physics_vx
    local_wind_vy = local_wind_v*math.cos(local_wind_direc*math.pi*2) - physics_vz
    --風速ベクトルと単位ｚベクトルをワールド変換
    x, y, z = Local2World(local_wind_vx, local_wind_vy, 0, 0, 0, 0, euler_x, euler_y, euler_z)
    e_x, e_y, e_z = Local2World(0, 0, 1, 0, 0, 0, euler_x, euler_y, euler_z)
    --ワールド風速を計算
    wind_vx = x - (e_x*z)/e_z
    wind_vy = y - (e_y*z)/e_z
    wind_direc = atan2(wind_vy, wind_vx)
    wind_v = distance2(wind_vx, wind_vy)
    return wind_v, wind_direc
end

function distance2(x, y)
    return math.sqrt(x^2 + y^2)
end

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

--t tick後の未来位置計算
function cal_future_position(x, y, z, vx, vy, vz, t)
    cal_x = x + vx*t
    cal_y = y + vy*t
    cal_z = z + vz*t
    return cal_x, cal_y, cal_z
end

error_pre_pitch = 0
error_sum_pitch = 0
error_pre_yaw = 0
error_sum_yaw = 0

--PID制御
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

    return controll, error_sum, error
end

function same_rotation(x)
    return (x + 0.5)%1 - 0.5
end

function limit_rotation(controll, position, min, max)
    if position >= max then
        if controll > 0 then
            controll = 0
        end
        controll = controll - 0.01
    elseif position <= min then
        if controll < 0 then
            controll = 0
        end
        controll = controll + 0.01
    end
    return controll
end

--ローカル極座標からローカル座標へ変換
function Polar2Local(pitch, yaw, distance)
    return distance*math.cos(pitch)*math.sin(yaw), distance*math.cos(pitch)*math.cos(yaw), distance*math.sin(pitch)
end

function onTick()
    target_x = INN(1) - INN(7)
    target_y = INN(2) - INN(9)
    target_z = INN(3) - INN(8)
    target_vx = INN(4)
    target_vy = INN(5)
    target_vz = INN(6)

    physics_x = INN(7)
    physics_y = INN(8)
    physics_z = INN(9)
    euler_x = INN(10)
    euler_y = INN(11)
    euler_z = INN(12)

    physics_vx = INN(13)/60
    physics_vy = INN(14)/60
    physics_vz = INN(15)/60
    physics_rx = INN(16)
    physics_ry = INN(17)
    physics_rz = INN(18)

    local_wind_v = INN(19)/60
    local_wind_direc = INN(20)
    pitch_position = INN(21)
    yaw_position = INN(22) - INN(24)/360

    Weapon = INN(23) + 1
    standby = INN(24)/360
    fov = INN(25)/720
    min_elevation = INN(26)/360
    max_elevation = INN(27)/360

    max_speed_gain = INN(28)
    pitch_pivot_speed = INN(32)/INN(30)   --gear/pivot
    yaw_pivot_speed = INN(32)/INN(31)

    rotation_limit = INB(3)
    reload = INB(5)

    range = false

    V0, K, tick_del, WI = parameter[Weapon][1]/60, parameter[Weapon][2], parameter[Weapon][3], parameter[Weapon][4]

    --補足時(1)かつ起動時(2)
    if INB(1) and INB(2) then
        --遅れ補正
        target_x, target_y, target_z = cal_future_position(target_x, target_y, target_z, target_vx, target_vy, target_vz, INN(29))
        --ワールド速度
        world_vx, world_vy, world_vz = Local2World(physics_vx, physics_vz, physics_vy, 0, 0, 0, euler_x, euler_y, euler_z)
        world_vxy = distance2(world_vx, world_vy)
        world_vxy_direc = atan2(world_vy, world_vx)
        --風向き変換
        wind_v, wind_direc = wind_local2world(local_wind_v, local_wind_direc, physics_vx, physics_vz, euler_x, euler_y, euler_z)

        --向くべき方向を計算
        future_x, future_y, future_z = target_x, target_y, target_z
        
        --未来位置偏差のループ
        tick_pre = 0
        for i = 1, 15 do
            --方位角、仰角仮定
            future_xy = distance2(future_x, future_y)
            Azimuth = atan2(future_y, future_x)
            Elevation = atan2(future_xy, future_z)
            
            --曲射ループ
            for k = 1, 2 do
                --イテレーション
                for j = 1, 30 do
                    --砲弾方向に風とビークル速度を成分分解
                    --yが砲弾前進方向
                    goal_y = future_xy*math.cos(atan2(future_y, future_x) - Azimuth)

                    wind_vx = wind_v*math.sin(wind_direc - Azimuth)
                    wind_vy = wind_v*math.cos(wind_direc - Azimuth)
                    wind_ax, wind_ay = -wind_vx*WI/60, -wind_vy*WI/60
    
                    V0_x = world_vxy*math.sin(world_vxy_direc - Azimuth)
                    V0_y = V0*math.cos(Elevation) + world_vxy*math.cos(world_vxy_direc - Azimuth)
                    V0_z = V0*math.sin(Elevation) + world_vz
    
                    --ロケット
                    if Weapon == 8 then
                        ay = rocket_a*math.cos(Elevation) + wind_ay
                        az = rocket_a*math.sin(Elevation) - g
                        rocket_y = cal_Trajectory(V0_y, ay, 60)
                        rocket_z = cal_Trajectory(V0_z, az, 60)
                        rocket_V0_y = cal_Trajectory_v(V0_y, ay, 60)
                        rocket_V0_z = cal_Trajectory_v(V0_z, az, 60)

                        --直射
                        if k < 2 then
                            --加速している間の計算
                            if rocket_y > goal_y then
                                tick, y = dichotomy(0, tick_del*2, tick_del, V0_y , ay, goal_y, 1)
                                z = cal_Trajectory(V0_z, az, tick)
                            --加速後の計算
                            else
                                rocket_tick, y = dichotomy(0, tick_del*2, tick_del, rocket_V0_y ,wind_ay, goal_y - rocket_y, 1)
                                y =  y + rocket_y
                                z = cal_Trajectory(rocket_V0_z, -g, rocket_tick) + rocket_z
                                tick = 60 + rocket_tick
                            end
                        --曲射
                        else
                            min_tick = cal_Trajectory_t(rocket_V0_z, -g)
                            rocket_tick, z = dichotomy(min_tick, tick_del*2, tick_del, rocket_V0_z , -g, future_z - rocket_z, -1)
                            y = cal_Trajectory(rocket_V0_y, wind_ay, rocket_tick) + rocket_y
                            z = z + rocket_z
                            tick = 60 + rocket_tick
                        end
                    --ロケット以外
                    else
                        --直射
                        if k < 2 then
                            tick, y = dichotomy(0, tick_del*2, tick_del, V0_y, wind_ay, goal_y, 1)
                            z = cal_Trajectory(V0_z, -g, tick)
                        --曲射
                        else
                            min_tick = cal_Trajectory_t(V0_z, -g)
                            tick, z = dichotomy(min_tick, tick_del*2, tick_del, V0_z, -g, future_z, -1)
                            y = cal_Trajectory(V0_y, wind_ay, tick)
                        end
                    end

                    x = cal_Trajectory(V0_x, wind_ax, tick)
                    
                    
                    OUN(28, x)
                    OUN(29, y)
                    OUN(30, z)
                    

                    --イテレーション終了
                    if (math.abs(future_z - z) < 0.1 and k < 2) or (math.abs(goal_y - y) < 0.1 and k > 1) then
                        break
                    end
    
                    --誤差より、方位角と仰角を修正
                    Azimuth = atan2(future_y, future_x) - atan2(y, x)
                    --曲射
                    if k > 1 then
                        if y < goal_y then
                            max_Elevation = Elevation
                            Elevation = (Elevation + min_Elevation)/2
                        else
                            min_Elevation = Elevation
                            Elevation = (Elevation + max_Elevation)/2
                        end
                    --直射
                    else
                        Elevation = Elevation + atan2(goal_y, future_z) - atan2(y, z)
                    end
                    
                end

                range = tick < tick_del

                --曲射ループへ
                if INB(4) and k < 2 and range then
                    min_Elevation = clamp(Elevation, math.pi/9, math.pi/2)
                    max_Elevation = math.pi/2
                    Elevation = math.pi/4 + min_Elevation/2
                else
                    break
                end
            end

            --tickより、目標未来位置計算
            future_x, future_y, future_z = cal_future_position(target_x, target_y, target_z, target_vx, target_vy, target_vz, tick)
            --未来位置偏差終了
            if math.abs(tick_pre - tick) < 0.01 then
                break
            end
            tick_pre = tick
        end

        --視線角速度計算
        target_local_x, target_local_y, target_local_z = World2Local(INN(1), INN(2), INN(3), physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
        target_local_vx, target_local_vy, target_local_vz = World2Local(target_vx, target_vy, target_vz, 0, 0, 0, euler_x, euler_y, euler_z)
        sum_x, sum_y, sum_z = target_local_x + target_local_vx - physics_vx, target_local_y + target_local_vy - physics_vz, target_local_z + target_local_vz - physics_vy
        rotation_speed_pitch = atan2(distance2(sum_x, sum_y), sum_z) - atan2(distance2(target_local_x, target_local_y), target_local_z)
        rotation_speed_yaw = atan2(sum_y, sum_x) - atan2(target_local_y, target_local_x)
    else
        Azimuth, Elevation = 0, 0
        range = false
        rotation_speed_pitch, rotation_speed_yaw = 0, 0
    end

    if not range then
        tick = 0
    end

    OUN(30, tick)
    OUN(31, Elevation)
    OUN(32, Azimuth)

    --ゼロ除算対策
    if pitch_pivot_speed ~= pitch_pivot_speed then
        pitch_pivot_speed = 1
    end
    if yaw_pivot_speed ~= yaw_pivot_speed then
        yaw_pivot_speed = 1
    end

    if reload then
        Elevation = 0
    end

    P = PRN("P")
    I = PRN("I")
    D = PRN("D")

    --向くべき座標計算
    controll_x = physics_x + infty*math.sin(Azimuth)
    controll_y = physics_z + infty*math.cos(Azimuth)
    controll_z = physics_y + infty*math.tan(Elevation)
    local_controll_x, local_controll_y, local_controll_z = World2Local(controll_x, controll_y, controll_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)

    --旧スタビ
    if range then
        --ローカル座標から目標回転数へ
        target_pitch = 0.5*atan2(distance2(local_controll_x, local_controll_y), local_controll_z)/math.pi
        target_yaw = same_rotation(0.5*atan2(local_controll_y, local_controll_x)/math.pi - standby)

        --スタビライザー
        local_rx, local_ry, local_rz = World2Local(physics_rx, physics_rz, physics_ry, 0, 0, 0, euler_x, euler_y, euler_z)
        stabi_rad = same_rotation(yaw_position + standby)*2*math.pi
        pitch_stabi = -pitch_pivot_speed*(local_rx*math.cos(stabi_rad) - local_ry*math.sin(stabi_rad))
        yaw_stabi = -yaw_pivot_speed*local_rz

        if (rotation_limit and math.abs(target_yaw) > fov) or (target_pitch < min_elevation or target_pitch > max_elevation) then
            target_pitch = 0
            target_yaw = 0
        end
    else
        target_pitch = 0
        target_yaw = 0
    end



    --スタビライザー
    if range then
        yaw_position_rad = yaw_position*pi2


        --追尾座標決定
        if not tracking and laser and distance ~= 4000 and distance ~= 0 then
            tracker_x, tracker_y, tracker_z = target_x, target_y, target_z
            tracking = true
        end
        --追尾
        if tracking then
            pitch_controll, yaw_controll = 0, 0
            stabi_x, stabi_y, stabi_z = tracker_x, tracker_y, tracker_z
            target_x, target_y, target_z = tracker_x, tracker_y, tracker_z
            tracking_physics_x, tracking_physics_z, tracking_physics_y = Local2World(-offset_x, -offset_y, -offset_z, physics_x, physics_y, physics_z, euler_x_laser, euler_y_laser, euler_z_laser)
            tracker_local_x, tracker_local_y, tracker_local_z = World2Local(tracker_x, tracker_y, tracker_z, tracking_physics_x, tracking_physics_y, tracking_physics_z, euler_x_body, euler_y_body, euler_z_body)
        end


        --基準ローカルベクトルへ変換
        stabi_local_x, stabi_local_y, stabi_local_z = World2Local(stabi_x, stabi_y, stabi_z, tracking_physics_x, tracking_physics_y, tracking_physics_z, euler_x_body, euler_y_body, euler_z_body)


        --基準ワールドベクトル更新
        stabi_x, stabi_y, stabi_z = Local2World(stabi_local_x, stabi_local_y, stabi_local_z, tracking_physics_x, tracking_physics_y, tracking_physics_z, euler_x_body, euler_y_body, euler_z_body)
        
        --角速度変換(スタビライザー)
        local_rvx, local_rvy, local_rvz = World2Local(physics_rvx, physics_rvz, physics_rvy, 0, 0, 0, euler_x_body, euler_y_body, euler_z_body)
        if tracking then
            local_target_rvx = los_rv(tracker_local_y, tracker_local_z, -physics_vz, -physics_vy)
            local_target_rvy = los_rv(tracker_local_z, tracker_local_x, -physics_vy, -physics_vx)
            local_target_rvz = los_rv(tracker_local_x, tracker_local_y, -physics_vx, -physics_vz)
            local_rvx = local_rvx - local_target_rvx
            local_rvy = local_rvy - local_target_rvy
            local_rvz = local_rvz - local_target_rvz
        end
        
        --レーザースタビ
        stabi_laser_x, stabi_laser_y, stabi_laser_z = stabi_future_angle(stabi_local_x, stabi_local_y, stabi_local_z, -local_rvx, -local_rvy, -local_rvz, stabi_delay_laser)
        stabi_pitch, stabi_yaw = Local2Polar(stabi_laser_x, stabi_laser_y, stabi_laser_z, false)
        laser_y = 8*stabi_pitch

        --ピッチスタビ
        stabi_pivot_x, stabi_pivot_y, stabi_pivot_z = stabi_future_angle(stabi_local_x, stabi_local_y, stabi_local_z, -local_rvx, -local_rvy, -local_rvz, stabi_delay_pivot)
        stabi_pitch, stabi_pitch = Local2Polar(stabi_pivot_x, stabi_pivot_y, stabi_pivot_z, false)
        pitch_diff = gear*same_rotation(stabi_pitch + manual_pitch_direc - pitch_position)/pivot
        pitch, stabi_pitch_error_sum, stabi_pitch_error_pre = PID(P, I, D, 0, -pitch_diff, stabi_pitch_error_sum, stabi_pitch_error_pre, -gear*max_speed_gain/pivot, gear*max_speed_gain/pivot)

        --ヨースタビ
        stabi_pivot_x, stabi_pivot_y, stabi_pivot_z = stabi_future_angle(stabi_local_x, stabi_local_y, stabi_local_z, -local_rvx, -local_rvy, -local_rvz, stabi_delay_pivot)
        stabi_pitch, stabi_yaw = Local2Polar(stabi_pivot_x, stabi_pivot_y, stabi_pivot_z, false)
        yaw_diff = gear*same_rotation(stabi_yaw + manual_yaw_direc - yaw_position)/pivot
        yaw, stabi_yaw_error_sum, stabi_yaw_error_pre = PID(P, I, D, 0, -yaw_diff, stabi_yaw_error_sum, stabi_yaw_error_pre, -gear*max_speed_gain/pivot, gear*max_speed_gain/pivot)
    
    --手動操作
    else
        tracking = false
        stabi_yaw_error_sum, stabi_yaw_error_pre = 0, 0

        laser_y = clamp(gain*rad_not_liner*8*pitch_controll/60 + laser_y, -1, 1)
        yaw = gain*rad_not_liner*yaw_controll*gear/pivot
    end

    --パルス生成
    stabilizer_pulse = stabilizer or tracker
    tracker_pulse = tracker



    --目標回転数から差分へ
    pitch_error = target_pitch - pitch_position
    pitch_speed = pitch_pivot_speed*(pitch_error)
    same_yaw = same_rotation(yaw_position)
    if rotation_limit then
        yaw_error = target_yaw - same_yaw
        yaw_speed = yaw_pivot_speed*(yaw_error)
    else
        yaw_error = same_rotation(target_yaw - yaw_position)
        yaw_speed = yaw_pivot_speed*same_rotation(yaw_error)
    end

    --PID
    pitch_PID, error_sum_pitch, error_pre_pitch = PID(P, I, D, 0, -pitch_speed, error_sum_pitch, error_pre_pitch, -pitch_pivot_speed*max_speed_gain, pitch_pivot_speed*max_speed_gain)
    yaw_PID, error_sum_yaw, error_pre_yaw = PID(P, I, D, 0, -yaw_speed, error_sum_yaw, error_pre_yaw, -yaw_pivot_speed*max_speed_gain, yaw_pivot_speed*max_speed_gain)

    --視線角速度変換(rad/tick -> /s)
    rotation_speed_pitch = rotation_speed_pitch*pitch_pivot_speed*30/math.pi
    rotation_speed_yaw = rotation_speed_yaw*yaw_pivot_speed*30/math.pi

    --射撃可能判定
    in_fov = math.abs(same_yaw) < fov and pitch_position > min_elevation and pitch_position < max_elevation
    position = math.abs(pitch_error) < error_range/360 and math.abs(yaw_error) < error_range/360
    shootable = range and position and in_fov and not reload

    OUN(3, pitch_error*360)
    OUN(4, yaw_error*360)

    if not (range and in_fov) then
        pitch_stabi, yaw_stabi = 0, 0
        rotation_speed_pitch, rotation_speed_yaw = 0, 0
    end

    --合成
    pitch = clamp(pitch_PID + pitch_stabi + rotation_speed_pitch, -pitch_pivot_speed*max_speed_gain, pitch_pivot_speed*max_speed_gain)
    yaw = clamp(yaw_PID + yaw_stabi + rotation_speed_yaw, -yaw_pivot_speed*max_speed_gain, yaw_pivot_speed*max_speed_gain)

    --ピッチ角制限
    pitch = limit_rotation(pitch, pitch_position, min_elevation, max_elevation)

    --ヨー角制限
    if rotation_limit then
        yaw = limit_rotation(yaw, same_yaw, -fov, fov)
    end

    OUN(1, pitch)
    OUN(2, yaw)
    OUB(1, shootable)
end