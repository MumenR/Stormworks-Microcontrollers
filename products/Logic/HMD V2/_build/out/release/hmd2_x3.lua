ce="%02.0f"
cd=":"
cc="%d"
cb="WP"

R=.5
x=360
bg=tostring
av=false
bb=property
ba=output
bi=input
ac=math
Q=screen
au=Q.drawRect
H=Q.drawRectF
A=string.format
r=Q.drawText
bc=Q.drawCircle
e=ac.floor
X=Q.drawLine
bl=ac.tan
aR=ac.sqrt
d=ac.sin
b=ac.cos
aF=ac.atan
aQ=Q.setColor
S=ac.pi
i=bi.getNumber
bZ=bi.getBool
aS=ba.setNumber
ca=ba.setBool
aK=bb.getNumber
w=bb.getBool
U=S*2
bG=(73/x)*U
bt=(58/x)*U
function y()aQ(0,255,0)end
function J()aQ(0,0,0)end
function az(c,p)if c>=0 then
aL=aF(p/c)elseif p>=0 then
aL=aF(p/c)+S
else
aL=aF(p/c)-S
end
return aL
end
function bk(c,min,max)if c>=max then
c=max
elseif c<=min then
c=min
end
return c
end
function N(k,n,m,al,ak,as,f,h,g)local z,E,ad,af,Z,Y,ae,q,v,t,D,ay,c,F,p,ao
k=k-al
n=n-as
m=m-ak
z=b(g)*b(h)E=b(g)*d(h)*d(f)-d(g)*b(f)ad=b(g)*d(h)*b(f)+d(g)*d(f)af=k
Z=d(g)*b(h)Y=d(g)*d(h)*d(f)+b(g)*b(f)ae=d(g)*d(h)*b(f)-b(g)*d(f)q=m
v=-d(h)t=b(h)*d(f)D=b(h)*b(f)ay=n
ao=((z*Y-E*Z)*D+(ad*Z-z*ae)*t+(E*ae-ad*Y)*v)c=0
p=0
F=0
if ao~=0 then
c=((E*ae-ad*Y)*ay+(af*Y-E*q)*D+(ad*q-af*ae)*t)/ao
p=-((z*ae-ad*Z)*ay+(af*Z-z*q)*D+(ad*q-af*ae)*v)/ao
F=((z*Y-E*Z)*ay+(af*Z-z*q)*t+(E*q-af*Y)*v)/ao
end
return c,F,p
end
function aA(o,j,l,al,ak,as,f,h,g)local bn,bh,bf
bn=b(g)*b(h)*o+(b(g)*d(h)*d(f)-d(g)*b(f))*l+(b(g)*d(h)*b(f)+d(g)*d(f))*j
bh=d(g)*b(h)*o+(d(g)*d(h)*d(f)+b(g)*b(f))*l+(d(g)*d(h)*b(f)-b(g)*d(f))*j
bf=-d(h)*o+b(h)*d(f)*l+b(h)*b(f)*j
return bn+al,bf+as,bh+ak
end
function bz(c,p,F,an)local u,s
u=az(aR(c^2+p^2),F)s=az(p,c)L=aR(c^2+p^2+F^2)if an then
return u,s,L
else
return u/(S*2),s/(S*2),L
end
end
function aO(u,s,L,an)local c,p,F
if not an then
u=u*S*2
s=s*S*2
end
c=L*b(u)*d(s)p=L*b(u)*b(s)F=L*d(u)return c,p,F
end
function bP(u,s,L,an)local c,p,F
if not an then
u=u*S*2
s=s*S*2
end
c=L*d(s)p=L*b(s)*b(u)F=L*b(s)*d(u)return c,p,F
end
function ax(o,j,l)local G,I,K
G=B/2+(o/j)*(B/2)/bl(bG/2)I=q/2-(l/j)*(q/2)/bl(bt/2)K=j>0
return G,I,K
end
function bo(k,n,m,f,h,g)local o,j,l,G,I,K
o,j,l=N(k,n,m,0,0,0,f,h,g)o,j,l=N(o,j,l,0,0,0,-ap,ar,0)G,I,K=ax(o,j,l)return G,I,K
end
function bp(u,s,aG,aN,aH)local k,n,m,G,I,K
k,n,m=aO(u,s,1,av)k,n,m=N(k,n,m,0,0,0,aG,aN,aH)G,I,K=bo(k,n,m,f,h,g)return G,I,K
end
function aw(u,s,aG,aN,aH)local k,n,m,G,I,K
k,n,m=bP(u,s,1,av)k,n,m=N(k,n,m,0,0,0,aG,aN,aH)G,I,K=bo(k,n,m,f,h,g)return G,I,K
end
function bM(_,a,O,W)local z,E,aq
z=bk((a-W)/(_-O),-1000,1000)E=a-z*_
aq=2*b(az(O-_,W-a))for c=_,O-aq,aq*2 do
if ag(c,z*c+E)then
X(c,z*c+E,c+aq,z*(c+aq)+E)end
end
end
function ag(c,p)return c>=0 and c<=B and p>=0 and p<=q
end
function aD(bI,bK)return#bg(e(bI*bK+R))end
function onTick()aB=aK("Speed Units")aI=aK("Altitude Units")bm=aK("Distance Units")ab=aD(500,aB)T=aD(30000,aI)P=bk(aD(150000,bm),3,100)al=i(1)ak=i(2)as=i(3)f=i(4)h=i(5)g=i(6)bD=i(21)*aI
bQ=i(2)*aI
aU=i(13)*aB
aY=i(20)*aB
aa=i(17)*U
ar=i(18)*U
ap=i(19)*U
bW=i(22)bB=i(23)bu=i(24)aJ=i(25)*bm
ai=i(26)bU=i(27)==1
bx=i(28)==1
bq=i(29)==1
bJ=i(30)bE=i(31)==1
bw=i(32)==1
aW=w("air speed")aX=w("ground speed")at=w("main speed")bC=w("air altitude")bO=w("ground altitude")bS=w("magnetic heading")bR=w("attitude bars")bT=w("horizon line")bN=w("center marker")bH=w("laser direction")by=w("waypoint marker")br=w("waypoint marker label")bV=w("waypoint marker distance")bv=w("waypoint distance")bA=w("waypoint arrival time")if bH then
o,j,l=N(0,0,-1,0,0,0,f,h,g)o,j,l=N(o,j,l,0,0,0,U/4,0,0)bF,bX,c_=bz(o,j,l,av)aS(1,bX*8)aS(2,bF*8)end
end
function onDraw()B=Q.getWidth()q=Q.getHeight()y()if bN then
o,j,l=N(0,1,0,0,0,0,-ap,ar,0)_,a,M=ax(o,j,l)if M then
bc(_,a,3)X(_+3,a,_+10,a)X(_-3,a,_-10,a)X(_,a-3,_,a-8)end
end
if bT then
for v=5,180,45 do
for t=-1,1,2 do
_,a,M=bp(0,t*v/x,0,aa,0)O,W,aM=bp(0,t*(v+45)/x,0,aa,0)if M and aM then
X(_,a,O,W)end
end
end
end
if bR then
for v=5,175,5 do
for t=-1,1,2 do
for D=-1,1,2 do
_,a,M=aw(D*v/x,t*12/x,0,aa,0)O,W,aM=aw(D*v/x,t*5/x,0,aa,0)b_,aV,bY=aw(D*(v-1)/x,t*12/x,0,aa,0)aT,aZ,bL=aw(D*v/x,t*16/x,0,aa,0)if M and aM and bY and bL then
if ag(_,a)or ag(O,W)then
if D==1 then
X(_,a,O,W)else
bM(O,W,_,a)end
end
if ag(_,a)or ag(b_,aV)then
X(_,a,b_,aV)end
if ag(aT,aZ)then
r(aT-2.5*#bg(D*v),aZ-3,D*v)end
end
end
end
end
end
if bS then
k,n,m=aA(0,1,0,0,0,0,-ap,ar,0)k,n,m=aA(k,n,m,0,0,0,f,h,g)aC=az(n,k)/U
k,n,m=aA(0,0,1,0,0,0,-ap,ar,0)k,n,m=aA(k,n,m,0,0,0,f,h,g)if m>0 then
t=1
else
t=-1
end
for v=0,t*355,t*5 do
o,j,l=aO(19.5/x,v/x-t*aC,1,av)_,a,M=ax(o,j,l)if M then
X(_,a+2,_,a-2)if v%10==0 then
r(_-4,a-7,A("%02d",t*v/10))end
end
end
_=e(B/2)aC=A("%03.0f",x*((-aa/U)%1))J()H(_-10,9,20,11)y()au(_-9,10,17,8)Q.drawTextBox(_-8,11,16,7,aC,0,0)end
if bU then
o,j,l=N(bW,bB,bu,al,ak,as,f,h,g)o,j,l=N(o,j,l,0,0,0,-ap,ar,0)if aJ>=10 then
aj=A("%.0f",e(aJ+R))else
aj=A("%.1f",e(aJ*10+R)/10)end
if by then
_,a,M=ax(o,j,l)_=e(_)a=e(a)if M then
y()bc(_,a,5)if br then
r(_-4,a-11,cb)end
if bV then
r(_+1-2.5*#aj,a+7,aj)end
end
end
if bv then
_,a=e(B/5),e(3*q/5)J()H(_-5-5*P,a,13+5*P,7)y()r(_-4-5*P,a+1,cb)r(_+8-5*#aj,a+1,aj)end
if bA then
_,a=e(B/5),e(3*q/5)bs=A(cc,e(ai/3600))bj=A(ce,e(ai%60+R))if ai<3600 then
aE=A(cc,e((ai/60)%60))ah=aE..cd..bj
elseif ai>=36000 then
ah="-:--:--"
else
aE=A(ce,e((ai/60)%60))ah=bs..cd..aE..cd..bj
end
J()H(_+7-5*#ah,a+7,5*#ah+1,7)y()r(_+8-5*#ah,a+8,ah)end
end
if bx then
_,a=e(B/5),e(3*q/5)J()H(_-5-5*P,a-7,11,7)y()r(_-4-5*P,a-6,"AP")end
if bE then
_,a=e(B/5)+11,e(3*q/5)J()H(_-5-5*P,a-7,11,7)y()r(_-4-5*P,a-6,"PH")end
if bw then
_,a=e(B/5)+22,e(3*q/5)J()H(_-5-5*P,a-7,11,7)y()r(_-4-5*P,a-6,"RH")end
if at then
bd=aU
aP=aY
be="AS"
else
bd=aY
aP=aU
be="GS"
end
if(at and aX)or(not at and aW)then
_,a=e(B/5),e(q/3)am=A(cc,e(bd+R))J()H(_+5-5*ab,a,5*ab+5,11)y()au(_+6-5*ab,a+1,5*ab+2,8)r(_+8-5*#am,a+3,am)end
if(at and aW)or(not at and aX)then
am=A(cc,e(aP+R))J()H(_-5-5*ab,a+10,5*ab+13,7)y()r(_-4-5*ab,a+11,be)r(_+8-5*#am,a+11,am)end
if bC then
_,a=e(4*B/5),e(q/3)V=A(cc,e(bQ+R))C=2*T
J()H(_-C,a,5+5*T,11)y()au(_+1-C,a+1,2+5*T,8)r(_+3+1.5*C-5*#V,a+3,V)end
if bq then
_,a=e(4*B/5),e(q/3)+10
V=A(cc,e(bJ+R))C=2*T
J()H(_-C-8,a,11+5*T,7)y()r(_-7-C,a+1,"AH")r(_+3+1.5*C-5*#V,a+1,V)end
if bO then
_,a=e(4*B/5),e(2*q/3)V=A(cc,e(bD+R))C=2*T
J()H(_-5-C,a,15+5*T,11)y()r(_-4-C,a+3,"AG")au(_+6-C,a+1,2+5*T,8)r(_+8+1.5*C-5*#V,a+3,V)end
end
