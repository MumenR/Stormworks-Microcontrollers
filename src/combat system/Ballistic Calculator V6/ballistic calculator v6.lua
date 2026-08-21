--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode

--[====[ EDITABLE SIMULATOR CONFIG - removed from release builds ]====]
---@section __LB_SIMULATOR_ONLY__
do
    simulator = simulator
    simulator:setScreen(1, "3x3")

    simulator:setProperty("Weapon Type", 3)
    simulator:setProperty("Stabilizer", 0)
    simulator:setProperty("standby yaw position (degree)", 0)
    simulator:setProperty("standby pitch position (degree)", 0)
    simulator:setProperty("min pitch (degree)", -15)
    simulator:setProperty("max pitch (degree)", 90)
    simulator:setProperty("Pitch Swivel Mode", false)
    simulator:setProperty("min yaw (degree)", -180)
    simulator:setProperty("max yaw (degree)", 180)
    simulator:setProperty("Yaw Swivel Mode", false)
    simulator:setProperty("Pivot rotation speed gain", 1)
    simulator:setProperty("Pitch gear ratio (1 : ?)", 32)
    simulator:setProperty("Types of Pitch PIVOT", 1)
    simulator:setProperty("Yaw gear ratio (1 : ?)", 32)
    simulator:setProperty("Types of Yaw PIVOT", 1)
    simulator:setProperty("manual P", 7.5)
    simulator:setProperty("manual I", 0)
    simulator:setProperty("manual D", 0)
    simulator:setProperty("Turret phy. offset x (m)", 0)
    simulator:setProperty("Turret phy. offset y (m)", 0)
    simulator:setProperty("Turret phy. offset z (m)", 0)
    simulator:setProperty("Muzzle offset x (m)", 0)
    simulator:setProperty("Muzzle offset y (m)", 0)
    simulator:setProperty("Muzzle offset z (m)", 0)

    function onLBSimulatorTick(simulator, ticks)
        for i = 1, 3 do
            simulator:setInputBool(i, simulator:getIsToggled(i))
            simulator:setInputNumber(i, simulator:getSlider(i)*1000)
        end
        for i = 4, 9 do
            simulator:setInputBool(i, simulator:getIsToggled(i))
            simulator:setInputNumber(i, simulator:getSlider(i))
        end
        simulator:setInputNumber(25, 40)
        simulator:setInputNumber(26, simulator:getSlider(10) - 0.5)
    end
end
---@endsection

--[====[ IN-GAME CODE ]====]

INN = input.getNumber
INB = input.getBool
OUN = output.setNumber
OUB = output.setBool
PRN = property.getNumber
PRB = property.getBool

PI2 = math.pi*2
ROCKET_ACCEL = 600/3600
ROCKET_TICKS = 60
STABI_DELAY_VELO = 8
STABI_DELAY_ROBO = 9.8
STABI_P = 7.5
STABI_I = 0
ERROR_P = 0
ERROR_I = 0.05
ERROR_D = 0
ROOT_SCAN = 128
HIT_TOL = 0.1
GAUSS_OFFSET = math.sqrt(3/5)/2
INFTY = 10000

-- muzzle speed [m/s], one-tick drag, lifetime [tick], wind influence
parameter = {
    {600, 0.0005, 2400, 0.105},
    {700, 0.001, 2400, 0.11},
    {800, 0.002, 2400, 0.12},
    {900, 0.005, 600, 0.125},
    {1000, 0.01, 300, 0.13},
    {1000, 0.02, 150, 0.135},
    {800, 0.025, 120, 0.15},
    {50, 0.003, 3600, 0.125}
}

do
    function mulQt(q, p)
        local a, b, c, d = table.unpack(q)
        local x, y, z, w = table.unpack(p)
        return {
            d*x - c*y + b*z + a*w,
            c*x + d*y - a*z + b*w,
            -b*x + a*y + d*z + c*w,
            -a*x - b*y - c*z + d*w
        }
    end

    function euler2Qt(x, y, z)
        return mulQt({0, math.sin(-z/2), 0, math.cos(-z/2)}, mulQt({0, 0, math.sin(-y/2), math.cos(-y/2)}, {math.sin(-x/2), 0, 0, math.cos(-x/2)}))
    end

    -- Public coordinate order is world X, horizontal Y, altitude Z.
    -- Physics-sensor positions use X, altitude Y, horizontal Z.
    function local2World(Lx, Ly, Lz, Px, Py, Pz, q)
        local v = mulQt(q, mulQt({Lx, Ly, Lz, 0}, {-q[1], -q[2], -q[3], q[4]}))
        return v[1] + Px, v[2] + Pz, v[3] + Py
    end

    function world2Local(Wx, Wy, Wz, Px, Py, Pz, q)
        return table.unpack(mulQt({-q[1], -q[2], -q[3], q[4]}, mulQt({Wx - Px, Wy - Pz, Wz - Py, 0}, q)))
    end

    function clamp(x, min, max)
        return x > max and max or (x < min and min or x)
    end

    function sameRotation(x)
        return (x + 0.5)%1 - 0.5
    end

    function rect2Polar(x, y, z, radian)
        local pitch, yaw = math.atan(z, math.sqrt(x*x + y*y)), math.atan(x, y)
        return radian and pitch or pitch/PI2, radian and yaw or yaw/PI2
    end

    -- Convert the apparent local wind reading to a horizontal world vector.
    function windLocal2World(speed, direction, Pvx, Pvz, q)
        local x, y, z = local2World(speed*math.sin(direction*PI2) - Pvx, speed*math.cos(direction*PI2) - Pvz, 0, 0, 0, 0, q)
        local ux, uy, uz = local2World(0, 0, 1, 0, 0, 0, q)
        if math.abs(uz) > 0.000001 then
            x, y = x - ux*z/uz, y - uy*z/uz
        end
        return x, y
    end

    -- Correct Stormworks environment formulae in tick units.
    function environment(h)
        local p = (44.33 - h/1000)/11.89
        return math.exp(-h/60000)/120, p > 0 and p^5.256/1013 or 0
    end

    stabiPitchEP, stabiPitchES = 0, 0
    stabiYawEP, stabiYawES = 0, 0
    pitchEP, pitchES = 0, 0
    yawEP, yawES = 0, 0

    function PID(P, I, D, target, current, sumLast, errorLast, min, max)
        local error = target - current
        local sum = math.abs(error) < 1/360 and sumLast + error or 0
        local control = P*error + I*sum + D*(error - errorLast)
        if control > max or control < min then
            sum = sumLast
            control = P*error + I*sum + D*(error - errorLast)
        end
        return clamp(control, min, max), sum, error
    end

    function stabilizer(Px, Py, Pz, q, Pvx, Pvy, Pvz, Prvx, Prvy, Prvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, losX, losY, losZ, delay)
        local x, y, z = world2Local(Tx, Ty, Tz, Px, Py, Pz, q)
        local vx, vy, vz = world2Local(Tvx, Tvy, Tvz, 0, 0, 0, q)
        local rvx, rvy, rvz = world2Local(Prvx, Prvz, Prvy, 0, 0, 0, q)
        local lx, ly, lz = world2Local(losX, losY, losZ, Px, Py, Pz, q)
        vx, vy, vz = vx - Pvx, vy - Pvz, vz - Pvy
        local r2 = x*x + y*y + z*z
        if r2 < 0.000000001 then
            return rect2Polar(lx, ly, lz, false)
        end
        local ax = (y*vz - z*vy)/r2 + rvx
        local ay = (z*vx - x*vz)/r2 + rvy
        local az = (x*vy - y*vx)/r2 + rvz
        local a = math.sqrt(ax*ax + ay*ay + az*az)
        if a < 0.000000001 then
            return rect2Polar(lx, ly, lz, false)
        end
        local c, s = math.cos(a*delay), math.sin(a*delay)/a
        local d = (ax*lx + ay*ly + az*lz)*(1 - c)/(a*a)
        return rect2Polar(c*lx + s*(ay*lz - az*ly) + d*ax, c*ly + s*(az*lx - ax*lz) + d*ay, c*lz + s*(ax*ly - ay*lx) + d*az, false)
    end

    -- Evaluate the one-dimensional time equation. The globals cache terms
    -- needed immediately after a root has been found.
    function ballisticError(t)
        local L, M = 0, 0
        if t > 0 then
            L = (1 - math.exp(-K*t))/K
            M = (t - L)/K
        end
        local S = V0*L
        if isRocket and t > 0 then
            if t <= ROCKET_TICKS then
                S = S + ROCKET_ACCEL*M
            else
                local u = t - ROCKET_TICKS
                local Lu = (1 - math.exp(-K*u))/K
                S = S + ROCKET_ACCEL*(M - (u - Lu)/K)
            end
        end
        local t2 = t*t/2
        calcQx = TWLx + Tvx*t + Tax*t2 - Wvx*L - windAx*M
        calcQy = TWLy + Tvy*t + Tay*t2 - Wvy*L - windAy*M
        calcQz = TWLz + Tvz*t + Taz*t2 - Wvz*L + effectiveG*M
        calcM, calcS = M, S
        local a = S + MUZ_OFFSET_Y
        return calcQx*calcQx + calcQy*calcQy + calcQz*calcQz - a*a - MUZ_OFFSET_X*MUZ_OFFSET_X - MUZ_OFFSET_Z*MUZ_OFFSET_Z
    end

    function ballisticMiss(f)
        local a = calcS + MUZ_OFFSET_Y
        return math.abs(f)/(math.sqrt(calcQx*calcQx + calcQy*calcQy + calcQz*calcQz) + math.sqrt(a*a + MUZ_OFFSET_X*MUZ_OFFSET_X + MUZ_OFFSET_Z*MUZ_OFFSET_Z) + 0.000000001)
    end

    -- Guaranteed Brent-Dekker iteration on a sign-changing interval.
    function brent(a, b, fa, fb)
        if fa == 0 then return a, fa, true end
        if fb == 0 then return b, fb, true end
        if fa*fb > 0 or fa ~= fa or fb ~= fb then return b, fb, false end
        local c, fc = a, fa
        local d, e = b - a, b - a
        for i = 1, 28 do
            if fb*fc > 0 then
                c, fc = a, fa
                d, e = b - a, b - a
            end
            if math.abs(fc) < math.abs(fb) then
                a, b, c = b, c, b
                fa, fb, fc = fb, fc, fb
            end
            local tol = 0.0001 + 0.0000001*math.abs(b)
            local m = (c - b)/2
            if math.abs(m) <= tol or fb == 0 then return b, fb, true end
            if math.abs(e) >= tol and math.abs(fa) > math.abs(fb) then
                local s, p, q = fb/fa
                if a == c then
                    p, q = 2*m*s, 1 - s
                else
                    q = fa/fc
                    local r = fb/fc
                    p = s*(2*m*q*(q - r) - (b - a)*(r - 1))
                    q = (q - 1)*(r - 1)*(s - 1)
                end
                if p > 0 then q = -q else p = -p end
                local limit = math.min(3*m*q - math.abs(tol*q), math.abs(e*q))
                if 2*p < limit then
                    e, d = d, p/q
                else
                    d, e = m, m
                end
            else
                d, e = m, m
            end
            a, fa = b, fb
            b = b + (math.abs(d) > tol and d or (m > 0 and tol or -tol))
            fb = ballisticError(b)
            if fb ~= fb then return b, fb, false end
        end
        return b, fb, false
    end

    -- Find every sign change. First time root is low angle; last is high.
    function findTime(high)
        local step = tickDel/ROOT_SCAN
        local lastT, lastF = 0, ballisticError(0)
        local a, b, fa, fb
        local minT, minF = 0, lastF
        for i = 1, ROOT_SCAN do
            local t = i*step
            local f = ballisticError(t)
            if f == f and f < minF then minT, minF = t, f end
            if f == f and lastF == lastF and (high and lastF <= 0 and f >= 0 or not high and lastF >= 0 and f <= 0) and (high or not a) then
                a, b, fa, fb = lastT, t, lastF, f
            end
            lastT, lastF = t, f
        end
        if a then return brent(a, b, fa, fb) end

        -- Refine the lowest sampled cell so near-tangent root pairs are not lost.
        a, b = math.max(0, minT - step), math.min(tickDel, minT + step)
        local left, right = a, b
        for i = 1, 16 do
            local c, d = (2*left + right)/3, (left + 2*right)/3
            if ballisticError(c) < ballisticError(d) then right = d else left = c end
        end
        local t = (left + right)/2
        local f = ballisticError(t)
        if ballisticMiss(f) <= HIT_TOL then return t, f, true end
        if f <= 0 then
            if high then a = t else b = t end
            fa, fb = ballisticError(a), ballisticError(b)
            if fa*fb <= 0 then return brent(a, b, fa, fb) end
        end
        return 0, lastF, false
    end

    -- Fixed-point effective environment: Brent time root, then response-weighted
    -- three-point Gauss-Legendre evaluation along the analytic trajectory.
    function solveBallistic()
        effectiveG, effectiveRho = environment(TurPy)
        for iteration = 1, 4 do
            windAx = -windWx*WIND_INFLUENCE*effectiveRho/60
            windAy = -windWy*WIND_INFLUENCE*effectiveRho/60
            local ok
            tick, _, ok = findTime(highAngleEnable)
            if not ok or tick <= 0 then return false end
            ballisticError(tick)
            local a = calcS + MUZ_OFFSET_Y
            local horizontal = math.sqrt(calcQx*calcQx + calcQy*calcQy)
            if math.abs(MUZ_OFFSET_X) - horizontal > HIT_TOL then return false end
            horizontal = math.sqrt(math.max(0, horizontal*horizontal - MUZ_OFFSET_X*MUZ_OFFSET_X))
            Azimuth = math.atan(calcQx, calcQy) - math.atan(MUZ_OFFSET_X, horizontal)
            Elevation = math.atan(calcQz, horizontal) - math.atan(MUZ_OFFSET_Z, a)

            local sinEl, cosEl = math.sin(Elevation), math.cos(Elevation)
            local muzzleZ = MUZ_OFFSET_Y*sinEl + MUZ_OFFSET_Z*cosEl
            local MT = calcM
            if MT <= 0 then return false end
            local sumG, sumRho, sumWeight = 0, 0, 0
            for i = 1, 3 do
                local ratio = i == 1 and 0.5 - GAUSS_OFFSET or (i == 2 and 0.5 or 0.5 + GAUSS_OFFSET)
                local ti = tick*ratio
                local L = (1 - math.exp(-K*ti))/K
                local M = (ti - L)/K
                local S = V0*L
                if isRocket then
                    if ti <= ROCKET_TICKS then
                        S = S + ROCKET_ACCEL*M
                    else
                        local u = ti - ROCKET_TICKS
                        local Lu = (1 - math.exp(-K*u))/K
                        S = S + ROCKET_ACCEL*(M - (u - Lu)/K)
                    end
                end
                local h = TurPy + muzzleZ + Wvz*L + sinEl*S - effectiveG*M
                local g, rho = environment(h)
                local u = tick - ti
                local weight = (1 - math.exp(-K*u))/K
                local q = i == 2 and 4/9 or 5/18
                sumG, sumRho, sumWeight = sumG + q*weight*g, sumRho + q*weight*rho, sumWeight + q*weight
            end
            -- The constant part integrates analytically; Gauss evaluates only the deviation.
            local newG = effectiveG + tick*(sumG - effectiveG*sumWeight)/MT
            local newRho = effectiveRho + tick*(sumRho - effectiveRho*sumWeight)/MT
            if newG ~= newG or newRho ~= newRho then return false end
            if math.abs(newG - effectiveG) < 0.00000001 and math.abs(newRho - effectiveRho) < 0.00001 then break end
            if iteration < 4 then effectiveG, effectiveRho = newG, newRho end
        end
        return tick < tickDel and ballisticMiss(ballisticError(tick)) <= HIT_TOL
    end
end

function onTick()
    -- Input mapping is identical to Ballistic Calculator V5.
    Tx, Ty, Tz = INN(1), INN(2), INN(3)
    Tvx, Tvy, Tvz = INN(4), INN(5), INN(6)
    Tax, Tay, Taz = INN(7), INN(8), INN(9)
    BodQt = euler2Qt(INN(10), INN(11), INN(12))
    BodPvx, BodPvy, BodPvz = INN(13)/60, INN(14)/60, INN(15)/60
    BodPrvx, BodPrvy, BodPrvz = INN(16)*PI2/60, INN(17)*PI2/60, INN(18)*PI2/60
    TurPx, TurPy, TurPz = INN(19), INN(20), INN(21)
    TurQt = euler2Qt(INN(22), INN(23), INN(24))
    windLv, windLdirec = INN(25)/60, INN(26)
    TRD1Exists, power, highAngleEnable, reloadEnable = INB(1), INB(2), INB(4), INB(5)

    -- Properties are static in a microcontroller, so read them only once.
    if not configured then
        WPN_TYPE = PRN("Weapon Type")
        STABI_D = PRN("Stabilizer")
        stabiEnable = STABI_D >= 0
        STANDBY_PITCH = PRN("standby pitch position (degree)")/360
        STANDBY_YAW = PRN("standby yaw position (degree)")/360
        MIN_PITCH = PRN("min pitch (degree)")/360
        MAX_PITCH = PRN("max pitch (degree)")/360
        PITCH_LIMIT_ENABLE = PRB("Pitch Swivel Mode")
        MIN_YAW = PRN("min yaw (degree)")/360
        MAX_YAW = PRN("max yaw (degree)")/360
        YAW_LIMIT_ENABLE = PRB("Yaw Swivel Mode")
        MAX_SPEED_GAIN = PRN("Pivot rotation speed gain")
        local p = PRN("Types of Pitch PIVOT")
        local y = PRN("Types of Yaw PIVOT")
        PITCH_PIVOT = PRN("Pitch gear ratio (1 : ?)")/(p == 0 and 1 or p)
        YAW_PIVOT = PRN("Yaw gear ratio (1 : ?)")/(y == 0 and 1 or y)
        MANUAL_P, MANUAL_I, MANUAL_D = PRN("manual P"), PRN("manual I"), PRN("manual D")
        PHY_OFFSET_X = -PRN("Turret phy. offset x (m)")
        PHY_OFFSET_Y = -PRN("Turret phy. offset y (m)")
        PHY_OFFSET_Z = -PRN("Turret phy. offset z (m)")
        MUZ_OFFSET_X = PRN("Muzzle offset x (m)")
        MUZ_OFFSET_Y = PRN("Muzzle offset y (m)")
        MUZ_OFFSET_Z = PRN("Muzzle offset z (m)")
        configured = true
    end

    inRange = false
    tick = 0
    idealPitch, idealYaw = STANDBY_PITCH, STANDBY_YAW
    stabiPitch, stabiYaw = STANDBY_PITCH, STANDBY_YAW
    roboticPitch, roboticYaw = STANDBY_PITCH, STANDBY_YAW
    Azimuth, Elevation = 0, 0

    -- Current turret pitch/yaw relative to the vehicle body.
    local x, y, z = local2World(0, 1, 0, 0, 0, 0, TurQt)
    x, y, z = world2Local(x, y, z, 0, 0, 0, BodQt)
    currentPitch, currentYaw = rect2Polar(x, y, z, false)
    x, y, z = local2World(0, 0, 1, 0, 0, 0, TurQt)
    x, y, z = world2Local(x, y, z, 0, 0, 0, BodQt)
    if z < 0 then
        currentPitch = sameRotation(0.5 - currentPitch)
        currentYaw = sameRotation(currentYaw + 0.5)
    end

    Wvx, Wvy, Wvz = local2World(BodPvx, BodPvz, BodPvy, 0, 0, 0, BodQt)
    local weapon = parameter[WPN_TYPE]
    if TRD1Exists and power and weapon then
        V0, K, tickDel, WIND_INFLUENCE = weapon[1]/60, -math.log(1 - weapon[2]), weapon[3], weapon[4]
        isRocket = WPN_TYPE == 8

        TurPx, TurPz, TurPy = local2World(PHY_OFFSET_X, PHY_OFFSET_Y, PHY_OFFSET_Z, TurPx, TurPy, TurPz, TurQt)
        TWLx, TWLy, TWLz = Tx - TurPx, Ty - TurPz, Tz - TurPy

        windWx, windWy = windLocal2World(windLv, windLdirec, BodPvx, BodPvz, BodQt)
        local _, localRho = environment(TurPy)
        if localRho > 0.000000001 then
            windWx, windWy = windWx/localRho, windWy/localRho
        else
            windWx, windWy = 0, 0
        end

        inRange = solveBallistic()
        if inRange then
            losWx = TurPx + INFTY*math.cos(Elevation)*math.sin(Azimuth)
            losWy = TurPz + INFTY*math.cos(Elevation)*math.cos(Azimuth)
            losWz = TurPy + INFTY*math.sin(Elevation)
            x, y, z = world2Local(losWx, losWy, losWz, TurPx, TurPy, TurPz, BodQt)
            idealPitch, idealYaw = rect2Polar(x, y, z, false)
            local t2 = tick*tick/2
            impx, impy, impz = Tx + Tvx*tick + Tax*t2, Ty + Tvy*tick + Tay*t2, Tz + Tvz*tick + Taz*t2
            impvx, impvy, impvz = Tvx + Tax*tick, Tvy + Tay*tick, Tvz + Taz*tick
        end
    end

    -- Missile mode and failed/out-of-range ballistic solutions use direct LOS.
    if not inRange and TRD1Exists and power then
        stabiPitch, stabiYaw = stabilizer(TurPx, TurPy, TurPz, BodQt, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, Tx, Ty, Tz, STABI_DELAY_VELO)
        roboticPitch, roboticYaw = stabilizer(TurPx, TurPy, TurPz, BodQt, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, Tx, Ty, Tz, Tvx, Tvy, Tvz, Tx, Ty, Tz, STABI_DELAY_ROBO)
        x, y, z = world2Local(Tx, Ty, Tz, TurPx, TurPy, TurPz, BodQt)
        idealPitch, idealYaw = rect2Polar(x, y, z, false)
    end

    currentInFOV = sameRotation(currentYaw) > MIN_YAW and sameRotation(currentYaw) < MAX_YAW and currentPitch > MIN_PITCH and currentPitch < MAX_PITCH
    targetInFOVPitch = idealPitch > MIN_PITCH and idealPitch < MAX_PITCH
    targetInFOVYaw = idealYaw > MIN_YAW and idealYaw < MAX_YAW
    pitchError = math.abs(sameRotation(idealPitch - currentPitch))*360
    yawError = math.abs(sameRotation(idealYaw - currentYaw))*360
    local inError = pitchError < 2 and yawError < 2
    shootable = ((WPN_TYPE == 9 and power and TRD1Exists) or inRange) and inError and currentInFOV and targetInFOVPitch and targetInFOVYaw and not reloadEnable

    local P, I, D
    if stabiEnable then
        if inRange then
            stabiPitch, stabiYaw = stabilizer(TurPx, TurPy, TurPz, BodQt, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, impx, impy, impz, impvx, impvy, impvz, losWx, losWy, losWz, STABI_DELAY_VELO)
            roboticPitch, roboticYaw = stabilizer(TurPx, TurPy, TurPz, BodQt, BodPvx, BodPvy, BodPvz, BodPrvx, BodPrvy, BodPrvz, impx, impy, impz, impvx, impvy, impvz, losWx, losWy, losWz, STABI_DELAY_ROBO)
        end
        if reloadEnable then stabiPitch, roboticPitch = STANDBY_PITCH, STANDBY_PITCH end
        local yawDiff = YAW_LIMIT_ENABLE and clamp(stabiYaw, MIN_YAW, MAX_YAW) - currentYaw or sameRotation(stabiYaw - currentYaw)
        local pitchDiff = PITCH_LIMIT_ENABLE and clamp(stabiPitch, MIN_PITCH, MAX_PITCH) - currentPitch or stabiPitch - currentPitch
        stabiPitchV, stabiPitchES, stabiPitchEP = PID(STABI_P, STABI_I, STABI_D, 0, -pitchDiff, stabiPitchES, stabiPitchEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)
        stabiYawV, stabiYawES, stabiYawEP = PID(STABI_P, STABI_I, STABI_D, 0, -yawDiff, stabiYawES, stabiYawEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)
        P, I, D = ERROR_P, ERROR_I, ERROR_D
    else
        P, I, D = MANUAL_P, MANUAL_I, MANUAL_D
        stabiPitchV, stabiYawV = 0, 0
        roboticPitch, roboticYaw = idealPitch, idealYaw
    end

    local yawDiff = YAW_LIMIT_ENABLE and clamp(idealYaw, MIN_YAW, MAX_YAW) - currentYaw or sameRotation(idealYaw - currentYaw)
    local pitchDiff = PITCH_LIMIT_ENABLE and clamp(idealPitch, MIN_PITCH, MAX_PITCH) - currentPitch or idealPitch - currentPitch
    local pitchV, yawV
    pitchV, pitchES, pitchEP = PID(P, I, D, 0, -pitchDiff, pitchES, pitchEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)
    yawV, yawES, yawEP = PID(P, I, D, 0, -yawDiff, yawES, yawEP, -MAX_SPEED_GAIN, MAX_SPEED_GAIN)
    pitchV, yawV = (stabiPitchV + pitchV)*PITCH_PIVOT, (stabiYawV + yawV)*YAW_PIVOT
    if PITCH_PIVOT < 0 then pitchV = (PITCH_LIMIT_ENABLE and clamp(roboticPitch, MIN_PITCH, MAX_PITCH) or roboticPitch)*4 end
    if YAW_PIVOT < 0 then yawV = (YAW_LIMIT_ENABLE and clamp(roboticYaw, MIN_YAW, MAX_YAW) or roboticYaw)*4 end
    if pitchV ~= pitchV then pitchV = 0 end
    if yawV ~= yawV then yawV = 0 end

    OUN(1, pitchV)
    OUN(2, yawV)
    OUB(1, shootable)
    OUB(2, inRange)
    OUN(3, pitchError)
    OUN(4, yawError)
    OUN(5, tick/60)
    OUN(30, tick)
    OUN(31, Elevation)
    OUN(32, Azimuth)
end
