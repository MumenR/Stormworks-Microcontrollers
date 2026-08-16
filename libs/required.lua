require("math.coordTrans")

---@section INN
INN = input.getNumber
---@endsection
---@section INB
INB = input.getBool
---@endsection
---@section OUN
OUN = output.setNumber
---@endsection
---@section OUB
OUB = output.setBool
---@endsection
---@section PRN
PRN = property.getNumber
---@endsection
---@section PRB
PRB = property.getBool
---@endsection
---@section PRT
PRT = property.getText
---@endsection
---@section TUP
TUP = table.unpack
---@endsection
---@section pi2
pi2 = math.pi*2
---@endsection

---@section offset
--カンマ区切り3つの文字列を数字に変換し、オフセット
---@param PRTName string オフセット取得用プロパティ名
---@param Wx number ワールドX座標
---@param Wy number ワールドY座標
---@param Wz number ワールドZ座標
---@param Qt quaternion テーブル
---@return coordinate xyz xyz座標のテーブル
function offset(PRTName, Wx, Wy, Wz, Qt)
    local offsetX, offsetY, offsetZ = string.match(PRT(PRTName), "([^,]+),([^,]+),([^,]+)")
    return {local2World(tonumber(offsetX), tonumber(offsetY), tonumber(offsetZ), Wx, Wy, Wz, Qt)}
end
---@endsection
