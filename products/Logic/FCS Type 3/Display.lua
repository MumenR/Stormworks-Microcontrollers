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
OUB = output.setBool

function World2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
	local Wx = Wx - Px
	local Wy = Wy - Pz
	local Wz = Wz - Py
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
	local Lower = ((a*f - b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
	x = 0
	y = 0
	z = 0
	if Lower ~= 0 then
		x = ((b*g - c*f)*l + (d*f - b*h)*k + (c*h - d*g)*j)/Lower
		y = -((a*g - c*e)*l + (d*e - a*h)*k + (c*h - d*g)*i)/Lower
		z = ((a*f - b*e)*l + (d*e - a*h)*j + (b*h - d*f)*i)/Lower
	end
	return x,z,y
end

function drawtarget(x, y, z)
    if y > 0 then
        circle_x = h*math.atan(x, y)/(2*cam_fov)
        circle_y = h*math.atan(z, y)/(2*cam_fov)
        screen.drawCircle(w/2 + circle_x, h/2 - circle_y, 4)
    end
end

function distance(x, y, z, a, b, c)
    return math.sqrt((x - a)^2 + (y - b)^2 + (z - c)^2)
end

function onTick()
    target_x = INN(1)
    target_y = INN(2)
    target_z = INN(3)
    target_vx = INN(4)*60
    target_vy = INN(5)*60
    target_vz = INN(6)*60
    physics_x = INN(7)
    physics_y = INN(8)
    physics_z = INN(9)
    euler_x = INN(10)
    euler_y = INN(11)
    euler_z = INN(12)
    radar_fov = INN(13)
    cam_fov = INN(14)
    laser_mode = (INN(15) == 1)

    detected = INB(1)
    lock_on = INB(2)

    speed = math.sqrt(target_vx^2 + target_vy^2 + target_vz^2)
    dist = distance(target_x, target_y, target_z, physics_x, physics_z, physics_y)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --中心線
    screen.setColor(128, 128, 128, 128)
    screen.drawLine(0, h/2, w/2 - h/20, h/2)
    screen.drawLine(w, h/2, w/2 + h/20, h/2)
    screen.drawLine(w/2, h, w/2, h/2 + h/20)

    --radar fov用矩形
    screen.setColor(0, 255, 0)
    rect_h = h*math.tan(radar_fov*math.pi)/math.tan(cam_fov)
    screen.drawRect(w/2 - rect_h/2, h/2 - rect_h/2, rect_h, rect_h)

    --ロックオン用表示
    screen.setColor(255, 0, 0)
    if detected then
        if lock_on or laser_mode then
            screen.drawText(1, 9, string.format("D=%dm", math.floor(dist)))
            screen.drawText(1, 15, string.format("V=%dm/s", math.floor(speed)))
            screen.drawText(1, 3, "LOCK ON")
        else
            screen.drawText(1, 3, "DETECTED")
        end
        if not laser_mode then
            screen.setColor(255, 0, 0)
            marker_local_x, marker_local_y, marker_local_z = World2Local(target_x, target_y, target_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
            drawtarget(marker_local_x, marker_local_y, marker_local_z)
        end
    end
end