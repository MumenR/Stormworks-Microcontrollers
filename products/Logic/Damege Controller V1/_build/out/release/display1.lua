-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 978 (1384 with comment) chars

_=255
s=true
f=false
r=property
A=output
F=input
i=screen
h=i.drawText
p=string.format
d=i.setColor
a=F.getNumber
z=F.getBool
j=A.setNumber
e=A.setBool
Q=r.getNumber
G=r.getBool
P=r.getText
u=0
O=300
t=f
l=f
q=f
N={}function onTick()H=z(1)L=z(2)b=a(3)y=a(11)C=a(5)M=a(12)K=a(13)I=a(8)w=y+C+M+K+I
k=100*y/w
o=100*C/w
D=a(1)J=a(2)n=100*D/J
B=G("The type of custom tank")if b>=4 or b<=.12 or k<=15 or o>=10 then
t=s
else
t=f
end
if n>1
then
l=s
elseif n<.1 then
l=f
end
if k<20 then
q=s
elseif k>21 then
q=f
end
if B and l then
m=3.8
elseif B then
m=1
else
m=40
end
j(1,k)j(2,o)j(3,b)j(4,n)j(5,D)e(1,H)e(2,l)e(3,not L)e(30,q)e(31,b-m<-.05)e(32,b-m>.05)u=u+1
end
function onDraw()c=i.getHeight()g=i.getWidth()if t then
d(_,0,0)i.drawClear()end
v=p("%.2f",b)x=p("%.1f%%",k)E=p("%.2f%%",o)d(0,_,0)h(g/2-7,c/2-14,"atm")d(_,_,_)h(g/2-#v*2.5,c/2-7,v)d(0,_,0)if u%360<180 then
h(g/2-5,c/2+1,"o2")d(_,_,_)h(g/2-#x*2.5,c/2+8,x)else
h(g/2-7,c/2+1,"co2")d(_,_,_)h(g/2-#E*2.5,c/2+8,E)end
end
