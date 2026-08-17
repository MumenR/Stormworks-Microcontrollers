require("math.coordTrans")

---@class coordinate3
---@field x number x座標
---@field y number y座標
---@field z number z座標
---@field vx number x方向速度
---@field vy number y方向速度
---@field vz number z方向速度
---@field ax number x方向加速度
---@field ay number y方向加速度
---@field az number z方向加速度


---@class gain
---@field alpha number αゲイン
---@field beta number βゲイン
---@field gamma number γゲイン

---@section ABGFUpdate
---α-β-γフィルタ(z: 観測値, x:状態量, gain: α-β-γフィルタのゲイン, N: 同時観測数)
---@param z coordinate3 観測値
---@param x coordinate3 状態量
---@param gain gain α-β-γフィルタのゲイン
---@param N number 同時観測数
---@return coordinate3 x 更新後の状態量
function ABGFUpdate(z, x, gain, N)
    gainN = 2*N/(N + 1) --サンプル数により信頼度を上げる
    for i = 1, 3 do
        local residual = z[i] - x[i]
        --更新
        for j = 0, 6, 3 do
            x[i + j] = x[i + j] + gain[j//3 + 1]*gainN*residual
        end
    end
    return x
end
---@endsection

---@section ABGFPredict
---α-β-γフィルタの予測(x:状態量)
---@param x coordinate3 状態量
---@return coordinate3 x 更新後の状態量
function ABGFPredict(x)
    for i = 1, 3 do
        x[i] = x[i] + x[i + 3] + x[i + 6]/2
        x[i + 3] = x[i + 3] + x[i + 6]
    end
    return x
end
---@endsection
