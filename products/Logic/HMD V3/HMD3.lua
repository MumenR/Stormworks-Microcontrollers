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

        -- NEW! button/slider options from the UI
        simulator:setInputNumber(18, simulator:getSlider(1)*0.25)
        simulator:setInputNumber(19, simulator:getSlider(2)*0.25)

        simulator:setInputNumber(25, simulator:getSlider(3)*150000)
        simulator:setInputNumber(26, simulator:getSlider(4)*35999)
        simulator:setInputNumber(27, simulator:getSlider(5))
        simulator:setInputNumber(28, simulator:getSlider(10))

        simulator:setInputNumber(21, simulator:getSlider(6)*30000)
        simulator:setInputNumber(2, simulator:getSlider(7)*30000)
        simulator:setInputNumber(13, simulator:getSlider(8)*999)
        simulator:setInputNumber(20, simulator:getSlider(9)*999)
        
        simulator:setProperty("air speed", true)
        simulator:setProperty("ground speed", true)
        simulator:setProperty("main speed", true)
        simulator:setProperty("air altitude", true)
        simulator:setProperty("ground altitude", true)
        simulator:setProperty("magnetic heading", true)
        simulator:setProperty("attitude bars", true)
        simulator:setProperty("horizon line", true)
        simulator:setProperty("center marker", true)
        simulator:setProperty("laser direction", true)
        simulator:setProperty("waypoint marker", true)
        simulator:setProperty("waypoint marker label", true)
        simulator:setProperty("waypoint marker distance", true)
        simulator:setProperty("waypoint distance", true)
        simulator:setProperty("waypoint arrival time", true)

        simulator:setProperty("Speed Units", 1)
        simulator:setProperty("Altitude Units", 0.001)
        simulator:setProperty("Distance Units", 0.0005)
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

pi2 = math.pi*2
fov_w = (73/360)*pi2
fov_h = (58/360)*pi2

function green()
    screen.setColor(0, 255, 0)
end

function black()
    screen.setColor(0, 0, 0)
end

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

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
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

--極座標から直交座標へ変換(Z軸優先)
function Polar2Rect(pitch, yaw, distance, radian_bool)
    local x, y, z
    if not radian_bool then
        pitch = pitch*math.pi*2
        yaw = yaw*math.pi*2
    end
    x = distance*math.cos(pitch)*math.sin(yaw)
    y = distance*math.cos(pitch)*math.cos(yaw)
    z = distance*math.sin(pitch)
    return x, y, z
end

--極座標から直交座標へ変換(X軸優先)
function PolarX2Rect(pitch, yaw, distance, radian_bool)
    local x, y, z
    if not radian_bool then
        pitch = pitch*math.pi*2
        yaw = yaw*math.pi*2
    end
    x = distance*math.sin(yaw)
    y = distance*math.cos(yaw)*math.cos(pitch)
    z = distance*math.cos(yaw)*math.sin(pitch)
    return x, y, z
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
    Lx, Ly, Lz = World2Local(Wx, Wy, Wz, 0, 0, 0, Ex, Ey, Ez)
    Lx, Ly, Lz = World2Local(Lx, Ly, Lz, 0, 0, 0, -seat_y, seat_x, 0)

    --ディスプレイ座標へ変換
    Dx, Dy, drawable = Local2Display(Lx, Ly, Lz)
    
    return Dx, Dy, drawable
end

--ワールド極座標からディスプレイ座標へ（Exは基準極座標系の回転）
function Polar2Display(pitch, yaw, euler_x, euler_y, euler_z)
    local Wx, Wy, Wz, Dx, Dy, drawable
    Wx, Wy, Wz = Polar2Rect(pitch, yaw, 1, false)
    Wx, Wy, Wz = World2Local(Wx, Wy, Wz, 0, 0, 0, euler_x, euler_y, euler_z)
    Dx, Dy, drawable = WorldRect2Display(Wx, Wy, Wz, Ex, Ey, Ez)
    return Dx, Dy, drawable
end

--X軸優先ワールド極座標からディスプレイ座標へ（Exは基準極座標系の回転）
function PolarX2Display(pitch, yaw, euler_x, euler_y, euler_z)
    local Wx, Wy, Wz, Dx, Dy, drawable
    Wx, Wy, Wz = PolarX2Rect(pitch, yaw, 1, false)
    Wx, Wy, Wz = World2Local(Wx, Wy, Wz, 0, 0, 0, euler_x, euler_y, euler_z)
    Dx, Dy, drawable = WorldRect2Display(Wx, Wy, Wz, Ex, Ey, Ez)
    return Dx, Dy, drawable
end

--点線
function DottedLine(x1, y1, x2, y2)
    local a, b, step
    a = clamp((y1 - y2)/(x1 - x2), -1000, 1000)
    b = y1 - a*x1

    step = 2*math.cos(atan2(x2 - x1, y2 - y1))

    for x = x1, x2 - step, step*2 do
        if CanDraw(x, a*x + b) then
            screen.drawLine(x, a*x + b, x + step, a*(x + step) + b)
        end
    end
end

--描画可能判定
function CanDraw(x, y)
    return x >= 0 and x <= w and y >= 0 and y <= h
end

function max_digits(max_num, unit)
    return #tostring(math.floor(max_num*unit + 0.5))
end

function onTick()
    spd_unit = PRN("Speed Units")
    alt_unit = PRN("Altitude Units")
    dist_unit = PRN("Distance Units")

    spd_max_digits = max_digits(500, spd_unit)
    alt_max_digits = max_digits(30000, alt_unit)
    dist_max_digits = clamp(max_digits(150000, dist_unit), 3, 100)

    Px = INN(1)
    Py = INN(2)
    Pz = INN(3)
    Ex = INN(4)
    Ey = INN(5)
    Ez = INN(6)

    gnd_alt = INN(21)*alt_unit
    altitude = INN(2)*alt_unit
    
    gnd_speed = INN(13)*spd_unit
    air_speed = INN(20)*spd_unit

    compass = INN(17)*pi2
    
    seat_x = INN(18)*pi2
    seat_y = INN(19)*pi2

    WPx = INN(22)
    WPy = INN(23)
    WPz = INN(24)
    WP_dist = INN(25)*dist_unit
    WP_time = INN(26)
    WP_detected = INN(27) == 1
    AP = INN(28) == 1

    show_air_speed = PRB("air speed")
    show_gnd_speed = PRB("ground speed")
    gnd_main = PRB("main speed")
    show_air_alt = PRB("air altitude")
    show_gnd_alt = PRB("ground altitude")
    show_azimuth = PRB("magnetic heading")
    show_attitude = PRB("attitude bars")
    show_horizon = PRB("horizon line")
    show_center = PRB("center marker")
    laser_direction = PRB("laser direction")
    show_WPmk = PRB("waypoint marker")
    show_WPmk_label = PRB("waypoint marker label")
    show_WPmk_dist = PRB("waypoint marker distance")
    show_WP_dist = PRB("waypoint distance")
    show_WP_time = PRB("waypoint arrival time")

    --レーザー方向補正
    if laser_direction then
        Lx, Ly, Lz = World2Local(0, 0, -1, 0, 0, 0, Ex, Ey, Ez)
        Lx, Ly, Lz = World2Local(Lx, Ly, Lz, 0, 0, 0, pi2/4, 0, 0)
        Lpi, Lya, Ldi = Rect2Polar(Lx, Ly, Lz, false)
        OUN(1, Lya*8)
        OUN(2, Lpi*8)
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    green()

    --中心線
    if show_center then
        Lx, Ly, Lz = World2Local(0, 1, 0, 0, 0, 0, -seat_y, seat_x, 0)
        x1, y1, drawable1 = Local2Display(Lx, Ly, Lz)
        if drawable1 then
            screen.drawCircle(x1, y1, 3)
            screen.drawLine(x1 + 3, y1, x1 + 10, y1)
            screen.drawLine(x1 - 3, y1, x1 - 10, y1)
            screen.drawLine(x1, y1 - 3, x1, y1 - 8)
        end
    end

    --水平線
    if show_horizon then
        local start_deg = 5
        if not show_center then
            start_deg = 0
        end
        
        for i = start_deg, 180, 45 do
            --左右
            for j = -1, 1, 2 do
                x1, y1, drawable1 = Polar2Display(0, j*i/360, 0, compass, 0)
                x2, y2, drawable2 = Polar2Display(0, j*(i + 45)/360, 0, compass, 0)
        
                if drawable1 and drawable2 then
                    screen.drawLine(x1, y1, x2, y2)
                end
            end
        end
    
    end

    --角度線
    if show_attitude then
        for i = 5, 175, 5 do
            --左右
            for j = -1, 1, 2 do
                --上下
                for k = -1, 1, 2 do
                    --線
                    x1, y1, drawable1 = PolarX2Display(k*i/360, j*12/360, 0, compass, 0)
                    x2, y2, drawable2 = PolarX2Display(k*i/360, j*5/360, 0, compass, 0)
                    x3, y3, drawable3 = PolarX2Display(k*(i - 1)/360, j*12/360, 0, compass, 0)
                    --角度
                    x4, y4, drawable4 = PolarX2Display(k*i/360, j*16/360, 0, compass, 0)
            
                    if drawable1 and drawable2 and drawable3 and drawable4 then
                        if CanDraw(x1, y1) or CanDraw(x2, y2) then
                            if k == 1 then
                                screen.drawLine(x1, y1, x2, y2)
                            else
                                DottedLine(x2, y2, x1, y1)
                            end
                        end
                        if CanDraw(x1, y1) or CanDraw(x3, y3) then
                            screen.drawLine(x1, y1, x3, y3)
                        end
                        if CanDraw(x4, y4) then
                            screen.drawText(x4 - 2.5*#tostring(k*i), y4 - 3, k*i)
                        end
                    end
                end
            end
        end
    end

    --方位角
    if show_azimuth then
        Wx, Wy, Wz = Local2World(0, 1, 0, 0, 0, 0, -seat_y, seat_x, 0)
        Wx, Wy, Wz = Local2World(Wx, Wy, Wz, 0, 0, 0, Ex, Ey, Ez)
        Az = atan2(Wy, Wx)/pi2
        Wx, Wy, Wz = Local2World(0, 0, 1, 0, 0, 0, -seat_y, seat_x, 0)
        Wx, Wy, Wz = Local2World(Wx, Wy, Wz, 0, 0, 0, Ex, Ey, Ez)
        if Wz > 0 then
            j = 1
        else
            j = -1
        end
        for i = 0, j*355, j*5 do
            Lx, Ly, Lz = Polar2Rect(19.5/360, i/360 - j*Az, 1, false)
            x1, y1, drawable1 = Local2Display(Lx, Ly, Lz)
            
            if drawable1 then
                screen.drawLine(x1, y1 + 2, x1, y1 - 2)
                if i%10 == 0 then
                    screen.drawText(x1 - 4, y1 - 7, string.format("%02d", j*i/10))
                end
            end
        end

        --方位角数値
        x1 = math.floor(w/2)
        Az = string.format("%03.0f", 360*((-compass/pi2)%1))
        black()
        screen.drawRectF(x1 - 10, 9, 20, 11)
        green()
        screen.drawRect(x1 - 9, 10, 17, 8)
        screen.drawTextBox(x1 - 8, 11, 16, 7, Az, 0, 0)
    end

    --ウェイポイント
    if WP_detected then
        --ローカル座標へ変換
        Lx, Ly, Lz = World2Local(WPx, WPy, WPz, Px, Py, Pz, Ex, Ey, Ez)
        Lx, Ly, Lz = World2Local(Lx, Ly, Lz, 0, 0, 0, -seat_y, seat_x, 0)

        --距離数値
        if WP_dist >= 10 then
            WPd = string.format("%.0f", math.floor(WP_dist + 0.5))
        else
            WPd = string.format("%.1f", math.floor(WP_dist*10 + 0.5)/10)
        end

        --ウェイポイントマーカー
        if show_WPmk then
            --ディスプレイ座標へ変換
            x1, y1, drawable1 = Local2Display(Lx, Ly, Lz)
            x1 = math.floor(x1)
            y1 = math.floor(y1)
            if drawable1 then
                green()
                screen.drawCircle(x1, y1, 5)
                if show_WPmk_label then
                    screen.drawText(x1 - 4, y1 - 11, "WP")
                end
                if show_WPmk_dist then
                    screen.drawText(x1 + 1 - 2.5*#WPd, y1 + 7, WPd)
                end
            end
        end

        --距離描画
        if show_WP_dist then
            x1, y1 = math.floor(w/5), math.floor(3*h/5)
            black()
            screen.drawRectF(x1 - 5 - 5*dist_max_digits, y1, 13 + 5*dist_max_digits, 7)
            green()
            screen.drawText(x1 - 4 - 5*dist_max_digits, y1 + 1, "WP")
            screen.drawText(x1 + 8 - 5*#WPd, y1 + 1, WPd)
        end

        --到達時間
        if show_WP_time then
            x1, y1 = math.floor(w/5), math.floor(3*h/5)
            WP_hou = string.format("%d", math.floor(WP_time/3600))
            WP_sec = string.format("%02.0f", math.floor(WP_time%60 + 0.5))
            if WP_time < 3600 then
                WP_min = string.format("%d", math.floor((WP_time/60)%60))
                WPt = WP_min..":"..WP_sec
            elseif WP_time >= 36000 then
                WPt = "-:--:--"
            else
                WP_min = string.format("%02.0f", math.floor((WP_time/60)%60))
                WPt = WP_hou..":"..WP_min..":"..WP_sec
            end
            black()
            screen.drawRectF(x1 + 7 - 5*#WPt, y1 + 7, 5*#WPt + 1, 7)
            green()
            screen.drawText(x1 + 8 - 5*#WPt, y1 + 8, WPt)
        end
    end

    --オートパイロット表示
    if AP then
        x1, y1 = math.floor(w/5), math.floor(3*h/5)
        black()
        screen.drawRectF(x1 - 5 - 5*dist_max_digits, y1 - 7, 11, 7)
        green()
        screen.drawText(x1 - 4 - 5*dist_max_digits, y1 - 6, "AP")
    end

    --速度数値
    if gnd_main then
        main_speed = gnd_speed
        sub_speed = air_speed
        sub_tag = "AS"
    else
        main_speed = air_speed
        sub_speed = gnd_speed
        sub_tag = "GS"
    end

    --メイン速度
    if (gnd_main and show_gnd_speed) or (not gnd_main and show_air_speed) then
        x1, y1 = math.floor(w/5), math.floor(h/3)
        spd = string.format("%d", math.floor(main_speed + 0.5))
        black()
        screen.drawRectF(x1 + 5 - 5*spd_max_digits, y1, 5*spd_max_digits + 5, 11)
        green()
        screen.drawRect(x1 + 6 - 5*spd_max_digits, y1 + 1, 5*spd_max_digits + 2, 8)
        screen.drawText(x1 + 8 - 5*#spd, y1 + 3, spd)
    end

    --サブ速度
    if (gnd_main and show_air_speed) or (not gnd_main and show_gnd_speed) then
        --大気速度数値
        spd = string.format("%d", math.floor(sub_speed + 0.5))
        black()
        screen.drawRectF(x1 - 5 - 5*spd_max_digits, y1 + 10, 5*spd_max_digits + 13, 7)
        green()
        screen.drawText(x1 - 4 - 5*spd_max_digits, y1 + 11, sub_tag)
        screen.drawText(x1 + 8 - 5*#spd, y1 + 11, spd)
    end

    --高度数値
    if show_air_alt then
        x1, y1 = math.floor(4*w/5), math.floor(h/3)
        alt = string.format("%d", math.floor(altitude + 0.5))
        offset = 2*alt_max_digits
        black()
        screen.drawRectF(x1 - offset, y1, 5 + 5*alt_max_digits, 11)
        green()
        screen.drawRect(x1 + 1 - offset, y1 + 1, 2 + 5*alt_max_digits, 8)
        screen.drawText(x1 + 3 + 1.5*offset - 5*#alt, y1 + 3, alt)
    end

    --対地高度数値
    if show_gnd_alt then
        x1, y1 = math.floor(4*w/5), math.floor(2*h/3)
        alt = string.format("%d", math.floor(gnd_alt + 0.5))
        offset = 2*alt_max_digits
        black()
        screen.drawRectF(x1 - 5 - offset, y1, 15 + 5*alt_max_digits, 11)
        green()
        screen.drawText(x1 - 4 - offset, y1 + 3, "AG")
        screen.drawRect(x1 + 6 - offset, y1 + 1, 2 + 5*alt_max_digits, 8)
        screen.drawText(x1 + 8 + 1.5*offset - 5*#alt, y1 + 3, alt)
    end
end



