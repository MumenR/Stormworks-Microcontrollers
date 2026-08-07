
aY=nil
M=true
N=pairs
w=false
cl=output
ca=input
bV=table
U=math
aO=U.huge
bM=U.abs
bc=bV.remove
an=bV.insert
V=U.sqrt
d=U.sin
c=U.cos
ah=U.pi
bI=U.atan
p=ca.getNumber
bl=ca.getBool
as=cl.setNumber
cm=cl.setBool
F=property.getNumber
bp=w
bb=w
az=w
cR=w
aX=w
aS=w
cS={}x={}bs=300
bF=300
bs=bs/60
bF=bF/3600
av=50
cT=w
s,u,E,R,T,Q=0,0,0,0,0,0
aN,ba,bd,bL,cn,bO=0,0,0,0,0,0
bv,bm=0,0
n=0
bt=0
function cj(_,min,max)if _>=max then
return max
elseif _<=min then
return min
else
return _
end
end
function aW(_,b)local f
if _>=0 then
f=bI(b/_)elseif b>=0 then
f=bI(b/_)+ah
else
f=bI(b/_)-ah
end
return f
end
function cd(C,y,G,e,m,h,j,l,i)cB=c(i)*c(l)*C+(c(i)*d(l)*d(j)-d(i)*c(j))*G+(c(i)*d(l)*c(j)+d(i)*d(j))*y
cs=d(i)*c(l)*C+(d(i)*d(l)*d(j)+c(i)*c(j))*G+(d(i)*d(l)*c(j)-c(i)*d(j))*y
cA=-d(l)*C+c(l)*d(j)*G+c(l)*c(j)*y
return cB+e,cA+h,cs+m
end
function bo(au,ax,ap,e,m,h,j,l,i)local au=au-e
local ax=ax-h
local ap=ap-m
local k,r,ai,q,ag,ad,aj,ak,g,H,aR,bg,_,f,b
k=c(i)*c(l)r=c(i)*d(l)*d(j)-d(i)*c(j)ai=c(i)*d(l)*c(j)+d(i)*d(j)q=au
ag=d(i)*c(l)ad=d(i)*d(l)*d(j)+c(i)*c(j)aj=d(i)*d(l)*c(j)-c(i)*d(j)ak=ap
g=-d(l)H=c(l)*d(j)aR=c(l)*c(j)bg=ax
local aT=((k*ad-r*ag)*aR+(ai*ag-k*aj)*H+(r*aj-ai*ad)*g)_=0
b=0
f=0
if aT~=0 then
_=((r*aj-ai*ad)*bg+(q*ad-r*ak)*aR+(ai*ak-q*aj)*H)/aT
b=-((k*aj-ai*ag)*bg+(q*ag-k*ak)*aR+(ai*ak-q*aj)*g)/aT
f=((k*ad-r*ag)*bg+(q*ag-k*ak)*H+(r*ak-q*ad)*g)/aT
end
return _,f,b
end
function ct(B,K,z,bJ)local _,b,f
if not bJ then
B=B*ah*2
K=K*ah*2
end
_=z*c(B)*d(K)b=z*c(B)*c(K)f=z*d(B)return _,b,f
end
function ck(_,b,f,bJ)local B,K
B=aW(V(_^2+b^2),f)K=aW(b,_)if bJ then
return B,K
else
return B/(ah*2),K/(ah*2)end
end
bQ,cp=0,0
c_,bN=0,0
function bW(aK,aJ,aF,cM,cC,ci,cy,min,max)local A,bq,aI
A=cM-cC
bf=ci+A
bq=A-cy
aI=aK*A+aJ*bf+aF*bq
if aI>max or aI<min then
bf=ci
aI=aK*A+aJ*bf+aF*bq
end
return cj(aI,min,max),bf,A
end
function X(aZ,be,aP,cJ,cF,cu)return V((aZ-cJ)^2+(be-cF)^2+(aP-cu)^2)end
function br(af)local k,r,at,O,aQ,aL=0,0,0,0,0,0
if#af<2 then
k=0
r=af[#af]._
else
for aq,aM in N(af)do
at=at+aM.n
O=O+aM._
aQ=aQ+aM.n*aM._
aL=aL+aM.n^2
end
k=(#af*aQ-at*O)/(#af*aL-at^2)r=(aL*O-aQ*at)/(#af*aL-at^2)end
return k,r
end
function cI()local I,aV=1,M
while aV do
aV=w
for aq,a in N(x)do
aV=a.cr==I
if aV then
I=I+1
break
end
end
end
return I
end
function bR(_,b,f,cK,cG,cH,n)local aH,aG,aD
aH=_+cK*n
aG=b+cG*n
aD=f+cH*n
return aH,aG,aD
end
aw={}function cQ(J)an(aw,J)if#aw>60 then
bc(aw,1)end
local bw=0
for g=1,#aw do
bw=bw+aw[g]end
return bw/#aw
end
function bk(s,u,E,R,T,Q,e,h,m,J,q,Z)s,u,E=bR(s,u,E,R,T,Q,Z)local D,L,P,am,ae,aH,aG,aD
local bU,cb,cf=e-s,h-u,m-E
L=U.acos((R*bU+T*cb+Q*cf)/V((R^2+T^2+Q^2)*(bU^2+cb^2+cf)))D=V(R^2+T^2+Q^2)if D==J then
if c(L)>0 then
P=q/(J*c(L))else
P=0
end
else
if J/D>bM(d(L))then
am=q*(D*c(L)+V(J^2-(D^2)*(d(L)^2)))/(D^2-J^2)ae=q*(D*c(L)-V(J^2-(D^2)*(d(L)^2)))/(D^2-J^2)if am>0 and ae>0 then
if am>ae then
P=ae
else
P=am
end
elseif am>0 and ae<=0 then
P=am
elseif ae>0 and am<=0 then
P=ae
else
P=0
end
elseif J/D==bM(d(L))then
P=q*D*c(L)/(D^2-J^2)else
P=0
end
end
aH,aG,aD=bR(s,u,E,R,T,Q,P)return aH,aG,aD
end
function bD(s,u,e,h,Z)local _,b,k,cq,ce
if s==e then
_=s
if u>h then
b=h+Z
else
b=h-Z
end
elseif u==h then
b=u
if s>e then
_=e+Z
else
_=e-Z
end
else
k=(h-u)/(e-s)cq=(Z/V(1+k^2))+e
ce=-(Z/V(1+k^2))+e
if s>e then
_=cq
else
_=ce
end
b=k*(_-e)+h
end
return _,b
end
function onTick()e,m,h=p(26),p(27),p(28)j,l,i=p(29),p(30),p(31)bG=F("radar delay [tick]")cv=F("detonation delay [tick]")aK,aJ,aF=F("P"),F("I"),F("D")type=F("Type")aU=p(25)%10
aS=p(25)%100>10
cc=bl(9)cL=bl(10)cD=p(32)/60
cN=F("Weapon Model No.")cx=F("Time to self-destruct (s)")*60
bT=F("Guidance start altitude [m]")cE=F("Cruise mode altitude [m]")cz=F("Top attack mode altitude [m]")cw=F("Sea skimming mode altitude [m]")if cL then
s=p(4)u=p(8)E=p(12)R=p(16)T=p(20)Q=p(24)end
if cc then
if aS then
for I,a in N(x)do
for aq,ch in N(a.o)do
ch.n=ch.n-1
end
a.b_=-a.o[#a.o].n
a.bC=a.bC+1
local z=X(e,h,m,a.o[#a.o]._,a.o[#a.o].b,a.o[#a.o].f)co=cj(150*z/2000+10,10,300)if a.b_>co then
x[I]=aY
else
local g=1
while g<=#a.o do
if-a.o[g].n>co then
bc(a.o,g)else
g=g+1
end
end
end
end
v={}for g=1,6 do
local K,B,bE,C,y,G,au,ax,ap
bE=p(g*4-3)K=p(g*4-2)B=p(g*4-1)if bl(g)then
C,y,G=ct(B,K,bE,w)au,ax,ap=cd(C,y,G,e,m,h,j,l,i)an(v,{_=au,b=ax,f=ap,q=bE,n=0})end
end
for g=1,#v do
local al,aB,S,bS,O,aA,aC,H
al=v[g]if al==aY then
break
end
bS=.02*al.q+av
S={al}H=g+1
while H<=#v do
aB=v[H]if X(al._,al.b,al.f,aB._,aB.b,aB.f)<bS then
an(S,aB)bc(v,H)else
H=H+1
end
end
O,aA,aC=0,0,0
for aq,bK in N(S)do
O=O+bK._
aA=aA+bK.b
aC=aC+bK.f
end
v[g]={_=O/#S,b=aA/#S,f=aC/#S,q=X(e,h,m,O/#S,aA/#S,aC/#S),n=0}end
for aq,a in N(x)do
local A,av,ay,aZ,be,aP,z
if#v==0 then
break
end
av=aO
ay=0
aZ=a.t._.k+a.t._.r
be=a.t.b.k+a.t.b.r
aP=a.t.f.k+a.t.f.r
for g,ar in N(v)do
z=X(aZ,be,aP,ar._,ar.b,ar.f)if z<av then
av=z
ay=g
end
end
if#a.o<=1 then
A=bs*a.b_
else
A=bF*(a.b_^2)/2
end
A=A+.02*v[ay].q
if av<A then
v[ay].q=aY
a.bC=aO
an(a.o,v[ay])bc(v,ay)end
end
for aq,ar in N(v)do
local I=cI()ar.q=aY
x[I]={o={ar},t={_={},b={},f={}},cr=I,b_=0,bC=aO}end
for aq,a in N(x)do
local bH,bA,bn,bz,bx,bB,bu,bi,bh
bH,bA,bn={},{},{}for g=1,#a.o do
an(bH,{n=a.o[g].n,_=a.o[g]._})an(bA,{n=a.o[g].n,_=a.o[g].b})an(bn,{n=a.o[g].n,_=a.o[g].f})end
bz,bx=br(bH)bB,bu=br(bA)bi,bh=br(bn)a.t={_={k=bz,r=bx,ab=bG*bz+bx},b={k=bB,r=bu,ab=bG*bB+bu},f={k=bi,r=bh,ab=bG*bi+bh}}end
cg,aa=aO,0
for I,a in N(x)do
local z=X(s,u,E,a.t._.ab,a.t.b.ab,a.t.f.ab)if z<cg then
cg=z
aa=I
end
end
aX=aa~=0
if aX then
aN=x[aa].t._.ab
ba=x[aa].t.b.ab
bd=x[aa].t.f.ab
bL=x[aa].t._.k
cn=x[aa].t.b.k
bO=x[aa].t.f.k
end
end
aE=cQ(cD)ao=X(s,u,E,e,h,m)if bb==w then
if type==1 then
W,Y,ac=e,h,m+1000
if m>=bT and m>cO+bT then
bb=M
end
elseif type==2 then
W,Y,ac=cd(0,1000,0,e,m,h,j,l,i)n=n+1
if n>60 then
bb=M
end
end
elseif az==w then
by,bj,bY=bk(s,u,E,R,T,Q,e,h,m,aE,ao,2)if aU==1 then
az=M
elseif aU==2 then
W,Y=bD(by,bj,e,h,500)ac=cE+bY
if ao<500 then
az=M
end
elseif aU==3 then
W,Y=bD(by,bj,e,h,500)ac=cz+bY
if ao<(m-E)/c(ah/9)then
az=M
end
elseif aU==4 then
W,Y=bD(by,bj,e,h,200)ac=cw
if ao<200 then
az=M
end
end
elseif cR==w then
cP=X(aN,ba,bd,e,h,m)if aS and ao<2000 and aX then
W,Y,ac=bk(aN,ba,bd,bL,cn,bO,e,h,m,aE,cP,0)else
W,Y,ac=bk(s,u,E,R,T,Q,e,h,m,aE,ao,2)end
bX=X(W,Y,ac,e,h,m)if bX/aE<cv then
bp=M
end
as(31,bX/aE)end
local C,y,G=bo(W,Y,ac,e,m,h,j,l,i)bP=-bW(aK,aJ,aF,0,aW(y,C),bQ,cp,-2,2)bZ=-bW(aK,aJ,aF,0,aW(y,G),c_,bN,-2,2)if az and aS and ao<2000 and aX then
local C,y,G=bo(aN,ba,bd,e,m,h,j,l,i)bm,bv=ck(C,y,G,w)else
local C,y,G=bo(s,u,E,e,m,h,j,l,i)bm,bv=ck(C,y,G,w)end
if bb==M then
bt=bt+1
if bt>cx then
bp=M
end
end
else
bQ,cp=0,0
c_,bN=0,0
bP,bZ=0,0
cO=m
end
as(1,bP)as(2,bZ)as(3,bv)as(4,bm)cm(1,bp)cm(2,cc)as(32,cN)end
