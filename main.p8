pico-8 cartridge // http://www.pico-8.com
version 34
__lua__

function _init()
  load_components()
  load_systems()
  tick=0
  music(0)

  -- place entities
  entities={
    mk_player(328,64)
  }

  -- debug init
  debug={}
end

function _update60()
  tick+=1
  s_friction(entities)
  s_walking(entities)
  s_playeranim(entities)
  s_maxvelocity(entities)
  s_collisions(entities)
end

function _draw()
  cls()
  map()
  s_camerapos(entities)
  s_draw(entities)
  
  -- uncomment to check processor usage
  -- debug[1]=stat(1)
 --debugging
  cursor(4,4)
  color(8)
  for txt in all(debug) do
    print(txt)
  end
end