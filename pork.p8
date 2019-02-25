pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 t=0
 
 dpal=explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")
 
 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")
 
 itm_name=explode("butter knife,cheese knife,paring knife,utility knife,chef's knife,meat cleaver,paper apron,cotton apron,rubber apron,leather apron,chef's apron,butcher's apron,food 1,food 2,food 3,food 4,food 5,food 6,spork,salad fork,fish fork,dinner fork")
 itm_type=explode("wep,wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr")
 itm_stat1=explodeval("1,2,3,4,5,6,0,0,0,0,1,2,1,2,3,4,5,6,1,2,3,4")
 itm_stat2=explodeval("0,0,0,0,0,0,1,2,3,4,3,3,0,0,0,0,0,0,0,0,0,0")
 itm_minf=explodeval("1,2,3,4,5,6,1,2,3,4,5,6,1,1,1,1,1,1,1,2,3,4")
 itm_maxf=explodeval("3,4,5,6,7,8,3,4,5,6,7,8,8,8,8,8,8,8,4,6,7,8")
 itm_desc=explode(",,,,,,,,,,,,heals,heals a lot,increases hp,stuns,is cursed,is blessed,,,,")

 mob_name=explode("player,slime,melt,shoggoth,mantis-man,giant scorpion,ghost,golem,drake")
 mob_ani=explodeval("240,192,196,200,204,208,212,216,220")
 mob_atk=explodeval("1,1,2,1,2,3,3,5,5")
 mob_hp=explodeval("5,1,2,3,3,4,5,14,8")
 mob_los=explodeval("4,4,4,4,4,4,4,4,4")
 mob_minf=explodeval("0,1,2,3,4,5,6,7,8")
 mob_maxf=explodeval("0,3,4,5,6,7,8,8,8")
 mob_spec=explode(",,,spawn?,fast?,stun,ghost?,slow,")

 --★
 crv_sig={0b11111111,0b11010110,0b01111100,0b10110011,0b11101001}
 crv_msk={0,0b00001001,0b00000011,0b00001100,0b00000110}

 wall_sig=explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
 wall_msk=explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")

 debug={}
 startgame()
end

function _update60()
 t+=1
 _upd()
 dofloats()
 dohpwind()
end

function _draw()
 _drw()
 drawind()
 
 --fadeperc=0
 checkfade()
 
 --★
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end

function startgame()
 tani=0
 fadeperc=1
 buttbuff=-1
 
 skipai=false
 win=false
 winfloor=9
 --★
 mob={}
 dmob={}
 p_mob=addmob(1,1,1)
 
 p_t=0
 
 inv,eqp={},{}

 --takeitem(1)
  
 wind={}
 float={}

 talkwind=nil
 
 hpwind=addwind(5,5,28,13,{})
 
 thrdx,thrdy=0,-1
 
 _upd=update_game
 _drw=draw_game
 
 genfloor(0)
 
end
-->8
--updates
function update_game()
 if talkwind then
  if getbutt()==5 then
   talkwind.dur=0
   talkwind=nil
  end
 else
  dobuttbuff()
  dobutt(buttbuff)
  buttbuff=-1
 end
end

function update_inv()
 --inventory
 move_mnu(curwind)
 if btnp(4) then
  if curwind==invwind then
   _upd=update_game
   invwind.dur=0
   statwind.dur=0
  --★
  elseif curwind==usewind then
   usewind.dur=0
   curwind=invwind
  end
 elseif btnp(5) then
  if curwind==invwind and invwind.cur!=3 then
   showuse()
   --★
  elseif curwind==usewind then
   -- use window confirm 
   triguse() 
  end
 end
end

function update_throw()
 local b=getbutt()
 if b>=0 and  b<=3 then
  thrdx=dirx[b+1]
  thrdy=diry[b+1]
 end
 if b==4 then
  _upd=update_game
 elseif b==5 then
  throw()
 end
end

function move_mnu(wnd)
 if btnp(2) then
  wnd.cur-=1
 elseif btnp(3) then
  wnd.cur+=1
 end
 wnd.cur=(wnd.cur-1)%#wnd.txt+1
end


function update_pturn()
 dobuttbuff()
 p_t=min(p_t+0.125,1)
 
 if p_mob.mov then
  p_mob:mov()
 end
 
 if p_t==1 then
  _upd=update_game
  if trig_step() then return end

  if checkend() and not skipai then
   doai()
  end
  skipai=false
 end
end

function update_aiturn()
 dobuttbuff()
 p_t=min(p_t+0.125,1)
 for m in all(mob) do
  if m!=p_mob and m.mov then
   m:mov()
  end
 end
 if p_t==1 then
  _upd=update_game
  checkend()
 end
end

function update_gover()
 if btnp(❎) then
  fadeout()
  startgame()
 end
end

function dobuttbuff()
 if buttbuff==-1 then
  buttbuff=getbutt()
 end
end

function getbutt()
 for i=0,5 do
  if btnp(i) then
   return i
  end
 end
 return -1
end

function dobutt(butt)
 if butt<0 then return end
 if butt<4 then
  moveplayer(dirx[butt+1],diry[butt+1])
 elseif butt==5 then
  showinv()
 elseif butt==4 then
  genfloor(floor+1)
  --prettywalls()
 end
end
-->8
--draws
function draw_game()
 cls(0)
 if fadeperc==1 then return end
 animap()
 map()
 for m in all(dmob) do
  if sin(time()*8)>0 then
   drawmob(m)
  end
  m.dur-=1
  if m.dur<=0 then
   del(dmob,m)
  end
 end
 
 for i=#mob,1,-1 do
  drawmob(mob[i])
 end
 
 if _upd==update_throw then
  --★
  local tx,ty=throwtile()
  local lx1,ly1=p_mob.x*8+3+thrdx*4,p_mob.y*8+3+thrdy*4
  local lx2,ly2=mid(0,tx*8+3,127),mid(0,ty*8+3,127)
  rectfill(lx1+thrdy,ly1+thrdx,lx2-thrdy,ly2-thrdx,0)
  
  local thrani,mb=flr(t/7)%2==0,getmob(tx,ty)
  if thrani then
   fillp(0b1010010110100101)
  else
   fillp(0b0101101001011010)
  end
  line(lx1,ly1,lx2,ly2,7)
  fillp()
  oprint8("+",lx2-1,ly2-2,7,0)
  
  if mb and thrani then
   mb.flash=1
  end
 end 
 
 for x=0,15 do
  for y=0,15 do
   if fog[x][y]==1 then
    rectfill2(x*8,y*8,8,8,0)
   end
  end
 end
  
 for f in all(float) do
  oprint8(f.txt,f.x,f.y,f.c,0)
 end
end

function drawmob(m)
 local col=10
 if m.flash>0 then
  m.flash-=1
  col=7
 end
 drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp)
end

function draw_gover()
 cls(2)
 print("y ded",50,50,7)
end

function draw_win()
 cls(2)
 print("u win",50,50,7)
end

function animap()
 tani+=1
 if (tani<15) return
 tani=0
 for x=0,15 do
  for y=0,15 do
   local tle=mget(x,y)
   if tle==64 or tle==66 then
    tle+=1
   elseif tle==65 or tle==67 then
    tle-=1
   end
   mset(x,y,tle)
  end
 end
end
-->8
--tools

function getframe(ani)
 return ani[flr(t/15)%#ani+1]
end

function drawspr(_spr,_x,_y,_c,_flip)
 palt(0,false)
 pal(6,_c)
 spr(_spr,_x,_y,1,1,_flip)
 pal()
end

function rectfill2(_x,_y,_w,_h,_c)
 --★
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
end

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function blankmap(_dflt)
 local ret={} 
 if (_dflt==nil) _dflt=0
 
 for x=0,15 do
  ret[x]={}
  for y=0,15 do
   ret[x][y]=_dflt
  end
 end
 return ret
end

function getrnd(arr)
 return arr[1+flr(rnd(#arr))]
end

function copymap(x,y)
 local tle
 for _x=0,15 do
  for _y=0,15 do
   tle=mget(_x+x,_y+y)
   mset(_x,_y,tle)
   if tle==15 then
    p_mob.x,p_mob.y=_x,_y
   end
  end
 end
end

function explode(s)
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)=="," then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end
-->8
--gameplay

function moveplayer(dx,dy)
 local destx,desty=p_mob.x+dx,p_mob.y+dy
 local tle=mget(destx,desty)
  
 if iswalkable(destx,desty,"checkmobs") then
  sfx(63)
  mobwalk(p_mob,dx,dy)
  p_t=0
  _upd=update_pturn
 else
  --not walkable
  mobbump(p_mob,dx,dy)
  p_t=0
  _upd=update_pturn
  
  local mob=getmob(destx,desty)
  if mob then
   sfx(58)
   hitmob(p_mob,mob)
  else
   if fget(tle,1) then
    trig_bump(tle,destx,desty)
   else
    skipai=true
    --mset(destx,desty,1)
   end
  end
 end
 unfog()
end

function trig_bump(tle,destx,desty)
 if tle==7 or tle==8 then
  --vase
  sfx(59)
  mset(destx,desty,1)
  if rnd(4)<1 then
   local itm=flr(rnd(#itm_name))+1
   takeitem(itm)
   showmsg(itm_name[itm],60)
  end
 elseif tle==10 or tle==12 then
  --chest
  sfx(61)
  mset(destx,desty,tle-1)
  local itm=flr(rnd(#itm_name))+1
  takeitem(itm)
  showmsg(itm_name[itm],60)
 elseif tle==13 then
  --door
  sfx(62)
  mset(destx,desty,1)
 elseif tle==6 then
  --stone tablet
  if floor==0 then
   showtalk({" welcome to porklike!",""," climb this sausage"," tower to obtain the"," ultimate power of"," the golden kielbasa",""})
  end
 elseif tle==110 then
  --kielbasa
  win=true
 end
end

function trig_step()
 local tle=mget(p_mob.x,p_mob.y)

 if tle==14 then
  fadeout()
  genfloor(floor+1)
  floormsg()
  return true
 end
 return false
end

function getmob(x,y)
 for m in all(mob) do
  if m.x==x and m.y==y then
   return m
  end
 end
 return false
end

function iswalkable(x,y,mode)
 local mode = mode or "test"
 
 --sight
 if inbounds(x,y) then
  local tle=mget(x,y)
  if mode=="sight" then
   return not fget(tle,2)
  else
   if not fget(tle,0) then
    if mode=="checkmobs" then
     return not getmob(x,y)
    end
    return true
   end
  end
 end
 return false
end

function inbounds(x,y)
 return not (x<0 or y<0 or x>15 or y>15)
end

function hitmob(atkm,defm,rawdmg)
 local dmg= atkm and atkm.atk or rawdmg
 
 local def=defm.defmin+flr(rnd(defm.defmax-defm.defmin+1))
 dmg-=min(def,dmg)
 --dmg=max(0,dmg)
 
 defm.hp-=dmg
 defm.flash=10
 
 addfloat("-"..dmg,defm.x*8,defm.y*8,9)
 
 if defm.hp<=0 then
  add(dmob,defm)
  del(mob,defm)
  defm.dur=10
 end
end

function healmob(mb,hp)
 hp=min(mb.hpmax-mb.hp,hp)
 mb.hp+=hp
 mb.flash=10
 
 addfloat("+"..hp,mb.x*8,mb.y*8,7)
end

function checkend()
 --★
 if win then
  wind={}  
  _upd=update_gover
  _drw=draw_win
  fadeout(0.02) 
  return false
 elseif p_mob.hp<=0 then
  wind={}
  _upd=update_gover
  _drw=draw_gover
  fadeout(0.02)
  return false
 end
 return true
end

function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true
 --★
 if dist(x1,y1,x2,y2)==1 then return true end
 if x1<x2 then
  sx,dx=1,x2-x1
 else
  sx,dx=-1,x1-x2
 end
 if y1<y2 then
  sy,dy=1,y2-y1
 else
  sy,dy=-1,y1-y2
 end
 local err,e2=dx-dy
 
 while not(x1==x2 and y1==y2) do
  if not frst and iswalkable(x1,y1,"sight")==false then return false end
  e2,frst=err+err,false
  if e2>-dy then
   err-=dy
   x1+=sx
  end
  if e2<dx then 
   err+=dx
   y1+=sy
  end
 end
 return true 
end

function unfog()
 local px,py=p_mob.x,p_mob.y
 for x=0,15 do
  for y=0,15 do 
   --★
   if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then
    unfogtile(x,y)
   end
  end
 end
end

function unfogtile(x,y)
 fog[x][y]=0
 if iswalkable(x,y,"sight") then
  for i=1,4 do
   local tx,ty=x+dirx[i],y+diry[i]
   if inbounds(tx,ty) and not iswalkable(tx,ty,"sight") then
    fog[tx][ty]=0
   end
  end  
 end
end

function calcdist(tx,ty)
 local cand,step,candnew={},0
 distmap=blankmap(-1)
 add(cand,{x=tx,y=ty})
 distmap[tx][ty]=0
 repeat
  step+=1
  candnew={} 
  for c in all(cand) do
   for d=1,4 do
    local dx=c.x+dirx[d]
    local dy=c.y+diry[d]
    if inbounds(dx,dy) and distmap[dx][dy]==-1 then
     distmap[dx][dy]=step
     if iswalkable(dx,dy) then
      add(candnew,{x=dx,y=dy})
     end
    end
   end
  end
  cand=candnew
 until #cand==0
end

function updatestats()
 local atk,dmin,dmax=1,0,0
 
 if eqp[1] then
  atk+=itm_stat1[eqp[1]]
 end
 
 if eqp[2] then
  dmin+=itm_stat1[eqp[2]]
  dmax+=itm_stat2[eqp[2]]
 end

 p_mob.atk=atk
 p_mob.defmin=dmin
 p_mob.defmax=dmax 
end

function eat(itm,mb)
 local effect=itm_stat1[itm]
 
 if effect==1 then
  --heal
  healmob(mb,1)
 end
end

function throw()
 local itm,tx,ty=inv[thrslt],throwtile()

 if inbounds(tx,ty) then
  local mb=getmob(tx,ty)
  if mb then
   if itm_type[itm]=="fud" then
    eat(itm,mb)
   else
    hitmob(nil,mb,itm_stat1[itm])
    sfx(58)
   end
  end
 end
 mobbump(p_mob,thrdx,thrdy)
 
 inv[thrslt]=nil
 p_t=0
 _upd=update_pturn
end

function throwtile()
 local tx,ty=p_mob.x,p_mob.y
 repeat
  tx+=thrdx
  ty+=thrdy
 until not iswalkable(tx,ty,"checkmobs")
 return tx,ty
end
-->8
--ui

function addwind(_x,_y,_w,_h,_txt)
 local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          txt=_txt}
 add(wind,w)
 return w
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  if w.cur then
   wx+=6
  end
  for i=1,#w.txt do
   local txt,c=w.txt[i],6
   if w.col and w.col[i] then
    c=w.col[i]
   end
   print(txt,wx,wy,c)
   if i==w.cur then
    spr(255,wx-5+sin(time()),wy)
   end
   wy+=6
  end
  clip()
 
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("❎",wx+ww-15,wy-1+sin(time()),6,0)
   end
  end
 end
end

function showmsg(txt,dur)
 local wid=(#txt+2)*4+7
 local w=addwind(63-wid/2,50,wid,13,{" "..txt})
 w.dur=dur
end

function showtalk(txt)
 talkwind=addwind(16,50,94,#txt*6+7,txt)
 talkwind.butt=true
end

function addfloat(_txt,_x,_y,_c)
 add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(float) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>70 then
   del(float,f)
  end
 end
end

function dohpwind()
 hpwind.txt[1]="♥"..p_mob.hp.."/"..p_mob.hpmax
 local hpy=5
 if p_mob.y<8 then
  hpy=110
 end
 hpwind.y+=(hpy-hpwind.y)/5
end

function showinv()
 local txt,col,itm,eqt={},{}
 _upd=update_inv
 for i=1,2 do
  itm=eqp[i]
  if itm then
   eqt=itm_name[itm]
   add(col,6)
  else
   eqt= i==1 and "[weapon]" or "[armor]"
   add(col,5)
  end
  add(txt,eqt)
 end
 add(txt,"……………………")
 add(col,6)
 for i=1,6 do
  itm=inv[i]
  if itm then
   add(txt,itm_name[itm])
   add(col,6)
  else
   add(txt,"...")
   add(col,5)
  end
 end
 
 invwind=addwind(5,17,84,62,txt)
 invwind.cur=3
 invwind.col=col
 
 statwind=addwind(5,5,84,13,{"atk: "..p_mob.atk.."  def: "..p_mob.defmin.."-"..p_mob.defmax})
 
 curwind=invwind 
end

function showuse()
 local itm=invwind.cur<3 and eqp[invwind.cur] or inv[invwind.cur-3]
 if itm==nil then return end
 local typ,txt=itm_type[itm],{}
 
 if (typ=="wep" or typ=="arm") and invwind.cur>3 then
  add(txt,"equip")
 end
 if typ=="fud" then
  add(txt,"eat")
 end
 if typ=="thr" or typ=="fud" then
  add(txt,"throw")
 end
 add(txt,"trash")

 usewind=addwind(84,invwind.cur*6+11,36,7+#txt*6,txt)
 usewind.cur=1
 curwind=usewind 
end

function triguse()
 local verb,i,back=usewind.txt[usewind.cur],invwind.cur,true
 local itm=i<3 and eqp[i] or inv[i-3]
 
 if verb=="trash" then
  if i<3 then
   eqp[i]=nil
  else
   inv[i-3]=nil
  end
 elseif verb=="equip" then
  local slot=2
  if itm_type[itm]=="wep" then
   slot=1
  end
  inv[i-3]=eqp[slot]
  eqp[slot]=itm
 elseif verb=="eat" then
  eat(itm,p_mob)
  _upd,inv[i-3],p_mob.mov,p_t,back=update_pturn,nil,nil,0,false
 elseif verb=="throw" then
  _upd,thrslt,back=update_throw,i-3,false
 end
 
 updatestats()
 usewind.dur=0
 
 if back then
  del(wind,invwind)
  del(wind,statwind)
  showinv()
  invwind.cur=i
 else
  invwind.dur=0
  statwind.dur=0
 end
end

function floormsg()
 showmsg("floor "..floor,120)
end
-->8
--mobs and items

function addmob(typ,mx,my)
 local m={
  x=mx,
  y=my,
  ox=0,
  oy=0,
  flp=false,
  ani={},
  flash=0,
  hp=mob_hp[typ],
  hpmax=mob_hp[typ],
  atk=mob_atk[typ],
  defmin=0,
  defmax=0,
  los=mob_los[typ],
  task=ai_wait
 }
 for i=0,3 do
  add(m.ani,mob_ani[typ]+i)
 end
 add(mob,m)
 return m
end

function mobwalk(mb,dx,dy)
 mb.x+=dx --?
 mb.y+=dy

 mobflip(mb,dx)
 mb.sox,mb.soy=-dx*8,-dy*8
 mb.ox,mb.oy=mb.sox,mb.soy
 mb.mov=mov_walk
end

function mobbump(mb,dx,dy)
 mobflip(mb,dx)
 mb.sox,mb.soy=dx*8,dy*8
 mb.ox,mb.oy=0,0
 mb.mov=mov_bump
end

function mobflip(mb,dx)
 mb.flp = dx==0 and mb.flp or dx<0

end


function mov_walk(self)
 local tme=1-p_t 
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function mov_bump(self)
 --★ 
 local tme= p_t>0.5 and 1-p_t or p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function doai()
 local moving=false
 for m in all(mob) do
  if m!=p_mob then
   m.mov=nil
   moving=m.task(m) or moving
  end
 end
 if moving then
  _upd=update_aiturn
  p_t=0
 end
end

function ai_wait(m)
 if cansee(m,p_mob) then
  --aggro
  m.task=ai_attac
  m.tx,m.ty=p_mob.x,p_mob.y
  addfloat("!",m.x*8+2,m.y*8,10)
  return true
 end
 return false
end

function ai_attac(m)  
 if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
  --attack player
  local dx,dy=p_mob.x-m.x,p_mob.y-m.y
  mobbump(m,dx,dy)
  hitmob(m,p_mob)  
  sfx(57)
  return true
 else
  --move to player
  if cansee(m,p_mob) then
   m.tx,m.ty=p_mob.x,p_mob.y
  end
  
  if m.x==m.tx and m.y==m.ty then
   --de aggro
   m.task=ai_wait
   addfloat("?",m.x*8+2,m.y*8,10)
  else 
   local bdst,cand=999,{}
   calcdist(m.tx,m.ty)
   for i=1,4 do
    local dx,dy=dirx[i],diry[i]
    local tx,ty=m.x+dx,m.y+dy
    if iswalkable(tx,ty,"checkmobs") then
     local dst=distmap[tx][ty]
     if dst<bdst then
      cand={}
      bdst=dst
     end
     if dst==bdst then
      add(cand,i)
     end
    end
   end
   if #cand>0 then
    local c=getrnd(cand)
    mobwalk(m,dirx[c],diry[c])
    return true
   end 
   --todo: re-aquire target?
  end
 end
 return false
end

function cansee(m1,m2)
 return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

function spawnmobs()
 
 mobpool={}
 for i=2,#mob_name do
  if mob_minf[i]<=floor and mob_maxf[i]>=floor then
   add(mobpool,i)
  end
 end
 
 if #mobpool==0 then return end
 
 local minmons=explodeval("3,5,7,9,10,11,12,13")
 local maxmons=explodeval("6,10,14,18,20,22,24,26")
 
 local placed,rpot=0,{}
 
 for r in all(rooms) do
  add(rpot,r)
 end
 
 repeat
  local r=getrnd(rpot)
  placed+=infestroom(r)
  del(rpot,r)
 until #rpot==0 or placed>maxmons[floor]
 
 if placed<minmons[floor] then
  repeat
   local x,y
   repeat
    x,y=flr(rnd(16)),flr(rnd(16))
   until iswalkable(x,y,"checkmobs")
   addmob(getrnd(mobpool),x,y)
  until placed>=minmons[floor]
 end
end

function infestroom(r)
 local target=2+flr(rnd(3))
 local x,y
 
 for i=1,target do
  repeat
   x=r.x+flr(rnd(r.w))
   y=r.y+flr(rnd(r.h))
  until iswalkable(x,y,"checkmobs")
  addmob(getrnd(mobpool),x,y)
 end
 return target
end

-------------------------
-- items
-------------------------

function takeitem(itm)
 local i=freeinvslot()
 if i==0 then return false end
 inv[i]=itm
 return true
end

function freeinvslot()
 for i=1,6 do
  if not inv[i] then
   return i
  end
 end
 return 0
end
-->8
--gen

function genfloor(f)
 floor=f
 mob={}
 add(mob,p_mob)
 fog=blankmap(0)
 if floor==0 then  
  copymap(16,0)
 elseif floor==winfloor then
  copymap(32,0)
 else
  fog=blankmap(0)
  mapgen()
  unfog()
 end
end


function mapgen()
 copymap(48,0)
 --todo

 --bettermonsters 
 --items/chests

 --entry not in an alcove? 
 --decos dont kill enty
 --remove isolated rooms

 rooms={}
 roomap=blankmap(0)
 doors={}
 genrooms()
 mazeworm()
 placeflags()
 carvedoors()
 carvescuts()
 startend()
 fillends()
 prettywalls()

 installdoors()
  
 spawnmobs()
 decorooms()
end

--★
function snapshot()
 return
 --[[cls()
 map()
 for i=0,1 do
  flip()
 end]]
end

----------------
-- rooms
----------------

function genrooms()
 -- tweak dis
 local fmax,rmax=5,4 --5,4?
 local mw,mh=6,6     --5,5?
 
 repeat
  --todo: 1st room bigger?
  local r=rndroom(mw,mh)
  if placeroom(r) then
   rmax-=1
   snapshot()
  else
   fmax-=1
   --★
   if r.w>r.h then
    mw=max(mw-1,3)
   else
    mh=max(mh-1,3)
   end
  end
 until fmax<=0 or rmax<=0
 --debug[1]="fails: "..fmax
 --debug[2]="rooms: "..rmax
end

function rndroom(mw,mh)
 --clamp max area
 local _w=3+flr(rnd(mw-2))
 mh=mid(35/_w,3,mh)
 local _h=3+flr(rnd(mh-2))
 return {
  x=0,
  y=0,
  w=_w,
  h=_h
 }
end

function placeroom(r)
 local cand,c={}
 
 for _x=0,16-r.w do
  for _y=0,16-r.h do
   if doesroomfit(r,_x,_y) then
    add(cand,{x=_x,y=_y})
   end
  end
 end
 
 if #cand==0 then return false end
 
 c=getrnd(cand)
 r.x=c.x
 r.y=c.y
 add(rooms,r) 
 for _x=0,r.w-1 do
  for _y=0,r.h-1 do
   mset(_x+r.x,_y+r.y,1)
   roomap[_x+r.x][_y+r.y]=#rooms
  end
 end
 return true
end

function doesroomfit(r,x,y)
 for _x=-1,r.w do
  for _y=-1,r.h do
   if iswalkable(_x+x,_y+y) then
    return false
   end
  end
 end
 
 return true
end

----------------
-- maze
----------------

function mazeworm()
 repeat
  local cand={}
  for _x=0,15 do
   for _y=0,15 do
    if cancarve(_x,_y,false) and not nexttoroom(_x,_y) then
     add(cand,{x=_x,y=_y})
    end
   end
  end
 
  if #cand>0 then
   local c=getrnd(cand)
   digworm(c.x,c.y)
  end
 until #cand<=1
end

function digworm(x,y)
 local dr,stp=1+flr(rnd(4)),0
 
 repeat
  mset(x,y,1)
  snapshot()
  if not cancarve(x+dirx[dr],y+diry[dr],false) or (rnd()<0.5 and stp>2) then
   stp=0
   local cand={}
   for i=1,4 do
    if cancarve(x+dirx[i],y+diry[i],false) then
     add(cand,i)
    end
   end
   if #cand==0 then
    dr=8
   else
    dr=getrnd(cand)
   end
  end
  x+=dirx[dr]
  y+=diry[dr]
  stp+=1
 until dr==8 
end

function cancarve(x,y,walk)
 if not inbounds(x,y) then return false end
 local walk= walk==nil and iswalkable(x,y) or walk
 
 if iswalkable(x,y)==walk then
  local sig=getsig(x,y)
  for i=1,#crv_sig do
   if bcomp(sig,crv_sig[i],crv_msk[i]) then 
    return true 
   end
  end
 end
 return false
end

function bcomp(sig,match,mask)
 local mask=mask and mask or 0
 return bor(sig,mask)==bor(match,mask)
end

function getsig(x,y)
 local sig,digit=0
 for i=1,8 do
  local dx,dy=x+dirx[i],y+diry[i]
  --★
  if iswalkable(dx,dy) then
   digit=0
  else
   digit=1
  end
  sig=bor(sig,shl(digit,8-i))
 end
 return sig
end

----------------
-- doorways
----------------

function placeflags()
 local curf=1
 flags=blankmap(0)
 for _x=0,15 do
  for _y=0,15 do
   if iswalkable(_x,_y) and flags[_x][_y]==0 then
    growflag(_x,_y,curf)
    curf+=1
   end
  end
 end
end

function growflag(_x,_y,flg)
 local cand,candnew={{x=_x,y=_y}}
 flags[_x][_y]=flg
 repeat
  candnew={}
  for c in all(cand) do
   for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if iswalkable(dx,dy) and flags[dx][dy]!=flg then
     flags[dx][dy]=flg
     add(candnew,{x=dx,y=dy})
    end
   end
  end
  cand=candnew
 until #cand==0
end

function carvedoors()
 local x1,y1,x2,y2,found,_f1,_f2,drs=1,1,1,1
 repeat
  drs={}
  for _x=0,15 do
   for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y)
     found=false
     if bcomp(sig,0b11000000,0b00001111) then
      x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then
      x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
     end
     _f1=flags[x1][y1]
     _f2=flags[x2][y2]
     if found and _f1!=_f2 then
      add(drs,{x=_x,y=_y,f=_f1})
     end
    end
   end
  end
  
  if #drs>0 then
   local d=getrnd(drs)
   --★
   add(doors,d)
   mset(d.x,d.y,1)
   snapshot()
   growflag(d.x,d.y,d.f)  
  end
 until #drs==0
end

function carvescuts()
 local x1,y1,x2,y2,cut,found,drs=1,1,1,1,0
 repeat
  drs={}
  for _x=0,15 do
   for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y)
     found=false
     if bcomp(sig,0b11000000,0b00001111) then
      x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then
      x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
     end
     if found then
      calcdist(x1,y1)
      if distmap[x2][y2]>20 then
       add(drs,{x=_x,y=_y})
      end
     end
    end
   end
  end
  
  if #drs>0 then
   local d=getrnd(drs)
   add(doors,d)
   mset(d.x,d.y,1)
   snapshot()
   cut+=1
  end
 until #drs==0 or cut>=3
end

function fillends()
 local filled,tle
 repeat
  filled=false
  for _x=0,15 do
   for _y=0,15 do
    tle=mget(_x,_y)
    --★
    if cancarve(_x,_y,true) and tle!=14 and tle!=15 then
     filled=true
     mset(_x,_y,2)
     snapshot()
    end
   end
  end
 until not filled
end

function isdoor(x,y)
 local sig=getsig(x,y)
 if bcomp(sig,0b11000000,0b00001111) or bcomp(sig,0b00110000,0b00001111) then
  return nexttoroom(x,y)
 end
 return false
end

function nexttoroom(x,y)
 for i=1,4 do
  if inbounds(x+dirx[i],y+diry[i]) and 
     roomap[x+dirx[i]][y+diry[i]]!=0 then
   return true
  end
 end
 return false
end

function installdoors()
 for d in all(doors) do
  local dx,dy=d.x,d.y
  if mget(dx,dy)==1 
   or mget(dx,dy)==4 
   and isdoor(dx,dy) 
   and not next2tile(dx,dy,13) then
   
   mset(dx,dy,13)
  end
 end
end

----------------
-- decoration
----------------

function startend()
 local high,low,px,py,ex,ey=0,9999
 repeat
  px,py=flr(rnd(16)),flr(rnd(16))
 until iswalkable(px,py)
 calcdist(px,py)
 --★
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if iswalkable(x,y) and tmp>high then
    px,py,high=x,y,tmp
   end
  end
 end 
 calcdist(px,py)
 high=0
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if tmp>high and cancarve(x,y) then
    ex,ey,high=x,y,tmp
   end
  end
 end
 mset(ex,ey,14)
 
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if tmp>=0 and tmp<low and cancarve(x,y) then
    px,py,low=x,y,tmp
   end
  end
 end  
 --★
 mset(px,py,15)
 p_mob.x=px
 p_mob.y=py
end

function next2tile(_x,_y,tle)
 for i=1,4 do
  if inbounds(_x+dirx[i],_y+diry[i]) and mget(_x+dirx[i],_y+diry[i])==tle then
   return true
  end
 end
 return false
end

function prettywalls()
 for x=0,15 do
  for y=0,15 do
   local tle=mget(x,y)
   if tle==2 then
    local sig,tle=getsig(x,y),3
    for i=1,#wall_sig do
     if bcomp(sig,wall_sig[i],wall_msk[i]) then
      tle=i+15
      break
     end
    end
    mset(x,y,tle)
   elseif tle==1 then
    if not iswalkable(x,y-1) then
     mset(x,y,4)
    end
   end
  end
 end
end

function decorooms()
 tarr_dirt=explodeval("1,74,75,76")
 tarr_farn=explodeval("1,70,70,70,71,71,71,72,73,74")
 tarr_vase=explodeval("1,1,7,8")
 for r in all(rooms) do
  local funcs,func={
   deco_dirt,
   deco_torch,
   deco_carpet,
   deco_farn,
   deco_vase
  }
  func=getrnd(funcs)
  
  for x=0,r.w-1 do
   for y=r.h-1,1,-1 do
    if mget(r.x+x,r.y+y)==1 then
     func(r,r.x+x,r.y+y,x,y)
    end
   end
  end
  
 end
end

function deco_torch(r,tx,ty,x,y)
 if rnd(3)>1 and y%2==1 and not next2tile(tx,ty,13) then
  if x==0 then
   mset(tx,ty,64)
  elseif x==r.w-1 then
   mset(tx,ty,66)
  end
 end
end

function deco_carpet(r,tx,ty,x,y)
 deco_torch(r,tx,ty,x,y)
 if x>0 and y>0 and x<r.w-1 and y<r.h-1 then
  mset(tx,ty,68)
 end
end

function deco_dirt(r,tx,ty,x,y)
 mset(tx,ty,getrnd(tarr_dirt))
end

function deco_farn(r,tx,ty,x,y)
 mset(tx,ty,getrnd(tarr_farn))
end

function deco_vase(r,tx,ty,x,y)
 if iswalkable(tx,ty,"checkmobs") and 
    not next2tile(tx,ty,13) and
    not bcomp(getsig(tx,ty),0,0b00001111) then
   
  mset(tx,ty,getrnd(tarr_vase))
 end
end

__gfx__
000000000000000066606660000000006660666066606660aaaaaaaa00aaa00000aaa00000000000000000000000000000aaa000a0aaa0a0a000000055555550
000000000000000000000000000000000000000000000000aaaaaaaa0a000a000a000a00066666600aaaaaa066666660a0aaa0a000000000a0aa000000000000
007007000000000060666060000000006066606060000060a000000a0a000a000a000a00060000600a0000a060000060a00000a0a0aaa0a0a0aa0aa055000000
00077000000000000000000000000000000000000000000000aa0a0000aaa000a0aaa0a0060000600a0aa0a060000060a00a00a000aaa00000aa0aa055055000
000770000000000066606660000000000000000060000060a000000a0a00aa00aa00aaa0066666600aaaaaa066666660aaa0aaa0a0aaa0a0a0000aa055055050
007007000005000000000000000000000005000000000000a0a0aa0a0aaaaa000aaaaa000000000000000000000000000000000000aaa000a0aa000055055050
000000000000000060666060000000000000000060666060a000000a00aaa00000aaa000066666600aaaaaa066666660aaaaaaa0a0aaa0a0a0aa0aa055055050
000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006666660666666000666666006666600666666006660666066666660000066606660000066666660000066600000666066600000
00000000000000000000000066666660666666606666666066666660666666606660666066666660000066606660000066666660000066600000666066600000
00000000000000000000000066666660666666606666666066666660666666606660066066666660000006606600000066666660000066600000066066600000
00000000000000000000000066600000000066606660000066606660000066606660000000000000000000000000000000000000000066600000000066600000
00000660666666606600000066600000000066606660666066606660666066606660066066000660660006606600066000000660660066606666666066600660
00006660666666606660000066600000000066606660666066606660666066606660666066606660666066606660666000006660666066606666666066606660
00006660666666606660000066600000000066606660666066606660666066606660666066606660666066606660666000006660666066606666666066606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660066666006660000066600000000066600666666066606660666666006660666066606660666066606660666066606660666000006660666066666660
00006660666666606660000066600000000066606666666066606660666666606660666066606660666066606660666066606660666000006660666066666660
00006660666666606660000066600000000066606666666066000660666666606600066066006660660006606600066066600660660000006600666066666660
00006660666066606660000066600000000066606660000000000000000066600000000000006660000000000000000066600000000000000000666000000000
00006660666666606660000066666660666666606666666066000660666666606666666066006660000006606600000066600000666666600000666066000000
00006660666666606660000066666660666666606666666066606660666666606666666066606660000066606660000066600000666666600000666066600000
00006660066666006660000006666660666666000666666066606660666666006666666066606660000066606660000066600000666666600000666066600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660666666606660000066666660666066606660666066606660666066600000666066600000000066600000000066606660666000005000000000000000
00006660666666606660000066666660666066606660666066606660666066600000666066600000000066600000000066606660666000005055000000000000
00000660666666606600000066666660666066606660666066606660666066600000066066000000000006600000000066000660660000005055055000000000
00000000000000000000000000000000666066606660000066606660000066600000000000000000000000000000000000000000000000000055055000000000
00000000000000000000000066666660666066606666666066666660666666606600000000000660000006606600066000000000660000005000055000000000
00000000000000000000000066666660666066606666666066666660666666606660000000006660000066606660666000000000666000005055000000000000
00000000000000000000000066666660666066600666666006666600666666006660000000006660000066606660666000000000666000005055055000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000060000000000505050506660666000000000000550000000000000000000000000000000000000000000000000000000000000000000
60000000060000000000006000000600000000000000000000500500000000500500005005050050005000000000005000500000000000000000000000000000
66000000660000000000066000000660505050506066606000050000055005000500005005000000000005000050055000000500000000000000000000000000
00000000000000000000000000000000000000000000000005050000555050000005000000005000000000000000000005000000000000000000000000000000
66000000660000000000066000000660505050505050505000005050000050500005050000005050000000000000000000055000000000000000000000000000
0005000000050000000500000005000000000000000000000050500000050000050505000500005000050000005500500050050000aaaaa00000000000000000
600000006000000000000060000000605050505050505050000050000005000005000000050500500000000005555000005550000aaaaaaaa000000000aaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aaaaaaaa00000aaaaaaa0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00aaaaaaaaaaaaaaaaaaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaa0a
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaa0aa
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaa0aa0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaa0a0a0a0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00aaa0a0a0a0a0a0a0a0a0a
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0000aaaa0a0a0a0a0aaa00a
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa000000aaaaaaaaaaa000aa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa000aa000000000000000aa
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0000aaaaaaaaaa0000aa0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0aa00000000000000aa0a0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00aa0000000000aa00a00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa00aaaaaaaaaa00aa000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0000000000aa00000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000006000000000006000000000000006600660000000000600060000000000000666000006660000066600000666000
00000000006660000000000000000000006600600006600060066000006600000060006066006600600060006600660000606600006066000060660000606600
00666000060666000066600000000000006660606066600060666000006660600060006000600060060006000060006066066660660666600006666000066660
06066600060666000606660006666660066666006066006006666600600660600606660006066600060666000606660060666660606666606666666066666660
60666660066666006066666060066666600666000666660006660060066666006060606060606660606666606066606000606600006606606060660060666660
66666660066666006666666066666666606660000666600000666060006666006066066060666060606060606060666000000660000660660000066000066066
06666600006660000666660006666660006666000066660006666000066660000666666006606660066606600666606000006600006606000000660000660660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066600000000000000000000000000000000000000000000000000006600000000000000666000000000000000000000666600666666000066660000666600
00600660006666000000000000666600006600000000000000660000066660000066600066666600006660000000000066066000660660006606600066666000
00000060060006606666660006000660066660000066000006666000006060006666660060666600666666000066600066666600006666006666660066666600
00006660000066600000666000006660006060000666600000606000666660606066660066666660606666006666660000006000000060000000600000006000
00666600006666000066660000666600666660600060600066666060606666606666666000666660666666606066660000660060006600000066006000660000
66066060660660606606606066066060606666606666606060666660000666000066666066666660006666606666666006660060066600000666006006660000
06606060066060600660606006606060000666006066666000066600000000006666666060606660666666600066666000666600006666600066660000666660
00000000000000000000000000000000000000000006660000000000000000006060666000066660606066606666666000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000606000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
00060600006666000006060000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
00666600000606660066660000060666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000
00060666000666660006066600066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
06066666006000000006666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
66000000066066000660000066066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66066606066066000660660066066606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600000660000060060000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000050500050303030103010307020005050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505000000000000000004040000000000010101000000000000000000000000000101010000000000000000000000000001030100000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020203030303030303030303030303030303030303030303030303030303030303030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020f0101010d01010707020801c00e0203030303030303030303030303030303030000000000000000000000000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101070201010707020101c0c00203030303030303030303030303030303030000001011111111111200000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010108020801010102010101010203030303030310111203030303030303030000002002020202022200000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101080208010108020707010102030303101111240e2311111203030303030000002002050205022200000003030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010102020d0202020202020d0203030320040445444504042203030303030000002004040404042200000003030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02080101080201010102010d01010102030303204a01444444014b22030303030303000020014d4e4f012200000003030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0208010808020101010201020d020202030303204001440644014322030303030303000020015d5e5f012200000003030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020d02020201c001020102c0c00802030303204801444444010122030303030303000020016d6e6f012200000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010d0101010201020101010203030320070101010101072203030303030000002001010101012200000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d02020202020101010201020101010203030320080701010108082203030303030000003014010101133200000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102020d02020201020101010203030330313114011331313203030303030000000020010f01220000000003030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101020101010102010d010a0102030303030303200f2203030303030303030000000030313131320000000003030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102010c01c0020102c001010203030303030330313203030303030303030000000000000000000000000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010d01c001010d01020101070203030303030303030303030303030303030000000000000000000000000000030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020203030303030303030303030303030303030303030303030303030303030303030202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000211102114015140271300f6300f6101c610196001761016600156100f6000c61009600076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b61006540065401963018630116100e6100c610096100861000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001f5302b5302e5302e5303250032500395002751027510285102a510005000050000500275102951029510005000050000500005002451024510245102751029510005000050000500005000050000500
0001000024030240301c0301c0302a2302823025210212101e2101b2101b21016210112100d2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100a2100020000200
0001000024030240301c0301c03039010390103a0103001030010300102d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000210302703025040230301a030190100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000d720137200d7100c40031200312000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
