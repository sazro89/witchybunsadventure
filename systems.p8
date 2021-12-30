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

    local vectorvel=sqrt(p.xv*p.xv+p.yv*p.yv)
    if(vectorvel>p.max) then 
      p.xv*=(p.max/vectorvel) 
      p.yv*=(p.max/vectorvel)
    end
  end)

  -- Map Collisions
  -- removed mcol until we have an explicit use for it
  s_collisions=sys({"pos","phys","coll"},function(e)
    local x,y,xoff,yoff,width,height,pos = e.pos.x,e.pos.y,e.coll.xoff,e.coll.yoff,e.coll.width,e.coll.height,e.pos

    local is_solid = function(x,y)
      return fget(mget(x,y),0)
    end

    local is_solid_x = function(step, y_adjustment)
      return (is_solid((pos.x+xoff+step)\8,(y+yoff+y_adjustment)\8) or
              is_solid((pos.x+xoff+width-1+step)\8,(y+yoff+y_adjustment)\8) or
              is_solid((pos.x+xoff+step)\8,(y+yoff+height-1+y_adjustment)\8) or
              is_solid((pos.x+xoff+width-1+step)\8,(y+yoff+height-1+y_adjustment)\8))
    end

    local is_solid_y = function(step, x_adjustment)
      return (is_solid((x+xoff+x_adjustment)\8,(pos.y+yoff+step)\8) or
              is_solid((x+xoff+width-1+x_adjustment)\8,(pos.y+yoff+step)\8) or
              is_solid((x+xoff+x_adjustment)\8,(pos.y+yoff+height-1+step)\8) or
              is_solid((x+xoff+width-1+x_adjustment)\8,(pos.y+yoff+height-1+step)\8))
    end

    local move_x = function(amt)
      e.phys.xrem+=amt
      local move=flr(e.phys.xrem)
      if (move==0) return
      e.phys.xrem-=move
      local step=sgn(amt)
      while(move!=0) do
        if not is_solid_x(step, 0) then
          pos.x+=step
        elseif not is_solid_x(step, 1) then
          pos.x += step
          pos.y += 1
        elseif not is_solid_x(step, -1) then
          pos.x += step
          pos.y -= 1
        else
          e.phys.xv = 0
          break
        end
        move-=step
      end
    end

    local move_y = function(amt)
      e.phys.yrem+=amt
      local move=flr(e.phys.yrem)
      if (move==0) return
      e.phys.yrem-=move
      local step=sgn(amt)
      while(move!=0) do
        if not is_solid_y(step,0) then
          pos.y+=step
        elseif not is_solid_y(step, 1) then
          pos.y += step
          pos.x += 1
        elseif not is_solid_y(step, -1) then
          pos.y += step
          pos.x -= 1
        else
          e.phys.yv=0
          break
        end
        move-=step
      end
    end

    local amount=e.phys.xv
    move_x(amount)
    amount=e.phys.yv
    move_y(amount)
  end)

  -- Camera
  s_camerapos=sys({"pos","cam"},function(e)
    local x=mid(64,flr(e.pos.x),448)
    local y=mid(64,flr(e.pos.y),192)
    camera(x-64,y-64)
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