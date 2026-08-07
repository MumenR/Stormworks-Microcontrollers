cA="%02.0f"
cz="%d"
cy=":"
cx="%.0f"

p=255
M=true
u=false
aP=property
bz=output
bh=input
C=math
bs=table
bp=map
F=screen
v=F.setColor
bx=bp.screenToMap
aY=bs.remove
aR=bs.insert
P=F.drawText
y=F.drawRectF
ak=C.floor
D=string.format
aw=F.drawLine
aL=bp.mapToScreen
b=C.sin
c=C.cos
af=C.pi
aM=C.atan
as=C.sqrt
bF=C.log
i=bh.getNumber
am=bh.getBool
w=bz.setNumber
aS=bz.setBool
H=aP.getNumber
aJ=aP.getBool
bB=aP.getText
cm=.5
j={{0,0}}K=0
A={}ad=u
al=M
aI=u
q=0
x=0
function bP(a,min,max)local z,bD,m
bD=bF(min)z=bF(max/min)m=C.exp(z*a+bD)return m
end
function aa(a,min,max)if a>=max then
return max
elseif a<=min then
return min
else
return a
end
end
function bj(aH,ap,az,aC)return as((aH-az)^2+(ap-aC)^2)end
function cw(a)return(a+.5)%1-.5
end
function bK(a,m)if a>=0 then
bb=aM(m/a)elseif m>=0 then
bb=aM(m/a)+af
else
bb=aM(m/a)-af
end
return bb
end
function ci(ae,Z,ac,l,ai,n,e,h,f)local bq,bw,bA
bq=c(f)*c(h)*ae+(c(f)*b(h)*b(e)-b(f)*c(e))*ac+(c(f)*b(h)*c(e)+b(f)*b(e))*Z
bw=b(f)*c(h)*ae+(b(f)*b(h)*b(e)+c(f)*c(e))*ac+(b(f)*b(h)*c(e)-c(f)*b(e))*Z
bA=-b(h)*ae+c(h)*b(e)*ac+c(h)*c(e)*Z
return bq+l,bA+n,bw+ai
end
function bQ(bc,aW,aZ,l,ai,n,e,h,f)local z,N,T,R,L,Q,S,_,g,at,ay,aF,a,ab,m,ao
bc=bc-l
aW=aW-n
aZ=aZ-ai
z=c(f)*c(h)N=c(f)*b(h)*b(e)-b(f)*c(e)T=c(f)*b(h)*c(e)+b(f)*b(e)R=bc
L=b(f)*c(h)Q=b(f)*b(h)*b(e)+c(f)*c(e)S=b(f)*b(h)*c(e)-c(f)*b(e)_=aZ
g=-b(h)at=c(h)*b(e)ay=c(h)*c(e)aF=aW
ao=((z*Q-N*L)*ay+(T*L-z*S)*at+(N*S-T*Q)*g)a=0
m=0
ab=0
if ao~=0 then
a=((N*S-T*Q)*aF+(R*Q-N*_)*ay+(T*_-R*S)*at)/ao
m=-((z*S-T*L)*aF+(R*L-z*_)*ay+(T*_-R*S)*g)/ao
ab=((z*Q-N*L)*aF+(R*L-z*_)*at+(N*_-R*Q)*g)/ao
end
return a,ab,m
end
function cb(a,m,ab,cp)local an,U
an=bK(as(a^2+m^2),ab)U=bK(m,a)bE=as(a^2+m^2+ab^2)if cp then
return an,U,bE
else
return an/(af*2),U/(af*2),bE
end
end
aV=0
aU=0
function cf(aE,ar,av,bL,bN,bn,cu,min,max)local W,aX,ag
W=bL-bN
aq=bn+W
aX=W-cu
ag=aE*W+ar*aq+av*aX
if ag>max or ag<min then
aq=bn
ag=aE*W+ar*aq+av*aX
end
return aa(ag,min,max),aq,W
end
function ck(r,s,k,d,_,l,n,X)local aB,au,aH,az,ap,aC
aB,au=aL(r,s,k,d,_,l,n)aH=aB-2*b(X)ap=au-2*c(X)az=aB-6*b(X)aC=au-6*c(X)F.drawCircle(aB,au,2)aw(aH,ap,az,aC)end
function cc(a,t,I,o,O)local aj
a=a*o
if a/(o/t)<1 then
aj=D(cx,a)..O
elseif a/(o/t)<10 then
aj=D("%.2f",a/(o/t))..I
elseif a/(o/t)<100 then
aj=D("%.1f",a/(o/t))..I
else
aj=D(cx,a/(o/t))..I
end
return aj
end
function cs(k,d,_,t,I,o,O)local aO,aD,aG
k=k*1000*o
if k/5>=(o/t)then
k=k/(o/t)O=I
end
aO=bR(k/5)aD=ak(d*aO/k)aG=D(cx,aO)..O
y(aa(d*4.5/5-1-aD/2,0,d-aD),_-10,aD,3)P(aa(d*4.5/5-1-#aG*2.5,0,d-5*#aG),_-6,aG)end
function bR(B)local g=0
while B>=10 do
B=B/10
g=g+1
end
if B<2 then
B=1
elseif B<5 then
B=2
else
B=5
end
return B*10^g
end
function bO(a)local bJ,min,aK,ax
bJ=D(cz,ak(a/3600))aK=D(cA,ak(a%60+.5))if a<3600 then
min=D(cz,ak((a/60)%60))ax=min..cy..aK
elseif a>=36000 then
ax="-:--:--"
else
min=D(cA,ak((a/60)%60))ax=bJ..cy..min..cy..aK
end
return ax
end
function onTick()by=u
local d,_
d=i(1)_=i(2)E=i(3)J=i(4)l=i(5)ai=i(6)n=i(7)e=i(8)h=i(9)f=i(10)cd=i(11)ch=i(12)bX=i(13)X=i(14)*af*2
bC=i(15)bu=i(16)c_=H("max zoom (km)")bZ=H("min zoom (km)")bf=H("zoom speed")/60
aE=i(17)ar=i(18)av=i(19)ah=H("Longest tap interval [tick]")co=H("Waypoint switch arrival time [s]")bU=H("Map color")t=H("Distance units (Large)")I=bB("Units text (Large)")o=H("Distance units (Small)")O=bB("Units text (Small)")bv=am(1)bM=am(2)cj=am(3)cn=am(4)bm=am(5)cg=aJ("Zoom scale")bi=aJ("Zoom lever")bI=aJ("Waypoint info.")br=u
bl=u
bt=u
ct,bY,cl=ci(cd,bX,ch,0,0,0,e,h,f)aR(A,{ct,bY,cl})while#A>300 do
aY(A,1)end
aQ,b_,aN=0,0,0
for g=1,#A do
aQ=aQ+A[g][1]b_=b_+A[g][2]aN=aN+A[g][3]end
ca=aQ/#A
bV=b_/#A
cv=aN/#A
j[1]={l,n}if cj then
if cn then
aR(j,{bC,bu})r,s=bC,bu
al=u
end
if bv then
if E>=1 and E<=8 and J>=_-7 then
br=M
al=M
q=0
elseif E>=10 and E<=17 and J>=_-7 then
bl=M
q=0
j={{l,n}}elseif E>=19 and E<=26 and J>=_-7 then
bt=M
if not ba and#j>1 then
aY(j,#j)end
elseif E>=d-6 and J>_/4 and J<_*3/4 and bi then
q=0
G=1-(J-_/4)/(_/2)elseif x<=ah and x>0 and q>0 then
if not ba then
r,s=bx(r,s,k,d,_,E,J)aR(j,{r,s})end
al=u
elseif bM then
G=aa(G-bf,0,1)aI=M
q=0
elseif q>ah then
G=aa(G+bf,0,1)else
q=q+1
x=0
end
else
if(ba and(x>0 or q>ah))or aI then
q,x=0,0
elseif q<=ah and q>0 then
x=x+1
end
aI=u
if x>=ah then
r,s=bx(r,s,k,d,_,E,J)q,x=0,0
al=u
end
end
ba=bv
else
r,s=l,n
q=0
x=0
G=cm
end
V,Y=0,0
while#j>1 do
V=j[2][1]Y=j[2][2]local bk,be=V-l,Y-n
bg=(bk*ca+be*bV)/as(bk^2+be^2)aA=bj(l,n,V,Y)K=aA/bg
if K<0 or C.abs(bg)<.01 then
K=36000
else
K=aa(K,0,36000)end
if K<co then
aY(j,2)if#j==1 then
by=M
end
else
break
end
end
aT=#j>1
aA=bj(l,n,V,Y)bW=cc(aA,t,I,o,O)k=bP(G,bZ,c_)if bm and not cr then
ad=not ad
end
cr=bm
if not aT then
ad=u
end
if ad then
local ae,Z,ac,an,U,bS
ae,Z,ac=bQ(V,Y,0,l,0,n,e,h,f)an,U,bS=cb(ae,Z,ac,u)bG,aU,aV=cf(aE,ar,av,0,-U,aU,aV,-1,1)else
bG,aU,aV=0,0,0
end
if al then
r,s=l,n
end
aS(1,aT)aS(2,ad)aS(3,by)w(1,V)w(2,Y)w(3,ai)w(4,0)w(5,0)w(6,0)w(7,aA)w(8,K)w(9,bG)w(10,r)w(11,s)w(12,k)end
function onDraw()local d,_
d=F.getWidth()_=F.getHeight()if aT then
for g=2,#j do
bd,bo=aL(r,s,k,d,_,j[g][1],j[g][2])cq,ce=aL(r,s,k,d,_,j[g-1][1],j[g-1][2])v(0,p,0)aw(bd,bo,cq,ce)v(p,0,0)F.drawCircleF(bd,bo,1.5)end
if bI then
v(0,p,0)P(1,1,"WP:"..bW)end
end
if bU==2 then
v(p,p,p)else
v(0,0,p)end
ck(r,s,k,d,_,l,n,X)v(32,32,32)y(0,_-7,28,7)v(64,64,64)for g=0,2 do
y(1+g*9,_-6,8,5)y(2+g*9,_-7,6,7)end
v(0,p,0)if br then
y(1,_-6,8,5)y(2,_-7,6,7)end
if bl then
y(10,_-6,8,5)y(11,_-7,6,7)end
if bt then
y(19,_-6,8,5)y(20,_-7,6,7)end
bT={"M","C","B"}v(p,p,p)for g=0,2 do
P(3+9*g,_-6,bT[g+1])end
if bi then
v(0,p,0)aw(d-4,_/4,d-4,_*3/4)aw(d-6,(1-G)*(_/2)+_/4,d-1,(1-G)*(_/2)+_/4)P(d-5,_/4-5,"+")P(d-5,_*3/4+1,"-")end
if cg then
v(0,p,0)cs(k,d,_,t,I,o,O)end
if ad and bI then
v(0,p,0)P(d-11,1,"AP")bH=bO(K)P(36-5*#bH,7,bH)end
end
