PRECISION = 0.1     --valueの最小保証精度
NBITS = 24          --valueに割り当てるビット数
function encode(id, value)
	value = math.floor(value / PRECISION + 0.5)
	if value < 0 then
		value = value + 1 << NBITS
	end
	value = value | id << NBITS
	id = (id >> (24 - NBITS)) + 66
	if id >= 127 then
		id = id + 67
	end
	local x = ('f'):unpack(('I3B'):pack(value & 16777215, id & 255))
	return x
end

function decode(x)
	local value, id = ('I3B'):unpack(('f'):pack(x))
	if id >> 7 & 1 ~= 0 then
		id = id - 67
	end
	id = (id - 66) << (24 - NBITS) | (value >> NBITS)
	value = value & ((1 << NBITS) - 1)
	if value >> (NBITS - 1) & 1 ~= 0 then
		value = value - (1 << NBITS)
	end
	return id, value * PRECISION
end

ID = 99
coord = 305648.165462

pack = encode(ID, coord)

print(decode(pack))