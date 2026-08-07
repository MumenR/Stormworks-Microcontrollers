-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1716 (2124 with comment) chars

Q=pairs
U=property
W=output
ad=input
x=math
G=screen
ac=string.format
ab=G.drawText
P=x.floor
V=x.tan
_=x.sin
c=x.cos
e=ad.getNumber
aw=ad.getBool
ao=W.setNumber
ax=W.setBool
Z=U.getNumber
ae=U.getBool
v={}L=x.pi*2
ak=(73/360)*L
al=(58/360)*L
function an(l,j,af,au,ag,ai)return x.sqrt((l-au)^2+(j-ag)^2+(af-ai)^2)end
function Y(E,H,F,M,J,O,a,d,b)local n,m,q,s,r,p,k,g,h,N,I,K,u,z,w,B
E=E-M
H=H-O
F=F-J
n=c(b)*c(d)m=c(b)*_(d)*_(a)-_(b)*c(a)q=c(b)*_(d)*c(a)+_(b)*_(a)s=E
r=_(b)*c(d)p=_(b)*_(d)*_(a)+c(b)*c(a)k=_(b)*_(d)*c(a)-c(b)*_(a)g=F
h=-_(d)N=c(d)*_(a)I=c(d)*c(a)K=H
B=((n*p-m*r)*I+(q*r-n*k)*N+(m*k-q*p)*h)u=0
w=0
z=0
if B~=0 then
u=((m*k-q*p)*K+(s*p-m*g)*I+(q*g-s*k)*N)/B
w=-((n*k-q*r)*K+(s*r-n*g)*I+(q*g-s*k)*h)/B
z=((n*p-m*r)*K+(s*r-n*g)*N+(m*g-s*p)*h)/B
end
return u,z,w
end
function aq(y,i,t)local C,A,D
C=X/2+(y/i)*(X/2)/V(ak/2)A=g/2-(t/i)*(g/2)/V(al/2)D=i>0
return C,A,D
end
function aj(E,H,F,a,d,b)local y,i,t,C,A,D
y,i,t=Y(E,H,F,M,J,O,a,d,b)y,i,t=Y(y,i,t,0,0,0,-at,am,0)C,A,D=aq(y,i,t)return C,A,D
end
function onTick()M=e(25)J=e(26)O=e(27)a=e(28)d=e(29)b=e(30)am=e(31)*L
at=e(32)*L
ah=Z("Radar delete tick")as=Z("Distance Units")av=ae("radar ID")ap=ae("radar distance")for o,f in Q(v)do
f.R=f.R+1
end
for h=0,5 do
o=e(h*4+4)if o~=0 then
v[o]={u=e(h*4+1),w=e(h*4+2),z=e(h*4+3),R=0}end
end
for o,f in Q(v)do
if f.R>ah then
v[o]=nil
end
end
ao(30,#v)end
function onDraw()X=G.getWidth()g=G.getHeight()G.setColor(0,255,0)for o,f in Q(v)do
l,j,ar=aj(f.u,f.w,f.z,a,d,b)l=P(l)j=P(j)if ar then
G.drawRect(l-4,j-4,8,8)if av then
aa=tostring(o)ab(l+1-2.5*#aa,j-10,aa)end
if ap then
T=an(M,O,J,f.u,f.w,f.z)*as
if T>=10 then
S=ac("%.0f",P(T+.5))else
S=ac("%.1f",P(T*10+.5)/10)end
ab(l+1-2.5*#S,j+6,S)end
end
end
end
