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
ALT_INTERVAL = 2000                         --数値積分の高度間隔[m]
MIN_INTERVAL = 30
MAX_INTERVAL = math.sqrt(240*ALT_INTERVAL)  --数値積分の最大ステップ幅[tick]
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

    --割線ブレント法更新(func:関数, b, fb, a, fa:初期のxとf(x), times: 更新回数, MAX_ERROR: 許容誤差)
    function secantBrentsMethod(func, b, fb, a, fa, times, MAX_ERROR)
        local fbAbs, c, fc, fcAbs, e, d, alpha, beta, p, q, r, brentsMode
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

                b, c = b + d, b
                fc = fb
            else
                diff = fb - fa
                --次のxを決定
                if fbAbs > faAbs*1.1 then --誤差が増加したら更新量を半分に
                    xNew = (a + b)/2
                elseif ((diff > 0 and diff or -diff) < MAX_ERROR*0.1 or b == a) and fbAbs > MAX_ERROR then   --更新量が小さすぎるときは更新量を増やす
                    xNew = b + 0.001
                else                        --#通常の割線法
                    xNew = b - fb*(b - a)/diff
                end

                --更新
                fa, a, faAbs = fb, b, fbAbs
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
        z2 = (vzLast - azLast/K)*(K*t - 1 + exp)/K/K/t + azLast*t/2/K + zLast   --平均高度
        atmCoef = WIND_INFLUENCE*(((44.33 - z2/1000)/11.89)^5.256)/60780        --風影響係数
        axLast, ayLast, azLast = axLast - windVx*atmCoef, ayLast - windVy*atmCoef, azLast - math.exp(-z2/60000)/120
        --更新(減衰あり等加速度直線運動)
        x, vx = ((vxLast - axLast/K)*(1 - exp) + axLast*t)/K + xLast, (vxLast - axLast/K)*exp + axLast/K
        y, vy = ((vyLast - ayLast/K)*(1 - exp) + ayLast*t)/K + yLast, (vyLast - ayLast/K)*exp + ayLast/K
        z, vz = ((vzLast - azLast/K)*(1 - exp) + azLast*t)/K + zLast, (vzLast - azLast/K)*exp + azLast/K
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
        g, atm = calGrav(TurPy), calAtm(TurPy)
        x, y, z = MUZ_OFFSET_X, MUZ_OFFSET_YZ*math.cos(MUZ_OFFSET_YZ_ANGLE + El), MUZ_OFFSET_YZ*math.sin(MUZ_OFFSET_YZ_ANGLE + El)
        --ビークル速度を加算した砲弾初速
        vx, vy, vz = Wvxy*math.sin(WvxyDirec - Azim), V0*math.cos(El) + Wvxy*math.cos(WvxyDirec - Azim), V0*math.sin(El) + Wvz
        ax, ay, az = 0, 0, 0

        local h = 60    --数値積分のステップ幅
        tick = 0        --発射からの経過時間
        xLast, yLast, zLast, vxLast, vyLast, vzLast, axLast, ayLast, azLast = x, y, z, vx, vy, vz, ax, ay, az
        fLast = -INFTY
        isArrived = false

        --ロケットの加速
        if isRocket then
            ay = ROCKET_ACL*math.cos(El)
            az = ROCKET_ACL*math.sin(El)

            f, isArrived = secantEuler(h)

            --目標を通過したら正確な位置とステップ幅を再計算(活線法)
            if isArrived then
                tick, _, nIter = secantBrentsMethod(secantEuler, h, f, 0, -TGT0y, 10, 0.01)

                --OUN(20, nIter)  --デバッグ用
            end

            h = hNew
            tick = tick + h
            ay, az = 0, 0   --加速終了
            xLast, yLast, zLast, vxLast, vyLast, vzLast, axLast, ayLast, azLast = x, y, z, vx, vy, vz, ax, ay, az
        end

        --デバッグ用
        nIter = 0

        --数値積分
        for k = 1, 20 do
            --更新
            f, isArrived = secantEuler(h)

            --目標を通過したら正確な位置とステップ幅を再計算(活線法)
            if isArrived then
                h, _, nIter = secantBrentsMethod(secantEuler, h, f, 0, fLast, 10, 0.01)

                --OUN(20, nIter)  --デバッグ用
            end

            tick = tick + h
            h = hNew
            xLast, yLast, zLast, vxLast, vyLast, vzLast, axLast, ayLast, azLast = x, y, z, vx, vy, vz, ax, ay, az

            --終了条件
            if isArrived or tick > tickDel then
                --OUN(19, k)
                break
            end
        end

        --[[
        OUN(23, x - TGTx)
        OUN(24, y - TGTy)
        OUN(25, z - TGTz)
        ]]

        return highAngleEnable and (TGTy - y) or (TGTz - z)   --仰角誤差
    end

    --方位角指定時の誤差を返す
    function secantAzimuth(Az)
        Azim = Az
        --仰角更新(割線法)
        do
            local ElevationMin, ElevationMax = highAngleEnable and highAngleBorder or -pi2/4, highAngleEnable and (pi2/2 - highAngleBorder) or highAngleBorder

            fElevation = secantElevation(Elevation)

            --初期更新はちょとだけ
            newElevation = Elevation + 0.001
            newfElevation = secantElevation(newElevation)

            Elevation, ElevationError, nIter = secantBrentsMethod(secantElevation, newElevation, newfElevation, Elevation, fElevation, MAX_ITERATION_I, ELEVATION_MAX_ERROR)
            Elevation = clamp(Elevation, ElevationMin, ElevationMax)

            --OUN(21, nIter)  --デバッグ用
        end

        return distance2(TGTx, TGTy)*(math.atan(TGTx, TGTy) - math.atan(x, y))  --方位角誤差(弧の長さ)
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
        MUZ_OFFSET_YZ = distance2(MUZ_OFFSET_Y, MUZ_OFFSET_Z)
        MUZ_OFFSET_YZ_ANGLE = math.atan(MUZ_OFFSET_Z, MUZ_OFFSET_Y)

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
        TurPx, TurPz, TurPy = local2World(PHY_OFFSET_X, PHY_OFFSET_Y, PHY_OFFSET_Z, TurPx, TurPy, TurPz, TurEx, TurEy, TurEz)

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

                --曲射/直射境界仰角条件(風なし)
                V0Border = V0 + (isRocket and 600/60 or 0)  --ロケットの加速を初速に加算
                A = -goalY*g/V0Border                       --文字数省略で置き換え
                highAngleBorder = math.acos(K*goalY/math.sqrt(A*A + V0Border*V0Border)) + math.atan(A, V0Border)

                --仰角からgolaYの時のzを求める(風なし)
                function secantEuler(b)
                    return goalY*(V0Border*math.sin(b) + g/K)/V0Border/math.cos(b) + g*math.log(1 - K*goalY/V0Border/math.cos(b))/(K*K) - goalZ
                end

                --仰角仮定
                if not highAngleEnable then
                    --直射解
                    Elevation = secantBrentsMethod(secantEuler, math.atan(goalZ, goalY), secantEuler(math.atan(goalZ, goalY)), highAngleBorder, secantEuler(highAngleBorder), 10, (0.1/360)*pi2)
                else
                    --曲射解
                    Elevation = secantBrentsMethod(secantEuler, math.acos(K*goalY/V0Border) - 0.001, secantEuler(math.acos(K*goalY/V0Border) - 0.001), highAngleBorder, secantEuler(highAngleBorder), 10, (0.1/360)*pi2)
                end
            end
        end

        --メインイテレーション実行
        --方位角更新(割線法)
        do  
            fAzimuth = secantAzimuth(Azimuth)
            newAzimuth = Azimuth + math.atan(TGTx, TGTy) - math.atan(x, y)

            Azimuth, AzimuthError, nIter = secantBrentsMethod(secantAzimuth, newAzimuth, secantAzimuth(newAzimuth), Azimuth, fAzimuth, MAX_ITERATION_I, AZIMUTH_MAX_ERROR)

            --OUN(22, nIter)  --デバッグ用
        end

        --射程内判定
        inRange = tick < tickDel and AzimuthError < AZIMUTH_MAX_ERROR and ElevationError < ELEVATION_MAX_ERROR
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
