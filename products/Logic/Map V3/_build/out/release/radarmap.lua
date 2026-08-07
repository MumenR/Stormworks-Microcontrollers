-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1631 (2039 with comment) chars

o=200
_=255
u=pairs
z=property
C=output
A=input
a=screen
j=a.drawLine
B=a.drawCircle
w=map.mapToScreen
m=a.setColor
I=a.setMapColorSnow
F=a.setMapColorSand
E=a.setMapColorGrass
H=a.setMapColorLand
L=a.setMapColorShallows
D=a.setMapColorOcean
l=math.floor
e=A.getNumber
ac=A.getBool
t=C.setNumber
ab=C.setBool
r=z.getNumber
G=z.getBool
k={}g,f=0,0
function aa(n,min,max)if n>=max then
return max
elseif n<=min then
return min
else
return n
end
end
function onTick()s=e(25)v=e(26)q=e(27)R=e(28)V=e(29)y=r("Radar delete tick")M=G("Distance circle")W=l(r("Distance circle max number"))Y=G("Map centerline")J=r("Map color")K=r("Distance units (Large)")for i,d in u(k)do
d.p=d.p+1
end
for h=0,5 do
i=e(h*4+4)%1000
if i~=0 then
k[i]={n=e(h*4+1),N=e(h*4+2),Z=e(h*4+3),p=0,O=l(e(h*4+4)/1000)%10==2,P=l(e(h*4+4)/10^4)%10==1}end
end
for i,d in u(k)do
if d.p>y then
k[i]=nil
end
end
t(30,#k)t(31,g)t(32,f)end
function onDraw()local b,c
b=a.getWidth()c=a.getHeight()if J==1 then
D(12,12,12,_)L(30,30,30,_)H(70,70,70,_)E(40,40,40,_)F(90,90,90,_)I(o,o,o,_)a.T(55,55,55,_)a.X(50,50,50,_)elseif J==2 then
D(0,5,20,_)L(0,7,30,_)H(2,2,5,_)E(10,10,20,_)F(5,5,10,_)I(20,20,40,_)a.T(3,3,6,_)a.X(4,4,8,_)end
a.drawMap(s,v,q)if M and K~=0 then
m(_,_,_,64)U,Q=w(s,v,q,b,c,R,V)for h=1,W do
S=w(0,0,q,b,c,h/K,0)B(U,Q,S-b/2)end
end
if Y then
m(_,_,_,64)j(0,c/2,b/2-5,c/2)j(b,c/2,b/2+5,c/2)j(b/2,0,b/2,c/2-5)j(b/2,c,b/2,c/2+5)end
for i,d in u(k)do
g,f=w(s,v,q,b,c,d.n,d.N)g,f=l(g),l(f)x=aa(510*(y-d.p)/y,0,_)if d.P then
m(0,0,_,x)elseif d.Z>50 then
m(_,o,0,x)else
m(0,o,_,x)end
j(g-2,f,g+3,f)j(g,f-2,g,f+3)a.drawText(g+3,f-6,i)if d.O then
B(g,f,3)end
end
end
