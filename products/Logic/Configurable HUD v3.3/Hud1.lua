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

vvSiz=2
pi=math.pi
pi2=2*pi
inN=input.getNumber
inB=input.getBool
s=math.sin
c=math.cos
t=math.tan
at=math.atan
abs=math.abs
min=math.min
drawT=screen.drawText
drawL=screen.drawLine
drawR=screen.drawRect
drawRF = screen.drawRectF
setC = screen.setColor
form = string.format
function sgn(x)
	if x==0 then return 0
	else return x/abs(x)
	end
end
function devAng(q,q0,qt,cw)
	return -cw*(q-q0+(1-qt))%1-(1-qt)
end
function rotV2Z(x,y,qz)
	qz=qz*pi2
	return x*c(qz)-y*s(qz),x*s(qz)+y*c(qz)
end
function updnText(x,posX,posY,xRange,xPitch,xScale,scale,label,LimU,LimB)
	posY = math.floor((LimB - LimU)/2 + posY)
    wordcount = #tostring(math.floor(x))
	if label then
		drawT(posX - wordcount*5 + 17, posY-2, math.floor(x))
		drawR(posX-5,posY-4, 22, 8)
	end
	if scale then
		for i=0,math.floor(xRange/(xPitch/xScale)) do
			xmod=x%xPitch
			xint=i*xPitch
			if (xmod-xint)*xScale<-7 and (xmod-xint)*xScale>-LimU then
                wordcount = #tostring(math.floor(x-xmod+xint))
				drawT(posX - wordcount*5 + 17, posY+(xmod-xint)*xScale, math.floor(x-xmod+xint))
			end
			if (xmod+xint)*xScale>5 and (xmod+xint)*xScale<LimB then
                wordcount = #tostring(math.floor(x-xmod-xint))
				drawT(posX - wordcount*5 + 17, posY+(xmod+xint)*xScale, math.floor(x-xmod-xint))
			end
		end
	end
end

function onTick()
	altunit=inN(11)
	alt=inN(1)*altunit
	Vunit=inN(12)
	dirV=inN(2)*Vunit
	horV=inN(3)*Vunit
	verV=inN(4)*Vunit
	rol0=inN(5)
	pit0=inN(6)
	vtilt=inN(7)
	rol=rol0-min(0,sgn(vtilt))*(sgn(rol0)*0.5-2*rol0)
	pit=math.asin(s(pit0*pi2)/c(rol*pi2))/pi2
	comp=devAng(inN(8),0,1,1)
	dAlt=inN(9)*altunit
--qx,qz=as(s(qx)/c(qy))
	r=inN(13)
	ladSc=inN(14)
	cOpt=inN(15)
	style=inN(16)
	compInt=inN(18)
	dNumC=math.floor(360/compInt)
	ss=inB(3)
	sl=inB(4)
	as=inB(5)
	al=inB(6)
	cs=inB(7)
	cl=inB(8)
	vv=inB(9)
	ll=inB(10)
	vvel=inB(11)
	absV=(dirV^2+horV^2+verV^2)^0.5
end

function onDraw()
	w=screen.getWidth()
	h=screen.getHeight()

	if cs then sideDy=-11 else sideDy=0 end
	sideLimB=h/2+sideDy
	if vvel then altDx=-18 else altDx=-16 end
	altx=w+altDx

	if style==0 then
--		setC(0,0,0,255)
--		screen.drawClear()
	else
		setC(60,20,10)
		screen.drawClear()
		setC(30,30,255)
		hP=r*t(-pit*pi2)
		mR=t(rol*pi2)
		pux,puy=w/2+(-hP+h/2)/mR,0
		pdx,pdy=w/2+(-hP-h/2)/mR,h

		if vtilt>0 then
			ptx,pty=pdx,puy
		else
			ptx,pty=pux,pdy
		end
		qux,quy=pdx-sgn(rol)*w,puy
		qdx,qdy=pdx-sgn(rol)*w,pdy
		screen.drawTriangleF(pux,puy,pdx,pdy,ptx,pty)
		if rol>0 then
			if vtilt>0 then
				drawRF(0,0,pdx,h)
			else
				drawRF(0,0,pux,h)
			end
		else
			if vtilt>0 then
				drawRF(pdx,0,w-pdx,h)
			else
				drawRF(pux,0,w-pux,h)
			end
		end
	end

	if cOpt == 0 or cOpt == 1 then setC(0, 255, 0) elseif cOpt == 2 then setC(63,63,63) end
	screen.drawCircleF(w/2,h/2,1)
	for i=-1,1,2 do
		drawL(w/2+i*w*ladSc*vvSiz/6,h/2,w/2+3*i*w*ladSc*vvSiz/6,h/2)
		drawL(w/2+i*w*ladSc*vvSiz/6,h/2,w/2+i*w*ladSc*vvSiz/6,h/2+h*ladSc*vvSiz/6)
	end

	setC(0,0,0,127)
	if sl then drawRF(0,h/2+sideDy/2-4,22,8) end
	if al then drawRF(altx-7,h/2+sideDy/2-4,22,8) end
	if cl then drawRF(w/2-8,h-9,17,8) end

--compass
	if cOpt == 0 then setC(0, 255, 0) elseif cOpt == 1 then setC(255, 0, 0) elseif cOpt == 2 then setC(255, 255, 255) end
	if cl then
		drawT(w/2-6,h-7,form("%3.0f",comp*360))
		drawR(w/2-8,h-9, 17, 8)
		if cs then drawL(w/2,h-9,w/2,h-17) end
	end
	if cs then
		for i=0,dNumC-1 do
		angYaw = devAng(i*compInt/360,comp,0.5,-1)
			if abs(angYaw)<at(w/1.5/r)/pi2 then
				drawL(w/2+r*t(angYaw*pi2), h-11, w/2+r*t(angYaw*pi2), h-17)
				if cl then cRange=at(11/r)/pi2 else cRange=0 end
				if abs(angYaw)>cRange then
					drawT(w/2+r*t(angYaw*pi2)-4,h-7,form("%2.0f",i*compInt/10))
				end
			end
		end
	end
	
--velocity
	updnText(absV,5,h/2,20,5,2.5,ss,sl,h/2,sideLimB)
--altitude
	updnText(alt,altx-2,h/2,20,5,2.5,as,al,h/2,sideLimB)
--vertical speed
	if vvel then
		if dAlt<0 then vvelx=w-2 else vvelx=w-1 end
		drawRF(vvelx,(sideLimB-h/2)/2+h/2,2,-dAlt*h/1)
	end
end


