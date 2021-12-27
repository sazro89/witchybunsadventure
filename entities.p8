pico-8 cartridge // http://www.pico-8.com
version 34
__lua__

-- Player Entity
function mk_player(x,y)
 return ent{typ="player"}
   +c_position(x,y)
   +c_physics(3,.5,.25)
   +c_control({dflt="dflt",
               side="side",
               up="up",
               down="down"})
   +c_mapcollidable
   +c_draw("dflt",{
      dflt={spd=5,frm={55,56},ext={57,58}},
      side={spd=5,frm={49,50},ext={51,52}},
      up={spd=5,frm={53,54},ext={59,60}},
      down={spd=5,frm={55,56},ext={57,58}}
   },true)
+c_cam(0,0)
end
