ca="%02.0f"
c_=":"
bZ="%d"
bY="WP"

T=.5
v=360
bf=tostring
ax=false
bk=property
aQ=output
bn=input
ab=math
N=screen
ay=N.drawRect
U=N.drawRectF
C=string.format
x=N.drawText
aO=N.drawCircle
h=ab.floor
R=N.drawLine
bh=ab.tan
bd=ab.sqrt
c=ab.sin
b=ab.cos
aL=ab.atan
ba=N.setColor
J=ab.pi
p=bn.getNumber
bX=bn.getBool
bi=aQ.setNumber
bV=aQ.setBool
aN=bk.getNumber
w=bk.getBool
S=J*2
bT=(73/v)*S
bR=(58/v)*S
function G()ba(0,255,0)end
function O()ba(0,0,0)end
function au(d,o)if d>=0 then
aB=aL(o/d)elseif o>=0 then
aB=aL(o/d)+J
else
aB=aL(o/d)-J
end
return aB
end
function bm(d,min,max)if d>=max then
d=max
elseif d<=min then
d=min
end
return d
end
function L(k,m,l,at,ai,ao,f,g,e)local y,B,aa,Z,V,Y,W,u,r,q,A,av,d,z,o,ah
k=k-at
m=m-ao
l=l-ai
y=b(e)*b(g)B=b(e)*c(g)*c(f)-c(e)*b(f)aa=b(e)*c(g)*b(f)+c(e)*c(f)Z=k
V=c(e)*b(g)Y=c(e)*c(g)*c(f)+b(e)*b(f)W=c(e)*c(g)*b(f)-b(e)*c(f)u=l
r=-c(g)q=b(g)*c(f)A=b(g)*b(f)av=m
ah=((y*Y-B*V)*A+(aa*V-y*W)*q+(B*W-aa*Y)*r)d=0
o=0
z=0
if ah~=0 then
d=((B*W-aa*Y)*av+(Z*Y-B*u)*A+(aa*u-Z*W)*q)/ah
o=-((y*W-aa*V)*av+(Z*V-y*u)*A+(aa*u-Z*W)*r)/ah
z=((y*Y-B*V)*av+(Z*V-y*u)*q+(B*u-Z*Y)*r)/ah
end
return d,z,o
end
function aA(n,i,j,at,ai,ao,f,g,e)local bc,aZ,aX
bc=b(e)*b(g)*n+(b(e)*c(g)*c(f)-c(e)*b(f))*j+(b(e)*c(g)*b(f)+c(e)*c(f))*i
aZ=c(e)*b(g)*n+(c(e)*c(g)*c(f)+b(e)*b(f))*j+(c(e)*c(g)*b(f)-b(e)*c(f))*i
aX=-c(g)*n+b(g)*c(f)*j+b(g)*b(f)*i
return bc+at,aX+ao,aZ+ai
end
function bF(d,o,z,aq)local t,s
t=au(bd(d^2+o^2),z)s=au(o,d)H=bd(d^2+o^2+z^2)if aq then
return t,s,H
else
return t/(J*2),s/(J*2),H
end
end
function bb(t,s,H,aq)local d,o,z
if not aq then
t=t*J*2
s=s*J*2
end
d=H*b(t)*c(s)o=H*b(t)*b(s)z=H*c(t)return d,o,z
end
function bz(t,s,H,aq)local d,o,z
if not aq then
t=t*J*2
s=s*J*2
end
d=H*c(s)o=H*b(s)*b(t)z=H*b(s)*c(t)return d,o,z
end
function aw(n,i,j)local E,F,D
E=I/2+(n/i)*(I/2)/bh(bT/2)F=u/2-(j/i)*(u/2)/bh(bR/2)D=i>0
return E,F,D
end
function bl(k,m,l,f,g,e)local n,i,j,E,F,D
n,i,j=L(k,m,l,0,0,0,f,g,e)n,i,j=L(n,i,j,0,0,0,-ap,ak,0)E,F,D=aw(n,i,j)return E,F,D
end
function b_(t,s,aI,aJ,aK)local k,m,l,E,F,D
k,m,l=bb(t,s,1,ax)k,m,l=L(k,m,l,0,0,0,aI,aJ,aK)E,F,D=bl(k,m,l,f,g,e)return E,F,D
end
function az(t,s,aI,aJ,aK)local k,m,l,E,F,D
k,m,l=bz(t,s,1,ax)k,m,l=L(k,m,l,0,0,0,aI,aJ,aK)E,F,D=bl(k,m,l,f,g,e)return E,F,D
end
function bK(_,a,M,P)local y,B,an
y=bm((a-P)/(_-M),-1000,1000)B=a-y*_
an=2*b(au(M-_,P-a))for d=_,M-an,an*2 do
if ad(d,y*d+B)then
R(d,y*d+B,d+an,y*(d+an)+B)end
end
end
function ad(d,o)return d>=0 and d<=I and o>=0 and o<=u
end
function aM(bE,bU)return#bf(h(bE*bU+T))end
function onTick()aH=aN("Speed Units")aC=aN("Altitude Units")aV=aN("Distance Units")ac=aM(500,aH)af=aM(30000,aC)ar=bm(aM(150000,aV),3,100)at=p(1)ai=p(2)ao=p(3)f=p(4)g=p(5)e=p(6)br=p(21)*aC
bA=p(2)*aC
bg=p(13)*aH
aT=p(20)*aH
X=p(17)*S
ak=p(18)*S
ap=p(19)*S
bx=p(22)bN=p(23)by=p(24)aD=p(25)*aV
ae=p(26)bM=p(27)==1
bq=p(28)==1
aY=w("air speed")bj=w("ground speed")as=w("main speed")bB=w("air altitude")bv=w("ground altitude")bD=w("magnetic heading")bQ=w("attitude bars")bG=w("horizon line")bP=w("center marker")bO=w("laser direction")bS=w("waypoint marker")bH=w("waypoint marker label")bL=w("waypoint marker distance")bw=w("waypoint distance")bJ=w("waypoint arrival time")if bO then
n,i,j=L(0,0,-1,0,0,0,f,g,e)n,i,j=L(n,i,j,0,0,0,S/4,0,0)bC,bt,bW=bF(n,i,j,ax)bi(1,bt*8)bi(2,bC*8)end
end
function onDraw()I=N.getWidth()u=N.getHeight()G()if bP then
n,i,j=L(0,1,0,0,0,0,-ap,ak,0)_,a,K=aw(n,i,j)if K then
aO(_,a,3)R(_+3,a,_+10,a)R(_-3,a,_-10,a)R(_,a-3,_,a-8)end
end
if bG then
for r=5,180,45 do
for q=-1,1,2 do
_,a,K=b_(0,q*r/v,0,X,0)M,P,aG=b_(0,q*(r+45)/v,0,X,0)if K and aG then
R(_,a,M,P)end
end
end
end
if bQ then
for r=5,175,5 do
for q=-1,1,2 do
for A=-1,1,2 do
_,a,K=az(A*r/v,q*12/v,0,X,0)M,P,aG=az(A*r/v,q*5/v,0,X,0)aU,aW,bs=az(A*(r-1)/v,q*12/v,0,X,0)bp,aR,bu=az(A*r/v,q*16/v,0,X,0)if K and aG and bs and bu then
if ad(_,a)or ad(M,P)then
if A==1 then
R(_,a,M,P)else
bK(M,P,_,a)end
end
if ad(_,a)or ad(aU,aW)then
R(_,a,aU,aW)end
if ad(bp,aR)then
x(bp-2.5*#bf(A*r),aR-3,A*r)end
end
end
end
end
end
if bD then
k,m,l=aA(0,1,0,0,0,0,-ap,ak,0)k,m,l=aA(k,m,l,0,0,0,f,g,e)aE=au(m,k)/S
k,m,l=aA(0,0,1,0,0,0,-ap,ak,0)k,m,l=aA(k,m,l,0,0,0,f,g,e)if l>0 then
q=1
else
q=-1
end
for r=0,q*355,q*5 do
n,i,j=bb(19.5/v,r/v-q*aE,1,ax)_,a,K=aw(n,i,j)if K then
R(_,a+2,_,a-2)if r%10==0 then
x(_-4,a-7,C("%02d",q*r/10))end
end
end
_=h(I/2)aE=C("%03.0f",v*((-X/S)%1))O()U(_-10,9,20,11)G()ay(_-9,10,17,8)N.drawTextBox(_-8,11,16,7,aE,0,0)end
if bM then
n,i,j=L(bx,bN,by,at,ai,ao,f,g,e)n,i,j=L(n,i,j,0,0,0,-ap,ak,0)if aD>=10 then
al=C("%.0f",h(aD+T))else
al=C("%.1f",h(aD*10+T)/10)end
if bS then
_,a,K=aw(n,i,j)_=h(_)a=h(a)if K then
G()aO(_,a,5)if bH then
x(_-4,a-11,bY)end
if bL then
x(_+1-2.5*#al,a+7,al)end
end
end
if bw then
_,a=h(I/5),h(3*u/5)O()U(_-5-5*ar,a,13+5*ar,7)G()x(_-4-5*ar,a+1,bY)x(_+8-5*#al,a+1,al)end
if bJ then
_,a=h(I/5),h(3*u/5)bI=C(bZ,h(ae/3600))aP=C(ca,h(ae%60+T))if ae<3600 then
aF=C(bZ,h((ae/60)%60))ag=aF..c_..aP
elseif ae>=36000 then
ag="-:--:--"
else
aF=C(ca,h((ae/60)%60))ag=bI..c_..aF..c_..aP
end
O()U(_+7-5*#ag,a+7,5*#ag+1,7)G()x(_+8-5*#ag,a+8,ag)end
end
if bq then
_,a=h(I/5),h(3*u/5)O()U(_-5-5*ar,a-7,11,7)G()x(_-4-5*ar,a-6,"AP")end
if as then
bo=bg
aS=aT
be="AS"
else
bo=aT
aS=bg
be="GS"
end
if(as and bj)or(not as and aY)then
_,a=h(I/5),h(u/3)aj=C(bZ,h(bo+T))O()U(_+5-5*ac,a,5*ac+5,11)G()ay(_+6-5*ac,a+1,5*ac+2,8)x(_+8-5*#aj,a+3,aj)end
if(as and aY)or(not as and bj)then
aj=C(bZ,h(aS+T))O()U(_-5-5*ac,a+10,5*ac+13,7)G()x(_-4-5*ac,a+11,be)x(_+8-5*#aj,a+11,aj)end
if bB then
_,a=h(4*I/5),h(u/3)am=C(bZ,h(bA+T))Q=2*af
O()U(_-Q,a,5+5*af,11)G()ay(_+1-Q,a+1,2+5*af,8)x(_+3+1.5*Q-5*#am,a+3,am)end
if bv then
_,a=h(4*I/5),h(2*u/3)am=C(bZ,h(br+T))Q=2*af
O()U(_-5-Q,a,15+5*af,11)G()x(_-4-Q,a+3,"AG")ay(_+6-Q,a+1,2+5*af,8)x(_+8+1.5*Q-5*#am,a+3,am)end
end
