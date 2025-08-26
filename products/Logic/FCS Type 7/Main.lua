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

CAM_RAD_MIN = 0.025
CAM_RAD_MAX = 2.2

--行列演算ライブラリ
matrix = {
    --和(A+B)
    add = function(A, B)
        local C = {}
        for i = 1, #A do
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

--拡張カルマンフィルタ
EKF = {

}

--ワールド座標からローカル座標へ(physics sensor使用)
function world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
    local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y, Lower
	Wx = Wx - Px
	Wy = Wy - Pz
	Wz = Wz - Py
	a = math.cos(Ez)*math.cos(Ey)
	b = math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex)
	c = math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex)
	d = Wx
	e = math.sin(Ez)*math.cos(Ey)
	f = math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex)
	g = math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex)
	h = Wz
	i = -math.sin(Ey)
	j = math.cos(Ey)*math.sin(Ex)
	k = math.cos(Ey)*math.cos(Ex)
	l = Wy
	Lower = ((a*f-b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
	x = 0
	y = 0
	z = 0
	if Lower ~= 0 then
		x = ((b*g - c*f)*l + (d*f - b*h)*k + (c*h - d*g)*j)/Lower
		y = -((a*g - c*e)*l + (d*e - a*h)*k + (c*h - d*g)*i)/Lower
		z = ((a*f - b*e)*l + (d*e - a*h)*j + (b*h - d*f)*i)/Lower
	end
	return x, z, y
end

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

--ワールド直交座標からディスプレイ座標へ変換(fovはラジアン)
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
    return matrix.mul(matrix.mul(matrix.transpose(matrix.sub(X, mean)), matrix.inv(var)), matrix.sub(X, mean))
end

--カメラズーム変換(FOVはラジアン)
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

zoomManual = 0
posDelayBuffer = {}
function onTick()

    VEHICLE_RADIUS = PRN("Vehicle radius [m]")
    ZOOM_GAIN = PRN("Zoom speed gain")
    MIN_FOV = PRN("Min fov [rad]")
    MAX_FOV = PRN("Max fov [rad]")

    laserDist = INN(28)
    seatIn3 = INN(29)
    currentPitch = INN(30)

    power = INB(9)

    --ズーム計算
    if power then
        if seatIn3 == -1 and zoomManual < 1 then
            zoomManual = zoomManual + 0.01*ZOOM_GAIN
        elseif seatIn3 == 1 and zoomManual > 0 then
            zoomManual = zoomManual - 0.01*ZOOM_GAIN
        end
    else
        zoomManual = 0
    end
    zoomCaled, zoomRadCaled = calZoom(zoomManual, MIN_FOV, MAX_FOV)

    --フィジックス情報取り込み
    --遅延生成
    table.insert(posDelayBuffer, {Px = INN(22), Py = INN(23), Pz = INN(24), Ex = INN(25), Ey = INN(26), Ez = INN(27)})
    while #posDelayBuffer > 7  do
        table.remove(posDelayBuffer, 1)
    end
    Px = posDelayBuffer[1].Px
    Py = posDelayBuffer[1].Py
    Pz = posDelayBuffer[1].Pz
    Ex = posDelayBuffer[1].Ex
    Ey = posDelayBuffer[1].Ey
    Ez = posDelayBuffer[1].Ez

    --データ取り込み
    --newTGT = {{dist, yaw, pitch}, ...}
    newTGT = {}
    for i = 1, 7 do
        local dist, yaw, pitch, Lx, Ly, Lz
        dist = INN(i*3 - 2)
        yaw = INN(i*3 - 1)
        pitch = INN(i*3 - 0)
        Lx, Ly, Lz = polar2Rect(dist, yaw, pitch, false)

        if INB(i) and dist >= VEHICLE_RADIUS then
            --追加
            table.insert(newTGT, {dist = dist, yaw = yaw, pitch = pitch, Lx = Lx, Ly = Ly, Lz = Lz})
        end
    end

    OUN(31, zoomManual)
    OUN(32, zoomCaled)

end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    fovW = zoomRadCaled*(h/w)
    fovH = zoomRadCaled

    --レーダー反応描画
    screen.setColor(0, 255, 0)
    for _, tgt in pairs(newTGT) do
        x1, y1, drawable1 = localRect2Display(tgt.Lx, tgt.Ly, tgt.Lz, w, h, fovW, fovW)
        x1 = math.floor(x1)
        y1 = math.floor(y1)
        if drawable1 then
            --円
            if tgt.lock or not tgt.MXT_out then
                screen.drawCircle(x1, y1, 4)
            end
        end
    end
end