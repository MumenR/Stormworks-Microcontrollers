x = 1126.42698639876
X = {x}

local t0 = os.clock()

-- 計測したい処理
for i = 1, 10000000 do
    y = X[1]
end

local t1 = os.clock()
print(t1 - t0)



local t0 = os.clock()

-- 計測したい処理
for i = 1, 10000000 do
    y = {x}
end

local t1 = os.clock()
print(t1 - t0)