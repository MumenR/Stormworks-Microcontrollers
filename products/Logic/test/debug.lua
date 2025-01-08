i5flip={x=12,y=12,w=12,h=12,a=false,p=false}

function onTick()
isP1 = input.getBool(1)
isP2 = input.getBool(2)

in1X = input.getNumber(3)
in1Y = input.getNumber(4)
in2X = input.getNumber(5)
in2Y = input.getNumber(6)

if isP1 and isInRectO(i5flip,in1X,in1Y) or isP2 and isInRectO(i5flip,in2X,in2Y) then
if not i5flip.p then
i5flip.a=not i5flip.a
i5flip.p=true
end
else
i5flip.p=false
end
output.setBool(1,i5flip.a)

end

function onDraw()

if i5flip.a then
setC(0,83,0)
screen.drawRectF(12,12,12,12)
setC(0,0,0)
screen.drawRectF(15,16,6,3)
setC(71,0,0)
screen.drawRectF(13,13,10,3)
else
setC(71,71,71)
screen.drawRectF(12,12,12,12)
setC(0,0,0)
screen.drawRectF(15,17,6,3)
setC(71,0,0)
screen.drawRectF(13,20,10,3)
end

end

function setC(r,g,b,a)
if a==nil then a=255 end
screen.setColor(r,g,b,a)
end

function isInRectO(o,px,py)
return px>=o.x and px<=o.x+o.w and py>=o.y and py<=o.y+o.h
end