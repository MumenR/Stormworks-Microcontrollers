fn="x (m)"
fm="z (m)"
fl="y (m)"

w=360
bp=.1
bw=1000
bq=600
au=false
dG=property
dr=output
dB=input
B=math
cP=B.acos
bK=B.exp
cD=B.abs
r=B.atan
cb=table.unpack
j=B.cos
n=B.sin
aS=B.sqrt
c=dB.getNumber
bX=dB.getBool
S=dr.setNumber
ec=dr.setBool
f=dG.getNumber
cU=dG.getBool
C=B.pi*2
y=30/3600
dA=bq/3600
fh=60
i=0
eX=0
ed=8
dt=9.8
dT=7.5
cY=0
eH=0
ev=.05
eE=0
cx=2000
cz=60*(cx/bw)ea=aS(240*cx)eW=B.floor(3600/cz)dO=8
dK=bp
dQ=bp
ce=10000
dH=2
bF={{bq,.0005,2400,.105},{700,.001,2400,.11},{800,.002,2400,.12},{900,.005,bq,.125},{bw,.01,300,.13},{bw,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}do
function df(dF,du,dn)return aV({0,n(-dn/2),0,j(-dn/2)},aV({0,0,n(-du/2),j(-du/2)},{n(-dF/2),0,0,j(-dF/2)}))end
function aV(g,R)local q,a,k,p=cb(g)local _,b,e,bz=cb(R)return{p*_-k*b+a*e+q*bz,k*_+p*b-q*e+a*bz,-a*_+q*b+p*e+k*bz,-q*_-a*b-k*e+p*bz}end
function aC(U,ae,I,aP,aK,aU,g)_,b,e=cb(aV(g,aV({U,ae,I,0},{-g[1],-g[2],-g[3],g[4]})))return _+aP,b+aU,e+aK
end
function ab(ac,ah,am,aP,aK,aU,g)return cb(aV({-g[1],-g[2],-g[3],g[4]},aV({ac-aP,ah-aU,am-aK,0},g)))end
function aF(eY,a,l,q,u,dY,cL)local aY,o,k,ad,W,aj,p,Z,aR,R,g,bV,co
aY=u>0 and u or-u
k,ad,W=q,u,aY
aj=a-q
p=aj
co=au
for fc=1,dY do
o=l>0 and l or-l
if l*u<0 then co=true end
if o<cL then
return a,o,fc
end
if u*l>0 then
q,u,aY=k,ad,W
p=a-k
aj=p
end
if aY<o then
q,a,k=a,k,a
u,l,ad=l,ad,l
aY,o,W=o,W,o
end
if co then
Z=(q-a)/2
aR=l/ad
if W<o then
p,aj=Z,Z
else
if q==k then
R=2*Z*aR
g=1-aR
else
g=ad/u
bV=l/u
R=aR*(2*Z*g*(g-bV)-(a-k)*(bV-1))g=(g-1)*(bV-1)*(aR-1)end
aR,aj=aj,p
cK=3*Z*g
if 2*(R>0 and R or-R)<(cK>0 and cK or-cK)then
p=-R/g
else
p,aj=Z,Z
end
end
k,ad,W=a,l,o
a=a+p
else
bQ=l-u
if o>W*1.1 then
cM=(k+a)/2
elseif((bQ>0 and bQ or-bQ)<cL*bp or a==k)and o>cL then
cM=a+.001
else
cM=a-l*(a-q)/bQ
end
ad,k,W=l,a,o
a=cM
end
l=eY(a)end
return a,o,dY
end
function eR(bL,bE,cS,ci,aw)local dp,dv,_,b,e,ef,dR,cw,aZ,ao
dp=bL*n(bE*C)-cS
dv=bL*j(bE*C)-ci
_,b,e=aC(dp,dv,0,0,0,0,aw)ef,dR,cw=aC(0,0,1,0,0,0,aw)bA=_-(ef*e)/cw
bG=b-(dR*e)/cw
aZ=r(bA,bG)ao=bM(bA,bG)return ao,aZ
end
function bM(_,b)return aS(_*_+b*b)end
function aA(_,min,max)if _>=max then
_=max
elseif _<=min then
_=min
end
return _
end
function cO(h,_,b,e,ay,ap,v,as,az,Q)return as*h*h/2+ay*h+_,az*h*h/2+ap*h+b,Q*h*h/2+v*h+e,as*h+ay,az*h+ap,Q*h+v
end
dE,dV=0,0
dZ,dN=0,0
dq,el=0,0
dS,dd=0,0
function bJ(aJ,aW,aI,ew,eF,dP,es,min,max)local an,aX,cB,bs
an=ew-eF
aX=cD(an)<1/w and dP+an or 0
cB=an-es
bs=aJ*an+aW*aX+aI*cB
if bs>max or bs<min then
aX=dP
bs=aJ*an+aW*aX+aI*cB
end
return aA(bs,min,max),aX,an
end
function X(_)return(_+.5)%1-.5
end
function bT(aP,aK,aU,aw,cS,fg,ci,fd,et,eJ,L,N,H,G,M,J,bm,bf,bb,dc)local bu,bn,bi,dl,dz,cT,dL,dw,cW,at,aq,ax,cC,cq,cn,cd,aT,cos,sin,bO,dj,da,dM,be,bv,bh
bu,bn,bi=ab(L,N,H,aP,aK,aU,aw)dl,dz,cT=ab(G,M,J,0,0,0,aw)dL,dw,cW=ab(fd,eJ,et,0,0,0,aw)be,bv,bh=ab(bm,bf,bb,aP,aK,aU,aw)cC,cq,cn=dl-cS,dz-ci,cT-fg
cd=bu*bu+bn*bn+bi*bi
at=(bn*cn-bi*cq)/cd-(-dL)aq=(bi*cC-bu*cn)/cd-(-dw)ax=(bu*cq-bn*cC)/cd-(-cW)aT=aS(at*at+aq*aq+ax*ax)cos=j(aT*dc)sin=n(aT*dc)/aT
bO=(at*be+aq*bv+ax*bh)*(1-cos)/aT/aT
dj=cos*be+sin*(aq*bh-ax*bv)+bO*at
da=cos*bv+sin*(ax*be-at*bh)+bO*aq
dM=cos*bh+sin*(at*bv-aq*be)+bO*ax
return cc(dj,da,dM,au)end
function cc(_,b,e,eO)local ch,cg
ch=r(e,aS(_*_+b*b))cg=r(_,b)if eO then
return ch,cg
else
return ch/C,cg/C
end
end
function bN(ac,ah,am,s)local eb,dm=bM(ac,ah),r(ac,ah)-s
return eb*n(dm),eb*j(dm),am
end
function bB(h)local exp,ct,cr,aO,bx
aO=i+h
bx=aO*aO/2
dU=eN*bx+fe*aO+eZ
bD=eG*bx+eK*aO+dJ
cu=eS*bx+ey*aO+ej
exp=bK(-d*h)ct=(bt-bg/d)*(d*h-1+exp)/d/d/h+bg*h/2/d+bW+m
cr=eI*(((44.20-ct/bw)/11.89)^5.256)/60780
y=bK(-ct/60000)/120
as=-bA*cr
az=cJ-bG*cr
Q=c_-y
_,ay=((by-as/d)*(1-exp)+as*h)/d+cH,(by-as/d)*exp+as/d
b,ap=((bZ-az/d)*(1-exp)+az*h)/d+cI,(bZ-az/d)*exp+az/d
e,v=((bt-Q/d)*(1-exp)+Q*h)/d+bW,(bt-Q/d)*exp+Q/d
Y=cx/(v<0 and-v or v)Y=Y>ea and ea or Y
Y=Y<cz and cz or Y
V=aG and(cu-e)or(b-bD)aL=V>0 and(not aG or v<0)return V,aL
end
function cy(aD)eZ,dJ,ej=bN(ak,aB,av,ai)fe,eK,ey=bN(G,M,J,ai)eN,eG,eS=bN(bH,ca,bI,ai)bA=ao*n(aZ-ai)bG=ao*j(aZ-ai)y=bK(-m/60000)/120
_,b,e=fa,eg*j(dh+aD),eg*n(dh+aD)ay,ap,v=dD*n(di-ai),bC*j(aD)+dD*j(di-ai),bC*n(aD)+eQ
local z=60
i=0
cH,cI,bW,by,bZ,bt=_,b,e,ay,ap,v
bg=-y
cJ,c_=0,0
cE=-ce
aL=au
if cF then
cJ=dA*j(aD)c_=dA*n(aD)bg=-y+c_
V,aL=bB(z)if aL then
i,f_,bU=aF(bB,z,V,0,(aG and ej or dJ),10,.01)return aG and(bD-b)or(cu-e)end
cE=V
i=i+z
z=Y
cJ,c_=0,0
cH,cI,bW,by,bZ,bt=_,b,e,ay,ap,v
bg=-y
end
bU=0
for fk=1,eW do
if i>de then
break
end
V,aL=bB(z)if aL then
z,f_,bU=aF(bB,z,V,0,cE,10,.01)i=i+z
break
end
cE=V
i=i+z
z=Y
cH,cI,bW,by,bZ,bt=_,b,e,ay,ap,v
bg=Q
end
return aG and(bD-b)or(cu-e)end
function cR(eP)ai=eP
eT=cy(t)cZ=t+.001
eu=cy(cZ)t,eB,bU=aF(cy,cZ,eu,t,eT,dO,dK)return dU-_
end
end
function onTick()do
L,N,H=c(1),c(2),c(3)G,M,J=c(4),c(5),c(6)bH,ca,bI=c(7),c(8),c(9)D=df(c(10),c(11),c(12))aQ,bl,aM=c(13)/60,c(14)/60,c(15)/60
bS,bR,bP=c(16)*C/60,c(17)*C/60,c(18)*C/60
E,m,F=c(19),c(20),c(21)cp=df(c(22),c(23),c(24))bL=c(25)/60
bE=c(26)aH=" (degree)"
ar=f("Weapon Type")cm=f("Stabilizer")eL=cm>=0
bk=f("standby pitch position"..aH)/w
ck=f("standby yaw position"..aH)/w
bj=f("min pitch"..aH)/w
br=f("max pitch"..aH)/w
cQ=cU("Pitch Swivel Mode")ba=f("min yaw"..aH)/w
bd=f("max yaw"..aH)/w
cA=cU("Yaw Swivel Mode")af=f("Pivot rotation speed gain")db=f("Pitch gear ratio (1 : ?)")/f("Types of Pitch PIVOT")ei=f("Yaw gear ratio (1 : ?)")/f("Types of Yaw PIVOT")ex=f("manual P")eo=f("manual I")en=f("manual D")al="Turret phy. offset "
ep=-f(al..fn)ff=-f(al..fl)eC=-f(al..fm)al="Muzzle offset "
fa=f(al..fn)dy=f(al..fl)ee=f(al..fm)eg=bM(dy,ee)dh=r(ee,dy)cs=bX(1)cl=bX(2)aG=bX(4)dx=bX(5)end
do
bo=au
i=0
aa,ag=bk,ck
b_,bY=bk,ck
aE,bc=bk,ck
s,t=0,0
end
do
ac,ah,am=aC(0,1,0,0,0,0,cp)U,ae,I=ab(ac,ah,am,0,0,0,D)K,O=cc(U,ae,I,au)ac,ah,am=aC(0,0,1,0,0,0,cp)U,ae,I=ab(ac,ah,am,0,0,0,D)if I<0 then
K=X(.5-K)O=X(O+.5)end
end
e_,dI,eQ=aC(aQ,aM,bl,0,0,0,D)if cs and cl and ar~=9 then
bC,d,de,eI=bF[ar][1]/60,bF[ar][2],bF[ar][3],bF[ar][4]cF=ar==8
E,F,m=aC(ep,ff,eC,E,m,F,cp)ak,aB,av=L-E,N-F,H-m
ak,aB,av,G,M,J=cO(eX,ak,aB,av,G,M,J,bH,ca,bI)dD=bM(e_,dI)di=r(e_,dI)ao,aZ=eR(bL,bE,aQ,aM,D)ao=ao/((((44.33-m/bw)/11.89)^5.256)/1013)y=bK(-m/60000)/120
do
i=aS(ak*ak+aB*aB+av*av)/(bC+(cF and bq or 0))em,er,fi=cO(i,ak,aB,av,G,M,J,bH,ca,bI)s=r(em,er)fj,T,cN=bN(ak,aB,av,s)P=bC+(cF and bq/60 or 0)cv=-T*y/P
cf=cP(d*T/aS(cv*cv+P*P))+r(cv,P)function aN(a)return T*(P*n(a)+y/d)/P/j(a)+y*B.log(1-d*T/P/j(a))/(d*d)-cN
end
if not aG then
t=aF(aN,r(cN,T),aN(r(cN,T)),cf,aN(cf),10,(bp/w)*C)else
t=aF(aN,cP(d*T/P)-1e-6,aN(cP(d*T/P)-1e-6),cf,aN(cf),10,(bp/w)*C)end
end
do
ez=cR(s)eq=t>C/4 and-2 or 2
ek=s+(r(dU,bD)-r(_,b))*eq
s,fb,bU=aF(cR,ek,cR(ek),s,ez,dO,dQ)end
bo=i<de and fb<dQ and eB<dK
bm,bf,bb=E+ce*j(t)*n(s),F+ce*j(t)*j(s),m+ce*n(t)U,ae,I=ab(bm,bf,bb,E,m,F,D)aa,ag=cc(U,ae,I,au)dC,d_,dg,eh,ds,dW=cO(i,L,N,H,G,M,J,bH,ca,bI)end
if not bo and cs and cl then
b_,bY=bT(E,m,F,D,aQ,bl,aM,bS,bR,bP,L,N,H,G,M,J,L,N,H,ed)aE,bc=bT(E,m,F,D,aQ,bl,aM,bS,bR,bP,L,N,H,G,M,J,L,N,H,dt)U,ae,I=ab(L,N,H,E,m,F,D)aa,ag=cc(U,ae,I,au)end
do
eV=X(O)>ba and X(O)<bd and K>bj and K<br
eA=aa>bj and aa<br
eD=ag>ba and ag<bd
dk=cD(X(aa-K))*w
cV=cD(X(ag-O))*w
eU=dk<dH and cV<dH
eM=((ar==9 and cl and cs)or bo)and eU and eV and eA and eD and not dx
end
do
if eL then
if bo then
b_,bY=bT(E,m,F,D,aQ,bl,aM,bS,bR,bP,dC,d_,dg,eh,ds,dW,bm,bf,bb,ed)aE,bc=bT(E,m,F,D,aQ,bl,aM,bS,bR,bP,dC,d_,dg,eh,ds,dW,bm,bf,bb,dt)end
if dx then
b_=bk
aE=bk
end
cG=cA and(aA(bY,ba,bd)-O)or X(bY-O)cj=cQ and(aA(b_,bj,br)-K)or b_-K
cX,dV,dE=bJ(dT,cY,cm,0,-cj,dV,dE,-af,af)dX,dN,dZ=bJ(dT,cY,cm,0,-cG,dN,dZ,-af,af)aJ,aW,aI=eH,ev,eE
else
aJ,aW,aI=ex,eo,en
cX,dX=0,0
aE,bc=aa,ag
end
cG=cA and(aA(ag,ba,bd)-O)or X(ag-O)cj=cQ and(aA(aa,bj,br)-K)or aa-K
x,dq,el=bJ(aJ,aW,aI,0,-cj,dq,el,-af,af)A,dS,dd=bJ(aJ,aW,aI,0,-cG,dS,dd,-af,af)x=cX+x
A=dX+A
x=x*db
A=A*ei
if db<0 then
x=cQ and aA(aE,bj,br)*4 or aE*4
end
if ei<0 then
A=cA and aA(bc,ba,bd)*4 or bc*4
end
x=(x~=x)and 0 or x
A=(A~=A)and 0 or A
end
S(1,x)S(2,A)ec(1,eM)ec(2,bo)S(3,dk)S(4,cV)S(5,i/60)S(30,i)S(31,t)S(32,s)end
