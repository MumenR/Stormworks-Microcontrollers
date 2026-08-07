
D=100
ai=180
u=false
aQ=property
bk=output
bp=input
aa=screen
ap=math
bu=ap.floor
bj=ap.abs
aA=aa.drawLine
aj=ap.pi
_=ap.sin
b=ap.cos
f=bp.getNumber
s=bp.getBool
k=bk.setNumber
aT=bk.setBool
a=aQ.getNumber
cP=aQ.getBool
cM=aQ.getText
bN=u
bv=u
q=u
function g(h,min,max)if h>=max then
return max
elseif h<=min then
return min
else
return h
end
end
function bI(at,ac,A,P,T,O,d,e,c)local x,G,E,B,F,w,z,p,o,aC,aM,aJ,h,aS,S,av
at=at-P
ac=ac-O
A=A-T
x=b(c)*b(e)G=b(c)*_(e)*_(d)-_(c)*b(d)E=b(c)*_(e)*b(d)+_(c)*_(d)B=at
F=_(c)*b(e)w=_(c)*_(e)*_(d)+b(c)*b(d)z=_(c)*_(e)*b(d)-b(c)*_(d)p=A
o=-_(e)aC=b(e)*_(d)aM=b(e)*b(d)aJ=ac
av=((x*w-G*F)*aM+(E*F-x*z)*aC+(G*z-E*w)*o)h=0
S=0
aS=0
if av~=0 then
h=((G*z-E*w)*aJ+(B*w-G*p)*aM+(E*p-B*z)*aC)/av
S=-((x*z-E*F)*aJ+(B*F-x*p)*aM+(E*p-B*z)*o)/av
aS=((x*w-G*F)*aJ+(B*F-x*p)*aC+(G*p-B*w)*o)/av
end
return h,aS,S
end
function aN(aq,an,aG,P,T,O,d,e,c)local bs,bl,be
bs=b(c)*b(e)*aq+(b(c)*_(e)*_(d)-_(c)*b(d))*aG+(b(c)*_(e)*b(d)+_(c)*_(d))*an
bl=_(c)*b(e)*aq+(_(c)*_(e)*_(d)+b(c)*b(d))*aG+(_(c)*_(e)*b(d)-b(c)*_(d))*an
be=-_(e)*aq+b(e)*_(d)*aG+b(e)*b(d)*an
return bs+P,be+O,bl+T
end
function bH(U,d,e,c)local at,ac,A=aN(0,0,1,0,0,0,d,e,c)if A<0 then
if U<0 then
U=-.5-U
else
U=.5-U
end
end
return U
end
function cc(h)return(h+.5)%1-.5
end
v,H=0,0
C,I=0,0
L,y=0,0
V,R=0,0
Q,W=0,0
al,as=0,0
ao,ah=0,0
ar,ak=0,0
function l(bw,bC,bL,bQ,cu,bA,bZ,min,max)local Y,aV,ag
Y=bQ-cu
aL=bA+Y
aV=Y-bZ
ag=bw*Y+bC*aL+bL*aV
if ag>max or ag<min then
aL=bA
ag=bw*Y+bC*aL+bL*aV
end
return g(ag,min,max),aL,Y
end
function drawCircle(h,S,ax,ci,cd)for o=ci,cd-10,10 do
local j,i,aB,aK
j,i=ax*b(aj*o/ai),ax*_(aj*o/ai)aB,aK=ax*b(aj*(o+10)/ai),ax*_(aj*(o+10)/ai)aA(h+j,S-i,h+aB,S-aK)end
end
bi=u
bD=u
n=0
function onTick()P,T,O=f(1),f(2),f(3)d,e,c=f(4),f(5),f(6)b_,bJ,bM=f(7),f(9),f(8)cL,cN,bq=aN(b_,bJ,bM,0,0,0,d,e,c)aW=f(13)co,cH,br=bI(f(10),f(12),f(11),0,0,0,d,e,c)aw=f(16)bo=f(15)bn=g(f(18)+f(22),-1,1)bB=g(f(19)+f(23),-1,1)bK=g(f(20)+f(24)+f(27),-1,1)am=g(f(21)+f(25),-1,1)bt=f(26)*.3048
bz=f(28)bc=f(29)bx=f(30)ba=s(1)bm=s(2)aU=s(3)aO=s(4)aY=s(5)cO=s(6)cy=s(7)bU=s(8)cf,cb,bV=a("roll P"),a("roll I"),a("roll D")ch,ck,cr=a("pitch P"),a("pitch I"),a("pitch D")cl,cJ,cE=a("yaw P"),a("yaw I"),a("yaw D")bT,cD,bX=a("collective P"),a("collective I"),a("collective D")cA,ct,cF=a("aileron P"),a("aileron I"),a("aileron D")bb,bf,bO=a("elevator P"),a("elevator I"),a("elevator D")cx,cB,cC=a("rudder P"),a("rudder I"),a("rudder D")c_,cI,cK=a("CTOL AH Pitch P"),a("CTOL AH Pitch I"),a("CTOL AH Pitch D")bY,ce,cn=a("CTOL AH Vz P"),a("CTOL AH Vz I"),a("CTOL AH Vz D")bE,aZ,bg=a("PH P"),a("PH I"),a("PH D")cz,cg,cq=a("RH P"),a("RH I"),a("RH D")bF=u
aX=u
if bm and not bD then
n=g(n-30,0,90)elseif ba and not bi then
n=g(n+30,0,90)end
bD=bm
bi=ba
if(aY and q)or bx<1 then
q=u
elseif aY and not q and bx>=1 then
q=true
end
if q then
n=0
end
by=n<=45
if q and not bN then
cm,cs=P,O
end
bN=q
if aO and not bv then
cp=bH(aw,d,e,c)end
bv=aO
if bU then
local r,t,aD,aR,aF,au,aE,aP
if by then
if not bd then
v,H=0,0
C,I=0,0
L,y=0,0
V,R=0,0
end
r,t,aD,aR=bn/20,bB/20,bK/8,am*20
aF,au,aE,aP=-aw,-bo,br,bM
Q,W=0,0
ar,ak=0,0
if aU then
aR=g(bt-T,-20,20)aP=bq
end
if q then
local aq,an,aG=bI(cm,cs,0,P,0,O,d,e,c)cv,bS=g(aq/10,-10,10),g(an/10,-10,10)r,as,al=l(bE,aZ,bg,cv,b_,as,al,-1/8,1/8)t,ah,ao=l(bE,aZ,bg,bS,bJ,ah,ao,-1/8,1/8)else
al,as=0,0
ao,ah=0,0
end
X,H,v=l(cf,cb,bV,r,aF,H,v,-1,1)m,I,C=l(ch,ck,cr,t,au,I,C,-1,1)Z,y,L=l(cl,cJ,cE,aD,aE,y,L,-1,1)bh,R,V=l(bT,cD,bX,aR,aP,R,V,-1,1)M,J=X,-X
N,K=m,m
ab,af=Z/2,-Z/2
ae,ad=bh+X,bh-X
if ae<0 then
ab=-ab
M=-M
N=-N
end
if ad<0 then
af=-af
J=-J
K=-K
end
else
if bd then
v,H=0,0
C,I=0,0
L,y=0,0
V,R=0,0
Q,W=0,0
end
r,t,aD=bn/5,bB/10,bK/30
aF,au,aE=-cH,co,br
if aU then
cw=g((bt-T)/5,-30,30)t,W,Q=l(bY,ce,cn,cw,bq,W,Q,-.25,.25)t=-t
au=-bo
bb,bf,bO=c_,cI,cK
else
Q,W=0,0
end
if aO then
bW=cc(cp-bH(aw,d,e,c))r,ak,ar=l(cz,cg,cq,bW,0,ak,ar,-.2,.2)r=-r
else
ar,ak=0,0
end
X,H,v=l(cA,ct,cF,r,aF,H,v,-1,1)m,I,C=l(bb,bf,bO,t,au,I,C,-1,1)Z,y,L=l(cx,cB,cC,aD,aE,y,L,-1,1)V,R=0,0
al,as=0,0
ao,ah=0,0
if aU then
local at,ac,A=aN(0,0,1,0,0,0,d,e,c)if A>=0 then
m=4*(.25-bj(aw))*m/2
else
m=-4*(.25-bj(aw))*m/2
end
end
M,J=Z,-Z
N,K=m,m
ab,af=0,0
ae,ad=1,1
bF=am>.1
aX=am<-.1
end
aH=X
az=m
aI=Z
else
v,H=0,0
C,I=0,0
L,y=0,0
V,R=0,0
Q,W=0,0
al,as=0,0
ao,ah=0,0
ar,ak=0,0
aH=0
az=0
aI=0
M=0
J=0
N=0
K=0
ab=0
af=0
ae=0
ad=0
end
bd=by
if cy then
bP,bG=4*30/360,4*30/360
ae,ad=g(am,0,1),g(am,0,1)else
bP=4*(n/360)+ab
bG=4*(n/360)+af
end
M=M/g(bz/60,1,D)J=J/g(bc/60,1,D)N=N/g(bz/60,1,D)K=K/g(bc/60,1,D)aH=aH/g(aW/60,1,D)az=az/g(aW/60,1,D)aI=aI/g(aW/60,1,D)k(1,aH)k(2,az)k(3,aI)k(4,M)k(5,J)k(6,N)k(7,K)k(8,bP)k(9,bG)k(10,ae)k(11,ad)aT(1,bF)aT(2,aX)aT(3,q)end
function onDraw()ca=aa.getWidth()p=aa.getHeight()j,i=bu(ca/10),bu(p*9/10)ay=aj*(90-n)/ai
aB,aK=20*b(ay),20*_(ay)bR,cG=10*b(ay),10*_(ay)cj=string.format("%d",90-n)aa.setColor(0,255,0)aa.drawText(j,i-4,cj)aA(j+aB,i-aK,j+bR,i-cG)drawCircle(j,i,15,0,90)drawCircle(j,i,20,0,90)aA(j,i-15,j,i-21)aA(j+15,i,j+20,i)end
