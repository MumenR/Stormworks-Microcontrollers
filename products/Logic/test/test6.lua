function quatFromEuler(ex,ey,ez)
    local cx,cy,cz, sx,sy,sz = math.cos(ex/2),math.cos(ey/2),math.cos(ez/2), math.sin(ex/2),math.sin(ey/2),math.sin(ez/2)
    return {
        cx*cy*cz + sx*sy*sz,
        sx*cy*cz - cx*sy*sz,
        cx*sy*cz + sx*cy*sz,
        cx*cy*sz - sx*sy*cz
    }
end

function rotateVec(q, x,y,z)
    local qx,qy,qz,qw = table.unpack(q)
    local tx, ty, tz = 2*(qy*z - qz*y), 2*(qz*x - qx*z), 2*(qx*y - qy*x)
    return
        x + qw*tx + (qy*tz - qz*ty),
        y + qw*ty + (qz*tx - qx*tz),
        z + qw*tz + (qx*ty - qy*tx)
end

function local2World(Lx,Ly,Lz,Px,Py,Pz,ex,ey,ez)
    local x,y,z = rotateVec(quatFromEuler(ex,ey,ez),Lx,Ly,Lz)
    return x+Px, y+Pz, z+Py
end

function world2Local(Wx,Wy,Wz,Px,Py,Pz,ex,ey,ez)
    local qx, qy, qz, qw = table.unpack(quatFromEuler(ex,ey,ez))
    return rotateVec({-qx, -qy, -qz, qw},Wx - Px,Wy - Pz,Wz - Py)
end
