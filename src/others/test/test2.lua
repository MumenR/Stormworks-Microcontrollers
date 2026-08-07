INN = input.getNumber
OUN = output.setNumber

--PID制御
function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
    local error, errorSum, errorDiff, control
    error = target - current
    errorSum = errorSumPre + error
    errorDiff = error - errorPre
    control = P*error + I*errorSum + D*errorDiff

    if control > max or control < min then
        errorSum = errorSumPre
        control = P*error + I*errorSum + D*errorDiff
    end
    return clamp(control, min, max), errorSum, error
end

function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end

errorPre = 0
errorSum = 0

function onTick()
    currentSpd = INN(1)*3.6
    seat = INN(2)
    targetSpd = INN(3)*seat
    P, I, D = INN(4), INN(5), INN(6)
    FFgain = INN(7)

    PIDEnable = seat > 0.01

    if PIDEnable then
        control, errorSum, errorPre = PID(P, I, D, targetSpd, currentSpd, errorSum, errorPre, -1, 1)
    else
        control, errorSum, errorPre = 0, 0, 0
    end
    control = clamp(seat*FFgain + control, 0, 1)

    OUN(1, control)
end