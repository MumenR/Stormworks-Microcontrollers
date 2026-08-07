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
        simulator:setInputBool(2, simulator:getIsToggled(1))
        simulator:setInputBool(3, simulator:getIsToggled(2))
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

laser_direction = {}
pi2 = math.pi*2
stabi_yaw_error_sum, stabi_yaw_error_pre = 0, 0

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--ワールド座標からローカル座標へ変換(physics sensor使用)
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

--ローカル座標からローカル極座標へ変換
function Local2Polar(x, y, z, radian_bool)
    local pitch, yaw
    pitch = atan2(math.sqrt(x^2 + y^2), z)
    yaw = atan2(y, x)
    if radian_bool then
        return pitch, yaw
    else
        return pitch/pi2, yaw/pi2
    end
end

--ローカル極座標からローカル座標へ変換
function Polar2Local(pitch, yaw, distance)
    return distance*math.cos(pitch)*math.sin(yaw), distance*math.cos(pitch)*math.cos(yaw), distance*math.sin(pitch)
end

rad_cam_max = math.pi*135/360  --FOV[rad] when input value is 0
rad_cam_min = 0.025/2     --FOV[rad] when input value is 1

--カメラズーム変換
function calzoom(zoom_controll, minfov, maxfov)
    local rad_min, rad_max, a, C, rad_liner
    rad_min = math.pi*minfov/360
    rad_max = math.pi*maxfov/360

    --入力値をラジアンに線形変換
    rad_liner = (rad_cam_min - rad_cam_max)*zoom_controll + rad_cam_max
    
    --線形ラジアンを非線形に変換
    a = math.log(math.tan(rad_min)/math.tan(rad_max))/(rad_cam_min - rad_cam_max)
    C = math.log(math.tan(rad_min)) - rad_cam_min*a
    rad_not_liner = math.atan(math.exp(a*rad_liner + C))

    --非線形ラジアンを制御用値に変換
    zoom_output = (rad_not_liner - rad_cam_max)/(rad_cam_min - rad_cam_max)

    return zoom_output
end

--回転数そろえる
function same_rotation(x)
    return (x + 0.5)%1 - 0.5
end

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

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

--視線角速度
function los_rv(x, y, vx, vy)
    return atan2(y + vy, x + vx) - atan2(y, x)
    
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

function onTick()
    touch = INB(1)
    power = INB(2)
    upper_bottun = INB(3)

    screen_w = INN(1)
    screen_h = INN(2)
    touch_x = INN(3)
    touch_y = INN(4)
    yaw_controll = INN(5)
    pitch_controll = INN(6)
    zoom_controll = INN(7)
    distance = INN(8)
    yaw_position = same_rotation(INN(9))

    physics_x = INN(10)
    physics_y = INN(11)
    physics_z = INN(12)
    euler_x_laser = INN(13)
    euler_y_laser = INN(14)
    euler_z_laser = INN(15)
    euler_x_body = INN(16)
    euler_y_body = INN(17)
    euler_z_body = INN(18)
    physics_vx = INN(19)/60
    physics_vy = INN(20)/60
    physics_vz = INN(21)/60
    physics_rvx = INN(22)*pi2/60
    physics_rvy = INN(23)*pi2/60
    physics_rvz = INN(24)*pi2/60

    gain = INN(25)
    pivot = INN(26)
    gear = INN(27)
    max_speed_gain = INN(28)
    P = property.getNumber("P")
    I = property.getNumber("I")
    D = property.getNumber("D")

    stabi_delay_laser = INN(29)
    stabi_delay_pivot = INN(30)

    offset_x = INN(31)
    offset_y = INN(32)
    offset_z = property.getNumber("laser physics offset z")


    --初期化
    laser_x = 0
    target_x, target_y, target_z = 0, 0, 0
    tracking_physics_x, tracking_physics_y, tracking_physics_z = 0, 0, 0
    tracker_local_x, tracker_local_y, tracker_local_z = 0, 0, 0

    if power then
        if touch and not touch_pulse then
            --ボタン
            if (touch_y >= screen_h - 7 and touch_y <= screen_h and not upper_bottun) or (touch_y >= 0 and touch_y <= 7 and upper_bottun) then
                if touch_pulse == false then
                    if touch_x >= screen_w/2 - 17 and touch_x <= screen_w/2 - 10 then
                        nightvision = not nightvision
                    end
                    if touch_x >= screen_w/2 - 8 and touch_x <= screen_w/2 - 1 then
                        laser = not laser
                    end
                    if touch_x >= screen_w/2 + 1 and touch_x <= screen_w/2 + 8 then
                        stabilizer = not stabilizer
                    end
                    if touch_x >= screen_w/2 + 10 and touch_x <= screen_w/2 + 17 then
                        tracker = not tracker
                    end
                end
            end
        end
        touch_pulse = touch

        --目標出力
        if laser then
            target_pitch = (laser_direction[1][2]/8)*pi2
            target_local_x, target_local_y, target_local_z = Polar2Local(target_pitch, 0, distance)
            target_x, target_y, target_z = Local2World(target_local_x - offset_x, target_local_y - offset_y, target_local_z - offset_z, physics_x, physics_y, physics_z, euler_x_laser, euler_y_laser, euler_z_laser)
        end

        --スタビライザーと追尾モード
        if stabilizer or tracker then
            yaw_position_rad = yaw_position*pi2
            --基準ワールドベクトル初期値設定
            if not stabilizer_pulse or (not tracker and tracker_pulse)then
                stabi_local_x, stabi_local_y, stabi_local_z = Polar2Local(pi2*laser_y/8, yaw_position_rad, 1)
                stabi_x, stabi_y, stabi_z = Local2World(stabi_local_x, stabi_local_y, stabi_local_z, 0, 0, 0, euler_x_body, euler_y_body, euler_z_body)
            end

            --追尾モード
            if tracker then
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
            else
                tracking = false
            end

            --基準ローカルベクトルへ変換
            stabi_local_x, stabi_local_y, stabi_local_z = World2Local(stabi_x, stabi_y, stabi_z, tracking_physics_x, tracking_physics_y, tracking_physics_z, euler_x_body, euler_y_body, euler_z_body)

            --手動操作
            manual_rv_gain = gain*pi2*rad_not_liner/60
            manual_pitch_direc = -manual_rv_gain*pitch_controll
            manual_yaw_direc = manual_rv_gain*yaw_controll

            --基準ローカルベクトルの変分を加算して更新(手動操作)
            stabi_local_x, stabi_local_y, stabi_local_z = stabi_future_angle(stabi_local_x, stabi_local_y, stabi_local_z, manual_pitch_direc*math.cos(yaw_position_rad), -manual_pitch_direc*math.sin(yaw_position_rad), manual_yaw_direc, 1)

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

            --ピボットスタビ
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
    else
        nightvision = false
        stabilizer = false
        tracker = false
        tracking = false
        laser = false
        laser_y = 0

        --初期位置
        yaw, stabi_yaw_error_sum, stabi_yaw_error_pre = PID(P, I, D, 0, yaw_position, stabi_yaw_error_sum, stabi_yaw_error_pre, -gear*max_speed_gain/pivot, gear*max_speed_gain/pivot)
    end

    --nill 対策
    if yaw ~= yaw then
        yaw = 0
    end

    --ズーム計算
    zoom = calzoom(zoom_controll, 180*0.025/math.pi, 135)

    --目標検出
    detected = laser and distance ~= 4000 and distance ~= 0

    --レーザー方向遅延生成
    table.insert(laser_direction, {laser_x, laser_y})
    if #laser_direction > 5 then
        table.remove(laser_direction, 1)
    end


    OUN(1, laser_x)
    OUN(2, laser_y)
    OUN(3, yaw)
    OUN(4, zoom)
    OUN(5, target_x)
    OUN(6, target_y)
    OUN(7, target_z)

    OUB(1, detected)
    OUB(2, nightvision)
    OUB(3, laser)

    OUN(32, distance)
    OUB(32, stabilizer)
    OUB(31, tracker)
    OUB(30, upper_bottun)
end