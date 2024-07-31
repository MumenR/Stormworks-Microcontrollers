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

log = math.log
sin = math.sin
cos = math.cos
pi = math.pi

bBx = 0
bBy = 0
bBz = 0

function V0dict(AD) --Air Drag
	if AD >= 0.024 then
		V0 = 800
	elseif AD >= 0.019 then
		V0 = 1000
	elseif AD >= 0.009 then
		V0 = 1000
	elseif AD >= 0.004 then
		V0 = 900
	elseif AD >= 0.0019 then
		V0 = 800
	elseif AD >= 0.0009 then
		V0 = 700
	elseif AD >= 0.0004 then
		V0 = 600
	elseif AD >= 0.00009 then
		V0 = 400
	else
		V0 = 1
	end
	return V0
end

function Hdisdict(AD)
	if AD >= 0.024 then
		Hd = 514
	elseif AD >= 0.019 then
		Hd = 808
	elseif AD >= 0.009 then
		Hd = 1605
	elseif AD >= 0.004 then
		Hd = 2769
	elseif AD >= 0.0019 then
		Hd = 5255
	elseif AD >= 0.0009 then
		Hd = 7014
	elseif AD >= 0.0004 then
		Hd = 7654
	elseif AD >= 0.00009 then
		Hd = 1700
	else
		Hd = 2000
	end
	return Hd
end

function DirecXYZ(direc, tilt)
	Hor = cos(tilt*2*pi)
	
	X = Hor * sin(direc*2*pi)
	Y = Hor * cos(direc*2*pi)
	Z = sin(tilt*2*pi)
	
	return X, Y, Z
end

function Local2World(Gx, Gy, Gz, Lx, Ly, Lz, Tx, Ty, Tz, Dx, Dy, Dz)
	
	Xx, Xy, Xz = DirecXYZ(Dx, Tx)
	Yx, Yy, Yz = DirecXYZ(Dy, Ty)
	Zx, Zy, Zz = DirecXYZ(Dz, Tz)
	
	Wx = Lx*Xx + Ly*Yx + Lz*Zx + Gx
	Wy = Lx*Xy + Ly*Yy + Lz*Zy + Gy
	Wz = Lx*Xz + Ly*Yz + Lz*Zz + Gz
	
	return Wx, Wy, Wz
end


ft = 0
RetDirection = 0
RetElevation = 0

function FlightY(Vo, tick, k)
	k = INN(26)
    g = 30/(60*60)
    ans = -(1/log(1 - k))*((Vo - g/log(1 - k))*(1 - (1 - k)^tick) - g*tick)

	if ans ~= ans then
		return 1
	else
		return ans
	end
end

function FlightXtime(Vo, x)
	
	k = INN(26)
	ans = log(1 + x*log(1 - k)/Vo, 1 - k)
	
	if ans ~= ans then
		return 1
	else
		return ans
	end
end

function CalculationStatic(vdis, hdis)
	k = INN(26)
	V = V0dict(k)/60
	Lower = math.atan(vdis, hdis)
	Upper = Lower + (45 / 360.0 * 2*pi)
	if Upper >= pi / 2.0 then
		Upper = pi / 2.0
	end
	Ave = (Upper + Lower) / 2.0

	for j = 1, 10 do
		Vv = V * sin(Ave)
		Vh = V * cos(Ave)
		
		ft = FlightXtime(Vh, hdis)
		PassAlt = FlightY(Vv, ft)
		
		if PassAlt < vdis then
			Lower = Ave
		else
			Upper = Ave
		end
		Ave = (Upper + Lower)/2.0
	end
	
	Vv = V * sin(Ave)
	Vh = V * cos(Ave)
	ft = FlightXtime(Vh, hdis)
	return Ave
end

function CalculationDynamic(CVx, CVy, CValt, TVx, TVy, TValt, Xdis, Ydis, AltDis)
	
	Vx = TVx - CVx
	Vy = TVy - CVy
	Valt = TValt - CValt
	
	ele = 0
	ft = 0
	FireDirec = 0
	FireEle = 0
	Xtemp = 0
	Ytemp = 0
	Vdis = 0
	Hdis = 0
	
	for i = 1, 6 do
		
		Vdis = AltDis + Valt*ft
		Xtemp = Xdis + Vx*ft
		Ytemp = Ydis + Vy*ft
		Hdis = math.sqrt(Xtemp^2 + Ytemp^2)
		
		CalculationStatic(Vdis, Hdis)
	end
	
	RetDirection = math.atan(Xtemp, Ytemp) / (2*pi)
	RetElevation = CalculationStatic(Vdis, Hdis, k) / (2*pi)
	return
end

function Range(Cx, Cy, Cz, TarX, TarY, TarZ, TarVx, TarVy, TarVz)
	k = INN(26)
	MaxHd = Hdisdict(k)
	
	TarX = TarX + TarVx*ft
	TarY = TarY + TarVy*ft
	TarZ = TarZ + TarVz*ft
	
	Hdis = math.sqrt((TarX-Cx)^2 + (TarY-Cy)^2)
	
	if Hdis < MaxHd then
		return true
	else
		return false
	end
	
	
end


function onTick()
	
	Tx=INN(1)
	Ty=INN(2)
	Tz=INN(3)
	TVx=INN(4)
	TVy=INN(5)
	TVz=INN(6)
	Bx=INN(7)
	By=INN(8)
	Bz=INN(9)
	
	Xtilt=INN(10)
	Ytilt=INN(11)
	Ztilt=INN(12)
	Xdirec=-INN(13)
	Ydirec=-INN(14)
	Zdirec=-INN(15)
	Delay=INN(25)
	
	for i=10, 28 do
		OUN(i, INN(i))
	end
	
	Detected=INB(1)
	
	Bz = Bz + 0.25*sin(INN(11) * 2*pi)
	
	Bx, By, Bz = Local2World(Bx, By, Bz, 0, 0, 3, Xtilt, Ytilt, Ztilt, Xdirec, Ydirec, Zdirec)
	
	
	BVx = Bx - bBx
	BVy = By - bBy
	BVz = Bz - bBz
	
	
	RetDirection = 0
	RetElevation = 0
	Shootable = false
	
	if Detected then
		
		Tx = Tx + TVx*Delay
		Ty = Ty + TVy*Delay
		Tz = Tz + TVz*Delay
		
		Xdis = Tx - Bx
		Ydis = Ty - By
		Zdis = Tz - Bz
		
		CalculationDynamic(BVx, BVy, BVz, TVx, TVy, TVz, Xdis, Ydis, Zdis)
		Shootable = Range(Bx, By, Bz, Tx, Ty, Tz, TVx, TVy, TVz)
	
	end
	
	OUN(1, RetElevation)
	OUN(2, RetDirection)
	
	OUN(7, Bx)
	OUN(8, By)
	OUN(9, Bz)
	
	OUN(30, INN(26))
	OUN(31, V0dict(INN(26)))
	OUN(32, Hdisdict(INN(26)))
	
	OUB(1, Shootable)
	
	
	
	bBx = Bx
	bBy = By
	bBz = Bz
end


