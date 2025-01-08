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

        simulator:setInputBool(3, simulator:getIsToggled(1))

        simulator:setInputNumber(7, simulator:getSlider(1)*10000)
        simulator:setInputNumber(8, simulator:getSlider(2)*10000)
        simulator:setInputNumber(9, simulator:getSlider(3)-0.5)
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

default_zoom = 0.5
tap_tick = 20

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

--ビークルマーカー描画
function vehicle_marker(map_x, map_y, zoom, secreen_width, screen_height, world_x, world_y, compass)
    local pixel_w, pixel_h, x1, x2, y1, y2
    pixel_w, pixel_h = map.mapToScreen(map_x, map_y, zoom, secreen_width, screen_height, world_x, world_y)
    x1 = pixel_w - 2*math.sin(compass)
    y1 = pixel_h - 2*math.cos(compass)
    x2 = pixel_w - 6*math.sin(compass)
    y2 = pixel_h - 6*math.cos(compass)
    screen.setColor(0, 255, 0)
    screen.drawCircle(pixel_w, pixel_h, 2)
    screen.drawLine(x1, y1, x2, y2)
end

function onTick()
    display_w = INN(1)
    display_h = INN(2)
    touch_w = INN(3)
    touch_h = INN(4)
    world_x = INN(7)
    world_y = INN(8)
    compass = INN(9)*math.pi*2
    zoom_max = INN(11)
    zoom_min = INN(12)
    zoom_speed = INN(13)/60
    key_x = INN(14)
    key_y = INN(15)

    touch_1 = INB(1)
    touch_2 = INB(2)
    power = INB(3)
    key_pulse = INB(4)

    my_location = false
    clear = false

    if power then
        --手動位置決め
        if key_pulse then
            target_x, target_y = key_x, key_y
            map_x, map_y = key_x, key_y
        end

        if touch_1 then
            --現在地ボタン
            if touch_w >= 1 and touch_w <= 8 and touch_h >= display_h - 7 then
                my_location = true
                touch_tick = 0
                map_x, map_y = world_x, world_y
            --クリアボタン
            elseif touch_w >= 10 and touch_w <= 17 and touch_h >= display_h - 7 then
                clear = true
                touch_tick = 0
                detected = false
                target_x, target_y = 0, 0
            --ズームアウト
            elseif touch_2 then
                zoom_manual = clamp(zoom_manual - zoom_speed, 0, 1)
                touch_tick = 0
                zoom_out = true
            --ズームイン
            elseif touch_tick > tap_tick then
                zoom_manual = clamp(zoom_manual + zoom_speed, 0, 1)
            --長押し時間計測
            else
                touch_tick = touch_tick + 1
            end
        else
            --マップ座標決定
            if touch_tick <= tap_tick and touch_tick > 0 and not zoom_out then
                target_x, target_y = map.screenToMap(map_x, map_y, zoom, display_w, display_h, touch_w, touch_h)
                map_x, map_y = target_x, target_y
                detected = true
            end
            touch_tick = 0
            zoom_out = false
        end

        target_distance = distance2(world_x, world_y, target_x, target_y)
        if target_distance < 10000 then
            target_distance_text = string.format("D:%.0fm", target_distance)
        elseif target_distance/1000 < 100 then
            target_distance_text = string.format("D:%.1fkm", target_distance/1000)
        else
            target_distance_text = string.format("D:%.0fkm", target_distance/1000)
        end
    else
        detected = false
        target_x, target_y = 0, 0
        map_x, map_y = world_x, world_y
        touch_tick = 0
        zoom_manual = default_zoom
    end

    zoom = cal_mapzooom(zoom_manual, zoom_min, zoom_max)
    zoom_text = string.format("%.1fkm", zoom)

    OUB(1, detected)
    OUN(1, target_x)
    OUN(2, target_y)
    OUN(3, INN(10))
    OUN(4, 0)
    OUN(5, 0)
    OUN(6, 0)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    if power then
        screen.drawMap(map_x, map_y, zoom)
        screen.setColor(0, 255, 0)
        screen.drawText(w - 5*#zoom_text, h - 6, zoom_text)

        if detected then
            --ターゲット座標変換
            target_map_w, target_map_h = map.mapToScreen(map_x, map_y, zoom, w, h, target_x, target_y)

            --距離
            screen.setColor(255, 127, 0)
            local vehicle_pixel_w, vehicle_pixel_h = map.mapToScreen(map_x, map_y, zoom, w, h, world_x, world_y)
            screen.drawLine(vehicle_pixel_w, vehicle_pixel_h, target_map_w, target_map_h)

            --ターゲットマーカー
            screen.setColor(255, 0, 0)
            screen.drawText(1, 1, target_distance_text)
            screen.drawLine(target_map_w - 2, target_map_h - 2, target_map_w + 3, target_map_h + 3)
            screen.drawLine(target_map_w - 2, target_map_h + 2, target_map_w + 3, target_map_h - 3)
        end

    
        --ビークルマーカー
        vehicle_marker(map_x, map_y, zoom, w, h, world_x, world_y, compass)
    
        --ボタン下地
        screen.setColor(32, 32, 32)
        screen.drawRectF(0, h - 7, 19, 7)
        screen.setColor(128, 128, 128)
        for i = 0, 1 do
            screen.drawRectF(1 + i*9 , h - 6, 8, 5)
            screen.drawRectF(2 + i*9 , h - 7, 6, 7)
        end
    
        --タッチ時の変化
        screen.setColor(0, 255, 0)
        if my_location then
            screen.drawRectF(1, h - 6, 8, 5)
            screen.drawRectF(2, h - 7, 6, 7)
        end
        if clear then
            screen.drawRectF(10, h - 6, 8, 5)
            screen.drawRectF(11, h - 7, 6, 7)
        end
    
        --ボタン文字
        list = {"M", "C"}
        screen.setColor(255, 255, 255)
        for i = 0, 1 do
            screen.drawText(3 + 9*i, h-6 ,list[i + 1])
        end
    end
end


