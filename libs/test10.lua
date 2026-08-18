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


Y=false
W=true
M=math
E=output.setNumber
X=M.sqrt
R=property.getNumber
d=input.getNumber
aj=M.atan
D=M.exp
u=M.abs
g=M.sin
n=M.cos
function aL(ax,ae,ab,q)ab={}for A=1,#ax do
ab[A]={}for aE=1,#ae[1]do
q=0
for _=1,#ae do q=q+ax[A][_]*ae[_][aE]end
ab[A][aE]=q
end
end
return ab
end
function aT(ap,G,I,C)G,I,C=ap.b,ap.e,ap.f
return{{n(I)*n(C),g(G)*g(I)*n(C)+g(C)*n(G),g(G)*g(C)-g(I)*n(G)*n(C)},{-g(C)*n(I),-g(G)*g(I)*g(C)+n(G)*n(C),g(G)*n(C)+g(I)*g(C)*n(G)},{g(I),-g(G)*n(I),n(G)*n(I)}}end
function z(j,l,ad,L,ac,q,A,m,h,H,O,aa)m=ad(j)h=ad(l)if m*h>0 then return 0 end
if u(m)<u(h)then
j,l=l,j
m,h=h,m
end
L=j
H=m
q=0
ac=0
O=W
A=0
while(h~=0 or u(l-j)>an)and A<30 do
A=A+1
if m~=H and h~=H then
q=(j*h*H)/((m-h)*(m-H))+(l*m*H)/((h-m)*(h-H))+(L*m*h)/((H-m)*(H-h))else
q=l-h*(l-j)/(h-m)end
if(q-(3*j+l)/4)*(q-l)>=0 or
O and u(q-l)>=u(l-L)/2 or
not(O)and u(q-l)>=u(L-ac)/2 or
O and u(l-L)<u(an)or
not(O)and u(L-ac)<u(an)then
q=(j+l)/2
O=W
else
O=Y
end
ac,L,H=L,l,h
aa=ad(q)if m*aa<0 then
l=q
h=aa
else
j=q
m=aa
end
if u(m)<u(h)then
j,l=l,j
m,h=h,m
end
end
return l
end
function J(a)p=D(-_*a)w=1-p
F,x=0,0
if t>0 and a>o then
F=a-o
x=1-D(-_*F)end
return B^2+(y+s*a/_-s/_^2*w)^2-((K/_)*w+t*((a-F)/_-w/_^2+x/_^2))^2
end
function aJ(a)p=D(-_*a)x=1-p
return(2*s/_*x)*(s*a/_-s*x/_^2+y)-(-2*t/_*x+2*K*p)*(-t*a/_+(t/_^2+K/_)*x)end
function at(a)p=D(-_*a)F=a-o
w=1-p
return(2*s/_*w)*(s*a/_-s*w/_^2+y)-(2*t/_*w+2*K*p)*(t*((a-F)/_-w/_^2+D(-_*F)/_^2)+K*w/_)end
function aM(a)p=D(-_*a)return aj(y-s/_^2*(1-p)+s/_*a,B)end
function ao(a,j,v,b,e,f,B,y)p=D(-_*a)w=1-p
b=ai(k.b,k.aG,k.ar,ak.b,S.b,p,a)e=ai(k.e,k.av,k.aA,ak.e,S.e,p,a)f=ai(k.f,k.aH,k.aB,ak.f,S.f,p,a)j=aj(b,e)v=aM(a)F,x=0,0
if t>0 and a>o then
F=a-o
x=1-D(-_*F)end
B=K*n(v)*w/_+t*n(v)*((a-F)/_-w/_^2+x/_^2)+V*n(v)y=(s/_^2+K*g(v)/_)*w-s/_*a+t*g(v)*((a-F)/_-w/_^2+x/_^2)+V*g(v)-af
return{v=v,j=j,B=B,y=y,b=b,e=e,f=f}end
function ai(b,aS,j,P,S,p,a)x=(T==_ or U)and(1-D(-T*a))/T or a
aF=a+aO
P=P-S
P=P<40 and P or 40
return b+aS*aF+aP*j*aF^2/2-S*x-P*ag/_^2*(1-p)+P*ag/_*a
end
function az(b)return(((44.33-b/1000)/11.89)^5.256)/1013
end
function as()c=z(0,o,J)or 0
r=c==0 and z(0,o,at)or 0
c=r>0 and z(0,r,J)or c
c=c==0 and z(r,o,J)or c
r=c==0 and z(o,Q,at)or 0
c=r>0 and z(o,r,J)or c
c=(c==0 or U)and z(r,Q,J)or c
end
function aW(c)aD=s+_*K*g(i.v)au=(c*aD/_^2-c^2*s/(2*_)+aD*(D(-c*_)-1)/_^3)/c
return au<0 and 0 or au
end
function aZ()aw=aW(c)ag=aC*az(aw)*.965
s=30*D(-1/60*aw/1000)end
aK={{800,1.5,5,.15,520,3.6},{1000,1.2,5,.135,815,3.3},{1000,.6,5,.13,1500,3.8},{900,.3,10,.125,2700,9.8},{800,.12,60,.12,5200,15},{700,.06,60,.11,7000,20},{600,.03,60,.105,7500,22},{50,.18,60,.125,2100,5.4,600,1,.1}}pi=M.pi
b_=pi*2
aY=1/60
an=.01
i={b=0,e=0,f=0,j=0,v=0,B=0,y=0}function onTick()aq=d(32)am={b=R("gunX")*.25,e=R("gunY")*.25,f=R("gunZ")*.25}aO=R("DelayTicks")*aY
V=R("barrelLength")*.25
aR=aq>0 and W or Y
aQ=aq==2 and W or Y
U=aq==3 and W or Y
aP=d(31)if aR then
Z={b=-d(13),e=-d(14),f=-d(15)}aN=aT(Z)al=aL(aN,{{am.b},{am.f},{am.e}})N={b=d(10)+al[1][1],e=d(11)+al[3][1],f=d(12)+al[2][1]}k=(U or aQ)and{b=d(23)-N.b,aG=0,ar=0,e=d(24)-N.e,av=0,aA=0,f=d(25)-N.f,aH=0,aB=0}or{b=d(1)-N.b,aG=d(2),ar=d(3),e=d(4)-N.e,av=d(5),aA=d(6),f=d(7)-N.f,aH=d(8),aB=d(9)}S={b=d(16),e=d(18),f=d(17)}ah=az(N.f)ak={b=d(19)/ah,e=d(20)/ah,f=d(21)/ah}s=30
K,_,Q,aC,ay,aU,t,o,T=table.unpack(aK[R("GUNSTYPE")])t=t and t or 0
T=T and T or _
o=o and o or 0
B,y=0,0
ag=aC
af=0
aX=X(k.b^2+k.f^2+k.e^2)if aX<ay-50 then
B=X(k.b^2+k.e^2)-V
y=k.f
elseif k.b^2+k.e^2<(ay+500)^2 then
i=ao(aU)B=X(i.b^2+i.e^2)y=i.f
end
if B~=0 then
if t>0 then
as()else
r=z(0,Q,aJ)r=r>0 and r<Q and r or Q
c=U and z(r,Q,J)or z(0,r,J)end
if c>0 then
i=ao(c)A=0
repeat
B=X(i.b^2+i.e^2)-V*n(i.v)aI=c<o and o-c or o
af=n(i.v)*330*aI*g(aj(14,330))/2
y=i.f-V*g(i.v)+af
aZ()aV=c
if t>0 then
as()else
c=U and z(r,Q,J)or z(0,r,J)end
if c==0 then break end
c=(aV+c)/2
i=ao(c)A=A+1
until u(i.b^2+i.e^2-i.B^2)<.125^2 and u(i.y-i.f)<.125 or A>30
end
end
E(1,c)E(2,i.j)E(3,i.v)E(4,d(29))E(5,d(30))E(6,k.b)E(7,k.e)E(8,k.f)E(10,Z.b)E(11,Z.e)E(12,Z.f)end
end
