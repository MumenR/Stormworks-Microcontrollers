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
pi2 = math.pi*2

LOST_TICK = 600

PRECISION = 0.1     --valueの最小保証精度
NBITS = 24          --valueに割り当てるビット数
function encode(id, value)
	value = math.floor(value / PRECISION + 0.5)
	if value < 0 then
		value = value + 1 << NBITS
	end
	value = value | id << NBITS
	id = (id >> (24 - NBITS)) + 66
	if id >= 127 then
		id = id + 67
	end
	local x = ('f'):unpack(('I3B'):pack(value & 16777215, id & 255))
	return x
end

function decode(x)
	local value, id = ('I3B'):unpack(('f'):pack(x))
	if id >> 7 & 1 ~= 0 then
		id = id - 67
	end
	id = (id - 66) << (24 - NBITS) | (value >> NBITS)
	value = value & ((1 << NBITS) - 1)
	if value >> (NBITS - 1) & 1 ~= 0 then
		value = value - (1 << NBITS)
	end
	return id, value * PRECISION
end

data = {}

function onTick()

    --時間経過と削除
    for ID, DATA in pairs(data) do
        data[ID].elaspedTick = data[ID].elaspedTick + 1
        data[ID].outputTick = data[ID].outputTick + 1

        if DATA.elaspedTick > LOST_TICK then
            data[ID] = nil
        end
    end
	
    --データ取り込み
    for i = 0, 5 do
        local x, y, z, ID
        x = INN(4*i + 1)
        y = INN(4*i + 2)
        z = INN(4*i + 3)
        ID = INN(4*i + 4)%1000
        if ID ~= 0 then
            --前回値と異なる値なら更新がされたと判定する
            local elaspedTick, outputTick = 0, math.huge
            if data[ID] ~= nil then
                --同じなら更新してない判定
                if data[ID].x == x and data[ID].y == y and data[ID].z == z then
                    outputTick = data[ID].outputTick
                    elaspedTick = data[ID].elaspedTick
                end
            end
            data[ID] = {
                x = x,
                y = y,
                z = z,
                elaspedTick = elaspedTick,
                outputTick = outputTick
            }
        end
    end


    --reset
    for i = 1, 32 do
        OUN(i, 0)
    end

    --最も最後に出力した値を探索
    local maxT, maxID = 0, 0
    for ID, DATA in pairs(data) do
        if DATA.outputTick > maxT then
            maxT = DATA.outputTick
            maxID = ID
        end
    end

    --出力
    if maxID ~= 0 then
        --3チャンネルに圧縮(千、百: x, 十: y, 一: z)
        local xID, yID, zID = math.floor((maxID/100)%100), math.floor((maxID/10)%10), math.floor(maxID%10)
        OUN(1, encode(xID, data[maxID].x))
        OUN(2, encode(yID, data[maxID].y))
        OUN(3, encode(zID, data[maxID].z))
        data[maxID].outputTick = 0
    end
end

