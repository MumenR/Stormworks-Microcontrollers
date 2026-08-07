-- Author: MumenR
-- GitHub: https://github.com/MumenR/Stormworks-Microcontrollers
-- Workshop: https://steamcommunity.com/profiles/76561199060549727/myworkshopfiles/
--
-- Developed & Minimized using LifeBoatAPI - Stormworks Lua plugin for VSCode
-- https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey
-- Minimized Size: 489 (895 with comment) chars

x=math
y=table.unpack
u=x.sin
t=x.cos
function z(d,_,b)local j,n,k,l,m,o=t(d/2),t(_/2),t(b/2),u(d/2),u(_/2),u(b/2)return{j*n*k+l*m*o,l*n*k-j*m*o,j*m*k+l*n*o,j*n*o-l*m*k}end
function A(F,f,h,i)local a,c,e,g=y(F)local w,v,s=2*(c*i-e*h),2*(e*f-a*i),2*(a*h-c*f)return
f+g*w+(c*s-e*v),h+g*v+(e*w-a*s),i+g*s+(a*v-c*w)end
function J(H,D,E,q,r,p,d,_,b)local f,h,i=A(z(d,_,b),H,D,E)return f+q,h+p,i+r
end
function I(C,B,G,q,r,p,d,_,b)local a,c,e,g=y(z(d,_,b))return A({-a,-c,-e,g},C-q,B-p,G-r)end
