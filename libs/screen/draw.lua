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
---@param gapLen number 点線と隙間の長さ
function drawDottedLine(x1, y1, x2, y2, gapLen)
    local dx, dy, len, i, dashEnd, sx, sy, ex, ey
    dx, dy = x2 - x1, y2 - y1
    len = math.sqrt(dx*dx + dy*dy)
    if len <= 0 then
        return
    end

    dx, dy = dx/len, dy/len
    i = 0
    while i <= len do
        dashEnd = math.min(i + gapLen, len)
        sx, sy = x1 + dx*i, y1 + dy*i
        ex, ey = x1 + dx*dashEnd, y1 + dy*dashEnd
        if canDraw(sx, sy) or canDraw(ex, ey) then
            screen.drawLine(sx, sy, ex, ey)
        end
        i = i + gapLen*2
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
    local dashCount, stepRad, x1, y1, x2, y2
    dashCount = math.max(4, math.floor(math.pi*r/4 + 0.5)*4)
    stepRad = pi2/(dashCount*2)
    for i = 0, dashCount - 1 do
        x1 = x + r*math.cos(i*stepRad*2)
        y1 = y + r*math.sin(i*stepRad*2)
        x2 = x + r*math.cos(i*stepRad*2 + stepRad)
        y2 = y + r*math.sin(i*stepRad*2 + stepRad)
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
    drawDottedLine(x, y, x, y + h + 1, 1)
    drawDottedLine(x, y, x + w + 1, y, 1)
    drawDottedLine(x + w, y + h, x, y + h, 1)
    drawDottedLine(x + w, y + h, x + w, y, 1)
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
    drawDottedLine(x1, y1, x2, y2, 1)
    drawDottedLine(x2, y2, x3, y3, 1)
    drawDottedLine(x3, y3, x1, y1, 1)
end
---@endsection



---@section drawSRD3
---SRD3用のターゲットマーカー描画関数
---@param rawID number SRD3の生のID
---@param t number 描画開始からの経過時間
function drawSRD3(pixX, pixY, rawID, t)
    local shapeNo, colorNo, addStaticNo, addDynamicNo

    --各機能決定
    shapeNo = rawID//(10^3)%10
    colorNo = rawID//(10^4)%10
    addStaticNo = rawID//(10^5)%10
    addDynamicNo = rawID//(10^6)%10

    --動的追加機能
    if addDynamicNo == 1 and t%12 < 6 then      --点滅のため描画なし
        return
    elseif addDynamicNo == 2 and t%30 < 15 then --点滅のため描画なし
        return
    elseif addDynamicNo == 3 then               --ゲーミングモード
        screen.setColor(127*math.sin(t/30) + 128, 127*math.cos(t/30) + 128, 127*math.sin(t/15) + 128)
    else                                        --通常描画、色決定
        local color = SRD3_COLORS[colorNo + 1] or SRD3_COLORS[1]
        screen.setColor(color[1], color[2], color[3])
    end

    drawSRD3Shape(pixX, pixY, 4, shapeNo, addStaticNo == 2) --形状描画
    drawSRD3Static(pixX, pixY, shapeNo, addStaticNo)        --静的追加機能描画
end
---@endsection

---@section SRD3_COLORS
---色
SRD3_COLORS = {
    {0, 255, 0},
    {16, 16, 255},
    {255, 0, 0},
    {255, 255, 0},
    {0, 255, 255},
    {255, 0, 255},
    {0, 255, 0},
    {0, 255, 0},
    {0, 255, 0},
    {255, 255, 255}
}
---@endsection

---@section drawSRD3Shape
---@param x number ディスプレイX座標
---@param y number ディスプレイY座標
---@param r number マークのサイズ(半径)
---@param shapeNo number 形状No.
---@param dottedEnable boolean 点線かどうか
function drawSRD3Shape(x, y, r, shapeNo, dottedEnable)
    local drawLine = dottedEnable and drawDottedLine or function(x1, y1, x2, y2) screen.drawLine(x1, y1, x2, y2) end
    local drawRect = dottedEnable and drawDottedRect or screen.drawRect
    local drawTriangle = dottedEnable and drawDottedTriangle or screen.drawTriangle
    local drawCircle = dottedEnable and drawDottedCircle or screen.drawCircle

    if shapeNo == 0 then
        drawRect(x - r, y - r, r*2, r*2)
    elseif shapeNo <= 2 then
        drawLine(x - r, y, x, y + r, 1)
        drawLine(x, y + r, x + r, y, 1)
        drawLine(x + r, y, x, y - r, 1)
        drawLine(x, y - r, x - r, y, 1)
        if shapeNo == 2 then
            local rectR = r == 3 and r + 1 or r
            drawRect(x - rectR, y - rectR, rectR*2, rectR*2)
        end
    elseif shapeNo == 3 then
        drawTriangle(x, y - r, x + r/2*3^0.5, y + r/2, x - r/2*3^0.5, y + r/2)
    elseif shapeNo == 4 then
        drawCircle(x, y, r)
    elseif shapeNo == 5 then
        if r == 3 then
            drawLine(x - r, y - r, x - r, y - r + 1, 1)
            drawLine(x - r, y + r, x - r, y + r + 1, 1)
            drawLine(x + r, y - r, x + r, y - r + 1, 1)
            drawLine(x + r, y + r, x + r, y + r + 1, 1)
        else
            drawLine(x - r, y - r, x - r/2, y - r, 1)
            drawLine(x - r, y - r, x - r, y - r/2, 1)
            drawLine(x - r, y + r, x - r/2, y + r, 1)
            drawLine(x - r, y + r, x - r, y + r/2, 1)
            drawLine(x + r, y - r, x + r/2, y - r, 1)
            drawLine(x + r, y - r, x + r, y - r/2, 1)
            drawLine(x + r, y + r, x + r/2, y + r, 1)
            drawLine(x + r, y + r, x + r, y + r/2, 1)
        end
    elseif shapeNo == 6 then
        if r == 3 then
            drawLine(x - r, y, x - r, y + 1, 1)
            drawLine(x, y + r, x, y + r + 1, 1)
            drawLine(x + r, y, x + r, y + 1, 1)
            drawLine(x, y - r, x, y - r + 1, 1)
        else
            drawLine(x - r, y, x - r/2, y + r/2, 1)
            drawLine(x - r, y, x - r/2, y - r/2, 1)
            drawLine(x, y + r, x + r/2, y + r/2, 1)
            drawLine(x, y + r, x - r/2, y + r/2, 1)
            drawLine(x + r, y, x + r/2, y + r/2, 1)
            drawLine(x + r, y, x + r/2, y - r/2, 1)
            drawLine(x, y - r, x + r/2, y - r/2, 1)
            drawLine(x, y - r, x - r/2, y - r/2, 1)
        end
    end
end
---@endsection

---@section drawSRD3Static
---@param x number ディスプレイX座標
---@param y number ディスプレイY座標
---@param shapeNo number 形状No.
---@param addStaticNo number 静的追加機能No.
function drawSRD3Static(x, y, shapeNo, addStaticNo)
    if addStaticNo == 1 then
        drawSRD3Shape(x, y, 3, shapeNo, false)
    elseif addStaticNo == 3 then
        screen.drawLine(x - 1, y, x + 2, y)
        screen.drawLine(x, y - 1, x, y + 2)
    elseif addStaticNo == 4 then
        screen.drawLine(x + 4, y, x - 5, y)
        screen.drawLine(x, y + 4, x, y - 5)
    elseif addStaticNo == 5 then
        screen.drawLine(x - 4, y - 4, x + 5, y + 5)
        screen.drawLine(x + 4, y - 4, x - 5, y + 5)
    elseif addStaticNo == 6 then
        screen.drawLine(x + 4, y, x + 1, y)
        screen.drawLine(x - 4, y, x - 1, y)
        screen.drawLine(x, y + 4, x, y + 1)
        screen.drawLine(x, y - 4, x, y - 1)
    elseif addStaticNo == 7 then
        screen.drawLine(x - 4, y - 4, x - 1, y - 1)
        screen.drawLine(x + 4, y + 4, x + 1, y + 1)
        screen.drawLine(x + 4, y - 4, x + 1, y - 1)
        screen.drawLine(x - 4, y + 4, x - 1, y + 1)
    end
end
---@endsection
