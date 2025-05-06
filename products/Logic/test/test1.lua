function distance3(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

data_new = {
    {x = 100, y = 100, z = 100, d = 1000, id = 1},
    {x = 230, y = 100, z = 100, d = 1000, id = 2},
    {x = 90, y = 100, z = 100, d = 1000, id = 3},
    {x = 230, y = 100, z = 100, d = 1000, id = 4},
    {x = 210, y = 100, z = 100, d = 1000, id = 5},
    {x = 120, y = 100, z = 100, d = 1000, id = 6},
    {x = 200, y = 100, z = 100, d = 1000, id = 7},
    {x = 110, y = 100, z = 100, d = 1000, id = 8},
}


for i = 1, #data_new do
    local A, B, same_data, error_range, sum_x, sum_y, sum_z, j
    A = data_new[i]
    if A == nil then
        break
    end
    error_range = 0.05*A.d
    same_data = {A}
    --距離を判定される側の探索
    j = i + 1
    while j <= #data_new do
        B = data_new[j]
        --規定値以下なら仮テーブルに追加し、元テーブルから削除
        if distance3(A.x, A.y, A.z, B.x, B.y, B.z) < error_range then
            table.insert(same_data, B)
            table.remove(data_new, j)
        else
            j = j + 1
        end
    end
    --仮テーブルから平均値を計算して値を更新
    --ついでにd→tへと定義を変更
    sum_x, sum_y, sum_z = 0, 0, 0
    for _, C in pairs(same_data) do
        sum_x = sum_x + C.x
        sum_y = sum_y + C.y
        sum_z = sum_z + C.z
    end
    data_new[i] = {
        x = sum_x/#same_data,
        y = sum_y/#same_data,
        z = sum_z/#same_data,
        t = 0
    }
end

for i = 1, #data_new do
    local A = data_new[i]
    print(A.x, A.y, A.z, A.t)
end