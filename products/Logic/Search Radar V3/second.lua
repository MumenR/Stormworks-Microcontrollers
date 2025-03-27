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

data_pos = {}
target = {}

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

--極座標から直交座標へ変換(Z軸優先)
function Polar2Rect(pitch, yaw, distance, radian_bool)
    local x, y, z
    if not radian_bool then
        pitch = pitch*math.pi*2
        yaw = yaw*math.pi*2
    end
    x = distance*math.cos(pitch)*math.sin(yaw)
    y = distance*math.cos(pitch)*math.cos(yaw)
    z = distance*math.sin(pitch)
    return x, y, z
end

--三次元距離
function distance3(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

--ID生成
function nextID()
    local ID, same = 1, true
    while same do
        same = false
        for i = 1, #target do
            same = ID == target[i][4]
            if same then
                ID = ID + 1
                break
            end
        end
    end
    return ID
end

function onTick()
    t_max = property.getNumber("target lost tick")

    --フィジックス情報取り込み
    --遅延生成
    table.insert(data_pos, {INN(25), INN(26), INN(27), INN(28), INN(29), INN(30)})
    while #data_pos > 6  do
        table.remove(data_pos, 1)
    end
    Px = data_pos[1][1]
    Py = data_pos[1][2]
    Pz = data_pos[1][3]
    Ex = data_pos[1][4]
    Ey = data_pos[1][5]
    Ez = data_pos[1][6]

    --時間経過処理
    --target[座標, ID, 時間]
    for i = 1, #target do
        target[i][5] = target[i][5] + 1
    end

    --データ削除
    i = 1
    while i <= #target do
        if target[i][5] > t_max then
            table.remove(target, i)
        else
            i = i + 1
        end
    end

    --データ取り込み
    --data_polar[チャンネル][極座標]
    data_polar = {}
    for i = 1, 8 do
        if INB(i) then
            table.insert(data_polar, {INN(i*3 - 2), INN(i*3 - 1), INN(i*3)})
        end
    end

    --data_world[チャンネル][ワールド座標]
    data_world = {}
    for i = 1, #data_polar do
        local Lx, Ly, Lz, Wx, Wy, Wz
        Lx, Ly, Lz = Polar2Rect(data_polar[i][3], data_polar[i][2], data_polar[i][1], false)
        Wx, Wy, Wz = Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
        table.insert(data_world, {Wx, Wy, Wz})
    end

    --同一目標のデータを統合
    i = 2
    while i <= #data_world do
        local x1, y1, z1, x2, y2, z2
        x1 = data_world[i][1]
        y1 = data_world[i][2]
        z1 = data_world[i][3]
        
        error_range = 0.01*distance3(x1, y1, z1, Px, Pz, Py)

        for j = 1, i - 1 do
            x2 = data_world[j][1]
            y2 = data_world[j][2]
            z2 = data_world[j][3]
            distance = distance3(x1, y1, z1, x2, y2, z2)
            if distance < error_range then
                data_world[j] = {(x1 + x2)/2, (y1 + y2)/2, (z1 + z2)/2}
                table.remove(data_world, i)
                i = i - 1
                break
            end
        end
        i = i + 1
    end

    --目標同定
    --target[座標, ID, 時間]
    max_movement = 300
    for i = 1, #target do
        local x1, y1, z1, x2, y2, z2
        x1 = target[i][1]
        y1 = target[i][2]
        z1 = target[i][3]
        for j = 1, #data_world do
            x2 = data_world[j][1]
            y2 = data_world[j][2]
            z2 = data_world[j][3]
            distance = distance3(x1, y1, z1, x2, y2, z2)
            if distance < max_movement then
                target[i] = {x2, y2, z2, target[i][4], 0}
                table.remove(data_world, j)
                break
            end
        end
    end

    --新規目標登録
    --target[座標, ID, 時間]
    for i = 1, #data_world do
        local x1, y1, z1
        x1 = data_world[i][1]
        y1 = data_world[i][2]
        z1 = data_world[i][3]
        table.insert(target, {x1, y1, z1, nextID(), 0})
    end

    --出力
    for i = 1, 24 do
        OUN(i, 0)
    end

    i = 0
    for j = 1, #target do
        if target[j][5] == 0 then
            if i < 6 then
                for k = 1, 4 do
                    OUN(4*i + k, target[j][k])
                end
                i = i + 1
            else
                target[j][5] = -1
            end
        end
    end
end