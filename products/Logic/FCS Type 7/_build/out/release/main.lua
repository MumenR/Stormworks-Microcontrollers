
V=pairs
aN=nil
ad=false
as=true
cm=output
cC=input
O=math
bD=table
ao=screen
bw=ao.drawLine
cu=ao.drawRect
az=ao.drawText
bX=bD.remove
aQ=bD.insert
ae=O.floor
cB=string.format
al=O.tan
bZ=O.log
cl=O.asin
bP=O.atan
aB=O.sqrt
bn=O.huge
u=O.sin
v=O.cos
K=cC.getNumber
aO=cC.getBool
q=cm.setNumber
cS=cm.setBool
af=property.getNumber
M=O.pi*2
bz=.025/2
aL=2.2/2
h=1
cH=11
da=15
cU=30
cE=50
dn=15
cJ=.27
db=1.01
cL=300/60
cF=300/3600
k={}bQ={e=0,d=0,f=-.5}b={bp=function(g,N,i)i={}for _=1,#g do
i[_]={}for c=1,#g[1]do
i[_][c]=g[_][c]+N[_][c]end
end
return i
end,sub=function(g,N,i)i={}for _=1,#g do
i[_]={}for c=1,#g[1]do
i[_][c]=g[_][c]-N[_][c]end
end
return i
end,F=function(g,N,i,bh)i={}for _=1,#g do
i[_]={}for c=1,#N[1]do
bh=0
for J=1,#g[1]do
bh=bh+g[_][J]*N[J][c]end
i[_][c]=bh
end
end
return i
end,ct=function(g,a,i)i={}for _=1,#g do
i[_]={}for c=1,#g[1]do
i[_][c]=g[_][c]*a
end
end
return i
end,cy=function(g,P,E,y,bq,bF)P,E,y=#g,{},{}for _=1,P do
E[_]={}y[_]={}for c=1,P do
y[_][c]=g[_][c]E[_][c]=(_==c)and 1 or 0
end
end
for _=1,P do
bq=y[_][_]if bq~=0 then
for c=1,P do
y[_][c]=y[_][c]/bq
E[_][c]=E[_][c]/bq
end
for J=1,P do
if J~=_ then
bF=y[J][_]for c=1,P do
y[J][c]=y[J][c]-bF*y[_][c]E[J][c]=E[J][c]-bF*E[_][c]end
end
end
end
end
return E
end,x=function(g,bf)bf={}for _=1,#g[1]do
bf[_]={}for c=1,#g do
bf[_][c]=g[c][_]end
end
return bf
end,aP=function(a,P,bx,bi,y,cg,cd)bx,bi,y=#a,#a[1],{}for _=1,bx*P do
y[_]={}for c=1,bi*P do
y[_][c]=0
end
end
for J=0,P-1 do
cg,cd=J*bx,J*bi
for _=1,bx do
for c=1,bi do
y[cg+_][cd+c]=a[_][c]end
end
end
return y
end}I={an=function(m,o,n)return{{v(n)*v(o),v(n)*u(o)*v(m)+u(n)*u(m),v(n)*u(o)*u(m)-u(n)*v(m)},{-u(o),v(o)*v(m),v(o)*u(m)},{u(n)*v(o),u(n)*u(o)*v(m)-v(n)*u(m),u(n)*u(o)*u(m)+v(n)*v(m)}}end,bd=function(e,d,f,aa,ab,Z,m,o,n)local bI=b.bp(b.F(I.an(m,o,n),b.x({{e,d,f}})),b.x({{aa,Z,ab}}))return bI[1][1],bI[2][1],bI[3][1]end,aT=function(ak,aj,ah,aa,ab,Z,m,o,n)local bL=b.F(b.x(I.an(m,o,n)),b.sub(b.x({{ak,aj,ah}}),b.x({{aa,Z,ab}})))return bL[1][1],bL[2][1],bL[3][1]end}E=b.aP({{1}},9)aK={de=function(L)local ak,aj,ah
ak,aj,ah=I.bd(L.e,L.d,L.f,aa,ab,Z,m,o,n)return{a=b.x({{ak,0,0,aj,0,0,ah,0,0}}),H=b.aP({{(L.j*.02)^2/60}},9),s={a=ak,l=aj,p=ah,aU=0,aX=0,aJ=0,au=0,ay=0,aA=0},l=b.x({{0,0,0}}),p=b.x({{L.j,L.A,L.w}}),ac=0,T=bn,aI=as,aC=0,ar=0}end,r=function(t,h,bY)local a,aU,au,l,aX,ay,p,aJ,aA=t.a[1][1],t.a[2][1],t.a[3][1],t.a[4][1],t.a[5][1],t.a[6][1],t.a[7][1],t.a[8][1],t.a[9][1]bW={{h^5/20,h^4/8,h^3/6},{h^4/8,h^3/3,h^2/2},{h^3/6,h^2/2,h}}bW=b.aP(b.ct(bW,bY),3)bb={{1,h,h^2/2},{0,1,h},{0,0,1}}bb=b.aP(bb,3)return{a={{au*h^2/2+aU*h+a},{au*h+aU},{au},{ay*h^2/2+aX*h+l},{ay*h+aX},{ay},{aA*h^2/2+aJ*h+p},{aA*h+aJ},{aA}},H=b.bp(b.ct(b.F(b.F(bb,t.H),b.x(bb)),db),bW),ac=t.ac,l=t.l,p=t.p,T=t.T,aI=t.aI,aC=t.aC,ar=t.ar}end,aq=function(Q,L)local ax,at,ci,p,l,an,bG,a,H,X,av,ac,aq,r
local e,d,f=I.aT(Q.a[1][1],Q.a[4][1],Q.a[7][1],aa,ab,Z,m,o,n)X,av=aB(e^2+d^2+f^2),aB(e^2+d^2)ax={{e/X,d/X,f/X},{d/av^2,-e/av^2,0},{-e*f/(X^2*av),-d*f/(X^2*av),av/X^2}}ax=b.F(ax,b.x(I.an(m,o,n)))at={}for _=1,3 do
at[_]={ax[_][1],0,0,ax[_][2],0,0,ax[_][3],0,0}end
ci=b.x({{X,bP(e,d),cl(f/X)}})p=b.x({{L.j,L.A,L.w}})l=b.sub(p,ci)an=b.aP({{(M*.002)^2/60}},3)an[1][1]=(L.j*.02)^2/60
bG=b.F(b.F(Q.H,b.x(at)),b.cy(b.bp(b.F(b.F(at,Q.H),b.x(at)),an)))a=b.bp(Q.a,b.F(bG,l))H=b.F(b.sub(E,b.F(bG,at)),Q.H)ac=Q.ac+1
aq={a=a,H=H,ac=ac,l=l,p=p,T=Q.T,aI=as,aC=Q.aC,ar=Q.ar}r=aK.r(aq,cH,0)aq.s={a=r.a[1][1],l=r.a[4][1],p=r.a[7][1],aU=r.a[2][1],aX=r.a[5][1],aJ=r.a[8][1],au=r.a[3][1],ay=r.a[6][1],aA=r.a[9][1]}return aq
end}function cr(j,A,w,bU)if not bU then
w=w*M
A=A*M
end
a=j*v(w)*u(A)l=j*v(w)*v(A)p=j*u(w)return a,l,p
end
function cW(a,l,p,bU)bO=aB(a^2+l^2+p^2)A=bP(a,l)w=cl(p/bO)if bU then
return bO,A,w
else
return bO,A/M,w/M
end
end
function cM(cz,aY,aV)return aB(b.F(b.F(b.x(b.sub(cz,aY)),b.cy(aV)),b.sub(cz,aY))[1][1])end
function aR(C,B,dl,aD,cQ,cN)return aB((C-aD)^2+(B-cQ)^2+(dl-cN)^2)end
function cA(a,min,max)if a>=max then
a=max
elseif a<=min then
a=min
end
return a
end
function d_(S,bt,bH)cY=(bz-aL)*S+aL
ck=bZ(al(bt)/al(bH))/(bz-aL)i=bZ(al(bt))-bz*ck
aG=bP(O.exp(ck*cY+i))return(aG-aL)/(bz-aL),aG
end
function bV(a)if a>=10 then
a=cB("%.0f",ae(a+.5))else
a=cB("%.1f",ae(a*10+.5)/10)end
return a
end
function dp(H,E,cp,dj,s,cx,dh,min,max)ag=dj-s
bC=cx+ag
cc=ag-dh
bo=H*ag+E*bC+cp*cc
if bo>max or bo<min then
bC=cx
bo=H*ag+E*bC+cp*cc
end
return cA(bo,min,max),bC,ag
end
S=0
W={}aw={}for _=1,9 do
aQ(aw,0)end
bM=ad
co=ad
R=0
bk=bn
ai,aW,aE=0,0,0
function onTick()dc=af("Vehicle radius [m]")dd=af("Radar fov")cb=af("Distance Units")df=af("Speed Units")aS=K(28)c_=K(29)cP=aO(9)aM=aO(10)aF=aO(11)cG=aO(12)if cG then
bk=0
end
bt=af("Cam min fov [rad]")/2
bH=af("Cam max fov [rad]")/2
cw=af("Zoom speed gain")if cP then
if c_==-1 and S>0 then
S=S-.01*cw
elseif c_==1 and S<1 then
S=S+.01*cw
end
else
S=0
end
dg,aG=d_(S,bt,bH)bm,ba,bA,bB,by,bs=K(22),K(23),K(24),K(25),K(26),K(27)aQ(W,{bm,ba,bA,bB,by,bs})aQ(aw,K(30))while#W>7
do
bX(W,1)end
while#aw>9
do
bX(aw,1)end
aa=W[1][1]ab=W[1][2]Z=W[1][3]m=W[1][4]o=W[1][5]n=W[1][6]cv=aw[7]*M
cX=cA(aw[7],-.125,.125)*M
G={}for _=1,7 do
j=K(_*3-2)A=K(_*3-1)*M
w=K(_*3-0)*M
e,d,f=cr(j,A,w,as)if aO(_)and j>=dc then
aQ(G,{j=j,A=A,w=w,e=e,d=d,f=f})end
end
for _=1,#G do
g=G[_]if g==aN then
break
end
di=(3*.02/5)*g.j+dn
Y={g}c=_+1
while c<=#G do
N=G[c]if aR(g.e,g.d,g.f,N.e,N.d,N.f)<di then
aQ(Y,N)bX(G,c)else
c=c+1
end
end
bc,be,bu=0,0,0
for cs,i in V(Y)do
bc=bc+i.e
be=be+i.d
bu=bu+i.f
end
j,A,w=cW(bc/#Y,be/#Y,bu/#Y,as)G[_]={j=j,A=A,w=w,e=bc/#Y,d=be/#Y,f=bu/#Y}end
dq={bD.unpack(G)}for D,z in V(k)do
k[D].aI=ad
k[D].T=k[D].T+1
cV=100*aR(M*z.l[1][1]/z.p[1][1]/10,z.l[2][1],z.l[3][1],0,0,0)cR,k[D].ar,k[D].aC=dp(0,.5,0,cJ,cV,z.ar,z.aC,-2.5,3)bY=10^-(10+cR)aY,aV,r={},{},aK.r(z,h,bY)for _=1,3 do
aY[_],aV[_]={r.a[3*_-2][1]},{}for c=1,3 do
aV[_][c]=r.H[3*_-2][3*c-2]end
end
ap,aZ=bn,0
for cO,b_ in V(G)do
ak,aj,ah=I.bd(b_.e,b_.d,b_.f,aa,ab,Z,m,o,n)a=b.x({{ak,aj,ah}})cq=cM(a,aY,aV)if cq<ap then
ap=cq
aZ=cO
end
end
if G[aZ]~=aN then
ag=(cF*h*h/2+cL*h+(3*.02/5)*G[aZ].j)*3+cE
if ap<ag then
k[D]=aK.aq(r,G[aZ])G[aZ]=aN
end
end
end
for cs,b_ in V(G)do
bl,br=1,as
while br do
br=ad
for dm,cs in V(k)do
br=dm==bl
if br then
bl=bl+1
break
end
end
end
k[bl]=aK.de(b_)end
for D,z in V(k)do
if not z.aI then
k[D]=aN
end
end
bN,ap,bR=0,bn,0
for D,z in V(k)do
bR=bR+1
e,d,f=I.aT(z.a[1][1],z.a[4][1],z.a[7][1],aa,ab,Z,m,o,n)e,d,f=I.aT(e,d,f,0,0,0,-cv,0,0)j=aB(e^2+f^2)/d
if j<ap then
bN=D
ap=j
end
end
am=(aF and aS~=0 and aS~=4000 or(ai~=0 and aM))or(not aF and bR>0)if bk<=cU then
bk=bk+1
R=bN
bM=ad
end
bv,bg,bj,bK,bT,bE,ch,cD,cj=0,0,0,0,0,0,0,0,0
if aF then
if aS~=0 and aS~=4000 and(not aM or not bM or ai==0)then
cI,dk,cK=I.bd(bQ.e,bQ.d,bQ.f,bm,ba,bA,bB,by,bs)e,d,f=cr(aS,0,cX,as)ai,aW,aE=I.bd(e,d,f,cI,cK,dk,bB,by,bs)end
bv,bg,bj=ai,aW,aE
R=0
if not aM then
ai,aW,aE=0,0,0
end
elseif am then
if not aM or not co then
R=bN
end
if k[R]~=aN then
if k[R].ac>da then
s=k[R].s
bv,bg,bj,bK,bT,bE,ch,cD,cj=s.a,s.l,s.p,s.aU,s.aX,s.aJ,s.au,s.ay,s.aA
else
am=ad
end
else
am=ad
end
ai,aW,aE=0,0,0
else
R=0
ai,aW,aE=0,0,0
end
bM=aF
co=am and aM and not aF
cf=0
if am then
cf=1
end
cS(1,am)q(1,bv)q(2,bg)q(3,bj)q(4,bK)q(5,bT)q(6,bE)q(7,ch)q(8,cD)q(9,cj)q(10,cf)q(11,aG)q(12,dg)for _=13,32 do
q(_,0)end
for _=4,8 do
ca,U=0,0
for D,z in V(k)do
if z.T>ca then
ca=z.T
U=D
end
end
if U~=0 then
q(_*4-3,k[U].s.a)q(_*4-2,k[U].s.l)q(_*4-1,k[U].s.p)if U==R then
q(_*4,U+2*10^3)else
q(_*4,U)end
k[U].T=0
end
end
end
function onDraw()cn=ao.getWidth()aH=ao.getHeight()bJ=2*aG
ao.setColor(0,255,0)if am then
az(1,1,"LOCK ON")az(1,7,"ID="..R)az(1,13,"D="..bV(cb*aR(bv,bg,bj,bm,bA,ba)))az(1,19,"V="..bV(df*60*aR(bK,bT,bE,0,0,0)))end
for D,cT in V(k)do
bS=aK.r(cT,5,0)e,d,f=I.aT(bS.a[1][1],bS.a[4][1],bS.a[7][1],bm,ba,bA,bB,by,bs)e,d,f=I.aT(e,d,f,0,0,0,-cv,0,0)C,B,cZ=ae(cn/2+e*aH/d/2/al(bJ/2)),ae(aH/2-f*aH/d/2/al(bJ/2)),d>0
if cZ then
cu(C-4,B-4,8,8)if R==D then
bw(C-4,B,C,B+4)bw(C,B+4,C+4,B)bw(C+4,B,C,B-4)bw(C,B-4,C-4,B)end
ce=tostring(D)az(C+1-2.5*#ce,B-10,ce)j=bV(aR(e,d,f,0,0,0)*cb)az(C+1-2.5*#j,B+6,j)end
end
aD=ae(aH*al(M*dd/2)/al(bJ/2))C=ae(cn/2-aD/2)B=ae(aH/2-aD/2)cu(C,B,aD,aD)end
