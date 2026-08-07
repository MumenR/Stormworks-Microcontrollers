
aE=nil
Z=pairs
V=false
F=true
bM=property
bR=output
cb=input
ab=math
bE=table
bU=bE.insert
cg=ab.asin
bT=ab.atan
as=ab.sqrt
ay=ab.huge
x=ab.sin
v=ab.cos
h=cb.getNumber
al=cb.getBool
N=bR.setNumber
Y=bR.setBool
bc=bM.getNumber
cx=bM.getBool
ac=ab.pi*2
da=.025/2
dc=2.2/2
f=1
cH=2
d_=30
cz=50
bJ=30
cR=.75
cj=10
cn=1.02
cD=5
cL=180
ck=3600
cS=300/60
cG=300/3600
s={}b={bs=function(e,U,p)p={}for a=1,#e do
p[a]={}for d=1,#e[1]do
p[a][d]=e[a][d]+U[a][d]end
end
return p
end,sub=function(e,U,p)p={}for a=1,#e do
p[a]={}for d=1,#e[1]do
p[a][d]=e[a][d]-U[a][d]end
end
return p
end,G=function(e,U,p,aZ)p={}for a=1,#e do
p[a]={}for d=1,#U[1]do
aZ=0
for O=1,#e[1]do
aZ=aZ+e[a][O]*U[O][d]end
p[a][d]=aZ
end
end
return p
end,cf=function(e,_,p)p={}for a=1,#e do
p[a]={}for d=1,#e[1]do
p[a][d]=e[a][d]*_
end
end
return p
end,ce=function(e,S,E,y,bq,by)S,E,y=#e,{},{}for a=1,S do
E[a]={}y[a]={}for d=1,S do
y[a][d]=e[a][d]E[a][d]=(a==d)and 1 or 0
end
end
for a=1,S do
bq=y[a][a]if bq~=0 then
for d=1,S do
y[a][d]=y[a][d]/bq
E[a][d]=E[a][d]/bq
end
for O=1,S do
if O~=a then
by=y[O][a]for d=1,S do
y[O][d]=y[O][d]-by*y[a][d]E[O][d]=E[O][d]-by*E[a][d]end
end
end
end
end
return E
end,C=function(e,br)br={}for a=1,#e[1]do
br[a]={}for d=1,#e do
br[a][d]=e[d][a]end
end
return br
end,aS=function(_,S,bm,aV,y,bZ,bS)bm,aV,y=#_,#_[1],{}for a=1,bm*S do
y[a]={}for d=1,aV*S do
y[a][d]=0
end
end
for O=0,S-1 do
bZ,bS=O*bm,O*aV
for a=1,bm do
for d=1,aV do
y[bZ+a][bS+d]=_[a][d]end
end
end
return y
end}T={ai=function(n,o,l)return{{v(l)*v(o),v(l)*x(o)*v(n)+x(l)*x(n),v(l)*x(o)*x(n)-x(l)*v(n)},{-x(o),v(o)*v(n),v(o)*x(n)},{x(l)*v(o),x(l)*x(o)*v(n)-v(l)*x(n),x(l)*x(o)*x(n)+v(l)*v(n)}}end,bu=function(i,j,m,L,J,K,n,o,l)local bv=b.bs(b.G(T.ai(n,o,l),b.C({{i,j,m}})),b.C({{L,K,J}}))return bv[1][1],bv[2][1],bv[3][1]end,aJ=function(z,B,D,L,J,K,n,o,l)local bG=b.G(b.C(T.ai(n,o,l)),b.sub(b.C({{z,B,D}}),b.C({{L,K,J}})))return bG[1][1],bG[2][1],bG[3][1]end}E=b.aS({{1}},9)aW={cI=function(P)local z,B,D
z,B,D=T.bu(P.i,P.j,P.m,L,J,K,n,o,l)return{_=b.C({{z,0,0,B,0,0,D,0,0}}),M=b.aS({{(P.g*.02)^2/12}},9),bh={_=z,k=B,q=D,aj=0,ag=0,ah=0,am=0,ax=0,ao=0},k=b.C({{0,0,0}}),q=b.C({{P.g,P.A,P.u}}),W=0,ar=ay,aM=F,aq=0,ap=0}end,w=function(t,f,bF)local _,aj,am,k,ag,ax,q,ah,ao=t._[1][1],t._[2][1],t._[3][1],t._[4][1],t._[5][1],t._[6][1],t._[7][1],t._[8][1],t._[9][1]bt={{f^5/20,f^4/8,f^3/6},{f^4/8,f^3/3,f^2/2},{f^3/6,f^2/2,f}}bt=b.aS(b.cf(bt,bF),3)bk={{1,f,f^2/2},{0,1,f},{0,0,1}}bk=b.aS(bk,3)return{_={{am*f^2/2+aj*f+_},{am*f+aj},{am},{ax*f^2/2+ag*f+k},{ax*f+ag},{ax},{ao*f^2/2+ah*f+q},{ao*f+ah},{ao}},M=b.bs(b.cf(b.G(b.G(bk,t.M),b.C(bk)),cn),bt),W=t.W,k=t.k,q=t.q,ar=t.ar,aM=t.aM,aq=t.aq,ap=t.ap}end,aw=function(R,P)local aB,av,bY,q,k,ai,bH,_,M,X,at,W,aw,w
local i,j,m=T.aJ(R._[1][1],R._[4][1],R._[7][1],L,J,K,n,o,l)X,at=as(i^2+j^2+m^2),as(i^2+j^2)aB={{i/X,j/X,m/X},{j/at^2,-i/at^2,0},{-i*m/(X^2*at),-j*m/(X^2*at),at/X^2}}aB=b.G(aB,b.C(T.ai(n,o,l)))av={}for a=1,3 do
av[a]={aB[a][1],0,0,aB[a][2],0,0,aB[a][3],0,0}end
bY=b.C({{X,bT(i,j),cg(m/X)}})q=b.C({{P.g,P.A,P.u}})k=b.sub(q,bY)ai=b.aS({{(ac*.002)^2/12}},3)ai[1][1]=(P.g*.02)^2/12
bH=b.G(b.G(R.M,b.C(av)),b.ce(b.bs(b.G(b.G(av,R.M),b.C(av)),ai)))_=b.bs(R._,b.G(bH,k))M=b.G(b.sub(E,b.G(bH,av)),R.M)W=R.W+1
aw={_=_,M=M,W=W,k=k,q=q,ar=R.ar,aM=F,aq=R.aq,ap=R.ap}w=aW.w(aw,cH,0)aw.bh={_=w._[1][1],k=w._[4][1],q=w._[7][1],aj=w._[2][1],ag=w._[5][1],ah=w._[8][1],am=w._[3][1],ax=w._[6][1],ao=w._[9][1]}return aw
end}function cZ(g,A,u,bD)if not bD then
u=u*ac
A=A*ac
end
_=g*v(u)*x(A)k=g*v(u)*v(A)q=g*x(u)return _,k,q
end
function bz(_,k,q,bD)bw=as(_^2+k^2+q^2)A=bT(_,k)u=cg(q/bw)if bD then
return bw,A,u
else
return bw,A/ac,u/ac
end
end
function cQ(c_,aK,aP)return as(b.G(b.G(b.C(b.sub(c_,aK)),b.ce(aP)),b.sub(c_,aK))[1][1])end
function bi(cs,cM,cT,cu,cp,ct)return as((cs-cu)^2+(cM-cp)^2+(cT-ct)^2)end
function bK(_,min,max)if _>=max then
_=max
elseif _<=min then
_=min
end
return _
end
function cF(M,E,bX,cw,bh,bO,cv,min,max)ae=cw-bh
bl=bO+ae
ca=ae-cv
bp=M*ae+E*bl+bX*ca
if bp>max or bp<min then
bl=bO
bp=M*ae+E*bl+bX*ca
end
return bK(bp,min,max),bl,ae
end
cJ,cE,cP=0,0,0
function cq(cl,cm,cC,cN,cA,cO)local i,j,m,bj,bn,bo,g,aQ,aI
i,j,m=T.aJ(cl,cm,cC,L,J,K,n,o,l)bj,bn,bo=T.aJ(cN,cA,cO,0,0,0,n,o,l)bj,bn,bo=bj-cJ,bn-cP,bo-cE
g=as(i^2+j^2+m^2)aQ=-(bj*i+bn*j+bo*m)/g
aI=aQ>0 and bK(g/aQ,0,ay)or ay
return aQ,aI
end
I={}function onTick()Y(32,V)Y(31,V)Y(30,V)cV=bc("Vehicle radius [m]")cX,cY,ch=bc("Radar phy. offset x (m)"),bc("Radar phy. offset y (m)"),bc("Radar phy. offset z (m)")cU=cx("Use tracking radar when aiming ELI")L,J,K,n,o,l=h(4),h(8),h(12),h(16),h(20),h(21)L,K,J=T.bu(cX,cY,ch,L,J,K,n,o,l)co=al(12)bx=al(13)ba,aX,b_,bW,cd,bQ=h(22),h(23),h(24),h(25),h(26),h(27)bP,bL,bV=h(17),h(18),h(19)for r,c in Z(I)do
c.bC=c.bC+1
if I[r].bC>3 then
I[r]=aE
end
end
H={}for a=1,4 do
g=h(a*4-3)A=h(a*4-2)*ac
u=h(a*4-1)*ac
i,j,m=cZ(g,A,u,F)if al(a)and g>=cV then
bU(H,{g=g,A=A,u=u,i=i,j=j,m=m})end
end
if h(31)>0 then
local r,aG=h(31)%1000,ab.floor(h(31)/1000)I[aG]={_=h(28),k=h(29),q=h(30),r=r,W=h(32),bC=0}end
for a=1,#H do
e=H[a]if e==aE then
break
end
bB=.02*e.g+bJ
aa={e}d=a+1
while d<=#H do
U=H[d]if bi(e.i,e.j,e.m,U.i,U.j,U.m)<bB then
bU(aa,U)bE.remove(H,d)else
d=d+1
end
end
be,bd,bg=0,0,0
for aY,p in Z(aa)do
be=be+p.i
bd=bd+p.j
bg=bg+p.m
end
g,A,u=bz(be/#aa,bd/#aa,bg/#aa,F)H[a]={g=g,A=A,u=u,i=be/#aa,j=bd/#aa,m=bg/#aa}end
db={bE.unpack(H)}for r,c in Z(s)do
s[r].aM=V
s[r].ar=s[r].ar+1
cr=100*bi(ac*c.k[1][1]/c.q[1][1]/10,c.k[2][1],c.k[3][1],0,0,0)cy,s[r].ap,s[r].aq=cF(0,cD,0,cR,cr,c.ap,c.aq,-3,3)bF=10^-(8+cy)aK,aP,w={},{},aW.w(c,f,bF)for a=1,3 do
aK[a],aP[a]={w._[3*a-2][1]},{}for d=1,3 do
aP[a][d]=w.M[3*a-2][3*d-2]end
end
az,aF=ay,0
for ci,aH in Z(H)do
z,B,D=T.bu(aH.i,aH.j,aH.m,L,J,K,n,o,l)_=b.C({{z,B,D}})bN=cQ(_,aK,aP)if bN<az then
az=bN
aF=ci
end
end
if H[aF]~=aE then
ae=(cG*f*f/2+cS*f+.02*H[aF].g)*15+cz
if az<ae then
s[r]=aW.aw(w,H[aF])H[aF]=aE
end
end
end
for aY,aH in Z(H)do
bf,bb=1,F
while bb do
bb=V
for cW,aY in Z(s)do
bb=cW==bf
if bb then
bf=bf+1
break
end
end
end
s[bf]=aW.cI(aH)end
for r,c in Z(s)do
if not c.aM then
s[r]=aE
end
end
ad=V
af,ak=0,0
an,aA,au,aD,aR,aN,aC,aT,aO=0,0,0,0,0,0,0,0,0
aL=V
cc=V
if co then
function bI(aG)return I[aG]._,I[aG].k,I[aG].q
end
function bA(z,B,D)local i,j,m=T.aJ(z,B,D,L,J,K,n,o,l)local aY,af,ak=bz(i,j,m,V)return af,ak
end
local Q,aU=0,ay
for r,c in Z(s)do
local _,k,q,aj,ag,ah=c._[1][1],c._[4][1],c._[7][1],c._[2][1],c._[5][1],c._[8][1]local aQ,aI=cq(_,k,q,aj,ag,ah)if aI<aU then
aU=aI
Q=r
end
end
if Q==0 then
if I[1]or I[2]then
if I[1]then
z,B,D=bI(1)elseif I[2]then
z,B,D=bI(2)end
af,ak=bA(z,B,D)ad=F
end
else
local c=s[Q]._
z,B,D=c[1][1],c[4][1],c[7][1]af,ak=bA(z,B,D)ad=F
end
if(I[1]and Q~=0)and(I[1].W<aU-cL)then
z,B,D=bI(1)af,ak=bA(z,B,D)ad=F
end
if Q~=0 then
local c=s[Q].bh
an,aA,au,aD,aR,aN,aC,aT,aO=c._,c.k,c.q,c.aj,c.ag,c.ah,c.am,c.ax,c.ao
cB=aU<ck
cK=s[Q].W>cj
if cK and cB then
aL=F
else
cc=F
end
end
else
if cU then
local Q,az=0,ay
if bx then
local bB=.05*bi(ba,aX,b_,L,K,J)+bJ
for r,c in Z(s)do
local g=bi(ba,aX,b_,c._[1][1],c._[4][1],c._[7][1])if g<bB and g<az then
az=g
Q=r
end
end
end
if Q~=0 then
ad=F
aL=F
local c=s[Q]._
an,aA,au,aD,aR,aN,aC,aT,aO=c[1][1],c[4][1],c[7][1],c[2][1],c[5][1],c[8][1],c[3][1],c[6][1],c[9][1]elseif bx then
ad=F
aL=F
an,aA,au,aD,aR,aN,aC,aT,aO=ba,aX,b_,bW,cd,bQ,bP,bL,bV
end
if ad then
local i,j,m=T.aJ(an,aA,au,L,J,K,n,o,l)aY,af,ak=bz(i,j,m,V)end
else
aL=bx
an,aA,au,aD,aR,aN,aC,aT,aO=ba,aX,b_,bW,cd,bQ,bP,bL,bV
end
end
Y(1,aL)Y(2,ad)Y(3,cc)N(1,af)N(2,ak)N(3,an)N(4,aA)N(5,au)N(6,aD)N(7,aR)N(8,aN)N(9,aC)N(10,aT)N(11,aO)Y(9,al(9))Y(10,al(10))Y(11,al(11))N(31,#s)end
