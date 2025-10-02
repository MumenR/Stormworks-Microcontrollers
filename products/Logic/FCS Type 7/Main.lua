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
    simulator:setProperty("Vehicle radius [m]", 15)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        math.randomseed(ticks)

        range = (simulator:getSlider(1)+0.001)*10000
        phi = simulator:getSlider(2)*100

        simulator:setInputNumber(32, phi)

        simulator:setInputNumber(1, range + 0.01*range*math.random()/5)
        simulator:setInputNumber(2, math.random()*0.002/5)
        simulator:setInputNumber(3, math.random()*0.002/5)
    end;
    simulator:setInputBool(1, true)
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
pi2 = math.pi*2

CAM_RAD_MIN = 0.025/2
CAM_RAD_MAX = 2.2/2
dt = 1
TRD1_DELAY = 11             --レーダーのノードによる遅延補正用
EKF_CONVERGENCE_TICK = 10   --収束までの時間
ELI3_TICK = 30              --ELI3による強制制御が有効になる時間
MIN_ERROR = 50              --目標同定用の最小マハラノビス距離
SAME_VEHICLE_RADIUS = 15    --同一目標合成用のビークル半径[m]
RESIDUAL_THRESHOLD = 0.27   --可変Qの、残差平方和*100の閾値

ALPHA = 1.01                --減衰記憶フィルタの係数

MAX_V = 300/60              --m/tick
MAX_A = 300/3600            --m/tick*tick
data = {}

laserOffset = {
    Lx = 0,
    Ly = 0,
    Lz = -0.5
}

--行列演算ライブラリ
matrix = {
    --和(A+B)
    add = function(A, B, C)
        C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j] + B[i][j]
            end
        end
        return C
    end,

    --差(A-B)
    sub = function(A, B, C)
        C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j] - B[i][j]
            end
        end
        return C
    end,

    --積(A*B)
    mul = function(A, B, C, sum)
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
    end,

    --スカラー倍(行列Aをx倍)
    mulScalar = function (A, x, C)
        C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j]*x
            end
        end
        return C
    end,

    --逆行列(Aの逆行列)
    inv = function(A, n, I, M, pivot, factor)
        n, I, M = #A, {}, {}
        for i = 1, n do
            I[i] = {}
            M[i] = {}
            for j = 1, n do
                M[i][j] = A[i][j]
                I[i][j] = (i == j) and 1 or 0
            end
        end

        for i = 1, n do
            -- ピボット正規化
            pivot = M[i][i]
            if pivot ~= 0 then
                for j = 1, n do
                    M[i][j] = M[i][j]/pivot
                    I[i][j] = I[i][j]/pivot
                end
                -- 他の行から消去
                for k = 1, n do
                    if k ~= i then
                        factor = M[k][i]
                        for j = 1, n do
                            M[k][j] = M[k][j] - factor * M[i][j]
                            I[k][j] = I[k][j] - factor * I[i][j]
                        end
                    end
                end
            end
        end
        return I
    end,

    --転置(Aの転置)
    transpose = function(A, T)
        T = {}
        for i = 1, #A[1] do
            T[i] = {}
            for j = 1, #A do
                T[i][j] = A[j][i]
            end
        end
        return T
    end,

    --対角行列へ展開(xをn回)
    diag = function (x, n, xRow, xColumn, M, rowOffset, colOffset)
        xRow, xColumn, M = #x, #x[1], {}

        -- 大きな行列を 0 で初期化
        for i = 1, xRow*n do
            M[i] = {}
            for j = 1, xColumn*n do
                M[i][j] = 0
            end
        end

        -- 各ブロックを対角に配置
        for k = 0, n-1 do
            rowOffset, colOffset = k*xRow, k*xColumn
            for i = 1, xRow do
                for j = 1, xColumn do
                    M[rowOffset + i][colOffset + j] = x[i][j]
                end
            end
        end

        return M
    end
}

--回転行列用
rotation = {
    R = function(Ex, Ey, Ez)
        return {
            {math.cos(Ez)*math.cos(Ey), math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex), math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex)},
            {-math.sin(Ey),             math.cos(Ey)*math.cos(Ex),                                          math.cos(Ey)*math.sin(Ex)},
            {math.sin(Ez)*math.cos(Ey), math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex), math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex)}
        }
    end,

    local2World = function(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
        local W = matrix.add(matrix.mul(rotation.R(Ex, Ey, Ez), matrix.transpose({{Lx, Ly, Lz}})), matrix.transpose({{Px, Pz, Py}}))
        return W[1][1], W[2][1], W[3][1]
    end,

    world2Local = function(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
        local L = matrix.mul(matrix.transpose(rotation.R(Ex, Ey, Ez)), matrix.sub(matrix.transpose({{Wx, Wy, Wz}}), matrix.transpose({{Px, Pz, Py}})))
        return L[1][1], L[2][1], L[3][1]
    end
}

--9*9単位行列
I = matrix.diag({{1}}, 9)

--拡張カルマンフィルタ
EKF = { 
    --初期化
    --[[
        data[ID] = {
            x = 状態変数ベクトル = {{x, vx, ax, y, vy, ay, z, vz, az}}^T
            P = 状態変数共分散行列
            current = 遅延補正済みの予測現在位置
            t = 探知開始からの経過チック
            tOut = SRD2に最後に出力してからの経過チック
            isUpdate = 更新した
            PIDErrorPre = 自動Q用
            PIDErrorSum = 自動Q用
        }
    ]]
    intialize = function(newTarget)
        local Wx, Wy, Wz
        Wx, Wy, Wz = rotation.local2World(newTarget.Lx, newTarget.Ly, newTarget.Lz, Px, Py, Pz, Ex, Ey, Ez)
        return {
            x = matrix.transpose({{Wx, 0, 0, Wy, 0, 0, Wz, 0, 0}}),
            P = matrix.diag({{(newTarget.dist*0.02)^2/60}}, 9),
            current = {x = Wx, y = Wy, z = Wz, vx = 0, vy = 0, vz = 0, ax = 0, ay = 0, az = 0},
            y = matrix.transpose({{0, 0, 0}}),
            z = matrix.transpose({{newTarget.dist, newTarget.yaw, newTarget.pitch}}),
            t = 0,
            tOut = math.huge,
            isUpdate = true,
            PIDErrorPre = 0,
            PIDErrorSum = 0
        }
    end,

    --予測
    predict = function(targetData, dt, PHI)
        local x, vx, ax, y, vy, ay, z, vz, az = targetData.x[1][1], targetData.x[2][1], targetData.x[3][1], targetData.x[4][1], targetData.x[5][1], targetData.x[6][1], targetData.x[7][1], targetData.x[8][1], targetData.x[9][1]

        --プロセスノイズ行列
        Q = {
            {dt^5/20, dt^4/8, dt^3/6},
            {dt^4/8,  dt^3/3, dt^2/2},
            {dt^3/6,  dt^2/2, dt}
        }
        Q = matrix.diag(matrix.mulScalar(Q, PHI), 3)

        --状態遷移行列
        F = {
            {1, dt, dt^2/2},
            {0,  1, dt},
            {0,  0, 1}
        }
        F = matrix.diag(F, 3)

        return {
            x = {
                {ax*dt^2/2 + vx*dt + x},
                {ax*dt + vx},
                {ax},
                {ay*dt^2/2 + vy*dt + y},
                {ay*dt + vy},
                {ay},
                {az*dt^2/2 + vz*dt + z},
                {az*dt + vz},
                {az}
            },
            P = matrix.add(matrix.mulScalar(matrix.mul(matrix.mul(F, targetData.P), matrix.transpose(F)), ALPHA), Q),
            t = targetData.t,
            y = targetData.y,
            z = targetData.z,
            tOut = targetData.tOut,
            isUpdate = targetData.isUpdate,
            PIDErrorPre = targetData.PIDErrorPre,
            PIDErrorSum = targetData.PIDErrorSum
        }
    end,

    --更新
    update = function(predictData, newTarget)
        local Hl, H, hx, z, y, R, K, x, P, r, rxy, t, update, predict
        local Lx, Ly, Lz = rotation.world2Local(predictData.x[1][1], predictData.x[4][1], predictData.x[7][1], Px, Py, Pz, Ex, Ey, Ez)
        r, rxy = math.sqrt(Lx^2 + Ly^2 + Lz^2), math.sqrt(Lx^2 + Ly^2)
        Hl = {
            {Lx/r, Ly/r, Lz/r},
            {Ly/rxy^2, -Lx/rxy^2, 0},
            {-Lx*Lz/(r^2*rxy), -Ly*Lz/(r^2*rxy), rxy/r^2}
        }
        Hl = matrix.mul(Hl, matrix.transpose(rotation.R(Ex, Ey, Ez)))
        H = {}
        for i = 1, 3 do
            H[i] = {Hl[i][1], 0, 0, Hl[i][2], 0, 0, Hl[i][3], 0, 0}
        end

        hx = matrix.transpose({{r, math.atan(Lx, Ly), math.asin(Lz/r)}})
        z = matrix.transpose({{newTarget.dist, newTarget.yaw, newTarget.pitch}})
        y = matrix.sub(z, hx)
        R = matrix.diag({{(pi2*0.002)^2/60}}, 3)
        R[1][1] = (newTarget.dist*0.02)^2/60
        K = matrix.mul(matrix.mul(predictData.P, matrix.transpose(H)), matrix.inv(matrix.add(matrix.mul(matrix.mul(H, predictData.P), matrix.transpose(H)), R)))
        x = matrix.add(predictData.x, matrix.mul(K, y))
        P = matrix.mul(matrix.sub(I, matrix.mul(K, H)), predictData.P)
        t = predictData.t + 1
        
        --遅延補正値を追加
        update = {x = x, P = P, t = t, y = y, z = z, tOut = predictData.tOut, isUpdate = true, PIDErrorPre = predictData.PIDErrorPre, PIDErrorSum = predictData.PIDErrorSum}
        predict = EKF.predict(update, TRD1_DELAY, 0)
        update.current = {x = predict.x[1][1], y = predict.x[4][1], z = predict.x[7][1], vx = predict.x[2][1], vy = predict.x[5][1], vz = predict.x[8][1], ax = predict.x[3][1], ay = predict.x[6][1], az = predict.x[9][1]}
        return update
    end
}

--極座標から直交座標へ変換(Z軸優先)
function polar2Rect(dist, yaw, pitch, radianBool)
    if not radianBool then
        pitch = pitch*pi2
        yaw = yaw*pi2
    end
    x = dist*math.cos(pitch)*math.sin(yaw)
    y = dist*math.cos(pitch)*math.cos(yaw)
    z = dist*math.sin(pitch)
    return x, y, z
end

--直交座標から極座標へ変換
function rect2Polar(x, y, z, radianBool)
    distance = math.sqrt(x^2 + y^2 + z^2)
    yaw = math.atan(x, y)
    pitch = math.asin(z/distance)
    if radianBool then
        return distance, yaw, pitch
    else
        return distance, yaw/pi2, pitch/pi2
    end
end

--マハラノビス距離
function mahalanobisDistance(X, mean, var)
    return math.sqrt(matrix.mul(matrix.mul(matrix.transpose(matrix.sub(X, mean)), matrix.inv(var)), matrix.sub(X, mean))[1][1])
end

--３次元ユークリッド距離
function distance3(x1, y1, z1, x2, y2 ,z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

--カメラズーム変換(FOVはラジアン, 出力：0-1の制御用値, 描画計算用FOVラジアン値)
function calZoom(zoomManual, MIN_FOV, MAX_FOV)
    --入力値をラジアンに線形変換
    zoomRadManual = (CAM_RAD_MIN - CAM_RAD_MAX)*zoomManual + CAM_RAD_MAX
    
    --線形ラジアンを非線形に変換
    a = math.log(math.tan(MIN_FOV)/math.tan(MAX_FOV))/(CAM_RAD_MIN - CAM_RAD_MAX)
    C = math.log(math.tan(MIN_FOV)) - CAM_RAD_MIN*a
    zoomRadCaled = math.atan(math.exp(a*zoomRadManual + C))

    --計算後ラジアンを制御用値(0-1)に変換
    return (zoomRadCaled - CAM_RAD_MAX)/(CAM_RAD_MIN- CAM_RAD_MAX), zoomRadCaled
end

function distance2Sring(x)
    if x >= 10 then
        x = string.format("%.0f", math.floor(x + 0.5))
    else
        x = string.format("%.1f", math.floor(x*10 + 0.5)/10)
    end
    return x
end

--PID制御
function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
    error = target - current
    errorSum = errorSumPre + error
    errorDiff = error - errorPre
    controll = P*error + I*errorSum + D*errorDiff

    if controll > max or controll < min then
        errorSum = errorSumPre
        controll = P*error + I*errorSum + D*errorDiff
    end
    return clamp(controll, min, max), errorSum, error
end

zoomManual = 0
posDelayBuffer = {}
pitchDelayBuffer = {}
for i = 1, 9 do
    table.insert(pitchDelayBuffer, 0)
end
laserPulse = false
autoaimPulse = false
TRD1ID = 0
ELI3t = math.huge
laserWx, laserWy, laserWz = 0, 0, 0

function onTick()

    VEHICLE_RADIUS = PRN("Vehicle radius [m]")
    RADAR_FOV = PRN("Radar fov")
    DIST_UNIT = PRN("Distance Units")
    SPEED_UNIT = PRN("Speed Units")

    laserDist = INN(28)
    seatQE = INN(29)

    power = INB(9)
    autoaimEnabled = INB(10)
    laserEnabled = INB(11)
    ELI3Exists = INB(12)
    if ELI3Exists then
        ELI3t = 0
    end

    --ズーム計算
    MIN_FOV = PRN("Cam min fov [rad]")/2
    MAX_FOV = PRN("Cam max fov [rad]")/2
    ZOOM_GAIN = PRN("Zoom speed gain")
    if power then
        if seatQE == -1 and zoomManual > 0 then
            zoomManual = zoomManual - 0.01*ZOOM_GAIN
        elseif seatQE == 1 and zoomManual < 1 then
            zoomManual = zoomManual + 0.01*ZOOM_GAIN
        end
    else
        zoomManual = 0
    end
    zoomCaled, zoomRadCaled = calZoom(zoomManual, MIN_FOV, MAX_FOV)

    --フィジックス情報取り込み
    --遅延生成
    nowPx, nowPy, nowPz, nowEx, nowEy, nowEz = INN(22), INN(23), INN(24), INN(25), INN(26), INN(27)
    table.insert(posDelayBuffer, {nowPx, nowPy, nowPz, nowEx, nowEy, nowEz})
    table.insert(pitchDelayBuffer, INN(30))
    while #posDelayBuffer > 7  do
        table.remove(posDelayBuffer, 1)
    end
    while #pitchDelayBuffer > 9  do
        table.remove(pitchDelayBuffer, 1)
    end
    Px = posDelayBuffer[1][1]
    Py = posDelayBuffer[1][2]
    Pz = posDelayBuffer[1][3]
    Ex = posDelayBuffer[1][4]
    Ey = posDelayBuffer[1][5]
    Ez = posDelayBuffer[1][6]
    camPitch = pitchDelayBuffer[7]*pi2
    laserPitch = clamp(pitchDelayBuffer[7], -0.125, 0.125)*pi2

    --データ取り込み
    --newTGT = {{dist, yaw, pitch, local x, local y, local z}, ...}
    newTGT = {}
    for i = 1, 7 do
        dist = INN(i*3 - 2)
        yaw = INN(i*3 - 1)*pi2
        pitch = INN(i*3 - 0)*pi2
        Lx, Ly, Lz = polar2Rect(dist, yaw, pitch, true)

        if INB(i) and dist >= VEHICLE_RADIUS then
            --追加
            table.insert(newTGT, {dist = dist, yaw = yaw, pitch = pitch, Lx = Lx, Ly = Ly, Lz = Lz})
        end
    end

    --同一目標の合体
    for i = 1, #newTGT do
        A = newTGT[i]
        if A == nil then
            break
        end
        errorRange = (3*0.02/5)*A.dist + SAME_VEHICLE_RADIUS
        sameTGT = {A}
        --距離を判定される側の探索
        j = i + 1
        while j <= #newTGT do
            B = newTGT[j]
            --規定値以下なら仮テーブルに追加し、元テーブルから削除
            if distance3(A.Lx, A.Ly, A.Lz, B.Lx, B.Ly, B.Lz) < errorRange then
                table.insert(sameTGT, B)
                table.remove(newTGT, j)
            else
                j = j + 1
            end
        end
        --仮テーブルから平均値を計算して値を更新
        sumX, sumY, sumZ = 0, 0, 0
        for _, C in pairs(sameTGT) do
            sumX = sumX + C.Lx
            sumY = sumY + C.Ly
            sumZ = sumZ + C.Lz
        end
        dist, yaw, pitch = rect2Polar(sumX/#sameTGT, sumY/#sameTGT, sumZ/#sameTGT, true)
        newTGT[i] = {
            dist = dist,
            yaw = yaw,
            pitch = pitch,
            Lx = sumX/#sameTGT,
            Ly = sumY/#sameTGT,
            Lz = sumZ/#sameTGT,
        }
    end

    --描画用コピーの作成
    newTGTDraw = {table.unpack(newTGT)}

    --目標同定(マハラノビス距離が最小)、EKF予測・更新
    for ID, DATA in pairs(data) do

        --データ更新フラグリセットとSRD2出力順位用の時間経過
        data[ID].isUpdate = false
        data[ID].tOut = data[ID].tOut + 1

        --自動プロセスノイズ調整(残差により変動)
        residual = 100*distance3(pi2*DATA.y[1][1]/DATA.z[1][1]/10, DATA.y[2][1], DATA.y[3][1], 0, 0, 0)
        PIDControl, data[ID].PIDErrorSum, data[ID].PIDErrorPre = PID(0, 0.5, 0, RESIDUAL_THRESHOLD, residual, DATA.PIDErrorSum, DATA.PIDErrorPre, -2.5, 3)

        PHI = 10^-(10 + PIDControl)

        --予測値の更新、マハラノビス距離用に共分散行列、平均ベクトルの変換
        mean, var, predict = {}, {}, EKF.predict(DATA, dt, PHI)
        for i = 1, 3 do
            mean[i], var[i] = {predict.x[3*i - 2][1]}, {}
            for j = 1, 3 do
                var[i][j] = predict.P[3*i - 2][3*j - 2]
            end
        end

        --マハラノビス距離が最小のものを探索
        minDist, minIndex = math.huge, 0
        for index, new in pairs(newTGT) do
            Wx, Wy, Wz = rotation.local2World(new.Lx, new.Ly, new.Lz, Px, Py, Pz, Ex, Ey, Ez)
            x = matrix.transpose({{Wx, Wy, Wz}})
            distMaha = mahalanobisDistance(x, mean, var)
            if distMaha < minDist then
                minDist = distMaha
                minIndex = index
            end
        end

        --規定以下ならデータ追加、EKF更新
        if newTGT[minIndex] ~= nil then
            error = (MAX_A*dt*dt/2 + MAX_V*dt + (3*0.02/5)*newTGT[minIndex].dist)*3 + MIN_ERROR
            if minDist < error then
                data[ID] = EKF.update(predict, newTGT[minIndex])
                newTGT[minIndex] = nil
            end
        end
    end

    --新規目標登録
    for _, new in pairs(newTGT) do
        --新規ID探索(nextID()と同じ)
        nextID, same = 1, true
        while same do
            same = false
            for dataID, _ in pairs(data) do
                same = dataID == nextID
                if same then
                    nextID = nextID + 1
                    break
                end
            end
        end

        data[nextID] = EKF.intialize(new)
    end

    --データ削除
    for ID, DATA in pairs(data) do
        if not DATA.isUpdate then
            data[ID] = nil
        end
    end

    --画面中央に最も近い目標の選択
    minID, minDist, dataNum = 0, math.huge, 0
    for ID, DATA in pairs(data) do
        dataNum = dataNum + 1
        Lx, Ly, Lz = rotation.world2Local(DATA.x[1][1], DATA.x[4][1], DATA.x[7][1], Px, Py, Pz, Ex, Ey, Ez)
        Lx, Ly, Lz = rotation.world2Local(Lx, Ly, Lz, 0, 0, 0, -camPitch, 0, 0)
        dist = math.sqrt(Lx^2 + Lz^2)/Ly
        if dist < minDist then
            minID = ID
            minDist = dist
        end
    end

    TRD1Exists = (laserEnabled and laserDist ~= 0 and laserDist ~= 4000 or (laserWx ~= 0 and autoaimEnabled)) or (not laserEnabled and dataNum > 0)

    --ELI3モード
    if ELI3t <= ELI3_TICK then
        ELI3t = ELI3t + 1
        TRD1ID = minID
        laserPulse = false
    end

    --出力値決定
    TRD1X, TRD1Y, TRD1Z, TRD1Vx, TRD1Vy, TRD1Vz, TRD1Ax, TRD1Ay, TRD1Az = 0, 0, 0, 0, 0, 0, 0, 0, 0
    if laserEnabled then
        --レーザー
        if laserDist ~= 0 and laserDist ~= 4000 and (not autoaimEnabled or not laserPulse or laserWx == 0) then
            offsetPx, offsetPz, offsetPy = rotation.local2World(laserOffset.Lx, laserOffset.Ly, laserOffset.Lz, nowPx, nowPy, nowPz, nowEx, nowEy, nowEz)
            Lx, Ly, Lz = polar2Rect(laserDist, 0, laserPitch, true)
            laserWx, laserWy, laserWz = rotation.local2World(Lx, Ly, Lz, offsetPx, offsetPy, offsetPz, nowEx, nowEy, nowEz)
        end
        TRD1X, TRD1Y, TRD1Z = laserWx, laserWy, laserWz
        TRD1ID = 0
        if not autoaimEnabled then
            laserWx, laserWy, laserWz = 0, 0, 0
        end
    elseif TRD1Exists then
        --レーダー
        if not autoaimEnabled or not autoaimPulse then
            TRD1ID = minID
        end

        if data[TRD1ID] ~= nil then
            if data[TRD1ID].t > EKF_CONVERGENCE_TICK then
                current = data[TRD1ID].current
                TRD1X, TRD1Y, TRD1Z, TRD1Vx, TRD1Vy, TRD1Vz, TRD1Ax, TRD1Ay, TRD1Az = current.x, current.y, current.z, current.vx, current.vy, current.vz, current.ax, current.ay, current.az
            else
                TRD1Exists = false
            end
        else
            TRD1Exists = false
        end
        laserWx, laserWy, laserWz = 0, 0, 0
    else
        TRD1ID = 0
        laserWx, laserWy, laserWz = 0, 0, 0
    end
    laserPulse = laserEnabled
    autoaimPulse = TRD1Exists and autoaimEnabled and not laserEnabled

    --0or1変換
    TRD1ExistsNum = 0
    if TRD1Exists then
        TRD1ExistsNum = 1
    end

    OUB(1, TRD1Exists)
    OUN(1, TRD1X)
    OUN(2, TRD1Y)
    OUN(3, TRD1Z)
    OUN(4, TRD1Vx)
    OUN(5, TRD1Vy)
    OUN(6, TRD1Vz)
    OUN(7, TRD1Ax)
    OUN(8, TRD1Ay)
    OUN(9, TRD1Az)
    OUN(10, TRD1ExistsNum)
    OUN(11, zoomRadCaled)
    OUN(12, zoomCaled)

    --SRD2出力リセット
    for i = 13, 32 do
        OUN(i, 0)
    end

    --最も最後に出力した値からSRD2出力
    for i = 4, 8 do
        --tOut 最大値探索
        maxT, maxID = 0, 0
        for ID, DATA in pairs(data) do
            if DATA.tOut > maxT then
                maxT = DATA.tOut
                maxID = ID
            end
        end
        --出力
        if maxID ~= 0 then
            OUN(i*4 - 3, data[maxID].current.x)
            OUN(i*4 - 2, data[maxID].current.y)
            OUN(i*4 - 1, data[maxID].current.z)

            if maxID == TRD1ID then
                OUN(i*4, maxID + 10^5)
            else
                OUN(i*4, maxID)
            end
            data[maxID].tOut = 0
        end
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    fovW = 2*zoomRadCaled*(w/h)
    fovH = 2*zoomRadCaled

    screen.setColor(0, 255, 0)

    --[[
    --レーダー反応描画(生データ)
    for _, tgt in pairs(newTGTDraw) do
        Lx, Ly, Lz = rotation.world2Local(tgt.Lx, tgt.Ly, tgt.Lz, 0, 0, 0, -pitchDelayBuffer[1]*pi2, 0, 0)
        x1, y1, drawable1 = math.floor(w/2 + Lx*w/Ly/2/math.tan(fovW/2)), math.floor(h/2 - Lz*h/Ly/2/math.tan(fovH/2)), Ly > 0
        if drawable1 then
            --円
            screen.drawCircle(x1, y1, 4)
        end
    end
    ]]

    --ロックオン情報
    if TRD1Exists then
        screen.drawText(1, 1, "LOCK ON")
        screen.drawText(1, 7, "ID="..TRD1ID)
        screen.drawText(1, 13, "D="..distance2Sring(DIST_UNIT*distance3(TRD1X, TRD1Y, TRD1Z, nowPx, nowPz, nowPy)))
        screen.drawText(1, 19, "V="..distance2Sring(SPEED_UNIT*60*distance3(TRD1Vx, TRD1Vy, TRD1Vz, 0, 0, 0)))
    end

    --レーダー反応描画(フィルタリング)
    for ID, tgt in pairs(data) do
        predictDraw = EKF.predict(tgt, 5, 0)
        Lx, Ly, Lz = rotation.world2Local(predictDraw.x[1][1], predictDraw.x[4][1], predictDraw.x[7][1], nowPx, nowPy, nowPz, nowEx, nowEy, nowEz)
        Lx, Ly, Lz = rotation.world2Local(Lx, Ly, Lz, 0, 0, 0, -camPitch, 0, 0)
        x1, y1, drawable1 = math.floor(w/2 + Lx*w/Ly/2/math.tan(fovW/2)), math.floor(h/2 - Lz*h/Ly/2/math.tan(fovH/2)), Ly > 0
        
        if drawable1 then
            --四角
            screen.drawRect(x1 - 4, y1 - 4, 8, 8)

            --菱形
            if TRD1ID == ID then
                screen.drawLine(x1 - 4, y1, x1, y1 + 4)
                screen.drawLine(x1, y1 + 4, x1 + 4, y1)
                screen.drawLine(x1 + 4, y1, x1, y1 - 4)
                screen.drawLine(x1, y1 - 4, x1 - 4, y1)
            end

            --ID
            stringID = tostring(ID)
            screen.drawText(x1 + 1 - 2.5*#stringID, y1 - 10, stringID)

            --距離数値
            dist = distance2Sring(distance3(Lx, Ly, Lz, 0, 0, 0)*DIST_UNIT)
            screen.drawText(x1 + 1 - 2.5*#dist, y1 + 6, dist)
        end
    end

    --レーダーFOV表示
    x2 = math.floor(pi2*RADAR_FOV*(h/fovH))
    x1 = math.floor(w/2 - x2/2)
    y1 = math.floor(h/2 - x2/2)
    screen.drawRect(x1, y1, x2, x2)
end