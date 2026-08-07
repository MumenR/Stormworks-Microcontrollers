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

radiator_sr = false
generator_sr = false
min_engine_rps = 2.5
thermal_throttling_temp = 100

idling_error_pre = 0
idling_error_sum = 0
clutch_error_pre = 0
clutch_error_sum = 0
throttle_error_pre = 0
throttle_error_sum = 0

--PID制御
function PID(P, I, D, target, current, error_sum_pre, error_pre, min, max)
    local error, error_diff, controll
    error = target - current
    error_sum = error_sum_pre + error
    error_diff = error - error_pre
    controll = P*error + I*error_sum + D*error_diff
    
    if controll > max or controll < min then
        if (controll > max and error_sum_pre > 0) or (controll < min and error_sum_pre < 0)  then
            error_sum = error_sum_pre
        end
        controll = P*error + I*error_sum + D*error_diff
    end

    return clamp(controll, min, max), error_sum, error
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
    target_prop_rps = INN(4)/60
    engine_rps = INN(5)
    air_pressure = INN(6)
    battery = INN(7)

    --propety
    max_temp = INN(8)
    min_temp = INN(9)
    max_battery = INN(10)
    min_battery = INN(11)
    target_rps = INN(14)
    thermal_throttling_rps = INN(15)
    max_rps = INN(16)
    target_af_ratio = INN(17)
    idling_rps_fuel = INN(21)
    clutch_P = INN(22)
    clutch_I = INN(23)
    clutch_D = INN(24)
    power = INN(25) == 1
    prop_rps = INN(26)
    throttle_P = INN(27)
    throttle_I = INN(28)
    throttle_D = INN(29)
    collective = math.abs(INN(30))

    --スターター
    starter = power and engine_rps < min_engine_rps

    --空気係数と最大燃料値
    air_coefficient = (0.4*target_af_ratio)/(air_pressure*0.029 + 2.75)
    max_fuel = 1/air_coefficient

    --サーマルスロットリング
    if temp > thermal_throttling_temp then
        target_rps = thermal_throttling_rps
    end

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

    --スロットルPID
    if power and not starter then
        throttle, throttle_error_sum, throttle_error_pre = PID(throttle_P, throttle_I, throttle_D, target_rps, engine_rps, throttle_error_sum, throttle_error_pre, -idling_rps_fuel*100/max_fuel, 100*(1 - idling_rps_fuel/max_fuel))
    else
        throttle_error_sum, throttle_error_pre = 0, 0
        throttle = 0
    end

    --クラッチPID
    clutch_P = clutch_P*(0.01 + (target_prop_rps^2)*(collective^2)/10000)
    clutch_I = clutch_I*(0.01 + (target_prop_rps^2)*(collective^2)/10000)
    clutch_D = clutch_D*(0.01 + (target_prop_rps^2)*(collective^2)/10000)
    if power and not starter then
        clutch_PID, clutch_error_sum, clutch_error_pre = PID(clutch_P, clutch_I, clutch_D, target_prop_rps, prop_rps, clutch_error_sum, clutch_error_pre, 0, 100)
    else
        clutch_PID, clutch_error_sum, clutch_error_pre = 0, 0, 0
    end

    --クラッチ制御
    if starter then
        clutch = 0
    else
        clutch = (clutch_PID/100)^(1/6)
    end

    --スロットル制御
    if power and engine_rps < max_rps then
        if starter then
            fuel = max_fuel
        else
            fuel = (throttle/100)*max_fuel + idling_rps_fuel
        end
    else
        fuel = 0
    end
    air = fuel*air_coefficient

    --num変換
    starter_num = bool2num(starter)
    radiator_num = bool2num(radiator)
    generator_num = bool2num(generator)

    OUN(1, 100*fuel/max_fuel)
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
end


