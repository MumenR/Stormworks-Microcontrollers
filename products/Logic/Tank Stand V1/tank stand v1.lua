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

        -- NEW! button/slider options from the UI
        simulator:setInputNumber(1, simulator:getSlider(1)*1000000)        -- set input 31 to the value of slider 1
        simulator:setInputNumber(2, simulator:getSlider(2)*60)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

--３桁ごとにカンマ
function comma_value(number)
    local character = string.format("%.0f", number)
    character = character:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    return character
end

function onTick()
    tank = input.getNumber(1)
    pressure = input.getNumber(2)
    content = property.getText("Tank Content")
    --フォーマット
    tank = comma_value(tank).." L"
    pressure = string.format("%.2f ATM", pressure)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    screen.drawText(w/2 - #content*2.5, 2, content)
    screen.drawText(w/2 + 27 - #tank*5, h/2 - 3, tank)
    screen.drawText(w/2 + 37 - #pressure*5, h - 8, pressure)
end