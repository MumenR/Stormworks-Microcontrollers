
C=360
at=.01
az=false
bU=property
bR=output
cC=input
v=math
au=v.abs
bi=v.sqrt
ch=v.exp
a=v.sin
b=v.cos
t=v.pi
bb=v.atan
d=cC.getNumber
aD=cC.getBool
H=bR.setNumber
dC=bR.setBool
m=bU.getNumber
cm=bU.getBool
o=0
bs=0
J=30/3600
cE=600/3600
e=0
bC=10000
bQ=2
aH={{600,.0005,2400,.105},{700,.001,2400,.11},{800,.002,2400,.12},{900,.005,600,.125},{1000,at,300,.13},{1000,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}function k(c,_)if c>=0 then
bA=bb(_/c)elseif _>=0 then
bA=bb(_/c)+t
else
bA=bb(_/c)-t
end
return bA
end
function aI(bK,b_,bk,aq,al,ak,h,i,g)bK,b_,bk=bK-aq,b_-ak,bk-al
Y=b(g)*b(i)P=b(g)*a(i)*a(h)-a(g)*b(h)U=b(g)*a(i)*b(h)+a(g)*a(h)N=bK
X=a(g)*b(i)M=a(g)*a(i)*a(h)+b(g)*b(h)K=a(g)*a(i)*b(h)-b(g)*a(h)V=bk
bl=-a(i)by=b(i)*a(h)aS=b(i)*b(h)bu=b_
aP=((Y*M-P*X)*aS+(U*X-Y*K)*by+(P*K-U*M)*bl)cl,cj,cA=0,0,0
if aP~=0 then
cl=((P*K-U*M)*bu+(N*M-P*V)*aS+(U*V-N*K)*by)/aP
cj=-((Y*K-U*X)*bu+(N*X-Y*V)*aS+(U*V-N*K)*bl)/aP
cA=((Y*M-P*X)*bu+(N*X-Y*V)*by+(P*V-N*M)*bl)/aP
end
return cl,cA,cj
end
function aM(bd,bG,aY,aq,al,ak,h,i,g)dI=b(g)*b(i)*bd+(b(g)*a(i)*a(h)-a(g)*b(h))*aY+(b(g)*a(i)*b(h)+a(g)*a(h))*bG
dN=a(g)*b(i)*bd+(a(g)*a(i)*a(h)+b(g)*b(h))*aY+(a(g)*a(i)*b(h)-b(g)*a(h))*bG
db=-a(i)*bd+b(i)*a(h)*aY+b(i)*b(h)*bG
return dI+aq,db+ak,dN+al
end
function x(o,w,n)return((o-w/B)*(1-ch(-B*n))+w*n)/B
end
function cu(o,w,n)return(o-w/B)*ch(-B*n)+w/B
end
function bS(o,w)return v.log(1-B*o/w)/B
end
function ae(cF,cy,e,o,w,u,reverse)local _
for de=1,20 do
_=x(o,w,e)if _*reverse>u*reverse then
cy=e
e=(e+cF)/2
else
cF=e
e=(e+cy)/2
end
end
return e,_
end
function dl(aK,aL,as,ar,A,D,z)local bZ,cM,c,_,f,bV,cs,bD,av,aa
bZ=aK*a(aL*t*2)-as
cM=aK*b(aL*t*2)-ar
c,_,f=aM(bZ,cM,0,0,0,0,A,D,z)bV,cs,bD=aM(0,0,1,0,0,0,A,D,z)aB=c-(bV*f)/bD
aA=_-(cs*f)/bD
av=k(aA,aB)aa=bt(aB,aA)return aa,av
end
function bt(c,_)return bi(c^2+_^2)end
function cz(c,min,max)if c>=max then
c=max
elseif c<=min then
c=min
end
return c
end
function bY(c,_,f,dv,dh,dm,n)cS=c+dv*n
cZ=_+dh*n
dr=f+dm*n
return cS,cZ,dr
end
bN=0
cb=0
bW=0
bO=0
function cq(ao,ay,ah,dt,dM,cg,df,min,max)local L,bf,l
L=dt-dM
aJ=cg+L
bf=L-df
l=ao*L+ay*aJ+ah*bf
if l>max or l<min then
aJ=cg
l=ao*L+ay*aJ+ah*bf
end
return cz(l,min,max),aJ,L
end
function y(c)return(c+.5)%1-.5
end
function ca(l,ct,min,max)if ct>=max then
if l>0 then
l=0
end
l=l-at
elseif ct<=min then
if l<0 then
l=0
end
l=l+at
end
return l
end
aE=at
function cU(c,_,f,cw,c_,cL,e)local cr,cc,co,aR,n
n=0
while n<=e do
cr,cc,co=_*cL-f*c_,f*cw-c*cL,c*c_-_*cw
c,_,f=c+cr*aE,_+cc*aE,f+co*aE
aR=bi(c^2+_^2+f^2)c,_,f=c/aR,_/aR,f/aR
n=n+aE
end
return c,_,f
end
function dd(aq,al,ak,bz,bJ,aT,cp,cd,bM,dy,dJ,d_,dB,dA,dL,cO,dK,dF)local cn,cx,bT,ap,ai,ax,bo,ba,bm,aQ,aG,aC
cn,cx,bT=aI(dy,d_,dJ,0,0,0,bz,bJ,aT)ap,ai,ax=aI(dB,dA,dL,aq,al,ak,bz,bJ,aT)bo,ba,bm=aI(cO,dK,dF,0,0,0,bz,bJ,aT)aQ=k(ax+bm-cd,ai+ba-bM)-k(ax,ai)-cn
aG=k(ap+bo-cp,ax+bm-cd)-k(ap,ax)-cx
aC=k(ai+ba-bM,ap+bo-cp)-k(ai,ap)-bT
return aQ,aG,aC
end
function bP(c,_,f,dk)local q,s
q=k(bi(c^2+_^2),f)s=k(_,c)if dk then
return q,s
else
return q/(t*2),s/(t*2)end
end
function onTick()G=d(1)u=d(2)I=d(3)bF=d(4)aX=d(5)aW=d(6)T=d(7)R=d(8)W=d(9)A=d(10)D=d(11)z=d(12)as=d(13)/60
cv=d(14)/60
ar=d(15)/60
dq=d(16)dp=d(17)dH=d(18)aK=d(19)/60
aL=d(20)af=d(21)E=d(22)ab=m("Weapon Type")+1
bp=m("standby yaw position (degree)")/C
bq=m("min pitch (degree)")/C
bj=m("max pitch (degree)")/C
cD=cm("Pitch Swivel Mode")bc=m("min yaw (degree)")/C
bn=m("max yaw (degree)")/C
bh=cm("Yaw Swivel Mode")E=E-bp
ao=d(23)ay=d(24)ah=d(25)aF=d(26)cR=d(27)dG=d(28)be=m("Pitch gear ratio (1 : ?)")/m("Types of Pitch PIVOT")bw=m("Yaw gear ratio (1 : ?)")/m("Types of Yaw PIVOT")da=m("offset x (m)")dw=m("offset y (m)")cQ=m("offset z (m)")du=aD(1)dc=aD(2)cG=aD(5)am=az
o,B,p,bs=aH[ab][1]/60,aH[ab][2],aH[ab][3],aH[ab][4]T,W,R=aM(da,dw,cQ,T,R,W,A,D,z)G,u,I=G-T,u-W,I-R
if du and dc then
G,u,I=bY(G,u,I,bF,aX,aW,cR)cH,cI,ds=aM(as,ar,cv,0,0,0,A,D,z)cJ=bt(cH,cI)cN=k(cI,cH)aa,av=dl(aK,aL,as,ar,A,D,z)ad,ag,S=G,u,I
cB=0
for de=1,15 do
ce=bt(ad,ag)r=k(ag,ad)j=k(ce,S)for Q=1,2 do
for dE=1,60 do
dz=dE
F=ce*b(k(ag,ad)-r)aB=aa*a(av-r)aA=aa*b(av-r)dn,aj=-aB*bs/60,-aA*bs/60
cT=cJ*a(cN-r)an=o*b(j)+cJ*b(cN-r)O=o*a(j)+ds
if ab==8 then
aU=cE*b(j)+aj
bv=cE*a(j)-J
aN=x(an,aU,60)bI=x(O,bv,60)bX=cu(an,aU,60)bL=cu(O,bv,60)if Q<2 then
if aN>F then
e,_=ae(0,p*2,p,an,aU,F,1)f=x(O,bv,e)else
aw,_=ae(0,p*2,p,bX,aj,F-aN,1)_=_+aN
f=x(bL,-J,aw)+bI
e=60+aw
end
else
bg=bS(bL,-J)aw,f=ae(bg,p*2,p,bL,-J,S-bI,-1)_=x(bX,aj,aw)+aN
f=f+bI
e=60+aw
end
else
if Q<2 then
e,_=ae(0,p*2,p,an,aj,F,1)f=x(O,-J,e)else
bg=bS(O,-J)e,f=ae(bg,p*2,p,O,-J,S,-1)_=x(an,aj,e)end
end
c=x(cT,dn,e)if(au(S-f)<.1 and Q<2)or(au(F-_)<.1 and Q>1)then
break
end
r=k(ag,ad)-k(_,c)if Q>1 then
if _<F then
cf=j
j=(j+aZ)/2
else
aZ=j
j=(j+cf)/2
end
else
j=j+k(F,S)-k(_,f)end
end
am=e<p and dz~=60
if aD(4)and Q<2 and am then
aZ=cz(j,t/9,t/2)cf=t/2
j=t/4+aZ/2
else
break
end
end
ad,ag,S=bY(G,u,I,bF,aX,aW,e)if au(cB-e)<at then
break
end
cB=e
end
else
r,j=0,0
am=az
dP,dO=0,0
end
if am then
dD=T+bC*a(r)di=W+bC*b(r)cV=R+bC*v.tan(j)bB,bE,aV=aI(dD,di,cV,T,R,W,A,D,z)aQ,aG,aC=dd(T,R,W,A,D,z,as,cv,ar,dq,dp,dH,G,u,I,bF,aX,aW)cP,dj,cX=cU(bB,bE,aV,aQ,aG,aC,dG)aO,Z=bP(cP,dj,cX,az)Z=y(Z-bp)if cG then
aO=0
end
else
aO,Z=0,0
bB,bE,aV=0,1,0
br,bx=0,C
e=0
end
bH,ac=bP(bB,bE,aV,az)ac=y(ac-bp)br=au(y(bH-af))*C
bx=au(y(ac-E))*C
dg=y(E)>bc and y(E)<bn and af>bq and af<bj
ck=bH>bq and bH<bj
ci=ac>bc and ac<bn
dx=br<bQ and bx<bQ
cY=am and dx and dg and ck and ci and not cG
if not ck and cD then
aO=0
end
if not ci and bh then
Z=0
end
cW=aO-af
if bh then
cK=Z-E
else
cK=y(Z-E)end
q,cb,bN=cq(ao,ay,ah,0,-cW*be,cb,bN,-be*aF,be*aF)s,bO,bW=cq(ao,ay,ah,0,-cK*bw,bO,bW,-bw*aF,bw*aF)if cD then
q=ca(q,y(af),bq,bj)end
if bh then
s=ca(s,y(E),bc,bn)end
if q~=q then
q=0
end
if s~=s then
s=0
end
H(1,q)H(2,s)dC(1,cY)H(3,br)H(4,bx)H(30,e)H(31,j)H(32,r)end
