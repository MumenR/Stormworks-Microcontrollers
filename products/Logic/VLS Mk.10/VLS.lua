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
time_out_tick_ELI = 1
weapon_data = {}
MTX_data = {}
is_launch = false
is_launch_pulse = false
launch_tick = 0
seed = 0
radio_freq = 0

function onTick()
    --武器情報--
    my_model_no = INN(31)
    last_vls_info = INN(32)

    is_loaded = my_model_no ~= 0

    --時間経過処理とタイムアウト削除 weapon_data
    for NO, data in pairs(weapon_data) do
        data.t = data.t + 1
        data.t_out = data.t_out + 1
        if data.t > time_out_tick then
            weapon_data[NO] = nil
        end
    end

    --取り込んだ情報を登録 weapon_data
    --[[
        weapon_data = {
            [model No.] = {
                no = weapon model No.,
                qty = weapon qty,
                t = time out tick,
                t_out = last output tick
            }
        }
    ]]
    if last_vls_info ~= 0 then
        last_wpn_no = math.floor(last_vls_info/1000)
        last_wpn_qty = last_vls_info%1000
        if weapon_data[last_wpn_no] == nil then
            weapon_data[last_wpn_no] = {
                no = last_wpn_no,
                qty = last_wpn_qty,
                t = 0,
                t_out = math.huge
            }
        else
            weapon_data[last_wpn_no].no = last_wpn_no
            weapon_data[last_wpn_no].qty = last_wpn_qty
            weapon_data[last_wpn_no].t = 0
        end
    end

    --自情報を追加
    if weapon_data[my_model_no] == nil and is_loaded then
        weapon_data[my_model_no] = {
            no = my_model_no,
            qty = 0,
            t = 0,
            t_out = math.huge
        }
    end

    --発射順位確定
    if is_loaded then
        firing_order = weapon_data[my_model_no].qty + 1
    else
        firing_order = 1000
    end

    --出力リセット
    for i = 1, 32 do
        OUN(i, 0)
        OUB(i, false)
    end

    --武器種番号と数量出力
    --t最大を探索
    local max_no, max_t = 0, -1
    for NO, data in pairs(weapon_data) do
        if data.t_out > max_t then
            max_t = data.t_out
            max_no = NO
        end
    end
    if max_no ~= 0 then
        if max_no == my_model_no and is_loaded and not is_launch then
            OUN(32, max_no*1000 + weapon_data[max_no].qty + 1)
        else
            OUN(32, max_no*1000 + weapon_data[max_no].qty)
        end
        weapon_data[max_no].t_out = 0
    end

    --debug
    OUN(20, my_model_no)
    OUN(21, firing_order)





    --発射処理--
    WPN_No = INN(29)
    mode = INN(30)
    is_ELI_fire = INB(1)

    HATCH_CLOSE_T = PRN("hatch close timing (s)")*60
    LAUNCH_T = PRN("launch timing (s)")*60 + 4
    GUIDANCE_T = PRN("guidance time (s)")*60

    --時間経過処理とタイムアウト削除 MTX_data
    for ID, data in pairs(MTX_data) do
        data.t = data.t + 1
        if (data.t > time_out_tick and ID ~= -1) or (data.t > time_out_tick_ELI and ID == -1) then
            MTX_data[ID] = nil
        end
    end

    --発射情報時間経過と終了
    if is_launch then
        launch_tick = launch_tick + 1
        if launch_tick > GUIDANCE_T then
            is_launch = false
            launch_tick = 0
        end
    end

    --取り込んだ情報を登録 MTX_data
    --[[
        MTX_data = {
            [ID] = {
                x = target world x, 
                y = target world y, 
                z = target world z,
                vx = target world vx,
                vy = target world vy,
                vz = traget world vz,
                ID = target ID,
                t = time out tick,
                mode = weapon mode
            }
        }
    ]]
    for i = 1, 4 do
        local ID = INN(i*7)
        if ID ~= 0 then
            --初回登録
            if MTX_data[ID] == nil or (ID == -1 and is_ELI_fire) then
                MTX_data[ID] = {
                    ID = ID,
                    mode = mode
                }
                if is_loaded and my_model_no == WPN_No and firing_order == 1 and not is_launch then
                    launch_ID = ID
                    is_launch = true
                    launch_tick = 0
                end
            end
            MTX_data[ID].x = INN(7*i - 6)
            MTX_data[ID].y = INN(7*i - 5)
            MTX_data[ID].z = INN(7*i - 4)
            MTX_data[ID].vx = INN(7*i - 3)
            MTX_data[ID].vy = INN(7*i - 2)
            MTX_data[ID].vz = INN(7*i - 1)
            MTX_data[ID].t = 0
        end
    end

    --選択して出力
    if is_launch and MTX_data[launch_ID] ~= nil then
        OUN(1, MTX_data[launch_ID].x)
        OUN(2, MTX_data[launch_ID].y)
        OUN(3, MTX_data[launch_ID].z)
        OUN(4, MTX_data[launch_ID].vx)
        OUN(5, MTX_data[launch_ID].vy)
        OUN(6, MTX_data[launch_ID].vz)
        OUN(7, MTX_data[launch_ID].mode)
        OUB(1, true)
    end


    OUB(30, is_launch and launch_tick < HATCH_CLOSE_T)                                  --ハッチ
    OUB(31, is_launch and launch_tick >= LAUNCH_T and launch_tick < LAUNCH_T + 60)      --発射
    OUB(32, is_launch)                                                                  --無線


    --無線周波数--
    seed = seed + 1
    if is_launch and not is_launch_pulse then
        math.randomseed(seed)
        radio_freq = math.random(1, 1000000)
    end
    is_launch_pulse = is_launch
    OUN(31, radio_freq)
end