-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 965 (1371 with comment) chars
C="R"
B="%.0f"

e=255
p=input
h=screen
n=h.drawRect
i=h.drawLine
g=h.drawText
k=h.drawRectF
f=h.setColor
m=math.floor
r=string.format
t=p.getNumber
j=p.getBool
function onTick()l=r(B,t(1)*100)o=r(B,t(2)*100)u=j(1)x=j(2)v=j(3)w=j(4)z=j(5)end
function onDraw()A,y=h.getWidth(),h.getHeight()a=32
c=32
_=0
d=y-c
b=m((c-5)/2)+d
q=m(l*(c-9)/200)s=m(o*(c-9)/200)if u then
f(e,0,0)k(a/4-4+_,b,9,q+1)f(0,e,0)g(a/4-2+_,b+c/8,C)else
f(0,e,0)k(a/4-4+_,b,9,-q)end
if x then
f(e,0,0)k(a*3/4-4+_,b,9,s+1)f(0,e,0)g(a*3/4-2+_,b+c/8,C)else
f(0,e,0)k(a*3/4-4+_,b,9,-s)end
f(0,e,0)i(a/4-5+_,b,a/4+5+_,b)i(a*3/4-5+_,b,a*3/4+5+_,b)f(0,e,0)g(a/4-#l*2.5+_,c-6+d,l)g(a*3/4-#o*2.5+_,c-6+d,o)i(a/4-5+_,2+d,a/4-5+_,c-7+d)i(a/4+5+_,2+d,a/4+5+_,c-7+d)i(a*3/4-5+_,2+d,a*3/4-5+_,c-7+d)i(a*3/4+5+_,2+d,a*3/4+5+_,c-7+d)if v then
f(0,e,0)n(_+a+1,b-10,17,8)g(_+a+3,b-8,"TCT")end
if w then
f(0,e,0)n(_+a+1,b+2,17,8)g(_+a+3,b+4,"BOW")end
if z then
f(0,e,0)n(_+a+21,b-10,22,8)g(_+a+23,b-8,"STOP")end
end
