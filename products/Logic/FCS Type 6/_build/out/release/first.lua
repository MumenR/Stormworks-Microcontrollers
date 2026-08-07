-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 696 (1102 with comment) chars

n=output
o=input
a=table
d=a.insert
c=o.getNumber
p=o.getBool
j=n.setNumber
k=n.setBool
b={}e={}g=1
f=0
function r(a)local max,min=a[1],a[1]for _=2,#a do
if a[_]>max then
max=a[_]elseif a[_]<min then
min=a[_]end
end
return(max+min)/2
end
function onTick()i={}for _=1,8 do
if p(_)then
d(i,{c(_*4-3),c(_*4-2),c(_*4-1),c(_*4)})if c(_*4)+1>g then
g=c(_*4)+1
end
end
end
if#i>0 then
if i[1][4]==0 then
b={}end
d(b,i)else
b={}end
if#b==g then
e={}for _=1,#b[1]do
local l={}for h=1,3 do
local m={}for q=1,#b do
d(m,b[q][_][h])end
d(l,r(m))end
d(e,l)end
f=1
end
for _=1,24 do
j(_,0)k(_,false)end
if f<=g then
for _=1,#e do
k(_,true)for h=1,3 do
j(3*(_-1)+h,e[_][h])end
end
j(32,f)f=f+1
else
e={}end
end
