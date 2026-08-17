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