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

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

pitch_error_sum = 0
pitch_error_pre = 0
roll_error_sum = 0
roll_error_pre = 0
updown_error_sum = 0
updown_error_pre = 0

--PID制御
function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
    error = target - current
    errorSum = errorSumPre + error
    errorDiff = error - errorPre
    controll = P*error + I*errorSum + D*errorDiff

    if controll > max or controll < min then
        errorSum = errorSumPre
        controll = P*error + I*errorSum + D*errorDiff
    end
    return clamp(controll, min, max), errorSum, error
end

function onTick()
    speed = INN(9)
    speed_abs = INN(13)
    alt = INN(2)
    tilt_pitch = INN(15)
    tilt_roll = INN(16)

    target_alt = PRN("Target Alt")
    roll_gain = PRN("roll gain")
    pitch_gain = PRN("pitch gain")
    updown_gain = PRN("updown gain")
    speed_gain = PRN("speed gain")

    roll_P = PRN("roll P")
    roll_I = PRN("roll I")
    roll_D = PRN("roll D")
    pitch_P = PRN("pitch P")
    pitch_I = PRN("pitch I")
    pitch_D = PRN("pitch D")
    updown_P = PRN("updown P")
    updown_I = PRN("updown I")
    updown_D = PRN("updown D")

    manual_yaw = INN(1)

    --前提計算
    --スピードによる制御力減衰
    speed_denom = clamp(speed_abs/speed_gain, 1, 100000)

    --旋回時の傾斜
    target_roll = -manual_yaw*speed_abs/1000

    --メイン計算
    if speed_abs < 5 then
        roll = -roll_gain*tilt_roll/speed_denom
        pitch = -pitch_gain*tilt_pitch/speed_denom
        updown = updown_gain*(target_alt - alt)/speed_denom
        roll_error_sum = 0
        roll_error_pre = 0
        pitch_error_sum = 0
        pitch_error_pre = 0
        updown_error_sum = 0
        updown_error_pre = 0
    else
        roll, roll_error_sum, roll_error_pre = PID(roll_P, roll_I, roll_D, target_roll, tilt_roll, roll_error_sum, roll_error_pre, -1, 1)
        pitch, pitch_error_sum, pitch_error_pre = PID(pitch_P, pitch_I, pitch_D, 0, tilt_pitch, pitch_error_sum, pitch_error_pre,  -1, 1)
        updown, updown_error_sum, updown_error_pre = PID(updown_P, updown_I, updown_D, target_alt, alt, updown_error_sum, updown_error_pre,  -1, 1)
    end

    --最大最小
    roll = clamp(roll, -0.7, 0.7)
    pitch = clamp(pitch, -0.7, 0.7)
    updown = clamp(updown, -0.3, 0.3)

    FL = pitch - roll + updown
    FM = pitch + updown
    FR = pitch + roll + updown
    ML = updown - roll
    MM = updown
    MR = updown + roll
    RL = -pitch - roll + updown
    RM = -pitch + updown
    RR = -pitch + roll + updown

    if speed < 0 then
        FL, FM, FR, ML, MM, MR, RL, RM, RR = -FL, -FM, -FR, -ML, -MM, -MR, -RL, -RM, -RR
    end

    OUN(1, FL)
    OUN(2, FM)
    OUN(3, FR)
    OUN(4, ML)
    OUN(5, MM)
    OUN(6, MR)
    OUN(7, RL)
    OUN(8, RM)
    OUN(9, RR)
end



