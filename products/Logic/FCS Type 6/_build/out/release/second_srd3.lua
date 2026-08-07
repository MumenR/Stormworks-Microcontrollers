bU='f'
bT='I3B'

p=nil
af=true
v=pairs
D=false
bs=property
bu=output
ba=input
b_=table
aj=math
aa=aj.huge
aQ=b_.remove
U=b_.insert
bk=aj.pi
o=aj.sin
q=aj.cos
x=ba.getNumber
bF=ba.getBool
m=bu.setNumber
bQ=bu.setBool
aA=bs.getNumber
bI=bs.getBool
L={}a={}az={}ai=D
Z=0
i=0
aR=1
aF={}bc=15
bC=600
bg=50
bl=300/60
bh=900/(60*60)bn=.1
M=24
function bR(y,t)t=aj.floor(t/bn+.5)if t<0 then
t=(t+(1<<M))&((1<<M)-1)end
t=t|y<<M
y=(y>>(24-M))+66
if y>=127 then
y=y+67
end
local b=(bU):unpack((bT):pack(t & 16777215,y & 255))return b
end
function aV(b)local t,y=(bT):unpack((bU):pack(b))if y>>7 & 1~=0 then
y=y-67
end
y=(y-66)<<(24-M)|(t>>M)t=t &((1<<M)-1)if t>>(M-1)& 1~=0 then
t=t-(1<<M)end
return y,t*bn
end
function bK(b,min,max)if b>=max then
return max
elseif b<=min then
return min
else
return b
end
end
function bO(ae,ad,ak,as,au,ao,B,G,C)bA=q(C)*q(G)*ae+(q(C)*o(G)*o(B)-o(C)*q(B))*ak+(q(C)*o(G)*q(B)+o(C)*o(B))*ad
bH=o(C)*q(G)*ae+(o(C)*o(G)*o(B)+q(C)*q(B))*ak+(o(C)*o(G)*q(B)-q(C)*o(B))*ad
bP=-o(G)*ae+q(G)*o(B)*ak+q(G)*q(B)*ad
return bA+as,bP+ao,bH+au
end
function bE(S,Y,N,bz)local b,f,e
if not bz then
S=S*bk*2
Y=Y*bk*2
end
b=N*q(S)*o(Y)f=N*q(S)*q(Y)e=N*o(S)return b,f,e
end
function ah(O,Q,R,bJ,bN,bw)return aj.sqrt((O-bJ)^2+(Q-bN)^2+(R-bw)^2)end
function aU(F)local l,n,ac,H,ax,ap=0,0,0,0,0,0
local bD=F[1].k and(F[#F].k-F[1].k)if#F<2 or bD<30 then
l=0
n=F[#F].b
else
for ag,ar in v(F)do
ac=ac+ar.k
H=H+ar.b
ax=ax+ar.k*ar.b
ap=ap+ar.k^2
end
l=(#F*ax-ac*H)/(#F*ap-ac^2)n=(ap*H-ax*ac)/(#F*ap-ac^2)end
return l or 0,n or 0
end
function bb()local d,av=1,af
while av do
av=D
for ag,_ in v(a)do
av=_.d==d
if av then
d=d+1
break
end
end
end
return d
end
function al(d)local al=D
for ag,bB in v(az)do
if bB.d==d then
al=af
break
end
end
return al
end
aC=0
function onTick()bf=aA("Vehicle radius [m]")aO=aA("Delay [tick]")bM=aA("Max target output time [sec]")*60
aw=aA("Detection interval [tick]")bL=bI("Mode")if bL then
s=x(31)else
s=0
end
aE=x(32)==1
U(L,{x(25),x(26),x(27),x(28),x(29),x(30)})while#L>6
do
aQ(L,1)end
as=L[1][1]au=L[1][2]ao=L[1][3]B=L[1][4]G=L[1][5]C=L[1][6]for d,_ in v(a)do
_.I=_.I+1
_.aY=D
if#_.j~=0 then
for ag,bj in v(_.j)do
bj.k=bj.k-1
end
_.ab=-_.j[#_.j].k
local N=ah(as,ao,au,_.j[#_.j].b,_.j[#_.j].f,_.j[#_.j].e)local be=bK(120*N/1000+10,2.5*aw,aa)if(_.ab>be or _.ab>aw*3)and not _.z then
a[d]=p
else
local c=1
while c<=#_.j do
if-_.j[c].k>be then
aQ(_.j,c)else
c=c+1
end
end
end
elseif not _.z then
a[d]=p
end
end
for bG,aD in v(az)do
aD.k=aD.k+1
if aD.k>bM or a[aD.d]==p then
az[bG]=p
end
end
for u,h in v(aF)do
h.k=h.k+1
if h.k>bC then
aF[u]=p
end
end
local bd,bp,br,b,f,e,aG
bd,b=aV(x(22))bp,f=aV(x(23))br,e=aV(x(24))aG=bd*100+bp*10+br
if aG~=0 and aC>3 then
aF[aG]={b=b,f=f,e=e,k=0}end
if aC<4 then
aC=aC+1
end
for ag,_ in v(a)do
_.z=D
end
for u,h in v(aF)do
local z=af
local aW,P=aa,0
for d,_ in v(a)do
if _.g~=p and not _.z then
local O,Q,R,T
O=_.g.b.l+_.g.b.n
Q=_.g.f.l+_.g.f.n
R=_.g.e.l+_.g.e.n
T=ah(O,Q,R,h.b,h.f,h.e)if T<aW then
aW=T
P=d
end
end
end
if P~=0 then
local V=bh*(aw^2)/2+bl*aw+.02*ah(0,0,0,h.b,h.f,h.e)+bg
if aW<V then
z=D
if a[u]~=p then
a[u],a[P]=a[P],a[u]a[u].d,a[P].d=a[P].d,a[u].d
else
a[u],a[P]=a[P],p
end
a[u].h=h
a[u].z=af
end
end
if z then
if a[u]~=p then
local aZ=bb()a[u].d=aZ
a[aZ],a[u]=a[u],p
end
a[u]={j={},g={b={l=0,n=h.b},f={l=0,n=h.f},e={l=0,n=h.e}},d=u,ab=0,I=aa,h=h,z=af}end
end
A={}for c=1,7 do
local Y,S,T,ae,ad,ak,bv,bo,bm
T=x(c*3-2)Y=x(c*3-1)S=x(c*3-0)if bF(c)and T>=bf then
ae,ad,ak=bE(S,Y,T,D)bv,bo,bm=bO(ae,ad,ak,as,au,ao,B,G,C)U(A,{b=bv,f=bo,e=bm,at=T,k=0})end
end
for c=1,#A do
local W,an,K,bi,H,am,aq,E
W=A[c]if W==p then
break
end
bi=.02*W.at+bf
K={W}E=c+1
while E<=#A do
an=A[E]if ah(W.b,W.f,W.e,an.b,an.f,an.e)<bi then
U(K,an)aQ(A,E)else
E=E+1
end
end
H,am,aq=0,0,0
for ag,aT in v(K)do
H=H+aT.b
am=am+aT.f
aq=aq+aT.e
end
A[c]={b=H/#K,f=am/#K,e=aq/#K,at=ah(as,ao,au,H/#K,am/#K,aq/#K),k=0}end
for aX,X in v(A)do
local V,aB,ay,O,Q,R,N
if#a==0 then
break
end
aB=aa
ay=0
for c,_ in v(a)do
if#_.j==0 then
O=_.h.b
Q=_.h.f
R=_.h.e
else
O=_.g.b.l+_.g.b.n
Q=_.g.f.l+_.g.f.n
R=_.g.e.l+_.g.e.n
end
N=ah(O,Q,R,X.b,X.f,X.e)if N<aB and not _.aY then
aB=N
ay=c
end
end
if ay~=0 then
local _=a[ay]if#_.j<=1 then
V=bl*_.ab
else
V=bh*(_.ab^2)/2
end
V=V+.02*X.at+bg
if aB<V then
A[aX].at=p
_.I=aa
_.aY=af
U(_.j,A[aX])A[aX]=p
end
end
end
for ag,X in v(A)do
local d=bb()X.at=p
a[d]={j={X},g={b={},f={},e={}},d=d,ab=0,I=aa,h={},z=D,aY=D}end
for d,_ in v(a)do
if#_.j~=0 then
local aS,aL,aH,aJ,aI,aN,aM,aP,aK
aS,aL,aH={},{},{}for c=1,#_.j do
U(aS,{k=_.j[c].k,b=_.j[c].b})U(aL,{k=_.j[c].k,b=_.j[c].f})U(aH,{k=_.j[c].k,b=_.j[c].e})end
aJ,aI=aU(aS)aN,aM=aU(aL)aP,aK=aU(aH)a[d].g={b={l=aJ,n=aI,r=aJ*aO+aI},f={l=aN,n=aM,r=aN*aO+aM},e={l=aP,n=aK,r=aP*aO+aK}}else
a[d].g={b={l=0,n=_.h.b,r=_.h.b},f={l=0,n=_.h.f,r=_.h.f},e={l=0,n=_.h.e,r=_.h.e}}end
end
if aE then
Z=Z+1
end
bq=Z<bc and Z>0 and not aE
bx=Z>=bc and Z>0 and not aE
if not aE then
Z=0
end
if bq and#a~=0 then
ai=i~=s
elseif#a==0 or(a[i]==p and i~=0)then
ai=D
i=0
end
if s~=0 and ai and bq and a[s]and not a[s].z then
i=s
elseif not ai or(a[i]and a[i].z)then
i=0
ai=D
end
if bx and ai then
local by={d=i,bS=aR,k=0,I=aa}U(az,by)aR=aR+1
end
for c=1,32 do
m(c,0)end
c=1
if i~=0 and a[i]~=p then
m(c*4-3,a[i].g.b.r)m(c*4-2,a[i].g.f.r)m(c*4-1,a[i].g.e.r)local w=a[i].d+2*10^3
if s==i then
w=w+1*10^5
end
m(c*4-0,w)m(25,a[i].g.b.r)m(26,a[i].g.f.r)m(27,a[i].g.e.r)m(28,a[i].g.b.l)m(29,a[i].g.f.l)m(30,a[i].g.e.l)m(31,1)a[i].I=0
c=c+1
end
if s~=0 and i~=s and a[s]~=p then
m(c*4-3,a[s].g.b.r)m(c*4-2,a[s].g.f.r)m(c*4-1,a[s].g.e.r)local w=1*10^5
if al(s)then
w=w+1*10^3
end
if a[s].z then
w=w+1*10^4
end
m(c*4-0,a[s].d+w)a[s].I=0
c=c+1
end
for E=c,6 do
local bt,J=0,0
for d,_ in v(a)do
if(_.I>bt)and(d~=i)and(d~=i)then
bt=_.I
J=d
end
end
if J~=0 then
m(E*4-3,a[J].g.b.r)m(E*4-2,a[J].g.f.r)m(E*4-1,a[J].g.e.r)local w=0
if al(a[J].d)then
w=w+1*10^3
end
if a[J].z then
w=w+1*10^4
end
m(E*4-0,a[J].d+w)a[J].I=0
end
end
m(32,aG)end
