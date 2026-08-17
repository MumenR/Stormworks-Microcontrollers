require("math.math")

---@section
---PID制御
---@param P number 比例ゲイン
---@param I number 積分ゲイン
---@param D number 微分ゲイン
---@param target number 目標値
---@param current number 現在値
---@param errorSumPre number 前回の誤差積分値
---@param errorPre number 前回の誤差値
---@param min number 制御量の最小値
---@param max number 制御量の最大値
---@return number control 制御量
---@return number errorSum 誤差積分値
---@return number error 誤差値
function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
    local error, errorSum, errorDiff, control
    error = target - current
    errorSum = math.abs(error) < 5/360 and errorSumPre + error or errorSumPre
    errorDiff = error - errorPre
    control = P*error + I*errorSum + D*errorDiff

    if control > max or control < min then
        errorSum = errorSumPre
        control = P*error + I*errorSum + D*errorDiff
    end
    return clamp2(control, min, max), errorSum, error
end
---@endsection