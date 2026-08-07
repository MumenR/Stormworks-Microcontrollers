-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1232 (1640 with comment) chars

G=false
J=output
C=input
I=math.abs
_=C.getNumber
ak=C.getBool
a=J.setNumber
t=J.setBool
c=property.getNumber
p=G
ae=2.5
V=13.7
m=0
q=0
n=0
r=0
function B(D,v,E,ai,M,s,U,min,max)local e,o,f
e=ai-M
i=s+e
o=e-U
f=D*e+v*i+E*o
if f>max or f<min and I(i)>I(s)then
i=s
f=D*e+v*i+E*o
end
return L(f,min,max),i,e
end
function w(N)if N then
return 1
else
return 0
end
end
function L(g,min,max)if g>=max then
g=max
elseif g<=min then
g=min
end
return g
end
function onTick()ah=_(1)af=_(2)k=_(3)l=_(5)Z=_(6)H=_(7)h=_(8)==1
T=c("target battery")ag=_(12)Y=_(13)Q=_(14)ab=c("max temp")X=c("min temp")P=c("thermal throttling temp")aj=c("thermal throttling rps")A=c("target rps")S=c("max rps")ad=_(9)aa=_(10)W=_(11)x=c("idling rps fuel")if h then
b,q,m=B(ag,Y,Q,T,H,q,m,0,1)else
b=0
m,q=0,0
end
d=h and l<ae and b>0
if k>ab then
p=true
elseif k<X then
p=G
end
z=p and not d
u=(.4*V)/(Z*.029+2.75)F=1/u
if h and l<S and b>0 then
if d then
j=F
else
j=b*(F-x)+x
end
else
j=0
end
ac=j*u
if k>P then
A=aj
end
if h and b>0 and not d then
K,r,n=B(ad*b,aa*b,W*b,A,l,r,n,-100,0)else
K,r,n=0,0,0
end
if d then
y=0
else
y=L((-K/100),0,1)^(1/6)end
R=w(d)O=w(z)a(1,b*100)a(2,l*60)a(3,k)a(4,H*100)a(5,ah/af)a(6,ac)a(7,j)a(8,y)a(9,R)a(10,O)t(1,h)t(2,d)t(3,z)end
