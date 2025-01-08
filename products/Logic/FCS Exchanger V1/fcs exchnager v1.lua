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
        simulator:setInputBool(3, simulator:getIsClicked(1))
        simulator:setInputBool(4, simulator:getIsClicked(2))

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

send = false
receive = false
send_in_pulse = false
receive_in_pulse = false
fire_table = {}
t = 0

--シリアルナンバー生成
math.randomseed()
SN = math.random(1, 100000000)

function onTick()
    --排他的トグルボタン
    send_in = INB(6)
    receive_in = INB(7)

    if send_in and not send_in_pulse then
        send = not send
        if send and receive then
            receive = false
        end
    end
    send_in_pulse = send_in

    if receive_in and not receive_in_pulse then
        receive = not receive
        if receive and send then
            send = false
        end
    end
    receive_in_pulse = receive_in

    OUB(6, send)
    OUB(7, receive)

    --着弾時間出力
    timing_tick = INN(9)
    OUN(31, timing_tick)
    OUN(32, SN)


    --ホスト処理、最大値選択
    timing_tick_send_in = INN(10)
    SN_send_in = INN(11)
    if send then
        --最新値に更新
        if SN_send_out == SN_send_in then
            timing_tick_send_out = timing_tick_send_in
            SN_send_out = SN_send_in
            t = 0
        elseif SN_send_in == 0 then
            --1秒間最遠クライアントから通信がなかったら更新
            if t <= 60 then
                t = t + 1
            else
                timing_tick_send_out = timing_tick_send_in
                SN_send_out = SN_send_in
            end
        elseif timing_tick_send_in > timing_tick_send_out then
            --受信値と比較
            timing_tick_send_out = timing_tick_send_in
            SN_send_out = SN_send_in
        end

        --自分と比較
        if timing_tick > timing_tick_send_out then
            timing_tick_send_out = timing_tick
            SN_send_out = SN
        end
    else
        timing_tick_send_out = timing_tick
        SN_send_out = SN
        t = 0
    end
    OUN(7, timing_tick_send_out)
    OUN(8, SN_send_out)
    OUB(8, send)

    --クライアント処理、出力切り替え
    timing_tick_receive_in = INN(18)
    SN_receive_in = INN(19)
    if receive then
        --自分と比較
        if timing_tick > timing_tick_receive_in and SN_receive_in ~= SN then
            timing_radio = true
        elseif SN_receive_in == SN then
            timing_radio = not timing_radio
        else
            timing_radio = false
        end
    else
        timing_radio = false
    end
    OUB(9, timing_radio)

    --射撃タイミング遅延
    fire_send = INB(2)
    fire_receive = INN(22) == 1
    --テーブル挿入
    if receive then
        table.insert(fire_table, fire_receive)
    else
        table.insert(fire_table, fire_send)
    end
    --要素数上限
    while #fire_table > 3600 do
        table.remove(fire_table, 1)
    end
    --インデックス計算
    if send then
        timing_index = #fire_table - math.floor(timing_tick_send_out - timing_tick + 0.5) - 7
    elseif receive then
        timing_index = #fire_table - math.floor(timing_tick_receive_in - timing_tick + 0.5)
    else
        timing_index = #fire_table
    end
    --射撃値選択
    if timing_index > 0 and (send or receive) then
        fire = fire_table[timing_index]
    elseif send or receive then
        fire = false
    else
        fire = fire_send
    end
    OUB(2, fire)
    OUB(3, fire_send)

    --ELI出力切り替え
    if receive then
        for i = 1, 6 do
            OUN(i, INN(i + 11))
        end
        OUB(1, INN(20) == 1)
        OUB(4, INN(23) == 1)
    else
        for i = 1, 6 do
            OUN(i, INN(i))
        end
        OUB(1, INB(1))
        OUB(4, INB(4))
    end

    OUN(20, #fire_table)
    OUN(21, timing_index)
end