-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1029 (1437 with comment) chars
H='f'
G='I3B'

w=nil
v=pairs
u=output
t=input
p=math
m=p.floor
o=t.getNumber
D=t.getBool
h=u.setNumber
F=u.setBool
C=property.getNumber
E=p.pi*2
A=600
s=.1
g=24
function n(b,a)a=m(a/s+.5)if a<0 then
a=(a+(1<<g))&((1<<g)-1)end
a=a|b<<g
b=(b>>(24-g))+66
if b>=127 then
b=b+67
end
local f=(H):unpack((G):pack(a & 16777215,b & 255))return f
end
function B(f)local a,b=(G):unpack((H):pack(f))if b>>7 & 1~=0 then
b=b-67
end
b=(b-66)<<(24-g)|(a>>g)a=a &((1<<g)-1)if a>>(g-1)& 1~=0 then
a=a-(1<<g)end
return b,a*s
end
_={}function onTick()for c,l in v(_)do
_[c].q=_[c].q+1
_[c].e=_[c].e+1
if l.q>A then
_[c]=w
end
end
for i=0,5 do
local f,j,k,c
f=o(4*i+1)j=o(4*i+2)k=o(4*i+3)c=o(4*i+4)%1000
if c~=0 then
local e=p.huge
if _[c]~=w then
e=_[c].e
end
_[c]={f=f,j=j,k=k,q=0,e=e}end
end
for i=1,32 do
h(i,n(0,0))end
local r,d=0,0
for c,l in v(_)do
if l.e>r then
r=l.e
d=c
end
end
if d~=0 then
local x,z,y=m((d/10)%10),m((d/10)%10),m(d%10)h(1,n(x,_[d].f))h(2,n(z,_[d].j))h(3,n(y,_[d].k))_[d].e=0
h(4,_[d].f)h(5,_[d].j)h(6,_[d].k)h(7,d)end
end
