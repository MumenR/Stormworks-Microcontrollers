
J=360
bI=true
aB=false
bS=property
c_=output
bP=input
A=math
ag=A.abs
bx=A.sqrt
u=A.atan
cd=A.exp
a=A.sin
b=A.cos
ak=A.pi
i=bP.getNumber
av=bP.getBool
L=c_.setNumber
cV=c_.setBool
o=bS.getNumber
cO=bS.getBool
O=ak*2
t=0
bb=0
m=30/3600
bT=600/3600
h=0
dl=0
dq=7.45
aj=8
az=0
at=20
bk=10000
cI=5
aI={{600,.0005,2400,.105},{700,.001,2400,.11},{800,.002,2400,.12},{900,.005,600,.125},{1000,.01,300,.13},{1000,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}function aT(aZ,bc,bp,p,q,r,c,f,d)local cz,cy,ci
cz=b(d)*b(f)*aZ+(b(d)*a(f)*a(c)-a(d)*b(c))*bp+(b(d)*a(f)*b(c)+a(d)*a(c))*bc
cy=a(d)*b(f)*aZ+(a(d)*a(f)*a(c)+b(d)*b(c))*bp+(a(d)*a(f)*b(c)-b(d)*a(c))*bc
ci=-a(f)*aZ+b(f)*a(c)*bp+b(f)*b(c)*bc
return cz+p,ci+r,cy+q
end
function aV(bd,bi,ba,p,q,r,c,f,d)local l,K,H,N,M,F,m,E,Z,U,w,aC,e,g,_,ao
bd=bd-p
bi=bi-r
ba=ba-q
l=b(d)*b(f)K=b(d)*a(f)*a(c)-a(d)*b(c)H=b(d)*a(f)*b(c)+a(d)*a(c)N=bd
M=a(d)*b(f)F=a(d)*a(f)*a(c)+b(d)*b(c)m=a(d)*a(f)*b(c)-b(d)*a(c)E=ba
Z=-a(f)U=b(f)*a(c)w=b(f)*b(c)aC=bi
ao=((l*F-K*M)*w+(H*M-l*m)*U+(K*m-H*F)*Z)e=0
_=0
g=0
if ao~=0 then
e=((K*m-H*F)*aC+(N*F-K*E)*w+(H*E-N*m)*U)/ao
_=-((l*m-H*M)*aC+(N*M-l*E)*w+(H*E-N*m)*Z)/ao
g=((l*F-K*M)*aC+(N*M-l*E)*U+(K*E-N*F)*Z)/ao
end
return e,g,_
end
function z(t,l,k)return((t-l/C)*(1-cd(-C*k))+l*k)/C
end
function bR(t,l,k)return(t-l/C)*cd(-C*k)+l/C
end
function ce(t,l)return A.log(1-C*t/l)/C
end
function aq(bD,bZ,h,t,l,ac,reverse)local _
for Z=1,20 do
_=z(t,l,h)if _*reverse>ac*reverse then
bZ=h
h=(h+bD)/2
else
bD=h
h=(h+bZ)/2
end
end
return h,_
end
function dd(aP,aY,G,P,c,f,d)local cv,cM,e,_,g,cB,bX,be,ar,an
cv=aP*a(aY*O)-G
cM=aP*b(aY*O)-P
e,_,g=aT(cv,cM,0,0,0,0,c,f,d)cB,bX,be=aT(0,0,1,0,0,0,c,f,d)aG=e-(cB*g)/be
aO=_-(bX*g)/be
ar=u(aG,aO)an=bh(aG,aO)return an,ar
end
function bh(e,_)return bx(e^2+_^2)end
function cA(e,min,max)if e>=max then
e=max
elseif e<=min then
e=min
end
return e
end
function cw(e,_,g,cC,cl,bL,cK,Y,S,k)return cK*k^2/2+cC*k+e,Y*k^2/2+cl*k+_,S*k^2/2+bL*k+g,cK*k+cC,Y*k+cl,S*k+bL
end
cf=0
ch=0
bO=0
bW=0
function bQ(aj,az,at,db,cW,ca,di,min,max)local ab,bl,n
ab=db-cW
aL=ca+ab
bl=ab-di
n=aj*ab+az*aL+at*bl
if n>max or n<min then
aL=ca
n=aj*ab+az*aL+at*bl
end
return cA(n,min,max),aL,ab
end
function D(e)return(e+.5)%1-.5
end
function cL(n,cp,min,max)if cp>=max then
if n>0 then
n=0
end
n=n-.01
elseif cp<=min then
if n<0 then
n=0
end
n=n+.01
end
return n
end
aQ=.1
function cR(e,_,g,cm,bH,cn,h)local cE,ck,bU,aN,k
k=0
while k<=h do
cE,ck,bU=_*cn-g*bH,g*cm-e*cn,e*bH-_*cm
e,_,g=e+cE*aQ,_+ck*aQ,g+bU*aQ
aN=bx(e^2+_^2+g^2)e,_,g=e/aN,_/aN,g/aN
k=k+aQ
end
return e,_,g
end
function dc(p,q,r,c,f,d,G,aE,P,bj,bt,bC,aW,ac,aH,ad,Q,ae)local bq,br,bB,aJ,aU,aD,aR,bE,cr,cg,cj,cq,bM
aU,aD,aR=aV(aW,ac,aH,p,q,r,c,f,d)bE,cr,cg=aV(ad,Q,ae,0,0,0,c,f,d)cj,cq,bM=aV(bj,bC,bt,0,0,0,c,f,d)bq,br,bB=bE-G,cr-P,cg-aE
aJ=aU^2+aD^2+aR^2
return-(aD*bB-aR*br)/aJ-cj,-(aR*bq-aU*bB)/aJ-cq,-(aU*br-aD*bq)/aJ-bM
end
function aF(e,_,g,dj)local x,y
x=u(g,bx(e^2+_^2))y=u(e,_)if dj then
return x,y
else
return x/(O),y/(O)end
end
function onTick()aW=i(3)ac=i(4)aH=i(5)ad=i(6)Q=i(7)ae=i(8)bN=i(9)cH=i(10)bK=i(11)p=i(12)q=i(13)r=i(14)c=i(15)f=i(16)d=i(17)G=i(18)/60
aE=i(19)/60
P=i(20)/60
bj=i(21)*O/60
bt=i(22)*O/60
bC=i(23)*O/60
aP=i(24)/60
aY=i(25)af=i(26)B=i(27)as=o("Weapon Type")+1
bo=o("standby yaw position (degree)")/J
bg=o("min pitch (degree)")/J
bz=o("max pitch (degree)")/J
cs=cO("Pitch Swivel Mode")bA=o("min yaw (degree)")/J
bw=o("max yaw (degree)")/J
bu=cO("Yaw Swivel Mode")B=B-bo
aK=o("Pivot rotation speed gain")bf=o("Pitch gear ratio (1 : ?)")/o("Types of Pitch PIVOT")bs=o("Yaw gear ratio (1 : ?)")/o("Types of Yaw PIVOT")dp=o("Body phy. offset x (m)")cU=o("Body phy. offset y (m)")cY=o("Body phy. offset z (m)")cG=av(1)bY=av(3)by=av(9)dg=av(10)cx=av(11)ax=aB
t,C,v,bb=aI[as][1]/60,aI[as][2],aI[as][3],aI[as][4]p,r,q=aT(dp,cU,cY,p,q,r,c,f,d)T,R,W=aW-p,ac-r,aH-q
if cG and by then
T,R,W,ad,Q,ae=cw(T,R,W,ad,Q,ae,bN,cH,bK,dl)cu,bJ,cQ=aT(G,P,aE,0,0,0,c,f,d)cN=bh(cu,bJ)co=u(cu,bJ)an,ar=dd(aP,aY,G,P,c,f,d)ay,aw,V=T,R,W
cD=0
for Z=1,15 do
bG=bh(ay,aw)s=u(ay,aw)j=u(V,bG)for w=1,2 do
for U=1,60 do
dh=U
I=bG*b(u(ay,aw)-s)aG=an*a(ar-s)aO=an*b(ar-s)cS,ap=-aG*bb/60,-aO*bb/60
cT=cN*a(co-s)ah=t*b(j)+cN*b(co-s)X=t*a(j)+cQ
if as==8 then
Y=bT*b(j)+ap
S=bT*a(j)-m
aA=z(ah,Y,60)bm=z(X,S,60)ct=bR(ah,Y,60)bn=bR(X,S,60)if w<2 then
if aA>I then
h,_=aq(0,v*2,v,ah,Y,I,1)g=z(X,S,h)else
am,_=aq(0,v*2,v,ct,ap,I-aA,1)_=_+aA
g=z(bn,-m,am)+bm
h=60+am
end
else
b_=ce(bn,-m)am,g=aq(b_,v*2,v,bn,-m,V-bm,-1)_=z(ct,ap,am)+aA
g=g+bm
h=60+am
end
else
if w<2 then
h,_=aq(0,v*2,v,ah,ap,I,1)g=z(X,-m,h)else
b_=ce(X,-m)h,g=aq(b_,v*2,v,X,-m,V,-1)_=z(ah,ap,h)end
end
e=z(cT,cS,h)if(ag(V-g)<.1 and w<2)or(ag(I-_)<.1 and w>1)then
break
end
s=u(ay,aw)-u(e,_)if w>1 then
if _<I then
cF=j
j=(j+bv)/2
else
bv=j
j=(j+cF)/2
end
else
j=j+u(V,I)-u(g,_)end
end
ax=h<v and dh~=60
if dg and w<2 and ax then
bv=cA(j,ak/9,ak/2)cF=ak/2
j=ak/4+bv/2
else
break
end
end
ay,aw,V=cw(T,R,W,ad,Q,ae,bN,cH,bK,h)if ag(cD-h)<.01 then
break
end
cD=h
end
if not ax then
j,s=aF(T,R,W,bI)end
elseif by and bY then
j,s=aF(T,R,W,bI)else
s,j=0,0
ax=aB
ds,dr=0,0
end
if by and(cG or bY)then
dm,cX,cZ=p+bk*a(s),r+bk*b(s),q+bk*A.tan(j)ai,au,al=aV(dm,cX,cZ,p,q,r,c,f,d)aX,aS=aF(ai,au,al,aB)dk,de,da=dc(p,q,r,c,f,d,G,aE,P,bj,bt,bC,aW,ac,aH,ad,Q,ae)ai,au,al=cR(ai,au,al,dk,de,da,dq)aM,aa=aF(ai,au,al,aB)aa=D(aa-bo)if cx then
aM=0
end
else
aM,aa=0,0
ai,au,al=0,1,0
aX,aS=0,0
h=0
end
df=D(B)>bA and D(B)<bw and af>bg and af<bz
bF=aX>bg and aX<bz
cJ=aS>bA and aS<bw
cc=ag(D(aX-af))*J
cb=ag(D(aS-bo-B))*J
dn=cc<cI and cb<cI
cP=ax and dn and df and bF and cJ and not cx
if not bF and cs then
aM=0
end
if not cJ and bu then
aa=0
end
d_=aM-af
if bu then
bV=aa-B
else
bV=D(aa-B)end
x,ch,cf=bQ(aj,az,at,0,-d_*bf,ch,cf,-bf*aK,bf*aK)y,bW,bO=bQ(aj,az,at,0,-bV*bs,bW,bO,-bs*aK,bs*aK)if cs then
x=cL(x,D(af),bg,bz)end
if bu then
y=cL(y,D(B),bA,bw)end
if x~=x then
x=0
end
if y~=y then
y=0
end
L(1,x)L(2,y)cV(1,cP)L(3,cc)L(4,cb)L(30,h)L(31,j)L(32,s)end
