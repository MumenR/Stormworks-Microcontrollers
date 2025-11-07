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
    simulator:setScreen(1, "2x2")
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


--[[
    Array for converting Weapon model No. to weapon name
    weapon_no_to_name[No.] = "weapon name"

    example:
    weapon_no_to_name = {
        [1001] = "SM 1",
        [1002] = "SM 2",
        [1003] = "SM 3"
    }
]]


INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool
PRN = property.getNumber
PRB = property.getBool
PRT = property.getText

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
                qty = weapon qty,
                t = last output tick,
                name = weapon name
            }
        }
    ]]
    if last_vls_info ~= 0 then
        local last_wpn_no, last_wpn_qty, last_wpn_name
        last_wpn_no = math.floor(last_vls_info/1000)
        last_wpn_qty = last_vls_info%1000
        if weapon_data[last_wpn_no] == nil then
            if PRT(tostring(last_wpn_no)) ~= "" then
                last_wpn_name = PRT(tostring(last_wpn_no))
            else
                last_wpn_name = tostring(last_wpn_no)
            end
            weapon_data[last_wpn_no] = {
                no = last_wpn_no,
                qty = last_wpn_qty,
                t = 0,
                name = last_wpn_name
            }
        else
            weapon_data[last_wpn_no].no = last_wpn_no
            weapon_data[last_wpn_no].qty = last_wpn_qty
            weapon_data[last_wpn_no].t = 0
        end
    end

    --No.が小さい順に
    --[[
        weapon_data_sort = {
            [index] = {
                no = model No.,
                qty = weapon_data
            }
        }
    ]]
    
    -- 一時的に weapon_data の値を配列として集める
    weapon_data_sort = {}
    for _, data in pairs(weapon_data) do
        table.insert(weapon_data_sort, data)
    end

    -- no の昇順でソート
    table.sort(weapon_data_sort, function(a, b) return a.no < b.no end)

    --出力リセット
    for i = 1, 32 do
        OUN(i, 0)
    end

    for i = 1, #weapon_data_sort do
        OUN(i*2 - 1, weapon_data_sort[i].no)
        OUN(i*2 - 0, weapon_data_sort[i].qty)
    end
end

function onDraw()
    w, h = screen.getWidth(), screen.getHeight()

    --ライン
    screen.setColor(0, 0, 64)
    for i = 7, h, 8 do
        screen.drawLine(0, i, w, i)
    end
    screen.drawLine(3*w/5, 0, 3*w/5, h)

    --ラベル
    screen.setColor(255, 255, 255)
    screen.drawText(3*w/10 - 8, 1, "MSL")
    screen.drawText(4*w/5 - 5, 1, "QTY")

    --名前と数量
    for i = 1, #weapon_data_sort do
        local index, name, qty
        index = weapon_data_sort[i].no
        name = weapon_data_sort[i].name
        qty = tostring(math.floor(weapon_data_sort[i].qty))

        screen.drawText(2, i*8 + 1, name)
        screen.drawText(4*w/5 - #qty*2.5 + 2, i*8 + 1, qty)
    end
end
