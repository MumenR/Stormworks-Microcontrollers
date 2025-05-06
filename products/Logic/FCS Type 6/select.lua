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
PRB = property.getBool

data = {}
push_t = 0
lock_on_ID = 0
select_ID = 0

function atan2(x, y)
    if x >= 0 then
        ans = math.atan(y/x)
    elseif y >= 0 then
        ans = math.atan(y/x) + math.pi
    else
        ans = math.atan(y/x) - math.pi
    end
    return ans
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

--直交座標から極座標へ変換
function Rect2Polar(x, y, z, radian_bool)
    local pitch, yaw
    pitch = atan2(math.sqrt(x^2 + y^2), z)
    yaw = atan2(y, x)
    distance = math.sqrt(x^2 + y^2 + z^2)
    if radian_bool then
        return pitch, yaw, distance
    else
        return pitch/(math.pi*2), yaw/(math.pi*2), distance
    end
end

--目標を選択
function onTick()
    Px = INN(25)
    Py = INN(26)
    Pz = INN(27)
    Ex = INN(28)
    Ey = INN(29)
    Ez = INN(30)
    seat_x = INN(31)
    seat_y = INN(32)

    lock_push = INB(1)

    delete_tick = PRN("target lost tick")*2

    --時間経過
    for ID, tgt in pairs(data) do
        tgt.t = tgt.t + 1
    end

    --データ取り込み
    --data[ID]{x, y, z, t}
    for i = 0, 5 do
        ID = INN(i*4 + 4)%10000
        if ID ~= 0 then
            data[ID] = {
                x = INN(i*4 + 1),
                y = INN(i*4 + 2),
                z = INN(i*4 + 3),
                t = 0
            }
        end
    end

    --一定時間以上で削除
    for ID, tgt in pairs(data) do
        if tgt.t > delete_tick then
            data[ID] = nil
        end
    end

    --短押し判定
    if lock_push then
        push_t = push_t + 1
    end
    lock_push_pulse = push_t < 15 and push_t > 0 and not lock_push
    if not lock_push then
        push_t = 0
    end
    --ロックオン切り替え
    if lock_push_pulse and #data ~= 0 then
        lock_on = lock_on_ID ~= select_ID
    elseif #data == 0 or (data[lock_on_ID] == nil and lock_on_ID ~= 0) then
        lock_on = false
    end

    --視点方向との差が最小のIDを探す
    error_min = (30/360)^2
    select_ID = 0
    for ID, tgt in pairs(data) do
        local Lx, Ly, Lz, Lpi, Lya, Ldi, error
        Lx, Ly, Lz = World2Local(tgt.x, tgt.y, tgt.z, Px, Py, Pz, Ex, Ey, Ez)
        Lpi, Lya, Ldi = Rect2Polar(Lx, Ly, Lz, false)

        error = (Lpi - seat_y)^2 + (Lya - seat_x)^2

        if error < error_min then
            error_min = error
            select_ID = ID
        end
    end

    --ロックオンID更新
    if select_ID ~= 0 and lock_on and lock_push_pulse then
        lock_on_ID = select_ID
    elseif not lock_on then
        lock_on_ID = 0
    end

    OUN(1, lock_on_ID)
    OUN(2, select_ID)

    --デバッグ用
    OUN(3, error_min)
end