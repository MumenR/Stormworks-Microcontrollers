---@section clamp
---数値をminとmaxの範囲に収める
---@param x number 対象の数値
---@param min number 最小値
---@param max number 最大値
---@return number answer minとmaxの範囲に収めた数値
function clamp(x, min, max)
    if x >= max then
        x = max
    elseif x <= min then
        x = min
    end
    return x
end
---@endsection

---@section clamp2
---数値をminとmaxの範囲に収める(文字数は少ないが重い)
---@param x number 対象の数値
---@param min number 最小値
---@param max number 最大値
---@return number answer minとmaxの範囲に収めた数値
function clamp2(x, min, max)
    return math.max(min, math.min(max, x))
end
---@endsection

---@section sameRotation
---@param x number 回転角度
---@return number answer 回転角度(-0.5~0.5)
function sameRotation(x)
    return (x + 0.5)%1 - 0.5
end
---@endsection