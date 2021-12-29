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
  s_collisions=sys({"pos","phys","mcol","coll"},function(e)
    local x,y,xoff,yoff,width,height,pos = e.pos.x,e.pos.y,e.coll.xoff,e.coll.yoff,e.coll.width,e.coll.height,e.pos

    local is_solid = function(x,y)
      return fget(mget(x,y),0)
    end

    local move_x = function(obj, amt)
      if (amt == 0) return
      local step = sgn(amt)
      for i=0,abs(amt) do
        if not (is_solid((pos.x+xoff+step)\8,(y+yoff)\8) or
           is_solid((pos.x+xoff+width-1+step)\8,(y+yoff)\8) or
           is_solid((pos.x+xoff+step)\8,(y+yoff+height-1)\8) or
           is_solid((pos.x+xoff+width-1+step)\8,(y+yoff+height-1)\8)) then
          pos.x += step
        else
          e.phys.xv = 0
          break
        end
      end
    end

    local move_y = function(obj, amt)
      if (amt == 0) return
      local step = sgn(amt)
      for i=0,abs(amt) do
        if not (is_solid((x+xoff)\8,(pos.y+yoff+step)\8) or
           is_solid((x+xoff+width-1)\8,(pos.y+yoff+step)\8) or
           is_solid((x+xoff)\8,(pos.y+yoff+height-1+step)\8) or
           is_solid((x+xoff+width-1)\8,(pos.y+yoff+height-1+step)\8)) then
          pos.y+=step
        else
          e.phys.yv=0
          break
        end
      end
    end

    local amount=e.phys.xv
    move_x(e,amount)
    amount=e.phys.yv
    move_y(e,amount)
  end)

  -- Camera

  s_camerapos=sys({"pos","cam"},function(e)
  local x=mid(64,flr(e.pos.x),448)
  local y=mid(64,flr(e.pos.y),192)
  camera(x-64,y-64)

  end)
                        
  -- Apply Velocity, now part of collision
  -- s_movement=sys({"pos","phys"},function(e)
  --   e.pos.x+=e.phys.xv
  --   e.pos.y+=e.phys.yv
  -- end)

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