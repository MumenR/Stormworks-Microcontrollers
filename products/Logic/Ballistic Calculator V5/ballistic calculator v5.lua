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
WIND_INFLUENCE = 0
g = 30/3600
ROCKET_ACL = 600/3600
ROCKET_ACL_TICK = 60
tick = 0
TRD1_DELAY = 0
STABI_DELAY = 7.45
P = 8
I = 0
D = 20
ALT_INTERVAL = 500  --数値積分の高度間隔[m]

INFTY = 10000
PIVOT_MAX_ERROR = 2 --degree
NEWTON_ERROR = 0.01  --ニュートン法における距離誤差[m]

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

--関数群
do
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

    --減衰あり等加速度直線運動で時間から位置と速度を求める
    --V0: 初速, a: 加速度, t: 時間, K:抵抗値
    function calTrajectoryXV(x0, V0, a, t, K)
        debug1 = debug1 + 1

        return ((V0 - a/K)*(1 - math.exp(-K*t)) + a*t)/K + x0, (V0 - a/K)*math.exp(-K*t) + a/K
    end

    --減衰あり等加速度直線運動で水平距離から垂直距離を求める
    function calTrajectoryZ(V0, K, theta, y)
        return y*(V0*math.sin(theta) + g/K)/V0/math.cos(theta) + g*math.log(1 - K*y/V0/math.cos(theta))/(K^2)
    end

    --高度変化による気圧と重力加速度を求める(return g [m/tick^2], atm)
    function calGravAndAtm(h)
        local g, atm
        g = 30*math.exp(-1/60*h/1000)/3600
        atm = (((44.33-h/1000)/11.89)^5.256)/1013
        atm = (h >= 40000) and 0 or atm
        return g, atm
    end

    --xに到達するまでの時間をニュートン法で求める(return t, y)
    function newtonsMethod(x, x0, v0, a, K, t)
        local df, y
        for i = 1, 20 do
            y = calTrajectoryXV(x0, v0, a, t, K) - x
            --終了条件
            if math.abs(y) < NEWTON_ERROR then
                break
            end
            df = (v0 - a/K)*math.exp(-K*t) + a/K
            t = t - y/df
        end
        return t, y + x
    end

    --ブレント法(b:最良, a:bと逆符号, c: 前回のb, d:今回更新幅, e:前回更新幅)
    --return: a, b, c, fa, fc, d
    function brentsMethod(a, b, c, fa, fb, fc, e)
        local alpha, beta, d
        if fa*fb > 0 then                   --a, bが同符号の場合入れ替え
            a = c
            fa = fc
            d = b - c
            e = d
        end
        if math.abs(fa) < math.abs(fb) then --入れ替え
            a, b, c = b, c, b
            fa, fb, fc = fb, fc, fb
        end

        alpha = (a - b)/2
        beta = fb/fc

        if math.abs(fc) < math.abs(fb) then --二分法
            d, e = alpha, alpha
        else
            local p, q, r
            if a == c then                  --線形補間
                p = 2*alpha*beta
                q = 1 - beta
            else                            --逆二次補完
                q = fc/fa
                r = fb/fa
                p = beta*(2*alpha*q*(q - r) - (b - c)*(r - 1))
                q = (q - 1)*(r - 1)*(beta - 1)
            end

            beta, e = e, d

            if math.abs(2*p) < math.abs(3*alpha*q) and math.abs(p) < math.abs(beta*q/2) then
                d = -p/q
            else                            --二分法
                d, e = alpha, alpha
            end
        end

        b, c = b + d, b
        fc = fb
        return a, b, c, fa, fc, d
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
        windVx = x - (e_x*z)/e_z
        windVy = y - (e_y*z)/e_z
        windWdirec = math.atan(windVx, windVy)
        windWv = distance2(windVx, windVy)
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
    function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
        local error, errorSum, errorDiff, control
        error = target - current
        errorSum = errorSumPre + error
        errorDiff = error - errorPre
        control = P*error + I*errorSum + D*errorDiff

        if control > max or control < min then
            errorSum = errorSumPre
            control = P*error + I*errorSum + D*errorDiff
        end
        return clamp(control, min, max), errorSum, error
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

    --ローカル座標からローカル極座標へ変換(return pitch, yaw)
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

end

function onTick()
    debug1 = 0

    --インプット
    do
        Tx = INN(1)
        Ty = INN(2)
        Tz = INN(3)
        Tvx = INN(4)
        Tvy = INN(5)
        Tvz = INN(6)
        Tax = INN(7)
        Tay = INN(8)
        Taz = INN(9)

        BodEx = INN(10)
        BodEy = INN(11)
        BodEz = INN(12)
        BodPvx = INN(13)/60
        BodPvy = INN(14)/60
        BodPvz = INN(15)/60
        BodPrvx = INN(16)*pi2/60
        BodPrvy = INN(17)*pi2/60
        BodPrvz = INN(18)*pi2/60

        TurPx = INN(19)
        TurPy = INN(20)
        TurPz = INN(21)
        TurEx = INN(22)
        TurEy = INN(23)
        TurEz = INN(24)

        windLv = INN(25)/60
        windLdirec = INN(26)

        WPN_TYPE = PRN("Weapon Type") + 1
        STANDBY_YAW = PRN("standby yaw position (degree)")/360
        MIN_PITCH = PRN("min pitch (degree)")/360
        MAX_PITCH = PRN("max pitch (degree)")/360
        PITCH_LIMIT_ENABLE = PRB("Pitch Swivel Mode")
        MIN_YAW = PRN("min yaw (degree)")/360
        MAX_YAW = PRN("max yaw (degree)")/360
        YAW_LIMIT_ENABLE = PRB("Yaw Swivel Mode")
        MAX_SPEED_GAIN = PRN("Pivot rotation speed gain")
        PITCH_PIVOT = PRN("Pitch gear ratio (1 : ?)")/PRN("Types of Pitch PIVOT")   --gear/pivot
        YAW_PIVOT = PRN("Yaw gear ratio (1 : ?)")/PRN("Types of Yaw PIVOT")
        OFFSET_X = PRN("Turret phy. offset x (m)")
        OFFSET_Y = PRN("Turret phy. offset y (m)")
        OFFSET_Z = PRN("Turret phy. offset z (m)")

        TRD1Exists = INB(1)

        power = INB(2)
        highAngleEnable = INB(4)
        reloadEnable = INB(5)

    end

    inRange = false

    --ピボットのヨーとピッチに変換
    do
        local Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, TurEx, TurEy, TurEz)
        local Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, BodEx, BodEy, BodEz)
        currentPitch, currentYaw = rect2Polar(Lx, Ly, Lz, false)
        currentYaw = currentYaw - STANDBY_YAW
    end

    V0, K, tickDel, WIND_INFLUENCE = parameter[WPN_TYPE][1]/60, parameter[WPN_TYPE][2], parameter[WPN_TYPE][3], parameter[WPN_TYPE][4]

    --オフセット
    TurPx, TurPz, TurPy = local2World(OFFSET_X, OFFSET_Y, OFFSET_Z, TurPx, TurPy, TurPz, BodEx, BodEy, BodEz)

    --自分基準ワールド座標系へ
    TWLx, TWLy, TWLz = Tx - TurPx, Ty - TurPz, Tz - TurPy

    --補足時かつ起動時
    if TRD1Exists and power then

        --ロケットか否か
        isRocket = WPN_TYPE == 8

        --遅れ補正
        TWLx, TWLy, TWLz, Tvx, Tvy, Tvz = predictTRD1(TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz, TRD1_DELAY)
        --ワールド速度
        Wvx, Wvy, Wvz = local2World(BodPvx, BodPvz, BodPvy, 0, 0, 0, BodEx, BodEy, BodEz)
        Wvxy = distance2(Wvx, Wvy)
        Wvxy_direc = math.atan(Wvx, Wvy)
        --風向き変換
        windWv, windWdirec = windLocal2World(windLv, windLdirec, BodPvx, BodPvz, BodEx, BodEy, BodEz)

        --海面高度での風速に変換
        local _, atm = calGravAndAtm(TurPy)
        windWv = windWv/atm
        OUN(22, atm)

        --目標の未来位置の初期値
        tick = math.sqrt(TWLx^2 + TWLy^2 + TWLz)/(V0 + (isRocket and 600 or 0))
        futureX, futureY, futureZ = predictTRD1(TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz, tick)
        
        tickPre = 0     --偏差終了判定に用いる到達時間

        --弾道計算
        --未来偏差イテレーション
        for i = 1, 10 do

            --方位角仮定
            futureXY = distance2(futureX, futureY)
            Azimuth = math.atan(futureX, futureY)

            --yが砲弾前進方向
            goalX = futureXY*math.sin(math.atan(futureX, futureY) - Azimuth)
            goalY = futureXY*math.cos(math.atan(futureX, futureY) - Azimuth)
            goalZ = futureZ

            --曲射解と直射解を解析式で求め、中間値を直射・曲射境界値に
            do
                local function brentsTrajectory(a, b, V0)
                    local c, fa, fb, fc, e
                    fa = calTrajectoryZ(V0, K, a, goalY) - goalZ
                    c, fc = a, fa
                    e = b - a
                    for i = 1, 10 do
                        fb = calTrajectoryZ(V0, K, b, goalY) - goalZ
                        a, b, c, fa, fc, e = brentsMethod(a, b, c, fa, fb, fc, e)
                        if math.abs(b) < (0.1/360)*pi2 then
                            break
                        end
                    end
                    return b
                end

                local V0Border, A

                --曲射/直射境界仰角条件
                V0Border = V0 + (isRocket and 600/60 or 0)
                A = -goalY*g/V0Border
                highAngleBorder = math.acos(K*goalY/math.sqrt(A^2 + V0Border^2)) + math.atan(A, V0Border)

                --直射解
                directTheta = brentsTrajectory(highAngleBorder, math.atan(goalZ, goalY), V0Border)

                --曲射解
                indirectTheta = brentsTrajectory(highAngleBorder, pi2/4 - (0.1/360)*pi2, V0Border)

                --境界条件をより余裕のある値へ(平均)
                highAngleBorder = (directTheta + indirectTheta)/2
            end

            OUN(28, indirectTheta)
            OUN(29, directTheta)

            --仰角仮定
            Elevation = highAngleEnable and indirectTheta or directTheta

            --仰角方位角イテレーション
            for j = 1, 10 do
                Iteration_j = j

                OUN(26, j)
                OUN(27, i)

                --yが砲弾前進方向
                goalX = futureXY*math.sin(math.atan(futureX, futureY) - Azimuth)
                goalY = futureXY*math.cos(math.atan(futureX, futureY) - Azimuth)
                goalZ = futureZ

                --砲弾方向に風とビークル速度を成分分解
                windVx = windWv*math.sin(windWdirec - Azimuth)
                windVy = windWv*math.cos(windWdirec - Azimuth)

                v0X = Wvxy*math.sin(Wvxy_direc - Azimuth)
                v0Y = V0*math.cos(Elevation) + Wvxy*math.cos(Wvxy_direc - Azimuth)
                v0Z = V0*math.sin(Elevation) + Wvz

                --ロケット
                rocketAy = ROCKET_ACL*math.cos(Elevation)
                rocketAz = ROCKET_ACL*math.sin(Elevation)

                --数値積分で厳密解を求める
                if highAngleEnable then --曲射
                    local MAX, G, x, y, z, vX, vY, vZ, stepT, aveAlt, isFalling, isArrived, lastZ, lastVz
                    MAX = math.sqrt(2*ALT_INTERVAL/g)
                    x, y, z = 0, 0, 0
                    vX, vY, vZ = v0X, v0Y, v0Z
                    G = g
                    tick = 0
                    lastZ, lastVz = z, vZ

                    --ロケットの加速
                    if isRocket then
                        tick = 60
                        aveAlt = TurPy + z + (rocketAz - G)*(30^2)/2 + vZ*30
                        G, atm = calGravAndAtm(aveAlt)
                        x, vX = calTrajectoryXV(x, vX, -windVx*atm*WIND_INFLUENCE/60, 60, K)
                        y, vY = calTrajectoryXV(y, vY, rocketAy - windVy*atm*WIND_INFLUENCE/60, 60, K)
                        z, vZ = calTrajectoryXV(z, vZ, rocketAz - G, 60, K)
                        lastZ, lastVz = z, vZ
                    end

                    --数値積分
                    for k = 1, 100 do
                        --垂直方向初速より更新ステップと平均高度を決定
                        stepT = clamp(math.abs(ALT_INTERVAL/vZ), 1, MAX)
                        aveAlt = TurPy + z - G*((stepT/2)^2)/2 + vZ*(stepT/2)

                        --重力加速度と気圧より、加速度を計算
                        G, atm = calGravAndAtm(aveAlt)
                        local ax, ay = -windVx*atm*WIND_INFLUENCE/60, -windVy*atm*WIND_INFLUENCE/60

                        --ステップ後の位置計算
                        z, vZ = calTrajectoryXV(z, vZ, -G, stepT, K)

                        --頂点通過判定
                        isFalling = vZ < 0
                        --目標高度の通過判定
                        isArrived = z < goalZ

                        --目標を通過したら正確な位置とステップ幅を再計算(ニュートン法)
                        if isFalling and isArrived then
                            stepT, z = newtonsMethod(goalZ, lastZ, lastVz, -G, K, stepT/2)
                        end

                        --x, yも計算
                        x, vX = calTrajectoryXV(x, vX, ax, stepT, K)
                        y, vY = calTrajectoryXV(y, vY, ay, stepT, K)
                        tick = tick + stepT

                        if (isFalling and isArrived) or tick > tickDel then
                            break
                        end

                        lastZ, lastVz = z, vZ
                    end
                    
                    OUN(23, x - goalX)
                    OUN(24, y - goalY)
                    OUN(25, z - goalZ)

                    --イテレーション終了
                    if math.abs(goalY - y) < 0.1 and math.abs(x - goalX) < 0.1 then
                        break
                    end

                    --仰角更新
                    if j == 1 then  --ブレント初期値設定
                        aEl, faEl = Elevation, y - goalY
                        if y < goalY then
                            Elevation = highAngleBorder
                        else
                            Elevation = pi2/4
                        end
                        cEl, fcEl = aEl, faEl
                        eEl = Elevation - aEl
                    else            --ブレント更新
                        aEl, Elevation, cEl, faEl, fcEl, eEl = brentsMethod(aEl, Elevation, cEl, faEl, y - goalY, fcEl, eEl)
                    end

                    --方位角更新
                    Azimuth = Azimuth + (math.atan(goalX, goalY) - math.atan(x, y))
                else                    --直射
                    local MAX, G, x, y, z, vX, vY, vZ, stepT, aveAlt, isArrived, lastY, lastVy
                    MAX = math.sqrt(2*ALT_INTERVAL/g)
                    x, y, z = 0, 0, 0
                    vX, vY, vZ = v0X, v0Y, v0Z
                    G = g
                    tick = 0
                    isArrived = false
                    lastY, lastVy = y, vY

                    --ロケットの加速
                    if isRocket then
                        stepT = 60
                        aveAlt = TurPy + z + (rocketAz - G)*(30^2)/2 + vZ*30
                        G, atm = calGravAndAtm(aveAlt)
                        
                        y, vY = calTrajectoryXV(y, vY, rocketAy - windVy*atm*WIND_INFLUENCE/60, stepT, K)
                        
                        --目標y座標の通過判定
                        isArrived = y > goalY

                        --目標を通過したら正確な位置とステップ幅を再計算(ニュートン法)
                        if isArrived then
                            stepT, y = newtonsMethod(goalY, 0, v0Y, rocketAy - windVy*atm*WIND_INFLUENCE/60, K, stepT/2)
                        end
                        x, vX = calTrajectoryXV(x, vX, -windVx*atm*WIND_INFLUENCE/60, stepT, K)
                        z, vZ = calTrajectoryXV(z, vZ, rocketAz - G, stepT, K)
                        tick = stepT
                        lastY, lastVy = y, vY
                    end

                    --数値積分
                    if not isArrived then
                        for k = 1, 100 do
                            --垂直方向初速より更新ステップと平均高度を決定
                            stepT = clamp(math.abs(ALT_INTERVAL/vZ), 1, MAX)
                            aveAlt = TurPy + z - G*((stepT/2)^2)/2 + vZ*(stepT/2)

                            --重力加速度と気圧より、加速度を計算
                            G, atm = calGravAndAtm(aveAlt)
                            local ax, ay = -windVx*atm*WIND_INFLUENCE/60, -windVy*atm*WIND_INFLUENCE/60

                            --ステップ後の位置計算
                            y, vY = calTrajectoryXV(y, vY, ay, stepT, K)

                            --目標高度の通過判定
                            isArrived = y > goalY

                            --目標を通過したら正確な位置とステップ幅を再計算(ニュートン法)
                            if isArrived then
                                stepT, y = newtonsMethod(goalY, lastY, lastVy, ay, K, stepT/2)
                            end

                            --x, zも計算
                            x, vX = calTrajectoryXV(x, vX, ax, stepT, K)
                            z, vZ = calTrajectoryXV(z, vZ, -G, stepT, K)
                            tick = tick + stepT

                            if isArrived or tick > tickDel then
                                break
                            end

                            lastY, lastVy = y, vY
                        end
                    end

                    OUN(23, x - goalX)
                    OUN(24, y - goalY)
                    OUN(25, z - goalZ)

                    --イテレーション終了
                    if math.abs(goalZ - z) < 0.1 and math.abs(x - goalX) < 0.1 then
                        break
                    end

                    --仰角更新
                    if j == 1 then  --ブレント初期値設定
                        aEl, faEl = Elevation, z - goalZ
                        if z >= goalZ then
                            Elevation = math.atan(goalZ, goalY)
                        else
                            Elevation = highAngleBorder
                        end
                        cEl, fcEl = aEl, faEl
                        eEl = Elevation - aEl
                    else            --ブレント更新
                        aEl, Elevation, cEl, faEl, fcEl, eEl = brentsMethod(aEl, Elevation, cEl, faEl, z - goalZ, fcEl, eEl)
                    end

                    --方位角更新
                    Azimuth = Azimuth + (math.atan(goalX, goalY) - math.atan(x, y))
                end
            end

            inRange = tick < tickDel and Iteration_j ~= 10

            --tickより、目標未来位置計算
            futureX, futureY, futureZ = predictTRD1(TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz, tick)
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
        stabiWx, stabiWy, stabiWz = TurPx + INFTY*math.sin(Azimuth), TurPz + INFTY*math.cos(Azimuth), TurPy + INFTY*math.tan(Elevation)
        srabiLx, srabiLy, srabiLz = world2Local(stabiWx, stabiWy, stabiWz, TurPx, TurPy, TurPz, BodEx, BodEy, BodEz)

        --射撃可能判定用の、本来向くべき向き
        targetPitch, targetYaw = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        
        --視線角速度計算
        losX, losY, losZ = losRv(TurPx, TurPy, TurPz, BodEx, BodEy, BodEz, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, Tx, Ty, Tz, Tvx, Tvy, Tvz)

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

    OUN(21, debug1)
end
