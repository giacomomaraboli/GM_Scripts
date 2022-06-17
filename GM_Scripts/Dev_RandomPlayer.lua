-- @description Random player
-- @author Giacomo Maraboli
-- @version 1.3
-- @about
--   Random player similar to wwise random container


--------------
reaper.ClearConsole()
function saveSel()
    
    local sel ={}
    local num = reaper.CountSelectedMediaItems()
    for i=0, num-1 do
        sel[#sel+1] = reaper.GetSelectedMediaItem(0,i)
    end
    return sel
end

function reSel(sel)
    local sel = sel
    for i = 1,#sel do
        reaper.SetMediaItemSelected( sel[i], true )
    end
end
------------------------------------------

function mode()

     itemMode= GUI.Val("Opt")
     
     if itemMode == 1 then
        getSel()
    else
        getVert() 
    end

end
------------------------------


------------------------------
function checkItems (itemNumber, regStart, regEnd) 
      for i=0, itemNumber-1 do
          found = false
          nextItem = reaper.GetSelectedMediaItem(0, i)
          if nextItem == nil then break end
          
          nextItemStart =  reaper.GetMediaItemInfo_Value(nextItem, "D_POSITION")
          nextItemEnd = nextItemStart + reaper.GetMediaItemInfo_Value(nextItem, "D_LENGTH")
          if (nextItemStart >= regStart and nextItemStart <= regEnd) or (nextItemEnd >= regStart and nextItemEnd <= regEnd)then
                                     
              if nextItemStart < regStart then
                 regStart = nextItemStart
                 found = true
                 reaper.SetMediaItemSelected( nextItem, 0 )
             
                 return regStart, regEnd, found
            
                        
              elseif nextItemEnd > regEnd then
                 regEnd = nextItemEnd
                 found = true  
                 reaper.SetMediaItemSelected( nextItem, 0 )
              
                 return regStart, regEnd, found
              
              else  
                  found = true  
                  reaper.SetMediaItemSelected( nextItem, 0 )
               
                  return regStart, regEnd, found
              end
              
          end
         
      end    
      
      return regStart, regEnd, found
end

------------------------------------------------------
function getVert() 
    
    opts = GUI.Val("List")
    pos[opts] = {}
    endPoint[opts] = {}
    items[opts]={}
    opts = GUI.Val("List")
    selItemNum = reaper.CountSelectedMediaItems()
    for i=0, selItemNum -1 do
        item = reaper.GetSelectedMediaItem(0,i)
        regionStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        regionEnd = regionStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        pos[opts][#pos[opts]+1] = regionStart
        endPoint[opts][#endPoint[opts]+1] = regionEnd
        items[opts][#items[opts]+1] = item
    end
  
end

-----------------------------------------------
                
function getSel()

sel = saveSel()
opts = GUI.Val("List")



i=0

lastItem = false
             
pos[opts] = {}
endPoint[opts] = {}
  while true do
      
      selItemNum = reaper.CountSelectedMediaItems()
      
      found = true
      item = reaper.GetSelectedMediaItem(0, 0)
      if item == nil then break end
      
      regionStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      regionEnd = regionStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
     
      
      
      while found == true do
          
          regionStart, regionEnd, found = checkItems(selItemNum, regionStart, regionEnd)
         
      end
          
      pos[opts][#pos[opts]+1] = regionStart
      endPoint[opts][#endPoint[opts]+1] = regionEnd
     -- regionindex=reaper.AddProjectMarker2(0, true, regionStart, regionEnd, "", -1, 1)
      
      reaper.SetMediaItemSelected( item, 0 )
     
  
  end 


reSel(sel)
    
end

---------------------------


function randomPlay()
    if #pos == 0 then return end
    
    dly1 = GUI.Val("Slider1")
    dly2 = GUI.Val("Slider2")
    rndIdx1 = math.random(1, #pos[1])
    if #pos > 1 then
        rndIdx2 = math.random(1, #pos[2])
    end
    if #pos > 2 then
        rndIdx3 = math.random(1, #pos[3])
    end

    --if #pos == 1 then
        reaper.SetEditCurPos(pos[1][rndIdx1], false, false)
        if GUI.Val("Opt") == 2 then
            reaper.Main_OnCommand(40289,0)--clear item selection
            reaper.SetMediaItemSelected( items[1][rndIdx1], true )
            reaper.Main_OnCommand(41558,0)--solo exclusive
        end
        reaper.Main_OnCommand(1007,0) --play
        
        playState1()
        
end



function stop()

 reaper.Main_OnCommand(1016,0)
-- reaper.Main_OnCommand(41185,0)--unsolo all
end
--------------------------------
function clear()
    clearOpt = GUI.Val("List")
    pos = {}

end


function playState1()

    cursor =  reaper.GetPlayPosition()
 
    if cursor > endPoint[1][rndIdx1] then
        
        if #pos > 1 then
            timerStart = reaper.time_precise()
            while true do
                elapsed = reaper.time_precise() - timerStart
            
                if elapsed >= dly1 then
                   
                    break
                end
            end
           
            reaper.SetEditCurPos(pos[2][rndIdx2], false, false)
            if GUI.Val("Opt") == 2 then
                reaper.Main_OnCommand(40289,0)--clear item selection
                reaper.SetMediaItemSelected( items[2][rndIdx2], true )
                reaper.Main_OnCommand(41558,0)--solo exclusive
            end
            
            reaper.Main_OnCommand(1007,0) --play
            playState2()
        else
            reaper.Main_OnCommand(1016,0) --stop
            reaper.Main_OnCommand(41185,0)--unsolo all
        end
        return
    else
        reaper.defer(playState1)
    end
   
end 

function playState2()
    
    cursor =  reaper.GetPlayPosition()

    if cursor > endPoint[2][rndIdx2] then
        reaper.Main_OnCommand(1016,0) --stop
        reaper.Main_OnCommand(41185,0)--unsolo all
        if #pos > 2 then
            timerStart = reaper.time_precise()
            while true do
                elapsed = reaper.time_precise() - timerStart
                        
                if elapsed >= dly2 then
                               
                    break
                end
            end
            
            reaper.SetEditCurPos(pos[3][rndIdx3], false, false)
            if GUI.Val("Opt") == 2 then
                reaper.Main_OnCommand(40289,0)--clear item selection
                reaper.SetMediaItemSelected( items[3][rndIdx3], true )
                reaper.Main_OnCommand(41558,0)--solo exclusive
            end
            reaper.Main_OnCommand(1007,0) --play
            playState3()
        end
        return
    else
        reaper.defer(playState2)
    end
   
end 

function playState3()
    
    cursor =  reaper.GetPlayPosition()

    if cursor > endPoint[3][rndIdx3] then
        reaper.Main_OnCommand(1016,0) --stop
        reaper.Main_OnCommand(41185,0)--unsolo all
        
        return
    else
        reaper.defer(playState3)
    end
   
end 

-------------------------------------------------------------------------




--MAIN

pos ={}   
endPoint={}
items={}

---------------------------------------------------------------------------------
-- Script generated by Lokasenna's GUI Builder


local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()




GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Slider.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end



GUI.name = "Random Play"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 400, 180
GUI.anchor, GUI.corner = "screen", "C"


--override of function in core.lua
GUI.Main_Update_State = function()

    -- Update mouse and keyboard state, window dimensions
    if GUI.mouse.x ~= gfx.mouse_x or GUI.mouse.y ~= gfx.mouse_y then

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y
        GUI.mouse.x, GUI.mouse.y = gfx.mouse_x, gfx.mouse_y

        -- Hook for user code
        if GUI.onmousemove then GUI.onmousemove() end

    else

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y

    end
    GUI.mouse.wheel = gfx.mouse_wheel
    GUI.mouse.cap = gfx.mouse_cap
    GUI.char = gfx.getchar()
  
  if GUI.char == 13 and GUI.ReturnSubmit then GUI.ReturnSubmit() end   ---ADDED
  

    if GUI.cur_w ~= gfx.w or GUI.cur_h ~= gfx.h then
        GUI.cur_w, GUI.cur_h = gfx.w, gfx.h

        GUI.resized = true

        -- Hook for user code
        if GUI.onresize then GUI.onresize() end

    else
        GUI.resized = false
    end

    --  (Escape key)  (Window closed)    (User function says to close)
    --if GUI.char == 27 or GUI.char == -1 or GUI.quit == true then
    if (GUI.char == 27 and not (  GUI.mouse.cap & 4 == 4
                                or   GUI.mouse.cap & 8 == 8
                                or   GUI.mouse.cap & 16 == 16
                                or  GUI.escape_bypass))
            or GUI.char == -1
            or GUI.quit == true then

        GUI.cleartooltip()
        return 0
    else
        if GUI.char == 27 and GUI.escape_bypass then GUI.escape_bypass = "close" end
        reaper.defer(GUI.Main)
    end

end







GUI.New("Button1", "Button", {
    z = 11,
    x = 160,
    y = 40,
    w = 80,
    h = 40,
    caption = "Play",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = randomPlay
})

GUI.New("Button2", "Button", {
    z = 11,
    x = 60,
    y = 40,
    w = 80,
    h = 40,
    caption = "Get Sel",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = mode
})

GUI.New("Button3", "Button", {
    z = 11,
    x = 260,
    y = 40,
    w = 80,
    h = 40,
    caption = "Stop",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = stop
})

GUI.New("Button4", "Button", {
    z = 11,
    x = 160,
    y = 140,
    w = 80,
    h = 20,
    caption = "Clear",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = clear
})




GUI.New("List", "Radio", {
    z = 11,
    x = 160,
    y = 100,
    w = 80,
    h = 45,
    caption = "",
    optarray = {"1", "2", "3"},
    dir = "h",
    pad = 5,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = nil,
    opt_size = 20
})

GUI.New("Opt", "Radio", {
    z = 11,
    x = 60,
    y = 100,
    w = 80,
    h = 45,
    caption = "",
    optarray = {"H", "V"},
    dir = "v",
    pad = 5,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = nil,
    opt_size = 20
})

GUI.New("Slider1", "Slider", {
    z = 11,
    x = 260,
    y = 110,
    w = 80,
    caption = "Delay",
    min = 0,
    max = 5,
    defaults = 0,
    inc = 0.1,
    dir = "h",
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_fill = nil,
    bg = "wnd_bg",
    show_handles = true,
    show_values = true,
    cap_x = 0,
    cap_y = 0
})

GUI.New("Slider2", "Slider", {
    z = 11,
    x = 260,
    y = 145,
    w = 80,
    caption = "",
    min = 0,
    max = 5,
    defaults = 0,
    inc = 0.1,
    dir = "h",
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_fill = false,
    bg = "wnd_bg",
    show_handles = true,
    show_values = true,
    cap_x = 0,
    cap_y = 0
})

GUI.Init()
GUI.Main()
GUI.Val("Fade", userFade)
GUI.Val("Lenght", userLenght)
GUI.Val("Loop(s)", userNumLoop)
GUI.Val("Color", {userColor})
GUI.Val("Glue", {userGlue})
GUI.Val("Group", {userGroup})

GUI.ReturnSubmit = doIt 
