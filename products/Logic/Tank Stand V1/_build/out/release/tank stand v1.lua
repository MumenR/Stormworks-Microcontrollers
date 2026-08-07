-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 366 (772 with comment) chars

c=screen
e=c.drawText
i=input.getNumber
h=string.format
function k(j)local b=h("%.0f",j)b=b:reverse():gsub("%d%d%d","%1,"):reverse():gsub("^,","")return b
end
function onTick()_=i(1)a=i(2)g=property.getText("Tank Content")_=k(_).." L"
a=h("%.2f ATM",a)end
function onDraw()d=c.getWidth()f=c.getHeight()e(d/2-#g*2.5,2,g)e(d/2+27-#_*5,f/2-3,_)e(d/2+37-#a*5,f-8,a)end
