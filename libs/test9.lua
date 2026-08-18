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


S=.25
ad=false
X=true
M=math
A=output.setNumber
Z=M.sqrt
c=input.getNumber
U=property.getNumber
aL=M.atan
D=M.exp
u=M.abs
f=M.sin
h=M.cos
function aG(aJ,an,aa,r)aa={}for B=1,#aJ do
aa[B]={}for ay=1,#an[1]do
r=0
for _=1,#an do r=r+aJ[B][_]*an[_][ay]end
aa[B][ay]=r
end
end
return aa
end
function aX(ao,E,H,F)E,H,F=ao.b,ao.d,ao.e
return{{h(H)*h(F),f(E)*f(H)*h(F)+f(F)*h(E),f(E)*f(F)-f(H)*h(E)*h(F)},{-f(F)*h(H),-f(E)*f(H)*f(F)+h(E)*h(F),f(E)*h(F)+f(H)*f(F)*h(E)},{f(H),-f(E)*h(H),h(E)*h(H)}}end
function x(i,n,ap,L,af,r,B,m,j,I,P,ae)m=ap(i)j=ap(n)if m*j>0 then return 0 end
if u(m)<u(j)then
i,n=n,i
m,j=j,m
end
L=i
I=m
r=0
af=0
P=X
B=0
while(j~=0 or u(n-i)>al)and B<30 do
B=B+1
if m~=I and j~=I then
r=(i*j*I)/((m-j)*(m-I))+(n*m*I)/((j-m)*(j-I))+(L*m*j)/((I-m)*(I-j))else
r=n-j*(n-i)/(j-m)end
if(r-(3*i+n)/4)*(r-n)>=0 or
P and u(r-n)>=u(n-L)/2 or
not(P)and u(r-n)>=u(L-af)/2 or
P and u(n-L)<u(al)or
not(P)and u(L-af)<u(al)then
r=(i+n)/2
P=X
else
P=ad
end
af,L,I=L,n,j
ae=ap(r)if m*ae<0 then
n=r
j=ae
else
i=r
m=ae
end
if u(m)<u(j)then
i,n=n,i
m,j=j,m
end
end
return n
end
function K(a)o=D(-_*a)w=1-o
G,z=0,0
if p>0 and a>v then
G=a-v
z=1-D(-_*G)end
return C^2+(y+t*a/_-t/_^2*w)^2-((J/_)*w+p*((a-G)/_-w/_^2+z/_^2))^2
end
function aW(a)o=D(-_*a)z=1-o
return(2*t/_*z)*(t*a/_-t*z/_^2+y)-(-2*p/_*z+2*J*o)*(-p*a/_+(p/_^2+J/_)*z)end
function aK(a)o=D(-_*a)G=a-v
w=1-o
return(2*t/_*w)*(t*a/_-t*w/_^2+y)-(2*p/_*w+2*J*o)*(p*((a-G)/_-w/_^2+D(-_*G)/_^2)+J*w/_)end
function aH(a)o=D(-_*a)return aL(y-t/_^2*(1-o)+t/_*a,C)end
function ag(a,i,q,b,d,e,C,y)o=D(-_*a)w=1-o
b=ah(l.b,l.aw,l.aC,aD.b,V.b,o,a+ai)d=ah(l.d,l.at,l.ax,aD.d,V.d,o,a+ai)e=ah(l.e,l.aM,l.av,0,V.e,o,a+ai)i=aL(b,d)q=aH(a)G,z=0,0
if p>0 and a>v then
G=a-v
z=1-D(-_*G)end
C=J*h(q)*w/_+p*h(q)*((a-G)/_-w/_^2+z/_^2)+Y*h(q)y=(t/_^2+J*f(q)/_)*w-t/_*a+p*f(q)*((a-G)/_-w/_^2+z/_^2)+Y*f(q)return{q=q,i=i,C=C,y=y,b=b,d=d,e=e}end
function ah(b,aT,i,Q,V,o,a)z=(R==_ or W)and(1-D(-R*a))/R or a
Q=Q-V
Q=Q<40 and Q or 40
return b+aT*a+i*a^2/2-V*z-Q*T/_^2*(1-o)+Q*T/_*a
end
function aQ(b)return(b~=b or b==M.huge)and 0 or b
end
function aR(a)o=D(-_*a)return-t/_+_*(t/_^2+(J+p*v)*f(g.q)/_)*o
end
function au(b)return(((44.33-b/1000)/11.89)^5.256)/1013
end
function aE()k=x(0,v,K)or 0
s=k==0 and x(0,v,aK)or 0
k=s>0 and x(0,s,K)or k
k=k==0 and x(s,v,K)or k
s=k==0 and x(v,O,aK)or 0
k=s>0 and x(v,s,K)or k
k=(k==0 or W)and x(s,O,K)or k
end
aP={{800,1.5,5,.15,520,3.6},{1000,1.2,5,.135,815,3.3},{1000,.6,5,.13,1500,3.8},{900,.3,10,.125,2700,9.8},{800,.12,60,.12,5200,15},{700,.06,60,.11,7000,20},{600,.03,60,.105,7500,22},{50,.18,60,.125,2100,5.4,600,1,.1}}pi=M.pi
as=pi*2
aO=1/60
al=.01
aj={b=U("gunX")*S,d=U("gunY")*S,e=U("gunZ")*S}ai=U("DelayTicks")*aO
Y=U("barrelLength")*S
g={b=0,d=0,e=0,i=0,q=0,C=0,y=0}function onTick()aq=c(32)aS=aq>0 and X or ad
aV=aq==2 and X or ad
W=aq==3 and X or ad
if aS then
ac={b=-c(13),d=aQ(-c(14)),e=-c(15)}aB=aX(ac)ar=aG(aB,{{aj.b},{aj.e},{aj.d}})N={b=c(10)+ar[1][1],d=c(11)+ar[3][1],e=c(12)+ar[2][1]}l=(W or aV)and{b=c(1)-N.b,aw=0,aC=0,d=c(2)-N.d,at=0,ax=0,e=c(3)-N.e,aM=0,av=0}or{b=c(1)-N.b,aw=c(4),aC=c(7),d=c(2)-N.d,at=c(5),ax=c(8),e=c(3)-N.e,aM=c(6),av=c(9)}V={b=c(16),d=c(18),e=c(17)}ab=au(N.e)am=c(21)/ab
az=c(22)*as
aA=aG(aB,{{am*f(az)/h(c(27)*as)},{am},{am*h(az)/h(c(26)*as)}})aD={b=aA[1][1],d=aA[3][1],e=0}t=30*ab
J,_,O,T,aI,aN,p,v,R=table.unpack(aP[U("GUNSTYPE")])p=p and p or 0
R=R and R or _
v=v and v or 0
C,y=0,0
aF=Z(l.b^2+l.e^2+l.d^2)if aF<aI-50 then
C=Z(l.b^2+l.d^2)-Y
y=l.e
elseif l.b^2+l.d^2<(aI+500)^2 then
g=ag(aN)C=Z(g.b^2+g.d^2)y=g.e
end
if C~=0 then
if p>0 then
aE()else
s=x(0,O,aW)s=s>0 and s<O and s or O
k=W and x(s,O,K)or x(0,s,K)end
if k>0 then
if W then
g.q=aH(k)ak=x(0,k,aR)aU=ak>0 and(t/_^2+(J+p*v)/_*f(g.q))*(1-D(-_*ak))-t/_*ak or 0
T=T*(.35*ab+.65*au(aU+N.e))else
T=T*ab
end
g=ag(k)B=0
while(u(g.b^2+g.d^2-g.C^2)>S^2 or u(g.y-g.e)>S)and B<20 do
C=Z(g.b^2+g.d^2)-Y*h(g.q)y=g.e-Y*f(g.q)if p>0 then
aE()else
k=W and x(s,O,K)or x(0,s,K)end
g=ag(k)B=B+1
end
end
end
A(1,k)A(2,g.i)A(3,g.q)A(4,c(19))A(5,c(20))A(6,l.b)A(7,l.d)A(8,l.e)A(9,aF)A(10,ac.b)A(11,ac.d)A(12,ac.e)end
end
