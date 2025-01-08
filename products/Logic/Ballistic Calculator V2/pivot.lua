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

infty = 10000
error_range = 1 --degree

error_pre_pitch = 0
error_sum_pitch = 0
error_pre_yaw = 0
error_sum_yaw = 0

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

function same_rotation(x)
    return (x + 0.5)%1 - 0.5
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

function onTick()

    physics_x = INN(1)
    physics_y = INN(2)
    physics_z = INN(3)
    euler_x = INN(4)
    euler_y = INN(5)
    euler_z = INN(6)
    physics_rx = INN(7)
    physics_ry = INN(8)
    physics_rz = INN(9)
    
    pitch_position = INN(10)
    yaw_position = INN(11)
    standby = INN(12)
    min_elevation = INN(13)
    max_elevation = INN(14)
    fov = INN(15)

    pitch_pivot_speed = INN(16)
    yaw_pivot_speed = INN(17)
    max_speed_gain = INN(18)

    rotation_speed_pitch = INN(19)
    rotation_speed_yaw = INN(20)

    --ゼロ除算対策
    if pitch_pivot_speed ~= pitch_pivot_speed then
        pitch_pivot_speed = 1
    end
    if yaw_pivot_speed ~= yaw_pivot_speed then
        yaw_pivot_speed = 1
    end

    Elevation = INN(31)
    Azimuth = INN(32)

    range = INB(1)
    rotation_limit = INB(2)
    reload = INB(3)

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