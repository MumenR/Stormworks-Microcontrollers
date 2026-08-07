-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1331 (1739 with comment) chars

b=100
L=true
j=false
F=output
E=input
_=E.getNumber
ar=E.getBool
a=F.setNumber
k=F.setBool
z=j
t=j
Y=2.5
ao=b
at=0
as=0
s=0
C=0
D=0
r=0
function M(H,I,P,S,aj,p,T,min,max)local e,q,d
e=S-aj
o=p+e
q=e-T
d=H*e+I*o+P*q
if d>max or d<min then
if(d>max and p>0)or(d<min and p<0)then
o=p
end
d=H*e+I*o+P*q
end
return aq(d,min,max),o,e
end
function u(al)if al then
return 1
else
return 0
end
end
function aq(i,min,max)if i>=max then
i=max
elseif i<=min then
i=min
end
return i
end
function onTick()an=_(1)ag=_(2)l=_(3)m=_(4)/60
n=_(5)ac=_(6)y=_(7)X=_(8)V=_(9)aa=_(10)Z=_(11)R=_(14)U=_(15)ai=_(16)am=_(17)x=_(21)A=_(22)w=_(23)B=_(24)f=_(25)==1
ab=_(26)ap=_(27)ad=_(28)W=_(29)v=math.abs(_(30))c=f and n<Y
Q=(.4*am)/(ac*.029+2.75)h=1/Q
if l>ao then
R=U
end
if l>X then
z=L
elseif l<V then
z=j
end
O=z and not c
if y>aa then
t=j
elseif y<Z then
t=L
end
N=t and not c
if f and not c then
J,r,D=M(ap,ad,W,R,n,r,D,-x*b/h,b*(1-x/h))else
r,D=0,0
J=0
end
A=A*(.01+(m^2)*(v^2)/10000)w=w*(.01+(m^2)*(v^2)/10000)B=B*(.01+(m^2)*(v^2)/10000)if f and not c then
G,C,s=M(A,w,B,m,ab,C,s,0,b)else
G,C,s=0,0,0
end
if c then
K=0
else
K=(G/b)^(1/6)end
if f and n<ai then
if c then
g=h
else
g=(J/b)*h+x
end
else
g=0
end
af=g*Q
ae=u(c)ak=u(O)ah=u(N)a(1,b*g/h)a(2,n*60)a(3,l)a(4,y*b)a(5,an/ag)a(6,af)a(7,g)a(8,K)a(9,ae)a(10,ak)a(11,ah)k(1,f)k(2,c)k(3,O)k(4,N)end
