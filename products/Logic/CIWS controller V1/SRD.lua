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
data = {}

TARGET_DELETE_TICK = 120

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

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

--x(t) = at + bを最小二乗法で求める
--ft = {{t = tick, x = X}, ...}
function leastSquaresMethod(ft)
    local a, b, sum_t, sum_x, sum_tx, sum_t2 = 0, 0, 0, 0, 0, 0
    local maxminT = ft[1].t and (ft[#ft].t - ft[1].t)
    if #ft < 2 or maxminT < 30 then
        a = 0
        b = ft[#ft].x
    else
        for _, FT in pairs(ft) do
            sum_t = sum_t + FT.t
            sum_x = sum_x + FT.x
            sum_tx = sum_tx + FT.t*FT.x
            sum_t2 = sum_t2 + FT.t^2
        end
        a = (#ft*sum_tx - sum_t*sum_x)/(#ft*sum_t2 - sum_t^2)
        b = (sum_t2*sum_x - sum_tx*sum_t)/(#ft*sum_t2 - sum_t^2)
    end
    return a or 0, b or 0
end

--対向速度と到達時間(近づくなら正)
function calClosingSpeed(Tx, Ty, Tz, Tvx, Tvy, Tvz)
    local Lx, Ly, Lz, Lvx, Lvy, Lvz, dist, cv, ct
    Lx, Ly, Lz = world2Local(Tx, Ty, Tz, Px, Py, Pz, Ex, Ey, Ez)
    Lvx, Lvy, Lvz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Ex, Ey, Ez)
    Lvx, Lvy, Lvz = Lvx - Pvx, Lvy - Pvz, Lvz - Pvy
    dist = math.sqrt(Lx^2 + Ly^2 + Lz^2)
    --対向速度
    cv = -(Lvx*Lx + Lvy*Ly + Lvz*Lz)/dist
    --到達時間
    ct = cv > 0 and clamp(dist/cv, 0, math.huge) or math.huge
    return cv, ct
end

function onTick()
    Px, Py, Pz, Ex, Ey, Ez = INN(25), INN(26), INN(27), INN(28), INN(29), INN(30)
    Pvx, Pvy, Pvz = 0, INN(31), 0

    --データ登録
    --[[
        data[ID] = {
            raw = {{x = x, y = y, z = z, t = 検知時が0、時間経過で減少}, ... }
            predict = {x = x, y = y, z = z, vx = vx, vy = vy, vz = vz}
        }
    ]]
    for i = 1, 6 do
        ID = INN(4*i)%1000
        if ID > 0 then
            local buffer = {
                x = INN(4*i - 3),
                y = INN(4*i - 2),
                z = INN(4*i - 1),
                t = 0
            }

            --場所がないなら作る
            if not data[ID] then
                data[ID] = {raw = {}}
            end
            table.insert(data[ID].raw, buffer)
        end
    end

    --時間経過と削除
    for ID, DATA in pairs(data) do
        for _, RAW in ipairs(DATA.raw) do
            RAW.t = RAW.t - 1
        end

        if DATA.raw[1].t <= -TARGET_DELETE_TICK then
            table.remove(data[ID].raw, 1)
            if #data[ID].raw == 0 then
                data[ID] = nil
            end
        end
    end

    --予測
    for ID, DATA in pairs(data) do
        --予測用テーブル作成
        local tableX, tableY, tableZ = {}, {}, {}
        for _, value in pairs(DATA.raw) do
            table.insert(tableX, {x = value.x, t = value.t})
            table.insert(tableY, {x = value.y, t = value.t})
            table.insert(tableZ, {x = value.z, t = value.t})
        end

        local vx, vy, vz, x, y, z
        vx, x = leastSquaresMethod(tableX)
        vy, y = leastSquaresMethod(tableY)
        vz, z = leastSquaresMethod(tableZ)

        data[ID].predict = {x = x, y = y, z = z, vx = vx, vy = vy, vz = vz}
    end

    --到達時間計算
    for ID, DATA in pairs(data) do
        local cv, ct = calClosingSpeed(DATA.predict.x, DATA.predict.y, DATA.predict.z, DATA.predict.vx, DATA.predict.vy, DATA.predict.vz)
        data[ID].closing = {cv = cv, ct = ct}
    end

    --最短到達時間の目標を探索
    minID, minT = 0, math.huge
    for ID, DATA in pairs(data) do
        if DATA.closing.ct < minT then
            minID = ID
            minT = DATA.closing.ct
        end
    end

    --最小値到達時間の目標を出力
    OUN(4, 0)
    OUN(5, minT)
    if minID ~= 0 then
        OUN(1, data[minID].predict.x)
        OUN(2, data[minID].predict.y)
        OUN(3, data[minID].predict.z)
        OUN(4, minID)
    end
end