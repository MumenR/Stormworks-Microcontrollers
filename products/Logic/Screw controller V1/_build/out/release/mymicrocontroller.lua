-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 624 (1030 with comment) chars
t="%.0f"

c=255
l=input
e=screen
k=e.drawText
d=e.drawLine
g=e.drawRectF
f=e.setColor
h=math.floor
p=string.format
n=l.getNumber
m=l.getBool
function onTick()i=p(t,n(1)*100)j=p(t,n(2)*100)r=m(1)s=m(2)end
function onDraw()_=e.getWidth()a=e.getHeight()b=h((a-5)/2)q=h(i*(a-9)/200)o=h(j*(a-9)/200)if r then
f(c,0,0)g(_/4-4,b,9,q+1)else
f(0,c,0)g(_/4-4,b,9,-q)end
if s then
f(c,0,0)g(_*3/4-4,b,9,o+1)else
f(0,c,0)g(_*3/4-4,b,9,-o)end
f(128,128,128)d(_/4-5,b,_/4+5,b)d(_*3/4-5,b,_*3/4+5,b)f(c,c,c)k(_/4-#i*2.5,a-6,i)k(_*3/4-#j*2.5,a-6,j)d(_/4-5,2,_/4-5,a-7)d(_/4+5,2,_/4+5,a-7)d(_*3/4-5,2,_*3/4-5,a-7)d(_*3/4+5,2,_*3/4+5,a-7)end
