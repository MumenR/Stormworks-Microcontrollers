--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool
PRN = property.getNumber
PRB = property.getBool
pi2 = math.pi*2

STABI_T = 7.5
STABI_P = 8.2
STABI_D = 15

SEAT_PIVOT = 32/5

--関数
do
    --積(A*B)
    function mul(A, B, C, sum)
        C = {}
        for i = 1, #A do
            C[i] = {}
            for j = 1, #B[1] do
                sum = 0
                for k = 1, #A[1] do
                    sum = sum + A[i][k]*B[k][j]
                end
                C[i][j] = sum
            end
        end
        return C
    end

    function R(Ex, Ey, Ez)
        local a, b, c, d, e, f = math.cos(Ex), math.sin(Ex), math.cos(Ey), math.sin(Ey), math.cos(Ez), math.sin(Ez)
        return {
            {e*c,   e*d*a + f*b,    e*d*b - f*a},
            {-d,    c*a,            c*b},
            {f*c,   f*d*a - e*b,    f*d*b + e*a}
        }
    end

    --ローカル座標からワールド座標へ変換(Physics sensor使用)
    function local2World(Lx, Ly, Lz, Px, Py, Pz, Ex, Ey, Ez)
        local W = mul(R(Ex, Ey, Ez), {{Lx}, {Ly}, {Lz}})
        return W[1][1] + Px, W[2][1] + Pz, W[3][1] + Py
    end

    --ワールド座標からローカル座標へ変換(Physics sensor使用)
    function world2Local(Wx, Wy, Wz, Px, Py, Pz, Ex, Ey, Ez)
        local L = mul({{Wx - Px, Wy - Pz, Wz - Py}}, R(Ex, Ey, Ez))
        return L[1][1], L[1][2], L[1][3]
    end

    --ローカル座標からローカル極座標へ変換(return pitch, yaw)
    function rect2Polar(x, y, z, radian_bool)
        local pitch, yaw
        pitch = math.atan(z, math.sqrt(x*x + y*y))
        yaw = math.atan(x, y)
        if radian_bool then
            return pitch, yaw
        else
            return pitch/pi2, yaw/pi2
        end
    end

    function clamp(x, min, max)
        if x >= max then
            x = max
        elseif x <= min then
            x = min
        end
        return x
    end

    function same_rotation(x)
        return (x + 0.5)%1 - 0.5
    end

    --(return: futurePitch, futureYaw)
    --Prv[rad/tick], Tは視線角速度観測用のターゲット位置と速度, losは向くべき方向, 2軸スタビ
    function stabilizer2(Px, Py, Pz, Ex, Ey, Ez, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, losWx, losWy, losWz, DELAY)
        local TLx, TLy, TLz, TLvx, TLvy, TLvz, Lrvx, Lrvy, Lrvz, losRvx, losRvy, losRvz, Vrx, Vry, Vrz, T2, absRv, cos, sin, dot, losFutureX, losFutureY, losFutureZ, losLx, losLy, losLz
        --ローカル座標
        TLx, TLy, TLz = world2Local(Tx, Ty, Tz, Px, Py, Pz, Ex, Ey, Ez)
        TLvx, TLvy, TLvz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, Ex, Ey, Ez)
        Lrvx, Lrvy, Lrvz = world2Local(Prvx, Prvz, Prvy, 0, 0, 0, Ex, Ey, Ez)
        losLx, losLy, losLz = world2Local(losWx, losWy, losWz, Px, Py, Pz, Ex, Ey, Ez)
        --相対速度
        Vrx, Vry, Vrz = TLvx - Pvx, TLvy - Pvz, TLvz - Pvy
        --視線角速度
        T2 = TLx*TLx + TLy*TLy + TLz*TLz
        losRvx = (TLy*Vrz - TLz*Vry)/T2 - (-Lrvx)
        losRvy = (TLz*Vrx - TLx*Vrz)/T2 - (-Lrvy)
        losRvz = (TLx*Vry - TLy*Vrx)/T2 - (-Lrvz)
        --t[tick]後の未来位置へ(ロドリゲスの公式)
        absRv = math.sqrt(losRvx*losRvx + losRvy*losRvy + losRvz*losRvz)
        cos = math.cos(absRv*DELAY)
        sin = math.sin(absRv*DELAY)/absRv
        dot = (losRvx*losLx + losRvy*losLy + losRvz*losLz)*(1 - cos)/absRv/absRv
        losFutureX = cos*losLx + sin*(losRvy*losLz - losRvz*losLy) + dot*losRvx
        losFutureY = cos*losLy + sin*(losRvz*losLx - losRvx*losLz) + dot*losRvy
        losFutureZ = cos*losLz + sin*(losRvx*losLy - losRvy*losLx) + dot*losRvz
        return rect2Polar(losFutureX, losFutureY, losFutureZ, false)
    end

    --(return: futurePitch, futureYaw)
    --Prv[rad/tick], azimuth[回転]は向くべき方位, 1軸スタビ
    function stabilizer1(Ex, Ey, Ez, Prvx, Prvy, Prvz, azimuth, DELAY)
        local losRvx, losRvy, losRvz, absRv, cos, sin, dot, futWx, futWy, futWz, Wx, Wy, ex, ey, ez, futLx, futLy, futLz
        --向くべき方位(３次元座標)
        Wx, Wy = math.sin(azimuth*pi2), math.cos(azimuth*pi2)
        --角速度を右手系変換し、標的の視線角速度に変える
        losRvx, losRvy, losRvz = -(-Prvx), -(-Prvz), -(-Prvy)
        --t[tick]後の未来位置へ(ロドリゲスの公式)
        absRv = math.sqrt(losRvx*losRvx + losRvy*losRvy + losRvz*losRvz)
        cos = math.cos(absRv*DELAY)
        sin = math.sin(absRv*DELAY)/absRv
        dot = (losRvx*Wx + losRvy*Wy)*(1 - cos)/absRv/absRv
        futWx = cos*Wx - sin*losRvz*Wy + dot*losRvx
        futWy = cos*Wy + sin*losRvz*Wx + dot*losRvy
        futWz = sin*(losRvx*Wy - losRvy*Wx) + dot*losRvz
        --ローカル座標変換
        ex, ey, ez = world2Local(0, 0, 1, 0, 0, 0, Ex, Ey, Ez)  --Z軸単位ベクトル
        futLx, futLy, futLz = world2Local(futWx, futWy, futWz, 0, 0, 0, Ex, Ey, Ez)
        --逆投影(?)
        futLx = futLx - ex*futLz/ez
        futLy = futLy - ey*futLz/ez
        return rect2Polar(futLx, futLy, 0, false)
    end

    seatYawES, seatYawEP = 0, 0
    seatPitchES, seatPitchEP = 0, 0

    --PID制御
    function PID(P, I, D, target, current, errorSumPre, errorPre, min, max)
        local error, errorSum, errorDiff, control
        error = target - current
        errorSum = math.abs(error) < 5/360 and errorSumPre + error or errorSumPre
        errorDiff = error - errorPre
        control = P*error + I*errorSum + D*errorDiff

        if control > max or control < min then
            errorSum = errorSumPre
            control = P*error + I*errorSum + D*errorDiff
        end
        return clamp(control, min, max), errorSum, error
    end
end

function onTick()
    --インプット
    do
        BodPx, BodPy, BodPz = INN(1), INN(2), INN(3)
        BodEx, BodEy, BodEz = INN(4), INN(5), INN(6)
        BodPvx, BodPvy, BodPvz = INN(7)/60, INN(8)/60, INN(9)/60
        BodPrvx, BodPrvy, BodPrvz = INN(10)*pi2/60, INN(11)*pi2/60, INN(12)*pi2/60

        SeatEx, SeatEy, SeatEz = INN(13), INN(14), INN(15)
    end

    --ピボットのヨーに変換
    do
        Wx, Wy, Wz = local2World(0, 1, 0, 0, 0, 0, SeatEx, SeatEy, SeatEz)
        Lx, Ly, Lz = world2Local(Wx, Wy, Wz, 0, 0, 0, BodEx, BodEy, BodEz)
        _, seatCntYaw = rect2Polar(Lx, Ly, Lz, false)
    end

    --シートピボット
    do
        _, seatIdealYaw = stabilizer1(BodEx, BodEy, BodEz, BodPrvx, BodPrvy, BodPrvz, 0.25, STABI_T)

        seatYawControl, seatYawES, seatYawEP = PID(STABI_P, 0, STABI_D, 0, -same_rotation(seatIdealYaw - seatCntYaw), seatYawES, seatYawEP, -100, 100)
        seatYawControl = seatYawControl*SEAT_PIVOT
        --nan対策
        seatYawControl = seatYawControl ~= seatYawControl and 0 or seatYawControl
    end

    OUN(31, seatYawControl)
end