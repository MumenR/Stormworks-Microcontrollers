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
fireTable = {}
t = 0
SN_t = 1700

function bool2num(bool)
    return bool and 1 or 0
end

--シリアルナンバー生成
SN = math.random(1, 10000000)

function onTick()
    shootable = INB(2)

    --シリアルナンバー更新
    do
        if SN_t >= 1800 then
            physics_x = INN(27)
            physics_y = INN(28)
            physics_z = INN(29)

            SN_t = 0
            math.randomseed(physics_x)
            SN_x = math.random(1, 3000000)
            math.randomseed(physics_y)
            SN_y = math.random(1, 3000000)
            math.randomseed(physics_z)
            SN_z = math.random(1, 3000000)

            SN = SN_x + SN_y + SN_z
        else
            SN_t = SN_t + 1
        end
    end

    --排他的トグルボタン(send or receive)
    do
        sendButton = INB(6)
        receiveButton = INB(7)

        if sendButton and not send_in_pulse then
            send = not send
            if send and receive then
                receive = false
            end
        end
        send_in_pulse = sendButton

        if receiveButton and not receive_in_pulse then
            receive = not receive
            if receive and send then
                send = false
            end
        end
        receive_in_pulse = receiveButton

        OUB(6, send)
        OUB(7, receive)
    end

    --着弾時間出力
    tickMyIn = INN(25)
    OUN(31, tickMyIn)
    OUN(32, SN)

    --ホスト処理、最大値選択
    do
        tickSubRadioIn = INN(10)
        SNSubRadioIn = INN(11)
        if send then
            --最新値に更新
            if maxSNOut == SNSubRadioIn then
                maxTickOut = tickSubRadioIn
                maxSNOut = SNSubRadioIn
                t = 0
            elseif SNSubRadioIn == 0 then
                --1秒間最遠クライアントから通信がなかったら更新
                if t <= 60 then
                    t = t + 1
                else
                    maxTickOut = tickSubRadioIn
                    maxSNOut = SNSubRadioIn
                end
            elseif tickSubRadioIn > maxTickOut then
                --受信値と比較
                maxTickOut = tickSubRadioIn
                maxSNOut = SNSubRadioIn
            end

            --自分と比較
            if tickMyIn > maxTickOut and shootable then
                maxTickOut = tickMyIn
                maxSNOut = SN
            end
        else
            maxTickOut = tickMyIn
            maxSNOut = SN
            t = 0
        end
        OUN(10, maxTickOut)
        OUN(11, maxSNOut)
        OUB(8, send)
    end

    --クライアント処理、出力切り替え
    do
        maxTickRadioIn = INN(21)
        maxSNRadioIn = INN(22)
        if receive and shootable then
            --自分と比較
            if tickMyIn > maxTickRadioIn and maxSNRadioIn ~= SN then    --自分がより遠ければ宣言
                radioSubSend = true
            elseif math.abs(maxSNRadioIn - SN) < 1 then                 --自分が最遠なら新入りが入れるように点滅
                radioSubSend = not radioSubSend
            else
                radioSubSend = false
            end
        else
            radioSubSend = false
        end
        OUB(9, radioSubSend)
    end

    --射撃タイミング遅延
    do
        fireButton = INB(3)
        fireMainRadio = INN(24) == 1
        --同期射撃しないならリセット
        if not (send or receive) then
            fireTable = {}
        end
        --テーブル挿入(最後尾が最新)
        if receive then
            table.insert(fireTable, fireMainRadio)
        else
            table.insert(fireTable, fireButton)
        end
        --要素数上限
        while #fireTable > 3600 do
            table.remove(fireTable, 1)
        end
        --インデックス計算
        if send then
            timing_index = #fireTable - math.floor(maxTickOut - tickMyIn + 0.5) - 6    --送信遅延補正
        elseif receive then
            timing_index = #fireTable - math.floor(maxTickRadioIn - tickMyIn + 0.5)
        else
            timing_index = #fireTable
        end
        --射撃値選択
        if timing_index > 0 and (send or receive) then
            fire = fireTable[timing_index]
        elseif send or receive then     --まだテーブルがないとき
            fire = false
        else
            fire = fireButton
        end
        OUB(2, fire and shootable)
        OUN(13, bool2num(fireButton))
    end

    --TRD出力切り替え
    if receive then
        for i = 1, 9 do
            OUN(i, INN(i + 11))
        end
        OUB(1, INN(23) == 1)
        OUN(12, INN(23))
    else
        for i = 1, 9 do
            OUN(i, INN(i))
        end
        OUB(1, INB(1))
        OUN(12, bool2num(INB(1)))
    end

    --debug
    OUN(23, #fireTable)
    OUN(24, timing_index)
end