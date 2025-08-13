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

--for auto generator

INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool
PRN = property.getNumber

radiator_sr = false
min_engine_rps = 2.5
target_af_ratio = 13.7

throttle_error_pre = 0
throttle_error_sum = 0

clutch_error_pre = 0
clutch_error_sum = 0

--PID制御
function PID(P, I, D, target, current, error_sum_pre, error_pre, min, max)
    local error, error_diff, controll
    error = target - current
    error_sum = error_sum_pre + error
    error_diff = error - error_pre
    controll = P*error + I*error_sum + D*error_diff

    if controll > max or controll < min and math.abs(error_sum) > math.abs(error_sum_pre) then
        error_sum = error_sum_pre
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
    engine_rps = INN(5)
    air_pressure = INN(6)
    battery = INN(7)

    is_power = INN(8) == 1

    --propety
    target_battery = PRN("target battery")
    throttle_P = INN(12)
    throttle_I = INN(13)
    throttle_D = INN(14)

    max_temp = PRN("max temp")
    min_temp = PRN("min temp")
    thermal_throttling_temp = PRN("thermal throttling temp")
    thermal_throttling_rps = PRN("thermal throttling rps")

    target_rps = PRN("target rps")
    max_rps = PRN("max rps")
    clutch_P = INN(9)
    clutch_I = INN(10)
    clutch_D = INN(11)

    idling_rps_fuel = PRN("idling rps fuel")

    --スロット
    if is_power then
        throttle, throttle_error_sum, throttle_error_pre = PID(throttle_P, throttle_I, throttle_D, target_battery, battery, throttle_error_sum, throttle_error_pre, 0, 1)
    else
        throttle = 0
        throttle_error_pre, throttle_error_sum = 0, 0
    end

    --スターター
    is_starter = is_power and engine_rps < min_engine_rps and throttle > 0

    --ラジエーター
    if temp > max_temp then
        radiator_sr = true
    elseif temp < min_temp then
        radiator_sr = false
    end
    is_radiator = radiator_sr and not is_starter

    --空気係数と最大燃料値
    air_coefficient = (0.4*target_af_ratio)/(air_pressure*0.029 + 2.75)
    max_fuel = 1/air_coefficient

    --スロットル制御
    if is_power and engine_rps < max_rps and throttle > 0 then
        if is_starter then
            fuel = max_fuel
        else
            fuel = throttle*(max_fuel - idling_rps_fuel) + idling_rps_fuel
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
    if is_power and throttle > 0 and not is_starter then
        clutch_PID, clutch_error_sum, clutch_error_pre = PID(clutch_P*throttle, clutch_I*throttle, clutch_D*throttle, target_rps, engine_rps, clutch_error_sum, clutch_error_pre, -100, 0)
    else
        clutch_PID, clutch_error_sum, clutch_error_pre = 0, 0, 0
    end

    --クラッチ制御
    if is_starter then
        clutch = 0
    else
        clutch = clamp((-clutch_PID/100), 0, 1)^(1/6)
    end


    --num変換
    starter_num = bool2num(is_starter)
    radiator_num = bool2num(is_radiator)

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

    OUB(1, is_power)
    OUB(2, is_starter)
    OUB(3, is_radiator)
end