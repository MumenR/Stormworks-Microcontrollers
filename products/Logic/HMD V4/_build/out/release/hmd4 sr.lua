
m=255
ao=pairs
aG=property
ay=output
ax=input
M=math
C=screen
au=string.format
aC=C.drawText
D=M.floor
ap=C.setColor
k=C.drawLine
aE=M.tan
f=M.sin
j=M.cos
as=M.sqrt
s=ax.getNumber
bb=ax.getBool
ba=ay.setNumber
bd=ay.setBool
aM=aG.getNumber
aK=aG.getBool
B={}R=M.pi*2
at=(58/360)*R
function aR(h,g,aX,r,t,aT)return as((h-r)^2+(g-t)^2+(aX-aT)^2)end
function aD(X,Z,ab,am,ah,ag,o,p,n)local K,F,H,J,G,L,I,l,e,x,al,af,b,V,a,ae
X=X-am
Z=Z-ag
ab=ab-ah
K=j(n)*j(p)F=j(n)*f(p)*f(o)-f(n)*j(o)H=j(n)*f(p)*j(o)+f(n)*f(o)J=X
G=f(n)*j(p)L=f(n)*f(p)*f(o)+j(n)*j(o)I=f(n)*f(p)*j(o)-j(n)*f(o)l=ab
e=-f(p)x=j(p)*f(o)al=j(p)*j(o)af=Z
ae=((K*L-F*G)*al+(H*G-K*I)*x+(F*I-H*L)*e)b=0
a=0
V=0
if ae~=0 then
b=((F*I-H*L)*af+(J*L-F*l)*al+(H*l-J*I)*x)/ae
a=-((K*I-H*G)*af+(J*G-K*l)*al+(H*l-J*I)*e)/ae
V=((K*L-F*G)*af+(J*G-K*l)*x+(F*l-J*L)*e)/ae
end
return b,V,a
end
function aO(P,A,N)local Y,ac,W
Y=E/2+(P/A)*(l/2)/aE(at/2)ac=l/2-(N/A)*(l/2)/aE(at/2)W=A>0
return Y,ac,W
end
function aQ(X,Z,ab,o,p,n)local P,A,N,Y,ac,W
P,A,N=aD(X,Z,ab,am,ah,ag,o,p,n)P,A,N=aD(P,A,N,0,0,0,-aU,aV,0)Y,ac,W=aO(P,A,N)return Y,ac,W
end
function bc(b,a)return b>=0 and b<=E and a>=0 and a<=l
end
function aS(c,d,y,Q,q,aa,v)local w,aB,aF,aw,aW,S
function w(h,g,r,t)local U,O,len,u,aJ,aI,az,av
U,O=r-h,t-g
len=as(U^2+O^2)U,O=U/len,O/len
u=1
for e=0,len,u*2 do
aJ,aI=h+U*e,g+O*e
az,av=h+U*(e+u),g+O*(e+u)if e+u<len then
k(aJ,aI,az,av)end
end
end
function aB(b,a,E,l)w(b,a,b,a+l+2)w(b,a,b+E+2,a)w(b+E,a+l,b,a+l)w(b+E,a+l,b+E,a)end
function aF(h,g,r,t,aH,aA)w(h,g,r,t)w(r,t,aH,aA)w(aH,aA,h,g)end
function aw(b,a,_)local ar=M.atan(1,_)for e=0,R,ar*2 do
local h,g,r,t
h=b+_*j(e)g=a+_*f(e)r=b+_*j(e+ar)t=a+_*f(e+ar)k(h,g,r,t)end
end
function aW(b,a,_)local u=10/360*R
for e=0,R-u,u do
local h,g,r,t
h=b+_*j(e)g=a+_*f(e)r=b+_*j(e+u)t=a+_*f(e+u)k(h,g,r,t)end
end
S=function(b,a,_,ai)drawLine=ai and w or k
drawRect=ai and aB or C.drawRect
drawTriangle=ai and aF or C.drawTriangle
drawCircle=ai and aw or C.drawCircle
if y==0 then
drawRect(b-_,a-_,_*2,_*2)elseif y<=2 then
drawLine(b-_,a,b,a+_)drawLine(b,a+_,b+_,a)drawLine(b+_,a,b,a-_)drawLine(b,a-_,b-_,a)if y==2 then
_=(_==3)and(_+1)or _
drawRect(b-_,a-_,_*2,_*2)end
elseif y==3 then
drawTriangle(c,d-_,c+_/2*3^.5,d+_/2,c-_/2*3^.5,d+_/2)elseif y==4 then
drawCircle(c,d,_)elseif y==5 then
if _==3 then
drawLine(b-_,a-_,b-_,a-_+1)drawLine(b-_,a+_,b-_,a+_+1)drawLine(b+_,a-_,b+_,a-_+1)drawLine(b+_,a+_,b+_,a+_+1)else
drawLine(b-_,a-_,b-_/2,a-_)drawLine(b-_,a-_,b-_,a-_/2)drawLine(b-_,a+_,b-_/2,a+_)drawLine(b-_,a+_,b-_,a+_/2)drawLine(b+_,a-_,b+_/2,a-_)drawLine(b+_,a-_,b+_,a-_/2)drawLine(b+_,a+_,b+_/2,a+_)drawLine(b+_,a+_,b+_,a+_/2)end
elseif y==6 then
if _==3 then
drawLine(b-_,a,b-_,a+1)drawLine(b,a+_,b,a+_+1)drawLine(b+_,a,b+_,a+1)drawLine(b,a-_,b,a-_+1)else
drawLine(b-_,a,b-_/2,a+_/2)drawLine(b-_,a,b-_/2,a-_/2)drawLine(b,a+_,b+_/2,a+_/2)drawLine(b,a+_,b-_/2,a+_/2)drawLine(b+_,a,b+_/2,a+_/2)drawLine(b+_,a,b+_/2,a-_/2)drawLine(b,a-_,b+_/2,a-_/2)drawLine(b,a-_,b-_/2,a-_/2)end
end
end
ak=function()if q==1 then
S(c,d,3,q==2)elseif q==3 then
k(c-1,d,c+2,d)k(c,d-1,c,d+2)elseif q==4 then
k(c+4,d,c-5,d)k(c,d+4,c,d-5)elseif q==5 then
k(c-4,d-4,c+5,d+5)k(c+4,d-4,c-5,d+5)elseif q==6 then
k(c+4,d,c+1,d)k(c-4,d,c-1,d)k(c,d+4,c,d+1)k(c,d-4,c,d-1)elseif q==7 then
k(c-4,d-4,c-1,d-1)k(c+4,d+4,c+1,d+1)k(c+4,d-4,c+1,d-1)k(c-4,d+4,c-1,d+1)end
end
aj={{0,m,0},{16,16,m},{m,0,0},{m,m,0},{0,m,m},{m,0,m},{0,m,0},{0,m,0},{0,m,0},{m,m,m}}if aj[Q+1]then
ap(aj[Q+1][1],aj[Q+1][2],aj[Q+1][3])else
ap(0,m,0)end
if aa==1 then
if v%12>=6 then
S(c,d,4,q==2)ak()end
elseif aa==2 then
if v%30>=15 then
S(c,d,4,q==2)ak()end
elseif aa==3 then
ap(127*f(v/30)+128,127*j(v/30)+128,127*f(v/15)+128)S(c,d,4,q==2)ak()else
S(c,d,4,q==2)ak()end
end
function onTick()am=s(27)ah=s(28)ag=s(29)o=s(30)p=s(31)n=s(32)aV=s(9)*R
aU=s(10)*R
aY=aM("Radar delete tick")aP=aM("Distance Units")aZ=aK("radar ID")aN=aK("radar distance")for z,i in ao(B)do
i.v=i.v+1
i.T=i.T+1
if i.T>60^3*10 then
i.T=0
end
end
for e=0,5 do
x=e>1 and 2 or 0
local ad=s(e*4+4+x)z=ad%1000
if z~=0 then
B[z]={b=s(e*4+1+x),a=s(e*4+2+x),V=s(e*4+3+x),v=0,y=D(ad/(10^3))%10,Q=D(ad/(10^4))%10,q=D(ad/(10^5))%10,aa=D(ad/(10^6))%10,T=(B[z]and B[z].T)or 0}end
end
for z,i in ao(B)do
if i.v>aY then
B[z]=nil
end
end
ba(30,#B)end
function onDraw()E=C.getWidth()l=C.getHeight()for z,i in ao(B)do
h,g,b_=aQ(i.b,i.a,i.V,o,p,n)h=D(h)g=D(g)if b_ then
aS(h,g,i.y,i.Q,i.q,i.aa,i.T)if aZ then
aL=tostring(z)aC(h+1-2.5*#aL,g-10,aL)end
if aN then
an=aR(am,ag,ah,i.b,i.a,i.V)*aP
if an>=10 then
aq=au("%.0f",D(an+.5))else
aq=au("%.1f",D(an*10+.5)/10)end
aC(h+1-2.5*#aq,g+6,aq)end
end
end
end
