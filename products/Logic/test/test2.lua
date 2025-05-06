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

for _, value in pairs(data_new) do
    print(value.x, value.y, value.z, value.d, value.id)
end

print()

for _, value in pairs(data_new) do
    data_new[_].x = nil
    print(value.x, value.y, value.z, value.d, value.id)
end