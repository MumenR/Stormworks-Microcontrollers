-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1358 (1766 with comment) chars

E=table
D=math
v=pairs
function K()local h,x=1,true
while x do
x=false
for t=1,#q do
x=h==q[t].i
if x then
h=h+1
break
end
end
end
return h
end
function B()for h,d in v(q)do
A(h)for t=1,#d.k do
l=d.k[t]A(l.b,l._,l.a,l.c,l.i,l.r)end
A("--------------------")end
A("------------------------------")end
function G(z,y,w,M,F,J)return D.sqrt((z-M)^2+(y-F)^2+(w-J)^2)end
n={{b=540,_=0,a=0,r=540,c=0,i=11},{b=140,_=0,a=0,r=140,c=0,i=22},{b=1000,_=0,a=0,r=1000,c=0,i=33}}q={[1]={k={{b=130,_=0,a=0,c=-1},{b=120,_=0,a=0,c=-2},{b=110,_=0,a=0,c=-3},{b=100,_=0,a=0,c=-4}},g={b={f=10,e=130,j=0},_={f=0,e=0,j=0},a={f=0,e=0,j=0}},i=1,u=1},[3]={k={{b=230,_=0,a=0,c=-1},{b=220,_=0,a=0,c=-2},{b=210,_=0,a=0,c=-3},{b=200,_=0,a=0,c=-4}},g={b={f=10,e=230,j=0},_={f=0,e=0,j=0},a={f=0,e=0,j=0}},i=3,u=1},[5]={k={{b=530,_=0,a=0,c=-1},{b=520,_=0,a=0,c=-2},{b=510,_=0,a=0,c=-3},{b=500,_=0,a=0,c=-4}},g={b={f=10,e=530,j=0},_={f=0,e=0,j=0},a={f=0,e=0,j=0}},i=5,u=1}}H=300/60
L=100/3600
B()for I,d in v(q)do
local o,s,m,z,y,w,C
s=D.huge
m=0
z=d.g.b.f+d.g.b.e
y=d.g._.f+d.g._.e
w=d.g.a.f+d.g.a.e
for t,p in v(n)do
C=G(z,y,w,p.b,p._,p.a)if C<s then
s=C
m=t
end
end
if#d.k<=1 then
o=H*d.u
else
o=L*(d.u^2)/2
end
o=o+.01*n[m].r
A("error:",o,"dist:",s)if s<o then
n[m].r=nil
E.insert(d.k,n[m])E.remove(n,m)end
end
B()for I,p in v(n)do
local h=K()q[h]={k={p},g={b={},_={},a={}},i=h,u=0}end
B()