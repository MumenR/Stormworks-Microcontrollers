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

Gear = 2

LCele = 0
LCdirec = 0
bLCele = 0
bLCdirec = 0
bShootable = false

function DirecCal(direc)
	return math.fmod(direc - math.floor(direc) + 1.5, 1)-0.5
end

function DirecXYZ(direc, tilt)
	Hor = math.cos(tilt*2*math.pi)
	
	X = Hor * math.sin(direc*2*math.pi)
	Y = Hor * math.cos(direc*2*math.pi)
	Z = math.sin(tilt*2*math.pi)
	
	return X, Y, Z
end

function World2Local(Gx, Gy, Gz, Wx, Wy, Wz, Tx, Ty, Tz, Dx, Dy, Dz)
	
	Xx, Xy, Xz = DirecXYZ(Dx, Tx)
	Yx, Yy, Yz = DirecXYZ(Dy, Ty)
	Zx, Zy, Zz = DirecXYZ(Dz, Tz)
	
	a = Wx-Gx
	b = Xx
	c = Yx
	d = Zx
	e = Wy-Gy
	f = Xy
	g = Yy
	h = Zy
	i = Wz-Gz
	j = Xz
	k = Yz
	l = Zz
	
	x = 0
	y = 0
	z = 0
	if ((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j) ~= 0 then
		x = ((a*g-c*e)*l+(d*e-a*h)*k+(c*h-d*g)*i)/((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j)
	end
	if ((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j) ~= 0 then
		y = -((a*f-b*e)*l+(d*e-a*h)*j+(b*h-d*f)*i)/((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j)
	end
	if ((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j) ~= 0 then
		z = ((a*f-b*e)*k+(c*e-a*g)*j+(b*g-c*f)*i)/((b*g-c*f)*l+(d*f-b*h)*k+(c*h-d*g)*j)
	end
	Lx = x
	Ly = y
	Lz = z
	
	return Lx, Ly, Lz	
end

function IsAim(Ele, Direc, Pele, Pdirec)
	
	if (Ele-Pele)^2 + DirecCal(Direc-Pdirec)^2 < 0.013^2 then
		return true
	else
		return false
	end
	
end

function Clamp(Val, Max, Min)
	
	if Val > Max then
		return Max
	elseif Val < Min then
		return Min
	else
		return Val
	end
	
end

function onTick()
	
	Cele=INN(1)
	Cdirec=INN(2)
	
	Bx=INN(7)
	By=INN(8)
	Bz=INN(9)
	Xtilt=INN(10)
	Ytilt=INN(11)
	Ztilt=INN(12)
	Xdirec=-INN(13)
	Ydirec=-INN(14)
	Zdirec=-INN(15)
	PRspeed=INN(16)
	YRspeed=INN(17)
	PPpos=INN(18)
	YPpos=INN(19)
	Cgain=INN(20)
	FOVR=INN(21)/2
	MaxEle=INN(22)
	MaxDep=INN(23)
	Spos=INN(24)
	Delay=INN(25)
	FireB=INN(27)
	FOVF=INN(28)/2
	
	Shootable = INB(1)
	
	Fire = false
	PPcont = 0
	YPcont = 0
	
	debug = 0
	
	if Shootable and bShootable then
		
		Fx, Fy, Fz = DirecXYZ(Cdirec, Cele)
		Fx = Fx*1000
		Fy = Fy*1000
		Fz = Fz*1000
		LFx, LFy, LFz = World2Local(Bx, By, Bz, Bx+Fx, By+Fy, Bz+Fz, Xtilt, Ytilt, Ztilt, Xdirec, Ydirec, Zdirec)
		
		LCele = math.atan(LFz, math.sqrt(LFx^2 + LFy^2)) / (2*math.pi)
		LCdirec = math.atan(LFx, LFy) / (2*math.pi)
		
		DelLCele = Clamp(LCele, MaxEle, MaxDep) - Clamp(bLCele, MaxEle, MaxDep)
		DelLCdirec = DirecCal(LCdirec-bLCdirec)
		
		
		PPcont = (Clamp(LCele, MaxEle, MaxDep)-PPpos) * Cgain + DelLCele*12*Gear
		YPcont = DirecCal(LCdirec-YPpos) * Cgain + DelLCdirec*12*Gear
		
		Fire = IsAim(LCele, LCdirec, PPpos, YPpos) and math.abs(DirecCal(Spos-LCdirec)) < FOVR and LCele  < MaxEle and MaxDep < LCele and math.abs(DirecCal(Spos-LCdirec)) > FOVF
		
		debug = LFz
		
	else
		
		PPcont = -PPpos * Cgain
		YPcont = DirecCal(Spos-YPpos) * Cgain
		
	end
	
	
	if Shootable then
		bLCele = LCele
		bLCdirec = LCdirec
	end
	
	
	
	OUN(1, PPcont)
	OUN(2, YPcont)
	OUN(3, debug)
	
	OUB(1, Fire)
	
	bShootable = Shootable
end
