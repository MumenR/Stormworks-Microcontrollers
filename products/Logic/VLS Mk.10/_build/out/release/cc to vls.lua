-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1534 (1942 with comment) chars

n=true
G=table
l=false
j=nil
F=pairs
z=property
I=output
K=input
L=math
J=L.huge
d=K.getNumber
M=K.getBool
c=I.setNumber
B=I.setBool
W=z.getNumber
V=z.getBool
Y=z.getText
a={}g={}P=100
Q=3
function onTick()R=M(1)T=M(2)D=d(31)==1
E=d(29)k=d(30)s=d(32)for _,f in F(a)do
f.m=f.m+1
f.i=f.i+1
if(f.m>P and _>-1)or(f.m>Q and _<=-1)then
a[_]=j
end
end
if D and not N then
a[-1]=j
a[-2]=j
end
if s~=0 then
local h,q
h=L.floor(s/1000)q=s%1000
if g[h]==j then
g[h]={p=h,H=q,u=l}else
if g[h].H~=q then
g[h].u=l
end
g[h].H=q
end
end
if R then
local _=T and-2 or-1
if a[_]==j then
a[_]={_=_,i=J,r=l,k=k,p=E}end
a[_].C=d(1)a[_].A=d(2)a[_].y=d(3)a[_].x=d(4)a[_].w=d(5)a[_].t=d(6)a[_].m=0
else
for e=1,4 do
local _=d(e*7)if _~=0 then
if a[_]==j then
a[_]={_=_,i=J,r=l,k=k,p=E}end
a[_].C=d(7*e-6)a[_].A=d(7*e-5)a[_].y=d(7*e-4)a[_].x=d(7*e-3)a[_].w=d(7*e-2)a[_].t=d(7*e-1)a[_].m=0
end
end
end
for e=1,32 do
c(e,0)B(e,l)end
c(29,E)c(30,k)local o,O,e,b={},l,1,1
for X,f in F(a)do
G.insert(o,f)end
G.sort(o,function(S,U)return S.i>U.i end)while e<=#o and b<=4 do
local _,v=o[e]._,o[e].p
if a[_].r or(D and not O and(_>0 or(_<0 and not N)))then
if not a[_].r then
if g[v]~=j then
if not g[v].u then
g[v].u=n
a[_].r=n
O=n
c(29,a[_].p)c(30,a[_].k)c(7*b-6,a[_].C)c(7*b-5,a[_].A)c(7*b-4,a[_].y)c(7*b-3,a[_].x)c(7*b-2,a[_].w)c(7*b-1,a[_].t)c(7*b-0,a[_]._)a[_].i=0
b=b+1
if _<=-1 then
B(1,n)end
B(32,n)end
end
else
c(7*b-6,a[_].C)c(7*b-5,a[_].A)c(7*b-4,a[_].y)c(7*b-3,a[_].x)c(7*b-2,a[_].w)c(7*b-1,a[_].t)c(7*b-0,a[_]._)a[_].i=0
b=b+1
end
end
e=e+1
end
N=D
end
