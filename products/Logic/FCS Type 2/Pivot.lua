-- Author: MumenR
-- GitHub: <GithubLink>
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
log = math.log
tan = math.tan
atan = math.atan
exp = math.exp
pi = math.pi
zoomrad = 0
zoom_operation = 1

function rad(degrees)
    return pi*degrees/180
end

function deg(radians)
    return 180*radians/pi
end

function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
	
	Wx = Wx-Px
	Wy = Wy-Pz
	Wz = Wz-Py
	
	local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y
	a = math.cos(Ez)*math.cos(Ey)
	b = math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex)
	c = math.cos(Ez)*math.sin(Ey)*math.cos(Ex)+math.sin(Ez)*math.sin(Ex)
	d = Wx
	e = math.sin(Ez)*math.cos(Ey)
	f = math.sin(Ez)*math.sin(Ey)*math.sin(Ex)+math.cos(Ez)*math.cos(Ex)
	g = math.sin(Ez)*math.sin(Ey)*math.cos(Ex)-math.cos(Ez)*math.sin(Ex)
	h = Wz
	i = -math.sin(Ey)
	j = math.cos(Ey)*math.sin(Ex)
	k = math.cos(Ey)*math.cos(Ex)
	l = Wy
	
	local Lower = ((a*f-b*e)*k+(c*e-a*g)*j+(b*g-c*f)*i)
	x = 0
	y = 0
	z = 0
	
	if Lower ~= 0 then
		x = ((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j)/Lower
		y = -((a*g-c*e)*l+(d*e-a*h)*k+(c*h-d*g)*i)/Lower
		z = ((a*f-b*e)*l+(d*e-a*h)*j+(b*h-d*f)*i)/Lower
	end
	
	return x, z, y
end

cammaxrad = rad(135)/2  --FOV[rad] when input value is 0
camminrad = 0.025/2     --FOV[rad] when input value is 1

function calzoom(zoom, minfov, maxfov)
    local minrad, maxrad, a, C

    minrad = rad(minfov)/2
    maxrad = rad(maxfov)/2

    zoomrad = (camminrad - cammaxrad)*zoom + cammaxrad
    
    a = log(tan(minrad)/tan(maxrad))/(camminrad - cammaxrad)
    C = log(tan(minrad)) - camminrad*a
    zoomrad = atan(exp(a*zoomrad + C))

    zoom = (zoomrad - cammaxrad)/(camminrad - cammaxrad)

    return zoom
end

function calspeed(x, gain)
    speed = gain*x*tan(zoomrad)/5
    speed = string.format("%.5f", speed)
    return speed
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

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

function onTick()
    target_x = INN(1)
    target_y = INN(2)
    target_z = INN(3)
    target_vx = INN(4)
    target_vy = INN(5)
    target_vz = INN(6)
    
    pitch_input = INN(7) -- -1 to 1
    yaw_input = INN(8)   -- -1 to 1
    zoom = INN(9)  -- -1 to 1
    gain = INN(10)
    minfov = INN(11)-- degrees
    maxfov = INN(12)-- degrees
    pitch_position = INN(13)
    yaw_position = INN(14)

    physics_x = INN(15)
    physics_y = INN(16)
    physics_z = INN(17)
    euler_x = INN(18)
    euler_y = INN(19)
    euler_z = INN(20)

    power = (INN(21) == 1)
    autoaim = (INN(22) == 1)
    detected = INB(1)

    max_elevation = INN(23)
    max_depression = INN(24)
    pitch_rotation_speed = INN(25)

    ELI3_x = INN(26)
    ELI3_y = INN(27)
    ELI3_z = INN(28)
    ELI3_on = (INN(29) == 1)

    autoaimgain = INN(30)

    pitch_rotation = ((pitch_position - 0.5)%1) - 0.5
    yaw_rotation = ((yaw_position - 0.5)%1) - 0.5

    if power then
        --ズーム数値維持、ズーム出力計算
        if zoom == -1 and zoom_operation < 1 then
            zoom_operation = zoom_operation + 0.01*gain
        elseif zoom == 1 and zoom_operation > 0 then
            zoom_operation = zoom_operation - 0.01*gain
        end

        --指定した方向へ向く
        if ELI3_on or ELI3_condition then
            --指定ターゲットへ
            pitch_manual, yaw_manual = 0, 0
            target_local_x, target_local_y, target_local_z = World2Local(ELI3_x, ELI3_y, ELI3_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
            --ローカル座標から目標回転数へ
            target_pitch = 0.5*atan2(target_local_y, target_local_z)/pi
            target_yaw = 0.5*atan2(target_local_y, target_local_x)/pi
            if math.abs(target_pitch - pitch_rotation) < 0.003 and math.abs((target_yaw - yaw_rotation + 0.5)%1 - 0.5) < 0.003 then
                ELI3_condition = false
            elseif pitch_rotation >= max_elevation/360 or pitch_rotation <= -max_depression/360 then
                ELI3_condition = false
            else
                ELI3_condition = true
            end
        elseif autoaim and detected then
            --自動追尾
            pitch_manual, yaw_manual = 0, 0
            target_local_x, target_local_y, target_local_z = World2Local(target_x, target_y, target_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
            --ローカル座標から目標回転数へ
            target_pitch = 0.5*atan2(math.sqrt(target_local_x^2 + target_local_y^2), target_local_z)/pi
            target_yaw = 0.5*atan2(target_local_y, target_local_x)/pi
        else
            --手動
            pitch_manual = calspeed(pitch_input, gain)
            yaw_manual = calspeed(yaw_input, gain)
        end
        pitch_stabilizer = -pitch_rotation_speed/1.25
        
    else
        target_pitch, target_yaw, pitch_stabilizer = 0, 0, 0
        pitch_manual, yaw_manual, zoom_operation = 0, 0, 1
    end

    --目標回転数からスピードへ
    pitch_auto = clamp(autoaimgain*(target_pitch - pitch_rotation), -0.25, 0.25)
    yaw_auto = clamp(autoaimgain*(((target_yaw - yaw_rotation + 0.5)%1) - 0.5), -0.25, 0.25)

    if power and not ELI3_condition and not (autoaim and detected) then
        pitch_auto, yaw_auto = 0, 0
    end
    pitch = pitch_manual + pitch_auto + pitch_stabilizer
    yaw = yaw_manual + yaw_auto

    --ピッチ角制限
    if pitch_rotation >= max_elevation/360 then
        if pitch > 0 then
            pitch = 0
        end
        pitch = pitch - 0.01
    elseif pitch_rotation <= -max_depression/360 then
        if pitch < 0 then
            pitch = 0
        end
        pitch = pitch + 0.01
    end

    --ズーム計算
    zoom_computed = calzoom(zoom_operation, minfov, maxfov)

    OUN(1, pitch)
    OUN(2, yaw)
    OUN(3, zoom_computed)
    OUN(4, zoomrad)
end