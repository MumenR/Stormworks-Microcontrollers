INN = input.getNumber
pi2 = math.pi*2

--ローカル座標からワールド座標へ変換(physics sensor使用)
function local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
    local RetX, RetY, RetZ
    RetX = math.cos(Ez)*math.cos(Ey)*Lx + (math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex))*Lz + (math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex))*Ly
    RetY = math.sin(Ez)*math.cos(Ey)*Lx + (math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex))*Lz + (math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex))*Ly
    RetZ = -math.sin(Ey)*Lx + math.cos(Ey)*math.sin(Ex)*Lz + math.cos(Ey)*math.cos(Ex)*Ly
    return RetX + Px, RetZ + Pz, RetY + Py
end

--ワールド座標からローカル座標へ(physics sensor使用)
function world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
    local a, b, c, d, e, f, g, h, i, j, k, l, x, z, y, Lower
    Wx = Wx - Px
    Wy = Wy - Pz
    Wz = Wz - Py
    a = math.cos(Ez)*math.cos(Ey)
    b = math.cos(Ez)*math.sin(Ey)*math.sin(Ex) - math.sin(Ez)*math.cos(Ex)
    c = math.cos(Ez)*math.sin(Ey)*math.cos(Ex) + math.sin(Ez)*math.sin(Ex)
    d = Wx
    e = math.sin(Ez)*math.cos(Ey)
    f = math.sin(Ez)*math.sin(Ey)*math.sin(Ex) + math.cos(Ez)*math.cos(Ex)
    g = math.sin(Ez)*math.sin(Ey)*math.cos(Ex) - math.cos(Ez)*math.sin(Ex)
    h = Wz
    i = -math.sin(Ey)
    j = math.cos(Ey)*math.sin(Ex)
    k = math.cos(Ey)*math.cos(Ex)
    l = Wy
    Lower = ((a*f-b*e)*k + (c*e - a*g)*j + (b*g - c*f)*i)
    x = 0
    y = 0
    z = 0
    if Lower ~= 0 then
        x = ((b*g - c*f)*l + (d*f - b*h)*k + (c*h - d*g)*j)/Lower
        y = -((a*g - c*e)*l + (d*e - a*h)*k + (c*h - d*g)*i)/Lower
        z = ((a*f - b*e)*l + (d*e - a*h)*j + (b*h - d*f)*i)/Lower
    end
    return x, z, y
end

--ローカル座標からディスプレイ座標へ変換
fovH = (58/360)*pi2    --HMDの視野角(縦)
function local2Display(Lx, Ly, Lz)
    local Dx, Dy, drawable
    Dx = w/2 + (Lx/Ly)*(h/2)/math.tan(fovH/2)
    Dy = h/2 - (Lz/Ly)*(h/2)/math.tan(fovH/2)
    drawable = Ly > 0
    return Dx, Dy, drawable
end

--極座標から直交座標へ変換
function polar2Rect(distance, yaw, pitch)
    local x, y, z
    x = distance*math.cos(pitch)*math.sin(yaw)
    y = distance*math.cos(pitch)*math.cos(yaw)
    z = distance*math.sin(pitch)
    return x, y, z
end

function onTick()
    --Physics sensor情報
    Ex, Ey, Ez = INN(4), INN(5), INN(6)

    --座席情報
    seatX = INN(9)*pi2
    seatY = -INN(10)*pi2
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(0, 255, 0)

    --ワイヤフレーム描画(15度間隔)
    for i = 0, 345, 15 do
        for j = -90, 75, 15 do

            --緯線
            --元となるワイヤフレームローカル座標
            Wx1, Wy1, Wz1 = polar2Rect(2, pi2*j/360, pi2*i/360)         --始点
            Wx2, Wy2, Wz2 = polar2Rect(2, pi2*(j + 15)/360, pi2*i/360)  --終点
            --ローカル座標へ変換
            Lx1, Ly1, Lz1 = world2Local(Wx1, Wy1, Wz1, -5, 0, 0, Ex, Ey, Ez)
            Lx2, Ly2, Lz2 = world2Local(Wx2, Wy2, Wz2, -5, 0, 0, Ex, Ey, Ez)
            --視線方向を反映
            Lx1, Ly1, Lz1 = world2Local(Lx1, Ly1, Lz1, 0, 0, 0, seatY, seatX, 0)
            Lx2, Ly2, Lz2 = world2Local(Lx2, Ly2, Lz2, 0, 0, 0, seatY, seatX, 0)
            --ディスプレイ座標へ変換
            Dx1, Dy1, drawable1 = local2Display(Lx1, Ly1, Lz1)
            Dx2, Dy2, drawable2 = local2Display(Lx2, Ly2, Lz2)
            --描画
            if drawable1 and drawable2 then
               screen.drawLine(Dx1, Dy1, Dx2, Dy2)
            end

            --経線
            --元となるワイヤフレームローカル座標
            Wx1, Wy1, Wz1 = polar2Rect(2, pi2*j/360, pi2*i/360)         --始点
            Wx2, Wy2, Wz2 = polar2Rect(2, pi2*j/360, pi2*(i + 15)/360)  --終点
            --ローカル座標へ変換
            Lx1, Ly1, Lz1 = world2Local(Wx1, Wy1, Wz1, -5, 0, 0, Ex, Ey, Ez)
            Lx2, Ly2, Lz2 = world2Local(Wx2, Wy2, Wz2, -5, 0, 0, Ex, Ey, Ez)
            --視線方向を反映
            Lx1, Ly1, Lz1 = world2Local(Lx1, Ly1, Lz1, 0, 0, 0, seatY, seatX, 0)
            Lx2, Ly2, Lz2 = world2Local(Lx2, Ly2, Lz2, 0, 0, 0, seatY, seatX, 0)
            --ディスプレイ座標へ変換
            Dx1, Dy1, drawable1 = local2Display(Lx1, Ly1, Lz1)
            Dx2, Dy2, drawable2 = local2Display(Lx2, Ly2, Lz2)
            --描画
            if drawable1 and drawable2 then
               screen.drawLine(Dx1, Dy1, Dx2, Dy2)
            end
        end
    end
end