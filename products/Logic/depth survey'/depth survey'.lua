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

        simulator:setInputNumber(6, simulator:getSlider(1) *200)
        simulator:setInputNumber(7, simulator:getSlider(2) *200)
        simulator:setInputNumber(8, simulator:getSlider(3) *200)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!



-- Tick function that will be executed every logic tick
function onTick()
	front_distance = input.getNumber(6)
	mid_distance = input.getNumber(7)
	rear_distance = input.getNumber(8)
end

-- Draw function that will be executed when this script renders to a screen
function onDraw()
	w = screen.getWidth()
	h = screen.getHeight()
	screen.setColor(255, 255, 255)
	screen.drawRectF(0, 0, w, 20)
	screen.setColor(0, 0, 0)
	screen.drawText(w/2 - 10, 8, "SHIP")
	screen.setColor(0, 0, 0)
	screen.drawTriangleF(w*0.1, 10, w*0.15, 17, w*0.15, 3)
	screen.drawRectF(w*0.15, 7, w*0.15, 6)
	front_y = front_distance/250*(h*0.87) + 21
	mid_y = mid_distance/250*(h*0.87) + 21
	rear_y = rear_distance/250*(h*0.87) + 21
	floor()
	front()
	middle()
	rear()
end

function front()
	screen.setColor(255, 255, 255)
    front_x = math.floor(w*0.1)
	screen.drawLine(front_x, 21, front_x, front_y)
	screen.drawLine(front_x - 2, 21, front_x + 2, 21)
	screen.drawLine(front_x - 2, front_y, front_x + 2, front_y)
	screen.drawText(front_x + 2, front_y/2 + 11, math.floor(front_distance))
end

function middle()
    mid_x = math.floor(w/2)
	screen.setColor(255, 255, 255)
	screen.drawLine(mid_x, 21, mid_x, mid_y)
	screen.drawLine(mid_x - 2, 21, mid_x + 2, 21)
	screen.drawLine(mid_x - 2, mid_y, mid_x + 2, mid_y)
	screen.drawText(mid_x + 2,mid_y/2 + 11, math.floor(mid_distance))
end
	
function rear()
    rear_x = math.floor(w*0.9)
    rear_distance_digits = #tostring(math.floor(rear_distance))
	screen.setColor(255, 255, 255)
	screen.drawLine(rear_x, 21, rear_x, rear_y)
	screen.drawLine(rear_x - 2, 21, rear_x + 2, 21)
	screen.drawLine(rear_x - 2, rear_y, rear_x + 2, rear_y)
	screen.drawText(rear_x - rear_distance_digits*5,rear_y/2 + 11, math.floor(rear_distance))
end
	
function floor()
	screen.setColor(80, 80, 0)
	screen.drawTriangleF(w*0.1, h*2, w*0.1, front_y+4, w/2, mid_y+4)
	screen.drawTriangleF(w*0.1, h*2, w/2, mid_y+4, w*0.9, h*2)
	screen.drawTriangleF(w/2, mid_y+4, w*0.9+1, rear_y+4, w*0.9, h*2)
	screen.drawRectF(0,front_y+4, w*0.1, h)
	screen.drawRectF(w*0.9, rear_y+4,w*0.1, h*2)
end