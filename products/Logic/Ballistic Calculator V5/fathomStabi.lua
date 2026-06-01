-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
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

iN=input.getNumber
iB=input.getBool
oN=output.setNumber
oB=output.setBool
pp=property
m=math
sin=m.sin
cos=m.cos
asin=m.asin
atan=m.atan
sqrt=m.sqrt
abs=m.abs
pi=m.pi
tb=table
tup=tb.unpack
pi2=pi*2
Sown_P,Stgt_P,ASown_P={0,0,0},{0,0,0},{0,0,0}
PID={}
tick=60
delay=5/tick

function onTick()	
	Qtip=EZYXtoQ(iN(13),NaN(iN(14)),iN(15))
	Qbase=EZYXtoQ(iN(19),NaN(iN(20)),iN(21))
	Qtgt=EZYXtoQ(iN(4),NaN(iN(5)),iN(6))
	Pown={iN(10),iN(11),iN(12)}
	Ptgt={iN(1),iN(2),iN(3)}

	Sown=Qrot(Qtip,{iN(16),iN(27),iN(28)})
	Stgt=Qrot(Qtgt,{iN(7),iN(8),iN(9)})
	ASown=Vscl(pi2,{iN(22),iN(23),iN(24)})

	Aown=Vscl(tick,Vsub(Sown,Sown_P))
	Atgt=Vscl(tick,Vsub(Stgt,Stgt_P))
	AAown=Vscl(tick,Vsub(ASown,ASown_P))

	Sown_P=Vcopy(Sown)
	Stgt_P=Vcopy(Stgt)
	ASown_P=Vcopy(ASown)

	Rpos=Qrot(Qconj(Qbase),Vsub(Ptgt,Pown))
	Rspd=Qrot(Qconj(Qbase),Vsub(Vcrs(ASown,Vsub(Ptgt,Pown)),Vsub(Stgt,Sown)))
	Racc=Qrot(Qconj(Qbase),Vsub(Vsum(Vcrs(ASown,Vcrs(ASown,Vsub(Ptgt,Pown))),Vcrs(AAown,Vsub(Ptgt,Pown))),Vsub(Atgt,Aown)))

	aziP,eleP,aziS,eleS=calcDAE(Rpos,Rspd,Racc,delay)
	eleC,aziC=QtoEYX(Qmult(Qconj(Qbase),Qtip))
	oN(1,LPID(0,NaN((aziC-aziP+2.5*pi2)%pi2-pi),"azi",true)+NaN(aziS/pi2*6.4))
	oN(2,LPID(0,NaN((-eleC-eleP+2.5*pi2)%pi2-pi),"ele",true)-NaN(eleS/pi2*6.4))
	
	oN(3,eleS)
end

function NaN(a)
if a~=a then
a=0
end
return a
end
function sgn(a)
return NaN(a/abs(a))
end
function atan2(x,y)
return (pi2/4-atan(y/abs(x)))*sgn(x)
end
function len(a,b,c)
c=c or 0
return sqrt(a^2+b^2+c^2)
end
function CtoP(M)
local x,y,z=tup(M)
return len(x,y,z),atan2(x,z),atan(y/len(x,z))
end
function PtoC(d,a,e)
return {d*sin(a)*cos(e),d*sin(e),d*cos(a)*cos(e)}
end

function calcDAE(P,V,A,d)
local px,py,pz=tup(P)
local vx,vy,vz=tup(V)
local ax,ay,az=tup(A)
local dp,ap,ep,ds,as,es,da,aa,ea,hp
dp,ap,ep=CtoP(P)
hp=len(px,pz)
as=(px*vz-pz*vx)/hp^2
es=(-py*(px*vx+pz*vz)+vy*hp^2)/(hp*dp^2)
aa=(2*px*pz*(ax-az)+hp^2*(-ax*pz+az*px))/hp^4
ea=(-2*ay*py*hp^4+ay*hp^4*dp^2-py*hp^2*(ax*px+az*pz)*dp^2+py*(ax*(2*px^2*hp^2+px^2*dp^2-hp^2*dp^2)+az*(2*pz^2*hp^2+pz^2*dp^2-hp^2*dp^2)))/(hp^3*dp^4)
ap,ep=ap+aa*d^2/2,ep+ea*d^2/2
as,es=as+aa*d,es+ea*d
return ap,ep,as,es
end

function EXtoQ(x)
return {sin(x/2),0,0,cos(x/2)}
end
function EYtoQ(y)
return {0,sin(y/2),0,cos(y/2)}
end
function EZtoQ(z)
return {0,0,sin(z/2),cos(z/2)}
end
function EZYXtoQ(x,y,z)
return Qmult(Qmult(EZtoQ(z),EYtoQ(y)),EXtoQ(x))
end
function EYXtoQ(x,y)
return Qmult(EYtoQ(y),EXtoQ(x))
end
function QtoEYX(q)
local x,y,z,w=tup(q)
return asin(-2*y*z+2*x*w),atan2((2*x*z+2*y*w),(2*w^2+2*z^2-1))
end
function Qmult(q,p)
local x,y,z,w=tup(q)
local a,b,c,d=tup(p)
return{w*a+x*d+y*c-z*b,w*b+y*d+z*a-x*c,w*c+z*d+x*b-y*a,w*d-z*c-y*b-x*a}
end
function Qconj(q)
local x,y,z,w=tup(q)
return{-x,-y,-z,w}
end
function Qrot(q,v)
v[4]=0
local x,y,z,w=tup(Qmult(Qmult(q,v),Qconj(q)))
return{x,y,z}
end

function Vsum(A,B)
local a,b,c=tup(A)
local d,e,f=tup(B)
return{a+d,b+e,c+f}
end
function Vsub(A,B)
local a,b,c=tup(A)
local d,e,f=tup(B)
return{a-d,b-e,c-f}
end
function Vscl(n,A)
local a,b,c=tup(A)
return{a*n,b*n,c*n}
end
function Vdot(A,B)
local a,b,c=tup(A)
local d,e,f=tup(B)
return a*d+b*e+c*f
end
function Vcrs(A,B)
local a,b,c=tup(A)
local d,e,f=tup(B)
return{b*f-c*e,c*d-a*f,a*e-b*d}
end
function Vcopy(A)
local a,b,c=tup(A)
return{a,b,c}
end

function LPID(sp,pv,name,on)
local data,p,i,d=PID[name]
if PID[name]==nil then
data=txt(name)
data[4]=0
data[5]=0
end
p=sp-pv
i=(p+data[5])/2+data[4]
d=p-data[5]
data[4]=i
data[5]=p
PID[name]=data
if on then
return p*data[1]+i*data[2]+d*data[3]
end
return 0
end
function txt(name)
local A={}
for str in string.gmatch(pp.getText(name),'%-*%w+%.*%w*')do
tb.insert(A,tonumber(str)or str)
end
return A
end