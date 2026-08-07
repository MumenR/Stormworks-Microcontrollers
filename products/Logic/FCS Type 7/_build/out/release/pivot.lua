
A=100
aq=false
aV=output
bn=input
at=screen
p=math
bl=p.floor
bk=at.drawText
bj=p.sqrt
a=p.sin
b=p.cos
K=p.pi
_=bn.getNumber
cz=bn.getBool
C=aV.setNumber
ct=aV.setBool
z=property.getNumber
x=K*2
bP=4
cw=7.45
bS=-2.5
ck=30
E,L,H=8,0,20
function ay(aG,aM,aP,O,F,G,c,f,d)local bz,by,bB
bz=b(d)*b(f)*aG+(b(d)*a(f)*a(c)-a(d)*b(c))*aP+(b(d)*a(f)*b(c)+a(d)*a(c))*aM
by=a(d)*b(f)*aG+(a(d)*a(f)*a(c)+b(d)*b(c))*aP+(a(d)*a(f)*b(c)-b(d)*a(c))*aM
bB=-a(f)*aG+b(f)*a(c)*aP+b(f)*b(c)*aM
return bz+O,bB+G,by+F
end
function ar(aJ,aN,aO,O,F,G,c,f,d)local s,t,u,v,r,w,y,j,V,as,ae,U,e,h,g,P
aJ=aJ-O
aN=aN-G
aO=aO-F
s=b(d)*b(f)t=b(d)*a(f)*a(c)-a(d)*b(c)u=b(d)*a(f)*b(c)+a(d)*a(c)v=aJ
r=a(d)*b(f)w=a(d)*a(f)*a(c)+b(d)*b(c)y=a(d)*a(f)*b(c)-b(d)*a(c)j=aO
V=-a(f)as=b(f)*a(c)ae=b(f)*b(c)U=aN
P=((s*w-t*r)*ae+(u*r-s*y)*as+(t*y-u*w)*V)e=0
g=0
h=0
if P~=0 then
e=((t*y-u*w)*U+(v*w-t*j)*ae+(u*j-v*y)*as)/P
g=-((s*y-u*r)*U+(v*r-s*j)*ae+(u*j-v*y)*V)/P
h=((s*w-t*r)*U+(v*r-s*j)*as+(t*j-v*w)*V)/P
end
return e,h,g
end
function be(aC,q,m,aB)local e,g,h
if not aB then
m=m*K*2
q=q*K*2
end
e=aC*b(m)*a(q)g=aC*b(m)*b(q)h=aC*a(m)return e,g,h
end
function aI(e,g,h,aB)local Y,q,m
Y=bj(e^2+g^2+h^2)q=p.atan(e,g)m=p.asin(h/Y)if aB then
return Y,q,m
else
return Y,q/(K*2),m/(K*2)end
end
function br(e)return(e+.5)%1-.5
end
function ah(e,min,max)if e>=max then
e=max
elseif e<=min then
e=min
end
return e
end
ao=.1
function aA(e,g,h,bi,bg,aT,cu)local aS,bA,aZ,ak,i
i=0
while i<=cu do
aS,bA,aZ=g*aT-h*bg,h*bi-e*aT,e*bg-g*bi
e,g,h=e+aS*ao,g+bA*ao,h+aZ*ao
ak=bj(e^2+g^2+h^2)e,g,h=e/ak,g/ak,h/ak
i=i+ao
end
return e,g,h
end
function ci(aa,aj,ap,au,aQ,aw,bW,bK,bV)local ax,aL,aE,X
ax,aL,aE=bW-aa,bK-aj,bV-ap
X=au^2+aQ^2+aw^2
return(aQ*aE-aw*aL)/X,(aw*ax-au*aE)/X,(au*aL-aQ*ax)/X
end
function cp(e,g,h,aa,aj,ap,aY,bc,bt,i)return aY*i^2/2+aa*i+e,bc*i^2/2+aj*i+g,bt*i^2/2+ap*i+h,aY*i+aa,bc*i+aj,bt*i+ap
end
J=0
D=0
function bv(E,L,H,bT,bM,aU,co,min,max)local B,aD,I
B=bT-bM
an=aU+B
aD=B-co
I=E*B+L*an+H*aD
if I>max or I<min then
an=aU
I=E*B+L*an+H*aD
end
return ah(I,min,max),an,B
end
k=0
bp,bo,aW=0,0,0
al=p.huge
function onTick()O,F,G=_(1),_(2),_(3)c,f,d=_(4),_(5),_(6)bG,cm,cn=_(7)/60,_(8)/60,_(9)/60
bX,cq,bI=_(10)*x/60,_(11)*x/60,_(12)*x/60
cb=_(16)==1
if cb then
bp,bo,aW=_(13),_(14),_(15)al=0
end
R,Q,N=_(17),_(18),_(19)W,ac,ad=_(20),_(21),_(22)cs,cx,cv=_(23),_(24),_(25)cg=_(26)==1
am=_(27)bs,bb=_(28),_(29)S=br(_(30))aF=_(31)%10==1
aK=_(31)%A>=10
b_=_(31)>=A
af=z("Cam control gain")bq,aX=z("Gear ratio (1 : ?)"),z("Types of Yaw PIVOT")ch,bQ,bD=z("Body phys. offset X"),z("Body phys. offset Y"),z("Body phys. offset Z")bx,bd,bh=ay(ch,bQ,bD,O,F,G,c,f,d)R,Q,N,W,ac,ad=cp(R,Q,N,W,ac,ad,cs,cx,cv,bS)T=b_ and cg
if al<=ck then
al=al+1
T=true
R,Q,N=bp,bo,aW
W,ac,ad=0,0,0
end
if aF and(aK or T)then
if not bJ then
n,l,o=be(1,S,k,aq)aH,az,aR=ay(n,l,o,0,0,0,c,f,d)end
if T then
ba,bw,bu=0,0,0
av,bf=0,0
aH,az,aR=R-bx,Q-bd,N-bh
else
av=-x*af*am*bb/60
bf=x*af*am*bs/60
ba=av*b(S*x)bw=-av*a(S*x)bu=bf
end
n,l,o=ar(aH,az,aR,0,0,0,c,f,d)n,l,o=aA(n,l,o,ba,bw,bu,1)local ag,bC,bU=aI(n,l,o,aq)n,l,o=be(1,bC,ah(bU,-.125,.25))aH,az,aR=ay(n,l,o,0,0,0,c,f,d)local ai,ab,Z=ar(bX,bI,cq,0,0,0,c,f,d)if T then
local cd,bR,bY=ar(R,Q,N,bx,bh,bd,c,f,d)local bL,cj,bE=ar(W,ac,ad,0,0,0,c,f,d)local cf,ce,cc=ci(bG,cn,cm,cd,bR,bY,bL,cj,bE)ai,ab,Z=ai+cf,ab+ce,Z+cc
end
local bH,c_,cr=aA(n,l,o,-ai,-ab,-Z,bP)ag,ag,k=aI(bH,c_,cr,aq)local ca,bN,cl=aA(n,l,o,-ai,-ab,-Z,cw)ag,bF,ag=aI(ca,bN,cl,aq)local bZ=bq*br(bF-S)/aX
M,J,D=bv(E,L,H,0,-bZ,J,D,-A,A)elseif aF then
J,D=0,0
k=ah(af*am*bb/60+k,-.125,.25)M=af*am*bs*bq/aX
else
k=0
M,J,D=bv(E,L,H,0,S,J,D,-A,A)end
bJ=aF and(aK or T)cy=ah(k-.25,-.125,0)bO=k>.125
if M==nil then
M=0
end
ct(1,bO)C(1,0)C(2,k*8)C(3,M)C(4,k)C(5,0)C(6,cy*8)end
function onDraw()bm=at.getWidth()j=at.getHeight()at.setColor(0,255,0)if aK then
bk(bl(bm/2)-21,j-6,"STAB")end
if b_ then
bk(bl(bm/2),j-6,"AUTO")end
end
