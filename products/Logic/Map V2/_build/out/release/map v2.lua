cw="%02.0f"
cv="%d"
cu="%.0f"
ct=":"

p=255
X=true
v=false
aP=property
bs=output
be=input
C=math
bl=table
ba=map
G=screen
w=G.setColor
by=ba.screenToMap
aY=bl.remove
aT=bl.insert
ah=G.drawText
z=G.drawRectF
ae=C.floor
B=string.format
bD=G.drawLine
aZ=ba.mapToScreen
b=C.sin
c=C.cos
ai=C.pi
aU=C.atan
aw=C.sqrt
bm=C.log
h=be.getNumber
ac=be.getBool
u=bs.setNumber
bg=bs.setBool
F=aP.getNumber
cs=aP.getBool
bh=aP.getText
c_=.5
j={{0,0}}I=0
y={}Z=v
aj=X
b_=v
s=0
A=0
function bP(_,min,max)local x,bk,l
bk=bm(min)x=bm(max/min)l=C.exp(x*_+bk)return l
end
function Q(_,min,max)if _>=max then
return max
elseif _<=min then
return min
else
return _
end
end
function bz(aD,aG,aq,aE)return aw((aD-aq)^2+(aG-aE)^2)end
function cr(_)return(_+.5)%1-.5
end
function bu(_,l)if _>=0 then
aO=aU(l/_)elseif l>=0 then
aO=aU(l/_)+ai
else
aO=aU(l/_)-ai
end
return aO
end
function bK(U,T,V,n,ad,m,e,g,d)local bC,bB,bw
bC=c(d)*c(g)*U+(c(d)*b(g)*b(e)-b(d)*c(e))*V+(c(d)*b(g)*c(e)+b(d)*b(e))*T
bB=b(d)*c(g)*U+(b(d)*b(g)*b(e)+c(d)*c(e))*V+(b(d)*b(g)*c(e)-c(d)*b(e))*T
bw=-b(g)*U+c(g)*b(e)*V+c(g)*c(e)*T
return bC+n,bw+m,bB+ad
end
function ca(aQ,aI,aN,n,ad,m,e,g,d)local x,O,M,K,L,P,N,a,f,as,au,at,_,R,l,am
aQ=aQ-n
aI=aI-m
aN=aN-ad
x=c(d)*c(g)O=c(d)*b(g)*b(e)-b(d)*c(e)M=c(d)*b(g)*c(e)+b(d)*b(e)K=aQ
L=b(d)*c(g)P=b(d)*b(g)*b(e)+c(d)*c(e)N=b(d)*b(g)*c(e)-c(d)*b(e)a=aN
f=-b(g)as=c(g)*b(e)au=c(g)*c(e)at=aI
am=((x*P-O*L)*au+(M*L-x*N)*as+(O*N-M*P)*f)_=0
l=0
R=0
if am~=0 then
_=((O*N-M*P)*at+(K*P-O*a)*au+(M*a-K*N)*as)/am
l=-((x*N-M*L)*at+(K*L-x*a)*au+(M*a-K*N)*f)/am
R=((x*P-O*L)*at+(K*L-x*a)*as+(O*a-K*P)*f)/am
end
return _,R,l
end
function cc(_,l,R,cb)local ag,S
ag=bu(aw(_^2+l^2),R)S=bu(l,_)bt=aw(_^2+l^2+R^2)if cb then
return ag,S,bt
else
return ag/(ai*2),S/(ai*2),bt
end
end
aW=0
aK=0
function cd(aB,aA,ax,bW,bN,bb,ce,min,max)local W,aV,ao
W=bW-bN
aC=bb+W
aV=W-ce
ao=aB*W+aA*aC+ax*aV
if ao>max or ao<min then
aC=bb
ao=aB*W+aA*aC+ax*aV
end
return Q(ao,min,max),aC,W
end
function bH(q,r,k,i,a,n,m,ab)local ay,av,aD,aq,aG,aE
ay,av=aZ(q,r,k,i,a,n,m)aD=ay-2*b(ab)aG=av-2*c(ab)aq=ay-6*b(ab)aE=av-6*c(ab)G.drawCircle(ay,av,2)bD(aD,aG,aq,aE)end
function bJ(_,t,E,o,J)local an
_=_*o
if _/(o/t)<1 then
an=B(cu,_)..J
elseif _/(o/t)<10 then
an=B("%.2f",_/(o/t))..E
elseif _/(o/t)<100 then
an=B("%.1f",_/(o/t))..E
else
an=B(cu,_/(o/t))..E
end
return an
end
function bZ(k,i,a,t,E,o,J)local aX,ap,ar
k=k*1000*o
if k/5>=(o/t)then
k=k/(o/t)J=E
end
aX=bV(k/5)ap=ae(i*aX/k)ar=B(cu,aX)..J
z(Q(i*4.5/5-1-ap/2,0,i-ap),a-10,ap,3)ah(Q(i*4.5/5-1-#ar*2.5,0,i-5*#ar),a-6,ar)end
function bV(D)local f=0
while D>=10 do
D=D/10
f=f+1
end
if D<2 then
D=1
elseif D<5 then
D=2
else
D=5
end
return D*10^f
end
function bL(_)local bc,min,aH,az
bc=B(cv,ae(_/3600))aH=B(cw,ae(_%60+.5))if _<3600 then
min=B(cv,ae((_/60)%60))az=min..ct..aH
elseif _>=36000 then
az="-:--:--"
else
min=B(cw,ae((_/60)%60))az=bc..ct..min..ct..aH
end
return az
end
function onTick()local i,a
i=h(1)a=h(2)H=h(3)al=h(4)n=h(5)ad=h(6)m=h(7)e=h(8)g=h(9)d=h(10)bQ=h(11)bS=h(12)bY=h(13)ab=h(14)*ai*2
bj=h(15)bd=h(16)ci=F("max zoom (km)")cj=F("min zoom (km)")bF=F("zoom speed")/60
aB=h(17)aA=h(18)ax=h(19)af=F("Longest tap interval [tick]")cg=F("Waypoint switch arrival time [s]")co=F("Map color")t=F("Distance units (Large)")E=bh("Units text (Large)")o=F("Distance units (Small)")J=bh("Units text (Small)")bE=ac(1)ch=ac(2)cn=ac(3)bR=ac(4)bG=ac(5)bi=v
bq=v
bn=v
cf,cm,cl=bK(bQ,bY,bS,0,0,0,e,g,d)aT(y,{cf,cm,cl})while#y>300 do
aY(y,1)end
aR,aS,aJ=0,0,0
for f=1,#y do
aR=aR+y[f][1]aS=aS+y[f][2]aJ=aJ+y[f][3]end
cp=aR/#y
ck=aS/#y
cq=aJ/#y
j[1]={n,m}if cn then
if bR then
aT(j,{bj,bd})q,r=bj,bd
aj=v
end
if bE then
if H>=1 and H<=8 and al>=a-7 then
bi=X
aj=X
s=0
elseif H>=10 and H<=17 and al>=a-7 then
bq=X
s=0
j={{n,m}}elseif H>=19 and H<=26 and al>=a-7 then
bn=X
if not aL and#j>1 then
aY(j,#j)end
elseif A<=af and A>0 and s>0 then
if not aL then
q,r=by(q,r,k,i,a,H,al)aT(j,{q,r})end
aj=v
elseif ch then
ak=Q(ak-bF,0,1)b_=X
s=0
elseif s>af then
ak=Q(ak+bF,0,1)else
s=s+1
A=0
end
else
if(aL and(A>0 or s>af))or b_ then
s,A=0,0
elseif s<=af and s>0 then
A=A+1
end
b_=v
if A>=af then
q,r=by(q,r,k,i,a,H,al)s,A=0,0
aj=v
end
end
aL=bE
else
q,r=n,m
s=0
A=0
ak=c_
end
Y,aa=0,0
while#j>1 do
Y=j[2][1]aa=j[2][2]local bv,br=Y-n,aa-m
bo=(bv*cp+br*ck)/aw(bv^2+br^2)aF=bz(n,m,Y,aa)I=aF/bo
if I<0 or C.abs(bo)<.01 then
I=36000
else
I=Q(I,0,36000)end
if I<cg then
aY(j,2)else
break
end
end
aM=#j>1
aF=bz(n,m,Y,aa)bT=bJ(aF,t,E,o,J)k=bP(ak,cj,ci)if bG and not bM then
Z=not Z
end
bM=bG
if not aM then
Z=v
end
if Z then
local U,T,V,ag,S,bU
U,T,V=ca(Y,aa,0,n,0,m,e,g,d)ag,S,bU=cc(U,T,V,v)bp,aK,aW=cd(aB,aA,ax,0,-S,aK,aW,-1,1)else
bp,aK,aW=0,0,0
end
if aj then
q,r=n,m
end
bg(1,aM)bg(2,Z)u(1,Y)u(2,aa)u(3,ad)u(4,0)u(5,0)u(6,0)u(7,aF)u(8,I)u(9,bp)u(10,q)u(11,r)u(12,k)end
function onDraw()local i,a
i=G.getWidth()a=G.getHeight()if aM then
for f=2,#j do
bA,bx=aZ(q,r,k,i,a,j[f][1],j[f][2])bX,bI=aZ(q,r,k,i,a,j[f-1][1],j[f-1][2])w(0,p,0)bD(bA,bx,bX,bI)w(p,0,0)G.drawCircleF(bA,bx,1.5)end
w(0,p,0)ah(1,1,"WP:"..bT)end
if co==2 then
w(p,p,p)else
w(0,0,p)end
bH(q,r,k,i,a,n,m,ab)w(32,32,32)z(0,a-7,28,7)w(64,64,64)for f=0,2 do
z(1+f*9,a-6,8,5)z(2+f*9,a-7,6,7)end
w(0,p,0)if bi then
z(1,a-6,8,5)z(2,a-7,6,7)end
if bq then
z(10,a-6,8,5)z(11,a-7,6,7)end
if bn then
z(19,a-6,8,5)z(20,a-7,6,7)end
bO={"M","C","B"}w(p,p,p)for f=0,2 do
ah(3+9*f,a-6,bO[f+1])end
w(0,p,0)bZ(k,i,a,t,E,o,J)if Z then
w(0,p,0)ah(i-11,1,"AP")bf=bL(I)ah(36-5*#bf,7,bf)end
end
