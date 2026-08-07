-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1248 (1656 with comment) chars
E="%.0f"

a=255
v=false
y=input
m=math
g=screen
x=g.drawText
h=m.cos
q=g.drawLine
c=m.pi
e=m.sin
j=g.setColor
w=string.format
k=y.getNumber
C=y.getBool
u=property.getText
o=v
t=v
function onTick()z=k(1)*k(3)D=k(2)*k(4)A=u("Value 1 unit")B=u("Value 2 unit")min=k(5)max=k(6)s=C(1)if s and not t then
o=not o
end
t=s
if o then
n=w(E,D)r=B
else
n=w(E,z)r=A
end
end
function onDraw()b=g.getWidth()_=g.getHeight()j(a,a,a)g.drawCircle(b/2,_/2,_/2-1)j(0,0,0)g.drawRectF(0,(_/2-1)*e(c/6)+_/2,b,_)l=m.abs(max-min)/5
p=0
while l>=10 do
l=l/10
p=p+1
end
if l<1.5 then
i=1
elseif l<3.5 then
i=2
elseif l<7.5 then
i=5
else
i=10
end
i=i*10^p
d=0
j(a,a,a)while d<=max do
f=(c*4/3)*(d-min)/(max-min)-7*c/6
if d>=min then
q(b/2+(_/2-2)*h(f),_/2+(_/2-2)*e(f),b/2+(_/2-5)*h(f),_/2+(_/2-5)*e(f))end
d=d+i
end
d=0
j(a,a,a)while d>=min do
f=(c*4/3)*(d-min)/(max-min)-7*c/6
if d>=min then
q(b/2+(_/2-2)*h(f),_/2+(_/2-2)*e(f),b/2+(_/2-5)*h(f),_/2+(_/2-5)*e(f))end
d=d-i
end
j(a,a,a)x(b/2-#n*2.5,(_/2-1)*e(c/6)+_/2-4,n)j(a,a,a)x(b/2-#r*2.5+1,_-6,r)rad=(c*4/3)*(n-min)/(max-min)-7*c/6
j(0,a,0)q(b/2,_/2,b/2+(_/2-1)*h(rad),_/2+(_/2-1)*e(rad))g.drawTriangleF(b/2+(_/2-1)*h(rad),_/2+(_/2-1)*e(rad),b/2+2*h(rad+c*2/3),_/2+2*e(rad+c*2/3),b/2+2*h(rad+c*4/3),_/2+2*e(rad+c*4/3))end
