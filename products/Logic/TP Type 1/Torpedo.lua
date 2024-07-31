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
speedlist = {}
detonate = false
step1 = false
step2 = false
step3 = false

target_x, target_y, target_z, target_vx, target_vy, target_vz = 0, 0, 0, 0, 0, 0

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

function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
	
	local Wx = Wx - Px
	local Wy = Wy - Pz
	local Wz = Wz - Py
	
	local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y
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
	
	local Lower = ((a*f-b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
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

--t tick後の未来位置計算
function cal_future_position(x, y, z, vx, vy, vz, t)
    local future_x, future_y, future_z
    future_x = x + vx*t
    future_y = y + vy*t
    future_z = z + vz*t
    return future_x, future_y, future_z
end

--動翼の出力計算(-1 to 1)
function cal_surface(local_x, local_y, local_z, gain)
    local x, y
    x = clamp(gain*atan2(local_y, local_x), -2, 2)
    y = clamp(gain*atan2(local_y, local_z), -2, 2)
    return x, y
end

--速度の平均
function speed_average(v)
    table.insert(speedlist, v)
    if #speedlist > 60 then
        table.remove(speedlist, 1)
    end
    local sum_v = 0
    for i = 1, #speedlist do
        sum_v = sum_v + speedlist[i]        
    end
    return sum_v/#speedlist
end

--二点間の距離
function distance(x, y, z, a, b, c)
    return math.sqrt((x - a)^2 + (y - b)^2 + (z - c)^2)
end

--衝突位置予測
function cal_collision_location(target_x, target_y, target_z, target_vx, target_vy, target_vz, world_x, world_y, world_z, missile_v, distance, delay)
    target_x, target_y, target_z = cal_future_position(target_x, target_y, target_z, target_vx, target_vy, target_vz, delay)
    local target_v, theta, tick, tick_plus, tick_minus, future_x, future_y, future_z
    local vector_x, vector_y, vector_z = world_x - target_x, world_y - target_y, world_z - target_z 
    theta = math.acos((target_vx*vector_x + target_vy*vector_y + target_vz*vector_z)/math.sqrt((target_vx^2 + target_vy^2 + target_vz^2)*(vector_x^2 + vector_y^2 + vector_z)))
    target_v = math.sqrt(target_vx^2 + target_vy^2 + target_vz^2)
    if target_v == missile_v then
        if math.cos(theta) > 0 then
            tick = distance/(missile_v*math.cos(theta))
        else
            tick = 0
        end
    else
        if missile_v/target_v > math.abs(math.sin(theta)) then
            tick_plus = distance*(target_v*math.cos(theta) + math.sqrt(missile_v^2 - (target_v^2)*(math.sin(theta)^2)))/(target_v^2 - missile_v^2)
            tick_minus = distance*(target_v*math.cos(theta) - math.sqrt(missile_v^2 - (target_v^2)*(math.sin(theta)^2)))/(target_v^2 - missile_v^2)
            if tick_plus > 0 and tick_minus > 0 then
                if tick_plus > tick_minus then
                    tick = tick_minus
                else
                    tick = tick_plus
                end
            elseif tick_plus > 0 and tick_minus <= 0 then
                tick = tick_plus
            elseif tick_minus > 0 and tick_plus <= 0 then
                tick = tick_minus
            else
                tick = 0
            end
        elseif missile_v/target_v == math.abs(math.sin(theta)) then
            tick = distance*target_v*math.cos(theta)/(target_v^2 - missile_v^2)
        else
            tick = 0
        end
    end
    future_x, future_y, future_z = cal_future_position(target_x, target_y, target_z, target_vx, target_vy, target_vz, tick)
    return future_x, future_y, future_z
end

--指定高度巡航
--delay(m)離れた点に向かって飛ぶ
function cruise(target_x, target_y, world_x, world_y, delay)
    local x, y, a, x_plus, x_minus
    if target_x == world_x then
        x = target_x
        if target_y > world_y then
            y = world_y + delay
        else
            y = world_y - delay
        end
    elseif target_y == world_y then
        y = target_y
        if target_x > world_x then
            x = world_x + delay
        else
            x = world_x - delay
        end
    else
        a = (world_y - target_y)/(world_x - target_x)
        x_plus = (delay/math.sqrt(1 + a^2)) + world_x
        x_minus = -(delay/math.sqrt(1 + a^2)) + world_x
        if target_x > world_x then
            x = x_plus
        else
            x = x_minus
        end
        y = a*(x - world_x) + world_y
    end
    return x, y
end

function onTick()
    detected = INB(1)
    launch = INB(2)
    hardpoint_detected = INN(29)
    manual_mode = INB(3)

    if manual_mode then
        target_x = INN(30)
        target_y = INN(31)
        target_z = INN(32)
        target_vx = 0
        target_vy = 0
        target_vz = 0
    elseif detected then
        target_x = INN(1)
        target_y = INN(2)
        target_z = INN(3)
        target_vx = INN(4)
        target_vy = INN(5)
        target_vz = INN(6)
    elseif hardpoint_detected == 1 then
        target_x = INN(23)
        target_y = INN(24)
        target_z = INN(25)
        target_vx = INN(26)
        target_vy = INN(27)
        target_vz = INN(28)
    end

    physics_x = INN(7)
    physics_y = INN(8)
    physics_z = INN(9)
    euler_x = INN(10)
    euler_y = INN(11)
    euler_z = INN(12)
    abs_v = INN(13)/60
    mode = INN(14)
    gain = INN(15)
    sonar_x = INN(16)
    sonar_y = INN(17)

    active_sonar_lock_on = (INN(18) == 1)
    active_sonar = INB(4)

    world_x = physics_x
    world_y = physics_z
    world_z = physics_y

    if launch then
        missile_v = speed_average(abs_v)
        target_distance = distance(target_x, target_y, target_z, world_x, world_y, world_z)

        --destinationに目的地のワールド座標を入れる
        --最低高度まで上昇
        if step1 == false then
            destination_x, destination_y, destination_z = world_x, world_y, 1000
            if world_z >= 25 and world_z > launch_z + 25 then
                step1 = true
            end
        --巡航
        elseif step2 == false then
            cruise_target_x, cruise_target_y, cruise_target_z = cal_collision_location(target_x, target_y, target_z, target_vx, target_vy, target_vz, world_x, world_y, world_z, missile_v, target_distance, 2)
            --ダイレクトアタック
            if mode == 1 then
                step2 = true
            --ノーマル巡航
            elseif mode == 2 then
                destination_x, destination_y = cruise(cruise_target_x, cruise_target_y, world_x, world_y, 300)
                destination_z = 100 + cruise_target_z
                if target_distance < 500 then
                    step2 = true
                end
            --トップアタック
            elseif mode == 3 then
                destination_x, destination_y = cruise(cruise_target_x, cruise_target_y, world_x, world_y, 300)
                destination_z = 1000 + cruise_target_z
                if target_distance < (world_z - target_z)/math.cos(math.pi/9) then
                    step2 = true
                end
            --シースキミング
            elseif mode == 4 then
                destination_x, destination_y = cruise(cruise_target_x, cruise_target_y, world_x, world_y, 200)
                destination_z = 5
                if target_distance < 200 then
                    step2 = true
                end
            end
        --終末誘導
        elseif step3 == false then
            sonar_target_distance = distance(sonar_x, sonar_y, sonar_z, world_x, world_y, world_z)
            if active_sonar and target_distance < 500 and active_sonar_lock_on == 1 then
                destination_x, destination_y, destination_z = cal_collision_location(sonar_x, sonar_y, sonar_z, sonar_vx, sonar_vy, sonar_vz, world_x, world_y, world_z, missile_v, sonar_target_distance, 0)
            else
                destination_x, destination_y, destination_z = cal_collision_location(target_x, target_y, target_z, target_vx, target_vy, target_vz, world_x, world_y, world_z, missile_v, target_distance, 2)
            end

            destination_distance = distance(destination_x, destination_y, destination_z, world_x, world_y, world_z)
            if destination_distance < 15 then
                detonate = true
            end

        end

        tgtlocal_x, tgtlocal_y, tgtlocal_z = World2Local(destination_x, destination_y, destination_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
        surface_x, surface_y = cal_surface(tgtlocal_x, tgtlocal_y, tgtlocal_z, gain)
    else
        surface_x, surface_y = 0, 0
        launch_z = world_z
    end

    OUN(1, surface_x)
    OUN(2, surface_y)
    OUN(3, destination_x)
    OUN(4, destination_y)
    OUN(5, destination_z)
    OUN(6, missile_v)
    OUB(1, detonate)
    OUB(2, step1)
    OUB(3, step2)
    OUB(4, step3)
    OUB(5, active_sonar)
    OUB(7, active_sonar_lock_on == 1)
end