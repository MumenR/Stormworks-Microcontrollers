-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
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
PRN = property.getNumber

time_out_tick = 100
weapon_data = {}

function onTick()
    last_vls_info = INN(32)

    --時間経過処理とタイムアウト削除
    for NO, MODEL in pairs(weapon_data) do
        MODEL.t = MODEL.t + 1
        if MODEL.t > time_out_tick then
            weapon_data[NO] = nil
        end
    end

    --取り込んだ情報を登録
    --[[
        weapon_data = {
            [model No.] = {
                no = weapon model No.,
                count = weapon count,
                t = last output tick
            }
        }
    ]]
    if last_vls_info ~= 0 then
        last_wpn_no = math.floor(last_vls_info/1000)
        last_wpn_count = last_vls_info%1000
        if weapon_data[last_wpn_no] == nil then
            weapon_data[last_wpn_no] = {
                no = last_wpn_no,
                count = last_wpn_count,
                t = 0
            }
        else
            weapon_data[last_wpn_no].no = last_wpn_no
            weapon_data[last_wpn_no].count = last_wpn_count
        end
    end

    --出力リセット
    for i = 1, 32 do
        OUN(i, 0)
    end
end
