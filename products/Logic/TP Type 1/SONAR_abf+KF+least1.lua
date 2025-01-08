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

lock_on = false
PN_toggle = false
lock_on_x = 0
lock_on_z = 0
lock_on_x_table = {}
lock_on_z_table = {}
t = 0

target_pred = 0
target_est = 0
target_ddt = 0
target_pred2 = 0
target_est2 = 0
target_ddt2 = 0


rawtable = {}
filtertable = {}
abftable = {}

-- テーブルの中から最小値のインデックスを返す関数
function find_Min_And_Index(t)
    local minValue = t[1]
    local minIndex = 1
    for i = 2, #t do
        if t[i] < minValue then
            minValue = t[i]
            minIndex = i
        end
    end
    return minIndex
end

--最小二乗法
function least_squares_method(xy)
    local a, b, sum_x, sum_y, sum_xy, sum_x2 = 0, 0, 0, 0, 0, 0

    if #xy == 0 then
        a = 0
        b = 0
    elseif #xy <= 5 then
        a = 0
        b = xy[#xy]
    else
        for i = 1, #xy do
            sum_x = sum_x + i
            sum_y = sum_y + xy[i]
            sum_xy = sum_xy + i*xy[i]
            sum_x2 = sum_x2 + i^2
        end
        a = (#xy*sum_xy - sum_x*sum_y)/(#xy*sum_x2 - sum_x^2)
        b = (sum_x2*sum_y - sum_xy*sum_x)/(#xy*sum_x2 - sum_x^2)
    end
    return a, b
end

pi = math.pi
pi2 = pi * 2
dt = 1 / 60

-- テーブルの中から最小値のインデックスを返す関数
function find_Min_And_Index(t)
    local minValue = t[1]
    local minIndex = 1
    for i = 2, #t do
        if t[i] < minValue then
            minValue = t[i]
            minIndex = i
        end
    end
    return minIndex
end

--和
function sum(A, B)
	local r = {}
	for i = 1, #A do
		r[i] = {}
		for j = 1, #A[1] do
			r[i][j] = A[i][j] + B[i][j]
		end
	end
	return r
end

--差
function substruct(A, B)
	local r = {}
	for i = 1, #A do
		r[i] = {}
		for j = 1, #A[1] do
			r[i][j] = A[i][j] - B[i][j]
		end
	end
	return r
end

--積
function multiplier(A, B)
	if #A[1] ~= #B then return nil end
	local r = {}
	for i = 1, #A do r[i] = {} end
	for i = 1, #A do
		for j = 1, #B[1] do
			local s = 0
			for k = 1, #B do s = s + A[i][k] * B[k][j] end
			r[i][j] = s
		end
	end
	return r
end

--逆行列
function inv(M)
	local n = #M
	local r = {}
	for i = 1, n do
		r[i] = {}
		for j = 1, n do r[i][j] = (i == j) and 1 or 0 end
	end
	for i = 1, n do
		local pv = M[i][i]
		for j = 1, n do
			M[i][j] = M[i][j] / pv
			r[i][j] = r[i][j] / pv
		end
		for k = 1, n do
			if k ~= i then
				local f = M[k][i]
				for j = 1, n do
					M[k][j] = M[k][j] - f * M[i][j]
					r[k][j] = r[k][j] - f * r[i][j]
				end
			end
		end
	end
	return r
end

--転置行列
function transpose(M)
	local r = {}
	for i = 1, #M[1] do
		r[i] = {}
		for j = 1, #M do r[i][j] = M[j][i] end
	end
	return r
end



--スカラー倍
function scalar(a, M)
	local r = {}
	for i = 1, #M do
		r[i] = {}
		for j = 1, #M[1] do
			r[i][j] = M[i][j] * a
		end
	end
	return r
end

--単位行列作成
function identity(n)
	local M = {}
	for i = 1, n do
		M[i] = {}
		for j = 1, n do
			if i == j then
				M[i][j] = 1
			else
				M[i][j] = 0
			end
		end
	end
	return M
end


--カルマンフィルタ
function KF(X, u, F, P, z, H, Q, R, I)
	local y, K
	--predict
	X = multiplier(F,X)-- multiplier(B,u)

	P = sum(multiplier(multiplier(F,P),transpose(F)),Q)

	--update
	y = substruct(z, multiplier(H,X))

	K = multiplier(multiplier(P, transpose(H)), inv(sum(multiplier(multiplier(H, P), transpose(H)), R)))

	X = sum(X, multiplier(K, y))
	P = multiplier(substruct(I, multiplier(K, H)), P)
	return X, P
end

--initilaize
I2 = identity(2)

azimuth = {{0},{0}}
elevation = {{0},{0}}

azimuthP = {{100,0},{0,100}}
elevationP = {{100,0},{0,100}}


F={{1, dt},{0, 1}}
H = {{1,0}}
isInit = false

function onTick()
    sonar_table = {}
    compare_sonar = {}
    target_x = 0
    target_z = 0

    ax, az = 0, 0
    bx, bz = 0, 0

    sonar_fov = property.getNumber("sonar fov")
    sample_num = INN(29)

    sonar_on = (INN(30) == 1)
    bQ = INN(31)
    target_rotate_x = 0
    target_rotate_z = INN(32)

    a = INN(27)
    b = INN(28)

    --noiseQ
    bearingQ = scalar(bQ, {{dt^3/2, dt^2/2}, {dt^2/2, dt}})

    if sonar_on then
        --情報読み込み
        for i = 1, 13 do
            if INB(i) then
                table.insert(sonar_table, {INN(2*i - 1), INN(2*i)})

                --ロックオン中ならば追跡値との差を比較
                if lock_on then
                    table.insert(compare_sonar, math.sqrt((INN(2*i - 1) - lock_on_x)^2 + (INN(2*i) - lock_on_z)^2))
                --そうでなければ目標座標との差を比較
                else
                    table.insert(compare_sonar, math.sqrt((INN(2*i - 1) - target_rotate_x)^2 + (INN(2*i) - target_rotate_z)^2))
                end
            end
        end

        if #sonar_table >= 1 then
            min_i = find_Min_And_Index(compare_sonar)

            --設定視野内ならば追跡値を上書き
            --視野範囲外の後方部分を円形とし、計算・判定
            if math.abs(sonar_table[min_i][1]) > sonar_fov/2 and (math.sin(sonar_table[min_i][2]*2*math.pi))^2 + (math.cos(sonar_table[min_i][2]*2*math.pi)*math.sin(sonar_table[min_i][1]*2*math.pi))^2 < (math.sin(sonar_fov*2*math.pi))^2 then
                lock_on = false
                PN_toggle = false
                lock_on_x = target_rotate_x
                lock_on_z = target_rotate_z
                lock_on_x_table, lock_on_z_table = {}, {}
            else
                lock_on = true

                target_current = sonar_table[min_i][1]
                target_pred = target_est + target_ddt
                residual = target_current - target_pred
                target_est = target_pred + a*residual
                target_ddt = target_ddt + b*residual

                target_current2 = sonar_table[min_i][2]
                target_pred2 = target_est2 + target_ddt2
                residual2 = target_current2 - target_pred2
                target_est2 = target_pred2 + a*residual2
                target_ddt2 = target_ddt2 + b*residual2

                target_x = sonar_table[min_i][1]
                target_z = sonar_table[min_i][2]
                lock_on_x = sonar_table[min_i][1]
                lock_on_z = sonar_table[min_i][2]
            end
        else
            lock_on = false
            target_pred = 0
            target_est = 0
            target_ddt = 0
            target_pred2 = 0
            target_est2 = 0
            target_ddt2 = 0
        end

        --追跡値にカルマンフィルタを適用
        if lock_on then
            if not(isInit) then
                --初期値
                azimuth = {{target_est},{0}}
                elevation = {{target_est2},{0}}
                isInit = true
            else
                local u,z={},{}
    
                --カルマンフィルタ
                sigmaBearing = (0.001)^2/12
                R = {{sigmaBearing}}
                
                --水平方向
                z = {{target_est}}
                u = {}
                azimuth, azimuthP= KF(azimuth, u, F, azimuthP, z, H, bearingQ, R, I2)
                
                --垂直方向
                z = {{target_est2}}
                u = {}
                elevation, elevationP= KF(elevation, u, F, elevationP, z, H, bearingQ, R, I2)
    
            end

            table.insert(lock_on_x_table, azimuth[1][1])
            table.insert(lock_on_z_table, elevation[1][1])

            --サンプル数を一定に保つ
            while #lock_on_x_table > sample_num do
                table.remove(lock_on_x_table, 1)
            end
            while #lock_on_z_table > sample_num do
                table.remove(lock_on_z_table, 1)
            end

            --最小二乗法
            ax, bx = least_squares_method(lock_on_x_table)
            az, bz = least_squares_method(lock_on_z_table)

        else
            -- no contact (reset)
            isInit=false
            azimuth = {{0},{0}}
            elevation = {{0},{0}}
            azimuthP = {{100,0},{0,100}}
            elevationP = {{100,0},{0,100}}
        end

        --距離が近い()
        if t >= 180 and #lock_on_x_table >= sample_num then
            PN_toggle = true
        elseif lock_on then
            t = t + 1
        else
            t = 0
            PN_toggle = false
        end

        --[[
        
        if PN_toggle then
            target_x = ax*60
            target_z = az*60
        end

        ]]
    else
        lock_on = false
        ax, az = 0, 0
        bx, bz = 0, 0
        target_pred = 0
        target_est = 0
        target_ddt = 0
        target_pred2 = 0
        target_est2 = 0
        target_ddt2 = 0
    end

    --遅延対策のため、オン/オフを0 or 1に変換
    if lock_on then
        lock_on_num = 1
    else
        lock_on_num = 0
    end

    OUN(1, target_x)
    OUN(2, target_z)
    OUN(3, lock_on_num)

    --グラフ描画用
    table.insert(rawtable, target_x)
    table.insert(filtertable, ax*sample_num + bx)
    table.insert(abftable, target_est)
    
    max_sample = 288
    if #rawtable > max_sample then
        table.remove(rawtable, 1)
    end
    if #filtertable > max_sample then
        table.remove(filtertable, 1)
    end
    if #abftable > max_sample then
        table.remove(abftable, 1)
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(255, 255, 255)
    screen.drawLine(0, h/2, w, h/2)

    screen.setColor(255, 255, 255, 128)
    for i = 1, 9 do
        line = math.floor(h*i/10)
        screen.drawLine(0, line, w, line)
        text = string.format("%.3f", 0.01 - 0.002*i)
        screen.drawText(w - #text*5, line - 6, text)
    end
    
    for i = 1, #rawtable do
        screen.setColor(255, 255, 0)
        glaph = math.floor(-rawtable[i]*(h/2)*100 + h/2)
        screen.drawLine(w - #rawtable + i, glaph, w - #rawtable + i + 1, glaph)

        screen.setColor(0, 0, 255)
        glaph = math.floor(-abftable[i]*(h/2)*100 + h/2)
        screen.drawLine(w - #abftable + i, glaph, w - #filtertable + i + 1, glaph)

        screen.setColor(255, 0, 0)
        glaph = math.floor(-filtertable[i]*(h/2)*100 + h/2)
        screen.drawLine(w - #filtertable + i, glaph, w - #filtertable + i + 1, glaph)
    end
end