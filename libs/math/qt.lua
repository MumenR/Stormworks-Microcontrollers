---@class quaternion
---@field [1] number
---@field [2] number
---@field [3] number
---@field [4] number

---@section euler2Qt
---左手系でXYZ順オイラー角から右手系クォータニオンへ変換
---@param LEx number 左手系Xオイラー角
---@param LEy number 左手系Yオイラー角
---@param LEz number 左手系Zオイラー角
---@return quaternion Qt 姿勢クォータニオン
function euler2Qt(LEx, LEy, LEz)
    return mulQt({0, math.sin(-LEz/2), 0, math.cos(-LEz/2)}, mulQt({0, 0, math.sin(-LEy/2), math.cos(-LEy/2)}, {math.sin(-LEx/2), 0, 0, math.cos(-LEx/2)}))
end
---@endsection

---@section mulQt
---クォータニオンの掛け算(q:回転, p: 姿勢)
---@param q quaternion 回転クォータニオン
---@param p quaternion 姿勢クォータニオン
---@return quaternion Qt 結果のクォータニオン
function mulQt(q, p)
    local a, b, c, d = TUP(q)
    local x, y, z, w = TUP(p)
    return {
        d*x - c*y + b*z + a*w,
        c*x + d*y - a*z + b*w,
        -b*x + a*y + d*z + c*w,
        -a*x - b*y - c*z + d*w
    }
end
---@endsection

---@section slerp
---姿勢の球面補間(q1からq2へtの割合)
---@param q1 quaternion 姿勢クォータニオン1
---@param q2 quaternion 姿勢クォータニオン2
---@param t number 補間係数 (0 から 1)
---@return quaternion Qt 結果のクォータニオン
function slerp(q1, q2, t)
    local dot, theta, e, f
    local a, b, c, d = table.unpack(q1)
    local x, y, z, w = table.unpack(q2)
    dot = a*x + b*y + c*z + d*w     --内積
    if dot < 0 then                 --遠回り回転なら逆へ回転させる
        dot, x, y, z, w = -dot, -x, -y, -z, -w
    end
    theta = math.acos(dot)          --必要回転角度
    if theta > 0.0001 then          --０除算対策
        e = math.sin((1 - t)*theta)/math.sin(theta)
        f = math.sin(t*theta)/math.sin(theta)
    else
        e, f = (1 - t), t
    end
    x = e*a + f*x
    y = e*b + f*y
    z = e*c + f*z
    w = e*d + f*w
    e = math.sqrt(x*x + y*y + z*z + w*w)    --正規化
    return {x/e, y/e, z/e, w/e}
end
---@endsection