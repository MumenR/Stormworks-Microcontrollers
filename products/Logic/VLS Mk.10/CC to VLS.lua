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
PRN = property.getNumber
PRB = property.getBool
PRT = property.getText

target_data = {}
weapon_data = {}
time_out_tick = 100
time_out_tick_ELI = 10

function onTick()
    is_ELI = INB(1)
    is_fire = INN(31) == 1

    WPN_No = INN(29)
    mode = INN(30)
    
    last_vls_info = INN(32)

    --時間経過とタイムアウト削除 target_data
    for ID, data in pairs(target_data) do
        data.t = data.t + 1
        data.t_out = data.t_out + 1
        if (data.t > time_out_tick and ID ~= -1) or (data.t > time_out_tick_ELI and ID == -1) then
            target_data[ID] = nil
        end
    end

    --武器データ取り込み weapon_data
    --[[
        weapon_data = {
            [model No.] = {
                no = weapon model No.,
                qty = weapon qty,
                is_wpnbusy = first output cool time
            }
        }
    ]]
    if last_vls_info ~= 0 then
        local last_wpn_no, last_wpn_qty
        last_wpn_no = math.floor(last_vls_info/1000)
        last_wpn_qty = last_vls_info%1000
        if weapon_data[last_wpn_no] == nil then
            --初回登録
            weapon_data[last_wpn_no] = {
                no = last_wpn_no,
                qty = last_wpn_qty,
                is_wpnbusy = false
            }
        else
            --連続出力防止用のis_wpnbusyをリセット
            if weapon_data[last_wpn_no].qty ~= last_wpn_qty then
                weapon_data[last_wpn_no].is_wpnbusy = false
            end
        end
        --更新
        weapon_data[last_wpn_no].qty = last_wpn_qty
    end

    --目標データ取り込み target_data
    --[[
        target_data = {
            [ID] = {
                x = target world x, 
                y = target world y, 
                z = target world z,
                vx = target world vx,
                vy = target world vy,
                vz = traget world vz,
                ID = target ID,
                t = timeout tick,
                t_out = output tick,
                no = weapon model No.,
                mode = weapon mode,
                is_output = is output bool
            }
        }
    ]]
    if is_ELI then
        --初回登録
        if target_data[-1] == nil then
            target_data[-1] = {
                ID = -1,
                t_out = math.huge,
                is_output = false,
                mode = mode,
                no = WPN_No
            }
        end
        target_data[-1].x = INN(1)
        target_data[-1].y = INN(2)
        target_data[-1].z = INN(3)
        target_data[-1].vx = INN(4)
        target_data[-1].vy = INN(5)
        target_data[-1].vz = INN(6)
        target_data[-1].t = 0
        --is_MTX
    else
        for i = 1, 4 do
            local ID = INN(i*7)
            if ID ~= 0 then
                --初回登録
                if target_data[ID] == nil then
                    target_data[ID] = {
                        ID = ID,
                        t_out = math.huge,
                        is_output = false,
                        mode = mode,
                        no = WPN_No
                    }
                end
                target_data[ID].x = INN(7*i - 6)
                target_data[ID].y = INN(7*i - 5)
                target_data[ID].z = INN(7*i - 4)
                target_data[ID].vx = INN(7*i - 3)
                target_data[ID].vy = INN(7*i - 2)
                target_data[ID].vz = INN(7*i - 1)
                target_data[ID].t = 0
            end
        end
    end

    --出力リセット
    for i = 1, 32 do
        OUN(i, 0)
    end
    OUN(29, WPN_No)
    OUN(30, mode)

    --出力
    --t_outが大きい順にソート
    local target_data_sort, j = {}, 1
    for _, data in pairs(target_data) do
        table.insert(target_data_sort, data)
    end
    table.sort(target_data_sort, function(a, b) return a.t_out > b.t_out end)
    if is_fire then
        for i = 1, 4 do
            --連続出力防止用判定
            while j <= #target_data_sort do
                if not target_data_sort[j].is_output then
                    if weapon_data[target_data_sort[j].no] ~= nil then
                        if not weapon_data[target_data_sort[j].no].is_wpnbusy then
                            weapon_data[target_data_sort[j].no].is_wpnbusy = true
                            target_data[target_data_sort[j].ID].is_output = true
                            OUN(29, target_data_sort[j].no)
                            OUN(30, target_data_sort[j].mode)
                            break
                        end
                    end
                else
                    break
                end
                j = j + 1
            end
            --出力
            if target_data_sort[j] ~= nil then
                OUN(7*i - 6, target_data_sort[j].x)
                OUN(7*i - 5, target_data_sort[j].y)
                OUN(7*i - 4, target_data_sort[j].z)
                OUN(7*i - 3, target_data_sort[j].vx)
                OUN(7*i - 2, target_data_sort[j].vy)
                OUN(7*i - 1, target_data_sort[j].vz)
                OUN(7*i - 0, target_data_sort[j].ID)
                target_data[target_data_sort[j].ID].t_out = 0
            else
                break
            end
        end
    end
end

function onDraw()
    screen.drawText(1, 1, "#target_data:"..#target_data)

    local i = 1
    for ID, data in pairs(target_data) do
        screen.drawText(1, i*7, "ID:"..data.ID)
        i = i + 1
        screen.drawText(1, i*7, "No:"..data.no)
        i = i + 1
        screen.drawText(1, i*7, "mode:"..data.mode)
        i = i + 1

        screen.drawText(1, i*7, "is_output:"..bool_to_text(data.is_output))
        i = i + 1
        screen.drawText(1, i*7, "is_wpnbusy:"..bool_to_text(weapon_data[data.no].is_wpnbusy))
        i = i + 1
    end
end

function bool_to_text(is)
    if is then
        return "True"
    else
        return "False"
    end
end