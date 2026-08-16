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


require("required")

gain1 = {0.1, 0.002, 0.00001}
gain2 = {0.3, 0.01, 0.0005}

--関数
do
    function clamp(x, min, max)
        if x >= max then
            x = max
        elseif x <= min then
            x = min
        end
        return x
    end

    --ベクトル同士の距離
    function distVec(x, y)
        sum = 0
        for i = 1, #x do
            sum = sum + (x[i] - y[i])^2
        end
        return math.sqrt(sum)
    end

    ---@param Wx number 自身の位置[m]
    ---@param Wz number 自身の位置[m]
    ---@param Wy number 自身の位置[m]
    ---@param Qt table 自身の姿勢[クォータニオン]
    ---@param Wvx number 自身の速度[m/tick]
    ---@param Wvz number 自身の速度[m/tick]
    ---@param Wvy number 自身の速度[m/tick]
    ---@param Wrvx number 自身の角速度[rad/tick]
    ---@param Wrvz number 自身の角速度[rad/tick]
    ---@param Wrvy number 自身の角速度[rad/tick]
    ---@param Tx number ターゲット位置[m]
    ---@param Ty number ターゲット位置[m]
    ---@param Tz number ターゲット位置[m]
    ---@param Tvx number ターゲット速度[m/tick]
    ---@param Tvy number ターゲット速度[m/tick]
    ---@param Tvz number ターゲット速度[m/tick]
    ---@param DELAY number 予測する時間[tick]
    ---@return number pitch [回転]
    ---@return number yaw [回転]
    --Prv[rad/tick], Tはターゲット位置と速度, 2軸スタビ
    function stabilizer2(Wx, Wy, Wz, Qt, Wvx, Wvy, Wvz, Wrvx, Wrvy, Wrvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, DELAY)
        local TLx, TLy, TLz, TLvx, TLvy, TLvz, Lrvx, Lrvy, Lrvz, losRvx, losRvy, losRvz, Vrx, Vry, Vrz, T2
        --ローカル座標
        TLx, TLy, TLz = world2Local(Tx, Ty, Tz, Wx, Wy, Wz, Qt)
        TLvx, TLvy, TLvz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Qt)
        Lrvx, Lrvy, Lrvz = world2Local(Wrvx, Wrvy, Wrvz, 0, 0, 0, Qt)
        --相対速度
        Vrx, Vry, Vrz = TLvx - Wvx, TLvy - Wvy, TLvz - Wvz
        --視線角速度
        T2 = TLx*TLx + TLy*TLy + TLz*TLz
        losRvx = (TLy*Vrz - TLz*Vry)/T2 - Lrvx
        losRvy = (TLz*Vrx - TLx*Vrz)/T2 - Lrvy
        losRvz = (TLx*Vry - TLy*Vrx)/T2 - Lrvz
        --未来位置
        TLx, TLy, TLz = rotateRv(TLx, TLy, TLz, losRvx, losRvy, losRvz, DELAY)
        return rect2Polar(TLx, TLy, TLz, false)
    end

    --位置ベクトルを角速度rv[rad/tick]でt[tick]回転させる
    function rotateRv(x, y, z, rvx, rvy, rvz, t)
        local abs, h, s, p
        abs = math.sqrt(rvx*rvx + rvy*rvy + rvz*rvz)
        if abs > 0 then
            h = abs*t/2
            s = math.sin(h)/abs
            p = mulQt({rvx*s, rvy*s, rvz*s, math.cos(h)}, mulQt({x, y, z, 0}, {-rvx*s, -rvy*s, -rvz*s, math.cos(h)}))
            x, y, z = TUP(p)
        end
        return x, y, z
    end

    --２つのベクトルから法線ベクトルを算出(gndが基準)
    function calNomVec(a, b, gnd)
        x1, y1, z1 = TUP(a)
        x2, y2, z2 = TUP(b)
        gndX, gndY, gndZ = TUP(gnd)
        x1, y1, z1 = x1 - gndX, y1 - gndY, z1 - gndZ
        x2, y2, z2 = x2 - gndX, y2 - gndY, z2 - gndZ
        nom = {
            y1*z2 - z1*y2,
            z1*x2 - x1*z2,
            x1*y2 - y1*x2
        }
        nx, ny, nz = TUP(nom)
        --正規化
        len = math.sqrt(nx*nx + ny*ny + nz*nz)
        if len > 0 then
            nom = {nx/len, ny/len, nz/len}
        end
        --上下逆なら反転
        if nz < 0 then
            nom = {-nom[1], -nom[2], -nom[3]}
        end
        return nom
    end

    --α-β-γフィルタ(z: 観測値, x:状態量, gain: α-β-γフィルタのゲイン, N: 同時観測数)
    function ABGFUpdate(z, x, gain, N)
        gainN = 2*N/(N + 1) --サンプル数により信頼度を上げる
        for i = 1, 3 do
            residual = z[i] - x[i]
            --更新
            for j = 0, 6, 3 do
                x[i + j] = x[i + j] + gain[j//3 + 1]*gainN*residual
            end
        end
        return x
    end

    function ABGFPredict(x)
        for i = 1, 3 do
            x[i] = x[i] + x[i + 3] + x[i + 6]/2
            x[i + 3] = x[i + 3] + x[i + 6]
        end
        return x
    end

    function copyTable(x)
        return {TUP(x)}
    end
end

t = 0
seatYawEP = 0
seatLosQtPrev = {0, 0, 0, 1}
lasDirec = {{0, 0, 0, 0, 0, 0, 0, 0}}
lasQtBuf = {{0, 0, 0, 1}}
trackInPre = false
seatResetPre = false
isTracking = false
is1P = false
trackT = 0
notHitT = 0
lasDirecSet = {}    --出力するヨー、ピッチ
lasPos = {}         --レーザ自身の座標

function onTick()
    --インプット(右手系に変換する)
    do
        lasQt = euler2Qt(INN(4), INN(5), INN(6))
        lasLvx, lasLvy, lasLvz = INN(7)/60, INN(9)/60, INN(8)/60
        lasWrvx, lasWrvy, lasWrvz = -INN(10)*pi2/60, -INN(12)*pi2/60, -INN(11)*pi2/60

        lasDist = {INN(27), INN(28), INN(29), INN(30)}

        bodQt = euler2Qt(INN(13), INN(14), INN(15))
        bodWrvx, bodWrvy, bodWrvz = -INN(16)*pi2/60, -INN(18)*pi2/60, -INN(17)*pi2/60

        seatQt = euler2Qt(INN(22), INN(23), INN(24))

        seatLosYaw, seatLosPitch = INN(25)*pi2, INN(26)*pi2

        trackIn = INN(31)%10 == 1
        seatReset = INN(31)//10 == 1
        isPower = INN(32) == 1

        vehicleCamMode = PRN("Vehicle Camera Mode")
        TGT_RADIUS0 = PRN("Target radius [m]")

        --視線の中心座標
        FPSPos = offset("FPS view offset", INN(19), INN(21), INN(20), seatQt)
        TPSPos = offset("TPS view offset", INN(19), INN(21), INN(20), seatQt)

        --レーザの座標
        for i = 1, 4 do
            lasPos[i] = offset("Laser offset "..i, INN(1), INN(3), INN(2), lasQt)
        end

        --レーザーの指している座標
        lasPoint = {}
        for i = 1, 7, 2 do
            Lx, Ly, Lz = polar2Rect(lasDirec[1][i + 1], lasDirec[1][i], lasDist[(i + 1)/2], false)
            table.insert(lasPoint, {local2World(Lx, Ly, Lz, INN(1), INN(3), INN(2), lasQtBuf[1])})
        end

        --視線の基準となる真の姿勢(球面補間)
        do
            a, b, c, d = TUP(seatLosQtPrev)
            x, y, z, w = TUP(seatQt)
            dot = a*x + b*y + c*z + d*w     --内積
            if dot < 0 then                 --遠回り回転なら逆へ回転させる
                dot, x, y, z, w = -dot, -x, -y, -z, -w
            end
            theta = math.acos(dot)          --必要回転角度
            if theta > 0.0001 then          --０除算対策
                e = math.sin(0.95*theta)/math.sin(theta)
                f = math.sin(0.05*theta)/math.sin(theta)
            else
                e, f = 0.95, 0.05
            end
            x = e*a + f*x
            y = e*b + f*y
            z = e*c + f*z
            w = e*d + f*w
            e = math.sqrt(x*x + y*y + z*z + w*w)    --正規化
            seatLosQt = {x/e, y/e, z/e, w/e}
            seatLosQtPrev = copyTable(seatLosQt)
        end
    end

    --出力リセット
    for i = 1, 32 do
        OUN(i, 0)
    end

    --追尾開始のパルス
    trackPulse = not trackInPre and trackIn
    trackInPre = trackIn

    --シート方向リセットのパルス
    seatResetPulse = not seatResetPre and seatReset
    seatResetPre = seatReset

    --シートピボットのヨー、向きたい方位角の計算
    do
        Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, seatQt)
        Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, bodQt)
        _, seatCntYaw = rect2Polar(Lx, Ly, Lz, false)
        Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, lasQt)
        _, turretAzi = rect2Polar(Wx, Wy, Wz, false)
    end

    --phys = 0の時を防ぎ、レーザの振動をなくす
    if t > 5 and isPower then
        --シートピボット回転速度計算
        do
            if seatResetPulse then
                seatTGTAzi = turretAzi
            end

            --t[tick]後の未来位置へ
            Wx, Wy, Wz = rotateRv(math.sin(seatTGTAzi*pi2), math.cos(seatTGTAzi*pi2), 0, bodWrvx, bodWrvz, bodWrvy, 7.5)
            --ローカル座標変換
            ex, ey, ez = world2Local(0, 0, 1, 0, 0, 0, bodQt)  --Z軸単位ベクトル
            Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, bodQt)
            --逆投影(?)しつつ極座標へ
            _, seatIdealYaw = rect2Polar(Lx - ex*Lz/ez, Ly - ey*Lz/ez, 0, false)
        end

        --視線が指している座標の計算
        do
            isFPS = is1P or vehicleCamMode == 2
            
            --視点からの距離を計算
            pos = isFPS and FPSPos or TPSPos
            if lasDist[1] == 4000 then
                if lasDist[2] == 4000 then
                    losDist = 300
                else
                    losDist = distVec(lasPoint[2], pos)
                end
            else
                losDist = distVec(lasPoint[1], pos)
            end

            --ワールド視線方向
            if isFPS then     --一人称または固定の時
                --ローカル座標系
                Lx, Ly, Lz = polar2Rect(seatLosPitch, seatLosYaw, losDist, true)
                losWx, losWy, losWz = local2World(Lx, Ly, Lz, FPSPos[1], FPSPos[2], FPSPos[3], seatQt)
            else              --水平固定または自由
                --ワールド座標系でピッチのみ零点シフト
                Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, seatLosQt)
                Wpi, Wya = rect2Polar(Wx, Wy, Wz, true)
                losWx, losWy, losWz = polar2Rect(seatLosPitch + Wpi, seatLosYaw + Wya, losDist, true)
                losWx, losWy, losWz = losWx + TPSPos[1], losWy + TPSPos[2], losWz + TPSPos[3]
            end
        end

        --レーザ方向
        do
            --追尾開始判定
            if trackPulse and not isTracking and lasDist[1] ~= 0 and lasDist[1] ~= 4000 then
                isTracking = true
                trackT = 0
                notHitT = 0
                gnd = copyTable(lasPoint[2])
                gnd1 = copyTable(gnd)
                gnd1[1] = gnd1[1] + 1
                nom = {0, 0, 1}
                TGT = {lasPoint[1][1], lasPoint[1][2], lasPoint[1][3], 0, 0, 0, 0, 0, 0}
                ID = 2001
                nextLas = copyTable(TGT)
                TGTRadius = TGT_RADIUS0
                hitSum = 0

                --地面を補足したかどうか
                isGndExist = lasDist[2] ~= 0 and lasDist[2] ~= 4000 and lasDist[2] < lasDist[1]
                
            --追尾終了判定
            elseif (isTracking and trackPulse) or lasDist[1] == 0 or notHitT > 200 then
                isTracking = false
            end

            --追尾中
            if isTracking then
                hitN, avgX, avgY, avgZ = 0, 0, 0, 0
                isHit = {}

                --ヒットしたどうか判定
                for i = 1, 4 do
                    Wx, Wy, Wz = TUP(lasPoint[i])
                    alt = (Wx - gnd[1])*nom[1] + (Wy - gnd[2])*nom[2] + (Wz - gnd[3])*nom[3]    --対地高度
                    error = distVec(lasPoint[i], nextLas)                                       --照射点と予測座標の距離
                    hit = error < TGTRadius*3 and (alt > 0.01 or not isGndExist)
                    if hit then
                        hitN, avgX, avgY, avgZ = hitN + 1, avgX + Wx, avgY + Wy, avgZ + Wz
                        hitSum = hitSum + 1
                    end
                    table.insert(isHit, hit)
                end

                --ABF
                do
                    --ヒットした座標のみで平均化
                    --更新があるときのみ更新
                    if hitN > 0 then
                        avgPos = {avgX/hitN, avgY/hitN, avgZ/hitN}
                        TGT = ABGFUpdate(avgPos, TGT, gain1, hitN)
                        notHitT = 0

                        --次に照射する座標
                        nextLas = ABGFUpdate(avgPos, nextLas, gain2, hitN)
                    else
                        notHitT = notHitT + 1
                    end
                    --予測
                    TGT = ABGFPredict(TGT)
                    nextLas = ABGFPredict(nextLas)
                end

                function setPiYa(x, z, lasIndex)
                    --照準面座標系のクォータニオンを生成(中心に自機、標的が正面、ロール角0°の座標系)
                    posX, posY, posZ = TUP(lasPos[lasIndex])
                    nlX, nlY, nlZ = TUP(nextLas)
                    aimYaw = -math.atan(nlX - posX, nlY - posY)
                    aimPitch = math.atan(nlZ - posZ, math.sqrt((nlX - posX)^2 + (nlY - posY)^2))
                    aimQt = mulQt({math.sin(aimPitch/2), 0, 0, math.cos(aimPitch/2)}, {0, 0, math.sin(aimYaw/2), math.cos(aimYaw/2)})
                    Wx, Wy, Wz = local2World(x, 0, z, nlX, nlY, nlZ, aimQt)
                    pitch, yaw = stabilizer2(posX, posY, posZ, lasQt, lasLvx, lasLvy, lasLvz, lasWrvx, lasWrvy, lasWrvz, Wx, Wy, Wz, nextLas[4], nextLas[5], nextLas[6], 4)
                    lasDirecSet[lasIndex*2 - 1], lasDirecSet[lasIndex*2] = yaw, pitch
                end

                --地面基準照射点を計算
                -- Z = -(半径*2)
                gndOfstZ = -TGTRadius*2

                --レーザ１は中心、地面
                if isGndExist then
                    i = trackT%4
                    setPiYa(i == 2 and 0.1 or 0, i == 0 and 0 or i == 3 and gndOfstZ - 0.1 or gndOfstZ, 1)
                else    --地面がないときは中心
                    setPiYa(0, 0, 1)
                end

                --レーザ２/３は八角形に投射(半径は一律)
                theta = (trackT%8)*pi2/8
                x = TGTRadius*math.cos(theta)
                z = TGTRadius*math.sin(theta)
                setPiYa(x, z, 2)
                theta = (trackT%8 + 0.5)*pi2/8
                x = TGTRadius*math.cos(theta)
                z = TGTRadius*math.sin(theta)
                setPiYa(-x, -z, 3)
                --レーザ４は四角形に投射(半径は半分)
                theta = (trackT%4)*pi2/4
                x = TGTRadius*math.cos(theta)/2
                z = TGTRadius*math.sin(theta)/2
                setPiYa(x, z, 4)

                --地面とターゲットサイズ更新
                if trackT > 4 then
                    if (trackT - 4)%4 == 1 then
                        --基準座標
                        gnd = copyTable(lasPoint[1])
                    elseif (trackT - 4)%4 == 2 then
                        --地面座標１を保持
                        gnd1 = copyTable(lasPoint[1])
                    elseif (trackT - 4)%4 == 3 then
                        --地面座標２と地面座標１を使い、法線ベクトルを算出
                        nom = calNomVec(lasPoint[1], gnd1, gnd)
                    end

                    --ヒット率に基づき半径を更新
                    if (trackT - 4)%8 == 0 then
                        if isHit[1] then
                            if hitSum/26 > 0.3 then
                                TGTRadius = TGTRadius*1.05
                            elseif hitSum/26 < 0.15 then
                                TGTRadius = TGTRadius/1.05
                            end
                        end
                        hitSum = 0
                    end
                elseif trackT == 4 then
                    nom = calNomVec(lasPoint[1], lasPoint[2], gnd)
                end

                trackT = trackT + 1
            else
                --座標出力
                TGT = {losWx, losWy, losWz, 0, 0, 0, 0, 0, 0}
                ID = 609001

                --レーザ１は直接ターゲットを補足
                --レーザ２は追尾に備えてターゲット下の地面を補足しておく
                --それ以外はニュートラル
                if lasDist[1] == 4000 and lasDist[2] == 4000 then
                    Lx, Ly, Lz = polar2Rect(seatLosPitch, seatLosYaw, 10^5, true)
                    losWx, losWy, losWz = local2World(Lx, Ly, Lz, FPSPos[1], FPSPos[2], FPSPos[3], seatQt)
                end

                las1pitch, las1yaw = stabilizer2(lasPos[1][1], lasPos[1][2], lasPos[1][3], lasQt, lasLvx, lasLvy, lasLvz, lasWrvx, lasWrvy, lasWrvz, losWx, losWy, losWz, 0, 0, 0, 4)
                gndOfstZ = -TGT_RADIUS0
                theta = math.atan(lasPos[2][2] - losWy, lasPos[2][1] - losWx)
                gndOfstX = math.cos(theta)*TGT_RADIUS0*2
                gndOfstY = math.sin(theta)*TGT_RADIUS0*2
                las2pitch, las2yaw = stabilizer2(lasPos[2][1], lasPos[2][2], lasPos[2][3], lasQt, lasLvx, lasLvy, lasLvz, lasWrvx, lasWrvy, lasWrvz, losWx + gndOfstX, losWy + gndOfstY, losWz + gndOfstZ, 0, 0, 0, 4)
                lasDirecSet = {las1yaw, las1pitch, las2yaw, las2pitch, 0, 0, 0, 0}
            end
        end

        OUB(1, true)

        OUB(10, isTracking)

        OUN(31, seatYawControl)

        for i = 1, 9 do
            OUN(i, TGT[i])
        end

        --レーザ俯仰角を制限, レーザ方向出力
        for i = 1, 8 do
            lasDirecSet[i] = clamp(lasDirecSet[i], -0.25, 0.25)
            OUN(9 + i, -lasDirecSet[i]*8)
        end

        --カメラとレーザの方向と倍率
        --18~22

        --SRD3
        for i = 1, 3 do
            OUN(22 + i, TGT[i])
        end
        OUN(26, ID)

        --レーザ方向の遅延
        do
            table.insert(lasDirec, copyTable(lasDirecSet))
            table.insert(lasQtBuf, copyTable(lasQt))

            if #lasDirec > 4 then
                table.remove(lasDirec, 1)
                table.remove(lasQtBuf, 1)
            end
        end
    elseif t <= 5 then
        t = t + 1
        seatIdealYaw = 0
        seatTGTAzi = turretAzi
    end

    --シートピボットのPID制御
    do
        error = (seatIdealYaw - seatCntYaw + 0.5)%1 - 0.5
        seatYawControl = 8*error + 15*(error - seatYawEP)
        seatYawEP = error
        seatYawControl = clamp(seatYawControl*6.4, -10, 10)
        --nan対策
        seatYawControl = seatYawControl ~= seatYawControl and 0 or seatYawControl
    end
    
    --一人称視点フラグ
    is1P = false
end

function onDraw()
    is1P = true

    --for debug
    screen.setColor(0, 255, 0)
    screen.drawText(0, 0, debug)
end
