eZ="x (m)"
eY="y (m)"
eX="z (m)"

L=360
aA=.01
b_=.1
bc=600
dj=true
ak=false
dw=property
cZ=output
dD=input
Q=math
R=table.unpack
cq=Q.acos
n=Q.atan
h=Q.abs
ci=Q.exp
m=Q.sin
r=Q.cos
ay=Q.sqrt
d=dD.getNumber
bz=dD.getBool
O=cZ.setNumber
dX=cZ.setBool
l=dw.getNumber
cT=dw.getBool
w=Q.pi*2
T=30/3600
dm=bc/3600
eW=60
q=0
eh=0
dT=7.45
cW=.28
aJ=8
aN=0
aM=20
dn=500
dV=ay(240*dn)db=8
bO=b_
cw=.001
cg=10000
cR=2
bI={{bc,.0005,2400,.105},{700,.001,2400,.11},{800,.002,2400,.12},{900,.005,bc,.125},{1000,aA,300,.13},{1000,.02,150,.135},{800,.025,120,.15},{50,.003,3600,.125}}do
function cD(V,cJ,bn,bK)bn={}for ai=1,#V do
bn[ai]={}for aF=1,#cJ[1]do
bK=0
for ca=1,#V[1]do
bK=bK+V[ai][ca]*cJ[ca][aF]end
bn[ai][aF]=bK
end
end
return bn
end
function dc(A,C,z)local k,c,u,t,B,y=r(A),m(A),r(C),m(C),r(z),m(z)return{{B*u,B*t*k+y*c,B*t*c-y*k},{-t,u*k,u*c},{y*u,y*t*k-B*c,y*t*c+B*k}}end
function aX(cx,bY,cj,aL,aH,aV,A,C,z)local bV=cD(dc(A,C,z),{{cx},{bY},{cj}})return bV[1][1]+aL,bV[2][1]+aV,bV[3][1]+aH
end
function be(an,ag,aT,aL,aH,aV,A,C,z)local bT=cD({{an-aL,ag-aV,aT-aH}},dc(A,C,z))return bT[1][1],bT[1][2],bT[1][3]end
function cp(b)return 30*ci(-1/60*b/1000)/3600
end
function ch(b)return b>=40000 and 0 or(((44.33-b/1000)/11.89)^5.256)/1013
end
function bJ(dM,aq,k,j,exp)return((aq-k/x)*(1-exp)+k*j)/x+dM,(aq-k/x)*exp+k/x
end
function aY(b,_)local exp,g,T,as,av,az,aC
local H={}exp=ci(-x*b)g=bJ(_[3],_[6],_[9],b/2,ci(-x*b/2))T,as=cp(g),ch(g)av=_[7]-bA*as*dy/60
az=_[8]-bB*as*dy/60
aC=_[9]-T
H[1],H[4]=bJ(_[1],_[4],av,b,exp)H[2],H[5]=bJ(_[2],_[5],az,b,exp)H[3],H[6]=bJ(_[3],_[6],aC,b,exp)H[7],H[8],H[9]=_[7],_[8],_[9]b=aS(dn/h(H[6]),30,dV)return b,H
end
function ba(k,c,aj,s,y,cE,Z)local u,aa,B,t,X,ab,bg,M,bE
u,aa=k,aj
B=c-k
t=B
for ai=1,cE do
if aj*s>0 then
k=u
aj=aa
t=c-u
B=t
end
if h(aj)<h(s)then
k,c,u=c,u,c
aj,s,aa=s,aa,s
end
X=(k-c)/2
ab=s/aa
if h(aa)<h(s)then
t,B=X,X
else
if k==u then
bg=2*X*ab
M=1-ab
else
M=aa/aj
bE=s/aj
bg=ab*(2*X*M*(M-bE)-(c-u)*(bE-1))M=(M-1)*(bE-1)*(ab-1)end
ab,B=B,t
if h(2*bg)<h(3*X*M)and h(bg)<h(ab*M/2)then
t=-bg/M
else
t,B=X,X
end
end
c,u=c+t,c
aa=s
s=y(c)if h(s)<Z or ai==cE then
return c
end
end
end
function dz(a,ct,y,dG,bR)local dd=y-dG
if h(y)>h(dG)*1.1 then
bi=(ct+a)/2
elseif(h(dd)<bR*b_ or a==ct)and h(y)>bR then
bi=a+.001
elseif h(y)<bR then
bi=a
else
bi=a-y*(a-ct)/dd
end
return bi
end
function dU(bN,bu,ce,bU,A,C,z)local cI,dv,a,f,g,ds,dC,c_,aE,ah
cI=bN*m(bu*w)-ce
dv=bN*r(bu*w)-bU
a,f,g=aX(cI,dv,0,0,0,0,A,C,z)ds,dC,c_=aX(0,0,1,0,0,0,A,C,z)bA=a-(ds*g)/c_
bB=f-(dC*g)/c_
aE=n(bA,bB)ah=co(bA,bB)return ah,aE
end
function co(a,f)return ay(a*a+f*f)end
function aS(a,min,max)if a>=max then
a=max
elseif a<=min then
a=min
end
return a
end
function ar(j,a,f,g,dg,da,dp,av,az,aC)return av*j*j/2+dg*j+a,az*j*j/2+da*j+f,aC*j*j/2+dp*j+g,av*j+dg,az*j+da,aC*j+dp,av,az,aC
end
dE=0
du=0
dA=0
dH=0
function dt(aJ,aN,aM,e_,dZ,cP,eg,min,max)local Z,aU,ck,o
Z=e_-dZ
aU=cP+Z
ck=Z-eg
o=aJ*Z+aN*aU+aM*ck
if o>max or o<min then
aU=cP
o=aJ*Z+aN*aU+aM*ck
end
return aS(o,min,max),aU,Z
end
function N(a)return(a+.5)%1-.5
end
function cV(o,cK,min,max)if cK>=max then
if o>0 then
o=0
end
o=o-aA
elseif cK<=min then
if o<0 then
o=0
end
o=o+aA
end
return o
end
by=b_
function cr(a,f,g,dx,d_,df,q)local dF,dk,de,bx,j
j=0
while j<=q do
dF,dk,de=f*df-g*d_,g*dx-a*df,a*d_-f*dx
a,f,g=a+dF*by,f+dk*by,g+de*by
bx=ay(a*a+f*f+g*g)a,f,g=a/bx,f/bx,g/bx
j=j+by
end
return a,f,g
end
function dR(aL,aH,aV,A,C,z,ce,dO,bU,dJ,ej,ey,bM,bq,bG,ao,ap,af)local cd,cn,cl,bj,bh,aI,aK,dh,cN,cO,dl,cF,dq
bh,aI,aK=be(bM,bq,bG,aL,aH,aV,A,C,z)dh,cN,cO=be(ao,ap,af,0,0,0,A,C,z)dl,cF,dq=be(dJ,ey,ej,0,0,0,A,C,z)cd,cn,cl=dh-ce,cN-bU,cO-dO
bj=bh*bh+aI*aI+aK*aK
return-(aI*cl-aK*cn)/bj-dl,-(aK*cd-bh*cl)/bj-cF,-(bh*cn-aI*cd)/bj-dq
end
function aR(a,f,g,eF)local E,D
E=n(g,ay(a*a+f*f))D=n(a,f)if eF then
return E,D
else
return E/(w),D/(w)end
end
function bC(an,ag,aT,i)local cB=co(an,ag)return cB*m(n(an,ag)-i),cB*r(n(an,ag)-i),aT
end
end
function onTick()do
bM=d(3)bq=d(4)bG=d(5)ao=d(6)ap=d(7)af=d(8)bQ=d(9)bW=d(10)cb=d(11)aB=d(12)aw=d(13)ax=d(14)bX=d(15)/60
cS=d(16)/60
cs=d(17)/60
eP=d(18)*w/60
eK=d(19)*w/60
ez=d(20)*w/60
at=d(21)K=d(22)au=d(23)eO=d(24)eG=d(25)dI=d(26)bN=d(27)/60
bu=d(28)bf=" (degree)"
aP=l("Weapon Type")+1
bH=l("standby yaw position"..bf)/L
bv=l("min pitch"..bf)/L
bF=l("max pitch"..bf)/L
bS=cT("Pitch Swivel Mode")bw=l("min yaw"..bf)/L
bt=l("max yaw"..bf)/L
bs=cT("Yaw Swivel Mode")bm=l("Pivot rotation speed gain")aG=l("Pitch gear ratio (1 : ?)")/l("Types of Pitch PIVOT")aZ=l("Yaw gear ratio (1 : ?)")/l("Types of Yaw PIVOT")ad="Turret phy. offset "
eN=l(ad..eZ)dN=l(ad..eY)et=l(ad..eX)ad="Muzzle offset "
ee=l(ad..eZ)ef=l(ad..eY)ep=l(ad..eX)ev=bz(1)dQ=bz(9)P=bz(10)cG=bz(11)end
cm=ak
do
an,ag,aT=aX(0,1,0,0,0,0,eO,eG,dI)cx,bY,cj=be(an,ag,aT,0,0,0,aB,aw,ax)bd,W=aR(cx,bY,cj,ak)W=W-bH
end
if ev and dQ then
aq,x,cA,dy=bI[aP][1]/60,bI[aP][2],bI[aP][3],bI[aP][4]cc=aP==8
at,au,K=aX(eN,dN,et,at,K,au,aB,aw,ax)ae,ac,al=bM-at,bq-au,bG-K
ae,ac,al,ao,ap,af=ar(eh,ae,ac,al,ao,ap,af,bQ,bW,cb)cQ,cU,dK=aX(bX,cs,cS,0,0,0,aB,aw,ax)dB=co(cQ,cU)cX=n(cQ,cU)ah,aE=dU(bN,bu,bX,cs,aB,aw,ax)T,as=cp(K),ch(K)ah=ah/as
do
q=ay(ae*ae+ac*ac+al*al)/(aq+(cc and bc or 0))eC,eH,eT=ar(q,ae,ac,al,ao,ap,af,bQ,bW,cb)i=n(eC,eH)eR,Y,cf=bC(ae,ac,al,i)do
local J,V
J=aq+(cc and bc/60 or 0)V=-Y*T/J
U=cq(x*Y/ay(V*V+J*J))+n(V,J)function v(c)return Y*(J*m(c)+T/x)/J/r(c)+T*Q.log(1-x*Y/J/r(c))/(x*x)-cf
end
cH=ba(U,n(cf,Y),v(U),v(n(cf,Y)),v,10,(b_/L)*w)cY=ba(U,cq(x*Y/J)-.001,v(U),v(cq(x*Y/J)-.001),v,10,(b_/L)*w)U=(cH+cY)/2
end
p=P and cY or cH
end
cv=0
for aF=1,db do
dL=aF
for ai=1,db do
cv=cv+1
eb,eD,dY=bC(ae,ac,al,i)eo,eL,ea=bC(ao,ap,af,i)eI,dP,eE=bC(bQ,bW,cb,i)am={eb,eD,dY,eo,eL,ea,eI,dP,eE}e={R(am)}bk={R(am)}bA=ah*m(aE-i)bB=ah*r(aE-i)es=dB*m(cX-i)eJ=aq*r(p)+dB*r(cX-i)eB=aq*m(p)+dK
T,as=cp(K),ch(K)_={ee,ef,ep,es,eJ,eB,0,0,0}ew=dm*r(p)eM=dm*m(p)local b,S=60,_
q=0
bb=ak
if cc then
_[8]=ew
_[9]=eM
local function v(c)e={ar(c,R(am))}local dW,dr=aY(c,S)return dr[2]-e[2],dW,dr
end
s,b,_=v(60)e={ar(60,R(am))}bb=s>0 and not P
if bb then
b=ba(0,60,-am[2],s,v,10,aA)aW,b,_=v(b)end
_[8]=0
_[9]=0
q,S=b,_
bk={R(e)}end
for ca=1,40 do
if bb or q>cA then
break
end
e={ar(q+b,R(am))}en,_=aY(b,_)function v(c)e={ar(q+c,R(am))}aW,_=aY(c,S)return P and(_[3]-e[3])or(_[2]-e[2])end
if P and _[3]<e[3]and _[6]<0 then
b=ba(0,b,S[3]-bk[3],_[3]-e[3],v,10,aA)aW,_=aY(b,S)bb=dj
elseif not P and _[2]>e[2]then
b=ba(0,b,S[2]-bk[2],_[2]-e[2],v,10,aA)aW,_=aY(b,S)bb=dj
end
q=q+b
b=en
S={R(_)}bk={R(e)}end
do
local cy,ei=P and U or-w/4,P and(w/2-U)or U
aQ=P and(e[2]-_[2])or(e[3]-_[3])if h(aQ)<bO then
break
end
if ai==1 then
if P then
if aQ>0 then
bL=(p+cy)/2
else
bL=w/4-(e[2]/_[2])*(w/4-p)end
else
bL=p+n(e[3],e[2])-n(_[3],_[2])end
else
bL=dz(p,eA,aQ,eu,bO)end
eA=p
eu=aQ
p=aS(bL,cy,ei)end
end
do
bl=n(e[1],e[2])-n(_[1],_[2])eU=h(e[1]-_[1])if h(bl)<cw then
break
end
if aF==1 then
cz=i+n(e[1],e[2])-n(_[1],_[2])else
cz=dz(i,el,bl,eq,cw)end
el=i
eq=bl
i=cz
end
end
cm=q<cA and bl<cw and h(aQ)<bO
O(21,cv)O(22,dL)else
i,p=0,0
eV,eS=0,0
end
if cm then
ed,dS,em=at+cg*r(p)*m(i),au+cg*r(p)*r(i),K+cg*m(p)F,I,G=be(ed,dS,em,at,K,au,aB,aw,ax)bp,br=aR(F,I,G,ak)bZ,cu,bP=dR(at,K,au,aB,aw,ax,bX,cS,cs,eP,eK,ez,bM,bq,bG,ao,ap,af)F,I,G=cr(F,I,G,bZ,cu,bP,dT)bo,aD=aR(F,I,G,ak)aD=N(aD-bH)F,I,G=cr(F,I,G,bZ,cu,bP,-aG*cW)bD,aW=aR(F,I,G,ak)F,I,G=cr(F,I,G,bZ,cu,bP,-aZ*cW)aW,aO=aR(F,I,G,ak)aO=N(aO-bH)if cG then
bo=0
bD=0
end
else
bo,aD=0,0
bD,aO=0,0
F,I,G=0,1,0
bp,br=0,0
q=0
end
do
er=N(W)>bw and N(W)<bt and bd>bv and bd<bF
cL=m(bp)>m(bv)and m(bp)<m(bF)cM=br>bw and br<bt
cC=h(N(bp-bd))*L
di=h(N(br-bH-W))*L
ek=cC<cR and di<cR
ex=cm and ek and er and cL and cM and not cG
end
do
if not cL and bS then
bo=0
end
if not cM and bs then
aD=0
end
eQ=bo-bd
ec=bs and(aD-W)or N(aD-W)E,du,dE=dt(aJ,aN,aM,0,-eQ*aG,du,dE,-aG*bm,aG*bm)D,dH,dA=dt(aJ,aN,aM,0,-ec*aZ,dH,dA,-aZ*bm,aZ*bm)if bS then
E=cV(E,N(bd),bv,bF)end
if bs then
D=cV(D,N(W),bw,bt)end
if aG<0 then
E=bS and aS(bD,bv,bF)*4 or bD*4
end
if aZ<0 then
D=bs and aS(aO,bw,bt)*4 or aO*4
end
E=(E~=E)and 0 or E
D=(D~=D)and 0 or D
end
O(1,E)O(2,D)dX(1,ex)O(3,cC)O(4,di)O(30,q)O(31,p)O(32,i)end
