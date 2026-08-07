-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1488 (1896 with comment) chars

I=true
p=false
Q=output
L=input
b=L.getNumber
at=L.getBool
a=Q.setNumber
i=Q.setBool
_=property.getNumber
r=p
v=p
ae=2.5
ad=13.7
t=0
z=0
y=0
s=0
function A(G,F,J,T,ap,P,ao,min,max)local e,w,k
e=T-ap
m=P+e
w=e-ao
k=G*e+F*m+J*w
if k>max or k<min then
m=P
k=G*e+F*m+J*w
end
return k,m,e
end
function u(S)if S then
return 1
else
return 0
end
end
function E(g,min,max)if g>=max then
g=max
elseif g<=min then
g=min
end
return g
end
function onTick()ab=b(1)R=b(2)l=b(3)d=math.abs(b(4))f=b(5)ar=b(6)x=b(7)h=b(8)==1
ah=_("max temp")aa=_("min temp")ac=_("thermal throttling temp")aq=_("max battery")am=_("min battery")H=_("idling rps")aj=_("idling generation rps")B=b(9)U=_("thermal throttling rps")ak=_("max rps")W=_("idling P")al=_("idling I")af=_("idling D")q=_("idling rps fuel")an=_("clutch P")ai=_("clutch I")as=_("clutch D")c=h and f<ae
if l>ah then
r=I
elseif l<aa then
r=p
end
C=r and not c
if x>aq then
v=p
elseif x<am then
v=I
end
o=v and not c
if o then
H=aj
end
D=h and d<.01 and not c
if D then
N,z,t=A(W,al,af,H,f,z,t,-q,n)else
N,z,t=0,0,0
end
K=(.4*ad)/(ar*.029+2.75)n=1/K
if h and f<ak then
if c then
j=n
else
if d>.01 then
j=d*(n-q)+q
else
j=E(N+q,0,n)end
end
else
j=0
end
Z=j*K
if l>ac then
B=U
end
if h and d>.01 and not c then
M,s,y=A(an*d,ai*d,as,B,f,s,y,-100,0)else
M,s,y=0,0,0
end
if c then
O=0
else
O=E((-M/100),0,1)^(1/6)end
V=o and D
X=u(c)ag=u(C)Y=u(o)a(1,d*100)a(2,f*60)a(3,l)a(4,x*100)a(5,ab/R)a(6,Z)a(7,j)a(8,O)a(9,X)a(10,ag)a(11,Y)i(1,h)i(2,c)i(3,C)i(4,o)i(5,V)end
