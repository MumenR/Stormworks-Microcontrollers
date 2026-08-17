require("required")

---共通の定数を定義
---@param fovH number 垂直方向視野角(ラジアン)
function setParam(fovH)
    w, h = screen.getWidth(), screen.getHeight()
    FOV_H = fovH
end

---@section canDraw
---描画可能判定
---@param x number ディスプレイX座標
---@param y number ディスプレイY座標
---@return boolean drawable 描画可能かどうか
function canDraw(x, y)
    return x >= 0 and x <= w and y >= 0 and y <= h
end
---@endsection

---@section local2Display
---HMDローカル座標→ディスプレイ座標
---@param Lxyz coordinate ローカル座標のテーブル
---@return number x ディスプレイX座標
---@return number y ディスプレイY座標
---@return boolean forward ディスプレイの前方である
---@return boolean drawable 描画可能かどうか
function local2Display(Lxyz)
    local Dx, Dy = w/2 + (Lxyz[1]/Lxyz[2])*(h/2)/math.tan(FOV_H/2), h/2 - (Lxyz[3]/Lxyz[2])*(h/2)/math.tan(FOV_H/2)
    return Dx, Dy, Lxyz[2] > 0, canDraw(Dx, Dy)
end
---@endsection

---@section localRect2Display
---座席ローカル座標→HMDローカル座標→ディスプレイ座標
---@param Lxyz coordinate ローカル直交座標のテーブル
---@param eyeQt quaternion 視点の回転クォータニオン
---@return number x ディスプレイX座標
---@return number y ディスプレイY座標
---@return boolean forward ディスプレイの前方である
---@return boolean drawable 描画可能かどうか
function localRect2Display(Lxyz, eyeQt)
    return local2Display(world2Local(Lxyz, ZERO3, eyeQt))
end
---@endsection

---@section worldRect2Display
---ワールド座標→座席ローカル座標→HMDローカル座標→ディスプレイ座標
---@param Wxyz coordinate ワールド直交座標のテーブル
---@param seatQt quaternion 座席の回転クォータニオン
---@param eyeQt quaternion 視点の回転クォータニオン
---@return number x ディスプレイX座標
---@return number y ディスプレイY座標
---@return boolean forward ディスプレイの前方である
---@return boolean drawable 描画可能かどうか
function worldRect2Display(Wxyz, seatQt, eyeQt)
    return local2Display(world2Local(world2Local(Wxyz, ZERO3, seatQt), ZERO3, eyeQt))
end
---@endsection

---@section worldPolar2Display
---ワールド極座標→任意回転→座席ローカル座標→HMDローカル座標→ディスプレイ座標
---@param pitch number ワールド極座標のピッチ角(回転)
---@param yaw number ワールド極座標のヨー角(回転)
---@param optionQt quaternion ワールド極座標のオプション回転用クォータニオン
---@param seatQt quaternion 座席の回転クォータニオン
---@param eyeQt quaternion 視点の回転クォータニオン
---@return number x ディスプレイX座標
---@return number y ディスプレイY座標
---@return boolean forward ディスプレイの前方である
---@return boolean drawable 描画可能かどうか
function worldPolar2Display(pitch, yaw, optionQt, seatQt, eyeQt)
    return worldRect2Display(world2Local(polar2Rect(pitch, yaw, 1, false), ZERO3, optionQt), seatQt, eyeQt)
end
---@endsection