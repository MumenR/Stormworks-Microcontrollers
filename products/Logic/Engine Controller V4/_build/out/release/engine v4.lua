-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1282 (1690 with comment) chars

E=true
n=false
A=output
D=input
_=D.getNumber
as=D.getBool
a=A.setNumber
j=A.setBool
y=n
q=n
S=2.5
am=110
r=0
u=0
x=0
v=0
function B(F,L,J,an,W,z,af,min,max)local d,w,h
d=an-W
p=z+d
w=d-af
h=F*d+L*p+J*w
if h>max or h<min then
p=z
h=F*d+L*p+J*w
end
return h,p,d
end
function t(R)if R then
return 1
else
return 0
end
end
function C(e,min,max)if e>=max then
e=max
elseif e<=min then
e=min
end
return e
end
function onTick()ag=_(1)ac=_(2)k=_(3)b=math.abs(_(4))f=_(5)ab=_(6)s=_(7)T=_(8)ah=_(9)Y=_(10)aq=_(11)O=_(12)ae=_(13)P=_(14)ap=_(15)Q=_(16)U=_(17)ai=_(18)V=_(19)ar=_(20)l=_(21)ak=_(22)ao=_(23)X=_(24)g=_(25)==1
c=g and f<S
if k>T then
y=E
elseif k<ah then
y=n
end
H=y and not c
if s>Y then
q=n
elseif s<aq then
q=E
end
o=q and not c
if o then
O=ae
end
N=g and b<.01 and not c
if N then
I,u,r=B(ai,V,ar,O,f,u,r,-l,m)else
I,u,r=0,0,0
end
G=(.4*U)/(ab*.029+2.75)m=1/G
if g and f<Q then
if c then
i=m
else
if b>.01 then
i=b*(m-l)+l
else
i=C(I+l,0,m)end
end
else
i=0
end
al=i*G
if k>am then
P=ap
end
if g and b>.01 and not c then
M,v,x=B(ak*b,ao*b,X*b,P,f,v,x,-100,0)else
M,v,x=0,0,0
end
if c then
K=0
else
K=C((-M/100),0,1)^(1/6)end
aa=o and N
Z=t(c)aj=t(H)ad=t(o)a(1,b*100)a(2,f*60)a(3,k)a(4,s*100)a(5,ag/ac)a(6,al)a(7,i)a(8,K)a(9,Z)a(10,aj)a(11,ad)j(1,g)j(2,c)j(3,H)j(4,o)j(5,aa)end
