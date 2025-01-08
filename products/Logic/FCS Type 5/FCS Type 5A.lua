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
        simulator:setInputBool(2, simulator:getIsToggled(1))

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
t = 0

nightvision = false
laser = false
stabilizer = false
tracker = false
touch_pulse = false

function rad(degrees)
    return math.pi*degrees/180
end

function deg(radians)
    return 180*radians/math.pi
end

rad_cam_max = rad(135)/2  --FOV[rad] when input value is 0
rad_cam_min = 0.025/2     --FOV[rad] when input value is 1

--fov[degree]
function calzoom(zoom_controll, minfov, maxfov)
    local rad_min, rad_max, a, C, rad_liner
    rad_min = rad(minfov)/2
    rad_max = rad(maxfov)/2

    --入力値をラジアンに線形変換
    rad_liner = (rad_cam_min - rad_cam_max)*zoom_controll + rad_cam_max
    
    --線形ラジアンを非線形に変換
    a = math.log(math.tan(rad_min)/math.tan(rad_max))/(rad_cam_min - rad_cam_max)
    C = math.log(math.tan(rad_min)) - rad_cam_min*a
    rad_not_liner = math.atan(math.exp(a*rad_liner + C))

    --非線形ラジアンを制御用値に変換
    zoom_output = (rad_not_liner - rad_cam_max)/(rad_cam_min - rad_cam_max)

    return zoom_output
end

function calspeed(x, gain)
    local speed = gain*x*rad_not_liner
    
    if speed >= 0 then
        speed = speed + 0.1
    else
        speed = speed - 0.1
    end
    return speed
end

function onTick()
    screen_w = INN(1)
    screen_h = INN(2)
    touch_x = INN(3)
    touch_y = INN(4)
    yaw_controll = INN(5)
    pitch_controll = INN(6)
    zoom_controll = INN(7)
    distance = INN(8)
    gain = INN(9)

    touch = INB(1)
    power = INB(2)
    upward = INB(3)
    foward = INB(4)

    distance = string.format("D:%dm", math.floor(distance))


    if power then
        if touch and not touch_pulse then
            --bottun
            if touch_y >= screen_h - 7 and touch_y <= screen_h then
                
                --toggle bottun
                if touch_pulse == false then
                    if touch_x >= screen_w/2 - 17 and touch_x <= screen_w/2 - 10 then
                        nightvision = not nightvision
                    end
                    if touch_x >= screen_w/2 - 8 and touch_x <= screen_w/2 - 1 then
                        laser = not laser
                    end
                    if touch_x >= screen_w/2 + 1 and touch_x <= screen_w/2 + 8 then
                        stabilizer = not stabilizer
                    end
                    if touch_x >= screen_w/2 + 10 and touch_x <= screen_w/2 + 17 then
                        tracker = not tracker
                    end
                end
            end
        end
    else
        nightvision = false
        stabilizer = false
        tracker = false
        laser = false
    end

    touch_pulse = touch
    
    zoom = calzoom(zoom_controll, deg(0.025), 135)

    pitch = calspeed(pitch_controll, gain)
    if upward then
        yaw = calspeed(yaw_controll, gain)
    else
        yaw = -calspeed(yaw_controll, gain)
    end

    --スポーン時に正面を向く
    if foward and t < 29 then
        if upward then
            pitch = pitch - 5
        else
            pitch = pitch + 5
        end
        t = t + 1
    end
    
    OUN(1, yaw)
    OUN(2, pitch)
    OUN(3, zoom)
    OUB(1, nightvision)
    OUB(2, stabilizer)
    OUB(3, tracker)
    OUB(4, laser)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --中心線
    screen.setColor(64, 64, 64, 128)
    local line_margin = math.floor(h/20)
    screen.drawLine(0, h/2, w/2 - line_margin, h/2)
    screen.drawLine(w/2 + line_margin + 1, h/2, w, h/2)
    screen.drawLine(w/2, 0, w/2, h/2 - line_margin)
    screen.drawLine(w/2, h/2 + line_margin + 1, w/2, h)

    --距離計
    if laser then
        screen.setColor(0, 200, 0)
        screen.drawText(w/2 - 2.5*#distance, 1, distance)
    end

    --ボタン下地
    screen.setColor(32, 32, 32)
    screen.drawRectF(w/2 - 18, h - 7, 37, 7)
    
    --ボタン四角
    screen.setColor(128, 128, 128)
    for i = 0, 3 do
        screen.drawRectF(w/2 - 17 + i*9 , h - 6, 8, 5)
        screen.drawRectF(w/2 - 16 + i*9 , h - 7, 6, 7)
    end

    --ボタンオンの場合
    screen.setColor(0, 200, 0)
    if nightvision then
        screen.drawRectF(w/2 - 17, h - 6, 8, 5)
        screen.drawRectF(w/2 - 16, h - 7, 6, 7)
    end
    if laser then
        screen.drawRectF(w/2 - 8, h - 6, 8, 5)
        screen.drawRectF(w/2 - 7, h - 7, 6, 7)
    end
    if stabilizer then
        screen.drawRectF(w/2 + 1, h - 6, 8, 5)
        screen.drawRectF(w/2 + 2, h - 7, 6, 7)
    end
    if tracker then
        screen.drawRectF(w/2 + 10 , h - 6, 8, 5)
        screen.drawRectF(w/2 + 11 , h - 7, 6, 7)
    end

    --ボタン文字
    list = {"N", "L", "S", "T"}
    screen.setColor(255, 255, 255)
    for i = 0, 3 do
        screen.drawText(w/2 - 15 + 9*i, h-6 ,list[i + 1])
    end
    
end