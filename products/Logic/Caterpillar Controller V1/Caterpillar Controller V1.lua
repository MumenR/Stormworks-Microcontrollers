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

        simulator:setInputBool(32, simulator:getIsToggled(1))
        simulator:setInputBool(31, simulator:getIsToggled(2))
        simulator:setInputNumber(3, simulator:getSlider(1)*120)
        simulator:setInputNumber(4, simulator:getSlider(2)*100)

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

function onTick()
    reverse_gear = INB(32)
    parking_brake = INB(31)

    temp = INN(3)
    battery = INN(4)

end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --前後
    screen.setColor(0, 255, 0)
    if reverse_gear then
        screen.drawText(1, 1, "rear")
    else
        screen.drawText(1, 1, "front")
    end

    --警告灯
    screen.setColor(255, 0, 0)
    if temp > 100 then
        local x, y = w - 13, h - 6
        screen.drawLine(x, y, x + 1, y + 6)
        screen.drawLine(x, y, x + 2, y + 1)
        screen.drawLine(x, y + 2, x + 2, y + 3)
        screen.drawLine(x - 1, y + 4, x + 2, y + 5)
    end
    if battery < 50 then
        local x, y = w - 8, h - 5
        screen.drawRect(x, y, 5, 3)
        screen.drawLine(x + 1, y - 1, x + 1, y)
        screen.drawLine(x + 4, y - 1, x + 4, y)
    end

    --パーキングブレーキ
    if parking_brake then
        screen.drawText(1, h - 6, "P")
    end

end



