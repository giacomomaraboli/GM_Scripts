-- @description loop utility
-- @author Giacomo Maraboli
-- @version 1.1.5
-- @about
--   loop utility

--USER DEFAULT--
userLenght = 0
userNumLoop = 1
userFade = 2
userColor = true
userGlue = false
userGroup = true
---------------

reaper.ClearConsole()

function createLoop(item, lenght, index, loopStart)

    local itm = item
    local loopLenght = lenght
    --local startPoint = origStart
    local idx = index
    --local loopEnd = loopEnd
    
    local reposition = loopStart
    
    
    reaper.SetMediaItemSelected( itm, true )
    local itStart =  reaper.GetMediaItemInfo_Value(itm, "D_POSITION")
    local itEnd = itStart + reaper.GetMediaItemInfo_Value(itm, "D_LENGTH")
    local itLenght = itEnd - itStart
    local itMidPoint= itStart + (itLenght/2)
    
    reaper.SetEditCurPos(itMidPoint, false, false)
    reaper.Main_OnCommand(41995, 0) --move cursor to nearest zero crossing
    
    --when items are too short, the zero crossing position could mess up with the reposition of items
    
    local zPos = reaper.GetCursorPosition() --get new cursor position
    
    reaper.Main_OnCommand(40757, 0) --split item at cursor
    
    reaper.SetEditCurPos(zPos-((loopLenght/2)+(fade/2)), false, false)
    reaper.Main_OnCommand(40511, 0) --trim left
    
    
    reaper.SetEditCurPos(zPos+((loopLenght/2)+(fade/2)), false, false)
    reaper.Main_OnCommand(40512, 0) --trim right
    
    
  
   
    reaper.SetMediaItemInfo_Value( reaper.GetSelectedMediaItem(0,0), "D_POSITION" , reposition+((loopLenght/2)-(fade/2)) )
    reaper.SetMediaItemInfo_Value( reaper.GetSelectedMediaItem(0,1), "D_POSITION" , reposition )
   
   
    loopStart = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,1), "D_POSITION")+reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,1), "D_LENGTH")
    
    
    reaper.Main_OnCommand(41059, 0) --crossfade items
    if group and not glue then
        reaper.Main_OnCommand(40032, 0) --group items
    end
    if glue then
       reaper.Main_OnCommand(42432, 0) --glue items
    end
    if color then
    
       reaper.Main_OnCommand(40706, 0) --random color
    end
    return loopStart
    
end

function doIt()

glue = GUI.Val("Glue")
color = GUI.Val("Color")
group = GUI.Val("Group")




--GUI.quit = true
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
num=reaper.CountSelectedMediaItems()

it = reaper.GetSelectedMediaItem(0,0)
origTrack = reaper.GetMediaItem_Track( it )
origTrackNum = reaper.GetMediaTrackInfo_Value( origTrack, "IP_TRACKNUMBER"  )
origStartPos =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")

st =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
en = st + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
shortest = en-st


for i=0, num-1 do
      it = reaper.GetSelectedMediaItem(0,i)
      st =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
      en = st + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
      len = en-st
      if len < shortest then
          shortest = len
      end
end
      
    






origItems={}
for x=0, num -1 do --put itmes in array
    
    origItems[x+1] = reaper.GetSelectedMediaItem(0,x)
end

for x=1, #origItems do

    lenght = tonumber(GUI.Val("Lenght")) --set UI values
    
    numLoop = tonumber(GUI.Val("Loop(s)"))
    fade = tonumber(GUI.Val("Fade"))
   
    reaper.SelectAllMediaItems( 0, false )
    
    it = origItems[x]
    reaper.SetMediaItemSelected( it, true )
    
    
   
    
    origStart =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
    origEnd = origStart + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
    itLenght = origEnd - origStart  --calculate item lenght

    if lenght == 0  or (itLenght < lenght*numLoop) then --set target lenght
        
        lenght = (shortest/numLoop)-fade
    end
    
   

    numDivision = itLenght/numLoop

    for i=1, numLoop  do
        splitPoint = origStart + (numDivision * i) --divide item depending on number of loops
        reaper.SetEditCurPos(splitPoint, false, false)
        reaper.Main_OnCommand(40757, 0) --split item at cursor
    
    end

    
    loops={}
    selNum = reaper.CountSelectedMediaItems() --put new items in array
    for i=0, selNum -1 do
       
        loops[i+1]= reaper.GetSelectedMediaItem(0,i)
    end

    
    reaper.SelectAllMediaItems( 0, false )
    
    track = reaper.GetMediaItem_Track( it )--set starting point for item in different track in order to be aligned to be aligned
    trackNum = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER"  )
        
    if trackNum == origTrackNum then
        loopStart = origStart
    else
        loopStart = origStartPos
        origTrackNum = trackNum
    end
        
        
        
    for i=0, #loops -1 do

        item = loops[i+1]
        loopStart = createLoop(item, lenght, i, loopStart)
        
        reaper.SelectAllMediaItems( 0, false )
        
       
    end
    
end
reaper.SetEditCurPos(origStart, false, false)
reaper.Undo_EndBlock("Undo loop creation", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
end



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
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end



GUI.name = "Loop Utiliy"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 190, 160
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


GUI.New("Glue", "Checklist", {
    z = 11,
    x = 112,
    y = 48,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Glue"},
    dir = "v",
    pad = 1,
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

GUI.New("Group", "Checklist", {
    z = 11,
    x = 112,
    y = 80,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Group"},
    dir = "v",
    pad = 1,
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

GUI.New("Fade", "Textbox", {
    z = 11,
    x = 48,
    y = 48,
    w = 40,
    h = 20,
    caption = "Fade",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})

GUI.New("Loop(s)", "Textbox", {
    z = 11,
    x = 48,
    y = 80,
    w = 40,
    h = 20,
    caption = "Loop(s)",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})

GUI.New("Color", "Checklist", {
    z = 11,
    x = 112,
    y = 16,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Color"},
    dir = "v",
    pad = 1,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = false,
    opt_size = 20,
    
})

GUI.New("Lenght", "Textbox", {
    z = 11,
    x = 48,
    y = 16,
    w = 40,
    h = 20,
    caption = "Lenght",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})

GUI.New("Button1", "Button", {
    z = 11,
    x = 70,
    y = 115,
    w = 60,
    h = 20,
    caption = "GO!",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = doIt
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
