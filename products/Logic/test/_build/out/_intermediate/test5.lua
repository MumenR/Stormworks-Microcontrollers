
x = 1.42698639876

local t0 = os.clock()

function test(x)
    return x
end

-- 計測したい処理
for i = 1, 1000000 do
    y = test(x)
end

local t1 = os.clock()
print(t1 - t0)



local t0 = os.clock()

-- 計測したい処理
for i = 1, 1000000 do
    y = math.floor(x)
end

local t1 = os.clock()
print(t1 - t0)