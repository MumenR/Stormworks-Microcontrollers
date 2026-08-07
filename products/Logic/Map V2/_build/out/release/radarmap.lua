-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1516 (1924 with comment) chars

l=200
_=255
x=pairs
y=property
J=output
B=input
a=screen
k=a.drawLine
r=map.mapToScreen
p=a.setColor
A=a.setMapColorSnow
z=a.setMapColorSand
D=a.setMapColorGrass
C=a.setMapColorLand
I=a.setMapColorShallows
G=a.setMapColorOcean
s=math.floor
g=B.getNumber
Z=B.getBool
w=J.setNumber
Y=J.setBool
n=y.getNumber
E=y.getBool
i={}f,e=0,0
function N(m,min,max)if m>=max then
return max
elseif m<=min then
return min
else
return m
end
end
function onTick()t=g(25)v=g(26)o=g(27)W=g(28)U=g(29)u=n("Radar delete tick")O=E("Distance circle")Q=s(n("Distance circle max number"))M=E("Map centerline")H=n("Map color")F=n("Distance units (Large)")for h,d in x(i)do
d.q=d.q+1
end
for j=0,5 do
h=g(j*4+4)if h~=0 then
i[h]={m=g(j*4+1),T=g(j*4+2),X=g(j*4+3),q=0}end
end
for h,d in x(i)do
if d.q>u then
i[h]=nil
end
end
w(30,#i)w(31,f)w(32,e)end
function onDraw()local b,c
b=a.getWidth()c=a.getHeight()if H==1 then
G(12,12,12,_)I(30,30,30,_)C(70,70,70,_)D(40,40,40,_)z(90,90,90,_)A(l,l,l,_)a.L(55,55,55,_)a.S(50,50,50,_)elseif H==2 then
G(0,5,20,_)I(0,7,30,_)C(2,2,5,_)D(10,10,20,_)z(5,5,10,_)A(20,20,40,_)a.L(3,3,6,_)a.S(4,4,8,_)end
a.drawMap(t,v,o)if O and F~=0 then
p(_,_,_,64)R,V=r(t,v,o,b,c,W,U)for j=1,Q do
P=r(0,0,o,b,c,j/F,0)a.drawCircle(R,V,P-b/2)end
end
if M then
p(_,_,_,64)k(0,c/2,b/2-5,c/2)k(b,c/2,b/2+5,c/2)k(b/2,0,b/2,c/2-5)k(b/2,c,b/2,c/2+5)end
for h,d in x(i)do
f,e=r(t,v,o,b,c,d.m,d.T)f=s(f)e=s(e)K=N(510*(u-d.q)/u,0,_)if d.X>50 then
p(_,l,0,K)else
p(0,l,_,K)end
k(f-2,e,f+3,e)k(f,e-2,f,e+3)a.drawText(f+3,e-6,h)end
end
