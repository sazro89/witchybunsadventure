pico-8 cartridge // http://www.pico-8.com
version 34
__lua__

-- Systems
function load_systems()
  -- Applies friction
  s_friction=sys({"phys"},function(e)
    local p=e.phys
    p.xv*=1-p.fric
    p.yv*=1-p.fric
    if (abs(p.xv)<p.fric) p.xv=0
    if (abs(p.yv)<p.fric) p.yv=0
  end)

  -- Walking
  s_walking=sys({"phys","ctrl"},function(e)
    local p=e.phys
    -- local c=e.ctrl

    if(btn(0)) p.xv-=p.acc
    if(btn(1)) p.xv+=p.acc
    if(btn(2)) p.yv-=p.acc
    if(btn(3)) p.yv+=p.acc
  end)

  -- Player Animations
  s_playeranim=sys({"phys","ctrl","draw"},function(e)
    local p=e.phys
    local c=e.ctrl
    local d=e.draw

    -- current animation
    -- if moving slow, use player input to determine direction
    if abs(p.xv)+abs(p.yv)<=2 then
     d.curanim=
       (btn(0) or btn(1))  and c.anims.side or
       btn(3)              and c.anims.down or
       btn(2)              and c.anims.up or
       d.curanim
    -- otherwise use velocity
    else
     d.curanim=
       abs(p.xv)>abs(p.yv) and c.anims.side or
       p.yv>0              and c.anims.down or
       p.yv<0              and c.anims.up or
       d.curanim
    end

    -- flip horizontally
    d.flip = p.xv==0 and d.flip or p.xv>0

    -- set animation on or off
    d.moving = (p.xv!=0 or p.yv!=0) and true or false
  end)

  -- Constrain Velocity
  s_maxvelocity=sys({"phys"},function(e)
    local p=e.phys
    p.xv=mid(p.xv,-p.max,p.max)
    p.yv=mid(p.yv,-p.max,p.max)
    if(abs(p.xv)<0.01) p.xv=0
    if(abs(p.yv)<0.01) p.yv=0

    local totalvel=abs(p.xv)+abs(p.yv)
    if(totalvel>p.max) p.xv*=(p.max/totalvel) p.yv*=(p.max/totalvel)
  end)

  -- Map Collisions
  s_collisions=sys({"pos","phys","mcol"},function(e)
    -- simulate new position after velocity update
    local dx=e.pos.x+e.phys.xv
    local dy=e.pos.y+e.phys.yv

    -- check map flags
    local mcol=function(x,y,w,h)
      return fget(mget(x\8,y\8),0)
          or fget(mget((x+w)\8,(y+h)\8),0)
    end

    -- check if in wall per direction
    -- if so, kill velocity and snap to wall
    if mcol(dx,e.pos.y,0,7) then
      e.phys.xv=0
      e.pos.x=dx\8*8+8
    end
    if mcol(dx+7,e.pos.y,0,7) then
      e.phys.xv=0
      e.pos.x=dx\8*8
    end
    if mcol(e.pos.x,dy,7,0) then
      e.phys.yv=0
      e.pos.y=dy\8*8+8
    end
    if mcol(e.pos.x,dy+7,7,0) then
      e.phys.yv=0
      e.pos.y=dy\8*8
    end
  end)

  -- Apply Velocity
  s_movement=sys({"pos","phys"},function(e)
    e.pos.x+=e.phys.xv
    e.pos.y+=e.phys.yv
  end)

  -- Camera

  s_camerapos=sys({"pos","cam"},function(e)
  local x=flr(e.pos.x/(16*8))*16*8
  local y=flr(e.pos.y/(16*8))*16*8
  camera(x,y)

  end)

  -- Drawing
  s_draw=sys({"pos","draw"},function(e)
    local anm=e.draw.anims[e.draw.curanim or "default"]
    local spi=e.draw.moving==true and anm.frm[tick\anm.spd%#anm.frm+1] or anm.frm[1]

    spr(spi,e.pos.x,e.pos.y,1,1,e.draw.flip)
    if e.draw.istall then
      spi=e.draw.moving==true and anm.ext[tick\anm.spd%#anm.ext+1] or anm.ext[1]
      spr(spi,e.pos.x,e.pos.y-8,1,1,e.draw.flip)
    end
  end)
end