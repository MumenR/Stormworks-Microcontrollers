---@section calZoom
---カメラズーム変換(FOVはラジアン, 出力：0-1の制御用値, 描画計算用FOVラジアン値)
---@param zoomManual number 0-1の制御用値
---@param MIN_FOV_CTRL number 設定最小FOVラジアン値/2
---@param MAX_FOV_CTRL number 設定最大FOVラジアン値/2
---@param MIN_FOV number カメラ最小FOVラジアン値/2
---@param MAX_FOV number カメラ最大FOVラジアン値/2
---@return number control 0-1の制御用値
---@return number fovRad 描画計算用FOVラジアン値/2
function calZoom(zoomManual, MIN_FOV_CTRL, MAX_FOV_CTRL, MIN_FOV, MAX_FOV)
    --入力値をラジアンに線形変換
    zoomRadManual = (MIN_FOV - MAX_FOV)*zoomManual + MAX_FOV
    
    --線形ラジアンを非線形に変換
    a = math.log(math.tan(MIN_FOV_CTRL)/math.tan(MAX_FOV_CTRL))/(MIN_FOV - MAX_FOV)
    C = math.log(math.tan(MIN_FOV_CTRL)) - MIN_FOV*a
    zoomRadCaled = math.atan(math.exp(a*zoomRadManual + C))

    --計算後ラジアンを制御用値(0-1)に変換
    return (zoomRadCaled - MAX_FOV)/(MIN_FOV- MAX_FOV), zoomRadCaled
end
---@endsection