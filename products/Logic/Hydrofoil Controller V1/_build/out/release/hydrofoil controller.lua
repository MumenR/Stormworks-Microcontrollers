-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 992 (1398 with comment) chars

f=.7
N=output
C=input
e=C.getNumber
ai=C.getBool
b=N.setNumber
ah=N.setBool
_=property.getNumber
function F(g,min,max)if g>=max then
g=max
elseif g<=min then
g=min
end
return g
end
q=0
v=0
x=0
B=0
z=0
m=0
function r(G,E,I,aa,ac,K,ag,min,max)h=aa-ac
i=K+h
M=h-ag
j=G*h+E*i+I*M
if j>max or j<min then
i=K
j=G*h+E*i+I*M
end
return F(j,min,max),i,h
end
function onTick()R=e(9)A=e(13)L=e(2)D=e(15)H=e(16)J=_("Target Alt")Q=_("roll gain")ad=_("pitch gain")U=_("updown gain")Y=_("speed gain")af=_("roll P")X=_("roll I")T=_("roll D")P=_("pitch P")ab=_("pitch I")W=_("pitch D")Z=_("updown P")S=_("updown I")ae=_("updown D")V=e(1)k=F(A/Y,1,100000)O=-V*A/1000
if A<5 then
d=-Q*H/k
c=-ad*D/k
a=U*(J-L)/k
x=0
B=0
q=0
v=0
z=0
m=0
else
d,x,B=r(af,X,T,O,H,x,B,-f,f)c,q,v=r(P,ab,W,0,D,q,v,-f,f)a,z,m=r(Z,S,ae,J,L,z,m,-f,f)end
y=c-d+a
u=c+a
s=c+d+a
w=a-d
p=a
t=a+d
l=-c-d+a
n=-c+a
o=-c+d+a
if R<0 then
y,u,s,w,p,t,l,n,o=-y,-u,-s,-w,-p,-t,-l,-n,-o
end
b(1,y)b(2,u)b(3,s)b(4,w)b(5,p)b(6,t)b(7,l)b(8,n)b(9,o)end
