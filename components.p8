pico-8 cartridge // http://www.pico-8.com
version 34
__lua__

-- Components
function load_components()
  -- x and y positions
  c_position=function(x,y) 
    return cmp("pos",{x=x,y=y})
  end

  -- physics object
  -- x and y velocities
  -- current, max, and accelerations
  -- friction
  c_physics=function(max,acc,fric) 
    return cmp("phys",{
      xv=0,yv=0,max=max,acc=acc,fric=fric
    })
  end

  -- collision object
  -- relative to base sprite, stores the following values
  -- x and y offsets, origin is the top left corner
  -- width and height of the box
  -- could just replace mcol with this?
  c_collision=function(xoff,yoff,width,height)
    return cmp("coll",{
      xoff=xoff,
      yoff=yoff,
      width=width,
      height=height
    })
  end

  -- drawable
  -- current anim
  -- animations
  -- flip horizontally
  -- whether the sprite is moving or not
  c_draw=function(curanim,anims,istall) 
    return cmp("draw",{
      curanim=curanim,
      anims=anims,
      istall=istall,
      flip=false,
      moving=false
    })
  end

  -- controllable
  -- might not need this?
  c_control=function(anims) 
    return cmp("ctrl",{
      anims=anims
    })
  end

  -- map collidable
  c_mapcollidable=cmp"mcol"
end

  c_cam=function(x,y)
    return cmp("cam", {
      x=x,
      y=y
    })
  end