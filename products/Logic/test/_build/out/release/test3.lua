-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 721 (1127 with comment) chars

_=100
o=pairs
local t=r.s()p=60
function l(g)for f=1,#g do
for u=1,#g[f].e do
j=g[f].e[u]k(j.c,j.d,j.b,j.a)end
k(g[f].i,"---")end
k("--------------------")end
g={[1]={e={{c=_,d=_,b=_,a=-60},{c=_,d=_,b=_,a=-40},{c=_,d=_,b=_,a=-20},{c=_,d=_,b=_,a=-0}},m=1,i=40},[2]={e={{c=200,d=_,b=_,a=-80},{c=200,d=_,b=_,a=-60},{c=200,d=_,b=_,a=-40},{c=200,d=_,b=_,a=-20}},m=2,i=60},[3]={e={{c=300,d=_,b=_,a=-140},{c=300,d=_,b=_,a=-120},{c=300,d=_,b=_,a=-_},{c=300,d=_,b=_,a=-80}},m=1,i=80}}l(g)for v,h in o(g)do
for w,n in o(h.e)do
n.a=n.a-1
end
h.i=h.e[#h.e].a
if-h.i>p then
g[v]=nil
else
local f=1
while f<=#h.e do
if-h.e[f].a>p then
table.remove(h.e,f)else
f=f+1
end
end
end
end
l(g)local q=r.s()k(string.format("time: %.8f s",q-t))