-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 1110 (1518 with comment) chars

r={y=function(b,h)local e={}for _=1,#b do
e[_]={}for a=1,#b[1]do
e[_][a]=b[_][a]+h[_][a]end
end
return e
end,sub=function(b,h)local e={}for _=1,#b do
e[_]={}for a=1,#b[1]do
e[_][a]=b[_][a]-h[_][a]end
end
return e
end,v=function(b,h)local e={}for _=1,#b do
e[_]={}for a=1,#h[1]do
local n=0
for d=1,#b[1]do
n=n+b[_][d]*h[d][a]end
e[_][a]=n
end
end
return e
end,x=function(b)local f,g,c=#b,{},{}for _=1,f do
g[_]={}c[_]={}for a=1,f do
c[_][a]=b[_][a]g[_][a]=(_==a)and 1 or 0
end
end
for _=1,f do
local k=c[_][_]if k~=0 then
for a=1,f do
c[_][a]=c[_][a]/k
g[_][a]=g[_][a]/k
end
for d=1,f do
if d~=_ then
local o=c[d][_]for a=1,f do
c[d][a]=c[d][a]-o*c[_][a]g[d][a]=g[d][a]-o*g[_][a]end
end
end
end
end
return g
end,w=function(b)local j={}for _=1,#b[1]do
j[_]={}for a=1,#b do
j[_][a]=b[a][_]end
end
return j
end,q=function(i,f)local m,l,c=#i,#i[1],{}for _=1,m*f do
c[_]={}for a=1,l*f do
c[_][a]=0
end
end
for d=0,f-1 do
local t,p=d*m,d*l
for _=1,m do
for a=1,l do
c[t+_][p+a]=i[_][a]end
end
end
return c
end}function s(c)for _=1,#c do
u(table.concat(c[_],"\t"))end
end
b={{1}}b={{1,2,3},{4,5,6},{7,8,9}}s(r.q(b,3))