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
        simulator:setInputNumber(1, 0)
        simulator:setInputNumber(2, 100)
        simulator:setInputNumber(3, 0)
        simulator:setInputNumber(4, 0000*10^4 + 0001)
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

--描画可能判定
function CanDraw(x, y)
    return x >= 0 and x <= w and y >= 0 and y <= h
end

--SRD3マーク描画用関数
function drawSRD3(pixX, pixY, shapeNo, colorNo, addStaticNo, addDynamicNo)
    local drawDottedLine, drawDottedRect, drawDottedTriangle, drawDottedCircle, drawTrueCircle, drawShape

    --点線
    function drawDottedLine(x1, y1, x2, y2)
        local dx, dy, len, step, sx, sy, ex, ey
        dx, dy = x2 - x1, y2 - y1
        len = math.sqrt(dx^2 + dy^2)
        dx, dy = dx / len, dy / len
        step = 1
        for i = 0, len, step*2 do
            sx, sy = x1 + dx*i, y1 + dy*i
            ex, ey = x1 + dx*(i + step), y1 + dy*(i + step)
            if i + step < len then
                screen.drawLine(sx, sy, ex, ey)
            end
        end
    end
    --点矩形
    function drawDottedRect(x, y, w, h)
        drawDottedLine(x, y, x, y + h)
        drawDottedLine(x, y, x + w, y)
        drawDottedLine(x + w, y + h, x, y + h)
        drawDottedLine(x + w, y + h, x + w, y)
    end
    --点三角
    function drawDottedTriangle(x1, y1, x2, y2, x3, y3)
        drawDottedLine(x1, y1, x2, y2)
        drawDottedLine(x2, y2, x3, y3)
        drawDottedLine(x3, y3, x1, y1)
    end
    --点円
    function drawDottedCircle(x, y, r)
        local stepRad = math.atan(1, r)
        for i = 0, pi2, stepRad*2 do
            local x1, y1, x2, y2
            x1 = x + r*math.cos(i)
            y1 = y + r*math.sin(i)
            x2 = x + r*math.cos(i + stepRad)
            y2 = y + r*math.sin(i + stepRad)
            screen.drawLine(x1, y1, x2, y2)
        end
    end

    function drawTrueCircle(x, y, r)
        local step = 10/360*pi2
        for i = 0, pi2 - step, step do
            local x1, y1, x2, y2
            x1 = x + r*math.cos(i)
            y1 = y + r*math.sin(i)
            x2 = x + r*math.cos(i + step)
            y2 = y + r*math.sin(i + step)
            screen.drawLine(x1, y1, x2, y2)
        end
    end

    colorNoData = {
        {0, 255, 0},
        {32, 32, 255},
        {255, 0, 0},
        {255, 0, 0}
    }

    --色設定
    if colorNoData[colorNo + 1] ~= nil then
        screen.setColor(colorNoData[colorNo + 1][1], colorNoData[colorNo + 1][2], colorNoData[colorNo + 1][3])
    else
        screen.setColor(0, 255, 0)
    end

    --形
    drawShape = function(x, y, r, dottedEnable)
        drawLine = dottedEnable and drawDottedLine or screen.drawLine
        drawRect = dottedEnable and drawDottedRect or screen.drawRect
        drawTriangle = dottedEnable and drawDottedTriangle or screen.drawTriangle
        drawCircle = dottedEnable and drawDottedCircle or screen.drawCircle

        if shapeNo == 0 then        --四角
            drawRect(x - r, y - r, r*2, r*2)
        elseif shapeNo <= 2 then    --菱形
            drawLine(x - r, y, x, y + r)
            drawLine(x, y + r, x + r, y)
            drawLine(x + r, y, x, y - r)
            drawLine(x, y - r, x - r, y)
            if shapeNo == 2 then    --四角+菱形
                r = (r == 3) and (r + 1) or r
                drawRect(x - r, y - r, r*2, r*2)
            end
        elseif shapeNo == 3 then    --三角
            drawTriangle(pixX, pixY - r, pixX + r/2*3^0.5, pixY + r/2, pixX - r/2*3^0.5, pixY + r/2)
        elseif shapeNo == 4 then    --円
            drawCircle(pixX, pixY, r)
        elseif shapeNo == 5 then    --四角の端だけ
            drawLine(x - r, y - r, x - r/2, y - r)
            drawLine(x - r, y - r, x - r, y - r/2)
            drawLine(x - r, y + r, x - r/2, y + r)
            drawLine(x - r, y + r, x - r, y + r/2)
            drawLine(x + r, y - r, x + r/2, y - r)
            drawLine(x + r, y - r, x + r, y - r/2)
            drawLine(x + r, y + r, x + r/2, y + r)
            drawLine(x + r, y + r, x + r, y + r/2)
        elseif shapeNo == 6 then    --菱形の隅だけ
            drawLine(x - r, y, x - r*3/4, y + r/4)
            drawLine(x - r/4, y + r*3/4, x, y + r)
            drawLine(x, y + r, x + r/4, y + r*3/4)
            drawLine(x + r*3/4, y + r/4, x + r, y)
            drawLine(x + r, y, x + r*3/4, y - r/4)
            drawLine(x + r/4, y - r*3/4, x, y - r)
            drawLine(x, y - r, x - r/4, y - r*3/4)
            drawLine(x - r*3/4, y - r/4, x - r, y)
        end
    end
    drawShape(pixX, pixY, 4, addStaticNo == 2)  --点線は2番

    --静的追加機能
    if addStaticNo == 1 then        --太
        drawShape(pixX, pixY, 3, addStaticNo == 2)
    elseif addStaticNo == 3 then    --中央点
        screen.drawCircle(pixX, pixY, 1)
    elseif addStaticNo == 4 then    --十字
        screen.drawLine(pixX + 4, pixY, pixX - 4, pixY)
        screen.drawLine(pixX, pixY + 4, pixX, pixY - 4)
    elseif addStaticNo == 5 then    --クロス十字
        screen.drawLine(pixX - 4, pixY - 4, pixX + 4, pixY + 4)
        screen.drawLine(pixX + 4, pixY - 4, pixX - 4, pixY + 4)
    elseif addStaticNo == 6 then    --中央空き十字
        screen.drawLine(pixX + 4, pixY, pixX + 1, pixY)
        screen.drawLine(pixX - 4, pixY, pixX - 1, pixY)
        screen.drawLine(pixX, pixY + 4, pixX, pixY + 1)
        screen.drawLine(pixX, pixY - 4, pixX, pixY - 1)
    elseif addStaticNo == 7 then    --中央空きクロス十字
        screen.drawLine(pixX - 4, pixY - 4, pixX - 1, pixY - 1)
        screen.drawLine(pixX + 4, pixY + 4, pixX + 1, pixY + 1)
        screen.drawLine(pixX + 4, pixY - 4, pixX + 1, pixY - 1)
        screen.drawLine(pixX - 4, pixY + 4, pixX - 1, pixY + 1)
    end

    --動的追加機能
    if addDynamicNo == 1 then
        
    end
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

    show_radar_id = PRB("radar ID")
    show_radar_dist = PRB("radar distance")

    --時間経過
    for ID, tgt in pairs(data) do
        tgt.t = tgt.t + 1
    end

    --データ取り込み
    --data[ID]{x, y, z, t, shapeNo, colorNo, addStaticNo, addDynamicNo}
    for i = 0, 5 do
        local rawID = INN(i*4 + 4)
        ID = rawID%10000
        if ID ~= 0 then
            data[ID] = {
                x = INN(i*4 + 1),
                y = INN(i*4 + 2),
                z = INN(i*4 + 3),
                t = 0,
                shapeNo = math.floor(rawID/(10^4))%10,
                colorNo = math.floor(rawID/(10^5))%10,
                addStaticNo = math.floor(rawID/(10^6))%10,
                addDynamicNo = math.floor(rawID/(10^7))%10
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
    for ID, tgt in pairs(data) do
        x1, y1, drawable1 = WorldRect2Display(tgt.x, tgt.y, tgt.z, Ex, Ey, Ez)
        x1 = math.floor(x1)
        y1 = math.floor(y1)
        if drawable1 then
            drawSRD3(x1, y1, tgt.shapeNo, tgt.colorNo, tgt.addStaticNo, tgt.addDynamicNo)

            --ID
            if show_radar_id then
                TGTid = tostring(ID)
                screen.drawText(x1 + 1 - 2.5*#TGTid, y1 - 10, TGTid)
            end

            --距離数値
            if show_radar_dist then
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
end



