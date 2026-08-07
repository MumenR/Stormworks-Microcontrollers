-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 279 (685 with comment) chars

f=output
e=input
l=e.getNumber
j=e.getBool
m=f.setNumber
a=f.setBool
_=0
c=true
d=false
function onTick()b=j(1)if b and _<200 then
_=_+1
end
if b then
c=not c
if c then
d=not d
end
end
k=b and _>0
g=b and _>65
h=b and _>130
i=b and _>195
a(1,k)a(2,g)a(3,h)a(4,i)a(5,c)a(6,d)end
