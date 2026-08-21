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
---@section ZERO3
ZERO3 = {0, 0, 0}
---@endsection

---@section copyTable
---@param x any コピー元のテーブル
---@return any copy コピーしたテーブル
function copyTable(x)
    return {TUP(x)}
end
---@endsection