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

pi = math.pi
sin = math.sin
cos = math.cos
data = {}

function onTick()
	angle = input.getNumber(4)*pi*2
	t_del = input.getNumber(8)
	range = input.getNumber(12)
	
	--input data{distance, x_rad, y_yad, frame}
	for i = 1, 8 do
		if input.getBool(i) then
			data_i = {input.getNumber(4*i - 3), input.getNumber(4*i -2)*pi*2, input.getNumber(4*i - 1)*pi*2, 0}
			table.insert(data, data_i)
		end
	end
	
	--delete data
	for i =# data, 1, -1 do
		data[i][4] = data[i][4] + 1
    	if data[i][4] >= t_del then
			table.remove(data, i)
		end
	end
end

function onDraw()
	--(0,0)--->x
	--|
	--y
	w = screen.getWidth()
	h = screen.getHeight()
	r = h/2 - 3
	px = r/range
	x_line = r*sin(angle) + w/2
	y_line = -r*cos(angle) + h/2
	screen.setColor(0, 255, 0)
	screen.drawLine(w/2, h/2, x_line, y_line)
	screen.drawCircle(w/2, h/2, r)
	
	for i = 1, #data do
		if data[i][1]*sin(data[i][3]) <= range then
			x = w/2 + px*(data[i][1]*cos(data[i][3]))*sin(data[i][2])
			y = h/2 - px*(data[i][1]*cos(data[i][3]))*cos(data[i][2])
			color = 255*(t_del - data[i][4])/t_del
			screen.setColor(color, color, color)
			screen.drawCircleF(x, y, 1)
		end
	end
end