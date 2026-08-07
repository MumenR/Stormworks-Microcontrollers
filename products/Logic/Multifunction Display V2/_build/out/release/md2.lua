bI="BATTERY"
bH="L-TMP"
bG="GENERATOR"
bF="R-TMP"
bE="GENE ENG"
bD="ENG"
bC="FUEL"
bB="R-RPM"
bA="SOS"
bz="L-RPM"
by="%.1f"
bx="%.0f"
bw="SHAFT"

K=130
x=260
o=220
r=230
B=150
n=250
z=1000
u=2.5
g=255
U=false
W=property
ae=output
ah=input
E=math
w=screen
q=w.drawRectF
ag=w.drawRect
P=w.drawTriangleF
i=w.drawText
e=w.drawLine
k=E.sin
h=E.pi
p=E.cos
l=w.setColor
D=string.format
Y=E.abs
c=ah.getNumber
f=ah.getBool
br=ae.setNumber
ar=ae.setBool
ao=W.getNumber
bu=W.getBool
ad=W.getText
J=0
R=0
I=U
ab=U
function Q(a,min,max)if a>=max then
return max
elseif a<=min then
return min
else
return a
end
end
function aI(a)return au(E.floor(a+.5))end
function bs(a,ai,aK,bb,aO)local L,V,F
if a*ai<1 then
V=bb
F=aO
else
V=ai
F=aK
end
a=a*V
T=Y(a)if T<1 then
L=D("%.3f",a)..F
elseif T<10 then
L=D("%.2f",a)..F
elseif T<100 then
L=D(by,a)..F
else
L=D(bx,a)..F
end
return L
end
function au(at)local aW=tostring(at)local bm,M,ba=aW:match("([%-]?)(%d+)(%.?%d*)")M=M:reverse():gsub("(%d%d%d)","%1,"):reverse()M=M:gsub("^,","")return bm..M..ba
end
function s()l(g,g,g)end
function bv()l(g,g,32)end
function drawCircle(a,_,N,as,aL)for v=as,aL-10,10 do
local aa,an,am,aj
aa,an=N*p(h*v/180),N*k(h*v/180)am,aj=N*p(h*(v+10)/180),N*k(h*(v+10)/180)e(a+aa,_-an,a+am,_-aj)end
end
function d(O,ac,min,max,a,_,j,b)if Y(O)>10 then
S=D(bx,O)else
S=D(by,O)end
l(g,g,g)drawCircle(j/2+a,b/2+_,b/2-1,-30,210)H=Y(max-min)/5
v=0
while H>=10 do
H=H/10
v=v+1
end
if H<1.5 then
y=1
elseif H<3.5 then
y=2
elseif H<7.5 then
y=5
else
y=10
end
y=y*10^v
m=0
l(g,g,g)while m<=max do
t=(h*4/3)*(m-min)/(max-min)-7*h/6
if m>=min then
e(j/2+(b/2-1)*p(t)+a,b/2+(b/2-1)*k(t)+_,j/2+(b/2-5)*p(t)+a,b/2+(b/2-5)*k(t)+_)end
m=m+y
end
m=0
while m>=min do
t=(h*4/3)*(m-min)/(max-min)-7*h/6
if m>=min then
e(j/2+(b/2-1)*p(t)+a,b/2+(b/2-1)*k(t)+_,j/2+(b/2-5)*p(t)+a,b/2+(b/2-5)*k(t)+_)end
m=m-y
end
i(j/2-#S*u+a,(b/2-1)*k(h/6)+b/2-4+_,S)i(j/2-#ac*u+1+a,(b/2-1)*k(h/6)+b/2+2+_,ac)rad=(h*4/3)*(O-min)/(max-min)-7*h/6
l(0,g,0)e(j/2+a,b/2+_,j/2+(b/2-1)*p(rad)+a,b/2+(b/2-1)*k(rad)+_)P(j/2+(b/2-1)*p(rad)+a,b/2+(b/2-1)*k(rad)+_,j/2+2*p(rad+h*2/3)+a,b/2+2*k(rad+h*2/3)+_,j/2+2*p(rad+h*4/3)+a,b/2+2*k(rad+h*4/3)+_)end
function onTick()do
aZ=ao("Distance units (Large)")bq=ad("Units text (Large)")ap=ao("Distance units (Small)")aD=ad("Units text (Small)")b_=c(1)aB=c(2)aR=c(3)be=c(4)aS=c(5)ax=c(6)aA=c(7)*z*aZ
bj=c(8)*ap
aw=c(21)bi=c(9)bl=c(10)bh=c(11)bk=c(12)az=c(13)bp=c(14)aT=c(15)*60
bo=c(16)*60
aY=c(17)aN=c(18)av=c(19)*60
bf=c(20)*60
al=f(2)aU=f(3)bd=f(4)aQ=f(5)bc=f(6)aJ=f(7)ay=f(8)bg=f(9)aX=f(10)aV=f(11)bt=f(12)aq=f(13)and f(17)Z=f(14)and f(18)ak=f(15)and f(19)af=f(16)and f(20)aG,aH=c(22),c(23)aM,aC=c(24),c(25)aE,aP=c(26),c(27)aF,bn=c(28),c(29)end
if aq then
G,A=aG,aH
C=aq
elseif Z then
G,A=aM,aC
C=Z
elseif ak then
G,A=aE,aP
C=ak
elseif af then
G,A=aF,bn
C=af
else
G,A=-1,-1
C=U
end
if C and not ab and G>=138 and G<=158 and A>=138 and A<=148 then
I=not I
end
ab=C
if I then
J=J+1
if al then
R=J*50-n
J=0
end
else
R=0
J=0
end
if I then
X=aI(Q(R*ap,0,E.huge))else
X="--"
end
ar(1,I)end
function onDraw()j=w.getWidth()b=w.getHeight()do
l(0,0,64)e(0,b/2,129,b/2)e(64,0,64,b)e(65,40,65+64,40)e(129,0,129,b)e(195,0,195,b)e(129,128,195,128)end
a,_=0,1
do
s()i(a+32-#bD*u,_,bD)_=_+5
d(b_,bz,0,z,a,_,32,32)d(aB,bB,0,z,a+32,_,32,32)_=_+32+10
d(aR,bH,0,120,a,_,32,32)d(be,bF,0,120,a+32,_,32,32)end
do
_=b/2+2
s()i(a+32-#bE*u,_,bE)_=_+5
d(bi,bz,0,z,a,_,32,32)d(bl,bB,0,z,a+32,_,32,32)_=_+32+9
d(bh,bH,0,120,a,_,32,32)d(bk,bF,0,120,a+32,_,32,32)end
a,_=a+64+1,1
do
s()i(a+32-#bw*u,_,bw)_=_+5
d(aT,bz,-4000,4000,a,_,32,32)d(bo,bB,-4000,4000,a+32,_,32,32)_=_+32+5
end
do
s()i(a+32-#bI*u,_,bI)_=_+5
d(az,"L-%",0,100,a,_,32,32)d(bp,"R-%",0,100,a+32,_,32,32)end
do
_=b/2+2
s()i(a+32-#bG*u,_,bG)_=_+5
d(av,bz,0,10000,a,_,32,32)d(bf,bB,0,10000,a+32,_,32,32)_=_+32+9
d(aY,"L-STW",0,z,a,_,32,32)d(aN,"R-STW",0,z,a+32,_,32,32)end
a,_=a+64+1,1
do
s()i(a+32-#bC*u,_,bC)_=_+5
d(aS,"L",0,100000,a,_,64,64)_=_+56
d(aw,"L/s",0,100,a,_,32,32)d(Q(bj,0,10),"ft/L",0,10,a+32,_,32,32)_=_+32
d(Q(aA,0,B),"nm",0,B,a,_,32,32)d(Q(ax,0,600),"min",0,600,a+32,_,32,32)_=_+32+5
end
do
s()i(a+32-#bA*u,_,bA)_=_+7
ag(a+32-24,_,20,10)ag(a+32+3,_,20,10)if I then
l(0,g,0)q(a+32-23,_+1,19,9)l(0,0,0)i(a+16-3,_+3,"ON")else
i(a+16-4,_+3,"OFF")end
if al then
l(0,g,0)q(a+32+4,_+1,19,9)l(0,0,0)i(a+48-9,_+3,"DTC")else
s()i(a+48-9,_+3,"DCT")end
_=_+15
s()i(a-(#X+2)*5+50,_,X.." "..aD)end
do
l(g,0,0)if aU then
P(240,10,r,35,n,35)end
if bd then
q(r,35,20,20)end
if aQ then
P(r,35,o,60,r,60)q(o,60,10,35)end
if bc then
P(n,35,x,60,n,60)q(n,60,10,35)end
if aJ then
q(r,55,20,40)end
if ay then
q(o,95,10,35)end
if bg then
q(n,95,10,35)end
if aX then
q(r,95,20,35)end
if aV then
q(o,K,40,20)end
l(g,g,g)e(240,10,o,60)e(o,60,o,B)e(o,B,x,B)e(x,B,x,60)e(x,60,240,10)e(r,35,n,35)e(r,55,n,55)e(o,95,x,95)e(o,K,x,K)e(r,35,r,K)e(n,35,n,K)end
end
