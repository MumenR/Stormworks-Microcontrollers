bS='f'
bR='I3B'

m=nil
aw=true
r=pairs
A=false
bp=property
bq=output
bs=input
aX=table
aj=math
Y=aj.huge
aT=aX.remove
J=aX.insert
ba=aj.pi
o=aj.sin
n=aj.cos
t=bs.getNumber
bw=bs.getBool
C=bq.setNumber
bP=bq.setBool
aC=bp.getNumber
bG=bp.getBool
F={}a={}ad={}Z=A
T=0
I=0
aS=1
ay={}bn=15
bF=600
bl=50
bd=300/60
bf=300/(60*60)br=.1
H=24
function bQ(s,q)q=aj.floor(q/br+.5)if q<0 then
q=(q+(1<<H))&((1<<H)-1)end
q=q|s<<H
s=(s>>(24-H))+66
if s>=127 then
s=s+67
end
local b=(bS):unpack((bR):pack(q & 16777215,s & 255))return b
end
function aG(b)local q,s=(bR):unpack((bS):pack(b))if s>>7 & 1~=0 then
s=s-67
end
s=(s-66)<<(24-H)|(q>>H)q=q &((1<<H)-1)if q>>(H-1)& 1~=0 then
q=q-(1<<H)end
return s,q*br
end
function bM(b,min,max)if b>=max then
return max
elseif b<=min then
return min
else
return b
end
end
function bI(aa,ab,ag,aq,ar,av,u,y,v)bE=n(v)*n(y)*aa+(n(v)*o(y)*o(u)-o(v)*n(u))*ag+(n(v)*o(y)*n(u)+o(v)*o(u))*ab
bO=o(v)*n(y)*aa+(o(v)*o(y)*o(u)+n(v)*n(u))*ag+(o(v)*o(y)*n(u)-n(v)*o(u))*ab
bN=-o(y)*aa+n(y)*o(u)*ag+n(y)*n(u)*ab
return bE+aq,bN+av,bO+ar
end
function bK(M,X,E,bA)local b,e,d
if not bA then
M=M*ba*2
X=X*ba*2
end
b=E*n(M)*o(X)e=E*n(M)*n(X)d=E*o(M)return b,e,d
end
function ak(Q,S,O,bx,bB,bL)return aj.sqrt((Q-bx)^2+(S-bB)^2+(O-bL)^2)end
function aU(z)local j,l,ai,B,az,ap=0,0,0,0,0,0
local by=z[1].h and(z[#z].h-z[1].h)if#z<2 or by<30 then
j=0
l=z[#z].b
else
for an,am in r(z)do
ai=ai+am.h
B=B+am.b
az=az+am.h*am.b
ap=ap+am.h^2
end
j=(#z*az-ai*B)/(#z*ap-ai^2)l=(ap*B-az*ai)/(#z*ap-ai^2)end
return j or 0,l or 0
end
function bu()local g,aF=1,aw
while aF do
aF=A
for an,_ in r(a)do
aF=_.g==g
if aF then
g=g+1
break
end
end
end
return g
end
aE=0
function onTick()bm=aC("Vehicle radius [m]")aW=aC("Delay [tick]")bJ=aC("Max target output time [sec]")*60
ax=aC("Detection interval [tick]")bv=bG("Mode")if bv then
ae=t(31)else
ae=0
end
aD=t(32)==1
J(F,{t(25),t(26),t(27),t(28),t(29),t(30)})while#F>6
do
aT(F,1)end
aq=F[1][1]ar=F[1][2]av=F[1][3]u=F[1][4]y=F[1][5]v=F[1][6]for g,_ in r(a)do
_.D=_.D+1
_.aZ=A
if#_.i~=0 then
for an,bo in r(_.i)do
bo.h=bo.h-1
end
_.af=-_.i[#_.i].h
local E=ak(aq,av,ar,_.i[#_.i].b,_.i[#_.i].e,_.i[#_.i].d)local b_=bM(120*E/1000+10,2.5*ax,Y)if(_.af>b_ or _.af>ax*3)and not _.x then
a[g]=m
else
local c=1
while c<=#_.i do
if-_.i[c].h>b_ then
aT(_.i,c)else
c=c+1
end
end
end
elseif not _.x then
a[g]=m
end
end
for as,ac in r(ad)do
ac.D=ac.D+1
ac.h=ac.h+1
if ac.h>bJ or a[ac.g]==m then
ad[as]=m
end
end
for p,f in r(ay)do
f.h=f.h+1
if f.h>bF then
ay[p]=m
end
end
local bg,bb,bt,b,e,d,aI
bg,b=aG(t(22))bb,e=aG(t(23))bt,d=aG(t(24))aI=bg*100+bb*10+bt
if aI~=0 and aE>3 then
ay[aI]={b=b,e=e,d=d,h=0}end
if aE<4 then
aE=aE+1
end
for an,_ in r(a)do
_.x=A
end
for p,f in r(ay)do
local x=aw
local aR,K=Y,0
for g,_ in r(a)do
if _.k~=m and not _.x then
local Q,S,O,L
Q=_.k.b.j+_.k.b.l
S=_.k.e.j+_.k.e.l
O=_.k.d.j+_.k.d.l
L=ak(Q,S,O,f.b,f.e,f.d)if L<aR then
aR=L
K=g
end
end
end
if K~=0 then
local V=bf*(ax^2)/2+bd*ax+.02*ak(0,0,0,f.b,f.e,f.d)+bl
if aR<V then
x=A
if a[p]~=m then
a[p],a[K]=a[K],a[p]a[p].g,a[K].g=a[K].g,a[p].g
else
a[p],a[K]=a[K],m
end
a[p].f=f
a[p].x=aw
end
end
if x then
if a[p]~=m then
local be=bu()a[p].g=be
a[be],a[p]=a[p],m
end
a[p]={i={},k={b={j=0,l=f.b},e={j=0,l=f.e},d={j=0,l=f.d}},g=p,af=0,D=Y,f=f,x=aw}end
end
w={}for c=1,7 do
local X,M,L,aa,ab,ag,bc,bh,bj
L=t(c*3-2)X=t(c*3-1)M=t(c*3-0)if bw(c)and L>=bm then
aa,ab,ag=bK(M,X,L,A)bc,bh,bj=bI(aa,ab,ag,aq,ar,av,u,y,v)J(w,{b=bc,e=bh,d=bj,al=L,h=0})end
end
for c=1,#w do
local W,au,G,bk,B,at,ao,ah
W=w[c]if W==m then
break
end
bk=.02*W.al+bm
G={W}ah=c+1
while ah<=#w do
au=w[ah]if ak(W.b,W.e,W.d,au.b,au.e,au.d)<bk then
J(G,au)aT(w,ah)else
ah=ah+1
end
end
B,at,ao=0,0,0
for an,aM in r(G)do
B=B+aM.b
at=at+aM.e
ao=ao+aM.d
end
w[c]={b=B/#G,e=at/#G,d=ao/#G,al=ak(aq,av,ar,B/#G,at/#G,ao/#G),h=0}end
for aL,U in r(w)do
local V,aA,aB,Q,S,O,E
if#a==0 then
break
end
aA=Y
aB=0
for c,_ in r(a)do
if#_.i==0 then
Q=_.f.b
S=_.f.e
O=_.f.d
else
Q=_.k.b.j+_.k.b.l
S=_.k.e.j+_.k.e.l
O=_.k.d.j+_.k.d.l
end
E=ak(Q,S,O,U.b,U.e,U.d)if E<aA and not _.aZ then
aA=E
aB=c
end
end
if aB~=0 then
local _=a[aB]if#_.i<=1 then
V=bd*_.af
else
V=bf*(_.af^2)/2
end
V=V+.02*U.al+bl
if aA<V then
w[aL].al=m
_.D=Y
_.aZ=aw
J(_.i,w[aL])w[aL]=m
end
end
end
for an,U in r(w)do
local g=bu()U.al=m
a[g]={i={U},k={b={},e={},d={}},g=g,af=0,D=Y,f={},x=A,aZ=A}end
for g,_ in r(a)do
if#_.i~=0 then
local aK,aN,aJ,aV,aY,aO,aH,aP,aQ
aK,aN,aJ={},{},{}for c=1,#_.i do
J(aK,{h=_.i[c].h,b=_.i[c].b})J(aN,{h=_.i[c].h,b=_.i[c].e})J(aJ,{h=_.i[c].h,b=_.i[c].d})end
aV,aY=aU(aK)aO,aH=aU(aN)aP,aQ=aU(aJ)a[g].k={b={j=aV,l=aY,R=aV*aW+aY},e={j=aO,l=aH,R=aO*aW+aH},d={j=aP,l=aQ,R=aP*aW+aQ}}else
a[g].k={b={j=0,l=_.f.b,R=_.f.b},e={j=0,l=_.f.e,R=_.f.e},d={j=0,l=_.f.d,R=_.f.d}}end
end
if aD then
T=T+1
end
bi=T<bn and T>0 and not aD
bC=T>=bn and T>0 and not aD
if not aD then
T=0
end
if bi and#a~=0 then
Z=I~=ae
elseif#a==0 or(a[I]==m and I~=0)then
Z=A
I=0
end
if ae~=0 and Z and bi and a[ae]and not a[ae].x then
I=ae
elseif not Z or(a[I]and a[I].x)then
I=0
Z=A
end
if bC and Z then
local bz={g=I,bD=aS,h=0,D=Y}J(ad,bz)aS=aS+1
end
for c=1,32 do
C(c,0)end
P={}for as,bH in r(ad)do
J(P,bH)P[#P].as=as
end
aX.sort(P,function(j,l)return j.D>l.D end)for c=1,4 do
if P[c]~=m then
N=P[c].g
if a[N]~=m and a[N].k~=m then
C(c*7-6,a[N].k.b.R)C(c*7-5,a[N].k.e.R)C(c*7-4,a[N].k.d.R)C(c*7-3,a[N].k.b.j)C(c*7-2,a[N].k.e.j)C(c*7-1,a[N].k.d.j)C(c*7-0,P[c].bD)ad[P[c].as].D=0
end
end
end
C(32,#ad)C(31,#a)end
