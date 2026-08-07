-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 2055 (2463 with comment) chars

V=pairs
ah=property
ac=output
af=input
z=math
y=screen
ae=string.format
ak=y.drawText
k=y.drawLine
ag=y.drawRect
J=z.floor
aj=z.tan
c=z.sin
e=z.cos
h=af.getNumber
aC=af.getBool
as=ac.setNumber
aD=ac.setBool
Y=ah.getNumber
ab=ah.getBool
v={}K=z.pi*2
al=(73/360)*K
am=(58/360)*K
function aw(a,_,aq,ay,az,ar)return z.sqrt((a-ay)^2+(_-az)^2+(aq-ar)^2)end
function aa(I,C,H,N,L,P,d,g,f)local m,o,n,p,q,t,s,i,j,S,O,R,w,B,x,F
I=I-N
C=C-P
H=H-L
m=e(f)*e(g)o=e(f)*c(g)*c(d)-c(f)*e(d)n=e(f)*c(g)*e(d)+c(f)*c(d)p=I
q=c(f)*e(g)t=c(f)*c(g)*c(d)+e(f)*e(d)s=c(f)*c(g)*e(d)-e(f)*c(d)i=H
j=-c(g)S=e(g)*c(d)O=e(g)*e(d)R=C
F=((m*t-o*q)*O+(n*q-m*s)*S+(o*s-n*t)*j)w=0
x=0
B=0
if F~=0 then
w=((o*s-n*t)*R+(p*t-o*i)*O+(n*i-p*s)*S)/F
x=-((m*s-n*q)*R+(p*q-m*i)*O+(n*i-p*s)*j)/F
B=((m*t-o*q)*R+(p*q-m*i)*S+(o*i-p*t)*j)/F
end
return w,B,x
end
function au(A,l,u)local D,G,E
D=ai/2+(A/l)*(ai/2)/aj(al/2)G=i/2-(u/l)*(i/2)/aj(am/2)E=l>0
return D,G,E
end
function ax(I,C,H,d,g,f)local A,l,u,D,G,E
A,l,u=aa(I,C,H,N,L,P,d,g,f)A,l,u=aa(A,l,u,0,0,0,-av,ap,0)D,G,E=au(A,l,u)return D,G,E
end
function onTick()N=h(25)L=h(26)P=h(27)d=h(28)g=h(29)f=h(30)ap=h(31)*K
av=h(32)*K
at=Y("Radar delete tick")aA=Y("Distance Units")an=ab("radar ID")aB=ab("radar distance")for r,b in V(v)do
b.W=b.W+1
end
for j=0,5 do
local T=h(j*4+4)r=T%10000
if r~=0 then
v[r]={w=h(j*4+1),x=h(j*4+2),B=h(j*4+3),W=0,ad=T%(10^5)>10^4,M=T%(10^6)>10^5,Q=T>10^6}end
end
for r,b in V(v)do
if b.W>at then
v[r]=nil
end
end
as(30,#v)end
function onDraw()ai=y.getWidth()i=y.getHeight()y.setColor(0,255,0)for r,b in V(v)do
a,_,ao=ax(b.w,b.x,b.B,d,g,f)a=J(a)_=J(_)if ao then
if b.M or not b.Q then
ag(a-4,_-4,8,8)end
if b.M or b.Q then
k(a-4,_,a,_+4)k(a,_+4,a+4,_)k(a+4,_,a,_-4)k(a,_-4,a-4,_)end
if not b.Q and not b.M and b.ad then
ag(a-3,_-3,6,6)end
if(b.Q or b.M)and b.ad then
k(a-3,_,a,_+3)k(a,_+3,a+3,_)k(a+3,_,a,_-3)k(a,_-3,a-3,_)end
if an then
Z=tostring(r)ak(a+1-2.5*#Z,_-10,Z)end
if aB then
U=aw(N,P,L,b.w,b.x,b.B)*aA
if U>=10 then
X=ae("%.0f",J(U+.5))else
X=ae("%.1f",J(U*10+.5)/10)end
ak(a+1-2.5*#X,_+6,X)end
end
end
end
