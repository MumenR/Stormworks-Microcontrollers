-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
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

pi2 = math.pi*2

STABI_DELAY_LASER = 4
STABI_DELAY_PIVOT = 7.45

--ローカル座標からワールド座標へ変換(physics sensor使用)
function local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
    local RetX, RetY, RetZ
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

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

--回転数そろえる
function sameRotation(x)
    return (x + 0.5)%1 - 0.5
end

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

--角速度より未来位置計算
tDelta = 0.1
function stabiFutureAngle(x, y, z, rvx, rvy, rvz, tick)
    local x_diff, y_diff, z_diff, abs_vector, t
    t = 0
    while t <= tick do
        --外積(変分)を計算
        x_diff, y_diff, z_diff = y*rvz - z*rvy, z*rvx - x*rvz, x*rvy - y*rvx
        --位置ベクトルに足し合わせる
        x, y, z = x + x_diff*tDelta, y + y_diff*tDelta, z + z_diff*tDelta
        --単位ベクトル化
        abs_vector = math.sqrt(x^2 + y^2 + z^2)
        x, y, z = x/abs_vector, y/abs_vector, z/abs_vector
        t = t + tDelta
    end
    return x, y, z
end

--視線角速度
function losRv(vx, vy, vz, Tx, Ty, Tz, Tvx, Tvy, Tvz)
    local LRvx, LRvy, LRvz
    LRvx = math.atan(Ty + Tvy - vy, Tz + Tvz - vz) - math.atan(Ty, Tz)
    LRvy = math.atan(Tz + Tvz - vz, Tx + Tvx - vx) - math.atan(Tz, Tx)
    LRvz = math.atan(Tx + Tvx - vx, Ty + Tvy - vy) - math.atan(Tx, Ty)
    return LRvx, LRvy, LRvz
end

yawErrorSum = 0
yawErrorPre = 0

--PID制御
function PID(P, I, D, target, current, error_sum_pre, error_pre, min, max)
    local error, error_diff, controll
    error = target - current
    error_sum = error_sum_pre + error
    error_diff = error - error_pre
    controll = P*error + I*error_sum + D*error_diff

    if controll > max or controll < min then
        error_sum = error_sum_pre
        controll = P*error + I*error_sum + D*error_diff
    end
    return clamp(controll, min, max), error_sum, error
end

pitchAngle = 0
function onTick()
    Px, Py, Pz = INN(1), INN(2), INN(3)
    Ex, Ey, Ez = INN(4), INN(5), INN(6)
    Vx, Vy, Vz = INN(7)/60, INN(8)/60, INN(9)/60
    Rvx, Rvy, Rvz = INN(10)*pi2/60, INN(11)*pi2/60, INN(12)*pi2/60

    ELI3X, ELI3Y, ELI3Z = INN(13), INN(14), INN(15)
    ELI3Exists = INN(16) == 1

    ELI2X, ELI2Y, ELI2Z = INN(17), INN(18), INN(19)
    ELI2Vx, ELI2Vy, ELI2Vz = INN(20), INN(21), INN(22)
    ELI2Exists = INN(23) == 1

    zoomRadCaled = INN(24)

    seatAD, seatWS = INN(25), INN(26)

    yawPosition = sameRotation(INN(27))
    power = INN(28) == 1

    stabiEnabled = INN(29) == 1
    autoaimEnabled = INN(30) == 1

    CONTROL_GAIN = PRN("Cam control gain")

    GEAR, PIVOT = PRN("Gear ratio (1 : ?)"), PRN("Types of Yaw PIVOT")
    P, I, D = PRN("P"), PRN("I"), PRN("D")

    OFFSET_X, OFFSET_Y, OFFSET_Z = PRN("Body phys. offset X"), PRN("Body phys. offset Y"), PRN("Body phys. offset Z")
    offsetPx, offsetPz, offsetPy = local2World(OFFSET_X, OFFSET_Y, OFFSET_Z, Px, Py, Pz, Ex, Ey, Ez)

    isTrack = autoaimEnabled and ELI2Exists

    --スタビライザーと追尾モード
    if power and (stabiEnabled or isTrack) then
        --基準ワールドベクトル初期値設定
        if not stabiPulse then
            stabiLx, stabiLy, stabiLz = polar2Rect(1, yawPosition, pitchAngle, false)
            stabiWx, stabiWy, stabiWz = local2World(stabiLx, stabiLy, stabiLz, 0, 0, 0, Ex, Ey, Ez)
        end

        --追尾モード
        if isTrack then
            manualLx, manualLy, manualLz = 0, 0, 0
            pitchManualDirec, yawManualDirec = 0, 0
            stabiWx, stabiWy, stabiWz = ELI2X - offsetPx, ELI2Y - offsetPz, ELI2Z - offsetPy
        else
            --手動変量
            pitchManualDirec = -pi2*CONTROL_GAIN*zoomRadCaled*seatWS/60
            yawManualDirec = pi2*CONTROL_GAIN*zoomRadCaled*seatAD/60
            --ジンバルロック
            manualLx = pitchManualDirec*math.cos(yawPosition*pi2)
            manualLy = -pitchManualDirec*math.sin(yawPosition*pi2)
            manualLz = yawManualDirec
        end

        --基準ローカルベクトルへ変換
        stabiLx, stabiLy, stabiLz = world2Local(stabiWx, stabiWy, stabiWz, 0, 0, 0, Ex, Ey, Ez)

        --基準ローカルベクトルの変分を加算して更新(手動操作)
        stabiLx, stabiLy, stabiLz = stabiFutureAngle(stabiLx, stabiLy, stabiLz, manualLx, manualLy, manualLz, 1)
        local _, stabiYawAngle, stabiPitchAngle = rect2Polar(stabiLx, stabiLy, stabiLz, false)
        stabiLx, stabiLy, stabiLz = polar2Rect(1, stabiYawAngle, clamp(stabiPitchAngle, -0.125, 0.25))

        --基準ワールドベクトル更新
        stabiWx, stabiWy, stabiWz = local2World(stabiLx, stabiLy, stabiLz, 0, 0, 0, Ex, Ey, Ez)
        
        --角速度変換(スタビライザー)
        local LRvx, LRvy, LRvz = world2Local(Rvx, Rvz, Rvy, 0, 0, 0, Ex, Ey, Ez)

        if isTrack then
            --追尾用視線角速度算出
            local TLx, TLy, TLz = world2Local(ELI2X, ELI2Y, ELI2Z, offsetPx, offsetPy, offsetPz, Ex, Ey, Ez)
            local TLvx, TLvy, TLvz = world2Local(ELI2Vx, ELI2Vy, ELI2Vz, 0, 0, 0, Ex, Ey, Ez)
            local TLosX, TLosY, TLosZ = losRv(0, 0, 0, TLx, TLy, TLz, TLvx, TLvy, TLvz)
            LRvx, LRvy, LRvz = LRvx - TLosX, LRvy - TLosY, LRvz - TLosZ
        end
        
        --レーザースタビ
        local stabiLaserX, stabiLaserY, stabiLaserZ = stabiFutureAngle(stabiLx, stabiLy, stabiLz, -LRvx, -LRvy, -LRvz, STABI_DELAY_LASER)
        _, _, pitchAngle = rect2Polar(stabiLaserX, stabiLaserY, stabiLaserZ, false)

        --ピボットスタビ
        local stabiPivotX, stabiPivotY, stabiPivotZ = stabiFutureAngle(stabiLx, stabiLy, stabiLz, -LRvx, -LRvy, -LRvz, STABI_DELAY_PIVOT)
        _, yawAngle, _ = rect2Polar(stabiPivotX, stabiPivotY, stabiPivotZ, false)
        local yawDiff = GEAR*sameRotation(yawAngle + yawManualDirec - yawPosition)/PIVOT
        yawSpeed, yawErrorSum, yawErrorPre = PID(P, I, D, 0, -yawDiff, yawErrorSum, yawErrorPre, -100, 100)

    elseif power then
        yawErrorSum, yawErrorPre = 0, 0
        --手動操作
        pitchAngle = clamp(CONTROL_GAIN*zoomRadCaled*seatWS/60 + pitchAngle, -0.125, 0.25)
        yawSpeed = CONTROL_GAIN*zoomRadCaled*seatAD*GEAR/PIVOT
    else
        --電源オフ
        pitchAngle = 0
        yawSpeed, yawErrorSum, yawErrorPre = PID(P, I, D, 0, yawPosition, yawErrorSum, yawErrorPre, -100, 100)
    end
    stabiPulse = power and (stabiEnabled or isTrack)

    upperCamPitch = clamp(pitchAngle - 0.25, -0.125, 0)
    upperCamEnabled = pitchAngle > 0.125

    --nil対策
    if yawSpeed == nil then
        yawSpeed = 0
    end

    OUB(1, upperCamEnabled)

    OUN(1, 0)
    OUN(2, pitchAngle*8)
    OUN(3, yawSpeed)
    OUN(4, pitchAngle)
    OUN(5, 0)
    OUN(6, upperCamPitch*8)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(0, 255, 0)
    if stabiEnabled then
        screen.drawText(1, h - 6, "STAB")
    end

    if autoaimEnabled then
        screen.drawText(25, h - 6, "AUTO")
    end
end