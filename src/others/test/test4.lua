INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool
PRN = property.getNumber
PRB = property.getBool
pi2 = math.pi*2

--積(A*B)
function mul(A, B, C, sum)
    C = {}
    for i = 1, #A do
        C[i] = {}
        for j = 1, #B[1] do
            sum = 0
            for k = 1, #A[1] do
                sum = sum + A[i][k]*B[k][j]
            end
            C[i][j] = sum
        end
    end
    return C
end

function R(Ex, Ey, Ez)
    local a, b, c, d, e, f = math.cos(Ex), math.sin(Ex), math.cos(Ey), math.sin(Ey), math.cos(Ez), math.sin(Ez)
    return {
        {e*c,   e*d*a + f*b,    e*d*b - f*a},
        {-d,    c*a,            c*b},
        {f*c,   f*d*a - e*b,    f*d*b + e*a}
    }
end

--ローカル座標からワールド座標へ変換(Physics sensor使用)
function local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
    local W = mul(R(Ex, Ey, Ez), {{Lx}, {Ly}, {Lz}})
    return W[1][1] + Px, W[2][1] + Pz, W[3][1] + Py
end

--ワールド座標からローカル座標へ変換(Physics sensor使用)
function world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
    local L = mul({{Wx - Px, Wy - Pz, Wz - Py}}, R(Ex, Ey, Ez))
    return L[1][1], L[1][2], L[1][3]
end

--未来位置予測(return: x, y, z, vx, vy, vz)
function predictTRD1(t, x, y, z, vx, vy, vz, ax, ay, az)
    return ax*t*t/2 + vx*t + x, ay*t*t/2 + vy*t + y, az*t*t/2 + vz*t + z, ax*t + vx, ay*t + vy, az*t + vz
end

function onTick()
    Px, Py, Pz = INN(1), INN(2), INN(3)
    Ex, Ey, Ez = INN(4), INN(5), INN(6)
    Pvx, Pvy, Pvz = INN(7)/60, INN(8)/60, INN(9)/60

    Wx, Wy, Wz = Px, Pz, Py
    Vx, Vy, Vz = local2World(Pvx, Pvz, Pvy, 0, 0, 0, Ex, Ey, Ez)

    Wx, Wy, Wz = predictTRD1(3, Wx, Wy, Wz, Vx, Vy, Vz, 0, 0, 0)

    OUB(1, true)

    OUN(1, Wx)
    OUN(2, Wy)
    OUN(3, Wz)
    OUN(4, Vx)
    OUN(5, Vy)
    OUN(6, Vz)
end