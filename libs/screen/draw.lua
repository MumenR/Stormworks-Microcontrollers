require("screen.coordTrans")
require("math.math")

---@section green
function green()
    screen.setColor(0, 255, 0)
end
---@endsection
---@section black
function black()
    screen.setColor(0, 0, 0)
end
---@endsection

---@section drawDottedLine
---点線
---@param x1 number 始点のディスプレイX座標
---@param y1 number 始点のディスプレイY座標
---@param x2 number 終点のディスプレイX座標
---@param y2 number 終点のディスプレイY座標
function drawDottedLine(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx*dx + dy*dy)
    if len <= 0 then
        return
    end

    dx, dy = dx/len, dy/len
    for i = 0, len, 4 do
        local sx, sy = x1 + dx*i, y1 + dy*i
        local ex, ey = x1 + dx*math.min(i + 2, len), y1 + dy*math.min(i + 2, len)
        if canDraw(sx, sy) or canDraw(ex, ey) then
            screen.drawLine(sx, sy, ex, ey)
        end
    end
end
---@endsection

---@section drawTrueCircle
---真円の描画
---@param x number 中心のディスプレイX座標
---@param y number ディスプレイY座標
---@param r number 円の半径
function drawTrueCircle(x, y, r)
    local step = 10/360*pi2
    for i = 0, pi2 - step, step do
        local x1, y1, x2, y2
        x1 = x + r*math.cos(i)
        y1 = y + r*math.sin(i)
        x2 = x + r*math.cos(i + step)
        y2 = y + r*math.sin(i + step)
        screen.drawLine(x1, y1, x2, y2)
    end
end
---@endsection

---@section
---点円
---@param x number 中心のディスプレイX座標
---@param y number 中心のディスプレイY座標
---@param r number 円の半径
function drawDottedCircle(x, y, r)
    local stepRad = math.atan(1, r)
    for i = 0, pi2, stepRad*2 do
        local x1, y1, x2, y2
        x1 = x + r*math.cos(i)
        y1 = y + r*math.sin(i)
        x2 = x + r*math.cos(i + stepRad)
        y2 = y + r*math.sin(i + stepRad)
        screen.drawLine(x1, y1, x2, y2)
    end
end
---@endsection

---@section drawDottedRect
---点矩形
---@param x number 始点のディスプレイX座標
---@param y number 始点のディスプレイY座標
---@param w number 矩形の幅
---@param h number 矩形の高さ
function drawDottedRect(x, y, w, h)
    drawDottedLine(x, y, x, y + h + 2)
    drawDottedLine(x, y, x + w + 2, y)
    drawDottedLine(x + w, y + h, x, y + h)
    drawDottedLine(x + w, y + h, x + w, y)
end
---@endsection

---@section drawDottedTriangle
---点三角
---@param x1 number 頂点１のディスプレイX座標
---@param y1 number 頂点１のディスプレイY座標
---@param x2 number 頂点２のディスプレイX座標
---@param y2 number 頂点２のディスプレイY座標
---@param x3 number 頂点３のディスプレイX座標
---@param y3 number 頂点３のディスプレイY座標
function drawDottedTriangle(x1, y1, x2, y2, x3, y3)
    drawDottedLine(x1, y1, x2, y2)
    drawDottedLine(x2, y2, x3, y3)
    drawDottedLine(x3, y3, x1, y1)
end
---@endsection
