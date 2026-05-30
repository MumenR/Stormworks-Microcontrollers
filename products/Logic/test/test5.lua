local t0 = os.clock()

-- 計測したい処理
for i = 1, 10000000 do
    x, y = i, i
end

local t1 = os.clock()
print(t1 - t0)


local t0 = os.clock()

-- 計測したい処理
for i = 1, 10000000 do
    x = i
    y = i
end

local t1 = os.clock()
print(t1 - t0)

