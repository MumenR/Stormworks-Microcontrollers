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

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        local phase = ticks / 60
        local yaw = math.sin(phase * 0.35) * 0.08
        local pitch = math.sin(phase * 0.22) * 0.02

        -- Vehicle / laser position: X, Z, Y input order
        simulator:setInputNumber(1, ticks / 60 * 4)
        simulator:setInputNumber(2, 0)
        simulator:setInputNumber(3, 0)

        -- Laser orientation, velocity, and angular velocity
        simulator:setInputNumber(4, pitch)
        simulator:setInputNumber(5, 0)
        simulator:setInputNumber(6, yaw)
        simulator:setInputNumber(7, 4)
        simulator:setInputNumber(8, 0)
        simulator:setInputNumber(9, 0)
        simulator:setInputNumber(10, 0)
        simulator:setInputNumber(11, 0)
        simulator:setInputNumber(12, 0)

        -- Body orientation and angular velocity
        simulator:setInputNumber(13, pitch)
        simulator:setInputNumber(14, 0)
        simulator:setInputNumber(15, yaw)
        simulator:setInputNumber(16, 0)
        simulator:setInputNumber(17, 0)
        simulator:setInputNumber(18, 0)

        -- Seat position and orientation
        simulator:setInputNumber(19, ticks / 60 * 4)
        simulator:setInputNumber(20, 0)
        simulator:setInputNumber(21, 0)
        simulator:setInputNumber(22, pitch)
        simulator:setInputNumber(23, 0)
        simulator:setInputNumber(24, yaw)

        -- TPS sight direction (turns)
        simulator:setInputNumber(25, math.sin(phase * 0.5) * 0.03)
        simulator:setInputNumber(26, math.sin(phase * 0.3) * 0.015)

        -- Four valid laser ranges. Trigger tracking after initial buffers fill.
        simulator:setInputNumber(27, 1200)
        simulator:setInputNumber(28, 1200)
        simulator:setInputNumber(29, 1200)
        simulator:setInputNumber(30, 1200)
        simulator:setInputNumber(31, ticks == 10 and 1 or 0)
        simulator:setInputNumber(32, 1)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("required")
require("math.math")
require("math.vector")
require("math.coordTrans")
require("math.filter")
require("control.stabilizer")
require("control.pid")
require("control.cam")

SEAT_STABI_T = 7.5
SEAT_STABI_P = 8
SEAT_STABI_D = 15
SEAT_PIVOT = 32/5

LASER_STABI_T = 4
LASER_DELAY = 4

GND_OFST = -2       --地面判定は標的のn[m]下に向けて行う
TGT_ALT = 0.01      --標的の高さがn[m]以上で目標と判定
TGT_PRED_DELAY = 0  --n[tick]後の未来位置を予測
TRC_END_TICK = 200  --n[tick]以上検出しなかったら追尾終了
TGT_RADIUS_GAIN = 1.05

NO_TGT_DIST = 500   --レーザーが当たってないときの仮想距離

gain1 = {0.1, 0.002, 0.00001}
gain2 = {0.3, 0.01, 0.0005}

SLERP_T = 0.05
MAX_FOV = 2.2/2
MIN_FOV = 0.025/2

--関数
do
    function setPiYa(x, z, lasIndex)
        --照準面座標系のクォータニオンを生成(中心に自機、標的が正面、ロール角0°の座標系)
        posX, posY, posZ = TUP(lasPos[lasIndex])
        nlX, nlY, nlZ = TUP(nextLas)
        aimYaw = -math.atan(nlX - posX, nlY - posY)
        aimPitch = math.atan(nlZ - posZ, math.sqrt((nlX - posX)^2 + (nlY - posY)^2))
        aimQt = mulQt({math.sin(aimPitch/2), 0, 0, math.cos(aimPitch/2)}, {0, 0, math.sin(aimYaw/2), math.cos(aimYaw/2)})
        pitch, yaw = stabilizer2(lasPos[lasIndex], lasQt, lasLv, lasWrv, local2World({x, 0, z}, nextLas, aimQt), {nextLas[4], nextLas[5], nextLas[6]}, LASER_STABI_T)
        lasDirecSet[lasIndex*2 - 1], lasDirecSet[lasIndex*2] = yaw, pitch
    end
end

seatYawES, seatYawEP = 0, 0
seatPitchES, seatPitchEP = 0, 0

t = 0
pitchPrev, yawPrev = 0, 0
seatLosQtPrev = {0, 0, 0, 1}
lasDirec = {{0, 0, 0, 0, 0, 0, 0, 0}}
lasQtBuf = {{0, 0, 0, 1}}
losWxyz = {0, 0, 0}
trackInPre = false
seatResetPre = false
scopePre = false
zoomManu = 0
zoomCtrl = 0
isTracking = false
is1P = false
GNDCorrectionT = 0
trackT = 0
notHitT = 0
lasDirecSet = {}    --出力するヨー、ピッチ
lasPos = {}         --レーザ自身の座標

function onTick()
    --インプット(右手系に変換する)
    do
        lasQt = euler2Qt(INN(4), INN(5), INN(6))
        lasLv = {INN(7)/60, INN(9)/60, INN(8)/60}
        lasWrv = {-INN(10)*pi2/60, -INN(12)*pi2/60, -INN(11)*pi2/60}

        lasDist = {INN(27), INN(28), INN(29), INN(30)}

        bodQt = euler2Qt(INN(13), INN(14), INN(15))
        bodWrv = {-INN(16)*pi2/60, -INN(18)*pi2/60, -INN(17)*pi2/60}

        seatQt = euler2Qt(INN(22), INN(23), INN(24))

        seatLosYaw, seatLosPitch = INN(25)*pi2, INN(26)*pi2

        trackIn = INN(31)%10 == 1
        seatReset = INN(31)//10 == 1
        isScope = INN(31)//100 == 1
        isPower = INN(31)//1000 == 1

        --スコープ用
        zoomIn = INN(32)%10 == 2
        zoomOut = INN(32)%10 == 0
        camPitchCtrl = INN(32)//10%10 - 1
        camYawCtrl = INN(32)//100%10 - 1

        CAM_SPEED_GAIN = PRN("Cam speed gain")
        ZOOM_SPEED_GAIN = PRN("Zoom speed gain")

        vehicleCamMode = PRN("Vehicle Camera Mode")
        TGT_RADIUS0 = PRN("Target radius [m]")

        MIN_FOV_CTRL = PRN("Cam min fov [rad]")/2
        MAX_FOV_CTRL = PRN("Cam max fov [rad]")/2

        --視線の中心座標
        FPSPos = offset("FPS view offset", INN(19), INN(21), INN(20), seatQt)
        TPSPos = offset("TPS view offset", INN(19), INN(21), INN(20), seatQt)

        camPos = offset("Cam offset", INN(1), INN(3), INN(2), lasQt)
        lasPosPointer = offset("Laser offset Pointer", INN(1), INN(3), INN(2), lasQt)

        --レーザの座標
        for i = 1, 4 do
            lasPos[i] = offset("Laser offset "..i, INN(1), INN(3), INN(2), lasQt)
        end

        --レーザーの指している座標
        lasPoint = {}
        for i = 1, 7, 2 do
            Lxyz = polar2Rect(lasDirec[1][i + 1], lasDirec[1][i], lasDist[(i + 1)/2], false)
            table.insert(lasPoint, local2World(Lxyz, {INN(1), INN(3), INN(2)}, lasQtBuf[1]))
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
                e = math.sin((1 - SLERP_T)*theta)/math.sin(theta)
                f = math.sin(SLERP_T*theta)/math.sin(theta)
            else
                e, f = (1 - SLERP_T), SLERP_T
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
        OUB(i, false)
    end

    --追尾開始のパルス
    trackPulse = not trackInPre and trackIn
    trackInPre = trackIn

    --シート方向リセットのパルス
    seatResetPulse = not seatResetPre and seatReset
    seatResetPre = seatReset

    --スコープ使用時のパルス
    scopePulse = not scopePre and isScope
    scopePre = isScope

    --シートピボットのヨー、砲塔正面方位角の計算
    do
        _, seatCntYaw = rect2Polar(world2Local(local2World({0, 1, 0}, ZERO3, seatQt), ZERO3, bodQt), false)
        _, turretAzi = rect2Polar(local2World({0, 1, 0}, ZERO3, lasQt), false)
    end

    --phys = 0の時を防ぎ、レーザの振動をなくす
    if t > 5 and isPower then
        --シートピボット回転速度計算
        do
            if seatResetPulse then
                seatTGTAzi = turretAzi
            end

            --Z軸単位ベクトル
            ex, ey, ez = TUP(world2Local({0, 0, 1}, ZERO3, bodQt))
            --t[tick]後のローカル未来位置へ
            Lx, Ly, Lz = TUP(world2Local(rotateRv({math.sin(seatTGTAzi*pi2), math.cos(seatTGTAzi*pi2), 0}, bodWrv, SEAT_STABI_T), ZERO3, bodQt))
            --逆投影(?)しつつ極座標へ
            _, seatIdealYaw = rect2Polar({Lx - ex*Lz/ez, Ly - ey*Lz/ez, 0}, false)
        end

        --視線が指している座標の計算
        do
            isFPS = is1P or vehicleCamMode == 2
            
            --視点からの距離を計算
            pos = isScope and camPos or (isFPS and FPSPos or TPSPos)
            if lasDist[1] == 4000 then
                if lasDist[2] == 4000 then
                    losDist = NO_TGT_DIST
                else
                    losDist = vecDist(lasPoint[2], pos)
                end
            else
                losDist = vecDist(lasPoint[1], pos)
            end

            --スコープの向き
            if isScope then
                --ズーム倍率計算
                if zoomIn then
                    zoomManu = clamp(zoomManu + ZOOM_SPEED_GAIN/60, 0, 1)
                elseif zoomOut then
                    zoomManu = clamp(zoomManu - ZOOM_SPEED_GAIN/60, 0, 1)
                end
                zoomCtrl, zoomRadian = calZoom(zoomManu, MIN_FOV_CTRL, MAX_FOV_CTRL, MIN_FOV, MAX_FOV)

                if not isTracking then
                    --スコープ方向初期値：視線方位角を維持、仰角はローカル水平にリセット
                    if scopePulse then
                        losLxyz = world2Local(losWxyz, camPos, lasQt)
                        losWyz = {losLxyz[1], losLxyz[2], 0}
                        losWPitch, losWYaw = rect2Polar(losWyz, false)
                    end

                    Lxyz = world2Local(polar2Rect(losWPitch, losWYaw, 1, false), ZERO3, lasQt)  --ローカル座標にして
                    Lxyz = rotateRv(Lxyz, {camPitchCtrl, 0, -camYawCtrl}, CAM_SPEED_GAIN/60)    --回転

                    Lpi, Lya = rect2Polar(Lxyz, false)    --極座標にし
                    Lxyz = polar2Rect(clamp(Lpi, -0.25, 0.25), Lya, 1, false) --ピッチ角制限
                    losWPitch, losWYaw = rect2Polar(local2World(Lxyz, ZERO3, lasQt), false) --ワールド座標に戻す

                    --向くべき方向を計算
                    losWxyz = vecAdd1(polar2Rect(losWPitch, losWYaw, 1e6, false), camPos)
                end

            else    --視点の向き
                if isFPS then     --一人称または固定の時
                    --普通のローカル座標系→ワールド座標系
                    losWxyz = local2World(polar2Rect(seatLosPitch, seatLosYaw, losDist, true), FPSPos, seatQt)
                else              --水平固定または自由
                    --ワールド座標系でピッチのみ零点シフト→ワールド座標系
                    Wpi, Wya = rect2Polar(local2World({0, 1, 0}, ZERO3, seatLosQt), true)
                    losWxyz = vecAdd1(polar2Rect(seatLosPitch + Wpi, seatLosYaw + Wya, losDist, true), TPSPos)
                end
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
            elseif (isTracking and trackPulse) or lasDist[1] == 0 or notHitT > TRC_END_TICK then
                isTracking = false
            end

            --追尾中
            if isTracking then
                hitN, avgPos = 0, {0, 0, 0}
                isHit = {}

                --ヒットしたどうか判定
                for i = 1, 4 do
                    alt = vecDot1(vecSub1(lasPoint[i], gnd), nom)                               --対地高度
                    error = vecDist(lasPoint[i], nextLas)                                       --照射点と予測座標の距離
                    hit = error < TGTRadius*3 and (alt > TGT_ALT or not isGndExist)
                    if hit then
                        hitN, avgPos = hitN + 1, vecAdd1(avgPos, lasPoint[i])
                        hitSum = hitSum + 1
                    end
                    table.insert(isHit, hit)
                end

                --ABGF
                do
                    --ヒットした座標のみで平均化
                    --更新があるときのみ更新
                    if hitN > 0 then
                        avgPos = vecMulScalar1(avgPos, 1/hitN)
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

                --地面基準照射点を計算
                -- Z = -(半径*2)
                gndOfstZ = -TGTRadius*2

                --レーザ１は中心、地面
                if isGndExist then
                    local p = ({
                        {0, 0},
                        {0, gndOfstZ},
                        {0.1, gndOfstZ},
                        {0, gndOfstZ - 0.1}
                    })[trackT%4+1]
                    setPiYa(p[1], p[2], 1)
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
                if trackT > LASER_DELAY then
                    if (trackT - LASER_DELAY)%4 == 1 then
                        --基準座標
                        gnd = copyTable(lasPoint[1])
                    elseif (trackT - LASER_DELAY)%4 == 2 then
                        --地面座標１を保持
                        gnd1 = copyTable(lasPoint[1])
                    elseif (trackT - LASER_DELAY)%4 == 3 then
                        --地面座標２と地面座標１を使い、法線ベクトルを算出
                        nom = vecNorm(lasPoint[1], gnd1, gnd)
                    end

                    --ヒット率に基づき半径を更新
                    if (trackT - LASER_DELAY)%8 == 0 then
                        if isHit[1] then
                            if hitSum/26 > 0.3 then
                                TGTRadius = TGTRadius*TGT_RADIUS_GAIN
                            elseif hitSum/26 < 0.15 then
                                TGTRadius = TGTRadius/TGT_RADIUS_GAIN
                            end
                        end
                        hitSum = 0
                    end
                elseif trackT == LASER_DELAY then
                    nom = vecNorm(lasPoint[1], lasPoint[2], gnd)
                end

                trackT = trackT + 1
            else
                --座標出力
                TGT = {losWxyz[1], losWxyz[2], losWxyz[3], 0, 0, 0, 0, 0, 0}
                ID = 609001

                --レーザ１は直接ターゲットを補足
                --レーザ２は追尾に備えてターゲット下の地面を補足しておく
                --それ以外はニュートラル
                if lasDist[1] == 4000 and lasDist[2] == 4000 then
                    losWxyz = local2World(polar2Rect(seatLosPitch, seatLosYaw, 10^5, true), FPSPos, seatQt)
                end

                las1pitch, las1yaw = stabilizer2(lasPos[1], lasQt, lasLv, lasWrv, losWxyz, ZERO3, LASER_STABI_T)
                theta = math.atan(lasPos[2][2] - losWxyz[2], lasPos[2][1] - losWxyz[1])
                gndOfst = {math.cos(theta)*TGT_RADIUS0*2, math.sin(theta)*TGT_RADIUS0*2, -TGT_RADIUS0}
                las2pitch, las2yaw = stabilizer2(lasPos[2], lasQt, lasLv, lasWrv, vecAdd1(losWxyz, gndOfst), ZERO3, LASER_STABI_T)
                lasDirecSet = {las1yaw, las1pitch, las2yaw, las2pitch, 0, 0, 0, 0}
            end
        end

        --TRD出力
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

        OUB(1, true)

        OUB(10, isTracking)

        OUN(31, seatYawControl)
        OUN(32, zoomCtrl)

        --SRD3
        OUN(23, TGT[1])
        OUN(24, TGT[2])
        OUN(25, TGT[3])
        OUN(26, ID)

    elseif t <= 5 then
        t = t + 1
        seatIdealYaw = 0
        seatTGTAzi = turretAzi
        zoomManu = 0
        zoomCtrl = 0
    end

    --シートピボットのPID制御
    do
        seatYawControl, seatYawES, seatYawEP = PID(SEAT_STABI_P, 0, SEAT_STABI_D, 0, -same_rotation(seatIdealYaw - seatCntYaw), seatYawES, seatYawEP, -100, 100)
        seatYawControl = clamp(seatYawControl*SEAT_PIVOT, -10, 10)
        --nan対策
        seatYawControl = seatYawControl ~= seatYawControl and 0 or seatYawControl
    end

    --レーザ方向の遅延
    do
        table.insert(lasDirec, copyTable(lasDirecSet))
        table.insert(lasQtBuf, copyTable(lasQt))

        if #lasDirec > LASER_DELAY then
            table.remove(lasDirec, 1)
            table.remove(lasQtBuf, 1)
        end
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
