-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/


ba=false
aO=output
aW=input
x=math
ak=x.abs
bn=x.exp
a=x.sin
b=x.cos
t=x.pi
aJ=x.atan
_=aW.getNumber
R=aW.getBool
d=aO.setNumber
aC=aO.setBool
cc=property.getNumber
m=0
aG=0
y=30/3600
aY=600/3600
e=0
ae={{600,.0005,2400,.105},{700,.001,2400,.11},{800,.002,1500,.12},{900,.005,600,.125},{1000,.01,300,.13},{1000,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}function l(h,c)if h>=0 then
an=aJ(c/h)elseif c>=0 then
an=aJ(c/h)+t
else
an=aJ(c/h)-t
end
return an
end
function b_(ay,aF,aH,av,al,aq,f,i,g)ay,aF,aH=ay-av,aF-aq,aH-al
B=b(g)*b(i)A=b(g)*a(i)*a(f)-a(g)*b(f)C=b(g)*a(i)*b(f)+a(g)*a(f)D=ay
L=a(g)*b(i)E=a(g)*a(i)*a(f)+b(g)*b(f)J=a(g)*a(i)*b(f)-b(g)*a(f)F=aH
au=-a(i)aL=b(i)*a(f)ax=b(i)*b(f)ao=aF
aa=((B*E-A*L)*ax+(C*L-B*J)*aL+(A*J-C*E)*au)bu,bs,bk=0,0,0
if aa~=0 then
bu=((A*J-C*E)*ao+(D*E-A*F)*ax+(C*F-D*J)*aL)/aa
bs=-((B*J-C*L)*ao+(D*L-B*F)*ax+(C*F-D*J)*au)/aa
bk=((B*E-A*L)*ao+(D*L-B*F)*aL+(A*F-D*E)*au)/aa
end
return bu,bk,bs
end
function at(ar,aA,az,av,al,aq,f,i,g)bH=b(g)*b(i)*ar+(b(g)*a(i)*a(f)-a(g)*b(f))*az+(b(g)*a(i)*b(f)+a(g)*a(f))*aA
bK=a(g)*b(i)*ar+(a(g)*a(i)*a(f)+b(g)*b(f))*az+(a(g)*a(i)*b(f)-b(g)*a(f))*aA
bV=-a(i)*ar+b(i)*a(f)*az+b(i)*b(f)*aA
return bH+av,bV+aq,bK+al
end
function o(m,p,s)return((m-p/q)*(1-bn(-q*s))+p*s)/q
end
function br(m,p,s)return(m-p/q)*bn(-q*s)+p/q
end
function aR(m,p)return x.log(1-q*m/p)/q
end
function Y(aX,bp,e,m,p,G,reverse)local c
for c_=1,15 do
c=o(m,p,e)if c*reverse>G*reverse then
bp=e
e=(e+aX)/2
else
aX=e
e=(e+bp)/2
end
end
return e,c
end
function bW(ad,af,P,Z,u,v,w)local bq,bo,h,c,k,bj,aU,aI,V,M
bq=ad*a(af*t*2)-P
bo=ad*b(af*t*2)-Z
h,c,k=at(bq,bo,0,0,0,0,u,v,w)bj,aU,aI=at(0,0,1,0,0,0,u,v,w)ah=h-(bj*k)/aI
ag=c-(aU*k)/aI
V=l(ag,ah)M=X(ah,ag)return M,V
end
function X(h,c)return x.sqrt(h^2+c^2)end
function bz(h,min,max)if h>=max then
h=max
elseif h<=min then
h=min
end
return h
end
function aZ(h,c,k,bP,bT,bQ,s)bA=h+bP*s
bY=c+bT*s
bM=k+bQ*s
return bA,bY,bM
end
function onTick()ac=_(1)-_(7)G=_(2)-_(9)ai=_(3)-_(8)am=_(4)aw=_(5)as=_(6)bi=_(7)bv=_(8)bb=_(9)u=_(10)v=_(11)w=_(12)P=_(13)/60
aV=_(14)/60
Z=_(15)/60
bS=_(16)cb=_(17)bC=_(18)ad=_(19)/60
af=_(20)bF=_(21)bU=_(22)-_(24)/360
Q=_(23)+1
ca=_(24)/360
bO=_(25)/720
bI=_(26)/360
bE=_(27)/360
bL=_(28)bX=_(32)/_(30)bw=_(32)/_(31)bR=R(3)bx=R(5)T=ba
m,q,n,aG=ae[Q][1]/60,ae[Q][2],ae[Q][3],ae[Q][4]if R(1)and R(2)then
ac,G,ai=aZ(ac,G,ai,am,aw,as,_(29))bh,aT,bZ=at(P,Z,aV,0,0,0,u,v,w)bf=X(bh,aT)bg=l(aT,bh)M,V=bW(ad,af,P,Z,u,v,w)S,N,H=ac,G,ai
aS=0
for c_=1,15 do
aP=X(S,N)r=l(N,S)j=l(aP,H)for K=1,2 do
for cd=1,30 do
z=aP*b(l(N,S)-r)ah=M*a(V-r)ag=M*b(V-r)bN,O=-ah*aG/60,-ag*aG/60
bD=bf*a(bg-r)U=m*b(j)+bf*b(bg-r)I=m*a(j)+bZ
if Q==8 then
aj=aY*b(j)+O
aM=aY*a(j)-y
ab=o(U,aj,60)aD=o(I,aM,60)bt=br(U,aj,60)aK=br(I,aM,60)if K<2 then
if ab>z then
e,c=Y(0,n*2,n,U,aj,z,1)k=o(I,aM,e)else
W,c=Y(0,n*2,n,bt,O,z-ab,1)c=c+ab
k=o(aK,-y,W)+aD
e=60+W
end
else
ap=aR(aK,-y)W,k=Y(ap,n*2,n,aK,-y,H-aD,-1)c=o(bt,O,W)+ab
k=k+aD
e=60+W
end
else
if K<2 then
e,c=Y(0,n*2,n,U,O,z,1)k=o(I,-y,e)else
ap=aR(I,-y)e,k=Y(ap,n*2,n,I,-y,H,-1)c=o(U,O,e)end
end
h=o(bD,bN,e)d(28,h)d(29,c)d(30,k)if(ak(H-k)<.1 and K<2)or(ak(z-c)<.1 and K>1)then
break
end
r=l(N,S)-l(c,h)if K>1 then
if c<z then
bm=j
j=(j+aB)/2
else
aB=j
j=(j+bm)/2
end
else
j=j+l(z,H)-l(c,k)end
end
T=e<n
if R(4)and K<2 and T then
aB=bz(j,t/9,t/2)bm=t/2
j=t/4+aB/2
else
break
end
end
S,N,H=aZ(ac,G,ai,am,aw,as,e)if ak(aS-e)<.01 then
break
end
aS=e
end
aE,aN,bd=b_(_(1),_(2),_(3),bi,bv,bb,u,v,w)bJ,bG,by=b_(am,aw,as,0,0,0,u,v,w)bc,bl,bB=aE+bJ-P,aN+bG-Z,bd+by-aV
aQ=l(X(bc,bl),bB)-l(X(aE,aN),bd)be=l(bl,bc)-l(aN,aE)else
r,j=0,0
T=ba
aQ,be=0,0
end
if not T then
e=0
end
aC(1,T)aC(2,bR)aC(3,bx)d(1,bi)d(2,bv)d(3,bb)d(4,u)d(5,v)d(6,w)d(7,bS)d(8,cb)d(9,bC)d(10,bF)d(11,bU)d(12,ca)d(13,bI)d(14,bE)d(15,bO)d(16,bX)d(17,bw)d(18,bL)d(19,aQ)d(20,be)d(30,e)d(31,j)d(32,r)end
