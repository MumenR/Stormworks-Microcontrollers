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
pi2 = math.pi*2

--初速と風影響度
--WI = wind influence
V0 = 0
WI = 0
g = 30/3600
rocket_a = 600/3600
tick = 0
TRD1_DELAY = 0
STABI_DELAY = 7.45
P = 8
I = 0
D = 20

INFTY = 10000
PIVOT_MAX_ERROR = 2 --degree

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

--ローカル座標からワールド座標へ変換(physics sensor使用)
function local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
    local RetX, RetY, RetZ
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--ワールド座標からローカル座標へ(physics sensor使用)
function world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
    local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y, Lower
	Wx = Wx - Px
	Wy = Wy - Pz
	Wz = Wz - Py
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
	Lower = ((a*f-b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
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

--等加速度直線運動で時間から位置を求める
--V0: 初速, a: 加速度, t: 時間, K:抵抗値
-- -(1/math.log(1 - K))*((V0 + a/math.log(1 - K))*(1 - (1 - K)^t) + a*t)
function calTrajectory(V0, a, t)
    return ((V0 - a/K)*(1 - math.exp(-K*t)) + a*t)/K
end

--等加速度直線運動で時間から速度を求める
function calTrajectoryV(V0, a, t)
    return (V0 - a/K)*math.exp(-K*t) + a/K
end

--等加速度直線運動で速度０となる時間を求める
function calTrajectoryT(V0, a)
    return math.log(1 - K*V0/a)/K
end

--二分法
--到達チックをy方向から逆算
function dichotomy(tick_min, tick_max, tick, V0, a, Ty, reverse)
    local y
    for i = 1, 20 do
        y = calTrajectory(V0, a, tick)
        if y*reverse > Ty*reverse then
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
function windLocal2World(windLv, windLdirec, Pvx, Pvz, Ex, Ey, Ez)
    local windLvx, windLvy, x, y, z, e_x, e_y, e_z, windWdirec, windWv
    --ローカル風速
    windLvx = windLv*math.sin(windLdirec*pi2) - Pvx
    windLvy = windLv*math.cos(windLdirec*pi2) - Pvz
    --風速ベクトルと単位ｚベクトルをワールド変換
    x, y, z = local2World(windLvx, windLvy, 0, 0, 0, 0, Ex, Ey, Ez)
    e_x, e_y, e_z = local2World(0, 0, 1, 0, 0, 0, Ex, Ey, Ez)
    --ワールド風速を計算
    windWvx = x - (e_x*z)/e_z
    windWvy = y - (e_y*z)/e_z
    windWdirec = math.atan(windWvx, windWvy)
    windWv = distance2(windWvx, windWvy)
    return windWv, windWdirec
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

--未来位置予測(return: x, y, z, vx, vy, vz)
function predictTRD1(x, y, z, vx, vy, vz, ax, ay, az, t)
    return ax*t^2/2 + vx*t + x, ay*t^2/2 + vy*t + y, az*t^2/2 + vz*t + z, ax*t + vx, ay*t + vy, az*t + vz
end

pitchErrorPre = 0
pitchErrorSum = 0
yawErrorPre = 0
yawErrorSum = 0

--PID制御
function PID(P, I, D, target, current, error_sum_pre, error_pre, min, max)
    local error, error_diff, control
    error = target - current
    error_sum = error_sum_pre + error
    error_diff = error - error_pre
    control = P*error + I*error_sum + D*error_diff

    if control > max or control < min then
        error_sum = error_sum_pre
        control = P*error + I*error_sum + D*error_diff
    end
    return clamp(control, min, max), error_sum, error
end

function same_rotation(x)
    return (x + 0.5)%1 - 0.5
end

function limit_rotation(control, position, min, max)
    if position >= max then
        if control > 0 then
            control = 0
        end
        control = control - 0.01
    elseif position <= min then
        if control < 0 then
            control = 0
        end
        control = control + 0.01
    end
    return control
end

--角速度より未来位置計算
t_delta = 0.1
function stabiFutureAngle(x, y, z, rvx, rvy, rvz, tick)
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

--視線角速度(return: losX, losY, losZ)
function losRv(Px, Py, Pz, Ex, Ey, Ez, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, Tx, Ty, Tz, Tvx, Tvy, Tvz)
    local Vrx, Vry, Vrz, T2, TLx, TLy, TLz, TLvx, TLvy, TLvz, PLrvx, PLrvy, PLrvz
    TLx, TLy, TLz = world2Local(Tx, Ty, Tz, Px, Py, Pz, Ex, Ey, Ez)
    TLvx, TLvy, TLvz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Ex, Ey, Ez)
    PLrvx, PLrvy, PLrvz = world2Local(Prvx, Prvz, Prvy, 0, 0, 0, Ex, Ey, Ez)
    --相対速度
    Vrx, Vry, Vrz = TLvx - Pvx, TLvy - Pvz, TLvz - Pvy
    --分母
    T2 = TLx^2 + TLy^2 + TLz^2
    --標的の角速度を求め、自身の角速度と合成
    return -(TLy*Vrz - TLz*Vry)/T2 - PLrvx, -(TLz*Vrx - TLx*Vrz)/T2 - PLrvy, -(TLx*Vry - TLy*Vrx)/T2 - PLrvz
end

--ローカル座標からローカル極座標へ変換
function rect2Polar(x, y, z, radian_bool)
    local pitch, yaw
    pitch = math.atan(z, math.sqrt(x^2 + y^2))
    yaw = math.atan(x, y)
    if radian_bool then
        return pitch, yaw
    else
        return pitch/(pi2), yaw/(pi2)
    end
end

function onTick()
    Tx = INN(1)
    Ty = INN(2)
    Tz = INN(3)
    Tvx = INN(4)
    Tvy = INN(5)
    Tvz = INN(6)
    Tax = INN(7)
    Tay = INN(8)
    Taz = INN(9)

    Px = INN(10)
    Py = INN(11)
    Pz = INN(12)
    Ex = INN(13)
    Ey = INN(14)
    Ez = INN(15)

    Pvx = INN(16)/60
    Pvy = INN(17)/60
    Pvz = INN(18)/60
    Prvx = INN(19)*pi2/60
    Prvy = INN(20)*pi2/60
    Prvz = INN(21)*pi2/60

    windLv = INN(22)/60
    windLdirec = INN(23)
    currentPitch = INN(24)
    currentYaw = INN(25)

    WPN_TYPE = PRN("Weapon Type") + 1
    STANDBY_YAW = PRN("standby yaw position (degree)")/360
    MIN_PITCH = PRN("min pitch (degree)")/360
    MAX_PITCH = PRN("max pitch (degree)")/360
    PITCH_LIMIT_ENABLE = PRB("Pitch Swivel Mode")
    MIN_YAW = PRN("min yaw (degree)")/360
    MAX_YAW = PRN("max yaw (degree)")/360
    YAW_LIMIT_ENABLE = PRB("Yaw Swivel Mode")

    currentYaw = currentYaw - STANDBY_YAW

    MAX_SPEED_GAIN = PRN("Pivot rotation speed gain")

    PITCH_PIVOT = PRN("Pitch gear ratio (1 : ?)")/PRN("Types of Pitch PIVOT")   --gear/pivot
    YAW_PIVOT = PRN("Yaw gear ratio (1 : ?)")/PRN("Types of Yaw PIVOT")

    OFFSET_X = PRN("offset x (m)")
    OFFSET_Y = PRN("offset y (m)")
    OFFSET_Z = PRN("offset z (m)")

    TRD1Exists = INB(1)

    power = INB(2)
    highAngleEnable = INB(4)
    reloadEnable = INB(5)

    inRange = false

    V0, K, tick_del, WI = parameter[WPN_TYPE][1]/60, parameter[WPN_TYPE][2], parameter[WPN_TYPE][3], parameter[WPN_TYPE][4]

    --オフセット
    Px, Pz, Py = local2World(OFFSET_X, OFFSET_Y, OFFSET_Z, Px, Py, Pz, Ex, Ey, Ez)

    --自分基準ワールド座標系へ
    TWLx, TWLy, TWLz = Tx - Px, Ty - Pz, Tz - Py

    --補足時かつ起動時
    if TRD1Exists and power then
        --遅れ補正
        TWLx, TWLy, TWLz, Tvx, Tvy, Tvz = predictTRD1(TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz, TRD1_DELAY)
        --ワールド速度
        Wvx, Wvy, Wvz = local2World(Pvx, Pvz, Pvy, 0, 0, 0, Ex, Ey, Ez)
        Wvxy = distance2(Wvx, Wvy)
        Wvxy_direc = math.atan(Wvx, Wvy)
        --風向き変換
        windWv, windWdirec = windLocal2World(windLv, windLdirec, Pvx, Pvz, Ex, Ey, Ez)

        --向くべき方向を計算
        future_x, future_y, future_z = TWLx, TWLy, TWLz
        
        tickPre = 0     --偏差終了判定に用いる到達時間

        --未来位置偏差のループ
        for i = 1, 15 do
            --方位角、仰角仮定
            future_xy = distance2(future_x, future_y)
            Azimuth = math.atan(future_x, future_y)
            Elevation = math.atan(future_z, future_xy)
            
            --曲射ループ
            for k = 1, 2 do
                --イテレーション
                for j = 1, 60 do
                    Iteration_j = j

                    --砲弾方向に風とビークル速度を成分分解
                    --yが砲弾前進方向
                    goal_y = future_xy*math.cos(math.atan(future_x, future_y) - Azimuth)

                    windWvx = windWv*math.sin(windWdirec - Azimuth)
                    windWvy = windWv*math.cos(windWdirec - Azimuth)
                    wind_ax, wind_ay = -windWvx*WI/60, -windWvy*WI/60
    
                    V0_x = Wvxy*math.sin(Wvxy_direc - Azimuth)
                    V0_y = V0*math.cos(Elevation) + Wvxy*math.cos(Wvxy_direc - Azimuth)
                    V0_z = V0*math.sin(Elevation) + Wvz
    
                    --ロケット
                    if WPN_TYPE == 8 then
                        ay = rocket_a*math.cos(Elevation) + wind_ay
                        az = rocket_a*math.sin(Elevation) - g
                        rocket_y = calTrajectory(V0_y, ay, 60)
                        rocket_z = calTrajectory(V0_z, az, 60)
                        rocket_V0_y = calTrajectoryV(V0_y, ay, 60)
                        rocket_V0_z = calTrajectoryV(V0_z, az, 60)

                        --直射
                        if k < 2 then
                            --加速している間の計算
                            if rocket_y > goal_y then
                                tick, y = dichotomy(0, tick_del*2, tick_del, V0_y , ay, goal_y, 1)
                                z = calTrajectory(V0_z, az, tick)
                            --加速後の計算
                            else
                                rocket_tick, y = dichotomy(0, tick_del*2, tick_del, rocket_V0_y ,wind_ay, goal_y - rocket_y, 1)
                                y =  y + rocket_y
                                z = calTrajectory(rocket_V0_z, -g, rocket_tick) + rocket_z
                                tick = 60 + rocket_tick
                            end
                        --曲射
                        else
                            min_tick = calTrajectoryT(rocket_V0_z, -g)
                            rocket_tick, z = dichotomy(min_tick, tick_del*2, tick_del, rocket_V0_z , -g, future_z - rocket_z, -1)
                            y = calTrajectory(rocket_V0_y, wind_ay, rocket_tick) + rocket_y
                            z = z + rocket_z
                            tick = 60 + rocket_tick
                        end
                    --ロケット以外
                    else
                        --直射
                        if k < 2 then
                            tick, y = dichotomy(0, tick_del*2, tick_del, V0_y, wind_ay, goal_y, 1)
                            z = calTrajectory(V0_z, -g, tick)
                        --曲射
                        else
                            min_tick = calTrajectoryT(V0_z, -g)
                            tick, z = dichotomy(min_tick, tick_del*2, tick_del, V0_z, -g, future_z, -1)
                            y = calTrajectory(V0_y, wind_ay, tick)
                        end
                    end

                    x = calTrajectory(V0_x, wind_ax, tick)

                    --イテレーション終了
                    if (math.abs(future_z - z) < 0.1 and k < 2) or (math.abs(goal_y - y) < 0.1 and k > 1) then
                        break
                    end
    
                    --誤差より、方位角と仰角を修正
                    Azimuth = math.atan(future_x, future_y) - math.atan(x, y)
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
                        Elevation = Elevation + math.atan(future_z, goal_y) - math.atan(z, y)
                    end

                end

                inRange = tick < tick_del and Iteration_j ~= 60

                --曲射ループへ
                if highAngleEnable and k < 2 and inRange then
                    min_Elevation = clamp(Elevation, math.pi/9, math.pi/2)
                    max_Elevation = math.pi/2
                    Elevation = math.pi/4 + min_Elevation/2
                else
                    break
                end
            end

            --tickより、目標未来位置計算
            future_x, future_y, future_z = predictTRD1(TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz, tick)
            --未来位置偏差終了
            if math.abs(tickPre - tick) < 0.01 then
                break
            end
            tickPre = tick
        end
    else
        Azimuth, Elevation = 0, 0
        inRange = false
        rotation_speed_pitch, rotation_speed_yaw = 0, 0
    end

    --スタビライザー
    if inRange then
        --向くべき座標計算
        stabiWx, stabiWy, stabiWz = Px + INFTY*math.sin(Azimuth), Pz + INFTY*math.cos(Azimuth), Py + INFTY*math.tan(Elevation)
        srabiLx, srabiLy, srabiLz = world2Local(stabiWx, stabiWy, stabiWz, Px, Py, Pz, Ex, Ey, Ez)

        --射撃可能判定用の、本来向くべき向き
        targetPitch, targetYaw = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        
        --視線角速度計算
        losX, losY, losZ = losRv(Px, Py, Pz, Ex, Ey, Ez, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, Tx, Ty, Tz, Tvx, Tvy, Tvz)

        --向くべき未来位置計算
        srabiLx, srabiLy, srabiLz = stabiFutureAngle(srabiLx, srabiLy, srabiLz, losX, losY, losZ, STABI_DELAY)
        stabiPitch, stabiYaw = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        stabiYaw = same_rotation(stabiYaw - STANDBY_YAW)

        if reloadEnable then
            stabiPitch = 0
        end
    else
        stabiPitch, stabiYaw = 0, 0
        srabiLx, srabiLy, srabiLz = 0, 1, 0
        targetPitch, targetYaw = 0, 0
        tick = 0
    end



    --射撃可能判定
    currentInFOV = same_rotation(currentYaw) > MIN_YAW and same_rotation(currentYaw) < MAX_YAW and currentPitch > MIN_PITCH and currentPitch < MAX_PITCH
    targetInFOVPitch = targetPitch > MIN_PITCH and targetPitch < MAX_PITCH
    targetInFOVYaw = targetYaw > MIN_YAW and targetYaw < MAX_YAW
    pitchError = math.abs(same_rotation(targetPitch - currentPitch))*360
    yawError = math.abs(same_rotation(targetYaw - STANDBY_YAW - currentYaw))*360
    inError = pitchError < PIVOT_MAX_ERROR and yawError < PIVOT_MAX_ERROR
    shootable = inRange and inError and currentInFOV and targetInFOVPitch and targetInFOVYaw and not reloadEnable

    --fov外処理
    if not targetInFOVPitch and PITCH_LIMIT_ENABLE then
        stabiPitch = 0
    end
    if not targetInFOVYaw and YAW_LIMIT_ENABLE then
        stabiYaw = 0
    end

    --差分へ
    pitch_diff = stabiPitch - currentPitch
    if YAW_LIMIT_ENABLE then
        yaw_diff = stabiYaw - currentYaw
    else
        yaw_diff = same_rotation(stabiYaw - currentYaw)
    end

    --PID
    pitch, pitchErrorSum, pitchErrorPre = PID(P, I, D, 0, -pitch_diff*PITCH_PIVOT, pitchErrorSum, pitchErrorPre, -PITCH_PIVOT*MAX_SPEED_GAIN, PITCH_PIVOT*MAX_SPEED_GAIN)
    yaw, yawErrorSum, yawErrorPre = PID(P, I, D, 0, -yaw_diff*YAW_PIVOT, yawErrorSum, yawErrorPre, -YAW_PIVOT*MAX_SPEED_GAIN, YAW_PIVOT*MAX_SPEED_GAIN)

    --ピッチ角制限
    if PITCH_LIMIT_ENABLE then
        pitch = limit_rotation(pitch, same_rotation(currentPitch), MIN_PITCH, MAX_PITCH)
    end
    --ヨー角制限
    if YAW_LIMIT_ENABLE then
        yaw = limit_rotation(yaw, same_rotation(currentYaw), MIN_YAW, MAX_YAW)
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

    OUN(3, pitchError)
    OUN(4, yawError)

    OUN(30, tick)
    OUN(31, Elevation)
    OUN(32, Azimuth)
end
