require("math.qt")

---@class coordinate
---@field [1] number
---@field [2] number
---@field [3] number

---@section local2World
---ローカル座標からワールド座標へ
function local2World(Lx, Ly, Lz, myWx, myWy, myWz, q)
    local x, y, z = TUP(mulQt(q, mulQt({Lx, Ly, Lz, 0}, {-q[1], -q[2], -q[3], q[4]})))
    return x + myWx, y + myWy, z + myWz
end
---@endsection

---@section world2Local
--ワールド座標からローカル座標へ
function world2Local(Wx, Wy, Wz, myWx, myWy, myWz, q)
    return TUP(mulQt({-q[1], -q[2], -q[3], q[4]}, mulQt({Wx - myWx, Wy - myWy, Wz - myWz, 0}, q)))
end
---@endsection

---@section rect2Polar
--ローカル座標からローカル極座標へ変換(return pitch, yaw)
function rect2Polar(x, y, z, radian_bool)
    local pitch, yaw
    pitch = math.atan(z, math.sqrt(x*x + y*y))
    yaw = math.atan(x, y)
    if radian_bool then
        return pitch, yaw
    else
        return pitch/pi2, yaw/pi2
    end
end
---@endsection

---@section polar2Rect
--極座標から直交座標へ変換(Z軸優先)
function polar2Rect(pitch, yaw, distance, radian_bool)
    local x, y, z
    if not radian_bool then
        pitch = pitch*pi2
        yaw = yaw*pi2
    end
    x = distance*math.cos(pitch)*math.sin(yaw)
    y = distance*math.cos(pitch)*math.cos(yaw)
    z = distance*math.sin(pitch)
    return x, y, z
end
---@endsection