x = {1, 2, 3, 4, 5, 6}
a, b, c, d, e, f = 1, 2, 3, 4, 5, 6

local t0 = os.clock()

function test(x)
    return x
end

-- 計測したい処理
for i = 1, 1000000 do
    x[1] = i
    x[2] = i
    x[3] = i
    x[4] = i
    x[5] = i
    x[6] = i
end

local t1 = os.clock()
print(t1 - t0)



local t0 = os.clock()

-- 計測したい処理
for i = 1, 1000000 do
    a, b, c, d, e, f = i, i, i, i, i, i
end

local t1 = os.clock()
print(t1 - t0)