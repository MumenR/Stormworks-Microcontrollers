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

--初速と風影響度
--WI = wind influence
V0 = 0
WI = 0
g = 30/3600
rocket_a = 600/3600
tick = 0

infty = 10000
error_range = 2 --degree

parameter = {
    {600, 0.0005, 2400, 0.105}, --Bertha
    {700, 0.001, 2400, 0.11},   --Artillery
    {800, 0.002, 2400, 0.12},   --Battle
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
    return clamp(controll, min, max), error_sum, error
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

--角速度より未来位置計算
t_delta = 0.01
function stabi_future_angle(x, y, z, rvx, rvy, rvz, tick)
    local x_diff, y_diff, z_diff, abs_vector, t
    t = 0
    while t <= tick do
        --外積(変分)を計算
        x_diff, y_diff, z_diff = y*rvz - z*rvy, z*rvx - x*rvz, x*rvy - y*rvx
        --位置ベクトルに足し合わせる
        x, y, z = x + x_diff*t_delta, y + y_diff*t_delta, z + z_diff*t_delta
        --単位ベクトル化
        abs_vector = math.sqrt(x^2 + y^2 + z^2)
        x, y, z = x/abs_vector, y/abs_vector, z/abs_vector
        t = t + t_delta
    end
    return x, y, z
end

--視線角速度
function los_rv(Px, Py, Pz, Pex, Pey, Pez, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, TGTx, TGTy, TGTz, TGTvx, TGTvy, TGTvz)
    local Lrvx, Lrvy, Lrvz, TGTLx, TGTLy, TGTLz, TGTLvx, TGTLvy, TGTLvz, los_rvx, los_rvy, los_rvz
    
    Lrvx, Lrvy, Lrvz = World2Local(Prvx, Prvz, Prvy, 0, 0, 0, Pex, Pey, Pez)
    TGTLx, TGTLy, TGTLz = World2Local(TGTx, TGTy, TGTz, Px, Py, Pz, Pex, Pey, Pez)
    TGTLvx, TGTLvy, TGTLvz = World2Local(TGTvx, TGTvy, TGTvz, 0, 0, 0, Pex, Pey, Pez)

    los_rvx = atan2(TGTLz + TGTLvz - Pvy, TGTLy + TGTLvy - Pvz) - atan2(TGTLz, TGTLy) - Lrvx
    los_rvy = atan2(TGTLx + TGTLvx - Pvx, TGTLz + TGTLvz - Pvy) - atan2(TGTLx, TGTLz) - Lrvy
    los_rvz = atan2(TGTLy + TGTLvy - Pvz, TGTLx + TGTLvx - Pvx) - atan2(TGTLy, TGTLx) - Lrvz
    
    return los_rvx, los_rvy, los_rvz
end

--ローカル座標からローカル極座標へ変換
function Local2Polar(x, y, z, radian_bool)
    local pitch, yaw
    pitch = atan2(math.sqrt(x^2 + y^2), z)
    yaw = atan2(y, x)
    if radian_bool then
        return pitch, yaw
    else
        return pitch/(math.pi*2), yaw/(math.pi*2)
    end
end

function onTick()
    target_x = INN(1)
    target_y = INN(2)
    target_z = INN(3)
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
    physics_rvx = INN(16)
    physics_rvy = INN(17)
    physics_rvz = INN(18)

    local_wind_v = INN(19)/60
    local_wind_direc = INN(20)
    pitch_position = INN(21)
    yaw_position = INN(22)

    Weapon = PRN("Weapon Type") + 1
    standby = PRN("standby yaw position (degree)")/360
    min_pitch = PRN("min pitch (degree)")/360
    max_pitch = PRN("max pitch (degree)")/360
    pitch_limit = PRB("Pitch Swivel Mode")
    min_yaw = PRN("min yaw (degree)")/360
    max_yaw = PRN("max yaw (degree)")/360
    yaw_limit = PRB("Yaw Swivel Mode")

    yaw_position = yaw_position - standby

    P = INN(23)
    I = INN(24)
    D = INN(25)
    max_speed_gain = INN(26)
    delay = INN(27)
    stabi_delay = INN(28)

    pitch_pivot_speed = PRN("Pitch gear ratio (1 : ?)")/PRN("Types of Pitch PIVOT")   --gear/pivot
    yaw_pivot_speed = PRN("Yaw gear ratio (1 : ?)")/PRN("Types of Yaw PIVOT")

    offset_x = PRN("offset x (m)")
    offset_y = PRN("offset y (m)")
    offset_z = PRN("offset z (m)")

    detected = INB(1)
    power = INB(2)
    reload = INB(5)

    range = false

    V0, K, tick_del, WI = parameter[Weapon][1]/60, parameter[Weapon][2], parameter[Weapon][3], parameter[Weapon][4]

    --オフセット
    physics_x, physics_z, physics_y = Local2World(offset_x, offset_y, offset_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)

    --自分基準ワールド座標系へ
    target_x, target_y, target_z = target_x - physics_x, target_y - physics_z, target_z - physics_y

    --補足時かつ起動時
    if detected and power then
        --遅れ補正
        target_x, target_y, target_z = cal_future_position(target_x, target_y, target_z, target_vx, target_vy, target_vz, delay)
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

                    Iteration_j = j
                end

                range = tick < tick_del and Iteration_j ~= 30

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
    else
        Azimuth, Elevation = 0, 0
        range = false
        rotation_speed_pitch, rotation_speed_yaw = 0, 0
    end

    --スタビライザー
    if range then
        --向くべき座標計算
        controll_x = physics_x + infty*math.sin(Azimuth)
        controll_y = physics_z + infty*math.cos(Azimuth)
        controll_z = physics_y + infty*math.tan(Elevation)
        controll_local_x, controll_local_y, controll_local_z = World2Local(controll_x, controll_y, controll_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
        
        --視線角速度計算
        los_rvx, los_rvy, los_rvz = los_rv(physics_x, physics_y, physics_z, euler_x, euler_y, euler_z, physics_vx, physics_vy, physics_vz, physics_rvx, physics_rvy, physics_rvz, target_x, target_y, target_z, target_vx, target_vy, target_vz)

        --向くべき未来位置計算
        controll_stabi_x, controll_stabi_y, controll_stabi_z = stabi_future_angle(controll_local_x, controll_local_y, controll_local_z, los_rvx, los_rvy, los_rvz, stabi_delay)
        controll_pitch, controll_yaw = Local2Polar(controll_stabi_x, controll_stabi_y, controll_stabi_z, false)
        controll_yaw = same_rotation(controll_yaw - standby)

        if reload then
            controll_pitch = 0
        end
    else
        controll_pitch, controll_yaw = 0, 0
        controll_local_x, controll_local_y, controll_local_z = 0, 1, 0
        pitch_error, yaw_error = 0, 360
        tick = 0
    end

    --射撃可能判定用誤差計算
    goal_pitch, goal_yaw = Local2Polar(controll_local_x, controll_local_y, controll_local_z, false)
    goal_yaw = same_rotation(goal_yaw - standby)
    pitch_error = math.abs(same_rotation(goal_pitch - pitch_position))*360
    yaw_error = math.abs(same_rotation(goal_yaw - yaw_position))*360

    --射撃可能判定
    position_in_fov = same_rotation(yaw_position) > min_yaw and same_rotation(yaw_position) < max_yaw and pitch_position > min_pitch and pitch_position < max_pitch
    target_in_fov_pitch = goal_pitch > min_pitch and goal_pitch < max_pitch
    target_in_fov_yaw = goal_yaw > min_yaw and goal_yaw < max_yaw
    in_error = pitch_error < error_range and yaw_error < error_range
    shootable = range and in_error and position_in_fov and target_in_fov_pitch and target_in_fov_yaw and not reload

    --fov外処理
    if not target_in_fov_pitch and pitch_limit then
        controll_pitch = 0
    end
    if not target_in_fov_yaw and yaw_limit then
        controll_yaw = 0
    end

    --差分へ
    pitch_diff = controll_pitch - pitch_position
    if yaw_limit then
        yaw_diff = controll_yaw - yaw_position
    else
        yaw_diff = same_rotation(controll_yaw - yaw_position)
    end

    --PID
    pitch, error_sum_pitch, error_pre_pitch = PID(P, I, D, 0, -pitch_diff*pitch_pivot_speed, error_sum_pitch, error_pre_pitch, -pitch_pivot_speed*max_speed_gain, pitch_pivot_speed*max_speed_gain)
    yaw, error_sum_yaw, error_pre_yaw = PID(P, I, D, 0, -yaw_diff*yaw_pivot_speed, error_sum_yaw, error_pre_yaw, -yaw_pivot_speed*max_speed_gain, yaw_pivot_speed*max_speed_gain)

    --ピッチ角制限
    if pitch_limit then
        pitch = limit_rotation(pitch, same_rotation(pitch_position), min_pitch, max_pitch)
    end
    --ヨー角制限
    if yaw_limit then
        yaw = limit_rotation(yaw, same_rotation(yaw_position), min_yaw, max_yaw)
    end

    --ゼロ除算対策
    if pitch ~= pitch then
        pitch = 0
    end
    if yaw ~= yaw then
        yaw = 0
    end

    OUN(1, pitch)
    OUN(2, yaw)
    OUB(1, shootable)

    OUN(3, pitch_error)
    OUN(4, yaw_error)

    OUN(30, tick)
    OUN(31, Elevation)
    OUN(32, Azimuth)
end