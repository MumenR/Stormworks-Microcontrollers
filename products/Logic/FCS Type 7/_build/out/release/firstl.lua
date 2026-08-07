-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1114 (1522 with comment) chars

w=false
A=output
y=input
g=math
d=table
l=d.insert
D=g.sin
x=g.cos
t=g.pi
h=y.getNumber
G=y.getBool
m=A.setNumber
z=A.setBool
f={}e={}r=1
n=0
u={q=-.5,p=0,o=-.25}function J(d)local max,min=d[1],d[1]for _=2,#d do
if d[_]>max then
max=d[_]elseif d[_]<min then
min=d[_]end
end
return(max+min)/2
end
function F(i,j,k,v)local b,c,a
b=g.sqrt(i^2+j^2+k^2)c=g.atan(i,j)a=g.asin(k/b)if v then
return b,c,a
else
return b,c/(t*2),a/(t*2)end
end
function I(b,c,a,v)local i,j,k
if not v then
a=a*t*2
c=c*t*2
end
i=b*x(a)*D(c)j=b*x(a)*x(c)k=b*D(a)return i,j,k
end
function E(b,c,a)local q,p,o
q,p,o=I(b,c,a,w)return F(-o-u.q,p-u.p,q-u.o,w)end
function onTick()s={}for _=1,8 do
if G(_)then
l(s,{h(_*4-3),h(_*4-2),h(_*4-1),h(_*4)})if h(_*4)+1>r then
r=h(_*4)+1
end
end
end
if#s>0 then
if s[1][4]==0 then
f={}end
l(f,s)else
f={}end
if#f==r then
e={}for _=1,#f[1]do
local C={}for H=1,3 do
local B={}for K=1,#f do
l(B,f[K][_][H])end
l(C,J(B))end
l(e,C)end
n=1
end
for _=1,24 do
m(_,0)z(_,w)end
if n<=r then
for _=1,#e do
local b,c,a=E(e[_][1],e[_][2],e[_][3])z(_,true)m(3*_-2,b)m(3*_-1,c)m(3*_-0,a)end
m(32,n)n=n+1
else
e={}end
end
