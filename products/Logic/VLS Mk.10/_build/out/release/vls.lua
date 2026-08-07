-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1499 (1907 with comment) chars

r=1000
D=true
m=nil
v=pairs
t=false
F=output
H=input
s=math
I=s.huge
f=H.getNumber
T=H.getBool
d=F.setNumber
q=F.setBool
w=property.getNumber
L=100
W=1
b={}a={}g=t
N=t
i=0
B=0
E=0
function onTick()j=f(31)x=f(32)u=j~=0
for A,c in v(b)do
c.e=c.e+1
c.o=c.o+1
if c.e>L then
b[A]=m
end
end
if x~=0 then
n=s.floor(x/r)M=x%r
if b[n]==m then
b[n]={C=n,p=M,e=0,o=I}else
b[n].C=n
b[n].p=M
b[n].e=0
end
end
if b[j]==m and u then
b[j]={C=j,p=0,e=0,o=I}end
if u then
y=b[j].p+1
else
y=r
end
for h=1,32 do
d(h,0)q(h,t)end
local l,J=0,-1
for A,c in v(b)do
if c.o>J then
J=c.o
l=A
end
end
if l~=0 then
if l==j and u and not g then
d(32,l*r+b[l].p+1)else
d(32,l*r+b[l].p)end
b[l].o=0
end
d(20,j)d(21,y)U=f(29)z=f(30)P=T(1)R=w("hatch close timing (s)")*60
G=w("launch timing (s)")*60+4
K=w("guidance time (s)")*60
for _,c in v(a)do
c.e=c.e+1
if(c.e>L and _>-1)or(c.e>W and _==-1)or(c.e>K and _==-2)then
a[_]=m
end
end
if g then
i=i+1
if i>K then
g=t
i=0
end
end
for h=1,4 do
local _=f(h*7)if _~=0 then
if a[_]==m or(_<=-1 and P)then
if a[_]==m then
a[_]={_=_,e=0}end
a[_].z=z
if u and j==U and y==1 and not g then
k=_
g=D
i=0
end
end
if _~=-2 or(_==-2 and i==0)then
a[_].O=f(7*h-6)a[_].Y=f(7*h-5)a[_].S=f(7*h-4)a[_].V=f(7*h-3)a[_].Q=f(7*h-2)a[_].X=f(7*h-1)a[_].e=0
end
end
end
if g and a[k]~=m then
d(1,a[k].O)d(2,a[k].Y)d(3,a[k].S)d(4,a[k].V)d(5,a[k].Q)d(6,a[k].X)d(7,a[k].z)q(1,D)end
q(30,g and i<R)q(31,g and i>=G and i<G+60)q(32,g)B=B+1
if g and not N then
s.randomseed(B)E=s.random(1,1000000)end
N=g
d(31,E)end
