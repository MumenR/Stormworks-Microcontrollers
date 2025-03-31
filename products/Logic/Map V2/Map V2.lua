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

default_zoom = 0.5
WP = {{0, 0}}
Wv_data = {}
AP = false
my_location_toggle = true
zoom_out_toggle = false

--x = 0 ~ 1
--min = 最小ズームの時のマップのズーム値
--max = 最大ズームの時のマップのズーム値
function cal_mapzooom(x, min, max)
    local a, C, y
    C = math.log(min)
    a = math.log(max/min)
    y = math.exp(a*x + C)
    return y
end

function clamp(x, min, max)
    if x >= max then
        return max
    elseif x <= min then
        return min
    else
        return x
    end
end

function distance2(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function same_rotation(x)
    return (x + 0.5)%1 - 0.5
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

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
    local RetX, RetY, RetZ
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
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

yaw_error_pre = 0
yaw_error_sum = 0

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

--ビークルマーカー描画
function vehicle_marker(map_x, map_y, zoom, w, h, Px, Pz, compass)
    local pixel_w, pixel_h, x1, x2, y1, y2
    pixel_w, pixel_h = map.mapToScreen(map_x, map_y, zoom, w, h, Px, Pz)
    x1 = pixel_w - 2*math.sin(compass)
    y1 = pixel_h - 2*math.cos(compass)
    x2 = pixel_w - 6*math.sin(compass)
    y2 = pixel_h - 6*math.cos(compass)
    screen.drawCircle(pixel_w, pixel_h, 2)
    screen.drawLine(x1, y1, x2, y2)
end

--縮尺フォーマット(x[m])
function format_distance(x)
    local x_txt
    if x < 10000 then
        x_txt = string.format("%.0fm", x)
    elseif x/1000 < 100 then
        x_txt = string.format("%.1fkm", x/1000)
    else
        x_txt = string.format("%.0fkm", x/1000)
    end
    return x_txt
end

--縮尺描画
function drawScale(zoom, w, h)
    local scale, size, i, scale_px, scale_txt
    zoom = zoom*1000
    --基準スケールサイズ
    size = zoom/5
    i = 0
    while size >= 10 do
        size = size/10
        i = i + 1
    end
    --キリの良いサイズに
    if size < 2 then
        scale = 1
    elseif size < 5 then
        scale = 2
    else
        scale = 5
    end
    scale = scale*10^i
    scale_px = math.floor(w*scale/zoom)
    --テキストフォーマット
    if scale < 1000 then
        scale_txt = string.format("%.0fm", scale)
    else
        scale_txt = string.format("%.0fkm", scale/1000)
    end
    screen.drawRectF(clamp(w*4.5/5 - 1, 0, w - 10) - scale_px/2 , h - 10, scale_px, 3)
    screen.drawText(clamp(w*4.5/5 - 1, 0, w - 10) - #scale_txt*2.5, h - 6, scale_txt)
end

function onTick()
    local w, h
    w = INN(1)
    h = INN(2)
    touch_x = INN(3)
    touch_y = INN(4)
    Px = INN(5)
    Py = INN(6)
    Pz = INN(7)
    Ex = INN(8)
    Ey = INN(9)
    Ez = INN(10)
    Pvx = INN(11)
    Pvy = INN(12)
    Pvz = INN(13)
    compass = INN(14)*math.pi*2
    key_x = INN(15)
    key_y = INN(16)

    zoom_max = PRN("max zoom (km)")
    zoom_min = PRN("min zoom (km)")
    zoom_speed = PRN("zoom speed")/60

    P = INN(17)
    I = INN(18)
    D = INN(19)

    tap_tick = PRN("Longest tap interval [tick]")
    WP_arrival = PRN("Waypoint switch arrival time [s]")

    touch_1 = INB(1)
    touch_2 = INB(2)
    power = INB(3)
    key_pulse = INB(4)
    AP_push = INB(5)

    my_location = false
    WP_clear = false
    WP_back = false

    --ワールド速度平均
    Wvx, Wvy, Wvz = Local2World(Pvx, Pvz, Pvy, 0, 0, 0, Ex, Ey, Ez)
    table.insert(Wv_data, {Wvx, Wvy, Wvz})
    while #Wv_data > 300 do
        table.remove(Wv_data, 1)
    end
    Wvx_sum, Wvy_sum, Wvz_sum = 0, 0, 0
    for i = 1, #Wv_data do
        Wvx_sum = Wvx_sum + Wv_data[i][1]
        Wvy_sum = Wvy_sum + Wv_data[i][2]
        Wvz_sum = Wvz_sum + Wv_data[i][3]
    end
    Wvx_ave = Wvx_sum/#Wv_data
    Wvy_ave = Wvy_sum/#Wv_data
    Wvz_ave = Wvz_sum/#Wv_data

    --1要素目は自分位置
    WP[1] = {Px, Pz}

    if power then
        --手動位置決め
        if key_pulse then
            table.insert(WP, {key_x, key_y})
            map_x, map_y = key_x, key_y
            my_location_toggle = false
        end

        if touch_1 then
            --現在地ボタン
            if touch_x >= 1 and touch_x <= 8 and touch_y >= h - 7 then
                my_location = true
                my_location_toggle = true
                touch_t1 = 0
            --クリアボタン
            elseif touch_x >= 10 and touch_x <= 17 and touch_y >= h - 7 then
                WP_clear = true
                touch_t1 = 0
                WP = {{Px, Pz}}
            --バックボタン
            elseif touch_x >= 19 and touch_x <= 26 and touch_y >= h - 7 then
                WP_back = true
                if not touch_1_pulse and #WP > 1 then
                    table.remove(WP, #WP)
                end
            --２タップ、ウェイポイント追加
            elseif touch_t2 <= tap_tick and touch_t2 > 0 and touch_t1 > 0 then
                if not touch_1_pulse then
                    map_x, map_y = map.screenToMap(map_x, map_y, zoom, w, h, touch_x, touch_y)
                    table.insert(WP, {map_x, map_y})
                end
                my_location_toggle = false
            --ズームアウト
            elseif touch_2 then
                zoom_manual = clamp(zoom_manual - zoom_speed, 0, 1)
                zoom_out_toggle = true
                touch_t1 = 0
            --ズームイン
            elseif touch_t1 > tap_tick then
                zoom_manual = clamp(zoom_manual + zoom_speed, 0, 1)
            --長押し時間計測
            else
                touch_t1 = touch_t1 + 1
                touch_t2 = 0
            end
        else
            --カウントリセット
            if (touch_1_pulse and (touch_t2 > 0 or touch_t1 > tap_tick)) or zoom_out_toggle then
                touch_t1, touch_t2 = 0, 0
            --タップからの経過時間計測
            elseif touch_t1 <= tap_tick and touch_t1 > 0 then
                touch_t2 = touch_t2 + 1
            end
            zoom_out_toggle = false

            --1タップ、中心座標更新
            if touch_t2 >= tap_tick then
                map_x, map_y = map.screenToMap(map_x, map_y, zoom, w, h, touch_x, touch_y)
                touch_t1, touch_t2 = 0, 0
                my_location_toggle = false
            end
        end
        touch_1_pulse = touch_1

    else
        map_x, map_y = Px, Pz
        touch_t1 = 0
        touch_t2 = 0
        zoom_manual = default_zoom
    end

    --到達時間より、ウェイポイントの削除
    WPx, WPy = 0, 0
    while #WP > 1 do
        --ウェイポイント出力用
        WPx = WP[2][1]
        WPy = WP[2][2]

        --接近速度
        --内積/|ウェイポイントベクトル|
        local WPx0, WPy0 = WPx - Px, WPy - Pz
        WP_speed = (WPx0*Wvx_ave + WPy0*Wvy_ave)/math.sqrt(WPx0^2 + WPy0^2)
        WP_dist = distance2(Px, Pz, WPx, WPy)
        WP_time = WP_dist/WP_speed

        --デバッグ
        OUN(30, WP_dist)
        OUN(31, WP_speed)
        OUN(32, WP_time)

        if WP_time < 0 or math.abs(WP_speed) < 0.01 then
            WP_time = 35999
        else
            WP_time = clamp(WP_time, 0, 35999)
        end

        if WP_time < WP_arrival then
            table.remove(WP, 2)
        else
            break
        end
    end
    WP_detected = #WP > 1

    --距離フォーマット
    WP_dist = distance2(Px, Pz, WPx, WPy)
    WP_dist_text = format_distance(WP_dist)
    --縮尺フォーマット
    zoom = cal_mapzooom(zoom_manual, zoom_min, zoom_max)

    --オートパイロットの切り替え
    if AP_push and not AP_pulse then
        AP = not AP
    end
    AP_pulse = AP_push
    --オートパイロット終了
    if not WP_detected then
        AP = false
    end

    --オートパイロット
    if AP then
        --必要回転角度
        local Lx, Ly, Lz, pitch, yaw, dist
        Lx, Ly, Lz = World2Local(WPx, WPy, 0, Px, 0, Pz, Ex, Ey, Ez)
        pitch, yaw, dist = Rect2Polar(Lx, Ly, Lz, false)
        
        --pid
        yaw_PID, yaw_error_sum, yaw_error_pre = PID(P, I, D, 0, -yaw, yaw_error_sum, yaw_error_pre, -1, 1)
    else
        WP_dist = 0
        WP_time = 0
        yaw_PID, yaw_error_sum, yaw_error_pre = 0, 0, 0
    end

    --マップ中心を自分に
    if my_location_toggle then
        map_x, map_y = Px, Pz
    end

    OUB(1, WP_detected)
    OUB(2, AP)

    OUN(1, WPx)
    OUN(2, WPy)
    OUN(3, Py)
    OUN(4, 0)
    OUN(5, 0)
    OUN(6, 0)
    OUN(7, WP_dist)
    OUN(8, WP_time)
    OUN(9, yaw_PID)
    OUN(10, map_x)
    OUN(11, map_y)
    OUN(12, zoom)
end

function onDraw()
    local w, h
    w = screen.getWidth()
    h = screen.getHeight()

    --ウェイポイントマーカー
    if WP_detected then
        for i = 2, #WP do
            --ウェイポイント座標変換
            WP_map_x1, WP_map_y1 = map.mapToScreen(map_x, map_y, zoom, w, h, WP[i][1], WP[i][2])
            WP_map_x2, WP_map_y2 = map.mapToScreen(map_x, map_y, zoom, w, h, WP[i - 1][1], WP[i - 1][2])

            --直線補完
            screen.setColor(0, 255, 0)
            screen.drawLine(WP_map_x1, WP_map_y1, WP_map_x2, WP_map_y2)

            --ウェイポイントマーカー
            screen.setColor(255, 0, 0)
            screen.drawCircleF(WP_map_x1, WP_map_y1, 1.5)
        end

        --距離
        screen.setColor(0, 255, 0)
        screen.drawText(1, 1, "WP:"..WP_dist_text)
    end

    --ビークルマーカー
    screen.setColor(0, 0, 255)
    vehicle_marker(map_x, map_y, zoom, w, h, Px, Pz, compass)

    --ボタン下地
    screen.setColor(32, 32, 32)
    screen.drawRectF(0, h - 7, 28, 7)
    screen.setColor(64, 64, 64)
    for i = 0, 2 do
        screen.drawRectF(1 + i*9 , h - 6, 8, 5)
        screen.drawRectF(2 + i*9 , h - 7, 6, 7)
    end

    --タッチ時の変化
    screen.setColor(0, 255, 0)
    if my_location then
        screen.drawRectF(1, h - 6, 8, 5)
        screen.drawRectF(2, h - 7, 6, 7)
    end
    if WP_clear then
        screen.drawRectF(10, h - 6, 8, 5)
        screen.drawRectF(11, h - 7, 6, 7)
    end
    if WP_back then
        screen.drawRectF(19, h - 6, 8, 5)
        screen.drawRectF(20, h - 7, 6, 7)
    end

    --ボタン文字
    list = {"M", "C", "B"}
    screen.setColor(255, 255, 255)
    for i = 0, 2 do
        screen.drawText(3 + 9*i, h-6 ,list[i + 1])
    end

    --縮尺
    screen.setColor(0, 255, 0)
    drawScale(zoom, w, h)
end