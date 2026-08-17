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

local m=math
local sin,cos,atan,exp,abs,sqrt,rad,tan,asin,pi2,tup,min,max=m.sin,m.cos,m.atan,m.exp,m.abs,m.sqrt,m.rad,m.tan,m.asin,m.pi*2,table.unpack,m.min,m.max
local pN,iN,oN,iB,oB,pB=property.getNumber,input.getNumber,output.setNumber,input.getBool,output.setBool,property.getBool
x,y,z=0,0,0
TY=0
tz=0
Prait=pN("Elevation gear ratio (1 : ?)")
Yrait=pN("Azimuth gear ratio (1 : ?)")
delay=pN('Processing Delay')
hi=pN('Limit Right (Deg)')/360
mi=pN('Limit Left (Deg)')/360
Rangle=pN('Limit Down (Deg)')/360
Hangle=pN('Limit Up (Deg)')/360
intial=pN('Initial Azimuth (Deg)')/360
intialE=pN('Initial Elevation (Deg)')/360
gain=pN('Tracking Sensitivity')*0.1*((Prait+Yrait)/2)
yuse=pN('Pivot Type Azimuth')
puse=pN('Pivot Type Elevation')
ocX=pN('Offset X')
ocY=pN('Offset Y')
ocZ=pN('Offset Z')
pmt=pN('Max Speed Elevation')*0.01
ymt=pN('Max Speed Azimuth')*0.01
pStab=pN('Elevation Stab Gain')*0.01*Prait
yStab=pN('Azimuth Stab Gain')*0.01*Yrait
Rp=pB('Enable Elevation Limit')
Ry=pB('Enable Azimuth Limit')
if Ry then
Ryn=1
else
hi=0.5
mi=-0.5
Ryn=0
end
if Rp then
Rpn=1
else
Hangle=0.5
Rangle=-0.5
Rpn=0
end
type=pN('Weapon Type')//1|0
params={{800,.025,120,.15},{1000,.02,150,.135},{1000,.01,300,.13},{900,.005,600,.125},{800,.002,1500,.12},{700,.001,2400,.11},{600, .0005,2400,.105},
}
type=type<1 and 1 or type>#params and #params or type
vel=params[type][1]/60
base_drag=params[type][2]
lifeSpan=params[type][3]
WindInf=params[type][4]
g=30/(60^2)
error=0.1
f=false
offset=0
time=0
time=0
P,G={},{}
for i=0,443 do
table.insert(P,(((44.33-i/10)/11.89)^5.256)/1013)
table.insert(G,30*exp(-1/60*i/10)/3600)
end
function bS(p,v,a,k,dt,ex)
local invK=1/k
local nextP=p+(a*invK)*dt+(v-a*invK)*invK*(1-ex)
local nextV=v*ex+(a*invK)*(1-ex)
return nextP,nextV
end
dt=6
k_base=-m.log(1-base_drag)
ex=exp(-k_base*dt)
function SP(th,ph,X,Bx,By,Bz,Wx,Wy,Wz,startH)
local NX={}
local ntx,nty,ntz=X[1],X[2],X[3]
local px,py,pz,oldX,oldY,oldZ=0,0,0,0,0,0
local vx,vy,vz=vel*cos(th)*sin(ph)+Bx,vel*sin(th)+By,vel*cos(th)*cos(ph)+Bz
local oldX,oldY,oldZ=px,py,pz
for t=0,lifeSpan,dt do
NX=PF(X,t)
local dis1=NX[1]*NX[1]+NX[3]*NX[3] 
local dis3=px*px+pz*pz
if dis3>=dis1 then
local dis1a=sqrt(dis1)
local disOld=sqrt(oldX*oldX+oldZ*oldZ)
local dis3a=sqrt(dis3)
local fraction=(dis1a-disOld)/(dis3a-disOld+1e-6)
local hitTime=t-dt+(dt*fraction)
local FNX=PF(X,hitTime)
local hitY=oldY+(py-oldY)*fraction
return hitY-FNX[2],hitTime,true,px,pz,FNX[1],FNX[3]
end
oldX,oldY,oldZ=px,py,pz
local raw_h=(startH+py)/100
local I=m.floor(max(0,min(441,raw_h)))
local frac=raw_h-I
local p1=P[I+1]+(P[I+2]-P[I+1])*frac
local g1=G[I+1]+(G[I+2]-G[I+1])*frac
local ax,ay,az=Wx*p1*(WindInf/60),Wy*p1*(WindInf/60)-g1,Wz*p1*(WindInf/60)
px,vx=bS(px,vx,ax,k_base,dt,ex)
py,vy=bS(py,vy,ay,k_base,dt,ex)
pz,vz=bS(pz,vz,az,k_base,dt,ex)
if py+startH<-10 then break end
end
return -999,lifeSpan,false,px,pz,NX[1],NX[3]
end
function SB(X,Bx,By,Bz,Wx,Wy,Wz,startH,HA)
local f=false
local tx,ty,tz=X[1],X[2],X[3]
local sx,sy,sz=X[4],X[5],X[6]
local ax,ay,az=X[7],X[8],X[9]
local t=isHighArc and lifeSpan or sqrt(tx*tx+ty*ty+tz*tz)/vel
tx,ty,tz=tx+sx*t+ax*t*t*0.5,ty+sy*t+ay*t*t*0.5,tz+sz*t+az*t*t*0.5
local targetAng=atan(tx,tz)
local ph=targetAng
local low,high
if HA then
low=rad(45)
high=rad(89)
else
low=rad(-30)
high=rad(45)
end
local th=(low+high)/2
for i=1,15 do
local errY,t_res,reached,fX,fZ,tTX,tTZ=SP(th,ph,X,Bx,By,Bz,Wx,Wy,Wz,startH)
if reached then
if abs(errY)<0.1 then f=true break end
if errY>0 then
if HA then low=th else high=th end
else
if HA then high=th else low=th end
end
local shellAng=atan(fX,fZ)
local targetFutureAng=atan(tTX,tTZ)
ph=ph+(targetFutureAng-shellAng)
else
if HA then high=th else low=th end
end
local next_th=(low+high)/2
if abs(next_th-th)<0.0001 then f=true break end
th=next_th
end
return th,ph,t_res,f
end
function PF(x,t)
local px,py,pz=x[1],x[2],x[3]
local vx,vy,vz=x[4],x[5],x[6]
local ax,ay,az=x[7],x[8],x[9]
local vv=vx*vx+vy*vy+vz*vz
local aa=ax*ax+ay*ay+az*az
local va=vx*ax+vy*ay+vz*az
local v_mag=sqrt(vv)+1e-6
local vxa_sq=vv*aa-va*va
if vxa_sq<0 then vxa_sq=0 end 
local vxa_mag=sqrt(vxa_sq)
local mix=(vxa_mag/v_mag)*333.333
if mix>1 then mix=1 elseif mix<0 then mix=0 end
local h=0.5*t*t
return {px+vx*t+ax*h,py+vy*t+ay*h,pz+vz*t+az*h}
end
function clamp(x,min,max)
y=false
if x~=x then x=min  
f=false end
if x<min then x=min y=true
f=false end
if x>max then x=max y=true
f=false end
return x,y
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
return Qmult(Qmult({0,0,sin(z/2),cos(z/2)},{0,sin(y/2),0,cos(y/2)}),{sin(x/2),0,0,cos(x/2)})
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
function E2(Q)
local Vfw=Qrot(Q, {0, 0, 1})
local Vh={Vfw[1],0,Vfw[3]}
local yaw_rad=atan(Vh[1],Vh[3])
local hy=yaw_rad*0.5
local q_pitch_roll=Qmult(Qconj({0,sin(hy),0,cos(hy)}),Q)
local x,y,z,w=q_pitch_roll[1],q_pitch_roll[2],q_pitch_roll[3],q_pitch_roll[4]
local pitch_rad=asin(max(-1.0,min(1.0,2*(w*x-y*z))))
local roll_rad=atan(2*(w*z+x*y),1-2*(x*x+z*z))
return {pitch_rad,yaw_rad,roll_rad}
end
function W2La(pitch,yaw,Q)
local cp=cos(pitch)
local sp=sin(pitch)
local cy=cos(yaw)
local sy=sin(yaw)
local wv={sy*cp,sp,cy*cp}
local lv=Qrot(Qconj(Q), wv)
local lx,ly,lz=tup(lv)
local nyaw= atan(lx, lz) 
local npitch =asin(max(-1.0,min(1.0,ly)))
return npitch,nyaw
end
function EV(x,y,z,ax,ay,az)
local AV=Qrot(Qconj(EZYXtoQ(x,y,z)),{ax,ay,az})
return AV
end
function l2w(x,y,z,ex,ey,ez,tx,ty,tz) local c1,c2,c3,s1,s2,s3=cos(ez),cos(ey),cos(ex),sin(ez),sin(ey),sin(ex) local TM={c1*c2,c2*s1,-s2,c1*s2*s3-c3*s1,c1*c3+s1*s2*s3,c2*s3,s1*s3+c1*c3*s2,c3*s1*s2-c1*s3,c2*c3} return TM[1]*tx+TM[4]*ty+TM[7]*tz+x,TM[2]*tx+TM[5]*ty+TM[8]*tz+y,TM[3]*tx+TM[6]*ty+TM[9]*tz+z end
function onTick()
local nx,nz,ny,ax,ay,az,ex,ey,ez,ex2,ey2,ez2=iN(1)-iN(10),iN(2)-iN(12),iN(3)-iN(11),iN(7),iN(8),iN(9),iN(13),iN(14),iN(15),iN(24),iN(25),iN(26)
local PX,PY=0, 0
if puse==1 or yuse==1 then
V=E2(Qmult(Qconj(EZYXtoQ(ex,ey,ez)),EZYXtoQ(ex2,ey2,ez2)))
PX=((((V[2])/-pi2)%1+2.5)%1-0.5)*-1
PY=V[1]/-pi2
else
PX=iN(16)
PY=iN(17)
end
local nocX,nocY,nocZ=l2w(0,0,0,ex,ey,ez,ocX,ocY,ocZ)
local sx1,sy1,sz1=l2w(0,0,0,ex,ey,ez,(iN(18)/60),(iN(19)/60),(iN(20)/60))
local nsx,nsy,nsz,ax,ay,az,Wr,Ws,Wr2,Ws2=iN(4),iN(6),iN(5),iN(7),iN(8),iN(9),iN(22)*pi2,iN(23)/60,iN(27)*pi2,iN(28)/60
local Wx,Wy,Wz=sin(Wr)*-Ws-sx1,sin(Wr2)*Ws2-sy1,cos(Wr)*-Ws-sz1
local nWx,nWy,nWz=l2w(0,0,0,ex,ey,ez,Wx,Wy,Wz)
local X={nx-nocX,ny-nocY,nz-nocZ,nsx,nsy,nsz,ax,ay,az}
f=false
th,ph,t_new,f=SB(X,sx1,sy1,sz1,nWx,nWy,nWz,iN(11),iB(3))
if iB(2) then
f=false
end
oB(1,f)
local Q=EZYXtoQ(ex,ey,ez)
local ty,tx=W2La(th,ph,Q)
tx,ty=tx/pi2,ty/pi2
if yuse>=0 and yuse<=1 then
ty,tyB=clamp(ty-intialE*Rpn,Rangle,Hangle)
else
ty,tyB=clamp(ty,Rangle+intialE,Hangle+intialE)
Rpn=0
end
if puse>=0 and puse<=1 then
tx,txB=clamp(tx-intial*Ryn,mi,hi)
else
tx,txB=clamp(tx,mi+intial,hi+intial)
end
if txB or tyB then
tx=intial*-(Ryn-1)
ty=intialE*-(Rpn-1)
oB(1,false)
end
if f and iB(1)then
else
tx=intial*-(Ryn-1)
ty=intialE*-(Rpn-1)
f=false
end
if iB(2)then
tx=intial*-(Ryn-1)
ty=intialE*-(Rpn-1)
f=false
end
nV=EV(ex,ey,ez,iN(29),iN(30),iN(31))
nV2=Qrot(Qconj(EYtoQ(PX*pi2)),nV)
if puse>=0 and puse<=1 then
oN(2,clamp((((ty%1+2.5)%1-0.5)-(((PY-intialE)%1+2.5)%1-0.5))*gain,-1,1)*pmt*Rpn+clamp(((ty-PY%1+2.5)%1-0.5)*gain,-1,1)*pmt*-(Rpn-1)-nV2[1]*-pStab)
else
if puse==2 then
oN(2,ty*4)
else
oN(2,ty)
end
end
if yuse>=0 and yuse<=1 then
oN(1,clamp((((tx%1+2.5)%1-0.5)-(((PX-intial)%1+2.5)%1-0.5))*gain,-1,1)*ymt*Ryn+clamp(((tx-PX%1+2.5)%1-0.5)*gain,-1,1)*ymt*-(Ryn-1)-nV[2]*yStab)
else
if yuse==2 then
oN(1,tx*4)
else
oN(1,tx)
end
end
end