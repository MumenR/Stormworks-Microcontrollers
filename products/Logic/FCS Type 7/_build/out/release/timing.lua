-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 295 (701 with comment) chars

f=output
e=input
l=e.getNumber
k=e.getBool
m=f.setNumber
b=f.setBool
_=0
c=true
d=false
function onTick()a=k(1)if a and _<10 then
_=_+1
elseif not a then
_=0
end
if a then
c=not c
if c then
d=not d
end
end
i=a and _>0
h=a and _>1
g=a and _>2
j=a and _>3
b(1,i)b(2,h)b(3,g)b(4,j)b(5,c)b(6,d)end
