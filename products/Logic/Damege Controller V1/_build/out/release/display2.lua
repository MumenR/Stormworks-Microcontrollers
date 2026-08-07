-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 435 (841 with comment) chars

c=property
d=output
e=input
f=screen
_=f.drawText
b=f.setColor
m=e.getNumber
a=e.getBool
q=d.setNumber
p=d.setBool
n=c.getNumber
r=c.getBool
o=c.getText
function onTick()h=a(1)i=a(2)j=a(3)k=a(30)g=a(31)l=a(32)end
function onDraw()b(0,255,0)if h then
_(6,1,"FIRE")end
if j then
b(255,0,0)_(4,7,"PUMP")b(0,255,0)elseif i then
_(4,7,"DRAIN")end
if k then
_(5,13,"O2 IN")end
if g then
_(4,19,"AIRIN")end
if l then
_(2,25,"AIROUT")end
end
