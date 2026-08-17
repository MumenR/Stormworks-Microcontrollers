require("math.coordTrans")
require("math.vector")
require("required")

---@section stabilizer2
---2軸スタビライザー(2軸スタビ)
---@param pos coordinate 自身のワールド位置[m]
---@param Qt quaternion 自身の姿勢[クォータニオン]
---@param Vxyz coordinate 自身のローカル速度[m/tick]
---@param Rvxyz coordinate 自身のワールド角速度[rad/tick]
---@param Txyz coordinate ターゲットワールド位置[m]
---@param Tvxyz coordinate ターゲットワールド速度[m/tick]
---@param DELAY number 予測する時間[tick]
---@return number pitch [回転]
---@return number yaw [回転]
--Prv[rad/tick], Tはターゲット位置と速度, 2軸スタビ
function stabilizer2(pos, Qt, Vxyz, Rvxyz, Txyz, Tvxyz, DELAY)
    local TLxyz, TLvxyz, Lrvxyz, RelativeV, losV
    --ローカル座標
    TLxyz = world2Local(Txyz, pos, Qt)
    TLvxyz = world2Local(Tvxyz, ZERO3, Qt)
    Lrvxyz = world2Local(Rvxyz, ZERO3, Qt)
    --相対速度
    RelativeV = vecSub1(TLvxyz, Vxyz)
    --視線角速度
    losV = vecMulScalar1(vecCross(TLxyz, RelativeV), 1/vecDist(TLxyz, ZERO3)^2)
    --自身の角速度と合成
    losV = vecSub1(losV, Lrvxyz)
    --未来位置を極座標で返す
    return rect2Polar(rotateRv(TLxyz, losV, DELAY), false)
end
---@endsection