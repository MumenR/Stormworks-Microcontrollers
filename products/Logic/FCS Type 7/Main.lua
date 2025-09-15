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

CAM_RAD_MIN = 0.025/2
CAM_RAD_MAX = 2.2/2
dt = 1
ELI2_DELAY = 8
EKF_CONVERGENCE_TICK = 5

MAX_V = 300/60
MAX_A = 300/3600     --m/tick*tick
data = {}

-- 9*9単位行列
I = {}
for i = 1, 9 do
    I[i] = {}
    for j = 1, 9 do
        if i == j then
            I[i][j] = 1
        else
            I[i][j] = 0
        end
    end
end

--行列演算ライブラリ
matrix = {
    --和(A+B)
    add = function(A, B)
        local C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j] + B[i][j]
            end
        end
        return C
    end,

    --差(A-B)
    sub = function(A, B)
        local C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #A[1] do
                C[i][j] = A[i][j] - B[i][j]
            end
        end
        return C
    end,

    --積(A*B)
    mul = function(A, B)
        local C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #B[1] do
                local sum = 0
                for k = 1, #A[1] do
                    sum = sum + A[i][k]*B[k][j]
                end
                C[i][j] = sum
            end
        end
        return C
    end,

    --逆行列（ガウス・ジョルダン法）
    inv = function(A)
        local n, I, M = #A, {}, {}
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
            local pivot = M[i][i]
            if pivot ~= 0 then
                for j = 1, n do
                    M[i][j] = M[i][j] / pivot
                    I[i][j] = I[i][j] / pivot
                end
                -- 他の行から消去
                for k = 1, n do
                    if k ~= i then
                        local factor = M[k][i]
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

    --転置
    transpose = function(A)
        local T = {}
        for i = 1, #A[1] do
            T[i] = {}
            for j = 1, #A do
                T[i][j] = A[j][i]
            end
        end
        return T
    end
}

--回転行列用
rotation = {
    R = function(Ex, Ey, Ez)
        return {
            {math.cos(Ez)*math.cos(Ey), math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex), math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex)},
            {-math.sin(Ey), math.cos(Ey)*math.cos(Ex),  math.cos(Ey)*math.sin(Ex)},
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

--拡張カルマンフィルタ
EKF = { 
    --初期化
    --[[
        data[ID] = {
            x = 状態変数ベクトル = {{x, vx, ax, y, vy, ay, z, vz, az}}^T
            P = 状態変数共分散行列
            z = 観測値ベクトル
            H = ヤコビアン
            hx = 観測関数
            y = 残差
            R = 観測ノイズ行列
            K = カルマンゲイン
            t = 探知開始からの経過チック
            is_update = 更新した
        }
    ]]
    intialize = function(newTarget)
        local r, Wx, Wy, Wz
        r = (newTarget.dist*0.02)^2/60
        Wx, Wy, Wz = rotation.local2World(newTarget.Lx, newTarget.Ly, newTarget.Lz, Px, Py, Pz, Ex, Ey, Ez)
        return {
            x = matrix.transpose({{Wx, 0, 0, Wy, 0, 0, Wz, 0, 0}}),
            P = {
                {r, 0, 0, 0, 0, 0, 0, 0, 0},
                {0, r, 0, 0, 0, 0, 0, 0, 0},
                {0, 0, r, 0, 0, 0, 0, 0, 0},
                {0, 0, 0, r, 0, 0, 0, 0, 0},
                {0, 0, 0, 0, r, 0, 0, 0, 0},
                {0, 0, 0, 0, 0, r, 0, 0, 0},
                {0, 0, 0, 0, 0, 0, r, 0, 0},
                {0, 0, 0, 0, 0, 0, 0, r, 0},
                {0, 0, 0, 0, 0, 0, 0, 0, r}
            },
            t = 0,
            is_update = true
        }
    end,

    --予測
    predict = function(targetData, dt, PHI)
        local F, Q, X, P
        local x, vx, ax, y, vy, ay, z, vz, az = targetData.x[1][1], targetData.x[2][1], targetData.x[3][1], targetData.x[4][1], targetData.x[5][1], targetData.x[6][1], targetData.x[7][1], targetData.x[8][1], targetData.x[9][1]
        F = {
            {1, dt, dt^2/2, 0, 0,  0,      0, 0,  0},
            {0,  1, dt,     0, 0,  0,      0, 0,  0},
            {0,  0, 1,      0, 0,  0,      0, 0,  0},
            {0,  0, 0,      1, dt, dt^2/2, 0, 0,  0},
            {0,  0, 0,      0, 1,  dt,     0, 0,  0},
            {0,  0, 0,      0, 0,  1,      0, 0,  0},
            {0,  0, 0,      0, 0,  0,      1, dt, dt^2/2},
            {0,  0, 0,      0, 0,  0,      0, 1,  dt},
            {0,  0, 0,      0, 0,  0,      0, 0,  1}
        }

        Q = {
            {dt^5/20, dt^4/8, dt^3/6, 0,       0,      0,      0,       0,      0},
            {dt^4/8,  dt^3/3, dt^2/2, 0,       0,      0,      0,       0,      0},
            {dt^3/6,  dt^2/2, dt,     0,       0,      0,      0,       0,      0},
            {0,       0,      0,      dt^5/20, dt^4/8, dt^3/6, 0,       0,      0},
            {0,       0,      0,      dt^4/8,  dt^3/3, dt^2/2, 0,       0,      0},
            {0,       0,      0,      dt^3/6,  dt^2/2, dt,     0,       0,      0},
            {0,       0,      0,      0,       0,      0,      dt^5/20, dt^4/8, dt^3/6},
            {0,       0,      0,      0,       0,      0,      dt^4/8,  dt^3/3, dt^2/2},
            {0,       0,      0,      0,       0,      0,      dt^3/6,  dt^2/2, dt}
        }
        for i = 1, #Q do
            for j = 1, #Q[1] do
                Q[i][j] = Q[i][j]*PHI
            end
        end

        X = {
            {ax*dt^2/2 + vx*dt + x},
            {ax*dt + vx},
            {ax},
            {ay*dt^2/2 + vy*dt + y},
            {ay*dt + vy},
            {ay},
            {az*dt^2/2 + vz*dt + z},
            {az*dt + vz},
            {az}
        }
        P = matrix.add(matrix.mul(matrix.mul(F, targetData.P), matrix.transpose(F)), Q)
        return {x = X, P = P, F = F, Q = Q, t = targetData.t}
    end,

    --更新
    update = function(predictData, newTarget)
        local Hl, H, hx, z, y, R, K, x, P, r, rxy, t
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
        R = {
            {(newTarget.dist*0.02)^2/60, 0, 0},
            {0, (math.pi*2*0.002)^2/60, 0},
            {0, 0, (math.pi*2*0.002)^2/60}
        }
        K = matrix.mul(matrix.mul(predictData.P, matrix.transpose(H)), matrix.inv(matrix.add(matrix.mul(matrix.mul(H, predictData.P), matrix.transpose(H)), R)))
        x = matrix.add(predictData.x, matrix.mul(K, y))
        P = matrix.mul(matrix.sub(I, matrix.mul(K, H)), predictData.P)
        t = predictData.t + 1
        return {x = x, P = P, H = H, hx = hx, z = z, y = y, R = R, K = K, t = t, is_update = true}
    end
}

--極座標から直交座標へ変換(Z軸優先)
function polar2Rect(dist, yaw, pitch, radianBool)
    local x, y, z
    if not radianBool then
        pitch = pitch*math.pi*2
        yaw = yaw*math.pi*2
    end
    x = dist*math.cos(pitch)*math.sin(yaw)
    y = dist*math.cos(pitch)*math.cos(yaw)
    z = dist*math.sin(pitch)
    return x, y, z
end

--直交座標から極座標へ変換
function rect2Polar(x, y, z, radianBool)
    local distance, yaw, pitch
    distance = math.sqrt(x^2 + y^2 + z^2)
    yaw = math.atan(x, y)
    pitch = math.asin(z/distance)
    if radianBool then
        return distance, yaw, pitch
    else
        return distance, yaw/(math.pi*2), pitch/(math.pi*2)
    end
end

--ローカル直交座標からディスプレイ座標へ変換(fovはラジアン)
function localRect2Display(Lx, Ly, Lz, w, h, fovW, fovH)
    local Dx, Dy, drawable

    --ディスプレイ座標へ変換
    Dx = w/2 + (Lx/Ly)*(w/2)/math.tan(fovW/2)
    Dy = h/2 - (Lz/Ly)*(h/2)/math.tan(fovH/2)
    drawable = Ly > 0
    
    return Dx, Dy, drawable
end

--マハラノビス距離
function mahalanobisDistance(X, mean, var)
    return math.sqrt(matrix.mul(matrix.mul(matrix.transpose(matrix.sub(X, mean)), matrix.inv(var)), matrix.sub(X, mean))[1][1])
end

--３次元ユークリッド距離
function distance3(x1, y1, z1, x2, y2 ,z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

--カメラズーム変換(FOVはラジアン, 出力：0-1の制御用値, 描画計算用FOVラジアン値)
function calZoom(zoomManual, MIN_FOV, MAX_FOV)
    local a, C, zoomRadManual, zoomRadCaled

    --入力値をラジアンに線形変換
    zoomRadManual = (CAM_RAD_MIN - CAM_RAD_MAX)*zoomManual + CAM_RAD_MAX
    
    --線形ラジアンを非線形に変換
    a = math.log(math.tan(MIN_FOV)/math.tan(MAX_FOV))/(CAM_RAD_MIN - CAM_RAD_MAX)
    C = math.log(math.tan(MIN_FOV)) - CAM_RAD_MIN*a
    zoomRadCaled = math.atan(math.exp(a*zoomRadManual + C))

    --計算後ラジアンを制御用値(0-1)に変換
    return (zoomRadCaled - CAM_RAD_MAX)/(CAM_RAD_MIN- CAM_RAD_MAX), zoomRadCaled
end

--ID生成
function nextID()
    local nextID, same = 1, true
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
    return nextID
end

--３次元未来位置(位置、速度、加速度)
function calFuturePos(x, y, z, vx, vy, vz, ax, ay, az, t)
    return (ax*t^2)/2 + vx*t + x, (ay*t^2)/2 + vy*t + y, (az*t^2)/2 + vz*t + z, ax*t + vx, ay*t + vy, az*t + vz
end

function bool2Num(Bool)
    local ans = 0
    if Bool then
        ans = 1
    end
    return ans
end

zoomManual = 0
posDelayBuffer = {}
pitchDelayBuffer = {}
laserPulse = false
autoaimPulse = false
ELI2ID = 0
function onTick()

    VEHICLE_RADIUS = PRN("Vehicle radius [m]")
    RADAR_FOV = PRN("Radar fov")

    laserDist = INN(28)
    seatQE = INN(29)

    PHI = INN(32)

    power = INB(9)
    autoaimEnabled = INB(10)
    laserEnabled = INB(11)

    DELAY = INN(31)

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
    while #pitchDelayBuffer > 3  do
        table.remove(pitchDelayBuffer, 1)
    end
    Px = posDelayBuffer[1][1]
    Py = posDelayBuffer[1][2]
    Pz = posDelayBuffer[1][3]
    Ex = posDelayBuffer[1][4]
    Ey = posDelayBuffer[1][5]
    Ez = posDelayBuffer[1][6]
    currentPitch = pitchDelayBuffer[1]*math.pi*2

    --データ更新リセット
    for ID, DATA in pairs(data) do
        data[ID].is_update = false
    end

    --データ取り込み
    --newTGT = {{dist, yaw, pitch, local x, local y, local z}, ...}
    newTGT = {}
    for i = 1, 7 do
        local dist, yaw, pitch, Lx, Ly, Lz
        dist = INN(i*3 - 2)
        yaw = INN(i*3 - 1)*math.pi*2
        pitch = INN(i*3 - 0)*math.pi*2
        Lx, Ly, Lz = polar2Rect(dist, yaw, pitch, true)

        if INB(i) and dist >= VEHICLE_RADIUS then
            --追加
            table.insert(newTGT, {dist = dist, yaw = yaw, pitch = pitch, Lx = Lx, Ly = Ly, Lz = Lz})
        end
    end

    --同一目標の合体
    for i = 1, #newTGT do
        local A, B, sameTGT, errorRange, sumX, sumY, sumZ, j
        A = newTGT[i]
        if A == nil then
            break
        end
        errorRange = 0.02*A.dist + VEHICLE_RADIUS
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
        local Lx, Ly, Lz = sumX/#sameTGT, sumY/#sameTGT, sumZ/#sameTGT
        local dist, yaw, pitch = rect2Polar(Lx, Ly, Lz, true)
        newTGT[i] = {
            dist = dist,
            yaw = yaw,
            pitch = pitch,
            Lx = Lx,
            Ly = Ly,
            Lz = Lz,
        }
    end

    --描画用コピーの作成
    newTGTDraw = {table.unpack(newTGT)}

    --目標同定(マハラノビス距離が最小)
    for ID, DATA in pairs(data) do
        --共分散行列、平均ベクトルの変換
        local mean, var, predict = {}, {}, EKF.predict(DATA, dt, PHI)
        for i = 1, 3 do
            mean[i], var[i] = {predict.x[3*i - 2][1]}, {}
            for j = 1, 3 do
                var[i][j] = predict.P[3*i - 2][3*j - 2]
            end
        end

        --マハラノビス距離が最小のものを探索
        local minDist, minIndex = math.huge, 0
        for index, new in pairs(newTGT) do
            local x, distMaha, Wx, Wy, Wz
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
            local error = (MAX_A*dt*dt/2 + MAX_V*dt + 0.02*newTGT[minIndex].dist + VEHICLE_RADIUS)*2
            if minDist < error then
                data[ID] = EKF.update(predict, newTGT[minIndex])
                newTGT[minIndex] = nil
            end
        end
    end

    --新規目標登録
    for _, new in pairs(newTGT) do
        local ID = nextID()
        data[ID] = EKF.intialize(new)
    end

    --データ削除
    for ID, DATA in pairs(data) do
        if not DATA.is_update then
            data[ID] = nil
        end
    end
    
    --画面中央に最も近い目標の選択
    minID, minDist = 0, math.huge
    for ID, DATA in pairs(data) do
        local Lx, Ly, Lz = rotation.world2Local(DATA.x[1][1], DATA.x[4][1], DATA.x[7][1], Px, Py, Pz, Ex, Ey, Ez)
        Lx, Ly, Lz = rotation.world2Local(Lx, Ly, Lz, 0, 0, 0, -currentPitch, 0, 0)
        dist = math.sqrt(Lx^2 + Lz^2)/Ly
        if dist < minDist then
            minID = ID
            minDist = dist
        end
    end

    ELI2Exists = (laserEnabled and laserDist ~= 4000 and laserDist ~= 0) or (not laserEnabled and #data > 0)

    --出力
    if laserEnabled then
        --レーザー
        if not autoaimEnabled or not laserPulse then
            local Lx, Ly, Lz = polar2Rect(laserDist, 0, currentPitch, true)
            laserWx, laserWy, laserWz = rotation.local2World(Lx, Ly, Lz, nowPx, nowPy, nowPz, nowEx, nowEy, nowEz)
        end
        ELI2X, ELI2Y, ELI2Z = laserWx, laserWy, laserWz
        ELI2Vx, ELI2Vy, ELI2Vz = 0, 0, 0
        ELI2ID = 0
    elseif ELI2Exists then
        --レーダー
        if not autoaimEnabled or not autoaimPulse then
            ELI2ID = minID
        end

        if data[ELI2ID] ~= nil then
            if data[ELI2ID].t > EKF_CONVERGENCE_TICK then
                ELI2X, ELI2Y, ELI2Z, ELI2Vx, ELI2Vy, ELI2Vz = calFuturePos(data[ELI2ID].x[1][1], data[ELI2ID].x[4][1], data[ELI2ID].x[7][1], data[ELI2ID].x[2][1], data[ELI2ID].x[5][1], data[ELI2ID].x[8][1], data[ELI2ID].x[3][1], data[ELI2ID].x[6][1], data[ELI2ID].x[9][1], ELI2_DELAY)
            else
                ELI2Exists = false
            end
        else
            ELI2Exists = false
        end
    else
        ELI2X, ELI2Y, ELI2Z = 0, 0, 0
        ELI2Vx, ELI2Vy, ELI2Vz = 0, 0, 0
        ELI2ID = 0
    end
    laserPulse = laserEnabled
    autoaimPulse = ELI2Exists and autoaimEnabled and not laserEnabled


    OUB(1, ELI2Exists)
    OUN(1, ELI2X)
    OUN(2, ELI2Y)
    OUN(3, ELI2Z)
    OUN(4, ELI2Vx)
    OUN(5, ELI2Vy)
    OUN(6, ELI2Vz)
    OUN(7, bool2Num(ELI2Exists))

    OUN(8, zoomRadCaled)
    OUN(32, zoomCaled)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    fovW = 2*zoomRadCaled*(w/h)
    fovH = 2*zoomRadCaled

    --レーダー反応描画(生データ)
    screen.setColor(0, 255, 0)
    for _, tgt in pairs(newTGTDraw) do
        local Lx, Ly, Lz, x1, y1, drawable1
        Lx, Ly, Lz = rotation.world2Local(tgt.Lx, tgt.Ly, tgt.Lz, 0, 0, 0, -currentPitch, 0, 0)
        x1, y1, drawable1 = localRect2Display(Lx, Ly, Lz, w, h, fovW, fovH)
        x1 = math.floor(x1)
        y1 = math.floor(y1)
        if drawable1 then
            --円
            screen.drawCircle(x1, y1, 4)
        end
    end

    --レーダー反応描画(フィルタリング)
    for ID, tgt in pairs(data) do
        if ID == ELI2ID then
            screen.setColor(255, 0, 0)
        else
            screen.setColor(0, 255, 0)
        end
        local Wx, Wy, Wz, Lx, Ly, Lz, x1, y1, drawable1
        Wx, Wy, Wz = calFuturePos(tgt.x[1][1], tgt.x[4][1], tgt.x[7][1], tgt.x[2][1], tgt.x[5][1], tgt.x[8][1], tgt.x[3][1], tgt.x[6][1], tgt.x[9][1], ELI2_DELAY)
        Lx, Ly, Lz = rotation.world2Local(Wx, Wy, Wz, nowPx, nowPy, nowPz, nowEx, nowEy, nowEz)
        Lx, Ly, Lz = rotation.world2Local(Lx, Ly, Lz, 0, 0, 0, -currentPitch, 0, 0)
        x1, y1, drawable1 = localRect2Display(Lx, Ly, Lz, w, h, fovW, fovH)
        x1 = math.floor(x1)
        y1 = math.floor(y1)

        if drawable1 then
            --円
            screen.drawCircle(x1, y1, 4)
            screen.drawText(x1, y1 + 5, ID)
        end
    end

    --レーダーFOV表示
    screen.setColor(0, 255, 0)
    local x1, y1, x2, y2
    x2 = math.floor(math.pi*2*RADAR_FOV*(h/fovH))
    y2 = x2
    x1 = math.floor(w/2 - x2/2)
    y1 = math.floor(h/2 - x2/2)
    screen.drawRect(x1, y1, x2, y2)

    screen.drawText(1, 1, #newTGT)
    screen.drawText(1, 10, ELI2ID)
end