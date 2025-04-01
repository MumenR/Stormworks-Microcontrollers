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
pi2 = math.pi*2
fov_w = (73/360)*pi2
fov_h = (58/360)*pi2

function distance3(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
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

--ローカル座標からディスプレイ座標へ変換
function Local2Display(Lx, Ly, Lz)
    local Dx, Dy, drawable
    Dx = w/2 + (Lx/Ly)*(w/2)/math.tan(fov_w/2)
    Dy = h/2 - (Lz/Ly)*(h/2)/math.tan(fov_h/2)
    drawable = Ly > 0
    return Dx, Dy, drawable
end

--ワールド直交座標からディスプレイ座標へ変換
function WorldRect2Display(Wx, Wy, Wz, Ex, Ey, Ez)
    local Lx, Ly, Lz, Dx, Dy, drawable

    --ローカル座標へ変換
    Lx, Ly, Lz = World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
    Lx, Ly, Lz = World2Local(Lx, Ly, Lz, 0, 0, 0, -seat_y, seat_x, 0)

    --ディスプレイ座標へ変換
    Dx, Dy, drawable = Local2Display(Lx, Ly, Lz)
    
    return Dx, Dy, drawable
end

function onTick()
    Px = INN(25)
    Py = INN(26)
    Pz = INN(27)
    Ex = INN(28)
    Ey = INN(29)
    Ez = INN(30)
    seat_x = INN(31)*pi2
    seat_y = INN(32)*pi2

    delete_tick = PRN("Radar delete tick")
    dist_unit = PRN("Distance Units")

    --時間経過
    for ID, tgt in pairs(data) do
        tgt.t = tgt.t + 1
    end

    --データ取り込み
    --data[ID]{x, y, z, t}
    for i = 0, 5 do
        ID = INN(i*4 + 4)
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

    --デバッグ用
    OUN(30, #data)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --レーダー反応描画
    screen.setColor(0, 255, 0)
    for ID, tgt in pairs(data) do
        x1, y1, drawable1 = WorldRect2Display(tgt.x, tgt.y, tgt.z, Ex, Ey, Ez)
        x1 = math.floor(x1)
        y1 = math.floor(y1)
        if drawable1 then
            screen.drawRect(x1 - 4, y1 - 4, 8, 8)

            --ID
            TGTid = tostring(ID)
            screen.drawText(x1 + 1 - 2.5*#TGTid, y1 - 10, TGTid)

            --距離数値
            tgt_dist = distance3(Px, Pz, Py, tgt.x, tgt.y, tgt.z)*dist_unit
            if tgt_dist >= 10 then
                TGTd = string.format("%.0f", math.floor(tgt_dist + 0.5))
            else
                TGTd = string.format("%.1f", math.floor(tgt_dist*10 + 0.5)/10)
            end
            screen.drawText(x1 + 1 - 2.5*#TGTd, y1 + 6, TGTd)
        end
    end
end



