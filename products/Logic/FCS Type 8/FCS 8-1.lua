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

    simulator:setProperty("FPS view offset", "0,0.25,1.45")
    simulator:setProperty("TPS view offset", "0,0.25,2")
    simulator:setProperty("Laser offset 1", "-0.5,0.5,-0.25")
    simulator:setProperty("Laser offset 2", "-0.25,0.5,-0.25")
    simulator:setProperty("Laser offset 3", "-0,0.5,-0.25")
    simulator:setProperty("Laser offset 4", "0.25,0.5,-0.25")

    for i = 1, 32 do
        simulator:setInputNumber(i, 0)
    end

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

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
PRT = property.getText
pi2 = math.pi*2

SEAT_STABI_T = 7.5
SEAT_STABI_P = 8.2
SEAT_STABI_D = 0
SEAT_PIVOT = 32/5

LASER_STABI_T = 4
LASER_DELAY = 4

GND_OFST = -2       --地面判定は標的のn[m]下に向けて行う
TGT_ALT = 0.1       --標的の高さがn[m]以上で目標と判定
TGT_PRED_DELAY = 0  --n[tick]後の未来位置を予測
TGT_DEL_TICK = 30   --n[tick]以上前のデータは削除
TGT_RADIUS_GAIN = 1.05

alpha = 0.1 --α-βフィルタのα
beta = 0.1  --α-βフィルタのβ

--関数
do

    --左手系でXYZ順オイラー角から右手系クォータニオンへ変換
    function euler2Qt(Ex, Ey, Ez)
        return mulQt({0, math.sin(-Ez/2), 0, math.cos(-Ez/2)}, mulQt({0, 0, math.sin(-Ey/2), math.cos(-Ey/2)}, {math.sin(-Ex/2), 0, 0, math.cos(-Ex/2)}))
    end

    --クォータニオンの掛け算(q:回転, p: 姿勢)
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

    --カンマ区切り3つの文字列を数字に変換し、オフセット
    function offset(PRTName, Px, Py, Pz, Qt)
        offsetX, offsetY, offsetZ = string.match(PRT(PRTName), "([^,]+),([^,]+),([^,]+)")
        return local2World(tonumber(offsetX), tonumber(offsetY), tonumber(offsetZ), Px, Py, Pz, Qt)
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

    --２つのベクトルから法線ベクトルを算出
    function calNomVec(x1, y1, z1, x2, y2, z2)
        local nx, ny, nz
        nx = y1*z2 - z1*y2
        ny = z1*x2 - x1*z2
        nz = x1*y2 - y1*x2
        --正規化
        local len = math.sqrt(nx*nx + ny*ny + nz*nz)
        if len > 0 then
            nx, ny, nz = nx/len, ny/len, nz/len
        else
            nx, ny, nz = 0, 0, 0
        end
        --上下逆なら反転
        if nz < 0 then
            nx, ny, nz = -nx, -ny, -nz
        end
        return nx, ny, nz
    end

    --標点、基準点、法線ベクトルから対地高度を算出
    function calGndAlt(targetX, targetY, targetZ, gndX, gndY, gndZ, nomX, nomY, nomZ)
        return (targetX - gndX)*nomX + (targetY - gndY)*nomY + (targetZ - gndZ)*nomZ
    end

    --x(t) = at + bを最小二乗法で求める(ABFに換装予定、後に消去する)
    --ft = {{t = tick, x = X}, ...}
    function leastSquaresMethod(ft)
        --最小2サンプル又は30tick以上のデータ量であること
        if #ft < 2 or (ft[1].t and ft[#ft].t - ft[1].t) < 30 then
            return 0, ft[#ft].x or 0
        else
            sumT, sumT2, sumX, sumTX = 0, 0, 0, 0
            for _, FT in pairs(ft) do
                sumT = sumT + FT.t
                sumT2 = sumT2 + FT.t*FT.t
                sumX = sumX + FT.x
                sumTX = sumTX + FT.t*FT.x
            end
            det = #ft*sumT2 - sumT*sumT
            a = (#ft*sumTX - sumT*sumX)/det
            b = (sumT2*sumX - sumTX*sumT)/det
            return a or 0, b or 0
        end
    end

    --α-βフィルタ更新(z: 観測値, vx: 予測速度, x: 予測位置)
    function ABFUpdate(z, vx, x)
        residual = z - x
        vx = vx + beta*residual
        x = x + alpha*residual
        return vx, x
    end

    --α-βフィルタ予測
    function APFPredict(vx, x)
        return x + vx
    end
end

t = 0
pitchPrev, yawPrev = 0, 0
seatLosQtPrev = {0, 0, 0, 1}
las1Direc = {{0, 0}}
las2Direc = {{0, 0}}
las3Direc = {{0, 0}}
las4Direc = {{0, 0}}
lasQtBuf = {{0, 0, 0, 1}}
trackInPre = false
isTracking = false
is1P = false
GNDCorrectionT = 0
trackT = 0
TGTx, TGTy, TGTz = {{t = 0, x = 0}}, {{t = 0, x = 0}}, {{t = 0, x = 0}}

function onTick()
    --インプット
    do
        lasPx, lasPy, lasPz = INN(1), INN(2), INN(3)
        lasQt = euler2Qt(INN(4), INN(5), INN(6))
        lasPvx, lasPvy, lasPvz = INN(7)/60, INN(8)/60, INN(9)/60
        lasPrvx, lasPrvy, lasPrvz = INN(10)*pi2/60, INN(11)*pi2/60, INN(12)*pi2/60

        las1Dist, las2Dist, las3Dist, las4Dist = INN(27), INN(28), INN(29), INN(30)

        bodQt = euler2Qt(INN(13), INN(14), INN(15))
        bodPrvx, bodPrvy, bodPrvz = INN(16)*pi2/60, INN(17)*pi2/60, INN(18)*pi2/60

        seatPx, seatPy, seatPz = INN(19), INN(20), INN(21)
        seatQt = euler2Qt(INN(22), INN(23), INN(24))

        seatLosYaw, seatLosPitch = INN(25)*pi2, INN(26)*pi2

        trackIn = INN(31) == 1
        isPower = INN(32) == 1

        vehicleCamMode = PRN("Vehicle Camera Mode")

        LaserOffset = "Laser offset "
        FPSWx, FPSWy, FPSWz = offset("FPS view offset", seatPx, seatPy, seatPz, seatQt)
        TPSWx, TPSWy, TPSWz = offset("TPS view offset", seatPx, seatPy, seatPz, seatQt)
        las1Px, las1Pz, las1Py = offset(LaserOffset.."1", lasPx, lasPy, lasPz, lasQt)
        las2Px, las2Pz, las2Py = offset(LaserOffset.."2", lasPx, lasPy, lasPz, lasQt)
        las3Px, las3Pz, las3Py = offset(LaserOffset.."3", lasPx, lasPy, lasPz, lasQt)
        las4Px, las4Pz, las4Py = offset(LaserOffset.."4", lasPx, lasPy, lasPz, lasQt)

        TGT_RADIUS = PRN("Target radius [m]")
    end

    --追尾開始のパルス
    trackPulse = not trackInPre and trackIn
    trackInPre = trackIn

    --phys = 0の時を防ぎ、レーザーの振動をなくす
    if t > 5 and isPower then
        --レーザーが指している座標
        do
            a, b, c, d = las1Direc[1], las2Direc[1], las3Direc[1], las4Direc[1]
            Lx, Ly, Lz = polar2Rect(a[1], a[2], las1Dist, false)
            las1Wx, las1Wy, las1Wz = local2World(Lx, Ly, Lz, lasPx, lasPy, lasPz, lasQtBuf[1])
            Lx, Ly, Lz = polar2Rect(b[1], b[2], las2Dist, false)
            las2Wx, las2Wy, las2Wz = local2World(Lx, Ly, Lz, lasPx, lasPy, lasPz, lasQtBuf[1])
            Lx, Ly, Lz = polar2Rect(c[1], c[2], las3Dist, false)
            las3Wx, las3Wy, las3Wz = local2World(Lx, Ly, Lz, lasPx, lasPy, lasPz, lasQtBuf[1])
            Lx, Ly, Lz = polar2Rect(d[1], d[2], las4Dist, false)
            las4Wx, las4Wy, las4Wz = local2World(Lx, Ly, Lz, lasPx, lasPy, lasPz, lasQtBuf[1])
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
                losDist = las1Dist ~= 4000 and distance3(las1Wx - FPSWx, las1Wy - FPSWy, las1Wz - FPSWz) or 100

                --ローカル座標系
                Lx, Ly, Lz = polar2Rect(seatLosPitch, seatLosYaw, losDist, true)
                losWx, losWy, losWz = local2World(Lx, Ly, Lz, FPSWx, FPSWz, FPSWy, seatQt)
            else                                    --水平固定または自由
                --視点からの距離を設定
                losDist = las1Dist ~= 4000 and distance3(las1Wx - TPSWx, las1Wy - TPSWy, las1Wz - TPSWz) or 100

                --ワールド座標系でピッチのみ零点シフト
                Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, seatLosQt)
                Wpi, Wya = rect2Polar(Wx, Wy, Wz, true)
                losWx, losWy, losWz = polar2Rect(seatLosPitch + Wpi, seatLosYaw + Wya, losDist, true)
                losWx, losWy, losWz = losWx + TPSWx, losWy + TPSWy, losWz + TPSWz
            end
        end

        --レーザー追尾
        do
            --追尾開始判定
            if trackPulse and not isTracking and las1Dist ~= 0 and las1Dist ~= 4000 then
                isTracking = true
                trackT = 0
                TGTx, TGTy, TGTz = {{t = 0, x = las1Wx}}, {{t = 0, x = las1Wy}}, {{t = 0, x = las1Wz}}
                gndX, gndY, gndZ = las2Wx, las2Wy, las2Wz
                gndX1, gndY1, gndZ1 = las2Wx + 1, las2Wy, las2Wz
                nomX, nomY, nomZ = 0, 0, 1
                TGTPredX, TGTPredY, TGTPredZ = las1Wx, las1Wy, las1Wz
                TGTRad0 = TGT_RADIUS
                TGTRad45 = TGT_RADIUS*0.6
                TGTRad90 = TGT_RADIUS*0.5
                TGTRad135 = TGT_RADIUS*0.6
                isHit0 = false
                isHit45 = false
                isHit90 = false
                isHit135 = false
            --追尾終了判定
            elseif (isTracking and trackPulse) or las1Dist == 0  or (#TGTx < 2 and TGTx[1].t < trackT - TGT_DEL_TICK) then
                isTracking = false
            end

            --追尾中
            if isTracking then
                --レーザ座標を判定し、ターゲット位置を保存
                function addData(Wx, Wy, Wz)
                    alt = calGndAlt(Wx, Wy, Wz, gndX, gndY, gndZ, nomX, nomY, nomZ)
                    error = distance3(Wx - TGTPredX, Wy - TGTPredY, Wz - TGTPredZ)
                    isHit = error < (TGTRad0 + TGTRad90)*2 and alt > TGT_ALT
                    if alt > TGT_ALT then
                        table.insert(TGTx, {t = trackT, x = Wx})
                        table.insert(TGTy, {t = trackT, x = Wy})
                        table.insert(TGTz, {t = trackT, x = Wz})
                    end
                    return isHit
                end

                --ヒットしたらデータを保存
                las1Hit = addData(las1Wx, las1Wy, las1Wz)
                las2Hit = addData(las2Wx, las2Wy, las2Wz)
                las3Hit = addData(las3Wx, las3Wy, las3Wz)
                las4Hit = addData(las4Wx, las4Wy, las4Wz)

                --最小二乗法
                do
                    --一定時間以上前のデータ削除
                    while #TGTx > 1 and TGTx[1].t < trackT - TGT_DEL_TICK do
                        table.remove(TGTx, 1)
                        table.remove(TGTy, 1)
                        table.remove(TGTz, 1)
                    end

                    --最小二乗法
                    a, b = leastSquaresMethod(TGTx)
                    TGTPredX = a*(trackT + TGT_PRED_DELAY) + b
                    TGTPredVx = a
                    a, b = leastSquaresMethod(TGTy)
                    TGTPredY = a*(trackT + TGT_PRED_DELAY) + b
                    TGTPredVy = a
                    a, b = leastSquaresMethod(TGTz)
                    TGTPredZ = a*(trackT + TGT_PRED_DELAY) + b
                    TGTPredVz = a
                end

                function calPiYa(x, z, Px, Py, Pz)
                    --照準面座標系のクォータニオンを生成(中心に自機、標的が正面、ロール角0°の座標系)
                    aimYaw = math.atan(TGTPredX - Px, TGTPredY - Pz)
                    aimPitch = math.atan(TGTPredZ - Py, math.sqrt((TGTPredX - Px)^2 + (TGTPredY - Pz)^2))
                    aimQt = mulQt({math.sin(aimPitch/2), 0, 0, math.cos(aimPitch/2)}, {0, 0, math.sin(aimYaw/2), math.cos(aimYaw/2)})
                    Wx, Wy, Wz = local2World(x, 0, z, TGTPredX, TGTPredZ, TGTPredY, aimQt)
                    return stabilizer2(Px, Py, Pz, lasQt, lasPvx, lasPvy, lasPvz, lasPrvx, lasPrvy, lasPrvz, Wx, Wy, Wz, TGTPredVx, TGTPredVy, TGTPredVz, Wx, Wy, Wz, LASER_STABI_T)
                end

                --地面基準照射点を計算
                -- Z = -(半径*2)
                gndOfstZ = -TGTRad90*2

                --レーザー１は地面、中心
                if trackT%4 == 0 then   --地面基準
                    las1pitch, las1yaw = calPiYa(0, gndOfstZ, las1Px, las1Py, las1Pz)
                elseif trackT%4 == 1 then   --地面ベクトル１
                    las1pitch, las1yaw = calPiYa(0.1, gndOfstZ, las1Px, las1Py, las1Pz)
                elseif trackT%4 == 2 then   --地面ベクトル２
                    las1pitch, las1yaw = calPiYa(0, gndOfstZ - 0.1, las1Px, las1Py, las1Pz)
                else                        --標的の中心
                    las1pitch, las1yaw = calPiYa(0, 0, las1Px, las1Py, las1Pz)
                end
                --レーザー２は±X, ±X±Zの4箇所、レーザー３は±Z, ∓X±Zの4箇所(照準面座標系)
                if trackT%4 == 0 then       -- +0, +90
                    las2pitch, las2yaw = calPiYa(TGTRad0, 0, las2Px, las2Py, las2Pz)
                    las3pitch, las3yaw = calPiYa(0, TGTRad90, las3Px, las3Py, las3Pz)
                elseif trackT%4 == 1 then   -- -0 -90
                    las2pitch, las2yaw = calPiYa(-TGTRad0, 0, las2Px, las2Py, las2Pz)
                    las3pitch, las3yaw = calPiYa(0, -TGTRad90, las3Px, las3Py, las3Pz)
                elseif trackT%4 == 2 then   -- +45 +135
                    las2pitch, las2yaw = calPiYa(TGTRad45, TGTRad45, las2Px, las2Py, las2Pz)
                    las3pitch, las3yaw = calPiYa(TGTRad135, -TGTRad135, las3Px, las3Py, las3Pz)
                else                        -- -45 -135
                    las2pitch, las2yaw = calPiYa(-TGTRad45, -TGTRad45, las2Px, las2Py, las2Pz)
                    las3pitch, las3yaw = calPiYa(-TGTRad135, TGTRad135, las3Px, las3Py, las3Pz)
                end

                --地面とターゲットサイズ更新
                if trackT > LASER_DELAY then
                    if (trackT - LASER_DELAY)%4 == 0 then
                        --基準座標
                        gndX, gndY, gndZ = las1Wx, las1Wy, las1Wz
                    elseif (trackT - LASER_DELAY)%4 == 1 then
                        --地面座標１を保持
                        gndX1, gndY1, gndZ1 = las1Wx, las1Wy, las1Wz
                    elseif (trackT - LASER_DELAY)%4 == 2 then
                        --地面座標２と地面座標１を使い、法線ベクトルを算出
                        nomX, nomY, nomZ = calNomVec(las1Wx - gndX, las1Wy - gndY, las1Wz - gndZ, gndX1 - gndX, gndY1 - gndY, gndZ1 - gndZ)
                    end

                    --対角線ヒット率に基づき半径を更新(0ヒットならば縮小、2ヒットならば拡大)
                    if (trackT - LASER_DELAY)%4 == 0 then
                        isHit0 = las2Hit
                        isHit90 = las3Hit
                    elseif (trackT - LASER_DELAY)%4 == 1 then
                        if isHit0 and las2Hit then
                            TGTRad0 = TGTRad0*TGT_RADIUS_GAIN
                        elseif not isHit0 and not las2Hit then
                            TGTRad0 = TGTRad0/TGT_RADIUS_GAIN
                        end
                        if isHit90 and las3Hit then
                            TGTRad90 = TGTRad90*TGT_RADIUS_GAIN
                        elseif not isHit90 and not las3Hit then
                            TGTRad90 = TGTRad90/TGT_RADIUS_GAIN
                        end
                    elseif (trackT - LASER_DELAY)%4 == 2 then
                        isHit45 = las2Hit
                        isHit135 = las3Hit
                    else
                        if isHit45 and las2Hit then
                            TGTRad45 = TGTRad45*TGT_RADIUS_GAIN
                        elseif not isHit45 and not las2Hit then
                            TGTRad45 = TGTRad45/TGT_RADIUS_GAIN
                        end
                        if isHit135 and las3Hit then
                            TGTRad135 = TGTRad135*TGT_RADIUS_GAIN
                        elseif not isHit135 and not las3Hit then
                            TGTRad135 = TGTRad135/TGT_RADIUS_GAIN
                        end
                    end
                elseif trackT == LASER_DELAY then
                    nomX, nomY, nomZ = calNomVec(las1Wx - gndX, las1Wy - gndY, las1Wz - gndZ, las2Wx - gndX, las2Wy - gndY, las2Wz - gndZ)
                end

                --ターゲット座標出力
                if trackT > LASER_DELAY then
                    OUN(1, TGTPredX)
                    OUN(2, TGTPredY)
                    OUN(3, TGTPredZ)
                    OUN(4, TGTPredVx)
                    OUN(5, TGTPredVy)
                    OUN(6, TGTPredVz)

                    if las1Hit then
                        OUN(20, las1Wx)
                        OUN(21, las1Wy)
                        OUN(22, las1Wz)
                    end


                    OUN(23, TGTRad90)
                    OUN(24, TGTRad0)
                end

                trackT = trackT + 1
            else
                --レーザー１は直接ターゲットを補足
                --レーザー２は追尾に備えてターゲット下の地面を補足しておく
                --それ以外はニュートラル
                las1pitch, las1yaw = stabilizer2(las1Px, las1Py, las1Pz, lasQt, lasPvx, lasPvy, lasPvz, lasPrvx, lasPrvy, lasPrvz, losWx, losWy, losWz, 0, 0, 0, losWx, losWy, losWz, LASER_STABI_T)
                gndOfstZ = -TGT_RADIUS
                theta = math.atan(las2Pz - losWy, las2Px - losWx)
                gndOfstX = math.cos(theta)*TGT_RADIUS*2
                gndOfstY = math.sin(theta)*TGT_RADIUS*2
                las2pitch, las2yaw = stabilizer2(las2Px, las2Py, las2Pz, lasQt, lasPvx, lasPvy, lasPvz, lasPrvx, lasPrvy, lasPrvz, losWx + gndOfstX, losWy + gndOfstY, losWz + gndOfstZ, 0, 0, 0, losWx + gndOfstX, losWy + gndOfstY, losWz + gndOfstZ, LASER_STABI_T)

                las3pitch, las3yaw = 0, 0
                las4pitch, las4yaw = 0, 0

                --座標出力
                OUN(1, losWx)
                OUN(2, losWy)
                OUN(3, losWz)
                OUN(4, 0)
                OUN(5, 0)
                OUN(6, 0)
            end
        end

        --レーザー俯仰角を制限
        las1pitch, las1yaw = clamp(las1pitch, -0.125, 0.125), clamp(las1yaw, -0.125, 0.125)
        las2pitch, las2yaw = clamp(las2pitch, -0.125, 0.125), clamp(las2yaw, -0.125, 0.125)
        las3pitch, las3yaw = clamp(las3pitch, -0.125, 0.125), clamp(las3yaw, -0.125, 0.125)
        las4pitch, las4yaw = clamp(las4pitch, -0.125, 0.125), clamp(las4yaw, -0.125, 0.125)
        OUB(1, true)

        OUB(10, isTracking)

        OUN(31, seatYawControl)

        OUN(10, -las1yaw*8)
        OUN(11, -las1pitch*8)
        OUN(12, -las2yaw*8)
        OUN(13, -las2pitch*8)
        OUN(14, -las3yaw*8)
        OUN(15, -las3pitch*8)
        OUN(16, -las4yaw*8)
        OUN(17, -las4pitch*8)

        --レーザー方向の遅延
        do
            table.insert(las1Direc, {las1pitch, las1yaw})
            table.insert(las2Direc, {las2pitch, las2yaw})
            table.insert(las3Direc, {las3pitch, las3yaw})
            table.insert(las4Direc, {las4pitch, las4yaw})
            table.insert(lasQtBuf, {table.unpack(lasQt)})

            if #las1Direc > LASER_DELAY then
                table.remove(las1Direc, 1)
                table.remove(las2Direc, 1)
                table.remove(las3Direc, 1)
                table.remove(las4Direc, 1)
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
