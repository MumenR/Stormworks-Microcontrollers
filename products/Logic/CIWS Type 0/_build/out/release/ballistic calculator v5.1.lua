fw="x (m)"
fv="y (m)"
fu="z (m)"

A=360
ba=.01
bb=.1
bo=1000
bl=600
aq=false
ek=property
de=output
dv=input
I=math
cP=I.acos
bO=I.exp
cs=I.abs
x=I.atan
g=I.sin
i=I.cos
aY=I.sqrt
b=dv.getNumber
cl=dv.getBool
as=de.setNumber
db=de.setBool
d=ek.getNumber
cV=ek.getBool
J=I.pi*2
G=30/3600
er=bl/3600
fs=60
h=0
eB=0
ep=7.5
et=9.5
dD=8
dY=0
di=15
eS=1
fb=.05
fo=1
cm=2000
cp=60*(cm/bo)dg=aY(240*cm)eX=I.floor(3600/cp)dh=8
ef=bb
dH=bb
bH=10000
ea=2
bx={{bl,.0005,2400,.105},{700,.001,2400,.11},{800,.002,2400,.12},{900,.005,bl,.125},{bo,ba,300,.13},{bo,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}do
function dE(ay,el,cj,bA)cj={}for bk=1,#ay do
cj[bk]={}for dN=1,#el[1]do
bA=0
for cz=1,#ay[1]do
bA=bA+ay[bk][cz]*el[cz][dN]end
cj[bk][dN]=bA
end
end
return cj
end
function dP(r,q,o)local v,_,j,n,t,p=i(r),g(r),i(q),g(q),i(o),g(o)return{{t*j,t*n*v+p*_,t*n*_-p*v},{-n,j*v,j*_},{p*j,p*n*v-t*_,p*n*_+t*v}}end
function bg(au,am,az,aX,aM,aU,r,q,o)local cS=dE(dP(r,q,o),{{au},{am},{az}})return cS[1][1]+aX,cS[2][1]+aU,cS[3][1]+aM
end
function ao(aJ,aE,bt,aX,aM,aU,r,q,o)local cW=dE({{aJ-aX,aE-aU,bt-aM}},dP(r,q,o))return cW[1][1],cW[1][2],cW[1][3]end
function aD(eL,_,l,v,B,ei,cD)local bi,u,j,W,ac,t,n,ae,aT,aR,ab,ck,cU
bi=B>0 and B or-B
j,W,ac=v,B,bi
t=_-v
n=t
cU=aq
for bk=1,ei do
u=l>0 and l or-l
if l*B<0 then cU=true end
if u<cD then
return _,u,bk
end
if B*l>0 then
v,B,bi=j,W,ac
n=_-j
t=n
end
if bi<u then
v,_,j=_,j,_
B,l,W=l,W,l
bi,u,ac=u,ac,u
end
if cU then
ae=(v-_)/2
aT=l/W
if ac<u then
n,t=ae,ae
else
if v==j then
aR=2*ae*aT
ab=1-aT
else
ab=W/B
ck=l/B
aR=aT*(2*ae*ab*(ab-ck)-(_-j)*(ck-1))ab=(ab-1)*(ck-1)*(aT-1)end
aT,t=t,n
cE=3*ae*ab
if 2*(aR>0 and aR or-aR)<(cE>0 and cE or-cE)then
n=-aR/ab
else
n,t=ae,ae
end
end
j,W,ac=_,l,u
_=_+n
else
bR=l-B
if u>ac*1.1 then
cJ=(j+_)/2
elseif((bR>0 and bR or-bR)<cD*bb or _==j)and u>cD then
cJ=_+.001
else
cJ=_-l*(_-v)/bR
end
W,j,ac=l,_,u
_=cJ
end
l=eL(_)end
return _,u,ei
end
function fk(bJ,bN,cM,cN,r,q,o)local dV,ej,a,f,k,du,eu,ct,bj,an
dV=bJ*g(bN*J)-cM
ej=bJ*i(bN*J)-cN
a,f,k=bg(dV,ej,0,0,0,0,r,q,o)du,eu,ct=bg(0,0,1,0,0,0,r,q,o)bB=a-(du*k)/ct
bE=f-(eu*k)/ct
bj=x(bB,bE)an=bZ(bB,bE)return an,bj
end
function bZ(a,f)return aY(a*a+f*f)end
function cn(a,min,max)if a>=max then
a=max
elseif a<=min then
a=min
end
return a
end
function cR(e,a,f,k,ap,al,D,av,aA,U)return av*e*e/2+ap*e+a,aA*e*e/2+al*e+f,U*e*e/2+D*e+k,av*e+ap,aA*e+al,U*e+D
end
dr,ed=0,0
dM,dy=0,0
dK,dJ=0,0
dW,da=0,0
function cg(aG,aC,aH,eA,eW,cQ,eG,min,max)local ax,bf,cI,m
ax=eA-eW
bf=cs(ax)<5/A and cQ+ax or cQ
cI=ax-eG
m=aG*ax+aC*bf+aH*cI
if m>max or m<min then
bf=cQ
m=aG*ax+aC*bf+aH*cI
end
return cn(m,min,max),bf,ax
end
function X(a)return(a+.5)%1-.5
end
function dt(m,dw,min,max)if dw>=max then
if m>0 then
m=0
end
m=m-ba
elseif dw<=min then
if m<0 then
m=0
end
m=m+ba
end
return m
end
function bD(aX,aM,aU,r,q,o,cM,f_,cN,fi,eP,eN,R,L,N,S,O,K,bu,bc,bp,dz)local bq,bs,bh,dA,dm,ev,dq,dj,df,ai,ag,aw,cH,cT,cO,bC,aP,cos,sin,bQ,en,cZ,dU,br,bm,bn
bq,bs,bh=ao(R,L,N,aX,aM,aU,r,q,o)dA,dm,ev=ao(S,O,K,0,0,0,r,q,o)dq,dj,df=ao(fi,eN,eP,0,0,0,r,q,o)br,bm,bn=ao(bu,bc,bp,aX,aM,aU,r,q,o)cH,cT,cO=dA-cM,dm-cN,ev-f_
bC=bq*bq+bs*bs+bh*bh
ai=(bs*cO-bh*cT)/bC-(-dq)ag=(bh*cH-bq*cO)/bC-(-dj)aw=(bq*cT-bs*cH)/bC-(-df)aP=aY(ai*ai+ag*ag+aw*aw)cos=i(aP*dz)sin=g(aP*dz)/aP
bQ=(ai*br+ag*bm+aw*bn)*(1-cos)/aP/aP
en=cos*br+sin*(ag*bn-aw*bm)+bQ*ai
cZ=cos*bm+sin*(aw*br-ai*bn)+bQ*ag
dU=cos*bn+sin*(ai*bm-ag*br)+bQ*aw
return bX(en,cZ,dU,aq)end
function bX(a,f,k,ex)local co,cy
co=x(k,aY(a*a+f*f))cy=x(a,f)if ex then
return co,cy
else
return co/J,cy/J
end
end
function ch(aJ,aE,bt,z)local dZ,dd=bZ(aJ,aE),x(aJ,aE)-z
return dZ*g(dd),dZ*i(dd),bt
end
function bW(e)local exp,cB,cC,aB,cf
aB=h+e
cf=aB*aB/2
dF=fd*cf+eD*aB+eQ
ca=eI*cf+fh*aB+dp
cw=fn*cf+ez*aB+dO
exp=bO(-c*e)cB=(bv-bw/c)*(c*e-1+exp)/c/c/e+bw*e/2/c+bF+s
cC=eJ*(((44.20-cB/bo)/11.89)^5.256)/60780
G=bO(-cB/60000)/120
av=-bB*cC
aA=cF-bE*cC
U=cc-G
a,ap=((ce-av/c)*(1-exp)+av*e)/c+cu,(ce-av/c)*exp+av/c
f,al=((bP-aA/c)*(1-exp)+aA*e)/c+cv,(bP-aA/c)*exp+aA/c
k,D=((bv-U/c)*(1-exp)+U*e)/c+bF,(bv-U/c)*exp+U/c
Y=cm/(D<0 and-D or D)Y=Y>dg and dg or Y
Y=Y<cp and cp or Y
p=aV and(cw-k)or(f-ca)aF=p>0 and(not aV or D<0)return p,aF
end
function cK(aL)eQ,dp,dO=ch(at,af,ah,aj)eD,fh,ez=ch(S,O,K,aj)fd,eI,fn=ch(bY,c_,bK,aj)bB=an*g(bj-aj)bE=an*i(bj-aj)G=bO(-s/60000)/120
a,f,k=fj,dS*i(ds+aL),dS*g(ds+aL)ap,al,D=ee*g(dL-aj),ci*i(aL)+ee*i(dL-aj),ci*g(aL)+eH
local F=60
h=0
cu,cv,bF,ce,bP,bv=a,f,k,ap,al,D
bw=-G
cF,cc=0,0
cr=-bH
aF=aq
if cx then
cF=er*i(aL)cc=er*g(aL)bw=-G+cc
p,aF=bW(F)if aF then
h,fc,bI=aD(bW,F,p,0,(aV and dp or dO),10,ba)return aV and(ca-f)or(cw-k)end
cr=p
h=h+F
F=Y
cF,cc=0,0
cu,cv,bF,ce,bP,bv=a,f,k,ap,al,D
bw=-G
end
bI=0
for cz=1,eX do
if h>ew then
break
end
p,aF=bW(F)if aF then
F,fc,bI=aD(bW,F,p,0,cr,10,ba)h=h+F
break
end
cr=p
h=h+F
F=Y
cu,cv,bF,ce,bP,bv=a,f,k,ap,al,D
bw=U
end
return aV and(ca-f)or(cw-k)end
function cL(fm)aj=fm
fe=cK(C)dx=C+.001
fq=cK(dx)C,eU,bI=aD(cK,dx,fq,C,fe,dh,ef)return dF-a
end
end
function onTick()do
R=b(3)L=b(4)N=b(5)S=b(6)O=b(7)K=b(8)bY=b(9)c_=b(10)bK=b(11)Q=b(12)M=b(13)P=b(14)aN=b(15)/60
be=b(16)/60
aO=b(17)/60
cd=b(18)*J/60
bG=b(19)*J/60
bL=b(20)*J/60
H=b(21)s=b(22)E=b(23)d_=b(24)dn=b(25)cX=b(26)bJ=b(27)/60
bN=b(28)aK=" (degree)"
aW=d("Weapon Type")aZ=d("standby pitch position"..aK)/A
cq=d("standby yaw position"..aK)/A
bV=d("min pitch"..aK)/A
by=d("max pitch"..aK)/A
dk=cV("Pitch Swivel Mode")bT=d("min yaw"..aK)/A
bS=d("max yaw"..aK)/A
bU=cV("Yaw Swivel Mode")Z=d("Pivot rotation speed gain")cY=d("Pitch gear ratio (1 : ?)")/d("Types of Pitch PIVOT")eh=d("Yaw gear ratio (1 : ?)")/d("Types of Yaw PIVOT")eK=cV("Pivot Control")fp=d("manual P")eC=d("manual I")eV=d("manual D")ar="Turret phy. offset "
eM=d(ar..fw)eY=d(ar..fv)fa=d(ar..fu)ar="Muzzle offset "
fj=d(ar..fw)dl=d(ar..fv)dX=d(ar..fu)dS=bZ(dl,dX)ds=x(dX,dl)eg=cl(1)ec=cl(9)aV=cl(10)eb=cl(11)end
do
bd=aq
h=0
ak,ad=aZ,cq
bz,bM=aZ,cq
aI,b_=aZ,cq
z,C=0,0
end
do
aJ,aE,bt=bg(0,1,0,0,0,0,d_,dn,cX)au,am,az=ao(aJ,aE,bt,0,0,0,Q,M,P)aQ,aa=bX(au,am,az,aq)end
e_,dc,eH=bg(aN,aO,be,0,0,0,Q,M,P)if eg and ec and aW~=9 then
ci,c,ew,eJ=bx[aW][1]/60,bx[aW][2],bx[aW][3],bx[aW][4]cx=aW==8
H,E,s=bg(eM,eY,fa,H,s,E,d_,dn,cX)at,af,ah=R-H,L-E,N-s
at,af,ah,S,O,K=cR(eB,at,af,ah,S,O,K,bY,c_,bK)ee=bZ(e_,dc)dL=x(e_,dc)an,bj=fk(bJ,bN,aN,aO,Q,M,P)an=an/((((44.33-s/bo)/11.89)^5.256)/1013)G=bO(-s/60000)/120
do
h=aY(at*at+af*af+ah*ah)/(ci+(cx and bl or 0))fg,ey,fr=cR(h,at,af,ah,S,O,K,bY,c_,bK)z=x(fg,ey)ft,V,cA=ch(at,af,ah,z)T=ci+(cx and bl/60 or 0)ay=-V*G/T
cb=cP(c*V/aY(ay*ay+T*T))+x(ay,T)function aS(_)return V*(T*g(_)+G/c)/T/i(_)+G*I.log(1-c*V/T/i(_))/(c*c)-cA
end
if not aV then
C=aD(aS,x(cA,V),aS(x(cA,V)),cb,aS(cb),10,(bb/A)*J)else
C=aD(aS,cP(c*V/T)-.001,aS(cP(c*V/T)-.001),cb,aS(cb),10,(bb/A)*J)end
end
do
ff=cL(z)eR=C>J/4 and-2 or 2
eq=z+(x(dF,ca)-x(a,f))*eR
z,eF,bI=aD(cL,eq,cL(eq),z,ff,dh,dH)end
bd=h<ew and eF<dH and eU<ef
bu,bc,bp=H+bH*i(C)*g(z),E+bH*i(C)*i(z),s+bH*g(C)au,am,az=ao(bu,bc,bp,H,s,E,Q,M,P)ak,ad=bX(au,am,az,aq)dB,em,eo,dI,dG,dC=cR(h,R,L,N,S,O,K,bY,c_,bK)end
if not bd and eg and ec then
bz,bM=bD(H,s,E,Q,M,P,aN,be,aO,cd,bG,bL,R,L,N,S,O,K,R,L,N,ep)aI,b_=bD(H,s,E,Q,M,P,aN,be,aO,cd,bG,bL,R,L,N,S,O,K,R,L,N,et)au,am,az=ao(R,L,N,H,s,E,Q,M,P)ak,ad=bX(au,am,az,aq)end
do
eT=X(aa)>bT and X(aa)<bS and aQ>bV and aQ<by
eZ=g(ak)>g(bV)and g(ak)<g(by)eE=ad>bT and ad<bS
dT=cs(X(ak-aQ))*A
dQ=cs(X(ad-aa))*A
fl=dT<ea and dQ<ea
eO=bd and fl and eT and eZ and eE and not eb
end
do
if eK then
if bd then
bz,bM=bD(H,s,E,Q,M,P,aN,be,aO,cd,bG,bL,dB,em,eo,dI,dG,dC,bu,bc,bp,ep)aI,b_=bD(H,s,E,Q,M,P,aN,be,aO,cd,bG,bL,dB,em,eo,dI,dG,dC,bu,bc,bp,et)end
if eb then
bz=aZ
aI=aZ
end
cG=bU and(bM-aa)or X(bM-aa)dR,ed,dr=cg(dD,dY,di,bz,aQ,ed,dr,-Z,Z)es,dy,dM=cg(dD,dY,di,0,-cG,dy,dM,-Z,Z)aG,aC,aH=eS,fb,fo
else
aG,aC,aH=fp,eC,eV
dR,es=0,0
aI,b_=ak,ad
end
cG=bU and(ad-aa)or X(ad-aa)w,dK,dJ=cg(aG,aC,aH,ak,aQ,dK,dJ,-Z,Z)y,dW,da=cg(aG,aC,aH,0,-cG,dW,da,-Z,Z)w=dR+w
y=es+y
if dk then
w=dt(w,X(aQ),bV,by)end
if bU then
y=dt(y,X(aa),bT,bS)end
w=w*cY
y=y*eh
if cY<0 then
w=dk and cn(aI,bV,by)*4 or aI*4
end
if eh<0 then
y=bU and cn(b_,bT,bS)*4 or b_*4
end
w=(w~=w)and 0 or w
y=(y~=y)and 0 or y
end
as(1,w)as(2,y)db(1,eO)db(2,bd)as(3,dT)as(4,dQ)as(30,h)as(31,C)as(32,z)end
