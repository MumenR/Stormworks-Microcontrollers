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
TRD1_DELAY = 2              --レーダーのノードによる遅延補正用
ELI3_TICK = 30              --ELI3による強制制御が有効になる時間
MIN_ERROR = 50              --目標同定用の最小マハラノビス距離
SAME_VEHICLE_RADIUS = 30    --同一目標合成用のビークル半径[m]
RESIDUAL_THRESHOLD = 0.75   --可変Qの、残差平方和*100の閾値
CONVERGENCE_TICK = 10       --収束判定用の経過時間
ALPHA = 1.02                --減衰記憶フィルタの係数

CLOSE_T_THRESHOLD = 3600    --迎撃開始チックの最大値
CLOSE_DIST_THRESHOLD = 2000 --迎撃開始距離の最大値(チックと距離どちらか満たせば迎撃)

MAX_V = 300/60              --m/tick
MAX_A = 300/3600            --m/tick*tick
data = {}

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
            P = matrix.diag({{(newTarget.dist*0.02)^2/12}}, 9),
            current = {x = Wx, y = Wy, z = Wz, vx = 0, vy = 0, vz = 0, ax = 0, ay = 0, az = 0},
            y = matrix.transpose({{0, 0, 0}}),
            z = matrix.transpose({{newTarget.dist, newTarget.yaw, newTarget.pitch}}),
            t = 0,
            tOut = math.huge,
            isUpdate = true,
            PIDErrorPre = 0,
            PIDErrorSum = 0,
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
        R = matrix.diag({{(pi2*0.002)^2/12}}, 3)
        R[1][1] = (newTarget.dist*0.02)^2/12
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

--対向速度と到達時間(近づくなら正)
Pvx, Pvy, Pvz = 0, 0, 0
function calClosingSpeed(Tx, Ty, Tz, Tvx, Tvy, Tvz)
    local Lx, Ly, Lz, Lvx, Lvy, Lvz, dist, cv, ct
    Lx, Ly, Lz = rotation.world2Local(Tx, Ty, Tz, Px, Py, Pz, Ex, Ey, Ez)
    Lvx, Lvy, Lvz = rotation.world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Ex, Ey, Ez)
    Lvx, Lvy, Lvz = Lvx - Pvx, Lvy - Pvz, Lvz - Pvy
    dist = math.sqrt(Lx^2 + Ly^2 + Lz^2)
    --対向速度
    cv = -(Lvx*Lx + Lvy*Ly + Lvz*Lz)/dist
    --到達時間
    ct = cv > 0 and clamp(dist/cv, 0, math.huge) or math.huge
    return cv, ct
end

dataSRD = {}
radarGimbalX = {0, 0, 0, 0, 0}
function onTick()

    --PHI = INN(19)
    OUB(32, false)
    OUB(31, false)
    OUB(30, false)

    VEHICLE_RADIUS = PRN("Vehicle radius [m]")
    OFFSET_X, OFFSET_Y, OFFSET_Z = PRN("Radar phy. offset x (m)"), PRN("Radar phy. offset y (m)"), PRN("Radar phy. offset z (m)")

    Px, Py, Pz, Ex, Ey, Ez = INN(4), INN(8), INN(12), INN(16), INN(20), INN(21)
    Px, Pz, Py = rotation.local2World(OFFSET_X, OFFSET_Y, OFFSET_Z, Px, Py, Pz, Ex, Ey, Ez)

    AutoInterceptEnable = INB(12)

    ELI2Exist = INB(13)
    ELI2X, ELI2Y, ELI2Z, ELI2Vx, ELI2Vy, ELI2Vz = INN(22), INN(23), INN(24), INN(25), INN(26), INN(27)

    --dataSRD時間経過と削除
    for ID, DATA in pairs(dataSRD) do
        DATA.tElapsed = DATA.tElapsed + 1
        if dataSRD[ID].tElapsed > 3 then
            dataSRD[ID] = nil
        end
    end

    --データ取り込み
    --newTGT = {{dist, yaw, pitch, local x, local y, local z}, ...}
    newTGT = {}
    for i = 1, 5 do
        dist = INN(i*4 - 3)
        yaw = INN(i*4 - 2)*pi2
        pitch = INN(i*4 - 1)*pi2
        Lx, Ly, Lz = polar2Rect(dist, yaw, pitch, true)

        if INB(i) and dist >= VEHICLE_RADIUS then
            --追加
            table.insert(newTGT, {dist = dist, yaw = yaw, pitch = pitch, Lx = Lx, Ly = Ly, Lz = Lz})
        end
    end
    --dataSRD[迎撃優先順位] = {x, y, z, ID, t = 到達時間, tElapsed = 経過時間}
    if INN(31) > 0 then
        local ID, priority = INN(31)%1000, math.floor(INN(31)/1000)

        dataSRD[priority] = {
            x = INN(28),
            y = INN(29),
            z = INN(30),
            ID = ID,
            t = INN(32),
            tElapsed = 0
        }
    end

    --同一目標の合体
    for i = 1, #newTGT do
        A = newTGT[i]
        if A == nil then
            break
        end
        errorRange = 0.02*A.dist + SAME_VEHICLE_RADIUS
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
        PIDControl, data[ID].PIDErrorSum, data[ID].PIDErrorPre = PID(0, 2, 0, RESIDUAL_THRESHOLD, residual, DATA.PIDErrorSum, DATA.PIDErrorPre, -1, 2)

        PHI = 10^-(8 + PIDControl)

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
            error = (MAX_A*dt*dt/2 + MAX_V*dt + 0.02*newTGT[minIndex].dist)*15 + MIN_ERROR
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

    --出力値決定
    radarOn = false
    radarX, radarY = 0, 0
    TRD1X, TRD1Y, TRD1Z, TRD1Vx, TRD1Vy, TRD1Vz, TRD1Ax, TRD1Ay, TRD1Az = 0, 0, 0, 0, 0, 0, 0, 0, 0
    TRD1Exists = false
    directAimEnable = false
    if AutoInterceptEnable then     --自動迎撃モード(SRDか自レーダーの目標を自動選択)

        --[[
            TR制御：
            スタンバイ状態→捜索レーダー第1脅威へ指向
            捜索レーダー検出中→それを追尾
            明らかにやばい脅威がいる→それに切りかえ
            追尾レーダー反応なし→スタンバイへ

            砲制御：
            視野内で最も脅威度の高いものへ射撃
        ]]
        
        function returnSRD(priority)    --SRDの座標取得関数
            return dataSRD[priority].x, dataSRD[priority].y, dataSRD[priority].z
        end


        --到達時間計算、最脅威決定
        local minID, minT = 0, math.huge
        for ID, DATA in pairs(data) do
            local x, y, z, vx, vy, vz = DATA.x[1][1], DATA.x[4][1], DATA.x[7][1], DATA.x[2][1], DATA.x[5][1], DATA.x[8][1]
            local cv, ct = calClosingSpeed(x, y, z, vx, vy, vz)

            if ct < minT then
                minT = ct
                minID = ID
            end
        end
        
        --スタンバイ
        if minID == 0 then
            if dataSRD[1] and dataSRD[2] then   --第一脅威、第二脅威ともに検出
                local x, y, z, residual

                --レーダーが向いてる方向と第一脅威の方向の差(視野内にいるか)
                x, y, z = returnSRD(1)
                x, y, z = rotation.world2Local(x, y, z, Px, Py, Pz, Ex, Ey, Ez)
                _, x, y = rect2Polar(x, y, z, false)
                residual = math.abs(x - radarGimbalX[1])

                if residual < 0.04/2 then       --視野内に第一脅威がいるはずなのに検出なし
                    Wx, Wy, Wz = returnSRD(2)
                else                            --第一脅威が視野内ではない
                    Wx, Wy, Wz = returnSRD(1)
                end
            elseif dataSRD[1] then              --第一脅威のみ検出
                Wx, Wy, Wz = returnSRD(1)
            else                                --第二脅威のみ検出
                Wx, Wy, Wz = returnSRD(2)
            end

            local Lx, Ly, Lz = rotation.world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
            _, radarX, radarY = rect2Polar(Lx, Ly, Lz, false)
            radarOn = true
        else    --検出中は追尾レーダー第一脅威を追尾
            local DATA = data[minID].x
            Wx, Wy, Wz = DATA[1][1], DATA[4][1], DATA[7][1]
            radarOn = true
        end

        --明らかやばい脅威
        if (dataSRD[1] and minID ~= 0) and (dataSRD[1].t < minT - 300) then
            Wx, Wy, Wz = returnSRD(1)
            local Lx, Ly, Lz = rotation.world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
            _, radarX, radarY = rect2Polar(Lx, Ly, Lz, false)
        end

        isConvergence = isTRdetected and (data[minID].t > CONVERGENCE_TICK) --収束している

        --砲制御
        if minID ~= 0 then
            local DATA = data[minID].current
            TRD1X, TRD1Y, TRD1Z, TRD1Vx, TRD1Vy, TRD1Vz, TRD1Ax, TRD1Ay, TRD1Az = DATA.x, DATA.y, DATA.z, DATA.vx, DATA.vy, DATA.vz, DATA.ax, DATA.ay, DATA.az
            if isConvergence then
                TRD1Exists = true
            else
                directAimEnable = true
            end
        end

    else                            --手動操作
        --ELI2との同一判定
        local minID, minDist = 0, math.huge
        if ELI2Exist then
            local errorRange = 0.05*distance3(ELI2X, ELI2Y, ELI2Z, Px, Pz, Py) + SAME_VEHICLE_RADIUS
            for ID, DATA in pairs(data) do
                local dist = distance3(ELI2X, ELI2Y, ELI2Z, DATA.x[1][1], DATA.x[4][1], DATA.x[7][1])
                if dist < errorRange and dist < minDist then
                    minDist = dist
                    minID = ID
                end
            end
        end

        if minID ~= 0 then          --自レーダーに反応あり
            radarOn = true
            TRD1Exists = true
            local DATA = data[minID].x
            TRD1X, TRD1Y, TRD1Z, TRD1Vx, TRD1Vy, TRD1Vz, TRD1Ax, TRD1Ay, TRD1Az = DATA[1][1], DATA[4][1], DATA[7][1], DATA[2][1], DATA[5][1], DATA[8][1], DATA[3][1], DATA[6][1], DATA[9][1]
        elseif ELI2Exist then       --ELI2にのみ反応あり
            radarOn = true
            TRD1Exists = true
            TRD1X, TRD1Y, TRD1Z, TRD1Vx, TRD1Vy, TRD1Vz, TRD1Ax, TRD1Ay, TRD1Az = ELI2X, ELI2Y, ELI2Z, ELI2Vx, ELI2Vy, ELI2Vz, 0, 0, 0
        end

        --レーダージンバル計算
        if radarOn then
            local Lx, Ly, Lz = rotation.world2Local(TRD1X, TRD1Y, TRD1Z, Px, Py, Pz, Ex, Ey, Ez)
            _, radarX, radarY = rect2Polar(Lx, Ly, Lz, false)
        end
    end

    --レーダージンバルの現在方向記録
    table.insert(radarGimbalX, radarX)
    table.remove(radarGimbalX, 1)

    OUB(1, TRD1Exists)
    OUB(2, radarOn)
    OUB(3, directAimEnable)

    OUN(1, radarX)
    OUN(2, radarY)

    OUN(3, TRD1X)
    OUN(4, TRD1Y)
    OUN(5, TRD1Z)
    OUN(6, TRD1Vx)
    OUN(7, TRD1Vy)
    OUN(8, TRD1Vz)
    OUN(9, TRD1Ax)
    OUN(10, TRD1Ay)
    OUN(11, TRD1Az)

    OUB(9, INB(9))
    OUB(10, INB(10))
    OUB(11, INB(11))

    --debug
    OUN(31, #data)
end