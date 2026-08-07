-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1298 (1706 with comment) chars

M=pairs
P=property
V=output
Q=input
t=math
Y=t.sqrt
_=t.sin
c=t.cos
w=t.pi
L=t.atan
d=Q.getNumber
al=Q.getBool
ab=V.setNumber
ai=V.setBool
aj=P.getNumber
ak=P.getBool
u={}J=0
ah=30
function T(b,a)if b>=0 then
C=L(a/b)elseif a>=0 then
C=L(a/b)+w
else
C=L(a/b)-w
end
return C
end
function aa(A,F,B,G,K,I,e,g,f)local r,m,o,k,l,n,q,p,h,y,z,x,b,j,a,v
A=A-G
F=F-I
B=B-K
r=c(f)*c(g)m=c(f)*_(g)*_(e)-_(f)*c(e)o=c(f)*_(g)*c(e)+_(f)*_(e)k=A
l=_(f)*c(g)n=_(f)*_(g)*_(e)+c(f)*c(e)q=_(f)*_(g)*c(e)-c(f)*_(e)p=B
h=-_(g)y=c(g)*_(e)z=c(g)*c(e)x=F
v=((r*n-m*l)*z+(o*l-r*q)*y+(m*q-o*n)*h)b=0
a=0
j=0
if v~=0 then
b=((m*q-o*n)*x+(k*n-m*p)*z+(o*p-k*q)*y)/v
a=-((r*q-o*l)*x+(k*l-r*p)*z+(o*p-k*q)*h)/v
j=((r*n-m*l)*x+(k*l-r*p)*y+(m*p-k*n)*h)/v
end
return b,j,a
end
function af(b,a,j,ae)local E,N
E=T(Y(b^2+a^2),j)N=T(a,b)X=Y(b^2+a^2+j^2)if ae then
return E,N,X
else
return E/(w*2),N/(w*2),X
end
end
function onTick()G=d(25)K=d(26)I=d(27)e=d(28)g=d(29)f=d(30)ad=d(31)ac=d(32)for s,i in M(u)do
i.H=i.H+1
end
for h=0,5 do
s=d(h*4+4)%1000
if s~=0 then
u[s]={b=d(h*4+1),a=d(h*4+2),j=d(h*4+3),H=0}end
end
for s,i in M(u)do
if i.H>ah then
u[s]=nil
end
end
U=(30/360)^2
J=0
for s,i in M(u)do
local O,R,S,W,Z,ag,D
O,R,S=aa(i.b,i.a,i.j,G,K,I,e,g,f)W,Z,ag=af(O,R,S,false)D=(W-ac)^2+(Z-ad)^2
if D<U then
U=D
J=s
end
end
ab(1,J)end
