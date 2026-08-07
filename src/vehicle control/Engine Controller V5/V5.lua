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

radiator_sr = false
generator_sr = false
min_engine_rps = 2.5
target_af_ratio = 13.7

idling_error_pre = 0
idling_error_sum = 0
clutch_error_pre = 0
clutch_error_sum = 0

--PID制御
function PID(P, I, D, target, current, error_sum_pre, error_pre, min, max)
    local error, error_diff, controll
    error = target - current
    error_sum = error_sum_pre + error
    error_diff = error - error_pre
    controll = P*error + I*error_sum + D*error_diff

    if controll > max or controll < min then
        error_sum = error_sum_pre
        controll = P*error + I*error_sum + D*error_diff
    end

    return controll, error_sum, error
end

--0or1変換
function bool2num(bool)
    if bool then
        return 1
    else
        return 0
    end
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
    air_volume = INN(1)
    fuel_volume = INN(2)
    temp = INN(3)
    throttle = math.abs(INN(4))
    engine_rps = INN(5)
    air_pressure = INN(6)
    battery = INN(7)

    power = INN(8) == 1

    --propety
    max_temp = PRN("max temp")
    min_temp = PRN("min temp")
    thermal_throttling_temp = PRN("thermal throttling temp")
    max_battery = PRN("max battery")
    min_battery = PRN("min battery")
    idling_rps = PRN("idling rps")
    idling_gene_rps = PRN("idling generation rps")
    target_rps = INN(9)
    thermal_throttling_rps = PRN("thermal throttling rps")
    max_rps = PRN("max rps")
    
    idling_P = PRN("idling P")
    idling_I = PRN("idling I")
    idling_D = PRN("idling D")
    idling_rps_fuel = PRN("idling rps fuel")
    clutch_P = PRN("clutch P")
    clutch_I = PRN("clutch I")
    clutch_D = PRN("clutch D")

    --スターター
    starter = power and engine_rps < min_engine_rps

    --ラジエーター
    if temp > max_temp then
        radiator_sr = true
    elseif temp < min_temp then
        radiator_sr = false
    end
    radiator = radiator_sr and not starter

    --発電機
    if battery > max_battery then
        generator_sr = false
    elseif battery < min_battery then
        generator_sr = true
    end
    generator = generator_sr and not starter

    --アイドリング時の目標回転数
    if generator then
        idling_rps = idling_gene_rps
    end

    --アイドリング
    idling = power and throttle < 0.01 and not starter
    if idling then
        idling_PID, idling_error_sum, idling_error_pre = PID(idling_P, idling_I, idling_D, idling_rps, engine_rps, idling_error_sum, idling_error_pre, -idling_rps_fuel, max_fuel)
    else
        idling_PID, idling_error_sum, idling_error_pre = 0, 0 ,0
    end

    --空気係数と最大燃料値
    air_coefficient = (0.4*target_af_ratio)/(air_pressure*0.029 + 2.75)
    max_fuel = 1/air_coefficient
    

    --スロットル制御
    if power and engine_rps < max_rps then
        if starter then
            fuel = max_fuel
        else
            if throttle > 0.01 then
                fuel = throttle*(max_fuel - idling_rps_fuel) + idling_rps_fuel
            else
                fuel = clamp(idling_PID + idling_rps_fuel, 0, max_fuel)
            end
        end
    else
        fuel = 0
    end
    air = fuel*air_coefficient

    --サーマルスロットリング
    if temp > thermal_throttling_temp then
        target_rps = thermal_throttling_rps
    end

    --クラッチPID
    if power and throttle > 0.01 and not starter then
        clutch_PID, clutch_error_sum, clutch_error_pre = PID(clutch_P*throttle, clutch_I*throttle, clutch_D, target_rps, engine_rps, clutch_error_sum, clutch_error_pre, -100, 0)
    else
        clutch_PID, clutch_error_sum, clutch_error_pre = 0, 0, 0
    end

    --クラッチ制御
    if starter then
        clutch = 0
    else
        clutch = clamp((-clutch_PID/100), 0, 1)^(1/6)
    end

    --発電機ギア
    generator_gear = generator and idling

    --num変換
    starter_num = bool2num(starter)
    radiator_num = bool2num(radiator)
    generator_num = bool2num(generator)

    OUN(1, throttle*100)
    OUN(2, engine_rps*60)
    OUN(3, temp)
    OUN(4, battery*100)
    OUN(5, air_volume/fuel_volume)
    OUN(6, air)
    OUN(7, fuel)
    OUN(8, clutch)
    OUN(9, starter_num)
    OUN(10, radiator_num)
    OUN(11, generator_num)

    OUB(1, power)
    OUB(2, starter)
    OUB(3, radiator)
    OUB(4, generator)
    OUB(5, generator_gear)
end