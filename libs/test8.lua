-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/id/SacabambaspisSacabambaspis/myworkshopfiles/
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

i,o,p,m=input,output,property,math
pgn,pgb,gn,gb,sn,sb=p.getNumber,p.getBool,i.getNumber,i.getBool,o.setNumber,o.setBool
abs,min,max,pi,pi2,sin,cos,tan,atan,asin,sqrt,exp=m.abs,m.min,m.max,m.pi,m.pi*2,m.sin,m.cos,m.tan,m.atan,m.asin,m.sqrt,m.exp
t,f=true,false

function clamp(x,y,z)
return max(min(x,max(z,y)),min(y,z))
end

function sgn(x)
return x>=0 and 1 or -1
end

function ran(a)
return a-(abs(a)>0.5 and sgn(a) or 0)
end

function dis(t0)
local e=1-exp(-b*t0)
local m,k=(l0*b^2+wx*e-wx*t0*b)^2,(wz*e-b*wz*t0)^2
return sqrt(v^2*e^2-(m+k)/(b^2))+g*e/b-g*t0-ly*b
end

function bis(t1,t2)
local er,t3,s1,s2,s3=f,0,0,0,0
for i=1,12 do
t3=(t1+t2)/2
if abs(t1-t2)<1 then break
end
s1,s2,s3=sgn(dis(t1)),sgn(dis(t2)),sgn(dis(t3))
if s1==s2 then
er,t3=t,0
break
elseif s1==s3 then t1=t3
else t2=t3
end
end
return er,t3
end

typ=pgn("Cannon type")
pr=pgb("Rotation pivot type")
pe=pgb("Elevation pivot type")
wp=pgb("Wind sensor placed")
ps0=pgn("Pivots speed")
lm1=pgn("Rotation right limit")/360
lm2=pgn("Rotation left limit")/360
lm1=pr and min(lm1,0.25) or lm1
lm2=pr and min(lm2,0.25) or lm2
lm3=pgn("Elevation upper limit")/180
lm4=pgn("Elevation lower limit")/180

bal={
{80,0.025,150,150,1.6,0.02},
{100,0.02,300,300,0.9,0.02},
{90,0.005,600,600,0.4,0.02},
{100,0.01,300,300,0.5,0.02},
{65,0.003,3600,720,0.33,0.02},
{80,0.002,3600,1058,0.255,0.02},
{70,0.00098,3600,1268,0.22,0.01},
{60,0.0005,3600,1347,0.21,0.005}}

v,b,tl,tm,w,ps=bal[typ][1]/6,bal[typ][2],bal[typ][3],bal[typ][4],bal[typ][5]*0.0001,bal[typ][6]*ps0

g=1/120
ar0=0
i1=0

function onTick()

ind=gb(1) and typ>4

a1=gn(18)
a2=gn(19)
a3=gn(20)
a4=gn(4)
a5=gn(5)
a6=gn(6)

sx=gn(1)
sy=gn(2)
sz=gn(3)
tx=gn(21)
tz=gn(22)
ty=gn(23)

ws=gn(24)
wa=gn(25)

c1=cos(a1)
s1=sin(a1)
c2=cos(a2)
s2=sin(a2)
c3=cos(a3)
s3=sin(a3)
c4=cos(a4)
s4=sin(a4)
c5=cos(a5)
s5=sin(a5)
c6=cos(a6)
s6=sin(a6)

m11=c3*c2
m12=s1*s2*c3-c1*s3
m13=s3*s1+c3*c1*s2
m21=c2*s3
m22=c1*c3+s1*s2*s3
m23=c1*s3*s2-c3*s1
m31=-s2
m32=s1*c2
m33=c2*c1

v1=s4*s5*c6-c4*s6
v2=c4*c6+s4*s5*s6
v3=s4*c5

ty=ty==0 and sy or ty

lx=tx-sx
ly=ty-sy
lz=tz-sz
l0=sqrt(lx^2+lz^2)
l1=sqrt(l0^2+ly^2)
a0=atan(lx,lz)

aa1=asin(v2)
aa2=atan(v1,v3)

ar1=asin(clamp(v1*m12+v2*m22+v3*m32,-0.9999,0.9999))/pi
ar2=atan(v1*m11+v2*m21+v3*m31,v1*m13+v2*m23+v3*m33)/pi2
ar0=(v1*v2*v3~=0 and ar0==0) and ar2+1 or ar0
ar3=ran(ar2-(ar0-1))

wa0=wp and ran(wa+ar2) or wa
wa1=atan(tan(wa0*pi2)*m33-m31,m11-tan(wa0*pi2)*m13)/pi2
wa2=abs(wa0)>0.25 and wa1-0.5*sgn(wa1) or ran(wa1)
wa3=-(pi/2-a0+wa2*pi2)
ws1=ws/max(sqrt(1-(m12*sin(wa2*pi2)+m32*cos(wa2*pi2))^2),0.001)
wx,wz=ws1*w*sin(wa3),ws1*w*cos(wa3)

if tx==0 and tz==0 then
er1,er2,er3=t,f,f
elseif ind and l0<100 or not ind and l1<5 then
er1,er2,er3=f,t,f
else
er1,er2=f,f
v=(typ==5 and not ind) and max(8.3*l0^0.26,30)/6 or bal[typ][1]/6
er3,t1=bis(ind and tm or 1,ind and tl or tm)
if not er3 then

local e=1-exp(-b*t1)
a01=asin(clamp((ly*b^2+g*t1*b-g*e)/(v*b*e),-0.9999,0.9999))
a02=a0+asin(clamp(wz*(e-b*t1)/(v*b*e*cos(a01)),-0.9999,0.9999))

v5=cos(a01)*sin(a02)
v6=sin(a01)
v7=cos(a01)*cos(a02)

a1=asin(clamp(v5*m12+v6*m22+v7*m32,-0.9999,0.9999))/pi
a2=atan(v5*m11+v6*m21+v7*m31,v5*m13+v6*m23+v7*m33)/pi2
a3=ran(a2-(ar0-1))

end
end

if er1 or er2 or er3 then
er4,t1,i1=f,0,0

if er1 then
a1,a3=0,0
else
a1,a3=ar1,ar3
end

elseif a1>lm3 or a1<lm4 or a3<-lm2 or a3>lm1 then
er4,a1,a3,i1=t,ar1,ar3,0
else
er4=f
i1=(abs(a1-ar1)<0.01 and abs(a1)<0.495) and clamp(i1+0.05*clamp(a1-ar1,-0.001,0.001),-0.002,0.002) or 0
a1=clamp(a1,lm4,lm3)
a3=clamp(a3,-lm2,lm1)
end

if pe then
p1=clamp(3.5*(a1-ar1)+i1,-ps,ps)
elseif a1~=ar1 then
p1=2*clamp(ar1+i1+clamp(a1-ar1,-ps*0.4,ps*0.4),lm4,lm3)
end

if pr and a1~=ar1 then
p2=4*clamp(-ar3-clamp(a3-ar3,-ps*0.2,ps*0.2),-lm1,lm2)
else
p2=clamp(3.5*(lm1*lm2<0.25 and ar3-a3 or ran(ar3-a3)),-ps,ps)
end

sb(1,er1)
sb(2,er2)
sb(3,er3)
sb(4,er4)

sn(1,m.floor(t1))
sn(2,p1)
sn(3,p2)
sn(4,ar1)
sn(5,rx)
sn(6,ry)
sn(7,rz)
sn(8,a1-ar1)
sn(9,ar3-a3)
end