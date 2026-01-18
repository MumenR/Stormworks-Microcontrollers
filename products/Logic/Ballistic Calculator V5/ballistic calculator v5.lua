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

    simulator:setProperty("Weapon Type", 1) -- 0: Bertha, 1: Artillery, 2: Battle, 3: Heavy Auto, 4: Rotary Auto, 5: Light Auto, 6: Machine Gun, 7: Rocket Launcher
    simulator:setProperty("standby yaw position (degree)", 0)
    simulator:setProperty("min pitch (degree)", -15)
    simulator:setProperty("max pitch (degree)", 90)
    simulator:setProperty("Pitch Swivel Mode", false)
    simulator:setProperty("min yaw (degree)", -180)
    simulator:setProperty("max yaw (degree)", 180)
    simulator:setProperty("Yaw Swivel Mode", false)
    simulator:setProperty("Pivot rotation speed gain", 1)
    simulator:setProperty("Pitch gear ratio (1 : ?)", 32)
    simulator:setProperty("Types of Pitch PIVOT", 1)
    simulator:setProperty("Yaw gear ratio (1 : ?)", 32)
    simulator:setProperty("Types of Yaw PIVOT", 1)
    simulator:setProperty("Turret phy. offset x (m)", 0)
    simulator:setProperty("Turret phy. offset y (m)", 0)
    simulator:setProperty("Turret phy. offset z (m)", 0)


    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)

        for i = 1, 3 do
           simulator:setInputBool(i, simulator:getIsToggled(i))
           simulator:setInputNumber(i, simulator:getSlider(i)*1000)
        end

        for i = 4, 9 do
           simulator:setInputBool(i, simulator:getIsToggled(i))
           simulator:setInputNumber(i, simulator:getSlider(i))
        end

        --[[
        simulator:setInputNumber(1, 100)
        simulator:setInputNumber(2, 100)
        simulator:setInputNumber(3, 0)
        simulator:setInputNumber(4, 0)
        simulator:setInputNumber(5, 0)
        simulator:setInputNumber(6, 0)
        simulator:setInputNumber(7, 0)
        simulator:setInputNumber(8, 0/60/60)
        simulator:setInputNumber(9, 0)
        ]]

        simulator:setInputNumber(25, 40)
        simulator:setInputNumber(26, simulator:getSlider(10) - 0.5)
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
g = 30/3600
ROCKET_ACL = 600/3600
ROCKET_ACL_TICK = 60
tick = 0
TRD1_DELAY = 0
STABI_DELAY_VELO = 7.45
STABI_DELAY_ROBO = 0.28
P = 8
I = 0
D = 20
ALT_INTERVAL = 500                          --数値積分の高度間隔[m]
MAX_INTERVAL = math.sqrt(240*ALT_INTERVAL)  --数値積分の最大ステップ幅[tick]
MAX_ITERATION_I = 8                        --イテレーション最大回数
ELEVATION_MAX_ERROR = 0.1                   --仰角割線法許容誤差[m]
AZIMUTH_MAX_ERROR = 0.001                   --方位角割線法許容誤差[rad]

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

--関数群
do
    --積(A*B)
    function mul(A, B, C, sum)
        C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #B[1] do
                sum = 0
                for k = 1, #A[1] do
                    sum = sum + A[i][k]*B[k][j]
                end
                C[i][j] = sum
            end
        end
        return C
    end

    function R(Ex, Ey, Ez)
        local a, b, c, d, e, f = math.cos(Ex), math.sin(Ex), math.cos(Ey), math.sin(Ey), math.cos(Ez), math.sin(Ez)
        return {
            {e*c,   e*d*a + f*b,    e*d*b - f*a},
            {-d,    c*a,            c*b},
            {f*c,   f*d*a - e*b,    f*d*b + e*a}
        }
    end

    --ローカル座標からワールド座標へ変換(Physics sensor使用)
    function local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
        local W = mul(R(Ex, Ey, Ez), {{Lx}, {Ly}, {Lz}})
        return W[1][1] + Px, W[2][1] + Pz, W[3][1] + Py
    end

    --ワールド座標からローカル座標へ変換(Physics sensor使用)
    function world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
        local L = mul({{Wx - Px, Wy - Pz, Wz - Py}}, R(Ex, Ey, Ez))
        return L[1][1], L[1][2], L[1][3]
    end

    --高度による重力加速度を求める(return g [m/tick^2])
    function calGrav(h)
        return 30*math.exp(-1/60*h/1000)/3600
    end

    --高度による気圧を求める(return atm)
    function calAtm(h)
        return h >= 40000 and 0 or (((44.33 - h/1000)/11.89)^5.256)/1013
    end

    --減衰あり等加速度直線運動で時間から位置と速度を求める
    --V0: 初速, a: 加速度, t: 時間, K:抵抗値
    function calTrajectoryXV(x0, V0, a, t, exp)
        return ((V0 - a/K)*(1 - exp) + a*t)/K + x0, (V0 - a/K)*exp + a/K
    end

    --オイラー法で数値積分(h: ステップ幅, s: {x, y, z, vx, vy, vz, ax, ay, az})
    --return h, s
    function eulerTrajectory(h, s)
        --debug1 = debug1 + 1
        local exp, z, g, atm, ax, ay, az
        local sNew = {}
        exp = math.exp(-K*h)
        z = calTrajectoryXV(s[3], s[6], s[9], h/2, math.exp(-K*h/2))
        g, atm = calGrav(z), calAtm(z)
        ax = s[7] - windVx*atm*WIND_INFLUENCE/60
        ay = s[8] - windVy*atm*WIND_INFLUENCE/60
        az = s[9] - g
        sNew[1], sNew[4] = calTrajectoryXV(s[1], s[4], ax, h, exp)
        sNew[2], sNew[5] = calTrajectoryXV(s[2], s[5], ay, h, exp)
        sNew[3], sNew[6] = calTrajectoryXV(s[3], s[6], az, h, exp)
        sNew[7], sNew[8], sNew[9] = s[7], s[8], s[9]
        h = clamp(ALT_INTERVAL/math.abs(sNew[6]), 30, MAX_INTERVAL)
        return h, sNew
    end

    --ブレント法(b:最良, a:bと逆符号, f:評価に使う関数, times:最大ループ回数, error:許容誤差)
    --return: b
    function brentsMethod(a, b, fa, fb, f, times, error)
        local c, fc, e, d, alpha, beta, p, q, r
        c, fc = a, fa
        e = b - a
        d = e
        for i = 1, times do
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
            fb = f(b)

            --評価、更新
            if math.abs(fb) < error or i == times then
                return b
            end
        end
    end

    --割線法更新
    function secantMethod(x, xLast, f, fLast, MAX_ERROR)
        local det = f - fLast
        if math.abs(f) > math.abs(fLast)*1.1 then --誤差が増加したら更新量を半分に
            xNew = (xLast + x)/2
        elseif (math.abs(det) < MAX_ERROR*0.1 or x == xLast) and math.abs(f) > MAX_ERROR then
            xNew = x + 0.001
        elseif math.abs(f) < MAX_ERROR then
            xNew = x
        else
            xNew = x - f*(x - xLast)/det
        end
        return xNew
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

    --2次元距離計算
    function distance2(x, y)
        return math.sqrt(x*x + y*y)
    end

    function clamp(x, min, max)
        if x >= max then
            x = max
        elseif x <= min then
            x = min
        end
        return x
    end

    --未来位置予測(return: x, y, z, vx, vy, vz, ax, ay, az)
    function predictTRD1(t, x, y, z, vx, vy, vz, ax, ay, az)
        return ax*t*t/2 + vx*t + x, ay*t*t/2 + vy*t + y, az*t*t/2 + vz*t + z, ax*t + vx, ay*t + vy, az*t + vz, ax, ay, az
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
            abs_vector = math.sqrt(x*x + y*y + z*z)
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
        T2 = TLx*TLx + TLy*TLy + TLz*TLz
        --標的の角速度を求め、自身の角速度と合成
        return -(TLy*Vrz - TLz*Vry)/T2 - PLrvx, -(TLz*Vrx - TLx*Vrz)/T2 - PLrvy, -(TLx*Vry - TLy*Vrx)/T2 - PLrvz
    end

    --ローカル座標からローカル極座標へ変換(return pitch, yaw)
    function rect2Polar(x, y, z, radian_bool)
        local pitch, yaw
        pitch = math.atan(z, math.sqrt(x*x + y*y))
        yaw = math.atan(x, y)
        if radian_bool then
            return pitch, yaw
        else
            return pitch/(pi2), yaw/(pi2)
        end
    end

    --砲弾方向基準をY方向とした座標系に変換
    function world2BallisticLocal(Wx, Wy, Wz, Azimuth)
        local BLxy = distance2(Wx, Wy)
        return BLxy*math.sin(math.atan(Wx, Wy) - Azimuth), BLxy*math.cos(math.atan(Wx, Wy) - Azimuth), Wz
    end
end

function onTick()
    --debug1 = 0

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

        DEGREE = " (degree)"
        WPN_TYPE = PRN("Weapon Type") + 1
        STANDBY_YAW = PRN("standby yaw position"..DEGREE)/360
        MIN_PITCH = PRN("min pitch"..DEGREE)/360
        MAX_PITCH = PRN("max pitch"..DEGREE)/360
        PITCH_LIMIT_ENABLE = PRB("Pitch Swivel Mode")
        MIN_YAW = PRN("min yaw"..DEGREE)/360
        MAX_YAW = PRN("max yaw"..DEGREE)/360
        YAW_LIMIT_ENABLE = PRB("Yaw Swivel Mode")
        MAX_SPEED_GAIN = PRN("Pivot rotation speed gain")
        PITCH_PIVOT = PRN("Pitch gear ratio (1 : ?)")/PRN("Types of Pitch PIVOT")   --gear/pivot
        YAW_PIVOT = PRN("Yaw gear ratio (1 : ?)")/PRN("Types of Yaw PIVOT")
        TEXT = "Turret phy. offset "
        PHY_OFFSET_X = PRN(TEXT.."x (m)")
        PHY_OFFSET_Y = PRN(TEXT.."y (m)")
        PHY_OFFSET_Z = PRN(TEXT.."z (m)")
        TEXT = "Muzzle offset "
        MUZ_OFFSET_X = PRN(TEXT.."x (m)")
        MUZ_OFFSET_Y = PRN(TEXT.."y (m)")
        MUZ_OFFSET_Z = PRN(TEXT.."z (m)")

        TRD1Exists = INB(1)

        power = INB(2)
        highAngleEnable = INB(4)
        reloadEnable = INB(5)

    end

    inRange = false

    --ピボットのヨーとピッチに変換
    do
        Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, TurEx, TurEy, TurEz)
        Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, BodEx, BodEy, BodEz)
        currentPitch, currentYaw = rect2Polar(Lx, Ly, Lz, false)
        currentYaw = currentYaw - STANDBY_YAW
    end

    --補足時かつ起動時
    if TRD1Exists and power then

        V0, K, tickDel, WIND_INFLUENCE = parameter[WPN_TYPE][1]/60, parameter[WPN_TYPE][2], parameter[WPN_TYPE][3], parameter[WPN_TYPE][4]
        isRocket = WPN_TYPE == 8

        --オフセット
        TurPx, TurPz, TurPy = local2World(PHY_OFFSET_X, PHY_OFFSET_Y, PHY_OFFSET_Z, TurPx, TurPy, TurPz, BodEx, BodEy, BodEz)

        --自分基準ワールド座標系へ
        TWLx, TWLy, TWLz = Tx - TurPx, Ty - TurPz, Tz - TurPy

        --遅れ補正
        TWLx, TWLy, TWLz, Tvx, Tvy, Tvz = predictTRD1(TRD1_DELAY, TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz)

        --ビークル速度
        Wvx, Wvy, Wvz = local2World(BodPvx, BodPvz, BodPvy, 0, 0, 0, BodEx, BodEy, BodEz)
        Wvxy = distance2(Wvx, Wvy)
        WvxyDirec = math.atan(Wvx, Wvy)

        --海面高度でのワールド風速に変換
        windWv, windWdirec = windLocal2World(windLv, windLdirec, BodPvx, BodPvz, BodEx, BodEy, BodEz)
        g, atm = calGrav(TurPy), calAtm(TurPy)
        windWv = windWv/atm

        --仰角、方位角の初期値設定
        do
            --到達時間の初期値
            tick = math.sqrt(TWLx*TWLx + TWLy*TWLy + TWLz*TWLz)/(V0 + (isRocket and 600 or 0))

            --方位角仮定
            futureX, futureY, futureZ = predictTRD1(tick, TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz)
            Azimuth = math.atan(futureX, futureY)
            goalX, goalY, goalZ = world2BallisticLocal(TWLx, TWLy, TWLz, Azimuth)

            --曲射解と直射解を解析式で求め、中間値を直射・曲射境界値に
            do
                local V0Border, A

                --曲射/直射境界仰角条件
                V0Border = V0 + (isRocket and 600/60 or 0)
                A = -goalY*g/V0Border
                highAngleBorder = math.acos(K*goalY/math.sqrt(A*A + V0Border*V0Border)) + math.atan(A, V0Border)

                --仰角からgolaYの時のzを求める(風なし)
                function brentsFunc(b)
                    return goalY*(V0Border*math.sin(b) + g/K)/V0Border/math.cos(b) + g*math.log(1 - K*goalY/V0Border/math.cos(b))/(K*K) - goalZ
                end

                --直射解
                directTheta = brentsMethod(highAngleBorder, math.atan(goalZ, goalY), brentsFunc(highAngleBorder), brentsFunc(math.atan(goalZ, goalY)), brentsFunc, 10, (0.1/360)*pi2)

                --曲射解
                indirectTheta = brentsMethod(highAngleBorder, math.acos(K*goalY/V0Border) - 0.001, brentsFunc(highAngleBorder), brentsFunc(math.acos(K*goalY/V0Border) - 0.001), brentsFunc, 10, (0.1/360)*pi2)

                --境界条件をより余裕のある値へ(平均)
                highAngleBorder = (directTheta + indirectTheta)/2
            end

            --仰角仮定
            Elevation = highAngleEnable and indirectTheta or directTheta
        end

        IndexI = 0

        --イテレーション
        for j = 1, MAX_ITERATION_I do
            lastIndexJ = j
            for i = 1, MAX_ITERATION_I do
                IndexI = IndexI + 1

                --ターゲット座標(砲弾方向基準ローカル座標系)
                TGTx, TGTy, TGTz = world2BallisticLocal(TWLx, TWLy, TWLz, Azimuth)
                TGTvx, TGTvy, TGTvz = world2BallisticLocal(Tvx, Tvy, Tvz, Azimuth)
                TGTax, TGTay, TGTaz = world2BallisticLocal(Tax, Tay, Taz, Azimuth)
                TGT0 = {TGTx, TGTy, TGTz, TGTvx, TGTvy, TGTvz, TGTax, TGTay, TGTaz}
                TGT = {table.unpack(TGT0)}
                TGTLast = {table.unpack(TGT0)}

                --砲弾方向に風とビークル速度を成分分解
                windVx = windWv*math.sin(windWdirec - Azimuth)
                windVy = windWv*math.cos(windWdirec - Azimuth)

                --ビークル速度を加算した砲弾初速を計算
                v0X = Wvxy*math.sin(WvxyDirec - Azimuth)
                v0Y = V0*math.cos(Elevation) + Wvxy*math.cos(WvxyDirec - Azimuth)
                v0Z = V0*math.sin(Elevation) + Wvz

                --数値積分初期値
                g, atm = calGrav(TurPy), calAtm(TurPy)
                s = {MUZ_OFFSET_X, MUZ_OFFSET_Y, MUZ_OFFSET_Z, v0X, v0Y, v0Z, 0, 0, 0}

                --ロケット
                rocketAy = ROCKET_ACL*math.cos(Elevation)
                rocketAz = ROCKET_ACL*math.sin(Elevation)

                local h, sLast = 60, s
                tick = 0    --発射からの経過時間

                isArrived = false

                --ロケットの加速
                if isRocket then
                    s[8] = rocketAy
                    s[9] = rocketAz
                    local function brentsFunc(b)
                        TGT = {predictTRD1(b, table.unpack(TGT0))}
                        local fh, fs = eulerTrajectory(b, sLast)
                        return fs[2] - TGT[2], fh, fs
                    end

                    fb, h, s = brentsFunc(60)
                    TGT = {predictTRD1(60, table.unpack(TGT0))}
                    
                    --目標y座標の通過判定
                    isArrived = fb > 0 and not highAngleEnable

                    --目標を通過したら正確な位置とステップ幅を再計算
                    if isArrived then
                        h = brentsMethod(0, 60, -TGT0[2], fb, brentsFunc, 10, 0.01)
                        _, h, s = brentsFunc(h)
                    end

                    s[8] = 0
                    s[9] = 0
                    tick, sLast = h, s
                    TGTLast = {table.unpack(TGT)}
                end

                --数値積分
                for k = 1, 40 do
                    --終了条件
                    if isArrived or tick > tickDel then
                        break
                    end

                    --更新
                    TGT = {predictTRD1(tick + h, table.unpack(TGT0))}
                    hNew, s = eulerTrajectory(h, s)

                    function brentsFunc(b)
                        TGT = {predictTRD1(tick + b, table.unpack(TGT0))}
                        _, s = eulerTrajectory(b, sLast)
                        return highAngleEnable and (s[3] - TGT[3]) or (s[2] - TGT[2])
                    end

                    --目標を通過したら正確な位置とステップ幅を再計算(ブレント法)
                    if highAngleEnable and s[3] < TGT[3] and s[6] < 0 then   --曲射

                        h = brentsMethod(0, h, sLast[3] - TGTLast[3], s[3] - TGT[3], brentsFunc, 10, 0.01)
                        _, s = eulerTrajectory(h, sLast)

                        isArrived = true
                    elseif not highAngleEnable and s[2] > TGT[2] then        --直射

                        h = brentsMethod(0, h, sLast[2] - TGTLast[2], s[2] - TGT[2], brentsFunc, 10, 0.01)
                        _, s = eulerTrajectory(h, sLast)

                        isArrived = true
                    end

                    tick = tick + h
                    h = hNew
                    sLast = {table.unpack(s)}
                    TGTLast = {table.unpack(TGT)}
                end

                --[[
                OUN(23, s[1] - TGT[1])
                OUN(24, s[2] - TGT[2])
                OUN(25, s[3] - TGT[3])
                ]]

                --仰角更新(割線法)
                do
                    local ElevationMin, ElevationMax = highAngleEnable and highAngleBorder or -pi2/4, highAngleEnable and (pi2/2 - highAngleBorder) or highAngleBorder

                    fEle = highAngleEnable and (TGT[2] - s[2]) or (TGT[3] - s[3]) --誤差

                    --イテレーション終了条件
                    if math.abs(fEle) < ELEVATION_MAX_ERROR then
                        break
                    end

                    if i == 1 then  --初期更新は幾何的に
                        if highAngleEnable then
                            if fEle > 0 then
                                newElevation = (Elevation + ElevationMin)/2
                            else
                                newElevation = pi2/4 - (TGT[2]/s[2])*(pi2/4 - Elevation)
                            end
                        else
                            newElevation = Elevation + math.atan(TGT[3], TGT[2]) - math.atan(s[3], s[2])
                        end
                    else            --２回目以降の更新は割線法
                        newElevation = secantMethod(Elevation, xEleLast, fEle, fEleLast, ELEVATION_MAX_ERROR)
                    end

                    xEleLast = Elevation
                    fEleLast = fEle
                    Elevation = clamp(newElevation, ElevationMin, ElevationMax)
                end
            end

            --方位角更新(割線法)
            do
                fAzi = math.atan(TGT[1], TGT[2]) - math.atan(s[1], s[2])
                xNorm = math.abs(TGT[1] - s[1])

                --イテレーション終了条件
                if math.abs(fAzi) < AZIMUTH_MAX_ERROR then
                    break
                end

                if j == 1 then
                    newAzimuth = Azimuth + math.atan(TGT[1], TGT[2]) - math.atan(s[1], s[2])
                else
                    newAzimuth = secantMethod(Azimuth, xAziLast, fAzi, fAziLast, AZIMUTH_MAX_ERROR)
                end

                xAziLast = Azimuth
                fAziLast = fAzi
                Azimuth = newAzimuth
            end
        end

        --射程内判定
        inRange = tick < tickDel and fAzi < AZIMUTH_MAX_ERROR and math.abs(fEle) < ELEVATION_MAX_ERROR

        OUN(21, IndexI)
        OUN(22, lastIndexJ)
    else
        Azimuth, Elevation = 0, 0
        rotation_speed_pitch, rotation_speed_yaw = 0, 0
    end

    --スタビライザー
    if inRange then
        --向くべき座標計算
        stabiWx, stabiWy, stabiWz = TurPx + INFTY*math.cos(Elevation)*math.sin(Azimuth), TurPz + INFTY*math.cos(Elevation)*math.cos(Azimuth), TurPy + INFTY*math.sin(Elevation)
        srabiLx, srabiLy, srabiLz = world2Local(stabiWx, stabiWy, stabiWz, TurPx, TurPy, TurPz, BodEx, BodEy, BodEz)

        --射撃可能判定用の、本来向くべき向き
        targetPitch, targetYaw = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        
        --視線角速度計算
        losX, losY, losZ = losRv(TurPx, TurPy, TurPz, BodEx, BodEy, BodEz, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, Tx, Ty, Tz, Tvx, Tvy, Tvz)

        --向くべき未来位置計算(速度ピボット)
        srabiLx, srabiLy, srabiLz = stabiFutureAngle(srabiLx, srabiLy, srabiLz, losX, losY, losZ, STABI_DELAY_VELO)
        stabiPitch, stabiYaw = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        stabiYaw = same_rotation(stabiYaw - STANDBY_YAW)

        --向くべき未来位置計算(ロボティックピボット)
        srabiLx, srabiLy, srabiLz = stabiFutureAngle(srabiLx, srabiLy, srabiLz, losX, losY, losZ, -PITCH_PIVOT*STABI_DELAY_ROBO)
        roboticPitch, _ = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        srabiLx, srabiLy, srabiLz = stabiFutureAngle(srabiLx, srabiLy, srabiLz, losX, losY, losZ, -YAW_PIVOT*STABI_DELAY_ROBO)
        _, roboticYaw = rect2Polar(srabiLx, srabiLy, srabiLz, false)
        roboticYaw = same_rotation(roboticYaw - STANDBY_YAW)

        if reloadEnable then
            stabiPitch = 0
            roboticPitch = 0
        end
    else
        stabiPitch, stabiYaw = 0, 0
        roboticPitch, roboticYaw = 0, 0
        srabiLx, srabiLy, srabiLz = 0, 1, 0
        targetPitch, targetYaw = 0, 0
        tick = 0
    end

    --射撃可能判定
    do
        currentInFOV = same_rotation(currentYaw) > MIN_YAW and same_rotation(currentYaw) < MAX_YAW and currentPitch > MIN_PITCH and currentPitch < MAX_PITCH
        targetInFOVPitch = math.sin(targetPitch) > math.sin(MIN_PITCH) and math.sin(targetPitch) < math.sin(MAX_PITCH)
        targetInFOVYaw = targetYaw > MIN_YAW and targetYaw < MAX_YAW
        pitchError = math.abs(same_rotation(targetPitch - currentPitch))*360
        yawError = math.abs(same_rotation(targetYaw - STANDBY_YAW - currentYaw))*360
        inError = pitchError < PIVOT_MAX_ERROR and yawError < PIVOT_MAX_ERROR
        shootable = inRange and inError and currentInFOV and targetInFOVPitch and targetInFOVYaw and not reloadEnable
    end

    --駆動系
    do
        --fov外処理
        if not targetInFOVPitch and PITCH_LIMIT_ENABLE then
            stabiPitch = 0
        end
        if not targetInFOVYaw and YAW_LIMIT_ENABLE then
            stabiYaw = 0
        end

        --差分へ
        pitchDiff = stabiPitch - currentPitch
        yawDiff = YAW_LIMIT_ENABLE and (stabiYaw - currentYaw) or same_rotation(stabiYaw - currentYaw)

        --PID
        pitch, pitchErrorSum, pitchErrorPre = PID(P, I, D, 0, -pitchDiff*PITCH_PIVOT, pitchErrorSum, pitchErrorPre, -PITCH_PIVOT*MAX_SPEED_GAIN, PITCH_PIVOT*MAX_SPEED_GAIN)
        yaw, yawErrorSum, yawErrorPre = PID(P, I, D, 0, -yawDiff*YAW_PIVOT, yawErrorSum, yawErrorPre, -YAW_PIVOT*MAX_SPEED_GAIN, YAW_PIVOT*MAX_SPEED_GAIN)

        --ピッチ角制限
        if PITCH_LIMIT_ENABLE then
            pitch = limit_rotation(pitch, same_rotation(currentPitch), MIN_PITCH, MAX_PITCH)
        end
        --ヨー角制限
        if YAW_LIMIT_ENABLE then
            yaw = limit_rotation(yaw, same_rotation(currentYaw), MIN_YAW, MAX_YAW)
        end

        --ロボティックピボットの場合
        if PITCH_PIVOT < 0 then
            pitch = PITCH_LIMIT_ENABLE and clamp(roboticPitch, MIN_PITCH, MAX_PITCH)*4 or roboticPitch*4
        end
        if YAW_PIVOT < 0 then
            yaw = YAW_LIMIT_ENABLE and clamp(roboticYaw, MIN_YAW, MAX_YAW)*4 or roboticYaw*4
        end

        --ゼロ除算対策
        pitch = (pitch ~= pitch) and 0 or pitch
        yaw = (yaw ~= yaw) and 0 or yaw
    end

    OUN(1, pitch)
    OUN(2, yaw)
    OUB(1, shootable)

    OUN(3, pitchError)
    OUN(4, yawError)

    OUN(30, tick)
    OUN(31, Elevation)
    OUN(32, Azimuth)

    --OUN(21, debug1)
end
