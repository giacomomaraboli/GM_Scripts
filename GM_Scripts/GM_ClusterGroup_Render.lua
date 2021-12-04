-- @description render groups or items
-- @author Giacomo Maraboli
-- @version 1.1.2
-- @about
--   render group or items


--USER DEFAULTS--

userChannels = "stereo" -- "quad" --"5.1"--"mono"
user2ndpass = false
userTailLenght = 0
userSingleFile = false
userImport = false

---------------------
reaper.ClearConsole()

function singleFile()

    
reaper.Main_OnCommand( 41561, 0 ) --solo selected items
num = reaper.CountSelectedMediaItems()



for i =0, num -1 do
    item = reaper.GetSelectedMediaItem(0,i)
    itemStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    
    if i == 0 then
        regionStart = itemStart
        regionEnd = itemEnd
    end
    
    if itemStart < regionStart then
        regionStart = itemStart
    end
    if itemEnd > regionEnd then
        regionEnd = itemEnd
    end
end
    regIdx=reaper.AddProjectMarker2(0, true, regionStart, regionEnd, "", -1, 1)      --create regions
    reaper.SetRegionRenderMatrix( 0, regIdx, reaper.GetMasterTrack( 0 ) , 1 )

_, itemText = reaper.GetSetMediaItemInfo_String(reaper.GetSelectedMediaItem(0,0), "P_NOTES","",false )

name = GUI.Val("TextboxName")

if string.find(name,"@") == nil then
                    
      regionName = name
else
    regionName = string.gsub(name, "@", itemText)
    
    if string.sub(regionName,-3,-3) == "_" then      --check if there is an index, if so remove it
        regionName=regionName:sub(1,-4) .. ""
                  
    elseif string.sub(regionName,-4,-4) == "_" then
        regionName=regionName:sub(1,-5) .. ""
    end 
            
end

    
reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,regionName, true ) --set name of rendering
reaper.Main_OnCommand( 41824, 0 ) --render with windows open

reaper.DeleteProjectMarker( 0, regIdx, true )
reaper.Main_OnCommand( 41561, 0 ) --unsolo selected items
if  GUI.Val("Import") == true then
    reaper.Main_OnCommand( 41557, 0 )  --untoggle solo
end


reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , origTailLenght, true )
reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,origRenderSetting, true ) --set 2nd pass render
reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" ,origTailFlag, true ) --set tail active
reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , origNmChannel, true ) --set numebr of channels
reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,origRanderName, true )
reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,origBounds, true ) 
reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , origRenderFormat, true )
reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", origImport, true )


reaper.Undo_EndBlock("Render", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
end






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


function clusterFreeRender()


i=0
reaper.Main_OnCommand( 41561, 0 ) --solo selected items
num = reaper.CountSelectedMediaItems()
allItems = {}
for i=0, num-1 do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end
lastItem = false
regions = {}
k=1

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
          
     
      regIdx=reaper.AddProjectMarker2(0, true, regionStart, regionEnd, "", -1, 1)      --create regions
      regions[k] = regIdx 
      k=k+1
      reaper.SetRegionRenderMatrix( 0, regIdx, reaper.GetMasterTrack( 0 ) , 1 )
      reaper.SetMediaItemSelected( item, 0 )
     
  
end
if #regions > 1 then

    name  = GUI.Val("TextboxName").."_$regionnumber"
else
    name = GUI.Val("TextboxName")
end


reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,name, true ) --set name of rendering
reaper.Main_OnCommand( 41824, 0 ) --render with windows open



k=1
while regions[k]~= nil do  --delete all regions
         
      reaper.DeleteProjectMarker( 0, regions[k], true )
      k=k+1
end

for i=0, num-1 do
    item = allItems[i]
    reaper.SetMediaItemSelected( item, true )
end


reaper.Main_OnCommand( 41561, 0 ) --solo selected items
if  GUI.Val("Import") == true then
    reaper.Main_OnCommand( 41557, 0 )  --untoggle solo
end



reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , origTailLenght, true )
reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,origRenderSetting, true ) --set 2nd pass render
reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" ,origTailFlag, true ) --set tail active
reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , origNmChannel, true ) --set numebr of channels
reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,origRanderName, true )
reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,origBounds, true ) 
reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , origRenderFormat, true )
reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", origImport, true )


reaper.Undo_EndBlock("Render", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()


end




function clusterGroupPrep()
num=reaper.CountSelectedMediaItems()
j=1
emptyItems={}  --put all empty items in array
for i=0,num-1 do
    item = reaper.GetSelectedMediaItem(0,i)
    take = reaper.GetActiveTake(item)
        if not take then
          emptyItems[j] = item
                       j=j+1
        end
end


j=1
k=1
renderGroup={}
renderGroup[j]={}

for i=1, #emptyItems do   
--for each empty item check if overlaps with other empty items and populate a table with the different render groups - one render group for all non overlapping items

    item = emptyItems[i]
    itemStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
   
     
    if i==1 then  --first time in the loop - insert first item in table 
        renderGroup[j][k] = item
    else
     
    j=1
    k=1
    done = false
    while renderGroup[j] ~= nil do  --check the next empty item start and end with all the empty items already in the table
        
        overlap = false
        
        while renderGroup[j][k] ~= nil do
            
            
            it = renderGroup[j][k]
            if it ~= item then  
            
                st = reaper.GetMediaItemInfo_Value(it, "D_POSITION")
                en = st + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
            
                if (itemStart>=st and itemStart <= en) or ( itemEnd >= st and itemEnd <= en) then
                    
                    overlap = true
                    break
                end
            end
                
            k=k+1
            
        end
        
        if overlap == false then  --not overlapping, insert item in the same array
                     
            renderGroup[j][k] = item
            done = true
            break
        end
        if done then break end
        
        j=j+1
        
        k=1
    end 
    
    if done == false then --overlapping createing the next array and put in the first element
      
      k=1
      renderGroup[j] ={}
       
      renderGroup[j][k] = item
    end
  end
end
 render()


end






function setRenderOptions()  --set general render option from GUI

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
    --GUI.quit = true
    item = reaper.GetSelectedMediaItem(0, 0)
    if not item then return end
    tk = reaper.GetActiveTake(item)
    if tk then 
        group = false
       -- reaper.ShowConsoleMsg("do cluster regions render")
    else    
        isGrouped = reaper.GetMediaItemInfo_Value( item, "I_GROUPID"  )
        if isGrouped == 0 then 
            retval = reaper.MB("Empty item not in a group", "Error", 0 ) 
            return 
            
        end
        group = true
        --defaultText()
        --retval = reaper.MB("Not an empty item", "Error", 0 )
    end
    
    
    local opts = GUI.Val("Checklist1")
    if opts == 2 then 
        loop = 2048
        tail=0
        
    else 
        loop = 0
        
        tailLenght = tonumber(GUI.Val("TextboxTail"))
        if tailLenght == 0 then
            tail = 0
            
        else
            tail = 8
            tailLenght = tailLenght * 1000
            reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , tailLenght, true )  --set render tail lenght in ms
        end
        
    end
    
    if GUI.Val("Import") == true then
        reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", 1, true )
    else
        reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", 0, true )
    end
    
    reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,3, true )
    reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , "wave", true )
    reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" , (8|loop), true ) --set 2nd pass render
    reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" , tail, true ) --set tail 
    
    
    optChan = GUI.Val("Channels")
    if optChan == 1 then channel = 1
    elseif optChan == 2 then channel = 2
    elseif optChan == 3 then channel = 4
    elseif optChan == 4 then channel = 6
    end
   
    reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , channel, true ) --set numebr of channels
    if GUI.Val("Single") == true then
       
        singleFile()
    else
        if group == true then
            clusterGroupPrep()
        
        else
            clusterFreeRender()
        end
    end
   
   
end
 
    
    
    
    
function render() --render cluster group
     
      
      regions ={}
      j=1
      k=1
      i=1
      lenght = #renderGroup
      while renderGroup[j] ~= nil do
          
          reaper.SelectAllMediaItems( 0, false )
          while renderGroup[j][k] ~= nil do
          --goes trough every array in the table and render them separately
              
            item = renderGroup[j][k]
            reaper.SetMediaItemSelected(item, true)
            reaper.Main_OnCommand(40034,0)  --select all items in group
            
            itemStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            _, itemText = reaper.GetSetMediaItemInfo_String(item , "P_NOTES","",false )
            nName = GUI.Val("TextboxName")
            
            if default_text  == "" then
            
                if string.find(nName,"@") == nil then
                    add = "_" .. string.format("%02d", tostring(i))
                    i=i+1
                    regionName = nName..add
                else
                    regionName = string.gsub(nName, "@", itemText)
            
                end
            elseif default_text == "@" then
            
                regionName = string.gsub(nName, default_text, itemText)
            
                
              
            end
            
            regIdx = reaper.AddProjectMarker2(0, true, itemStart, itemEnd, regionName, -1, 1)   --create regions
            regions[k] = regIdx 
            reaper.SetRegionRenderMatrix( 0, regIdx, reaper.GetMasterTrack( 0 ) , 1 ) --load region in render matrix
            k=k+1
          end
      
       
      
      reaper.Main_OnCommand( 41561, 0 )  --solo exlclusive
      reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,"$region", true )
      if j == lenght then
          reaper.Main_OnCommand( 41824, 0 ) --render with windows open
      else
          reaper.Main_OnCommand( 42230, 0 ) --render with windows auto close
      end
      j=j+1
      k=1
      
      
      
      while regions[k]~= nil do  --delete all regions
         
          reaper.DeleteProjectMarker( 0, regions[k], true )
          k=k+1
      end
      
     
      k=1
      end
      
      
      
      for i=1, #emptyItems do
          item = emptyItems[i]
          reaper.SetMediaItemSelected(item, true)
          reaper.Main_OnCommand(40034,0)  --select all items in group
      end
      
      reaper.Main_OnCommand( 41561, 0 )  --untoggle solo exlclusive
      if  GUI.Val("Import") == true then
          reaper.Main_OnCommand( 41557, 0 )  --untoggle solo
      end
      
      --reaper.Main_OnCommand( 41557, 0 )  --untoggle solo
      
      
      
      --reset original render settings
      reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , origTailLenght, true )
      reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,origRenderSetting, true ) --set 2nd pass render
      reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" ,origTailFlag, true ) --set tail active
      reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , origNmChannel, true ) --set numebr of channels
      reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,origRanderName, true )
      reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,origBounds, true ) 
      reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , origRenderFormat, true )
      
      reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", origImport, true )
      
reaper.Undo_EndBlock("Render", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
      
end





--MAIN
reaper.ClearConsole()

num=reaper.CountSelectedMediaItems()
item = reaper.GetSelectedMediaItem(0, 0)
if not item then return end
tk = reaper.GetActiveTake(item)
if tk then 
    group = false
    default_text = ""
   -- reaper.ShowConsoleMsg("do cluster regions render")
else    
    isGrouped = reaper.GetMediaItemInfo_Value( item, "I_GROUPID"  )
    if isGrouped == 0 then 
        retval = reaper.MB("Empty item not in a group", "Error", 0 ) 
        return 
        
    end
    group = true
    default_text = "@"
    --retval = reaper.MB("Not an empty item", "Error", 0 )
end



--save render existing render settings

origTailLenght = reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , 0, false )
origRenderSetting = reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,0, false ) --set 2nd pass render
origBounds = reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,0, false )
origTailFlag = reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG " ,0, false ) --set tail active
origNmChannel = reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , 0, false ) --set numebr of channels
_,origRanderName = reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,"", false )
_, origRenderFormat = reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , "", false )
origImport = reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", 0, false )



-- Script generated by Lokasenna's GUI Builder
local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

loadfile(lib_path .. "Core.lua")()




GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Button.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "Render Groups"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 600, 158
GUI.anchor, GUI.corner = "screen", "C"


--GUI first part END
--Start script code



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

--override of function in textbox.class
function GUI.Textbox:new(name, z, x, y, w, h, caption, pad)

  local txt = (not x and type(z) == "table") and z or {}

  txt.name = name
  txt.type = "Textbox"

  txt.z = txt.z or z

  txt.x = txt.x or x
    txt.y = txt.y or y
    txt.w = txt.w or w
    txt.h = txt.h or h

    txt.retval = txt.retval or ""

  txt.caption = txt.caption or caption or ""
  txt.pad = txt.pad or pad or 4

    if txt.shadow == nil then
        txt.shadow = true
    end
  txt.bg = txt.bg or "wnd_bg"
  txt.color = txt.color or "txt"

  txt.font_a = txt.font_a or 3

  txt.font_b = txt.font_b or "monospace"

    txt.cap_pos = txt.cap_pos or "left"

    txt.undo_limit = txt.undo_limit or 20

    txt.undo_states = {}
    txt.redo_states = {}

    txt.wnd_pos = 0
    if group == true then
          txt.caret = string.len(default_text)
    else
          txt.caret = 0
    end
  txt.sel_s, txt.sel_e = nil, nil

    txt.char_h, txt.wnd_h, txt.wnd_w, txt.char_w = nil, nil, nil, nil

  txt.focus = false

  txt.blink = 0
  GUI.redraw_z[txt.z] = true

  setmetatable(txt, self)
  self.__index = self
  return txt

end







--Start GUI second part

GUI.New("Single", "Checklist", {
    z = 11,
    x = 355,
    y = 48,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Single file"},
    dir = "v",
    pad = 1,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = true,
    opt_size = 20
})

GUI.New("Import", "Checklist", {
    z = 11,
    x = 495,
    y = 48,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Import in project"},
    dir = "v",
    pad = 1,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = true,
    opt_size = 20
})

GUI.New("Checklist1", "Radio", {
    z = 11,
    x = 144,
    y = 48,
    w = 65,
    h = 45,
    caption = "",
    optarray = {"Tail", "2nd pass"},
    dir = "v",
    pad = 0,
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

GUI.New("Render", "Button", {
    z = 11,
    x = 230,
    y = 100,
    w = 128,
    h = 30,
    caption = "Render",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = setRenderOptions
    
})

GUI.New("Channels", "Menubox", {
    z = 11,
    x = 64,
    y = 48,
    w = 65,
    h = 20,
    caption = "Channels",
    optarray = {"Mono", "Stereo", "Quad", "5.1"},
    retval = 2,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4,
    noarrow = false,
    align = 0
})

GUI.New("TextboxTail", "Textbox", {
    z = 11,
    x = 210,
    y = 48,
    w = 50,
    h = 20,
    caption = "Lenght (s)",
    cap_pos = "right",
    font_a = 4,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    
    pad = 4,
    undo_limit = 20
})

GUI.New("TextboxName", "Textbox", {
    
    z = 11,
    x = 64,
    y = 16,
    w = 500,
    h = 20,
    caption = "Name",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    
    
})

GUI.Init()
GUI.Main()
GUI.elms.TextboxName.focus = true
GUI.Val("TextboxTail", userTailLenght)
if user2ndpass == true then
    GUI.Val("Checklist1", 2)
else  
    GUI.Val("Checklist1", 1)
end

GUI.Val("Single", {userSingleFile})
GUI.Val("Import", {userImport})
if userChannels == "stereo" then
    GUI.Val("Channels", 2)
elseif userChannels == "mono" then
    GUI.Val("Channels", 1)
elseif userChannels == "5.1" then
    GUI.Val("Channels", 4)
elseif userChannels == "quad" then
    GUI.Val("Channels", 3)
end


GUI.Val("TextboxName",default_text) 
GUI.ReturnSubmit = setRenderOptions
      
      
      
      
      
