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

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

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

function atan2(x, y)
    local z
    if x >= 0 then
        z = math.atan(y/x)
    elseif y >= 0 then
        z = math.atan(y/x) + math.pi
    else
        z = math.atan(y/x) - math.pi
    end
    return z
end

--二点間の距離
function distance_xy(x, y, a, b)
    return math.sqrt((x - a)^2 + (y - b)^2)
end

-- テーブルの中から最小値のインデックスを返す関数
function find_Min_Index(t)
    local minValue = t[1]
    local minIndex = 1
    for i = 2, #t do
        if t[i] < minValue then
            minValue = t[i]
            minIndex = i
        end
    end
    return minIndex
end

Composite_Switch = false

sonar_data = {}
target_data = {}

physics_x = 0
physics_y = 0
physics_z = 0
euler_x = 0
euler_y = 0
euler_z = 0
w = 64
h = 64
touch_x = 0
touch_y = 0
zoom_input = 0
zoom_max = 100
zoom_min = 50000
indicator_lengh = 1000
zoom = 50
lock_on_azimuth = 0
lock_on_depth_angle = 0
zoom_text = "50.0km"
lock_on_i = 1
compass = 0

Power = false
touch = false
touch_pulse = false
lock_on = false

function onTick()
    sonar_signal = not INB(17)

    if sonar_signal then
        sonar_data = {}
        target_data = {}

        if Power then
            --情報読み込み
            for i = 1, 16 do
                if INB(i) then
                    table.insert(sonar_data, {INN(2*i-1)*math.pi*2, INN(2*i)*math.pi*2})
                end
            end

            --指定距離先に目標がいると仮定し、ワールド座標と方位・深度角を計算
            for i = 1, #sonar_data do
                local local_x, local_y, local_z, target_x, target_y, target_z, azimuth, depth_angle, dist_xy
                local_x = indicator_lengh*math.sin(sonar_data[i][1])*math.cos(sonar_data[i][2])
                local_y = indicator_lengh*math.cos(sonar_data[i][1])*math.cos(sonar_data[i][2])
                local_z = indicator_lengh*math.sin(sonar_data[i][2])
                target_x, target_y, target_z = Local2World(local_x, local_y, local_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
                azimuth = atan2(target_y - physics_z, target_x - physics_x)
                dist_xy = distance_xy(physics_x, physics_z, target_x, target_y)
                depth_angle = atan2(dist_xy, target_z - physics_y)
                table.insert(target_data, {target_x, target_y, target_z, azimuth, depth_angle})
            end

            --目標同定
            if lock_on then
                if #target_data > 0 then
                    local min_i
                    local azimuth = {}
                    for i = 1, #target_data do
                        table.insert(azimuth, distance_xy(target_data[i][4], target_data[i][5], lock_on_azimuth, lock_on_depth_angle))
                    end
                    min_i = find_Min_Index(azimuth)
    
                    --ロックオン継続判定
                    if azimuth[min_i] < 0.2 then
                        lock_on_azimuth = target_data[min_i][4]
                        lock_on_depth_angle = target_data[min_i][5]
                        lock_on_i = min_i
                    else
                        lock_on = false
                        lock_on_azimuth = 0
                        lock_on_depth_angle = 0
                    end
                else
                    lock_on = false
                    lock_on_azimuth = 0
                    lock_on_depth_angle = 0
                end
            end
        end

    else
        physics_x = INN(1)
        physics_y = INN(2)
        physics_z = INN(3)
        euler_x = INN(4)
        euler_y = INN(5)
        euler_z = INN(6)
        w = INN(7)
        h = INN(8)
        touch_x = INN(9)
        touch_y = INN(10)
        zoom_input = INN(11)
        zoom_max = INN(12)
        zoom_min = INN(13)
        indicator_lengh = INN(14)
        compass = INN(17)*2*math.pi

        Power = INB(1)
        touch = INB(2)

        zoom = cal_mapzooom(zoom_input, zoom_min, zoom_max)
        zoom_text = string.format("%.1fkm", zoom)
    end

    if Power then
        --タッチされた場合
        if touch and not touch_pulse then
            local touch_world_x, touch_world_y, touch_azimuth, min_i
            --タッチされた方位角を計算
            touch_world_x, touch_world_y = map.screenToMap(physics_x, physics_z, zoom, w, h, touch_x, touch_y)
            touch_azimuth = atan2(touch_world_y - physics_z, touch_world_x - physics_x)

            --方位差が最小のものを探す
            if #target_data > 0 then
                local azimuth = {}
                for i = 1, #target_data do
                    table.insert(azimuth, math.abs(target_data[i][4] - touch_azimuth))
                end
                min_i = find_Min_Index(azimuth)

                --ロックオン切り替え
                if azimuth[min_i] < 0.7 then
                    if lock_on and lock_on_azimuth == target_data[min_i][4] then
                        lock_on = false
                        lock_on_azimuth = 0
                        lock_on_depth_angle = 0
                    else
                        lock_on = true
                        lock_on_azimuth = target_data[min_i][4]
                        lock_on_depth_angle = target_data[min_i][5]
                        lock_on_i = min_i
                    end
                end
            end
        end
        touch_pulse = touch
    else
        lock_on = false
        touch = false
        lock_on_azimuth = 0
        lock_on_depth_angle = 0
    end

    OUN(1, lock_on_azimuth/(2*math.pi))

    OUB(1, Composite_Switch)
    Composite_Switch = not Composite_Switch
end

function onDraw()
    local w, h
    w = screen.getWidth()
    h = screen.getHeight()

    screen.drawMap(physics_x, physics_z, zoom)

    --ソナーシグナル表示
    screen.setColor(255, 255, 0)
    for i = 1, #target_data do
        local pixel_x, pixel_y = map.mapToScreen(physics_x, physics_z, zoom, w, h, target_data[i][1], target_data[i][2])
        if lock_on and i == lock_on_i then
            screen.setColor(255, 0, 0)
            screen.drawLine(w/2, h/2, pixel_x, pixel_y)
            screen.setColor(255, 255, 0)
        else
            screen.drawLine(w/2, h/2, pixel_x, pixel_y)
        end
    end

    --ビークル方向指示用
    x1 = w/2 - 2*math.sin(compass)
    y1 = h/2 - 2*math.cos(compass)
    x2 = w/2 - 6*math.sin(compass)
    y2 = h/2 - 6*math.cos(compass)
    screen.setColor(0, 0, 255)
    screen.drawCircle(w/2, h/2, 2)
    screen.drawLine(x1, y1, x2, y2)

    --縮尺
    screen.setColor(0, 255, 0)
    screen.drawText(w - 5*#zoom_text, h - 5, zoom_text)
end