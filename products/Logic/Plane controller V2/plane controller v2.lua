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
PRT = property.getText

PH_pulse = false
RH_pulse = false

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
end

--ワールド座標からローカル座標へ(physics sensor使用)
function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
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

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
    local RetX, RetY, RetZ
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--ティルトセンサーを全周対応
function tilt_around(tilt, Ex, Ey, Ez)
    local Wx, Wy, Wz = Local2World(0, 0, 1, 0, 0, 0, Ex, Ey, Ez)
    if Wz < 0 then
        if tilt < 0 then
            tilt = -0.5 - tilt
        else
            tilt = 0.5 - tilt
        end
    end
    return tilt
end

function same_rotation(x)
    return (x + 0.5)%1 - 0.5
end

rE, rS = 0, 0
pE, pS = 0, 0
yE, yS = 0, 0
cE, cS = 0, 0
VzE, VzS = 0, 0
VxE, VxS = 0, 0
VyE, VyS = 0, 0
RHE, RHS = 0, 0

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

--円描画
function drawCircle(x, y, r, start_degree, stop_degree)
    for i = start_degree, stop_degree - 10, 10 do
        local x1, y1, x2, y2
        x1, y1 = r*math.cos(math.pi*i/180), r*math.sin(math.pi*i/180)
        x2, y2 = r*math.cos(math.pi*(i + 10)/180), r*math.sin(math.pi*(i + 10)/180)
        screen.drawLine(x + x1, y - y1, x + x2, y - y2)
    end
end

pivot_down_pulse = false
pivot_up_pulse = false
pivot_manual = 0

function onTick()
    Px, Py, Pz = INN(1), INN(2), INN(3)
    Ex, Ey, Ez = INN(4), INN(5), INN(6)
    Lvx, Lvy, Lvz = INN(7), INN(9), INN(8)
    Wvx, Wvy, Wvz = Local2World(Lvx, Lvy, Lvz, 0, 0, 0, Ex, Ey, Ez)
    V_abs = INN(13)
    Rx, Ry, Rz = World2Local(INN(10), INN(12), INN(11), 0, 0, 0, Ex, Ey, Ez)
    tilt_x = INN(16)
    tilt_y = INN(15)
    seat_ro = clamp(INN(18) + INN(22), -1, 1)
    seat_pi = clamp(INN(19) + INN(23), -1, 1)
    seat_ya = clamp(INN(20) + INN(24) + INN(27), -1, 1)
    seat_co = clamp(INN(21) + INN(25), -1, 1)

    tgt_alt = INN(26)*0.3048

    prop_RPS_L = INN(28)
    prop_RPS_R = INN(29)

    tilt_L = INN(30)
    tilt_R = INN(31)

    pivot_down = INB(1)
    pivot_up = INB(2)
    AH = INB(3)
    RH = INB(4)
    PH = INB(5)
    AP = INB(6)
    taxing = INB(7)
    power = INB(8)


    rP, rI, rD = PRN("roll P"), PRN("roll I"), PRN("roll D")
    pP, pI, pD = PRN("pitch P"), PRN("pitch I"), PRN("pitch D")
    yP, yI, yD = PRN("yaw P"), PRN("yaw I"), PRN("yaw D")
    cP, cI, cD = PRN("collective P"), PRN("collective I"), PRN("collective D")

    aiP, aiI, aiD = PRN("aileron P"), PRN("aileron I"), PRN("aileron D")
    elP, elI, elD = PRN("elevator P"), PRN("elevator I"), PRN("elevator D")
    ruP, ruI, ruD = PRN("rudder P"), PRN("rudder I"), PRN("rudder D")

    CTOLpP, CTOLpI, CTOLpD = PRN("CTOL AH Pitch P"), PRN("CTOL AH Pitch I"), PRN("CTOL AH Pitch D")
    CTOLVzP, CTOLVzI, CTOLVzD = PRN("CTOL AH Vz P"), PRN("CTOL AH Vz I"), PRN("CTOL AH Vz D")

    PHP, PHI, PHD = PRN("PH P"), PRN("PH I"), PRN("PH D")
    RHP, RHI, RHD = PRN("RH P"), PRN("RH I"), PRN("RH D")

    throttle_up = false
    throttle_down = false

    --ティルト角度
    if pivot_up and not pivot_up_pulse then
        pivot_manual = clamp(pivot_manual - 30, 0, 90)
    elseif pivot_down and not pivot_down_pulse then
        pivot_manual = clamp(pivot_manual + 30, 0, 90)
    end
    pivot_up_pulse = pivot_up
    pivot_down_pulse = pivot_down

    if PH then
        pivot_manual = 0
    end

    --飛行モード
    VTOL = pivot_manual <= 45

    --座標維持
    if PH and not PH_pulse then
        PH_x, PH_y = Px, Pz
    end
    PH_pulse = PH

    --ロール保持
    if RH and not RH_pulse then
        RH_tilt_x = tilt_around(tilt_x, Ex, Ey, Ez)
    end
    RH_pulse = RH

    --PID
    if power then
        local rT, pT, yT, cT, rC, pC, yC, cC
        --垂直離着陸モード
        if VTOL then
            if not VTOL_pulse then
                rE, rS = 0, 0
                pE, pS = 0, 0
                yE, yS = 0, 0
                cE, cS = 0, 0
            end

            rT, pT, yT, cT = seat_ro/20, seat_pi/20, seat_ya/8, seat_co*20
            rC, pC, yC, cC = -tilt_x, -tilt_y, Rz, Lvz
            VzE, VzS = 0, 0
            RHE, RHS = 0, 0

            --高度維持
            if AH then
                cT = clamp(tgt_alt - Py, -20, 20)
                cC = Wvz
            end

            --座標維持
            if PH then
                local Lx, Ly, Lz = World2Local(PH_x, PH_y, 0, Px, 0, Pz, Ex, Ey, Ez)
                VxT, VyT = clamp(Lx/10, -10, 10), clamp(Ly/10, -10, 10)
                rT, VxS, VxE = PID(PHP, PHI, PHD, VxT, Lvx, VxS, VxE, -1/8, 1/8)
                pT, VyS, VyE = PID(PHP, PHI, PHD, VyT, Lvy, VyS, VyE, -1/8, 1/8)
                --rT, pT = -rT, -pT
            else
                VxE, VxS = 0, 0
                VyE, VyS = 0, 0
            end

            --メインPID
            r_PID, rS, rE = PID(rP, rI, rD, rT, rC, rS, rE, -1, 1)
            p_PID, pS, pE = PID(pP, pI, pD, pT, pC, pS, pE, -1, 1)
            y_PID, yS, yE = PID(yP, yI, yD, yT, yC, yS, yE, -1, 1)
            c_PID, cS, cE = PID(cP, cI, cD, cT, cC, cS, cE, -1, 1)

            roll_L, roll_R = r_PID, -r_PID
            pitch_L, pitch_R = p_PID, p_PID
            pivot_auto_L, pivot_auto_R = y_PID/2, -y_PID/2
            collective_L, collective_R = c_PID + r_PID, c_PID - r_PID

            --コレクティブ逆転時
            if collective_L < 0 then
                pivot_auto_L = -pivot_auto_L
                roll_L = -roll_L
                pitch_L = -pitch_L
            end
            if collective_R < 0 then
                pivot_auto_R = -pivot_auto_R
                roll_R = -roll_R
                pitch_R = -pitch_R
            end
        --固定翼モード
        else
            if VTOL_pulse then
                rE, rS = 0, 0
                pE, pS = 0, 0
                yE, yS = 0, 0
                cE, cS = 0, 0
                VzE, VzS = 0, 0
            end

            rT, pT, yT = seat_ro/5, seat_pi/10, seat_ya/30
            rC, pC, yC = -Ry, Rx, Rz

            --高度維持
            if AH then
                VzT = clamp((tgt_alt - Py)/5, -30, 30)
                pT, VzS, VzE = PID(CTOLVzP, CTOLVzI, CTOLVzD, VzT, Wvz, VzS, VzE, -0.25, 0.25)
                pT = -pT
                pC = -tilt_y
                elP, elI, elD = CTOLpP, CTOLpI, CTOLpD
            else
                VzE, VzS = 0, 0
            end

            --ロール保持
            if RH then
                RHT = same_rotation(RH_tilt_x - tilt_around(tilt_x, Ex, Ey, Ez))
                rT, RHS, RHE = PID(RHP, RHI, RHD, RHT, 0, RHS, RHE, -0.2, 0.2)
                rT = -rT
            else
                RHE, RHS = 0, 0
            end

            --メインPID
            r_PID, rS, rE = PID(aiP, aiI, aiD, rT, rC, rS, rE, -1, 1)
            p_PID, pS, pE = PID(elP, elI, elD, pT, pC, pS, pE, -1, 1)
            y_PID, yS, yE = PID(ruP, ruI, ruD, yT, yC, yS, yE, -1, 1)
            cE, cS = 0, 0
            VxE, VxS = 0, 0
            VyE, VyS = 0, 0

            --高度維持用補正
            if AH then
                local Wx, Wy, Wz = Local2World(0, 0, 1, 0, 0, 0, Ex, Ey, Ez)
                if Wz >= 0 then
                    p_PID = 4*(0.25 - math.abs(tilt_x))*p_PID/2
                else
                    p_PID = -4*(0.25 - math.abs(tilt_x))*p_PID/2
                end
            end

            roll_L, roll_R = y_PID, -y_PID
            pitch_L, pitch_R = p_PID, p_PID
            pivot_auto_L, pivot_auto_R = 0, 0
            collective_L, collective_R = 1, 1

            throttle_up = seat_co > 0.1
            throttle_down = seat_co < -0.1
        end

        aileron = r_PID
        elevator = p_PID
        rudder = y_PID
    else
        rE, rS = 0, 0
        pE, pS = 0, 0
        yE, yS = 0, 0
        cE, cS = 0, 0
        VzE, VzS = 0, 0
        VxE, VxS = 0, 0
        VyE, VyS = 0, 0
        RHE, RHS = 0, 0
        
        aileron = 0
        elevator = 0
        rudder = 0
        roll_L = 0
        roll_R = 0
        pitch_L = 0
        pitch_R = 0
        pivot_auto_L = 0
        pivot_auto_R = 0
        collective_L = 0
        collective_R = 0
    end

    VTOL_pulse = VTOL

    if taxing then
        pivot_L, pivot_R = 4*30/360, 4*30/360
        collective_L, collective_R = clamp(seat_co, 0, 1), clamp(seat_co, 0, 1)
    else
        pivot_L = 4*(pivot_manual/360) + pivot_auto_L
        pivot_R = 4*(pivot_manual/360) + pivot_auto_R
    end

    roll_L = roll_L/clamp(prop_RPS_L/60, 1, 100)
    roll_R = roll_R/clamp(prop_RPS_R/60, 1, 100)
    pitch_L = pitch_L/clamp(prop_RPS_L/60, 1, 100)
    pitch_R = pitch_R/clamp(prop_RPS_R/60, 1, 100)

    aileron = aileron/clamp(V_abs/60, 1, 100)
    elevator = elevator/clamp(V_abs/60, 1, 100)
    rudder = rudder/clamp(V_abs/60, 1, 100)

    OUN(1, aileron)
    OUN(2, elevator)
    OUN(3, rudder)

    OUN(4, roll_L)
    OUN(5, roll_R)

    OUN(6, pitch_L)
    OUN(7, pitch_R)

    OUN(8, pivot_L)
    OUN(9, pivot_R)

    OUN(10, collective_L)
    OUN(11, collective_R)

    OUB(1, throttle_up)
    OUB(2, throttle_down)
end

function onDraw()
    --[[
    screen.setColor(255, 255, 255)
    x = string.format("%.03f", tilt_x)
    y = string.format("%.03f", tilt_y)
    rx = string.format("%.03f", Rx)
    ry = string.format("%.03f", Ry)
    rz = string.format("%.03f", Rz)
    wvx = string.format("%.03f", Wvx)
    wvy = string.format("%.03f", Wvy)
    wvz = string.format("%.03f", Wvz)
    screen.drawText(1, 1, "tilt_x:"..x)
    screen.drawText(1, 7, "tilt_y:"..y)
    screen.drawText(1, 13, "Rx:"..rx)
    screen.drawText(1, 19, "Ry:"..ry)
    screen.drawText(1, 25, "Rz:"..rz)
    screen.drawText(1, 31, "Vx:"..wvx)
    screen.drawText(1, 37, "Vy:"..wvy)
    screen.drawText(1, 43, "Vz:"..wvz)
    ]]

    w = screen.getWidth()
    h = screen.getHeight()

    --HMD用ティルト角度表示
    x1, y1 = math.floor(w/10), math.floor(h*9/10)
    rotor_tilt = math.pi*(90 - pivot_manual)/180
    x2, y2 = 20*math.cos(rotor_tilt), 20*math.sin(rotor_tilt)
    x3, y3 = 10*math.cos(rotor_tilt), 10*math.sin(rotor_tilt)
    tilt_txt = string.format("%d", 90 - pivot_manual)
    screen.setColor(0, 255, 0)
    screen.drawText(x1, y1 - 4, tilt_txt)
    screen.drawLine(x1 + x2, y1 - y2, x1 + x3, y1 - y3)
    drawCircle(x1, y1, 15, 0, 90)
    drawCircle(x1, y1, 20, 0, 90)
    screen.drawLine(x1, y1 - 15, x1, y1 - 21)
    screen.drawLine(x1 + 15, y1, x1 + 20, y1)
end



