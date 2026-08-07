
P=360
aV=false
aU=debug
cp=property
bR=output
bH=input
A=math
aj=A.abs
bo=A.sqrt
u=A.atan
cC=A.exp
a=A.sin
b=A.cos
ak=A.pi
i=bH.getNumber
aW=bH.getBool
B=bR.setNumber
db=bR.setBool
o=cp.getNumber
cc=cp.getBool
F=ak*2
s=0
br=0
n=30/3600
c_=600/3600
h=0
dd=0
dp=7.45
al=8
ad=0
at=20
bj=10000
cG=2
aC={{600,.0005,2400,.105},{700,.001,2400,.11},{800,.002,2400,.12},{900,.005,600,.125},{1000,.01,300,.13},{1000,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}function aE(bd,bc,ba,q,r,p,c,f,d)local cv,bS,cj
cv=b(d)*b(f)*bd+(b(d)*a(f)*a(c)-a(d)*b(c))*ba+(b(d)*a(f)*b(c)+a(d)*a(c))*bc
bS=a(d)*b(f)*bd+(a(d)*a(f)*a(c)+b(d)*b(c))*ba+(a(d)*a(f)*b(c)-b(d)*a(c))*bc
cj=-a(f)*bd+b(f)*a(c)*ba+b(f)*b(c)*bc
return cv+q,cj+p,bS+r
end
function aX(bf,bA,bn,q,r,p,c,f,d)local k,K,G,O,H,J,n,I,T,U,v,aT,e,g,_,av
bf=bf-q
bA=bA-p
bn=bn-r
k=b(d)*b(f)K=b(d)*a(f)*a(c)-a(d)*b(c)G=b(d)*a(f)*b(c)+a(d)*a(c)O=bf
H=a(d)*b(f)J=a(d)*a(f)*a(c)+b(d)*b(c)n=a(d)*a(f)*b(c)-b(d)*a(c)I=bn
T=-a(f)U=b(f)*a(c)v=b(f)*b(c)aT=bA
av=((k*J-K*H)*v+(G*H-k*n)*U+(K*n-G*J)*T)e=0
_=0
g=0
if av~=0 then
e=((K*n-G*J)*aT+(O*J-K*I)*v+(G*I-O*n)*U)/av
_=-((k*n-G*H)*aT+(O*H-k*I)*v+(G*I-O*n)*T)/av
g=((k*J-K*H)*aT+(O*H-k*I)*U+(K*I-O*J)*T)/av
end
return e,g,_
end
function z(s,k,j)aU=aU+1
return((s-k/C)*(1-cC(-C*j))+k*j)/C
end
function ca(s,k,j)return(s-k/C)*cC(-C*j)+k/C
end
function bD(s,k)return A.log(1-C*s/k)/C
end
function ar(cn,bC,h,s,k,S,reverse)local _
for T=1,20 do
_=z(s,k,h)if _*reverse>S*reverse then
bC=h
h=(h+cn)/2
else
cn=h
h=(h+bC)/2
end
end
return h,_
end
function cR(aK,ax,N,M,c,f,d)local cd,cb,e,_,g,ci,bL,bp,au,aq
cd=aK*a(ax*F)-N
cb=aK*b(ax*F)-M
e,_,g=aE(cd,cb,0,0,0,0,c,f,d)ci,bL,bp=aE(0,0,1,0,0,0,c,f,d)aG=e-(ci*g)/bp
aw=_-(bL*g)/bp
au=u(aG,aw)aq=by(aG,aw)return aq,au
end
function by(e,_)return bo(e^2+_^2)end
function co(e,min,max)if e>=max then
e=max
elseif e<=min then
e=min
end
return e
end
function bK(e,_,g,cE,cf,bF,cK,Z,Q,j)return cK*j^2/2+cE*j+e,Z*j^2/2+cf*j+_,Q*j^2/2+bF*j+g,cK*j+cE,Z*j+cf,Q*j+bF
end
cm=0
bY=0
ch=0
bX=0
function cI(al,ad,at,de,cS,cq,cU,min,max)local Y,be,m
Y=de-cS
aJ=cq+Y
be=Y-cU
m=al*Y+ad*aJ+at*be
if m>max or m<min then
aJ=cq
m=al*Y+ad*aJ+at*be
end
return co(m,min,max),aJ,Y
end
function D(e)return(e+.5)%1-.5
end
function cr(m,bE,min,max)if bE>=max then
if m>0 then
m=0
end
m=m-.01
elseif bE<=min then
if m<0 then
m=0
end
m=m+.01
end
return m
end
aQ=.1
function dk(e,_,g,bG,cA,cu,h)local ce,bJ,bW,aM,j
j=0
while j<=h do
ce,bJ,bW=_*cu-g*cA,g*bG-e*cu,e*cA-_*bG
e,_,g=e+ce*aQ,_+bJ*aQ,g+bW*aQ
aM=bo(e^2+_^2+g^2)e,_,g=e/aM,_/aM,g/aM
j=j+aQ
end
return e,_,g
end
function cQ(q,r,p,c,f,d,N,aS,M,bt,bk,aZ,aA,S,aP,W,ab,X)local bh,b_,bi,aL,aI,aY,aD,bU,bN,ct,bI,cB,bM
aI,aY,aD=aX(aA,S,aP,q,r,p,c,f,d)bU,bN,ct=aX(W,ab,X,0,0,0,c,f,d)bI,cB,bM=aX(bt,aZ,bk,0,0,0,c,f,d)bh,b_,bi=bU-N,bN-M,ct-aS
aL=aI^2+aY^2+aD^2
return-(aY*bi-aD*b_)/aL-bI,-(aD*bh-aI*bi)/aL-cB,-(aI*b_-aY*bh)/aL-bM
end
function cL(e,_,g,cN)local w,x
w=u(g,bo(e^2+_^2))x=u(e,_)if cN then
return w,x
else
return w/(F),x/(F)end
end
function onTick()aU=0
aA=i(1)S=i(2)aP=i(3)W=i(4)ab=i(5)X=i(6)cx=i(7)bP=i(8)bO=i(9)q=i(10)r=i(11)p=i(12)c=i(13)f=i(14)d=i(15)N=i(16)/60
aS=i(17)/60
M=i(18)/60
bt=i(19)*F/60
bk=i(20)*F/60
aZ=i(21)*F/60
aK=i(22)/60
ax=i(23)ae=i(24)E=i(25)ap=o("Weapon Type")+1
bs=o("standby yaw position (degree)")/P
bv=o("min pitch (degree)")/P
bz=o("max pitch (degree)")/P
cy=cc("Pitch Swivel Mode")bq=o("min yaw (degree)")/P
bm=o("max yaw (degree)")/P
bl=cc("Yaw Swivel Mode")E=E-bs
aB=o("Pivot rotation speed gain")bb=o("Pitch gear ratio (1 : ?)")/o("Types of Pitch PIVOT")bx=o("Yaw gear ratio (1 : ?)")/o("Types of Yaw PIVOT")df=o("offset x (m)")di=o("offset y (m)")cX=o("offset z (m)")dj=aW(1)da=aW(2)cZ=aW(4)cD=aW(5)ac=aV
s,C,t,br=aC[ap][1]/60,aC[ap][2],aC[ap][3],aC[ap][4]q,p,r=aE(df,di,cX,q,r,p,c,f,d)aF,aO,aH=aA-q,S-p,aP-r
if dj and da then
aF,aO,aH,W,ab,X=bK(aF,aO,aH,W,ab,X,cx,bP,bO,dd)cH,bT,dc=aE(N,M,aS,0,0,0,c,f,d)bQ=by(cH,bT)ck=u(cH,bT)aq,au=cR(aK,ax,N,M,c,f,d)ah,an,V=aF,aO,aH
bZ=0
for T=1,15 do
bV=by(ah,an)y=u(ah,an)l=u(V,bV)for v=1,2 do
for U=1,60 do
cO=U
L=bV*b(u(ah,an)-y)aG=aq*a(au-y)aw=aq*b(au-y)cP,ao=-aG*br/60,-aw*br/60
cT=bQ*a(ck-y)am=s*b(l)+bQ*b(ck-y)aa=s*a(l)+dc
if ap==8 then
Z=c_*b(l)+ao
Q=c_*a(l)-n
ay=z(am,Z,60)bg=z(aa,Q,60)cz=ca(am,Z,60)bw=ca(aa,Q,60)if v<2 then
if ay>L then
h,_=ar(0,t*2,t,am,Z,L,1)g=z(aa,Q,h)else
ai,_=ar(0,t*2,t,cz,ao,L-ay,1)_=_+ay
g=z(bw,-n,ai)+bg
h=60+ai
end
else
bB=bD(bw,-n)ai,g=ar(bB,t*2,t,bw,-n,V-bg,-1)_=z(cz,ao,ai)+ay
g=g+bg
h=60+ai
end
else
if v<2 then
h,_=ar(0,t*2,t,am,ao,L,1)g=z(aa,-n,h)else
bB=bD(aa,-n)h,g=ar(bB,t*2,t,aa,-n,V,-1)_=z(am,ao,h)end
end
e=z(cT,cP,h)if(aj(V-g)<.1 and v<2)or(aj(L-_)<.1 and v>1)then
break
end
y=u(ah,an)-u(e,_)if v>1 then
if _<L then
cl=l
l=(l+bu)/2
else
bu=l
l=(l+cl)/2
end
else
l=l+u(V,L)-u(g,_)end
end
ac=h<t and cO~=60
if cZ and v<2 and ac then
bu=co(l,ak/9,ak/2)cl=ak/2
l=ak/4+bu/2
else
break
end
end
ah,an,V=bK(aF,aO,aH,W,ab,X,cx,bP,bO,h)if aj(bZ-h)<.01 then
break
end
bZ=h
end
else
y,l=0,0
ac=aV
dq,dr=0,0
end
if ac then
dh,cY,dn=q+bj*a(y),p+bj*b(y),r+bj*A.tan(l)as,af,ag=aX(dh,cY,dn,q,r,p,c,f,d)az,aR=cL(as,af,ag,aV)dl,cW,dg=cQ(q,r,p,c,f,d,N,aS,M,bt,bk,aZ,aA,S,aP,W,ab,X)as,af,ag=dk(as,af,ag,dl,cW,dg,dp)aN,R=cL(as,af,ag,aV)R=D(R-bs)if cD then
aN=0
end
else
aN,R=0,0
as,af,ag=0,1,0
az,aR=0,0
h=0
end
cV=D(E)>bq and D(E)<bm and ae>bv and ae<bz
cw=az>bv and az<bz
cJ=aR>bq and aR<bm
cs=aj(D(az-ae))*P
cF=aj(D(aR-bs-E))*P
dm=cs<cG and cF<cG
d_=ac and dm and cV and cw and cJ and not cD
if not cw and cy then
aN=0
end
if not cJ and bl then
R=0
end
cM=aN-ae
if bl then
cg=R-E
else
cg=D(R-E)end
w,bY,cm=cI(al,ad,at,0,-cM*bb,bY,cm,-bb*aB,bb*aB)x,bX,ch=cI(al,ad,at,0,-cg*bx,bX,ch,-bx*aB,bx*aB)if cy then
w=cr(w,D(ae),bv,bz)end
if bl then
x=cr(x,D(E),bq,bm)end
if w~=w then
w=0
end
if x~=x then
x=0
end
B(1,w)B(2,x)db(1,d_)B(3,cs)B(4,cF)B(30,h)B(31,l)B(32,y)B(20,aU)end
