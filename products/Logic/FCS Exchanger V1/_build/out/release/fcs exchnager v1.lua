-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1274 (1682 with comment) chars

f=false
z=output
A=input
y=table
q=math
C=q.floor
D=y.insert
w=q.randomseed
v=q.random
_=A.getNumber
h=A.getBool
a=z.setNumber
e=z.setBool
c=f
b=f
G=f
I=f
d={}n=0
t=1700
function s(R)local E=0
if R then
E=1
end
return E
end
j=v(1,10000000)function onTick()if t>=1800 then
N=_(24)O=_(25)P=_(26)t=0
w(N)M=v(1,3000000)w(O)Q=v(1,3000000)w(P)L=v(1,3000000)j=M+Q+L
else
t=t+1
end
H=h(6)F=h(7)if H and not G then
c=not c
if c and b then
b=f
end
end
G=H
if F and not I then
b=not b
if b and c then
c=f
end
end
I=F
e(6,c)e(7,b)i=_(9)a(31,i)a(32,j)r=_(10)m=_(11)if c then
if k==m then
g=r
k=m
n=0
elseif m==0 then
if n<=60 then
n=n+1
else
g=r
k=m
end
elseif r>g then
g=r
k=m
end
if i>g then
g=i
k=j
end
else
g=i
k=j
n=0
end
a(7,g)a(8,k)e(8,c)J=_(18)B=_(19)if b then
if i>J and B~=j then
l=true
elseif q.abs(B-j)<1 then
l=not l
else
l=f
end
else
l=f
end
e(9,l)x=h(2)K=_(22)==1
if b then
D(d,K)else
D(d,x)end
while#d>3600 do
y.remove(d,1)end
if c then
o=#d-C(g-i+.5)-7
elseif b then
o=#d-C(J-i+.5)else
o=#d
end
if o>0 and(c or b)then
u=d[o]elseif c or b then
u=f
else
u=x
end
e(2,u)a(10,s(u))a(11,s(x))if b then
for p=1,6 do
a(p,_(p+11))end
e(1,_(20)==1)a(9,_(20))e(4,_(23)==1)a(12,_(23))else
for p=1,6 do
a(p,_(p))end
e(1,h(1))a(9,s(h(1)))e(4,h(4))a(12,s(h(4)))end
a(20,#d)a(21,o)end
