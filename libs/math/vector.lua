require("required")

---@section vecAdd1
---1次元ベクトル同士の和
---@param x number[] ベクトル1
---@param y number[] ベクトル2
---@return number[] sum ベクトル同士の和
function vecAdd1(x, y)
    local sum = {}
    for i = 1, #x do
        sum[i] = x[i] + y[i]
    end
    return sum
end
---@endsection

---@section vecSub1
---1次元ベクトル同士の差
---@param x number[] ベクトル1
---@param y number[] ベクトル2
---@return number[] diff ベクトル同士の差
function vecSub1(x, y)
    local diff = {}
    for i = 1, #x do
        diff[i] = x[i] - y[i]
    end
    return diff
end
---@endsection

---@section vecMulScalar1
---1次元ベクトルとスカラーの積
---@param v number[] ベクトル
---@param s number スカラー
---@return number[] product ベクトルとスカラーの積
function vecMulScalar1(v, s)
    local product = {}
    for i = 1, #v do
        product[i] = v[i]*s
    end
    return product
end
---@endsection

---@section vecDot1
---1次元ベクトル同士の内積
---@param x number[] ベクトル1
---@param y number[] ベクトル2
---@return number dot 内積
function vecDot1(x, y)
    local dot = 0
    for i = 1, #x do
        dot = dot + x[i]*y[i]
    end
    return dot
end
---@endsection

---@section vecDist
---ベクトル同士の距離
---@param x number[] ベクトル1
---@param y number[] ベクトル2
---@return number distance ベクトル同士の距離
function vecDist(x, y)
    local sum = 0
    for i = 1, #x do
        sum = sum + (x[i] - y[i])^2
    end
    return math.sqrt(sum)
end
---@endsection

---@section vecNormShort
---２つのベクトルから法線ベクトルを算出(cが基準、依存なし)
---@param a number[] ベクトル1
---@param b number[] ベクトル2
---@param c number[] 基準ベクトル
---@return number[] normal 法線ベクトル(zが正の単位ベクトル)
function vecNormShort(a, b, c)
    c1, c2, c3 = TUP(c)
    a1, a2, a3 = a[1] - c1, a[2] - c2, a[3] - c3
    b1, b2, b3 = b[1] - c1, b[2] - c2, b[3] - c3
    local nom = {
        a2*b3 - a3*b2,
        a3*b1 - a1*b3,
        a1*b2 - a2*b1
    }
    a1, a2, a3 = TUP(nom)
    --正規化
    b1 = math.sqrt(a1*a1 + a2*a2 + a3*a3)
    if b1 > 0 then
        nom = {a1/b1, a2/b1, a3/b1}
    end
    --上下逆なら反転
    if a3 < 0 then
        nom = {-nom[1], -nom[2], -nom[3]}
    end
    return nom
end
---@endsection

---@section vecNorm
---２つのベクトルから法線ベクトルを算出(cが基準、依存あり)
---@param a number[] ベクトル1
---@param b number[] ベクトル2
---@param c number[] 基準ベクトル
---@return number[] normal 法線ベクトル(zが正の単位ベクトル)
function vecNorm(a, b, c)
    local nom = vecCross(vecSub1(a, c), vecSub1(b, c))
    a1, a2, a3 = TUP(nom)
    --正規化
    b1 = math.sqrt(a1*a1 + a2*a2 + a3*a3)
    if b1 > 0 then
        nom = {a1/b1, a2/b1, a3/b1}
    end
    --上下逆なら反転
    if a3 < 0 then
        nom = {-nom[1], -nom[2], -nom[3]}
    end
    return nom
end
---@endsection

---@section vecCross
---ベクトルの外積を計算
---@param a number[] ベクトル1
---@param b number[] ベクトル2
---@return number[] cross 外積ベクトル
function vecCross(a, b)
    a1, a2, a3 = TUP(a)
    b1, b2, b3 = TUP(b)
    return {
        a2*b3 - a3*b2,
        a3*b1 - a1*b3,
        a1*b2 - a2*b1
    }
end
---@endsection