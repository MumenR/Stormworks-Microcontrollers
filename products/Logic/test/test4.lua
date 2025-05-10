--ID生成
function nextID()
    local ID, same = 1, true
    while same do
        same = false
        for i = 1, #data do
            same = ID == data[i].id
            if same then
                ID = ID + 1
                break
            end
        end
    end
    return ID
end

function show_data()
    for ID, DATA in pairs(data) do
        print(ID)
        for i = 1, #DATA.position do
            X = DATA.position[i]
            print(X.x, X.y, X.z, X.t, X.id, X.d)
        end
        print("--------------------")
    end
    print("------------------------------")
end

--三次元距離
function distance3(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

data_new = {
    {x = 540, y = 0, z = 0, d = 540, t = 0, id = 11},
    {x = 140, y = 0, z = 0, d = 140, t = 0, id = 22},
    {x = 1000, y = 0, z = 0, d = 1000, t = 0, id = 33},
}

data = {
    [1] = {
        position = {
            {x = 130, y = 0, z = 0, t = -1},
            {x = 120, y = 0, z = 0, t = -2},
            {x = 110, y = 0, z = 0, t = -3},
            {x = 100, y = 0, z = 0, t = -4},
        },
        predict = {
            x = {a = 10, b = 130, est = 0},
            y = {a = 0, b = 0, est = 0},
            z = {a = 0, b = 0, est = 0},
        },
        id = 1,
        t_last = 1
    },
    [3] = {
        position = {
            {x = 230, y = 0, z = 0, t = -1},
            {x = 220, y = 0, z = 0, t = -2},
            {x = 210, y = 0, z = 0, t = -3},
            {x = 200, y = 0, z = 0, t = -4},
        },
        predict = {
            x = {a = 10, b = 230, est = 0},
            y = {a = 0, b = 0, est = 0},
            z = {a = 0, b = 0, est = 0},
        },
        id = 3,
        t_last = 1
    },
    [5] = {
        position = {
            {x = 530, y = 0, z = 0, t = -1},
            {x = 520, y = 0, z = 0, t = -2},
            {x = 510, y = 0, z = 0, t = -3},
            {x = 500, y = 0, z = 0, t = -4},
        },
        predict = {
            x = {a = 10, b = 530, est = 0},
            y = {a = 0, b = 0, est = 0},
            z = {a = 0, b = 0, est = 0},
        },
        id = 5,
        t_last = 1
    },
}

max_velocity = 300/60
max_accel = 100/3600

show_data()

--目標同定
for _, DATA in pairs(data) do
    local error, min_dist, min_i, x1, y1, z1, distance
    --最小距離データを探索
    min_dist = math.huge
    min_i = 0
    x1 = DATA.predict.x.a + DATA.predict.x.b
    y1 = DATA.predict.y.a + DATA.predict.y.b
    z1 = DATA.predict.z.a + DATA.predict.z.b
    for i, NEW in pairs(data_new) do
        distance = distance3(x1, y1, z1, NEW.x, NEW.y, NEW.z)
        if distance < min_dist then
            min_dist = distance
            min_i = i
        end
    end

    --許容誤差として最大移動ユークリッド距離を設定
    if #DATA.position <= 1 then
        error = max_velocity*DATA.t_last
    else
        error = max_accel*(DATA.t_last^2)/2
    end
    error = error + 0.01*data_new[min_i].d
    
    print("error:", error, "dist:", min_dist)

    --データ追加
    if min_dist < error then
        data_new[min_i].d = nil
        table.insert(DATA.position, data_new[min_i])
        table.remove(data_new, min_i)
    end
end

show_data()

--新規目標登録
for _, NEW in pairs(data_new) do
    local ID = nextID()
    data[ID] = {
        position = {NEW},
        predict = {x = {}, y = {}, z = {}},
        id = ID,
        t_last = 0
    }
end

show_data()