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
launch_pusle = false
launch_x, launch_y, launch_z, launch_distance_xy = 0, 0, 0, 0
step1 = false
step2 = false
step3 = false
detonate = false
target_z_offset = 5000

destination_x, destination_y, destination_z = 0, 0, 0

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

function distance(x, y, z, a, b, c)
    return math.sqrt((x - a)^2 + (y - b)^2 + (z - c)^2)
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

--原点と(x0(>0), y0)を通り、極大値max_yの放物線
--y = ax^2 + bx
function parabola(x, x0, y0, max_y)
    local y, a, b, a_plus, a_minus, b_plus, b_minus
    if y0 > max_y or x0 <= 0 then
        y = 0
    else
        b_plus = 2*(max_y + math.sqrt(max_y*(max_y - y0)))/x0
        b_minus = 2*(max_y - math.sqrt(max_y*(max_y - y0)))/x0
        a_plus = y0/(x0^2) - b_plus/x0
        a_minus = y0/(x0^2) - b_minus/x0

        if -b_plus/(2*a_plus) >= 0 and -b_plus/(2*a_plus) <= x0 then
            a, b = a_plus, b_plus
        elseif -b_minus/(2*a_minus) >= 0 and -b_minus/(2*a_minus) <= x0 then
            a, b = a_minus, b_minus
        else
            a, b = 0, 0
        end

        y = a*x^2 + b*x
    end

    return y
end

function cal_surface(local_x, local_y, local_z, gain)
    local x, y
    x = clamp(gain*atan2(local_y, local_x)/math.pi, -1, 1)
    y = clamp(gain*atan2(local_y, local_z)/math.pi, -1, 1)
    return x, y
end

function onTick()
    astronomy_x = INN(1)
    astronomy_y = INN(2)
    astronomy_z = INN(3)
    euler_x = INN(4)
    euler_y = INN(5)
    euler_z = INN(6)

    --放物線の頂点
    max_altitude = INN(15)
    --打ち上げ時に垂直上昇すべき高度
    min_altitude = INN(16)
    gain = INN(17)

    distace_sensor = INN(18)

    launch = INB(1)

    if launch then

        distance_xy = distance(target_x, target_y, 0, astronomy_x, astronomy_z, 0)

        if not launch_pusle then
            launch_min_altitude = clamp(astronomy_y + min_altitude, min_altitude, max_altitude)
        end

        --destinationに目標ワールド座標を入力
        --指定高度まで上昇
        if not step1 then
            destination_x, destination_y, destination_z = astronomy_x, astronomy_z, astronomy_y + 200
            if astronomy_y >= launch_min_altitude then
                step1 = true
                launch_distance_xy = distance_xy
            end
        --放物線軌道
        elseif not step2 then
            destination_x, destination_y = cruise(target_x, target_y, astronomy_x, astronomy_z, 300)
            destination_z = parabola(distance_xy - 300, launch_distance_xy, launch_min_altitude - target_z, max_altitude - target_z) + target_z
            if distance_xy <= 300 then
                step2 = true
            end
        --直上へ移動
        elseif not step3 then
            destination_x, destination_y, destination_z = target_x, target_y, target_z

            distance_xyz_offset = distance(target_x, target_y, target_z, astronomy_x, astronomy_z, astronomy_y)

            if distance_xyz_offset <= 300 then
                step3 = true
            end
        --終末誘導
        else
            destination_x, destination_y, destination_z = target_x, target_y, target_z - target_z_offset

            distance_xyz = distance(target_x, target_y, target_z - target_z_offset, astronomy_x, astronomy_z, astronomy_y)
            roll = 1

            if distance_xyz <= 250 or distace_sensor <= 250 then
                detonate = true
            end
        end

        tgtlocal_x, tgtlocal_y, tgtlocal_z = World2Local(destination_x, destination_y, destination_z, astronomy_x, astronomy_y, astronomy_z, euler_x, euler_y, euler_z)
        yaw, pitch = cal_surface(tgtlocal_x, tgtlocal_y, tgtlocal_z, gain)
        throttle = 1
    else
        target_x = INN(12)
        target_y = INN(13)
        target_z = INN(14) + target_z_offset
        roll, pitch, yaw, throttle = 0, 0, 0, 0
    end
    launch_pusle = launch

    OUN(1, roll)
    OUN(2, pitch)
    OUN(3, yaw)
    OUN(4, throttle)

    OUB(1, detonate)

    OUB(31, step1)
    OUB(32, step2)
    OUN(30, destination_x)
    OUN(31, destination_y)
    OUN(32, destination_z)
end