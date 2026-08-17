require("math.qt")
require("required")

---@class coordinate
---@field [1] number
---@field [2] number
---@field [3] number

---@section local2World
---ローカル座標からワールド座標へ
---@param Lxyz coordinate
---@param pos coordinate
---@param q quaternion
function local2World(Lxyz, pos, q)
    local x, y, z = TUP(mulQt(q, mulQt({Lxyz[1], Lxyz[2], Lxyz[3], 0}, {-q[1], -q[2], -q[3], q[4]})))
    return {x + pos[1], y + pos[2], z + pos[3]}
end
---@endsection

---@section world2Local
---ワールド座標からローカル座標へ
---@param Wxyz coordinate ワールド座標のテーブル
---@param pos coordinate 自分の座標のテーブル
---@param q quaternion 自分のクォータニオンのテーブル
---@return coordinate xyz ローカル座標のテーブル
function world2Local(Wxyz, pos, q)
    local x, y, z = TUP(mulQt({-q[1], -q[2], -q[3], q[4]}, mulQt({Wxyz[1] - pos[1], Wxyz[2] - pos[2], Wxyz[3] - pos[3], 0}, q)))
    return {x, y, z}
end
---@endsection

---@section rect2Polar
---直交座標から極座標へ
---@param xyz coordinate 直交座標のテーブル
---@param radianBool boolean trueならラジアン、falseなら0~1の範囲
---@return number pitch ピッチ角
---@return number yaw ヨー角
function rect2Polar(xyz, radianBool)
    local x, y, z = TUP(xyz)
    local pitch, yaw = math.atan(z, math.sqrt(x*x + y*y)), math.atan(x, y)
    if radianBool then
        return pitch, yaw
    else
        return pitch/pi2, yaw/pi2
    end
end
---@endsection

---@section polar2Rect
---極座標から直交座標へ変換(ヨー→ピッチ順)
---@param pitch number ピッチ角
---@param yaw number ヨー角
---@param distance number 距離
---@param radianBool boolean trueならラジアン、falseなら0~1
---@return coordinate xyz 直交座標のテーブル
function polar2Rect(pitch, yaw, distance, radianBool)
    if not radianBool then
        pitch = pitch*pi2
        yaw = yaw*pi2
    end
    return {distance*math.cos(pitch)*math.sin(yaw), distance*math.cos(pitch)*math.cos(yaw), distance*math.sin(pitch)}
end
---@endsection

---@section polarX2Rect
---極座標から直交座標へ変換(ピッチ→ヨー順)
---@param pitch number ピッチ角
---@param yaw number ヨー角
---@param distance number 距離
---@param radianBool boolean trueならラジアン、falseなら0~1
---@return coordinate xyz 直交座標のテーブル
function polarX2Rect(pitch, yaw, distance, radianBool)
    if not radianBool then
        pitch = pitch*math.pi*2
        yaw = yaw*math.pi*2
    end
    return {distance*math.sin(yaw), distance*math.cos(yaw)*math.cos(pitch), distance*math.cos(yaw)*math.sin(pitch)}
end
---@endsection

---@section offset
---カンマ区切り3つの文字列を数字に変換し、オフセット
---@param PRTName string オフセット取得用プロパティ名
---@param Wxyz coordinate ワールド座標
---@param Qt quaternion クォータニオン
---@return coordinate xyz xyz座標のテーブル
function offset(PRTName, Wxyz, Qt)
    local offsetX, offsetY, offsetZ = string.match(PRT(PRTName), "([^,]+),([^,]+),([^,]+)")
    return local2World({tonumber(offsetX), tonumber(offsetY), tonumber(offsetZ)}, Wxyz, Qt)
end
---@endsection