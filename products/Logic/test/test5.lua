local t0 = os.clock()

-- 計測したい処理
for i = 1, 10000000 do
    y = i
end

local t1 = os.clock()
print(t1 - t0)



local t0 = os.clock()

-- 計測したい処理
function a(i)
    return i
end
for i = 1, 10000000 do
    y = a(i)
end

local t1 = os.clock()
print(t1 - t0)