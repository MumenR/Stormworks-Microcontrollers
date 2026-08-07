cb=":"
ca="WP"
c_="%d"
bZ="%02.0f"

R=.5
v=360
aZ=tostring
au=false
aV=property
bk=output
bf=input
aa=math
O=screen
az=O.drawRect
ar=O.drawRectF
C=string.format
x=O.drawText
br=O.drawCircle
h=aa.floor
P=O.drawLine
bm=aa.tan
bg=aa.sqrt
d=aa.sin
b=aa.cos
aD=aa.atan
aO=O.setColor
L=aa.pi
q=bf.getNumber
bW=bf.getBool
bo=bk.setNumber
bX=bk.setBool
av=aV.getNumber
w=aV.getBool
U=L*2
aU=(58/v)*U
function K()aO(0,255,0)end
function aj()aO(0,0,0)end
function ax(c,o)if c>=0 then
aM=aD(o/c)elseif o>=0 then
aM=aD(o/c)+L
else
aM=aD(o/c)-L
end
return aM
end
function be(c,min,max)if c>=max then
c=max
elseif c<=min then
c=min
end
return c
end
function M(l,n,m,ap,aq,ae,e,g,f)local y,B,W,V,Z,X,T,u,s,p,z,aB,c,A,o,af
l=l-ap
n=n-ae
m=m-aq
y=b(f)*b(g)B=b(f)*d(g)*d(e)-d(f)*b(e)W=b(f)*d(g)*b(e)+d(f)*d(e)V=l
Z=d(f)*b(g)X=d(f)*d(g)*d(e)+b(f)*b(e)T=d(f)*d(g)*b(e)-b(f)*d(e)u=m
s=-d(g)p=b(g)*d(e)z=b(g)*b(e)aB=n
af=((y*X-B*Z)*z+(W*Z-y*T)*p+(B*T-W*X)*s)c=0
o=0
A=0
if af~=0 then
c=((B*T-W*X)*aB+(V*X-B*u)*z+(W*u-V*T)*p)/af
o=-((y*T-W*Z)*aB+(V*Z-y*u)*z+(W*u-V*T)*s)/af
A=((y*X-B*Z)*aB+(V*Z-y*u)*p+(B*u-V*X)*s)/af
end
return c,A,o
end
function aw(k,i,j,ap,aq,ae,e,g,f)local bh,aR,aQ
bh=b(f)*b(g)*k+(b(f)*d(g)*d(e)-d(f)*b(e))*j+(b(f)*d(g)*b(e)+d(f)*d(e))*i
aR=d(f)*b(g)*k+(d(f)*d(g)*d(e)+b(f)*b(e))*j+(d(f)*d(g)*b(e)-b(f)*d(e))*i
aQ=-d(g)*k+b(g)*d(e)*j+b(g)*b(e)*i
return bh+ap,aQ+ae,aR+aq
end
function by(c,o,A,as)local t,r
t=ax(bg(c^2+o^2),A)r=ax(o,c)I=bg(c^2+o^2+A^2)if as then
return t,r,I
else
return t/(L*2),r/(L*2),I
end
end
function bi(t,r,I,as)local c,o,A
if not as then
t=t*L*2
r=r*L*2
end
c=I*b(t)*d(r)o=I*b(t)*b(r)A=I*d(t)return c,o,A
end
function bQ(t,r,I,as)local c,o,A
if not as then
t=t*L*2
r=r*L*2
end
c=I*d(r)o=I*b(r)*b(t)A=I*b(r)*d(t)return c,o,A
end
function aA(k,i,j)local H,G,F
H=Q/2+(k/i)*(u/2)/bm(aU/2)G=u/2-(j/i)*(u/2)/bm(aU/2)F=i>0
return H,G,F
end
function bp(l,n,m,e,g,f)local k,i,j,H,G,F
k,i,j=M(l,n,m,0,0,0,e,g,f)k,i,j=M(k,i,j,0,0,0,-ag,al,0)H,G,F=aA(k,i,j)return H,G,F
end
function aC(t,r,aN,aK,aE)local l,n,m,H,G,F
l,n,m=bi(t,r,1,au)l,n,m=M(l,n,m,0,0,0,aN,aK,aE)H,G,F=bp(l,n,m,e,g,f)return H,G,F
end
function at(t,r,aN,aK,aE)local l,n,m,H,G,F
l,n,m=bQ(t,r,1,au)l,n,m=M(l,n,m,0,0,0,aN,aK,aE)H,G,F=bp(l,n,m,e,g,f)return H,G,F
end
function bT(_,a,E,J)local y,B,am
y=be((a-J)/(_-E),-1000,1000)B=a-y*_
am=2*b(ax(E-_,J-a))for c=_,E-am,am*2 do
if ad(c,y*c+B)then
P(c,y*c+B,c+am,y*(c+am)+B)end
end
end
function ad(c,o)return c>=0 and c<=Q and o>=0 and o<=u
end
function aI(bH,bR)return#aZ(h(bH*bR+R))end
function onTick()aL=av("Speed Units")aJ=av("Altitude Units")aY=av("Distance Units")Y=aI(500,aL)ab=aI(30000,aJ)bJ=be(aI(150000,aY),3,100)ap=q(1)aq=q(2)ae=q(3)e=q(4)g=q(5)f=q(6)bP=q(21)*aJ
bu=q(2)*aJ
aS=q(13)*aL
bd=q(20)*aL
N=q(17)*U
al=q(9)*U
ag=q(10)*U
bD=q(22)bG=q(23)bA=q(24)aG=q(25)*aY
ac=q(26)bF=q(27)==1
bY=q(28)==1
b_=w("air speed")bc=w("ground speed")ai=w("main speed")bx=w("air altitude")bv=w("ground altitude")bK=w("magnetic heading")aW=w("attitude bars")bz=w("horizon line")bt=w("center marker")bO=w("laser direction")bN=w("waypoint marker")bB=w("waypoint marker label")bI=w("waypoint marker distance")bS=w("waypoint distance")bM=w("waypoint arrival time")bn=h(av("Minimum angle for attitude bars"))if bO then
k,i,j=M(0,0,-1,0,0,0,e,g,f)k,i,j=M(k,i,j,0,0,0,U/4,0,0)bU,bw,bV=by(k,i,j,au)bo(1,bw*8)bo(2,bU*8)end
end
function onDraw()Q=O.getWidth()u=O.getHeight()K()if bt then
k,i,j=M(0,1,0,0,0,0,-ag,al,0)_,a,D=aA(k,i,j)if D then
br(_,a,3)P(_+3,a,_+10,a)P(_-3,a,_-10,a)P(_,a-3,_,a-8)end
end
if bz then
local ba=5
if not bt then
ba=0
end
for s=ba,180,45 do
for p=-1,1,2 do
_,a,D=aC(0,p*s/v,0,N,0)E,J,ah=aC(0,p*(s+45)/v,0,N,0)if D and ah then
P(_,a,E,J)end
end
end
elseif aW then
for p=-1,1,2 do
_,a,D=aC(0,p*5/v,0,N,0)E,J,ah=aC(0,p*15/v,0,N,0)if D and ah then
P(_,a,E,J)end
end
end
if aW then
for s=bn,175,bn do
for p=-1,1,2 do
for z=-1,1,2 do
_,a,D=at(z*s/v,p*12/v,0,N,0)E,J,ah=at(z*s/v,p*5/v,0,N,0)bq,bs,bL=at(z*(s-1)/v,p*12/v,0,N,0)aX,aT,bE=at(z*s/v,p*16/v,0,N,0)if D and ah and bL and bE then
if ad(_,a)or ad(E,J)then
if z==1 then
P(_,a,E,J)else
bT(E,J,_,a)end
end
if ad(_,a)or ad(bq,bs)then
P(_,a,bq,bs)end
if ad(aX,aT)then
x(aX-2.5*#aZ(z*s),aT-3,z*s)end
end
end
end
end
end
if bK then
l,n,m=aw(0,1,0,0,0,0,-ag,al,0)l,n,m=aw(l,n,m,0,0,0,e,g,f)aF=ax(n,l)/U
l,n,m=aw(0,0,1,0,0,0,-ag,al,0)l,n,m=aw(l,n,m,0,0,0,e,g,f)if m>0 then
p=1
else
p=-1
end
for s=0,p*355,p*5 do
k,i,j=bi(19.5/v,s/v-p*aF,1,au)_,a,D=aA(k,i,j)if D then
P(_,a+2,_,a-2)if s%10==0 then
x(_-4,a-7,C("%02d",p*s/10))end
end
end
_=h(Q/2)aF=C("%03.0f",v*((-N/U)%1))aj()ar(_-10,9,20,11)K()az(_-9,10,17,8)O.drawTextBox(_-8,11,16,7,aF,0,0)end
if bF then
k,i,j=M(bD,bG,bA,ap,aq,ae,e,g,f)k,i,j=M(k,i,j,0,0,0,-ag,al,0)if aG>=10 then
ak=C("%.0f",h(aG+R))else
ak=C("%.1f",h(aG*10+R)/10)end
if bN then
_,a,D=aA(k,i,j)_=h(_)a=h(a)if D then
K()br(_,a,5)if bB then
x(_-4,a-11,ca)end
if bI then
x(_+1-2.5*#ak,a+7,ak)end
end
end
if bS then
_,a=h(Q/5),h(3*u/5)K()x(_-4-5*bJ,a+1,ca)x(_+8-5*#ak,a+1,ak)end
if bM then
_,a=h(Q/5),h(3*u/5)bC=C(c_,h(ac/3600))bj=C(bZ,h(ac%60+R))if ac<3600 then
aH=C(c_,h((ac/60)%60))ay=aH..cb..bj
elseif ac>=36000 then
ay="-:--:--"
else
aH=C(bZ,h((ac/60)%60))ay=bC..cb..aH..cb..bj
end
K()x(_+8-5*#ay,a+8,ay)end
end
if ai then
aP=aS
bb=bd
bl="AS"
else
aP=bd
bb=aS
bl="GS"
end
if(ai and bc)or(not ai and b_)then
_,a=h(Q/5),h(u/3)ao=C(c_,h(aP+R))aj()ar(_+5-5*Y,a,5*Y+5,11)K()az(_+6-5*Y,a+1,5*Y+2,8)x(_+8-5*#ao,a+3,ao)end
if(ai and b_)or(not ai and bc)then
ao=C(c_,h(bb+R))aj()ar(_-5-5*Y,a+10,5*Y+13,7)K()x(_-4-5*Y,a+11,bl)x(_+8-5*#ao,a+11,ao)end
if bx then
_,a=h(4*Q/5),h(u/3)an=C(c_,h(bu+R))S=2*ab
aj()ar(_-S,a,5+5*ab,11)K()az(_+1-S,a+1,2+5*ab,8)x(_+3+1.5*S-5*#an,a+3,an)end
if bv then
_,a=h(4*Q/5),h(2*u/3)an=C(c_,h(bP+R))S=2*ab
aj()ar(_-5-S,a,15+5*ab,11)K()x(_-4-S,a+3,"AG")az(_+6-S,a+1,2+5*ab,8)x(_+8+1.5*S-5*#an,a+3,an)end
end
