-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 2185 (2593 with comment) chars

ai=output
aH=input
k=math
K=k.abs
l=k.pi
N=k.atan
a=k.sin
b=k.cos
_=aH.getNumber
P=aH.getBool
D=ai.setNumber
be=ai.setBool
R=property.getNumber
ab=10000
aG=1
aO=0
as=0
aJ=0
aj=0
function ar(S,aa,U,bh,bj,aW,h,i,f)S,aa,U=S-bh,aa-aW,U-bj
v=b(f)*b(i)o=b(f)*a(i)*a(h)-a(f)*b(h)u=b(f)*a(i)*b(h)+a(f)*a(h)r=S
n=a(f)*b(i)t=a(f)*a(i)*a(h)+b(f)*b(h)p=a(f)*a(i)*b(h)-b(f)*a(h)m=U
O=-a(i)Q=b(i)*a(h)T=b(i)*b(h)M=aa
L=((v*t-o*n)*T+(u*n-v*p)*Q+(o*p-u*t)*O)aE,aD,aK=0,0,0
if L~=0 then
aE=((o*p-u*t)*M+(r*t-o*m)*T+(u*m-r*p)*Q)/L
aD=-((v*p-u*n)*M+(r*n-v*m)*T+(u*m-r*p)*O)/L
aK=((v*t-o*n)*M+(r*n-v*m)*Q+(o*m-r*t)*O)/L
end
return aE,aK,aD
end
function ap(d,q)if d>=0 then
af=N(q/d)elseif q>=0 then
af=N(q/d)+l
else
af=N(q/d)-l
end
return af
end
function bi(d,q)return k.sqrt(d^2+q^2)end
function aL(d,min,max)if d>=max then
d=max
elseif d<=min then
d=min
end
return d
end
function w(d)return(d+.5)%1-.5
end
function al(C,z,A,aP,aU,ao,bb,min,max)local s,ag,c
s=aP-aU
G=ao+s
ag=s-bb
c=C*s+z*G+A*ag
if c>max or c<min then
G=ao
c=C*s+z*G+A*ag
end
return c,G,s
end
function aA(c,H,min,max)if H>=max then
if c>0 then
c=0
end
c=c-.01
elseif H<=min then
if c<0 then
c=0
end
c=c+.01
end
return c
end
function onTick()ay=_(1)aq=_(2)av=_(3)an=_(4)ak=_(5)ax=_(6)ba=_(7)bd=_(8)aV=_(9)E=_(10)ah=_(11)aB=_(12)Y=_(13)X=_(14)J=_(15)g=_(16)e=_(17)j=_(18)F=_(19)I=_(20)if g~=g then
g=1
end
if e~=e then
e=1
end
aI=_(31)aF=_(32)V=P(1)ae=P(2)au=P(3)if au then
aI=0
end
C=R("P")z=R("I")A=R("D")bf=ay+ab*a(aF)aZ=av+ab*b(aF)aS=aq+ab*k.tan(aI)aM,az,aQ=ar(bf,aZ,aS,ay,aq,av,an,ak,ax)if V then
y=.5*ap(bi(aM,az),aQ)/l
x=w(.5*ap(az,aM)/l-aB)aR,b_,bc=ar(ba,aV,bd,0,0,0,an,ak,ax)aN=w(ah+aB)*2*l
aw=-g*(aR*b(aN)-b_*a(aN))am=-e*bc
if(ae and K(x)>J)or(y<Y or y>X)then
y=0
x=0
end
else
y=0
x=0
end
W=y-E
aX=g*(W)ac=w(ah)if ae then
B=x-ac
at=e*(B)else
B=w(x-ah)at=e*w(B)end
bg,as,aO=al(C,z,A,0,-aX,as,aO,-g*j,g*j)aY,aj,aJ=al(C,z,A,0,-at,aj,aJ,-e*j,e*j)F=F*g*30/l
I=I*e*30/l
aC=K(ac)<J and E>Y and E<X
H=K(W)<aG/360 and K(B)<aG/360
aT=V and H and aC and not au
D(3,W*360)D(4,B*360)if not(V and aC)then
aw,am=0,0
F,I=0,0
end
ad=aL(bg+aw+F,-g*j,g*j)Z=aL(aY+am+I,-e*j,e*j)ad=aA(ad,E,Y,X)if ae then
Z=aA(Z,ac,-J,J)end
D(1,ad)D(2,Z)be(1,aT)end
