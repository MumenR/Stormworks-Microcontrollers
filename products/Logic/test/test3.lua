--時間経過処理
--[[
    data = {
        [ID] = {
            position = {
                {x = world X, y = world Y, z = world Z, t = tick},
                ...
            },
            id = data ID,
            t_last = last tick
        },
        ...
    }
]]

local start_time = os.clock()

t_max = 60

function show_data(data)
    for i = 1, #data do
        for j = 1, #data[i].position do
            A = data[i].position[j]
            print(A.x, A.y, A.z, A.t)
        end
        print(data[i].t_last, "---")
    end
    print("--------------------")
end

data = {
    [1] = {
        position = {
            {x = 100, y = 100, z = 100, t = -60},
            {x = 100, y = 100, z = 100, t = -40},
            {x = 100, y = 100, z = 100, t = -20},
            {x = 100, y = 100, z = 100, t = -0},
        },
        id = 1,
        t_last = 40
    },
    [2] = {
        position = {
            {x = 200, y = 100, z = 100, t = -80},
            {x = 200, y = 100, z = 100, t = -60},
            {x = 200, y = 100, z = 100, t = -40},
            {x = 200, y = 100, z = 100, t = -20},
        },
        id = 2,
        t_last = 60
    },
    [3] = {
        position = {
            {x = 300, y = 100, z = 100, t = -140},
            {x = 300, y = 100, z = 100, t = -120},
            {x = 300, y = 100, z = 100, t = -100},
            {x = 300, y = 100, z = 100, t = -80},
        },
        id = 1,
        t_last = 80
    },
}

show_data(data)

for ID, DATA in pairs(data) do
    --時間経過
    for _, POS in pairs(DATA.position) do
        POS.t = POS.t - 1
    end
    DATA.t_last = DATA.position[#DATA.position].t

    --データ削除
    if -DATA.t_last > t_max then
        data[ID] = nil
    else
        local i = 1
        while i <= #DATA.position do
            if -DATA.position[i].t > t_max then
                table.remove(DATA.position, i)
            else
                i = i + 1
            end
        end
    end
end

show_data(data)


local end_time = os.clock()
print(string.format("time: %.8f s", end_time - start_time))