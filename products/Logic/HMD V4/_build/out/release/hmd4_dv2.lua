cf=":"
ce="WP"
cd="%d"
cc="%02.0f"

P=.5
w=360
aU=tostring
ax=false
bn=property
bo=output
bh=input
Z=math
S=screen
aC=S.drawRect
I=S.drawRectF
z=string.format
s=S.drawText
bc=S.drawCircle
e=Z.floor
R=S.drawLine
bu=Z.tan
ba=Z.sqrt
c=Z.sin
b=Z.cos
aL=Z.atan
aY=S.setColor
U=Z.pi
i=bh.getNumber
c_=bh.getBool
br=bo.setNumber
cb=bo.setBool
av=bn.getNumber
x=bn.getBool
ab=U*2
aQ=(58/w)*ab
function y()aY(0,255,0)end
function K()aY(0,0,0)end
function aA(d,p)if d>=0 then
aM=aL(p/d)elseif p>=0 then
aM=aL(p/d)+U
else
aM=aL(p/d)-U
end
return aM
end
function bs(d,min,max)if d>=max then
d=max
elseif d<=min then
d=min
end
return d
end
function T(l,m,o,ar,an,al,f,h,g)local A,D,ad,aa,ae,af,ac,q,v,r,F,az,d,C,p,am
l=l-ar
m=m-al
o=o-an
A=b(g)*b(h)D=b(g)*c(h)*c(f)-c(g)*b(f)ad=b(g)*c(h)*b(f)+c(g)*c(f)aa=l
ae=c(g)*b(h)af=c(g)*c(h)*c(f)+b(g)*b(f)ac=c(g)*c(h)*b(f)-b(g)*c(f)q=o
v=-c(h)r=b(h)*c(f)F=b(h)*b(f)az=m
am=((A*af-D*ae)*F+(ad*ae-A*ac)*r+(D*ac-ad*af)*v)d=0
p=0
C=0
if am~=0 then
d=((D*ac-ad*af)*az+(aa*af-D*q)*F+(ad*q-aa*ac)*r)/am
p=-((A*ac-ad*ae)*az+(aa*ae-A*q)*F+(ad*q-aa*ac)*v)/am
C=((A*af-D*ae)*az+(aa*ae-A*q)*r+(D*q-aa*af)*v)/am
end
return d,C,p
end
function aw(k,j,n,ar,an,al,f,h,g)local bt,bj,bp
bt=b(g)*b(h)*k+(b(g)*c(h)*c(f)-c(g)*b(f))*n+(b(g)*c(h)*b(f)+c(g)*c(f))*j
bj=c(g)*b(h)*k+(c(g)*c(h)*c(f)+b(g)*b(f))*n+(c(g)*c(h)*b(f)-b(g)*c(f))*j
bp=-c(h)*k+b(h)*c(f)*n+b(h)*b(f)*j
return bt+ar,bp+al,bj+an
end
function bS(d,p,C,aq)local u,t
u=aA(ba(d^2+p^2),C)t=aA(p,d)N=ba(d^2+p^2+C^2)if aq then
return u,t,N
else
return u/(U*2),t/(U*2),N
end
end
function bq(u,t,N,aq)local d,p,C
if not aq then
u=u*U*2
t=t*U*2
end
d=N*b(u)*c(t)p=N*b(u)*b(t)C=N*c(u)return d,p,C
end
function bF(u,t,N,aq)local d,p,C
if not aq then
u=u*U*2
t=t*U*2
end
d=N*c(t)p=N*b(t)*b(u)C=N*b(t)*c(u)return d,p,C
end
function aB(k,j,n)local G,M,H
G=E/2+(k/j)*(q/2)/bu(aQ/2)M=q/2-(n/j)*(q/2)/bu(aQ/2)H=j>0
return G,M,H
end
function bm(l,m,o,f,h,g)local k,j,n,G,M,H
k,j,n=T(l,m,o,0,0,0,f,h,g)k,j,n=T(k,j,n,0,0,0,-aj,as,0)G,M,H=aB(k,j,n)return G,M,H
end
function ay(u,t,aF,aJ,aI)local l,m,o,G,M,H
l,m,o=bq(u,t,1,ax)l,m,o=T(l,m,o,0,0,0,aF,aJ,aI)G,M,H=bm(l,m,o,f,h,g)return G,M,H
end
function aD(u,t,aF,aJ,aI)local l,m,o,G,M,H
l,m,o=bF(u,t,1,ax)l,m,o=T(l,m,o,0,0,0,aF,aJ,aI)G,M,H=bm(l,m,o,f,h,g)return G,M,H
end
function bR(_,a,J,O)local A,D,ap
A=bs((a-O)/(_-J),-1000,1000)D=a-A*_
ap=2*b(aA(J-_,O-a))for d=_,J-ap,ap*2 do
if ai(d,A*d+D)then
R(d,A*d+D,d+ap,A*(d+ap)+D)end
end
end
function ai(d,p)return d>=0 and d<=E and p>=0 and p<=q
end
function aK(by,bx)return#aU(e(by*bx+P))end
function onTick()aE=av("Speed Units")aG=av("Altitude Units")aV=av("Distance Units")Y=aK(500,aE)W=aK(30000,aG)V=bs(aK(150000,aV),3,100)ar=i(1)an=i(2)al=i(3)f=i(4)h=i(5)g=i(6)bW=i(21)*aG
bO=i(2)*aG
aX=i(13)*aE
aT=i(20)*aE
Q=i(17)*ab
as=i(9)*ab
aj=i(10)*ab
bH=i(22)bN=i(23)bY=i(24)aH=i(25)*aV
ag=i(26)bz=i(27)==1
bZ=i(28)==1
bC=i(29)==1
bX=i(30)bD=i(31)==1
bE=i(32)==1
bl=x("air speed")aZ=x("ground speed")ao=x("main speed")bw=x("air altitude")bJ=x("ground altitude")bK=x("magnetic heading")bk=x("attitude bars")bL=x("horizon line")bg=x("center marker")bB=x("laser direction")bT=x("waypoint marker")bQ=x("waypoint marker label")bP=x("waypoint marker distance")bU=x("waypoint distance")bA=x("waypoint arrival time")bi=e(av("Minimum angle for attitude bars"))if bB then
k,j,n=T(0,0,-1,0,0,0,f,h,g)k,j,n=T(k,j,n,0,0,0,ab/4,0,0)bM,bv,ca=bS(k,j,n,ax)br(1,bv*8)br(2,bM*8)end
end
function onDraw()E=S.getWidth()q=S.getHeight()y()if bg then
k,j,n=T(0,1,0,0,0,0,-aj,as,0)_,a,L=aB(k,j,n)if L then
bc(_,a,3)R(_+3,a,_+10,a)R(_-3,a,_-10,a)R(_,a-3,_,a-8)end
end
if bL then
local b_=5
if not bg then
b_=0
end
for v=b_,180,45 do
for r=-1,1,2 do
_,a,L=ay(0,r*v/w,0,Q,0)J,O,at=ay(0,r*(v+45)/w,0,Q,0)if L and at then
R(_,a,J,O)end
end
end
elseif bk then
for r=-1,1,2 do
_,a,L=ay(0,r*5/w,0,Q,0)J,O,at=ay(0,r*15/w,0,Q,0)if L and at then
R(_,a,J,O)end
end
end
if bk then
for v=bi,175,bi do
for r=-1,1,2 do
for F=-1,1,2 do
_,a,L=aD(F*v/w,r*12/w,0,Q,0)J,O,at=aD(F*v/w,r*5/w,0,Q,0)bd,be,bI=aD(F*(v-1)/w,r*12/w,0,Q,0)aR,aP,bG=aD(F*v/w,r*16/w,0,Q,0)if L and at and bI and bG then
if ai(_,a)or ai(J,O)then
if F==1 then
R(_,a,J,O)else
bR(J,O,_,a)end
end
if ai(_,a)or ai(bd,be)then
R(_,a,bd,be)end
if ai(aR,aP)then
s(aR-2.5*#aU(F*v),aP-3,F*v)end
end
end
end
end
end
if bK then
l,m,o=aw(0,1,0,0,0,0,-aj,as,0)l,m,o=aw(l,m,o,0,0,0,f,h,g)aN=aA(m,l)/ab
l,m,o=aw(0,0,1,0,0,0,-aj,as,0)l,m,o=aw(l,m,o,0,0,0,f,h,g)if o>0 then
r=1
else
r=-1
end
for v=0,r*355,r*5 do
k,j,n=bq(19.5/w,v/w-r*aN,1,ax)_,a,L=aB(k,j,n)if L then
R(_,a+2,_,a-2)if v%10==0 then
s(_-4,a-7,z("%02d",r*v/10))end
end
end
_=e(E/2)aN=z("%03.0f",w*((-Q/ab)%1))K()I(_-10,9,20,11)y()aC(_-9,10,17,8)S.drawTextBox(_-8,11,16,7,aN,0,0)end
if bz then
k,j,n=T(bH,bN,bY,ar,an,al,f,h,g)k,j,n=T(k,j,n,0,0,0,-aj,as,0)if aH>=10 then
au=z("%.0f",e(aH+P))else
au=z("%.1f",e(aH*10+P)/10)end
if bT then
_,a,L=aB(k,j,n)_=e(_)a=e(a)if L then
y()bc(_,a,5)if bQ then
s(_-4,a-11,ce)end
if bP then
s(_+1-2.5*#au,a+7,au)end
end
end
if bU then
_,a=e(E/5),e(3*q/5)K()I(_-5-5*V,a,13+5*V,7)y()s(_-4-5*V,a+1,ce)s(_+8-5*#au,a+1,au)end
if bA then
_,a=e(E/5),e(3*q/5)bV=z(cd,e(ag/3600))aS=z(cc,e(ag%60+P))if ag<3600 then
aO=z(cd,e((ag/60)%60))ah=aO..cf..aS
elseif ag>=36000 then
ah="-:--:--"
else
aO=z(cc,e((ag/60)%60))ah=bV..cf..aO..cf..aS
end
K()I(_+7-5*#ah,a+7,5*#ah+1,7)y()s(_+8-5*#ah,a+8,ah)end
end
if bZ then
_,a=e(E/5),e(3*q/5)K()I(_-5-5*V,a-7,11,7)y()s(_-4-5*V,a-6,"AP")end
if bD then
_,a=e(E/5)+11,e(3*q/5)K()I(_-5-5*V,a-7,11,7)y()s(_-4-5*V,a-6,"PH")end
if bE then
_,a=e(E/5)+22,e(3*q/5)K()I(_-5-5*V,a-7,11,7)y()s(_-4-5*V,a-6,"RH")end
if ao then
aW=aX
bb=aT
bf="AS"
else
aW=aT
bb=aX
bf="GS"
end
if(ao and aZ)or(not ao and bl)then
_,a=e(E/5),e(q/3)ak=z(cd,e(aW+P))K()I(_+5-5*Y,a,5*Y+5,11)y()aC(_+6-5*Y,a+1,5*Y+2,8)s(_+8-5*#ak,a+3,ak)end
if(ao and bl)or(not ao and aZ)then
ak=z(cd,e(bb+P))K()I(_-5-5*Y,a+10,5*Y+13,7)y()s(_-4-5*Y,a+11,bf)s(_+8-5*#ak,a+11,ak)end
if bw then
_,a=e(4*E/5),e(q/3)X=z(cd,e(bO+P))B=2*W
K()I(_-B,a,5+5*W,11)y()aC(_+1-B,a+1,2+5*W,8)s(_+3+1.5*B-5*#X,a+3,X)end
if bC then
_,a=e(4*E/5),e(q/3)+10
X=z(cd,e(bX+P))B=2*W
K()I(_-B-8,a,11+5*W,7)y()s(_-7-B,a+1,"AH")s(_+3+1.5*B-5*#X,a+1,X)end
if bJ then
_,a=e(4*E/5),e(2*q/3)X=z(cd,e(bW+P))B=2*W
K()I(_-5-B,a,15+5*W,11)y()s(_-4-B,a+3,"AG")aC(_+6-B,a+1,2+5*W,8)s(_+8+1.5*B-5*#X,a+3,X)end
end
