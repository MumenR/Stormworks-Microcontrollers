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

SEAT_STABI_T = 7.5
SEAT_STABI_P = 8.2
SEAT_STABI_D = 0
SEAT_PIVOT = 32/5

LASER_STABI_T = 4
LASER_DELAY = 4
t = 0

is1P = false

--関数
do

    --オイラー角からクォータニオン変換
    function euler2Qt(Ex, Ey, Ez)
        return mulQt({0, math.sin(-Ez/2), 0, math.cos(-Ez/2)}, mulQt({0, 0, math.sin(-Ey/2), math.cos(-Ey/2)}, {math.sin(-Ex/2), 0, 0, math.cos(-Ex/2)}))
    end

    --クォータニオンの掛け算(p: 姿勢, q:回転)
    function mulQt(q, p)
        local a, b, c, d = table.unpack(q)
        local x, y, z, w = table.unpack(p)
        return {
            d*x - c*y + b*z + a*w,
            c*x + d*y - a*z + b*w,
            -b*x + a*y + d*z + c*w,
            -a*x - b*y - c*z + d*w
        }
    end

    --ローカル座標からワールド座標へ
    function local2World(Lx, Ly, Lz, Px, Py, Pz, q)
        x, y, z = table.unpack(mulQt(q, mulQt({Lx, Ly, Lz, 0}, {-q[1], -q[2], -q[3], q[4]})))
        return x + Px, y + Pz, z + Py
    end

    --ワールド座標からローカル座標へ
    function world2Local(Wx, Wy, Wz, Px, Py, Pz, q)
        return table.unpack(mulQt({-q[1], -q[2], -q[3], q[4]}, mulQt({Wx - Px, Wy - Pz, Wz - Py, 0}, q)))
    end

    --姿勢の球面補間(q1からq2へtの割合)
    function slerp(q1, q2, t)
        local dot, theta, e, f
        local a, b, c, d = table.unpack(q1)
        local x, y, z, w = table.unpack(q2)
        dot = a*x + b*y + c*z + d*w     --内積
        if dot < 0 then                 --遠回り回転なら逆へ回転させる
            dot, x, y, z, w = -dot, -x, -y, -z, -w
        end
        theta = math.acos(dot)          --必要回転角度
        if theta > 0.0001 then          --０除算対策
            e = math.sin((1 - t)*theta)/math.sin(theta)
            f = math.sin(t*theta)/math.sin(theta)
        else
            e, f = (1 - t), t
        end
        x = e*a + f*x
        y = e*b + f*y
        z = e*c + f*z
        w = e*d + f*w
        e = math.sqrt(x*x + y*y + z*z + w*w)    --正規化
        return {x/e, y/e, z/e, w/e}
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

    --極座標から直交座標へ変換(Z軸優先)
    function polar2Rect(pitch, yaw, distance, radian_bool)
        local x, y, z
        if not radian_bool then
            pitch = pitch*pi2
            yaw = yaw*pi2
        end
        x = distance*math.cos(pitch)*math.sin(yaw)
        y = distance*math.cos(pitch)*math.cos(yaw)
        z = distance*math.sin(pitch)
        return x, y, z
    end

    function clamp(x, min, max)
        if x >= max then
            x = max
        elseif x <= min then
            x = min
        end
        return x
    end

    function distance3(x, y, z)
        return math.sqrt(x*x + y*y + z*z)
    end

    function same_rotation(x)
        return (x + 0.5)%1 - 0.5
    end

    --(return: futurePitch, futureYaw)
    --Prv[rad/tick], Tは視線角速度観測用のターゲット位置と速度, losは向くべき方向, 2軸スタビ
    function stabilizer2(Px, Py, Pz, Qt, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, losWx, losWy, losWz, DELAY)
        local TLx, TLy, TLz, TLvx, TLvy, TLvz, Lrvx, Lrvy, Lrvz, losRvx, losRvy, losRvz, Vrx, Vry, Vrz, T2, absRv, cos, sin, dot, losFutureX, losFutureY, losFutureZ, losLx, losLy, losLz
        --ローカル座標
        TLx, TLy, TLz = world2Local(Tx, Ty, Tz, Px, Py, Pz, Qt)
        TLvx, TLvy, TLvz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Qt)
        Lrvx, Lrvy, Lrvz = world2Local(Prvx, Prvz, Prvy, 0, 0, 0, Qt)
        losLx, losLy, losLz = world2Local(losWx, losWy, losWz, Px, Py, Pz, Qt)
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

    --(return: futurePitch, futureYaw)
    --Prv[rad/tick], azimuth[回転]は向くべき方位, 1軸スタビ
    function stabilizer1(Qt, Prvx, Prvy, Prvz, azimuth, DELAY)
        local losRvx, losRvy, losRvz, absRv, cos, sin, dot, futWx, futWy, futWz, Wx, Wy, ex, ey, ez, futLx, futLy, futLz
        --向くべき方位(３次元座標)
        Wx, Wy = math.sin(azimuth*pi2), math.cos(azimuth*pi2)
        --角速度を右手系変換し、標的の視線角速度に変える
        losRvx, losRvy, losRvz = -(-Prvx), -(-Prvz), -(-Prvy)
        --t[tick]後の未来位置へ(ロドリゲスの公式)
        absRv = math.sqrt(losRvx*losRvx + losRvy*losRvy + losRvz*losRvz)
        cos = math.cos(absRv*DELAY)
        sin = math.sin(absRv*DELAY)/absRv
        dot = (losRvx*Wx + losRvy*Wy)*(1 - cos)/absRv/absRv
        futWx = cos*Wx - sin*losRvz*Wy + dot*losRvx
        futWy = cos*Wy + sin*losRvz*Wx + dot*losRvy
        futWz = sin*(losRvx*Wy - losRvy*Wx) + dot*losRvz
        --ローカル座標変換
        ex, ey, ez = world2Local(0, 0, 1, 0, 0, 0, Qt)  --Z軸単位ベクトル
        futLx, futLy, futLz = world2Local(futWx, futWy, futWz, 0, 0, 0, Qt)
        --逆投影(?)
        futLx = futLx - ex*futLz/ez
        futLy = futLy - ey*futLz/ez
        return rect2Polar(futLx, futLy, 0, false)
    end

    seatYawES, seatYawEP = 0, 0
    seatPitchES, seatPitchEP = 0, 0

    --PID制御
    function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
        local error, errorSum, errorDiff, control
        error = target - current
        errorSum = math.abs(error) < 5/360 and errorSumPre + error or errorSumPre
        errorDiff = error - errorPre
        control = P*error + I*errorSum + D*errorDiff

        if control > max or control < min then
            errorSum = errorSumPre
            control = P*error + I*errorSum + D*errorDiff
        end
        return clamp(control, min, max), errorSum, error
    end
end

pitchPrev, yawPrev = 0, 0
seatLosQtPrev = {0, 0, 0, 1}
las1Direc = {{0, 0}}
las2Direc = {{0, 0}}
lasQtBuf = {{0, 0, 0, 1}}
trackInPre = false
isTracking = false
function onTick()
    --インプット
    do
        isPower = INN(15) == 1

        lasPx, lasPy, lasPz = INN(1), INN(2), INN(3)
        lasQt = euler2Qt(INN(4), INN(5), INN(6))
        lasPvx, lasPvy, lasPvz = INN(7)/60, INN(8)/60, INN(9)/60
        lasPrvx, lasPrvy, lasPrvz = INN(10)*pi2/60, INN(11)*pi2/60, INN(12)*pi2/60

        las1Dist, las2Dist = INN(13), INN(14)

        bodQt = euler2Qt(INN(16), INN(17), INN(18))
        bodPrvx, bodPrvy, bodPrvz = INN(19)*pi2/60, INN(20)*pi2/60, INN(21)*pi2/60

        seatLosYaw, seatLosPitch = INN(22)*pi2, INN(23)*pi2

        seatPx, seatPy, seatPz = INN(24), INN(25), INN(26)
        seatQt = euler2Qt(INN(27), INN(28), INN(29))

        trackIn = INN(30) == 1

        vehicleCamMode = PRN("Vehicle Camera Mode")

        FPSoffsetX = PRN("FPS view offset X")
        FPSoffsetY = PRN("FPS view offset Y")
        FPSoffsetZ = PRN("FPS view offset Z")
        TPSoffsetX = PRN("TPS view offset X")
        TPSoffsetY = PRN("TPS view offset Y")
        TPSoffsetZ = PRN("TPS view offset Z")
        lasOffsetX = PRN("Laser offset X")
        lasOffsetY = PRN("Laser offset Y")
        lasOffsetZ = PRN("Laser offset Z")

        targetSize = PRN("Target size [m]")
    end

    --追尾開始のパルス
    trackPulse = not trackInPre and trackIn
    trackInPre = trackIn

    --phys = 0の時を防ぎ、レーザーの振動をなくす
    if t > 5 and isPower then
        --レーザーが指している座標
        do
            a, b = las1Direc[1], las2Direc[1]
            Lx, Ly, Lz = polar2Rect(a[1], a[2], las1Dist, false)
            las1Wx, las1Wy, las1Wz = local2World(Lx + lasOffsetX, Ly + lasOffsetY, Lz + lasOffsetZ, lasPx, lasPy, lasPz, lasQtBuf[1])
            Lx, Ly, Lz = polar2Rect(b[1], b[2], las2Dist, false)
            las2Wx, las2Wy, las2Wz = local2World(Lx + lasOffsetX, Ly + lasOffsetY, Lz + lasOffsetZ, lasPx, lasPy, lasPz, lasQtBuf[1])
        end

        --視線の基準となる真の姿勢
        do
            seatLosQt = slerp(seatLosQtPrev, seatQt, 0.05)
            seatLosQtPrev = {table.unpack(seatLosQt)}
        end

        --ピボットのヨーに変換
        do
            Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, seatQt)
            Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, bodQt)
            _, seatCntYaw = rect2Polar(Lx, Ly, Lz, false)
        end

        --シートピボット
        do
            _, seatIdealYaw = stabilizer1(bodQt, bodPrvx, bodPrvy, bodPrvz, 0.25, SEAT_STABI_T)

            seatYawControl, seatYawES, seatYawEP = PID(SEAT_STABI_P, 0, SEAT_STABI_D, 0, -same_rotation(seatIdealYaw - seatCntYaw), seatYawES, seatYawEP, -100, 100)
            seatYawControl = seatYawControl*SEAT_PIVOT
            --nan対策
            seatYawControl = seatYawControl ~= seatYawControl and 0 or seatYawControl
        end

        --視線方向
        do
            --ワールド視線方向
            if is1P or vehicleCamMode == 2 then     --一人称または固定の時
                --視点からの距離を設定
                losWxOff, losWyOff, losWzOff = local2World(FPSoffsetX, FPSoffsetY, FPSoffsetZ, seatPx, seatPy, seatPz, seatQt)
                losDist = distance3(las1Wx - losWxOff, las1Wy - losWyOff, las1Wz - losWzOff)
                losDist = las1Dist ~= 4000 and losDist or 100

                --ローカル座標系
                Lx, Ly, Lz = polar2Rect(seatLosPitch, seatLosYaw, losDist, true)
                losWx, losWy, losWz = local2World(Lx, Ly, Lz, 0, 0, 0, seatQt)
            else                                    --水平固定または自由
                --視点からの距離を設定
                losWxOff, losWyOff, losWzOff = local2World(TPSoffsetX, TPSoffsetY, TPSoffsetZ, seatPx, seatPy, seatPz, seatQt)
                losDist = distance3(las1Wx - losWxOff, las1Wy - losWyOff, las1Wz - losWzOff)
                losDist = las1Dist ~= 4000 and losDist or 100

                --ワールド座標系でピッチのみ零点シフト
                Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, seatLosQt)
                Wpi, Wya = rect2Polar(Wx, Wy, Wz, true)
                losWx, losWy, losWz = polar2Rect(seatLosPitch + Wpi, seatLosYaw + Wya, losDist, true)
            end

            losWx, losWy, losWz = losWx + losWxOff, losWy + losWyOff, losWz + losWzOff

            OUN(21, losWx)
            OUN(22, losWy)
            OUN(23, losWz)

            --レーザー座標のオフセット
            Wx, Wy, Wz = local2World(lasOffsetX, lasOffsetY, lasOffsetZ, 0, 0, 0, lasQt)
            
            --スタビライザー
            losPitch, losYaw = stabilizer2(lasPx + Wx, lasPy + Wz, lasPz + Wy, lasQt, lasPvx, lasPvy, lasPvz, lasPrvx, lasPrvy, lasPrvz, losWx, losWy, losWz, 0, 0, 0, losWx, losWy, losWz, LASER_STABI_T)
        end

        --レーザー追尾
        do
            --追尾開始判定
            if trackPulse and not isTracking and las1Dist ~= 0 and las1Dist ~= 4000 then
                isTracking = true
                trackT = 0
            --追尾終了判定
            elseif (isTracking and trackPulse) or las1Dist == 0 or las1Dist == 4000 then
                isTracking = false
            end

            if isTracking then
                --走査範囲計算
                tgtDist = las1Dist
                
                delta = math.atan(targetSize/2, las1Dist)/pi2

                --レーザー方向
                --レーザー１は上中下
                if trackT%3 == 0 then       --上
                    las1pitch, las1yaw = losPitch + delta/2, losYaw
                elseif trackT%3 == 1 then   --中
                    las1pitch, las1yaw = losPitch, losYaw
                else                        --下
                    las1pitch, las1yaw = losPitch - delta/2, losYaw
                end
                --レーザー２は左右
                if trackT%2 == 0 then       --左
                    las2pitch, las2yaw = losPitch, losYaw - delta
                else                        --右
                    las2pitch, las2yaw = losPitch, losYaw + delta
                end

                trackT = trackT + 1
            else
                --レーザー１は直接ターゲットを補足
                --レーザー２は追尾に備えてターゲット下の地面を補足しておく
                las1pitch, las1yaw = losPitch, losYaw
                delta = math.atan(targetSize/2, las1Dist)/pi2
                las2pitch, las2yaw = losPitch - delta, losYaw
            end
        end

        --レーザー俯仰角を制限
        las1pitch, las1yaw = clamp(las1pitch, -0.125, 0.125), clamp(las1yaw, -0.125, 0.125)
        las2pitch, las2yaw = clamp(las2pitch, -0.125, 0.125), clamp(las2yaw, -0.125, 0.125)

        OUB(1, true)
        OUN(1, losWx)
        OUN(2, losWy)
        OUN(3, losWz)

        OUN(31, seatYawControl)

        OUN(10, -las1yaw*8)
        OUN(11, -las1pitch*8)
        OUN(12, -las2yaw*8)
        OUN(13, -las2pitch*8)

        --レーザー方向の遅延
        do
            table.insert(las1Direc, {las1pitch, las1yaw})
            table.insert(las2Direc, {las2pitch, las2yaw})
            table.insert(lasQtBuf, {table.unpack(lasQt)})

            if #las1Direc > LASER_DELAY then
                table.remove(las1Direc, 1)
                table.remove(las2Direc, 1)
                table.remove(lasQtBuf, 1)
            end
        end
    elseif t <= 5 then
        t = t + 1
    end
    
    --一人称視点フラグ
    is1P = false
end

function onDraw()
    is1P = true
end
