cl=":"
ck="WP"
cj="%d"
ci="%02.0f"

ai=.05
V=.5
s=360
bA=tostring
aH=false
bd=property
bm=output
bq=input
Q=math
M=screen
aL=M.drawRect
Z=M.drawRectF
E=string.format
B=M.drawText
b_=M.drawCircle
bu=Q.abs
k=Q.floor
A=M.drawLine
bc=Q.tan
bh=Q.sqrt
c=Q.sin
b=Q.cos
aS=Q.atan
bB=M.setColor
R=Q.pi
p=bq.getNumber
ch=bq.getBool
bt=bm.setNumber
cg=bm.setBool
aF=bd.getNumber
t=bd.getBool
I=R*2
ba=(58/s)*I
function N()bB(0,255,0)end
function U()bB(0,0,0)end
function aM(d,r)if d>=0 then
aR=aS(r/d)elseif r>=0 then
aR=aS(r/d)+R
else
aR=aS(r/d)-R
end
return aR
end
function aI(d,min,max)if d>=max then
d=max
elseif d<=min then
d=min
end
return d
end
function F(l,n,m,az,ay,at,e,h,f)local C,G,af,ag,ab,ac,aa,x,o,q,D,aE,d,H,r,aC
l=l-az
n=n-at
m=m-ay
C=b(f)*b(h)G=b(f)*c(h)*c(e)-c(f)*b(e)af=b(f)*c(h)*b(e)+c(f)*c(e)ag=l
ab=c(f)*b(h)ac=c(f)*c(h)*c(e)+b(f)*b(e)aa=c(f)*c(h)*b(e)-b(f)*c(e)x=m
o=-c(h)q=b(h)*c(e)D=b(h)*b(e)aE=n
aC=((C*ac-G*ab)*D+(af*ab-C*aa)*q+(G*aa-af*ac)*o)d=0
r=0
H=0
if aC~=0 then
d=((G*aa-af*ac)*aE+(ag*ac-G*x)*D+(af*x-ag*aa)*q)/aC
r=-((C*aa-af*ab)*aE+(ag*ab-C*x)*D+(af*x-ag*aa)*o)/aC
H=((C*ac-G*ab)*aE+(ag*ab-C*x)*q+(G*x-ag*ac)*o)/aC
end
return d,H,r
end
function aj(i,g,j,az,ay,at,e,h,f)local be,bv,bb
be=b(f)*b(h)*i+(b(f)*c(h)*c(e)-c(f)*b(e))*j+(b(f)*c(h)*b(e)+c(f)*c(e))*g
bv=c(f)*b(h)*i+(c(f)*c(h)*c(e)+b(f)*b(e))*j+(c(f)*c(h)*b(e)-b(f)*c(e))*g
bb=-c(h)*i+b(h)*c(e)*j+b(h)*b(e)*g
return be+az,bb+at,bv+ay
end
function bO(d,r,H,aA)local y,u
y=aM(bh(d^2+r^2),H)u=aM(r,d)O=bh(d^2+r^2+H^2)if aA then
return y,u,O
else
return y/(R*2),u/(R*2),O
end
end
function bl(y,u,O,aA)local d,r,H
if not aA then
y=y*R*2
u=u*R*2
end
d=O*b(y)*c(u)r=O*b(y)*b(u)H=O*c(y)return d,r,H
end
function ca(y,u,O,aA)local d,r,H
if not aA then
y=y*R*2
u=u*R*2
end
d=O*c(u)r=O*b(u)*b(y)H=O*b(u)*c(y)return d,r,H
end
function ad(i,g,j)local J,K,L
J=S/2+(i/g)*(x/2)/bc(ba/2)K=x/2-(j/g)*(x/2)/bc(ba/2)L=g>0
return J,K,L
end
function aX(l,n,m,e,h,f)local i,g,j,J,K,L
i,g,j=F(l,n,m,0,0,0,e,h,f)i,g,j=F(i,g,j,0,0,0,-W,X,0)J,K,L=ad(i,g,j)return J,K,L
end
function aJ(y,u,aP,aO,aV)local l,n,m,J,K,L
l,n,m=bl(y,u,1,aH)l,n,m=F(l,n,m,0,0,0,aP,aO,aV)J,K,L=aX(l,n,m,e,h,f)return J,K,L
end
function aD(y,u,aP,aO,aV)local l,n,m,J,K,L
l,n,m=ca(y,u,1,aH)l,n,m=F(l,n,m,0,0,0,aP,aO,aV)J,K,L=aX(l,n,m,e,h,f)return J,K,L
end
function ce(_,a,v,z)local C,G,ar
C=aI((a-z)/(_-v),-1000,1000)G=a-C*_
ar=2*b(aM(v-_,z-a))for d=_,v-ar,ar*2 do
if al(d,C*d+G)then
A(d,C*d+G,d+ar,C*(d+ar)+G)end
end
end
function al(d,r)return d>=0 and d<=S and r>=0 and r<=x
end
function aU(bQ,bR)return#bA(k(bQ*bR+V))end
function onTick()do
au=aF("Speed Units")aN=aF("Altitude Units")bf=aF("Distance Units")bp=t("air speed")by=t("ground speed")av=t("main speed")cb=t("air altitude")bS=t("ground altitude")bV=t("magnetic heading")bs=t("Pitch ladder")bG=t("Bank angle indicator")bF=t("horizon line")bi=t("Aircraft symbol (w)")aZ=t("Velocity vector symbol")bk=t("Velocity vector for helicopter")cd=t("If high speed, hide vector (heli)")bX=t("laser direction")bD=t("waypoint marker")bM=t("waypoint marker label")c_=t("waypoint marker distance")bL=t("waypoint distance")bZ=t("waypoint arrival time")aY=k(aF("Minimum angle of pitch ladder"))end
do
ae=aU(500,au)ah=aU(30000,aN)aw=aI(aU(150000,bf),3,100)az,ay,at=p(1),p(2),p(3)e,h,f=p(4),p(5),p(6)bo,bK,bn=p(7),p(8),p(11)bT=p(21)*aN
bJ=p(2)*aN
as=p(13)*au
bg=p(20)*au
P=p(17)*I
X=p(9)*I
W=p(10)*I
bP=p(22)bC=p(23)bW=p(24)aT=p(25)*bf
ak=p(26)bN=p(27)==1
bI=p(28)==1
end
if bX then
i,g,j=F(0,0,-1,0,0,0,e,h,f)i,g,j=F(i,g,j,0,0,0,I/4,0,0)bE,bH,cf=bO(i,g,j,aH)bt(1,bH*8)bt(2,bE*8)end
end
function onDraw()S=M.getWidth()x=M.getHeight()N()if bi or bk then
i,g,j=F(0,1,0,0,0,0,-W,X,0)_,a,w=ad(i,g,j)if w then
A(_,a,_+3,a+4)A(_,a,_-3,a+4)A(_+3,a+4,_+6,a)A(_-3,a+4,_-6,a)A(_+6,a,_+11,a)A(_-6,a,_-11,a)end
end
if aZ and bu(as/au)>ai then
i,g,j=F(bo,bn,bK,0,0,0,-W,X,0)_,a,w=ad(i,g,j)if w then
b_(_,a,3)A(_+3,a,_+10,a)A(_-3,a,_-10,a)A(_,a-3,_,a-8)end
end
if bk and bu(as/au)>ai and not(cd and as>30)then
i,g,j=F(0,1,0,0,0,0,-W,X,0)_,a,w=ad(i,g,j)v,z=aI(bo,-30,30),aI(-bn,-30,30)if w then
A(_,a,_+v,a+z)end
end
if bF or aZ then
local bj=5
if not bi then
bj=0
end
for o=bj,180,45 do
for q=-1,1,2 do
_,a,w=aJ(0,q*o/s,0,P,0)v,z,ax=aJ(0,q*(o+45)/s,0,P,0)if w and ax then
A(_,a,v,z)end
end
end
elseif bs then
for q=-1,1,2 do
_,a,w=aJ(0,q*5/s,0,P,0)v,z,ax=aJ(0,q*15/s,0,P,0)if w and ax then
A(_,a,v,z)end
end
end
if bs then
for o=aY,175,aY do
for q=-1,1,2 do
for D=-1,1,2 do
_,a,w=aD(D*o/s,q*12/s,0,P,0)v,z,ax=aD(D*o/s,q*5/s,0,P,0)ao,an,bY=aD(D*(o-1)/s,q*12/s,0,P,0)aG,aK,cc=aD(D*o/s,q*16/s,0,P,0)if w and ax and bY and cc then
if al(_,a)or al(v,z)then
if D==1 then
A(_,a,v,z)else
ce(v,z,_,a)end
end
if al(_,a)or al(ao,an)then
A(_,a,ao,an)end
if al(aG,aK)then
B(aG-2.5*#bA(D*o),aK-3,D*o)end
end
end
end
end
end
if bV then
l,n,m=aj(0,1,0,0,0,0,-W,X,0)l,n,m=aj(l,n,m,0,0,0,e,h,f)aQ=aM(n,l)/I
l,n,m=aj(0,0,1,0,0,0,-W,X,0)l,n,m=aj(l,n,m,0,0,0,e,h,f)if m>0 then
q=1
else
q=-1
end
for o=0,q*355,q*5 do
i,g,j=bl(19.5/s,o/s-q*aQ,1,aH)_,a,w=ad(i,g,j)if w then
A(_,a+2,_,a-2)if o%10==0 then
B(_-4,a-7,E("%02d",q*o/10))end
end
end
_=k(S/2)aQ=E("%03.0f",s*((-P/I)%1))U()Z(_-10,9,20,11)N()aL(_-9,10,17,8)M.drawTextBox(_-8,11,16,7,aQ,0,0)end
if bG then
l,n,m=aj(1,0,0,0,0,0,e,h,f)l,n,m=aj(l,n,m,0,0,0,0,P,0)T=Q.acos(l)T=m>0 and T or-T
i,g,j=F(0,1,0,0,0,0,-W,X,0)_,a,w=ad(i,g,j)v,z=_+50*c(-T),a+50*b(-T)ao,an=_+45*c(-T+ai),a+45*b(-T+ai)aG,aK=_+45*c(-T-ai),a+45*b(-T-ai)if w then
M.drawTriangle(v,z,ao,an,aG,aK)end
for o=-50,50,10 do
v,z=_+51*c(I*o/s),a+51*b(I*o/s)ao,an=_+56*c(I*o/s),a+56*b(I*o/s)if w then
if o==0 then
B(v-1,z+1,"0")else
A(v,z,ao,an)end
end
end
end
if bN then
i,g,j=F(bP,bC,bW,az,ay,at,e,h,f)i,g,j=F(i,g,j,0,0,0,-W,X,0)if aT>=10 then
aB=E("%.0f",k(aT+V))else
aB=E("%.1f",k(aT*10+V)/10)end
if bD then
_,a,w=ad(i,g,j)_=k(_)a=k(a)if w then
N()b_(_,a,5)if bM then
B(_-4,a-11,ck)end
if c_ then
B(_+1-2.5*#aB,a+7,aB)end
end
end
if bL then
_,a=k(S/5),k(3*x/5)U()Z(_-5-5*aw,a,13+5*aw,7)N()B(_-4-5*aw,a+1,ck)B(_+8-5*#aB,a+1,aB)end
if bZ then
_,a=k(S/5),k(3*x/5)bU=E(cj,k(ak/3600))bw=E(ci,k(ak%60+V))if ak<3600 then
aW=E(cj,k((ak/60)%60))am=aW..cl..bw
elseif ak>=36000 then
am="-:--:--"
else
aW=E(ci,k((ak/60)%60))am=bU..cl..aW..cl..bw
end
U()Z(_+7-5*#am,a+7,5*#am+1,7)N()B(_+8-5*#am,a+8,am)end
end
if bI then
_,a=k(S/5),k(3*x/5)U()Z(_-5-5*aw,a-7,11,7)N()B(_-4-5*aw,a-6,"AP")end
if av then
bz=as
br=bg
bx="AS"
else
bz=bg
br=as
bx="GS"
end
if(av and by)or(not av and bp)then
_,a=k(S/5),k(x/3)ap=E(cj,k(bz+V))U()Z(_+5-5*ae,a,5*ae+5,11)N()aL(_+6-5*ae,a+1,5*ae+2,8)B(_+8-5*#ap,a+3,ap)end
if(av and bp)or(not av and by)then
ap=E(cj,k(br+V))U()Z(_-5-5*ae,a+10,5*ae+13,7)N()B(_-4-5*ae,a+11,bx)B(_+8-5*#ap,a+11,ap)end
if cb then
_,a=k(4*S/5),k(x/3)aq=E(cj,k(bJ+V))Y=2*ah
U()Z(_-Y,a,5+5*ah,11)N()aL(_+1-Y,a+1,2+5*ah,8)B(_+3+1.5*Y-5*#aq,a+3,aq)end
if bS then
_,a=k(4*S/5),k(2*x/3)aq=E(cj,k(bT+V))Y=2*ah
U()Z(_-5-Y,a,15+5*ah,11)N()B(_-4-Y,a+3,"AG")aL(_+6-Y,a+1,2+5*ah,8)B(_+8+1.5*Y-5*#aq,a+3,aq)end
end
