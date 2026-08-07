
aK=nil
X=pairs
V=false
H=true
bY=property
ca=output
bT=input
ab=math
bx=table
bR=bx.insert
bU=ab.asin
bO=ab.atan
ay=ab.sqrt
al=ab.huge
v=ab.sin
t=ab.cos
q=bT.getNumber
ao=bT.getBool
P=ca.setNumber
Y=ca.setBool
bm=bY.getNumber
cO=bY.getBool
ac=ab.pi*2
cY=.025/2
cZ=2.2/2
f=1
cp=2
d_=30
cG=50
bJ=30
cI=.75
cU=10
ce=1.02
cC=5
ch=180
cw=3600
ct=300/60
cW=300/3600
s={}b={br=function(e,T,o)o={}for a=1,#e do
o[a]={}for d=1,#e[1]do
o[a][d]=e[a][d]+T[a][d]end
end
return o
end,sub=function(e,T,o)o={}for a=1,#e do
o[a]={}for d=1,#e[1]do
o[a][d]=e[a][d]-T[a][d]end
end
return o
end,G=function(e,T,o,aW)o={}for a=1,#e do
o[a]={}for d=1,#T[1]do
aW=0
for N=1,#e[1]do
aW=aW+e[a][N]*T[N][d]end
o[a][d]=aW
end
end
return o
end,bQ=function(e,_,o)o={}for a=1,#e do
o[a]={}for d=1,#e[1]do
o[a][d]=e[a][d]*_
end
end
return o
end,cb=function(e,S,E,y,bl,bB)S,E,y=#e,{},{}for a=1,S do
E[a]={}y[a]={}for d=1,S do
y[a][d]=e[a][d]E[a][d]=(a==d)and 1 or 0
end
end
for a=1,S do
bl=y[a][a]if bl~=0 then
for d=1,S do
y[a][d]=y[a][d]/bl
E[a][d]=E[a][d]/bl
end
for N=1,S do
if N~=a then
bB=y[N][a]for d=1,S do
y[N][d]=y[N][d]-bB*y[a][d]E[N][d]=E[N][d]-bB*E[a][d]end
end
end
end
end
return E
end,C=function(e,bb)bb={}for a=1,#e[1]do
bb[a]={}for d=1,#e do
bb[a][d]=e[d][a]end
end
return bb
end,aO=function(_,S,bg,ba,y,bS,bL)bg,ba,y=#_,#_[1],{}for a=1,bg*S do
y[a]={}for d=1,ba*S do
y[a][d]=0
end
end
for N=0,S-1 do
bS,bL=N*bg,N*ba
for a=1,bg do
for d=1,ba do
y[bS+a][bL+d]=_[a][d]end
end
end
return y
end}Q={ai=function(k,n,j)return{{t(j)*t(n),t(j)*v(n)*t(k)+v(j)*v(k),t(j)*v(n)*v(k)-v(j)*t(k)},{-v(n),t(n)*t(k),t(n)*v(k)},{v(j)*t(n),v(j)*v(n)*t(k)-t(j)*v(k),v(j)*v(n)*v(k)+t(j)*t(k)}}end,bF=function(g,i,l,L,M,J,k,n,j)local bt=b.br(b.G(Q.ai(k,n,j),b.C({{g,i,l}})),b.C({{L,J,M}}))return bt[1][1],bt[2][1],bt[3][1]end,aS=function(A,B,z,L,M,J,k,n,j)local bE=b.G(b.C(Q.ai(k,n,j)),b.sub(b.C({{A,B,z}}),b.C({{L,J,M}})))return bE[1][1],bE[2][1],bE[3][1]end}E=b.aO({{1}},9)bp={cD=function(O)local A,B,z
A,B,z=Q.bF(O.g,O.i,O.l,L,M,J,k,n,j)return{_=b.C({{A,0,0,B,0,0,z,0,0}}),K=b.aO({{(O.h*.02)^2/12}},9),bs={_=A,m=B,p=z,ad=0,ag=0,aj=0,ar=0,at=0,aB=0},m=b.C({{0,0,0}}),p=b.C({{O.h,O.D,O.u}}),W=0,aA=al,aN=H,as=0,an=0}end,x=function(w,f,bI)local _,ad,ar,m,ag,at,p,aj,aB=w._[1][1],w._[2][1],w._[3][1],w._[4][1],w._[5][1],w._[6][1],w._[7][1],w._[8][1],w._[9][1]bw={{f^5/20,f^4/8,f^3/6},{f^4/8,f^3/3,f^2/2},{f^3/6,f^2/2,f}}bw=b.aO(b.bQ(bw,bI),3)bd={{1,f,f^2/2},{0,1,f},{0,0,1}}bd=b.aO(bd,3)return{_={{ar*f^2/2+ad*f+_},{ar*f+ad},{ar},{at*f^2/2+ag*f+m},{at*f+ag},{at},{aB*f^2/2+aj*f+p},{aB*f+aj},{aB}},K=b.br(b.bQ(b.G(b.G(bd,w.K),b.C(bd)),ce),bw),W=w.W,m=w.m,p=w.p,aA=w.aA,aN=w.aN,as=w.as,an=w.an}end,am=function(U,O)local av,ap,bW,p,m,ai,bG,_,K,Z,ax,W,am,x
local g,i,l=Q.aS(U._[1][1],U._[4][1],U._[7][1],L,M,J,k,n,j)Z,ax=ay(g^2+i^2+l^2),ay(g^2+i^2)av={{g/Z,i/Z,l/Z},{i/ax^2,-g/ax^2,0},{-g*l/(Z^2*ax),-i*l/(Z^2*ax),ax/Z^2}}av=b.G(av,b.C(Q.ai(k,n,j)))ap={}for a=1,3 do
ap[a]={av[a][1],0,0,av[a][2],0,0,av[a][3],0,0}end
bW=b.C({{Z,bO(g,i),bU(l/Z)}})p=b.C({{O.h,O.D,O.u}})m=b.sub(p,bW)ai=b.aO({{(ac*.002)^2/12}},3)ai[1][1]=(O.h*.02)^2/12
bG=b.G(b.G(U.K,b.C(ap)),b.cb(b.br(b.G(b.G(ap,U.K),b.C(ap)),ai)))_=b.br(U._,b.G(bG,m))K=b.G(b.sub(E,b.G(bG,ap)),U.K)W=U.W+1
am={_=_,K=K,W=W,m=m,p=p,aA=U.aA,aN=H,as=U.as,an=U.an}x=bp.x(am,cp,0)am.bs={_=x._[1][1],m=x._[4][1],p=x._[7][1],ad=x._[2][1],ag=x._[5][1],aj=x._[8][1],ar=x._[3][1],at=x._[6][1],aB=x._[9][1]}return am
end}function cr(h,D,u,bC)if not bC then
u=u*ac
D=D*ac
end
_=h*t(u)*v(D)m=h*t(u)*t(D)p=h*v(u)return _,m,p
end
function bD(_,m,p,bC)bz=ay(_^2+m^2+p^2)D=bO(_,m)u=bU(p/bz)if bC then
return bz,D,u
else
return bz,D/ac,u/ac
end
end
function cm(bV,aF,aH)return ay(b.G(b.G(b.C(b.sub(bV,aF)),b.cb(aH)),b.sub(bV,aF))[1][1])end
function aX(cy,cl,cK,ck,cx,cN)return ay((cy-ck)^2+(cl-cx)^2+(cK-cN)^2)end
function bX(_,min,max)if _>=max then
_=max
elseif _<=min then
_=min
end
return _
end
function cT(K,E,cd,cR,bs,bP,cz,min,max)af=cR-bs
aV=bP+af
c_=af-cz
aZ=K*af+E*aV+cd*c_
if aZ>max or aZ<min then
aV=bP
aZ=K*af+E*aV+cd*c_
end
return bX(aZ,min,max),aV,af
end
cu,cE,cL=0,0,0
function cv(cs,cS,cP,cB,cA,co)local g,i,l,bc,bk,aY,h,aG,aQ
g,i,l=Q.aS(cs,cS,cP,L,M,J,k,n,j)bc,bk,aY=Q.aS(cB,cA,co,0,0,0,k,n,j)bc,bk,aY=bc-cu,bk-cL,aY-cE
h=ay(g^2+i^2+l^2)aG=-(bc*g+bk*i+aY*l)/h
aQ=aG>0 and bX(h/aG,0,al)or al
return aG,aQ
end
I={}function onTick()Y(32,V)Y(31,V)Y(30,V)cQ=bm("Vehicle radius [m]")cq,cJ,cM=bm("Radar phy. offset x (m)"),bm("Radar phy. offset y (m)"),bm("Radar phy. offset z (m)")cH=cO("Use tracking radar when aiming ELI")L,M,J,k,n,j=q(4),q(8),q(12),q(16),q(20),q(21)L,J,M=Q.bF(cq,cJ,cM,L,M,J,k,n,j)cj=ao(12)bv=ao(13)bn,bj,be,bZ,bN,bM=q(22),q(23),q(24),q(25),q(26),q(27)for r,c in X(I)do
c.bu=c.bu+1
if I[r].bu>3 then
I[r]=aK
end
end
F={}for a=1,5 do
h=q(a*4-3)D=q(a*4-2)*ac
u=q(a*4-1)*ac
g,i,l=cr(h,D,u,H)if ao(a)and h>=cQ then
bR(F,{h=h,D=D,u=u,g=g,i=i,l=l})end
end
if q(31)>0 then
local r,aR=q(31)%1000,ab.floor(q(31)/1000)I[aR]={_=q(28),m=q(29),p=q(30),r=r,W=q(32),bu=0}end
for a=1,#F do
e=F[a]if e==aK then
break
end
by=.02*e.h+bJ
aa={e}d=a+1
while d<=#F do
T=F[d]if aX(e.g,e.i,e.l,T.g,T.i,T.l)<by then
bR(aa,T)bx.remove(F,d)else
d=d+1
end
end
bi,b_,bq=0,0,0
for aU,o in X(aa)do
bi=bi+o.g
b_=b_+o.i
bq=bq+o.l
end
h,D,u=bD(bi/#aa,b_/#aa,bq/#aa,H)F[a]={h=h,D=D,u=u,g=bi/#aa,i=b_/#aa,l=bq/#aa}end
cX={bx.unpack(F)}for r,c in X(s)do
s[r].aN=V
s[r].aA=s[r].aA+1
cV=100*aX(ac*c.m[1][1]/c.p[1][1]/10,c.m[2][1],c.m[3][1],0,0,0)cn,s[r].an,s[r].as=cT(0,cC,0,cI,cV,c.an,c.as,-3,3)bI=10^-(8+cn)aF,aH,x={},{},bp.x(c,f,bI)for a=1,3 do
aF[a],aH[a]={x._[3*a-2][1]},{}for d=1,3 do
aH[a][d]=x.K[3*a-2][3*d-2]end
end
au,aM=al,0
for cg,aE in X(F)do
A,B,z=Q.bF(aE.g,aE.i,aE.l,L,M,J,k,n,j)_=b.C({{A,B,z}})bK=cm(_,aF,aH)if bK<au then
au=bK
aM=cg
end
end
if F[aM]~=aK then
af=(cW*f*f/2+ct*f+.02*F[aM].h)*15+cG
if au<af then
s[r]=bp.am(x,F[aM])F[aM]=aK
end
end
end
for aU,aE in X(F)do
bo,bh=1,H
while bh do
bh=V
for cF,aU in X(s)do
bh=cF==bo
if bh then
bo=bo+1
break
end
end
end
s[bo]=bp.cD(aE)end
for r,c in X(s)do
if not c.aN then
s[r]=aK
end
end
ah=V
ak,ae=0,0
aw,aq,az,aI,aC,aP,aD,aJ,aL=0,0,0,0,0,0,0,0,0
aT=V
cc=V
if cj then
function bH(aR)return I[aR]._,I[aR].m,I[aR].p
end
function bA(A,B,z)local g,i,l=Q.aS(A,B,z,L,M,J,k,n,j)local aU,ak,ae=bD(g,i,l,V)return ak,ae
end
local R,bf=0,al
for r,c in X(s)do
local _,m,p,ad,ag,aj=c._[1][1],c._[4][1],c._[7][1],c._[2][1],c._[5][1],c._[8][1]local aG,aQ=cv(_,m,p,ad,ag,aj)if aQ<bf then
bf=aQ
R=r
end
end
if R==0 then
if I[1]or I[2]then
if I[1]then
A,B,z=bH(1)elseif I[2]then
A,B,z=bH(2)end
ak,ae=bA(A,B,z)ah=H
end
else
local c=s[R]._
A,B,z=c[1][1],c[4][1],c[7][1]ak,ae=bA(A,B,z)ah=H
end
if(I[1]and R~=0)and(I[1].W<bf-ch)then
A,B,z=bH(1)ak,ae=bA(A,B,z)ah=H
end
if R~=0 then
local c=s[R].bs
aw,aq,az,aI,aC,aP,aD,aJ,aL=c._,c.m,c.p,c.ad,c.ag,c.aj,c.ar,c.at,c.aB
cf=bf<cw
ci=s[R].W>cU
if ci and cf then
aT=H
else
cc=H
end
end
else
if cH then
local R,au=0,al
if bv then
local by=.05*aX(bn,bj,be,L,J,M)+bJ
for r,c in X(s)do
local h=aX(bn,bj,be,c._[1][1],c._[4][1],c._[7][1])if h<by and h<au then
au=h
R=r
end
end
end
if R~=0 then
ah=H
aT=H
local c=s[R]._
aw,aq,az,aI,aC,aP,aD,aJ,aL=c[1][1],c[4][1],c[7][1],c[2][1],c[5][1],c[8][1],c[3][1],c[6][1],c[9][1]elseif bv then
ah=H
aT=H
aw,aq,az,aI,aC,aP,aD,aJ,aL=bn,bj,be,bZ,bN,bM,0,0,0
end
if ah then
local g,i,l=Q.aS(aw,aq,az,L,M,J,k,n,j)aU,ak,ae=bD(g,i,l,V)end
else
aT=bv
aw,aq,az,aI,aC,aP,aD,aJ,aL=bn,bj,be,bZ,bN,bM,0,0,0
end
end
Y(1,aT)Y(2,ah)Y(3,cc)P(1,ak)P(2,ae)P(3,aw)P(4,aq)P(5,az)P(6,aI)P(7,aC)P(8,aP)P(9,aD)P(10,aJ)P(11,aL)Y(9,ao(9))Y(10,ao(10))Y(11,ao(11))P(31,#s)end
