cb=":"
ca="WP"
c_="%d"
bZ="%02.0f"

U=.5
v=360
br=tostring
aA=false
bg=property
aR=output
bu=input
ac=math
P=screen
av=P.drawRect
T=P.drawRectF
C=string.format
x=P.drawText
aW=P.drawCircle
h=ac.floor
M=P.drawLine
aS=ac.tan
bt=ac.sqrt
d=ac.sin
b=ac.cos
aM=ac.atan
be=P.setColor
N=ac.pi
q=bu.getNumber
bY=bu.getBool
aZ=aR.setNumber
bX=aR.setBool
aB=bg.getNumber
w=bg.getBool
X=N*2
bd=(58/v)*X
function J()be(0,255,0)end
function S()be(0,0,0)end
function aw(c,o)if c>=0 then
aI=aM(o/c)elseif o>=0 then
aI=aM(o/c)+N
else
aI=aM(o/c)-N
end
return aI
end
function bo(c,min,max)if c>=max then
c=max
elseif c<=min then
c=min
end
return c
end
function Q(n,m,k,aj,am,al,e,g,f)local y,A,aa,Z,W,Y,ab,u,r,p,B,aD,c,z,o,au
n=n-aj
m=m-al
k=k-am
y=b(f)*b(g)A=b(f)*d(g)*d(e)-d(f)*b(e)aa=b(f)*d(g)*b(e)+d(f)*d(e)Z=n
W=d(f)*b(g)Y=d(f)*d(g)*d(e)+b(f)*b(e)ab=d(f)*d(g)*b(e)-b(f)*d(e)u=k
r=-d(g)p=b(g)*d(e)B=b(g)*b(e)aD=m
au=((y*Y-A*W)*B+(aa*W-y*ab)*p+(A*ab-aa*Y)*r)c=0
o=0
z=0
if au~=0 then
c=((A*ab-aa*Y)*aD+(Z*Y-A*u)*B+(aa*u-Z*ab)*p)/au
o=-((y*ab-aa*W)*aD+(Z*W-y*u)*B+(aa*u-Z*ab)*r)/au
z=((y*Y-A*W)*aD+(Z*W-y*u)*p+(A*u-Z*Y)*r)/au
end
return c,z,o
end
function ax(l,i,j,aj,am,al,e,g,f)local bl,bc,bq
bl=b(f)*b(g)*l+(b(f)*d(g)*d(e)-d(f)*b(e))*j+(b(f)*d(g)*b(e)+d(f)*d(e))*i
bc=d(f)*b(g)*l+(d(f)*d(g)*d(e)+b(f)*b(e))*j+(d(f)*d(g)*b(e)-b(f)*d(e))*i
bq=-d(g)*l+b(g)*d(e)*j+b(g)*b(e)*i
return bl+aj,bq+al,bc+am
end
function bJ(c,o,z,aq)local s,t
s=aw(bt(c^2+o^2),z)t=aw(o,c)K=bt(c^2+o^2+z^2)if aq then
return s,t,K
else
return s/(N*2),t/(N*2),K
end
end
function aQ(s,t,K,aq)local c,o,z
if not aq then
s=s*N*2
t=t*N*2
end
c=K*b(s)*d(t)o=K*b(s)*b(t)z=K*d(s)return c,o,z
end
function bH(s,t,K,aq)local c,o,z
if not aq then
s=s*N*2
t=t*N*2
end
c=K*d(t)o=K*b(t)*b(s)z=K*b(t)*d(s)return c,o,z
end
function ay(l,i,j)local D,G,F
D=L/2+(l/i)*(u/2)/aS(bd/2)G=u/2-(j/i)*(u/2)/aS(bd/2)F=i>0
return D,G,F
end
function aP(n,m,k,e,g,f)local l,i,j,D,G,F
l,i,j=Q(n,m,k,0,0,0,e,g,f)l,i,j=Q(l,i,j,0,0,0,-ar,ai,0)D,G,F=ay(l,i,j)return D,G,F
end
function aC(s,t,aE,aJ,aG)local n,m,k,D,G,F
n,m,k=aQ(s,t,1,aA)n,m,k=Q(n,m,k,0,0,0,aE,aJ,aG)D,G,F=aP(n,m,k,e,g,f)return D,G,F
end
function az(s,t,aE,aJ,aG)local n,m,k,D,G,F
n,m,k=bH(s,t,1,aA)n,m,k=Q(n,m,k,0,0,0,aE,aJ,aG)D,G,F=aP(n,m,k,e,g,f)return D,G,F
end
function bC(_,a,E,I)local y,A,ap
y=bo((a-I)/(_-E),-1000,1000)A=a-y*_
ap=2*b(aw(E-_,I-a))for c=_,E-ap,ap*2 do
if ad(c,y*c+A)then
M(c,y*c+A,c+ap,y*(c+ap)+A)end
end
end
function ad(c,o)return c>=0 and c<=L and o>=0 and o<=u
end
function aK(bz,bK)return#br(h(bz*bK+U))end
function onTick()aL=aB("Speed Units")aF=aB("Altitude Units")bj=aB("Distance Units")V=aK(500,aL)ae=aK(30000,aF)as=bo(aK(150000,bj),3,100)aj=q(1)am=q(2)al=q(3)e=q(4)g=q(5)f=q(6)bG=q(21)*aF
bE=q(2)*aF
bn=q(13)*aL
aX=q(20)*aL
O=q(17)*X
ai=q(9)*X
ar=q(10)*X
bO=q(22)bF=q(23)bL=q(24)aN=q(25)*bj
af=q(26)bN=q(27)==1
bB=q(28)==1
aV=w("air speed")bf=w("ground speed")ak=w("main speed")bP=w("air altitude")bI=w("ground altitude")bQ=w("magnetic heading")bp=w("attitude bars")bV=w("horizon line")bi=w("center marker")bD=w("laser direction")bM=w("waypoint marker")bx=w("waypoint marker label")by=w("waypoint marker distance")bw=w("waypoint distance")bS=w("waypoint arrival time")aY=h(aB("Minimum angle for attitude bars"))if bD then
l,i,j=Q(0,0,-1,0,0,0,e,g,f)l,i,j=Q(l,i,j,0,0,0,X/4,0,0)bR,bT,bW=bJ(l,i,j,aA)aZ(1,bT*8)aZ(2,bR*8)end
end
function onDraw()L=P.getWidth()u=P.getHeight()J()if bi then
l,i,j=Q(0,1,0,0,0,0,-ar,ai,0)_,a,H=ay(l,i,j)if H then
aW(_,a,3)M(_+3,a,_+10,a)M(_-3,a,_-10,a)M(_,a-3,_,a-8)end
end
if bV then
local ba=5
if not bi then
ba=0
end
for r=ba,180,45 do
for p=-1,1,2 do
_,a,H=aC(0,p*r/v,0,O,0)E,I,ao=aC(0,p*(r+45)/v,0,O,0)if H and ao then
M(_,a,E,I)end
end
end
elseif bp then
for p=-1,1,2 do
_,a,H=aC(0,p*5/v,0,O,0)E,I,ao=aC(0,p*15/v,0,O,0)if H and ao then
M(_,a,E,I)end
end
end
if bp then
for r=aY,175,aY do
for p=-1,1,2 do
for B=-1,1,2 do
_,a,H=az(B*r/v,p*12/v,0,O,0)E,I,ao=az(B*r/v,p*5/v,0,O,0)bm,bk,bU=az(B*(r-1)/v,p*12/v,0,O,0)b_,bb,bA=az(B*r/v,p*16/v,0,O,0)if H and ao and bU and bA then
if ad(_,a)or ad(E,I)then
if B==1 then
M(_,a,E,I)else
bC(E,I,_,a)end
end
if ad(_,a)or ad(bm,bk)then
M(_,a,bm,bk)end
if ad(b_,bb)then
x(b_-2.5*#br(B*r),bb-3,B*r)end
end
end
end
end
end
if bQ then
n,m,k=ax(0,1,0,0,0,0,-ar,ai,0)n,m,k=ax(n,m,k,0,0,0,e,g,f)aO=aw(m,n)/X
n,m,k=ax(0,0,1,0,0,0,-ar,ai,0)n,m,k=ax(n,m,k,0,0,0,e,g,f)if k>0 then
p=1
else
p=-1
end
for r=0,p*355,p*5 do
l,i,j=aQ(19.5/v,r/v-p*aO,1,aA)_,a,H=ay(l,i,j)if H then
M(_,a+2,_,a-2)if r%10==0 then
x(_-4,a-7,C("%02d",p*r/10))end
end
end
_=h(L/2)aO=C("%03.0f",v*((-O/X)%1))S()T(_-10,9,20,11)J()av(_-9,10,17,8)P.drawTextBox(_-8,11,16,7,aO,0,0)end
if bN then
l,i,j=Q(bO,bF,bL,aj,am,al,e,g,f)l,i,j=Q(l,i,j,0,0,0,-ar,ai,0)if aN>=10 then
at=C("%.0f",h(aN+U))else
at=C("%.1f",h(aN*10+U)/10)end
if bM then
_,a,H=ay(l,i,j)_=h(_)a=h(a)if H then
J()aW(_,a,5)if bx then
x(_-4,a-11,ca)end
if by then
x(_+1-2.5*#at,a+7,at)end
end
end
if bw then
_,a=h(L/5),h(3*u/5)S()T(_-5-5*as,a,13+5*as,7)J()x(_-4-5*as,a+1,ca)x(_+8-5*#at,a+1,at)end
if bS then
_,a=h(L/5),h(3*u/5)bv=C(c_,h(af/3600))aU=C(bZ,h(af%60+U))if af<3600 then
aH=C(c_,h((af/60)%60))ag=aH..cb..aU
elseif af>=36000 then
ag="-:--:--"
else
aH=C(bZ,h((af/60)%60))ag=bv..cb..aH..cb..aU
end
S()T(_+7-5*#ag,a+7,5*#ag+1,7)J()x(_+8-5*#ag,a+8,ag)end
end
if bB then
_,a=h(L/5),h(3*u/5)S()T(_-5-5*as,a-7,11,7)J()x(_-4-5*as,a-6,"AP")end
if ak then
bh=bn
aT=aX
bs="AS"
else
bh=aX
aT=bn
bs="GS"
end
if(ak and bf)or(not ak and aV)then
_,a=h(L/5),h(u/3)ah=C(c_,h(bh+U))S()T(_+5-5*V,a,5*V+5,11)J()av(_+6-5*V,a+1,5*V+2,8)x(_+8-5*#ah,a+3,ah)end
if(ak and aV)or(not ak and bf)then
ah=C(c_,h(aT+U))S()T(_-5-5*V,a+10,5*V+13,7)J()x(_-4-5*V,a+11,bs)x(_+8-5*#ah,a+11,ah)end
if bP then
_,a=h(4*L/5),h(u/3)an=C(c_,h(bE+U))R=2*ae
S()T(_-R,a,5+5*ae,11)J()av(_+1-R,a+1,2+5*ae,8)x(_+3+1.5*R-5*#an,a+3,an)end
if bI then
_,a=h(4*L/5),h(2*u/3)an=C(c_,h(bG+U))R=2*ae
S()T(_-5-R,a,15+5*ae,11)J()x(_-4-R,a+3,"AG")av(_+6-R,a+1,2+5*ae,8)x(_+8+1.5*R-5*#an,a+3,an)end
end
