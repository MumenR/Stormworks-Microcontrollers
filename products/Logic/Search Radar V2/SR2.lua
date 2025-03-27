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
        simulator:setInputBool(9, screenConnection.isTouched)
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

world_table = {}
tick_del = 200
touch_pulse = false
zoom_i = 1

--ローカル座標からワールド座標へ変換(physics sensor使用)
function Local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
	RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex)-math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
	RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
	RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
	return RetX + Px, RetZ + Pz, RetY + Py
end

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end


function onTick()

    physics_x = INN(4)
    physics_y = INN(8)
    physics_z = INN(12)
    euler_x = INN(16)
    euler_y = INN(20)
    euler_z = INN(24)

    compass = INN(28)*2*math.pi
    zoom = {250, 500, 1000, 2500, 5000, 10000, 25000, 50000}
    touch = INB(9)

    --目標をテーブルに読み込む
    rotate_table = {}
    local_table = {}
    for i = 1, 7 do
        if INB(i) then
            table.insert(rotate_table, {INN(i*4 - 3), INN(i*4 - 2), INN(i*4 - 1)})
        end
    end

    for i = 1, #rotate_table do
        --ローカル座標に変換
        local_x = rotate_table[i][1]*math.cos(rotate_table[i][3]*2*math.pi)*math.sin(rotate_table[i][2]*2*math.pi)
        local_y = rotate_table[i][1]*math.cos(rotate_table[i][3]*2*math.pi)*math.cos(rotate_table[i][2]*2*math.pi)
        local_z = rotate_table[i][1]*math.sin(rotate_table[i][3]*2*math.pi)
        table.insert(local_table, {local_x, local_y, local_z})
        --ワールド座標に変換
        --world_table = {{world_x1, world_y1, world_z1, tick1},...}
        world_x, world_y, world_z = Local2World(local_x, local_y, local_z, physics_x, physics_y, physics_z, euler_x, euler_y, euler_z)
        table.insert(world_table, {world_x, world_y, world_z, 0})
    end

    --時間経過処理
    for i = 1, #world_table do
        world_table[i][4] = world_table[i][4] + 1
    end

    --一定時間で削除
    do
        local i = 1
        while i <= #world_table do
            if world_table[i][4] > tick_del then
                table.remove(world_table, i)
                if #world_table == 0 then
                    break
                end
            else
                i = i + 1
            end
        end
    end


    --ズームレベル切り替え
    if touch and (not touch_pulse) then
        zoom_i = (zoom_i + 1)%#zoom
    end
    touch_pulse = touch
    km = zoom[zoom_i + 1]/1000

end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    --マップ描画
    screen.drawMap(physics_x, physics_z, km)

    --レーダー反応描画
    for i = 1, #world_table do
        map_x, map_y = map.mapToScreen(physics_x, physics_z, km, w, h, world_table[i][1], world_table[i][2])
        alpha = clamp(-510*(world_table[i][4] - tick_del)/tick_del, 0, 255)
        if world_table[i][3] > 100 then
            screen.setColor(255, 128, 0, alpha)
        else
            screen.setColor(255, 0, 0, alpha)
        end
        screen.drawCircleF(map_x, map_y, 1)
    end
    
    --自分の位置と向き
    x1 = w/2 - 2*math.sin(compass)
    y1 = h/2 - 2*math.cos(compass)
    x2 = w/2 - 6*math.sin(compass)
    y2 = h/2 - 6*math.cos(compass)
    screen.setColor(0, 255, 0)
    screen.drawCircle(w/2, h/2, 2)
    screen.drawLine(x1, y1, x2, y2)

    --縮尺
    scale = string.format("%.1fkm", km)
    screen.drawText(w - 5*#scale, h - 5, scale)
end



