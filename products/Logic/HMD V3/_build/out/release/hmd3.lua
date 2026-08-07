cb=":"
ca="%d"
c_="WP"
bZ="%02.0f"

Q=.5
v=360
bi=tostring
au=false
bj=property
aW=output
bn=input
ab=math
J=screen
ax=J.drawRect
R=J.drawRectF
z=string.format
x=J.drawText
aR=J.drawCircle
h=ab.floor
U=J.drawLine
bp=ab.tan
aX=ab.sqrt
d=ab.sin
b=ab.cos
aJ=ab.atan
be=J.setColor
K=ab.pi
p=bn.getNumber
bW=bn.getBool
aU=aW.setNumber
bX=aW.setBool
aL=bj.getNumber
w=bj.getBool
P=K*2
bP=(73/v)*P
bu=(58/v)*P
function G()be(0,255,0)end
function S()be(0,0,0)end
function av(c,o)if c>=0 then
aF=aJ(o/c)elseif o>=0 then
aF=aJ(o/c)+K
else
aF=aJ(o/c)-K
end
return aF
end
function bc(c,min,max)if c>=max then
c=max
elseif c<=min then
c=min
end
return c
end
function M(l,k,m,aj,al,ar,e,g,f)local y,A,V,Z,W,aa,Y,u,t,q,B,aA,c,C,o,ap
l=l-aj
k=k-ar
m=m-al
y=b(f)*b(g)A=b(f)*d(g)*d(e)-d(f)*b(e)V=b(f)*d(g)*b(e)+d(f)*d(e)Z=l
W=d(f)*b(g)aa=d(f)*d(g)*d(e)+b(f)*b(e)Y=d(f)*d(g)*b(e)-b(f)*d(e)u=m
t=-d(g)q=b(g)*d(e)B=b(g)*b(e)aA=k
ap=((y*aa-A*W)*B+(V*W-y*Y)*q+(A*Y-V*aa)*t)c=0
o=0
C=0
if ap~=0 then
c=((A*Y-V*aa)*aA+(Z*aa-A*u)*B+(V*u-Z*Y)*q)/ap
o=-((y*Y-V*W)*aA+(Z*W-y*u)*B+(V*u-Z*Y)*t)/ap
C=((y*aa-A*W)*aA+(Z*W-y*u)*q+(A*u-Z*aa)*t)/ap
end
return c,C,o
end
function aw(n,i,j,aj,al,ar,e,g,f)local aP,bq,aO
aP=b(f)*b(g)*n+(b(f)*d(g)*d(e)-d(f)*b(e))*j+(b(f)*d(g)*b(e)+d(f)*d(e))*i
bq=d(f)*b(g)*n+(d(f)*d(g)*d(e)+b(f)*b(e))*j+(d(f)*d(g)*b(e)-b(f)*d(e))*i
aO=-d(g)*n+b(g)*d(e)*j+b(g)*b(e)*i
return aP+aj,aO+ar,bq+al
end
function bR(c,o,C,ai)local s,r
s=av(aX(c^2+o^2),C)r=av(o,c)I=aX(c^2+o^2+C^2)if ai then
return s,r,I
else
return s/(K*2),r/(K*2),I
end
end
function bm(s,r,I,ai)local c,o,C
if not ai then
s=s*K*2
r=r*K*2
end
c=I*b(s)*d(r)o=I*b(s)*b(r)C=I*d(s)return c,o,C
end
function by(s,r,I,ai)local c,o,C
if not ai then
s=s*K*2
r=r*K*2
end
c=I*d(r)o=I*b(r)*b(s)C=I*b(r)*d(s)return c,o,C
end
function az(n,i,j)local E,D,F
E=H/2+(n/i)*(H/2)/bp(bP/2)D=u/2-(j/i)*(u/2)/bp(bu/2)F=i>0
return E,D,F
end
function bb(l,k,m,e,g,f)local n,i,j,E,D,F
n,i,j=M(l,k,m,0,0,0,e,g,f)n,i,j=M(n,i,j,0,0,0,-at,as,0)E,D,F=az(n,i,j)return E,D,F
end
function aQ(s,r,aD,aM,aE)local l,k,m,E,D,F
l,k,m=bm(s,r,1,au)l,k,m=M(l,k,m,0,0,0,aD,aM,aE)E,D,F=bb(l,k,m,e,g,f)return E,D,F
end
function ay(s,r,aD,aM,aE)local l,k,m,E,D,F
l,k,m=by(s,r,1,au)l,k,m=M(l,k,m,0,0,0,aD,aM,aE)E,D,F=bb(l,k,m,e,g,f)return E,D,F
end
function bz(_,a,L,T)local y,A,ak
y=bc((a-T)/(_-L),-1000,1000)A=a-y*_
ak=2*b(av(L-_,T-a))for c=_,L-ak,ak*2 do
if ad(c,y*c+A)then
U(c,y*c+A,c+ak,y*(c+ak)+A)end
end
end
function ad(c,o)return c>=0 and c<=H and o>=0 and o<=u
end
function aC(bs,bL)return#bi(h(bs*bL+Q))end
function onTick()aG=aL("Speed Units")aB=aL("Altitude Units")bf=aL("Distance Units")X=aC(500,aG)ag=aC(30000,aB)ah=bc(aC(150000,bf),3,100)aj=p(1)al=p(2)ar=p(3)e=p(4)g=p(5)f=p(6)bS=p(21)*aB
bO=p(2)*aB
bl=p(13)*aG
bo=p(20)*aG
ac=p(17)*P
as=p(18)*P
at=p(19)*P
bI=p(22)bt=p(23)bv=p(24)aI=p(25)*bf
ae=p(26)bG=p(27)==1
bD=p(28)==1
aT=w("air speed")aY=w("ground speed")an=w("main speed")bA=w("air altitude")bK=w("ground altitude")bT=w("magnetic heading")bU=w("attitude bars")bQ=w("horizon line")br=w("center marker")bx=w("laser direction")bC=w("waypoint marker")bV=w("waypoint marker label")bN=w("waypoint marker distance")bw=w("waypoint distance")bJ=w("waypoint arrival time")if bx then
n,i,j=M(0,0,-1,0,0,0,e,g,f)n,i,j=M(n,i,j,0,0,0,P/4,0,0)bH,bE,bY=bR(n,i,j,au)aU(1,bE*8)aU(2,bH*8)end
end
function onDraw()H=J.getWidth()u=J.getHeight()G()if br then
n,i,j=M(0,1,0,0,0,0,-at,as,0)_,a,N=az(n,i,j)if N then
aR(_,a,3)U(_+3,a,_+10,a)U(_-3,a,_-10,a)U(_,a-3,_,a-8)end
end
if bQ then
local aZ=5
if not br then
aZ=0
end
for t=aZ,180,45 do
for q=-1,1,2 do
_,a,N=aQ(0,q*t/v,0,ac,0)L,T,aH=aQ(0,q*(t+45)/v,0,ac,0)if N and aH then
U(_,a,L,T)end
end
end
end
if bU then
for t=5,175,5 do
for q=-1,1,2 do
for B=-1,1,2 do
_,a,N=ay(B*t/v,q*12/v,0,ac,0)L,T,aH=ay(B*t/v,q*5/v,0,ac,0)bh,bk,bB=ay(B*(t-1)/v,q*12/v,0,ac,0)bd,bg,bM=ay(B*t/v,q*16/v,0,ac,0)if N and aH and bB and bM then
if ad(_,a)or ad(L,T)then
if B==1 then
U(_,a,L,T)else
bz(L,T,_,a)end
end
if ad(_,a)or ad(bh,bk)then
U(_,a,bh,bk)end
if ad(bd,bg)then
x(bd-2.5*#bi(B*t),bg-3,B*t)end
end
end
end
end
end
if bT then
l,k,m=aw(0,1,0,0,0,0,-at,as,0)l,k,m=aw(l,k,m,0,0,0,e,g,f)aK=av(k,l)/P
l,k,m=aw(0,0,1,0,0,0,-at,as,0)l,k,m=aw(l,k,m,0,0,0,e,g,f)if m>0 then
q=1
else
q=-1
end
for t=0,q*355,q*5 do
n,i,j=bm(19.5/v,t/v-q*aK,1,au)_,a,N=az(n,i,j)if N then
U(_,a+2,_,a-2)if t%10==0 then
x(_-4,a-7,z("%02d",q*t/10))end
end
end
_=h(H/2)aK=z("%03.0f",v*((-ac/P)%1))S()R(_-10,9,20,11)G()ax(_-9,10,17,8)J.drawTextBox(_-8,11,16,7,aK,0,0)end
if bG then
n,i,j=M(bI,bt,bv,aj,al,ar,e,g,f)n,i,j=M(n,i,j,0,0,0,-at,as,0)if aI>=10 then
am=z("%.0f",h(aI+Q))else
am=z("%.1f",h(aI*10+Q)/10)end
if bC then
_,a,N=az(n,i,j)_=h(_)a=h(a)if N then
G()aR(_,a,5)if bV then
x(_-4,a-11,c_)end
if bN then
x(_+1-2.5*#am,a+7,am)end
end
end
if bw then
_,a=h(H/5),h(3*u/5)S()R(_-5-5*ah,a,13+5*ah,7)G()x(_-4-5*ah,a+1,c_)x(_+8-5*#am,a+1,am)end
if bJ then
_,a=h(H/5),h(3*u/5)bF=z(ca,h(ae/3600))aS=z(bZ,h(ae%60+Q))if ae<3600 then
aN=z(ca,h((ae/60)%60))af=aN..cb..aS
elseif ae>=36000 then
af="-:--:--"
else
aN=z(bZ,h((ae/60)%60))af=bF..cb..aN..cb..aS
end
S()R(_+7-5*#af,a+7,5*#af+1,7)G()x(_+8-5*#af,a+8,af)end
end
if bD then
_,a=h(H/5),h(3*u/5)S()R(_-5-5*ah,a-7,11,7)G()x(_-4-5*ah,a-6,"AP")end
if an then
b_=bl
ba=bo
aV="AS"
else
b_=bo
ba=bl
aV="GS"
end
if(an and aY)or(not an and aT)then
_,a=h(H/5),h(u/3)aq=z(ca,h(b_+Q))S()R(_+5-5*X,a,5*X+5,11)G()ax(_+6-5*X,a+1,5*X+2,8)x(_+8-5*#aq,a+3,aq)end
if(an and aT)or(not an and aY)then
aq=z(ca,h(ba+Q))S()R(_-5-5*X,a+10,5*X+13,7)G()x(_-4-5*X,a+11,aV)x(_+8-5*#aq,a+11,aq)end
if bA then
_,a=h(4*H/5),h(u/3)ao=z(ca,h(bO+Q))O=2*ag
S()R(_-O,a,5+5*ag,11)G()ax(_+1-O,a+1,2+5*ag,8)x(_+3+1.5*O-5*#ao,a+3,ao)end
if bK then
_,a=h(4*H/5),h(2*u/3)ao=z(ca,h(bS+Q))O=2*ag
S()R(_-5-O,a,15+5*ag,11)G()x(_-4-O,a+3,"AG")ax(_+6-O,a+1,2+5*ag,8)x(_+8+1.5*O-5*#ao,a+3,ao)end
end
