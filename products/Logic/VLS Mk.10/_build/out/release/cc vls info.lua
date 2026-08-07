-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1314 (1722 with comment) chars
X="WPN"

j=255
C=table
m=tostring
D=nil
A=pairs
u=property
E=output
F=input
H=math
k=screen
G=k.drawRectF
e=k.drawText
J=k.drawLine
o=k.setColor
w=H.floor
i=F.getNumber
P=F.getBool
l=E.setNumber
S=E.setBool
U=u.getNumber
W=u.getBool
I=u.getText
O=100
f={}x=false
q=0
function onTick()local a,n=i(1),i(2)V=i(3)z=i(4)B=P(1)v=i(31)Q=i(32)for R,t in A(f)do
t.p=t.p+1
if t.p>O then
f[R]=D
end
end
if v~=0 then
local c,s,r
c=w(v/1000)s=v%1000
if f[c]==D then
if I(m(c))~="" then
r=I(m(c))else
r=m(c)end
f[c]={d=c,g=s,p=0,h=r}else
f[c].d=c
f[c].g=s
f[c].p=0
end
end
b={}for T,M in A(f)do
C.insert(b,M)end
C.sort(b,function(L,K)return L.d<K.d end)N=H.min(#b,w(n/8)-1)for _=1,N do
local y=_*8+1
if B and not x and z>=y and z<y+7 then
q=b[_].d
break
end
end
x=B
for _=1,32 do
l(_,0)end
for _=1,#b do
if _>30 then
break
end
l(_*2-1,b[_].d)l(_*2-0,b[_].g)end
l(31,q)l(32,Q)end
function onDraw()local a,n=k.getWidth(),k.getHeight()o(0,0,64)for _=7,n,8 do
J(0,_,a,_)end
J(3*a/5,0,3*a/5,n)o(j,j,j)if a==32 then
e(4*a/5-3,1,"QT")e(3*a/10-7,1,X)else
e(4*a/5-5,1,"QTY")e(3*a/10-8,1,X)end
for _=1,#b do
local d,h,g
d=b[_].d
h=b[_].h
g=m(w(b[_].g))if d==q then
o(64,64,0)G(0,_*8,3*a/5-1,7)G(3*a/5,_*8,2*a/5,7)o(j,j,j)end
if a==32 then
if#h>3 then
e(0,_*8+1,h)else
e(2,_*8+1,h)end
else
e(2,_*8+1,h)end
e(4*a/5-#g*2.5+2,_*8+1,g)end
end
