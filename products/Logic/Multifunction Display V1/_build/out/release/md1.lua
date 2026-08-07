-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1925 (2333 with comment) chars
at="%02.0f"
as=":"
ar="%.2f"
aq="%d"

o=255
r=property
P=output
z=input
y=math
j=screen
c=j.drawText
q=j.drawLine
t=j.setColor
k=y.floor
d=string.format
e=z.getNumber
x=z.getBool
am=P.setNumber
an=P.setBool
B=r.getNumber
ap=r.getBool
E=r.getText
n=0
function ae(a,min,max)if a>=max then
return max
elseif a<=min then
return min
else
return a
end
end
function Z(a)local N,min,v,p
N=d(aq,k(a/3600))v=d(at,k(a%60+.5))if a>=36000 or a<0 then
p="-:--:--"
elseif a<3600 then
min=d(aq,k((a/60)%60))p=min..as..v
else
min=d(at,k((a/60)%60))p=N..as..min..as..v
end
return p
end
function i(a)return af(k(a+.5))end
function ao(a,D,ak,ag,aj)local m,s,g
if a*D<1 then
s=ag
g=aj
else
s=D
g=ak
end
a=a*s
if a<1 then
m=d("%.3f",a)..g
elseif a<10 then
m=d(ar,a)..g
elseif a<100 then
m=d("%.1f",a)..g
else
m=d("%.0f",a)..g
end
return m
end
function af(W)local Y=tostring(W)local R,l,ad=Y:match("([%-]?)(%d+)(%.?%d*)")l=l:reverse():gsub("(%d%d%d)","%1,"):reverse()l=l:gsub("^,","")return R..l..ad
end
function h()t(o,o,o)end
function f()t(o,o,32)end
function onTick()S=B("Distance units (Large)")ai=E("Units text (Large)")K=B("Distance units (Small)")C=E("Units text (Small)")ah=e(1)Q=e(2)T=e(3)ac=e(4)aa=e(5)U=e(6)*60
V=e(7)*1000
X=e(8)G=x(1)ab=x(2)if G then
n=n+1
if ab then
w=n*50-250
n=0
end
else
w=0
n=0
end
L=i(ah)H=i(Q)M=i(T)A=i(ac)I=i(aa)O=Z(U)F=d(ar,V*S)J=d(ar,X*K)if G then
u=i(ae(w*K,0,y.huge))else
u="--"
end
end
function onDraw()b=j.getWidth()al=j.getHeight()t(0,0,64)q(0,14,b,14)q(0,28,b,28)q(0,48,b,48)q(0,56,b,56)_=2
f()c(b/4-12,_,"RPM-L")c(b*3/4-12,_,"RPM-R")_=_+6
h()c(b/4-2.5*#L,_,L)c(b*3/4-2.5*#H,_,H)_=_+8
f()c(b/4-12,_,"TMP-L")c(b*3/4-12,_,"TMP-R")_=_+6
h()c(b/4-2.5*#M,_,M)c(b*3/4-2.5*#A,_,A)_=_+8
f()c(1,_,"FU")c(b-5,_,"L")h()c(b-11-5*#I,_,I)_=_+6
f()c(2,_,"EL")c(b-10,_,ai)h()c(b-11-5*#F,_,F)_=_+6
c(b-11-5*#O,_,O)_=_+8
f()c(1,_,"ECO")c(b-10,_,C)h()c(b-11-5*#J,_,J)_=_+8
f()c(1,_,"SOS")c(b-10,_,C)h()c(b-11-5*#u,_,u)end
