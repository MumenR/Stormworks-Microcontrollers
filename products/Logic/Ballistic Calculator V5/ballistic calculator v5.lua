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

    simulator:setProperty("Weapon Type", 7) -- 0: Bertha, 1: Artillery, 2: Battle, 3: Heavy Auto, 4: Rotary Auto, 5: Light Auto, 6: Machine Gun, 7: Rocket Launcher
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
STABI_DELAY_VELO = 7.5
STABI_DELAY_ROBO = 0.28
STABI_P = 8
STABI_I = 0
STABI_D = 15
ERROR_P = 1
ERROR_I = 0.1
ERROR_D = 1
ALT_INTERVAL = 2000                         --数値積分の高度間隔[m]
MIN_INTERVAL = 60*(ALT_INTERVAL/1000)       --数値積分の最小ステップ幅[tick]
MAX_INTERVAL = math.sqrt(240*ALT_INTERVAL)  --数値積分の最大ステップ幅[tick]
MAX_EULER = math.floor(3600/MIN_INTERVAL)   --数値積分最大回数
MAX_ITERATION_I = 8                         --イテレーション最大回数
ELEVATION_MAX_ERROR = 0.1                   --仰角割線法許容誤差[m]
AZIMUTH_MAX_ERROR = 0.1                     --方位角(弧の長さ)割線法許容誤差[m]

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
    {50, 0.003, 3600, 0.125},   --Rocket Launcher
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

    --割線ブレント法更新(func:関数, b, fb, a, fa:初期のxとf(x), times: 更新回数, MAX_ERROR: 許容誤差)
    function secantBrentsMethod(func, b, fb, a, fa, times, MAX_ERROR)
        local faAbs, fbAbs, c, fc, fcAbs, e, d, alpha, beta, p, q, r, brentsMode
        faAbs = fa > 0 and fa or -fa
        c, fc, fcAbs = a, fa, faAbs
        e = b - a
        d = e
        
        brentsMode = false

        for i = 1, times do
            fbAbs = fb > 0 and fb or -fb

            if fb*fa < 0 then brentsMode = true end     --fとfLastが符号を跨いでいたらブレント法を有効化

            if fbAbs < MAX_ERROR then
                return b, fbAbs, i
            end

            if fa*fb > 0 then                           --a, bが同符号の場合入れ替え
                a, fa, faAbs = c, fc, fcAbs
                d = b - c
                e = d
            end
            if faAbs < fbAbs then                       --bの時が解に近くなるようにbとaを入れ替え
                a, b, c = b, c, b
                fa, fb, fc = fb, fc, fb
                faAbs, fbAbs, fcAbs = fbAbs, fcAbs, fbAbs
            end

            if brentsMode then
                alpha = (a - b)/2
                beta = fb/fc

                if fcAbs < fbAbs then                   --二分法
                    d, e = alpha, alpha
                else
                    if a == c then                      --線形補間
                        p = 2*alpha*beta
                        q = 1 - beta
                    else                                --逆二次補完
                        q = fc/fa
                        r = fb/fa
                        p = beta*(2*alpha*q*(q - r) - (b - c)*(r - 1))
                        q = (q - 1)*(r - 1)*(beta - 1)
                    end

                    beta, e = e, d
                    aq3 = 3*alpha*q

                    if 2*(p > 0 and p or -p) < (aq3 > 0 and aq3 or -aq3) then
                        d = -p/q
                    else                                --二分法
                        d, e = alpha, alpha
                    end
                end

                c, fc, fcAbs =b, fb, fbAbs
                b = b + d
            else
                diff = fb - fa
                --次のxを決定
                if fbAbs > fcAbs*1.1 then --誤差が増加したら更新量を半分に
                    xNew = (c + b)/2
                elseif ((diff > 0 and diff or -diff) < MAX_ERROR*0.1 or b == c) and fbAbs > MAX_ERROR then   --更新量が小さすぎるときは更新量を増やす
                    xNew = b + 0.001
                else                        --#通常の割線法
                    xNew = b - fb*(b - a)/diff
                end

                --更新
                fc, c, fcAbs = fb, b, fbAbs
                b = xNew
            end
            fb = func(b)
        end
        return b, fbAbs, times
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

    --未来位置予測(return: x, y, z, vx, vy, vz)
    function predictTRD1(t, x, y, z, vx, vy, vz, ax, ay, az)
        return ax*t*t/2 + vx*t + x, ay*t*t/2 + vy*t + y, az*t*t/2 + vz*t + z, ax*t + vx, ay*t + vy, az*t + vz
    end

    stabiPitchEP, stabiPitchES = 0, 0
    stabiYawEP, stabiYawES = 0, 0
    pitchES, pitchEP = 0, 0
    yawES, yawEP = 0, 0

    --PID制御
    function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
        local error, errorSum, errorDiff, control
        error = target - current
        errorSum = clamp(errorSumPre + error, -1, 1)
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

    --(return: futurePitch, futureYaw)
    --Prv[rad/tick], Tは視線角速度観測用のターゲット位置と速度, losは向くべき方向
    function stabilizer(Px, Py, Pz, Ex, Ey, Ez, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, losWx, losWy, losWz, DELAY)
        local TLx, TLy, TLz, TLvx, TLvy, TLvz, Lrvx, Lrvy, Lrvz, losRvx, losRvy, losRvz, Vrx, Vry, Vrz, T2, absRv, cos, sin, dot, losFutureX, losFutureY, losFutureZ, losLx, losLy, losLz
        --ローカル座標
        TLx, TLy, TLz = world2Local(Tx, Ty, Tz, Px, Py, Pz, Ex, Ey, Ez)
        TLvx, TLvy, TLvz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Ex, Ey, Ez)
        Lrvx, Lrvy, Lrvz = world2Local(Prvx, Prvz, Prvy, 0, 0, 0, Ex, Ey, Ez)
        losLx, losLy, losLz = world2Local(losWx, losWy, losWz, Px, Py, Pz, Ex, Ey, Ez)
        --相対速度
        Vrx, Vry, Vrz = TLvx - Pvx, TLvy - Pvz, TLvz - Pvy
        --視線角速度
        T2 = TLx*TLx + TLy*TLy + TLz*TLz
        losRvx = (TLy*Vrz - TLz*Vry)/T2 - (-Lrvx)
        losRvy = (TLz*Vrx - TLx*Vrz)/T2 - (-Lrvy)
        losRvz = (TLx*Vry - TLy*Vrx)/T2 - (-Lrvz)
        --t[tick]後の未来位置へ(ロドリゲスの公式)
        absRv = math.sqrt(losRvx*losRvx + losRvy*losRvy + losRvz*losRvz)
        cos = math.cos(absRv*DELAY)
        sin = math.sin(absRv*DELAY)/absRv
        dot = (losRvx*losLx + losRvy*losLy + losRvz*losLz)*(1 - cos)/absRv/absRv
        losFutureX = cos*losLx + sin*(losRvy*losLz - losRvz*losLy) + dot*losRvx
        losFutureY = cos*losLy + sin*(losRvz*losLx - losRvx*losLz) + dot*losRvy
        losFutureZ = cos*losLz + sin*(losRvx*losLy - losRvy*losLx) + dot*losRvz
        return rect2Polar(losFutureX, losFutureY, losFutureZ, false)
    end

    --ローカル座標からローカル極座標へ変換(return pitch, yaw)
    function rect2Polar(x, y, z, radian_bool)
        local pitch, yaw
        pitch = math.atan(z, math.sqrt(x*x + y*y))
        yaw = math.atan(x, y)
        if radian_bool then
            return pitch, yaw
        else
            return pitch/pi2, yaw/pi2
        end
    end

    --砲弾方向基準をY方向とした座標系に変換
    function world2BallisticLocal(Wx, Wy, Wz, Azimuth)
        local BLxy, theta = distance2(Wx, Wy), math.atan(Wx, Wy) - Azimuth
        return BLxy*math.sin(theta), BLxy*math.cos(theta), Wz
    end

    --tickからtick + tまで数値積分し、tickによる誤差を返す
    function secantEuler(t)
        local exp, z2, atmCoef, t2, t3
        --標的未来位置を計算
        t2 = tick + t
        t3 = t2*t2/2
        TGTx = TGT0ax*t3 + TGT0vx*t2 + TGT0x
        TGTy = TGT0ay*t3 + TGT0vy*t2 + TGT0y
        TGTz = TGT0az*t3 + TGT0vz*t2 + TGT0z

        --数値積分
        exp = math.exp(-K*t)
        z2 = (vzLast - azLast/K)*(K*t - 1 + exp)/K/K/t + azLast*t/2/K + zLast + TurPy   --平均高度
        --atmCoef = WIND_INFLUENCE*(((44.33 - z2/1000)/11.89)^5.256)/60780                --風影響係数
        atmCoef = WIND_INFLUENCE*(((44.20 - z2/1000)/11.89)^5.256)/60780                --風影響係数
        g = math.exp(-z2/60000)/120
        --加速度計算
        ax = -windVx*atmCoef
        ay = ayRocket - windVy*atmCoef
        az = azRocket - g
        --更新(減衰あり等加速度直線運動)
        x, vx = ((vxLast - ax/K)*(1 - exp) + ax*t)/K + xLast, (vxLast - ax/K)*exp + ax/K
        y, vy = ((vyLast - ay/K)*(1 - exp) + ay*t)/K + yLast, (vyLast - ay/K)*exp + ay/K
        z, vz = ((vzLast - az/K)*(1 - exp) + az*t)/K + zLast, (vzLast - az/K)*exp + az/K
        --ステップ幅にclamp
        hNew = ALT_INTERVAL/(vz < 0 and -vz or vz)
        hNew = hNew > MAX_INTERVAL and MAX_INTERVAL or hNew
        hNew = hNew < MIN_INTERVAL and MIN_INTERVAL or hNew

        f = highAngleEnable and (TGTz - z) or (y - TGTy)        --着弾誤差
        isArrived = f > 0 and (not highAngleEnable or vz < 0)   --着弾判定
        return f, isArrived
    end

    --仰角時指定時の誤差を返す
    function secantElevation(El)

        --ターゲット座標(砲弾方向基準ローカル座標系)
        TGT0x, TGT0y, TGT0z = world2BallisticLocal(TWLx, TWLy, TWLz, Azim)
        TGT0vx, TGT0vy, TGT0vz = world2BallisticLocal(Tvx, Tvy, Tvz, Azim)
        TGT0ax, TGT0ay, TGT0az = world2BallisticLocal(Tax, Tay, Taz, Azim)

        --砲弾方向に風とビークル速度を成分分解
        windVx = windWv*math.sin(windWdirec - Azim)
        windVy = windWv*math.cos(windWdirec - Azim)

        --数値積分初期値
        g = math.exp(-TurPy/60000)/120
        x, y, z = MUZ_OFFSET_X, MUZ_OFFSET_YZ*math.cos(MUZ_OFFSET_YZ_ANGLE + El), MUZ_OFFSET_YZ*math.sin(MUZ_OFFSET_YZ_ANGLE + El)
        --ビークル速度を加算した砲弾初速
        vx, vy, vz = Wvxy*math.sin(WvxyDirec - Azim), V0*math.cos(El) + Wvxy*math.cos(WvxyDirec - Azim), V0*math.sin(El) + Wvz

        local h = 60    --数値積分のステップ幅
        tick = 0        --発射からの経過時間
        xLast, yLast, zLast, vxLast, vyLast, vzLast = x, y, z, vx, vy, vz
        azLast = -g
        ayRocket, azRocket = 0, 0
        fLast = -INFTY
        isArrived = false

        --ロケットの加速
        if isRocket then
            ayRocket = ROCKET_ACL*math.cos(El)
            azRocket = ROCKET_ACL*math.sin(El)
            azLast = -g + azRocket

            f, isArrived = secantEuler(h)

            --目標を通過したら正確な位置とステップ幅を再計算(活線法)
            if isArrived then
                tick, _, nIter = secantBrentsMethod(secantEuler, h, f, 0, (highAngleEnable and TGT0y or TGT0z), 10, 0.01)
                --OUN(20, nIter)  --デバッグ用

                return highAngleEnable and (TGTy - y) or (TGTz - z)
            end

            fLast = f
            tick = tick + h
            h = hNew
            ayRocket, azRocket = 0, 0   --加速終了
            xLast, yLast, zLast, vxLast, vyLast, vzLast = x, y, z, vx, vy, vz
            azLast = -g
        end

        --デバッグ用
        nIter = 0

        --数値積分
        for k = 1, MAX_EULER do
            --終了条件
            if tick > tickDel then
                break
            end

            --OUN(19, k)  --デバッグ用

            --更新
            f, isArrived = secantEuler(h)

            --目標を通過したら正確な位置とステップ幅を再計算(活線法)
            if isArrived then
                h, _, nIter = secantBrentsMethod(secantEuler, h, f, 0, fLast, 10, 0.01)
                tick = tick + h
                
                --OUN(20, nIter)  --デバッグ用

                break
            end

            fLast = f
            tick = tick + h
            h = hNew
            xLast, yLast, zLast, vxLast, vyLast, vzLast = x, y, z, vx, vy, vz
            azLast = az
        end

        return highAngleEnable and (TGTy - y) or (TGTz - z)   --仰角誤差
    end

    --方位角指定時の誤差を返す
    function secantAzimuth(Az)
        Azim = Az
        --仰角更新(割線法)
        fElevation = secantElevation(Elevation)

        --初期更新はちょとだけ
        newElevation = Elevation + 0.001
        newfElevation = secantElevation(newElevation)

        Elevation, ElevationError, nIter = secantBrentsMethod(secantElevation, newElevation, newfElevation, Elevation, fElevation, MAX_ITERATION_I, ELEVATION_MAX_ERROR)

        --OUN(21, nIter)  --デバッグ用

        return TGTx - x
    end

end

function onTick()
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
        STANDBY_PITCH = PRN("standby pitch position"..DEGREE)/360
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
        stabiEnable = PRB("Pivot Control")
        MANUAL_P = PRN("manual P")
        MANUAL_I = PRN("manual I")
        MANUAL_D = PRN("manual D")
        TEXT = "Turret phy. offset "
        PHY_OFFSET_X = PRN(TEXT.."x (m)")
        PHY_OFFSET_Y = PRN(TEXT.."y (m)")
        PHY_OFFSET_Z = PRN(TEXT.."z (m)")
        TEXT = "Muzzle offset "
        MUZ_OFFSET_X = PRN(TEXT.."x (m)")
        MUZ_OFFSET_Y = PRN(TEXT.."y (m)")
        MUZ_OFFSET_Z = PRN(TEXT.."z (m)")
        MUZ_OFFSET_YZ = distance2(MUZ_OFFSET_Y, MUZ_OFFSET_Z)
        MUZ_OFFSET_YZ_ANGLE = math.atan(MUZ_OFFSET_Z, MUZ_OFFSET_Y)

        TRD1Exists = INB(1)

        power = INB(2)
        highAngleEnable = INB(4)
        reloadEnable = INB(5)

    end

    --初期値
    do
        inRange = false
        tick = 0
        idealPitch, idealYaw = STANDBY_PITCH, STANDBY_YAW
        stabiPitch, stabiYaw = STANDBY_PITCH, STANDBY_YAW
        Azimuth, Elevation = 0, 0
    end

    --ピボットのヨーとピッチに変換
    do
        Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, TurEx, TurEy, TurEz)
        Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, BodEx, BodEy, BodEz)
        currentPitch, currentYaw = rect2Polar(Lx, Ly, Lz, false)
    end
    --ワールド速度算出
    Wvx, Wvy, Wvz = local2World(BodPvx, BodPvz, BodPvy, 0, 0, 0, BodEx, BodEy, BodEz)

    --補足時かつ起動時に弾道計算機有効
    if TRD1Exists and power and WPN_TYPE ~= 9 then

        V0, K, tickDel, WIND_INFLUENCE = parameter[WPN_TYPE][1]/60, parameter[WPN_TYPE][2], parameter[WPN_TYPE][3], parameter[WPN_TYPE][4]
        isRocket = WPN_TYPE == 8

        --オフセット
        TurPx, TurPz, TurPy = local2World(PHY_OFFSET_X, PHY_OFFSET_Y, PHY_OFFSET_Z, TurPx, TurPy, TurPz, TurEx, TurEy, TurEz)

        --自分基準ワールド座標系へ
        TWLx, TWLy, TWLz = Tx - TurPx, Ty - TurPz, Tz - TurPy

        --遅れ補正
        TWLx, TWLy, TWLz, Tvx, Tvy, Tvz = predictTRD1(TRD1_DELAY, TWLx, TWLy, TWLz, Tvx, Tvy, Tvz, Tax, Tay, Taz)

        --ビークル速度
        Wvxy = distance2(Wvx, Wvy)
        WvxyDirec = math.atan(Wvx, Wvy)

        --海面高度でのワールド風速に変換
        windWv, windWdirec = windLocal2World(windLv, windLdirec, BodPvx, BodPvz, BodEx, BodEy, BodEz)
        windWv = windWv/((((44.33 - TurPy/1000)/11.89)^5.256)/1013)
        g = math.exp(-TurPy/60000)/120

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

                --曲射/直射境界仰角条件(風なし)
                V0Border = V0 + (isRocket and 600/60 or 0)  --ロケットの加速を初速に加算
                A = -goalY*g/V0Border                       --文字数省略で置き換え
                highAngleBorder = math.acos(K*goalY/math.sqrt(A*A + V0Border*V0Border)) + math.atan(A, V0Border)

                --仰角からgolaYの時のzを求める(風なし)
                function secantElevation0(b)
                    return goalY*(V0Border*math.sin(b) + g/K)/V0Border/math.cos(b) + g*math.log(1 - K*goalY/V0Border/math.cos(b))/(K*K) - goalZ
                end

                --仰角仮定
                if not highAngleEnable then
                    --直射解
                    Elevation = secantBrentsMethod(secantElevation0, math.atan(goalZ, goalY), secantElevation0(math.atan(goalZ, goalY)), highAngleBorder, secantElevation0(highAngleBorder), 10, (0.1/360)*pi2)
                else
                    --曲射解
                    Elevation = secantBrentsMethod(secantElevation0, math.acos(K*goalY/V0Border) - 0.001, secantElevation0(math.acos(K*goalY/V0Border) - 0.001), highAngleBorder, secantElevation0(highAngleBorder), 10, (0.1/360)*pi2)
                end
            end
        end

        --メインイテレーション実行
        --方位角更新(割線法)
        do  
            fAzimuth = secantAzimuth(Azimuth)
            newAzimuth = Azimuth + math.atan(TGTx, TGTy) - math.atan(x, y)

            Azimuth, AzimuthError, nIter = secantBrentsMethod(secantAzimuth, newAzimuth, secantAzimuth(newAzimuth), Azimuth, fAzimuth, MAX_ITERATION_I, AZIMUTH_MAX_ERROR)

            --[[
            OUN(22, nIter)  --デバッグ用
            OUN(23, x - TGTx)
            OUN(24, y - TGTy)
            OUN(25, z - TGTz)
            ]]
        end

        --射程内判定
        inRange = tick < tickDel and AzimuthError < AZIMUTH_MAX_ERROR and ElevationError < ELEVATION_MAX_ERROR

        --向くべき方向を仮想的に３次元座標で算出
        losWx, losWy, losWz = TurPx + INFTY*math.cos(Elevation)*math.sin(Azimuth), TurPz + INFTY*math.cos(Elevation)*math.cos(Azimuth), TurPy + INFTY*math.sin(Elevation)
        Lx, Ly, Lz = world2Local(losWx, losWy, losWz, TurPx, TurPy, TurPz, BodEx, BodEy, BodEz)

        --射撃可能判定用の、本来向くべき向き
        idealPitch, idealYaw = rect2Polar(Lx, Ly, Lz, false)

        --着弾点座標と、その時の標的速度
        impx, impy, impz, impvx, impvy, impvz = predictTRD1(tick, Tx, Ty, Tz, Tvx, Tvy, Tvz, Tax, Tay, Taz)
    end

    --射撃可能判定
    do
        currentInFOV = same_rotation(currentYaw) > MIN_YAW and same_rotation(currentYaw) < MAX_YAW and currentPitch > MIN_PITCH and currentPitch < MAX_PITCH
        targetInFOVPitch = math.sin(idealPitch) > math.sin(MIN_PITCH) and math.sin(idealPitch) < math.sin(MAX_PITCH)
        targetInFOVYaw = idealYaw > MIN_YAW and idealYaw < MAX_YAW
        pitchError = math.abs(same_rotation(idealPitch - currentPitch))*360
        yawError = math.abs(same_rotation(idealYaw - currentYaw))*360
        inError = pitchError < PIVOT_MAX_ERROR and yawError < PIVOT_MAX_ERROR
        shootable = inRange and inError and currentInFOV and targetInFOVPitch and targetInFOVYaw and not reloadEnable
    end

    --駆動系
    do
        --射程外またはミサイルモードの場合、目標方向を直接向く
        if not inRange and TRD1Exists then
            stabiPitch, stabiYaw = stabilizer(TurPx, TurPy, TurPz, BodEx, BodEy, BodEz, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, Tx, Ty, Tz, STABI_DELAY_VELO)
            roboticPitch, roboticYaw = stabiPitch, stabiYaw
            idealPitch, idealYaw = stabiPitch, stabiYaw
        end

        --スタビライザー
        if stabiEnable then
            --向くべき座標計算
            if inRange then
                --向くべき未来位置計算(速度ピボット)
                stabiPitch, stabiYaw = stabilizer(TurPx, TurPy, TurPz, BodEx, BodEy, BodEz, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, impx, impy, impz, impvx, impvy, impvz, losWx, losWy, losWz, STABI_DELAY_VELO)

                --向くべき未来位置計算(ロボティックピボット)
                roboticPitch, roboticYaw = stabilizer(TurPx, TurPy, TurPz, BodEx, BodEy, BodEz, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, impx, impy, impz, impvx, impvy, impvz, losWx, losWy, losWz, STABI_DELAY_ROBO)
            end

            if reloadEnable then
                stabiPitch = STANDBY_PITCH
                roboticPitch = STANDBY_PITCH
            end

            --差分へ
            yawDiff = YAW_LIMIT_ENABLE and (stabiYaw - currentYaw) or same_rotation(stabiYaw - currentYaw)

            --PID
            stabiPitchV, stabiPitchES, stabiPitchEP = PID(STABI_P, STABI_I, STABI_D, stabiPitch, currentPitch, stabiPitchES, stabiPitchEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)
            stabiYawV, stabiYawES, stabiYawEP = PID(STABI_P, STABI_I, STABI_D, 0, -yawDiff, stabiYawES, stabiYawEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)

            --誤差修正用のPIDパラメータ
            P, I, D = ERROR_P, ERROR_I, ERROR_D
        else
            P, I, D = MANUAL_P, MANUAL_I, MANUAL_D
            stabiPitchV, stabiYawV = 0, 0
            roboticPitch, roboticYaw = idealPitch, idealYaw
        end

        --差分へ
        yawDiff = YAW_LIMIT_ENABLE and (idealYaw - currentYaw) or same_rotation(idealYaw - currentYaw)

        --PID
        pitchV, pitchES, pitchEP = PID(P, I, D, idealPitch, currentPitch, pitchES, pitchEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)
        yawV, yawES, yawEP = PID(P, I, D, 0, -yawDiff, yawES, yawEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)

        pitchV = stabiPitchV + pitchV
        yawV = stabiYawV + yawV

        --ピッチ角制限
        if PITCH_LIMIT_ENABLE then
            pitchV = limit_rotation(pitchV, same_rotation(currentPitch), MIN_PITCH, MAX_PITCH)
        end
        --ヨー角制限
        if YAW_LIMIT_ENABLE then
            yawV = limit_rotation(yawV, same_rotation(currentYaw), MIN_YAW, MAX_YAW)
        end

        --ギア補正
        pitchV = pitchV*PITCH_PIVOT
        yawV = yawV*YAW_PIVOT

        --ロボティックピボットの場合
        if PITCH_PIVOT < 0 then
            pitchV = PITCH_LIMIT_ENABLE and clamp(roboticPitch, MIN_PITCH, MAX_PITCH)*4 or roboticPitch*4
        end
        if YAW_PIVOT < 0 then
            yawV = YAW_LIMIT_ENABLE and clamp(roboticYaw, MIN_YAW, MAX_YAW)*4 or roboticYaw*4
        end

        --ゼロ除算対策
        pitchV = (pitchV ~= pitchV) and 0 or pitchV
        yawV = (yawV ~= yawV) and 0 or yawV
    end

    OUN(1, pitchV)
    OUN(2, yawV)
    OUB(1, shootable)
    OUB(2, inRange)

    OUN(3, pitchError)
    OUN(4, yawError)

    OUN(30, tick)
    OUN(31, Elevation)
    OUN(32, Azimuth)

    OUN(20, pitchES)
    OUN(21, pitchEP)
    OUN(22, yawES)
    OUN(23, yawEP)
end

--[[
TWLx, TWLy, TWLz = 0, 0, 0
windWdirec = 0

--砲塔と風の向きと着弾位置の描画
function onDraw()
    w, h = screen.getWidth(), screen.getHeight()
    screen.setColor(0, 255, 0)

    --砲塔の向き
    screen.drawCircle(w/2, h/2, 1)
    screen.drawLine(w/2, h/2, w/2 + math.sin(Azimuth)*10, h/2 - math.cos(Azimuth)*10)

    --ターゲット位置
    screen.setColor(255, 0, 0)
    screen.drawCircle(w/2 + TWLx/30, h/2 - TWLy/30, 2)

    --風の向き
    screen.setColor(0, 0, 255)
    screen.drawCircleF(10, 10, 1)
    screen.drawLine(10, 10, 10 + math.sin(windWdirec)*5, 10 - math.cos(windWdirec)*5)
end
]]