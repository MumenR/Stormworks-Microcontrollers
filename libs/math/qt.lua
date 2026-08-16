--姿勢の球面補間(q1からq2へtの割合)
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