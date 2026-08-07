-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 2380 (2788 with comment) chars

F=1000
C=pairs
av=output
as=input
D=math
am=table
N=am.insert
au=D.huge
an=D.sqrt
d=D.sin
f=D.cos
n=as.getNumber
aU=as.getBool
q=av.setNumber
b_=av.setBool
aV=property.getNumber
aY=D.pi*2
a={}aR=120
aW=F/60
aZ=F/60/60
aT=50
aw=3600
function ao(ae,af,ak,ah,aj,Z,g,i,h)local m,o,u,A,z,v,t,B,r,U,X,T,_,j,l,K
ae=ae-ah
af=af-Z
ak=ak-aj
m=f(h)*f(i)o=f(h)*d(i)*d(g)-d(h)*f(g)u=f(h)*d(i)*f(g)+d(h)*d(g)A=ae
z=d(h)*f(i)v=d(h)*d(i)*d(g)+f(h)*f(g)t=d(h)*d(i)*f(g)-f(h)*d(g)B=ak
r=-d(i)U=f(i)*d(g)X=f(i)*f(g)T=af
K=((m*v-o*z)*X+(u*z-m*t)*U+(o*t-u*v)*r)_=0
l=0
j=0
if K~=0 then
_=((o*t-u*v)*T+(A*v-o*B)*X+(u*B-A*t)*U)/K
l=-((m*t-u*z)*T+(A*z-m*B)*X+(u*B-A*t)*r)/K
j=((m*v-o*z)*T+(A*z-m*B)*U+(o*B-A*v)*r)/K
end
return _,j,l
end
function aH(_,min,max)if _>=max then
_=max
elseif _<=min then
_=min
end
return _
end
function aa(p)local m,o,H,W,P,J=0,0,0,0,0,0
local aK=p[1].e and(p[#p].e-p[1].e)if#p<2 or aK<30 then
m=0
o=p[#p]._
else
for ap,I in C(p)do
H=H+I.e
W=W+I._
P=P+I.e*I._
J=J+I.e^2
end
m=(#p*P-H*W)/(#p*J-H^2)o=(J*W-P*H)/(#p*J-H^2)end
return m or 0,o or 0
end
aI,aA,aF=0,0,0
function ay(aL,aE,az,aJ,aP,aD)local al,ac,ai,O,S,V,ag,y,s
al,ac,ai=ao(aL,aE,az,ah,aj,Z,g,i,h)O,S,V=ao(aJ,aP,aD,0,0,0,g,i,h)O,S,V=O-aI,S-aF,V-aA
ag=an(al^2+ac^2+ai^2)y=-(O*al+S*ac+V*ai)/ag
s=y>0 and aH(ag/y,0,au)or au
return y,s
end
function aX(aC,aG,aS,aQ,aM,aB)return an((aC-aQ)^2+(aG-aM)^2+(aS-aB)^2)end
Y=true
function onTick()ah,aj,Z,g,i,h=n(25),n(26),n(27),n(28),n(29),n(30)for b,c in C(a)do
for ap,aq in ipairs(c.E)do
aq.e=aq.e-1
end
if c.E[1].e<=-aR then
am.remove(a[b].E,1)if#a[b].E==0 then
a[b]=nil
end
end
end
for r=1,6 do
b=n(4*r)%F
aN=D.floor(n(4*r)/10^4)==1
if b>0 and not aN then
aO={_=n(4*r-3),l=n(4*r-2),j=n(4*r-1),b=b,e=0}if not a[b]then
a[b]={E={}}end
N(a[b].E,aO)end
end
for b,c in C(a)do
local ar,ax,at={},{},{}for ap,G in C(c.E)do
N(ar,{_=G._,e=G.e})N(ax,{_=G.l,e=G.e})N(at,{_=G.j,e=G.e})end
local L,M,R,_,l,j
L,_=aa(ar)M,l=aa(ax)R,j=aa(at)a[b].k={_=_,l=l,j=j,L=L,M=M,R=R}end
for b,c in C(a)do
local y,s=ay(c.k._,c.k.l,c.k.j,c.k.L,c.k.M,c.k.R)a[b].Q={y=y,s=s}end
x,ab=0,aw
for b,c in C(a)do
if c.Q.s<ab-60 then
x=b
ab=c.Q.s
end
end
w,ad=0,aw
for b,c in C(a)do
if c.Q.s<ad-60 and b~=x then
w=b
ad=c.Q.s
end
end
q(4,0)if x~=0 and(Y or w==0)then
q(1,a[x].k._)q(2,a[x].k.l)q(3,a[x].k.j)q(4,F+x%F)q(5,ab)elseif w~=0 then
q(1,a[w].k._)q(2,a[w].k.l)q(3,a[w].k.j)q(4,2000+w%F)q(5,ad)end
Y=not Y
end
