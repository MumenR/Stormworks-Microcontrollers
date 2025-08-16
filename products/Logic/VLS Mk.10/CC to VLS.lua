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
time_out_tick_ELI = 3

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

    --ELIデータ削除
    if is_fire and not is_fire_pulse then
        target_data[-1] = nil
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
            --更新
            weapon_data[last_wpn_no].qty = last_wpn_qty
        end
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
        OUB(i, false)
    end
    OUN(29, WPN_No)
    OUN(30, mode)

    --出力
    --t_outが大きい順にソート
    local target_data_sort, is_new_target_out, i, j = {},  false, 1, 1
    for _, data in pairs(target_data) do
        table.insert(target_data_sort, data)
    end
    table.sort(target_data_sort, function(a, b) return a.t_out > b.t_out end)

    --t_outが大きい順に出力、新規目標はis_fireがオン且つ1つまで出力可能
    while i <= #target_data_sort and j <= 4 do
        local ID, No = target_data_sort[i].ID, target_data_sort[i].no
        --出力可能か判定(新規目標で、重複出力のときとnot is fireのパターンを除外)
        if target_data[ID].is_output or (is_fire and not is_new_target_out) then
            --新規目標のとき
            if not target_data[ID].is_output then
                --WPN busyではないことを確認
                if weapon_data[No] ~= nil then
                    if not weapon_data[No].is_wpnbusy then
                        weapon_data[No].is_wpnbusy = true
                        target_data[ID].is_output = true
                        is_new_target_out = true
                        OUN(29, target_data[ID].no)
                        OUN(30, target_data[ID].mode)

                        OUN(7*j - 6, target_data[ID].x)
                        OUN(7*j - 5, target_data[ID].y)
                        OUN(7*j - 4, target_data[ID].z)
                        OUN(7*j - 3, target_data[ID].vx)
                        OUN(7*j - 2, target_data[ID].vy)
                        OUN(7*j - 1, target_data[ID].vz)
                        OUN(7*j - 0, target_data[ID].ID)
                        target_data[ID].t_out = 0
                        j = j + 1

                        --ELIのとき
                        if ID == -1 then
                            OUB(1, true)
                        end
                    end
                end
            --新規目標ではないとき
            else
                OUN(7*j - 6, target_data[ID].x)
                OUN(7*j - 5, target_data[ID].y)
                OUN(7*j - 4, target_data[ID].z)
                OUN(7*j - 3, target_data[ID].vx)
                OUN(7*j - 2, target_data[ID].vy)
                OUN(7*j - 1, target_data[ID].vz)
                OUN(7*j - 0, target_data[ID].ID)
                target_data[ID].t_out = 0
                j = j + 1
            end
        end

        i = i + 1
    end

    is_fire_pulse = is_fire
end
--[[
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

]]