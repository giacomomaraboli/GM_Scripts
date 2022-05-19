-- @description New rename items
-- @author Giacomo Maraboli
-- @version 1.3
-- @about
--   rename items - to be used with Auto folder item

reaper.ClearConsole()

--is there a way to have the textbox selected when script opens?
----------------------------------------------------------------------------------------------
function contains(parentItem, item)
--returns true is item is inside parentItem timewise

      local parentItem = parentItem
      local item = item
      
      local parentIn = reaper.GetMediaItemInfo_Value( parentItem,"D_POSITION") - 0.000000000001
      local parentOut = parentIn + reaper.GetMediaItemInfo_Value( parentItem,"D_LENGTH") + 0.000000000002
      local itemIn = reaper.GetMediaItemInfo_Value( item,"D_POSITION") 
      local itemOut = itemIn + reaper.GetMediaItemInfo_Value( item,"D_LENGTH")
      
       
      if parentIn<=itemIn and itemOut<=parentOut then
          return true
      else
          return false
      end 
end --functions
-------------------------------------------------------------------------------------------------

function WriteNoteInChildrenItems(parentTrack, item, text, emptyitems)

    local parentTrack = parentTrack
    local parentItem = item
    local parentNum, track, m, item, i
    local depth
    local text = text
    local foundText = false
    local newFolder = false
    local fullText = ""
    local emptyItems = emptyItems
    
    parentNum = -1 + reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER")
    trackAbove =  reaper.GetTrack( 0, parentNum )
    x = 1
    j=0
    while trackAbove do
    
          folderDepth = reaper.GetMediaTrackInfo_Value( trackAbove, "I_FOLDERDEPTH"  )
                          --trackAbove =  reaper.GetTrack( 0, parentNum - x )
                          --x=x+1
          if folderDepth ~= 1 then
              break
          else
              trackAbove =  reaper.GetTrack( 0, parentNum - x )
                              --reaper.ShowConsoleMsg(parentNum-x.."\n")
              x=x+1
              j=j+1
          end
    end
    --reaper.ShowConsoleMsg(j.."\n")
    --reaper.ShowConsoleMsg(#emptyItems.."\n")
    i = 1
    depth = 0
    
    track = reaper.GetTrack(0, parentNum+i)
    depth = 0 --we know that this parent has at least one child 
    while depth>=0 do  
        fullText = ""
     
        track = reaper.GetTrack(0, parentNum+i)
    if track ~= nil then
      --select  items on the track
      for m=0, reaper.CountTrackMediaItems(track)-1 do
         item = reaper.GetTrackMediaItem(track, m)
         
         if contains(parentItem, item) then
            
            tk = reaper.GetActiveTake(item)
            if tk then 
                itemTrack = reaper.GetMediaItem_Track( item )
                itemTrackIdx = reaper.GetMediaTrackInfo_Value(itemTrack, "IP_TRACKNUMBER")
                --w = itemTrackIdx - j
                
                --reaper.ShowConsoleMsg((parentNum+1).."   ")
                --reaper.ShowConsoleMsg(itemTrackIdx.."\n")
                
                _, origText  = reaper.GetSetMediaItemInfo_String( item, "P_NOTES","",false )
                
                
                if origText ~= "" then
                    _,sepNum  = string.gsub(origText, ".SEP", "")
                    --reaper.ShowConsoleMsg(sepNum.."\n")
                    done = false
                    
                    for k=0, sepNum do
                        separator = string.format(" .SEP%01d. ",k)
                        _, origEnd =  string.find(origText, separator )
                        nextOrigBegin = string.find(origText, string.format(" .SEP%01d. ",k+1) )
                        
                      
                                               
                        if origEnd and nextOrigBegin then
                            temp = string.sub(origText, origEnd+1, nextOrigBegin-1)
                            
                            --reaper.ShowConsoleMsg(temp.."\n")
                        elseif origEnd and not nextOrigBegin then
                            temp = string.sub(origText, origEnd+1,-1)
                            --reaper.ShowConsoleMsg(temp.."\n")
                        else 
                                             --done = true
                            temp = ""
                           fullText = fullText..separator
                                break
                          
                        end
                        if k == j-1 then
                            temp = text
                        end
                                                             
                      
                 
                        fullText = fullText..separator..temp
                        
                    end
                else
                    -----------------------------find a way to count empty items stacked----
                    for k=0, 10 do
                        separator = string.format(" .SEP%01d. ",k)
                         
                                       
                        if k == j then
                            fullText = fullText..text
                            --break
                        end
                            fullText = fullText..separator
                    end
                end
                --reaper.ShowConsoleMsg(fullText.."\n")
                    Begin, End = string.find(fullText, string.format(" .SEP%01d. ",j-1) )
                    nextBegin, nextEnd = string.find(fullText, string.format(" .SEP%01d. ",j) )
                
                --end
                --reaper.ShowConsoleMsg(End.."     ")
                --reaper.ShowConsoleMsg(nextBegin.."\n")
                
                --string.insert(text, fulltext, End)
                
                --reaper.ShowConsoleMsg(fullText.."\n")
                
                
               _, _  = reaper.GetSetMediaItemInfo_String( parentItem, "P_NOTES",text,true )
               _, _  = reaper.GetSetMediaItemInfo_String( item, "P_NOTES",fullText,true )
               --reaper.BR_SetMediaItemImageResource( item, "", 3 )
               --reaper.BR_SetMediaItemImageResource( parentItem, "", 3 )
               
            --
            end    
         end 
     
      end --for
      
    
      
      --check depth
      depth = depth + reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
      i = i+1
        else 
      depth = -1
    end
    end --while 
    

end --function selectItems
-----------------------------------------------------------------------------------------
function rename()
   
   reaper.PreventUIRefresh(1)
   reaper.Undo_BeginBlock()
   
   selItemNum =  reaper.CountSelectedMediaItems() 
   item = reaper.GetSelectedMediaItem(0, 0)
   tr =  reaper.GetMediaItem_Track( item )
   idx =  reaper.GetMediaTrackInfo_Value( tr, "IP_TRACKNUMBER"  )
   
   
   
   if not item then return 
   end
   tk = reaper.GetActiveTake(item)
   if not tk then
      emptyItems = {}
             
         
      for i=0, selItemNum -1 do
          --reaper.ShowConsoleMsg(i)
          item = reaper.GetSelectedMediaItem(0, i)    --get item
          track =  reaper.GetMediaItem_Track( item )
          index =  reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER"  )
          
        
          tk = reaper.GetActiveTake(item)             --check if item is empty
          if not tk then
              if index == idx then
              
                  emptyItems[i+1]= item
              end
            
          end
      end
      --reaper.ShowConsoleMsg(#emptyItems)
      
      
      --reaper.ShowConsoleMsg(#emptyItems.."\n")
      for i=1, #emptyItems do
          item = emptyItems[i]
          --tr =  reaper.GetMediaItem_Track( item )
          
          text = GUI.Val("Name")
          if #emptyItems > 1 then
                           
             -- for i=0,#emptyItems -1 do
                    
                  if text ~= "" then
                      add = "_" .. string.format("%02d", tostring(i))    --add index
                      --reaper.ShowConsoleMsg(add.."\n")
                      text = text..add
                                     --reaper.ULT_SetMediaItemNote(emptyItems[i+1], text..add)
                  end
              --end
          end
          
          
          WriteNoteInChildrenItems(tr, item, text, emptyItems)
               -- _, _  = reaper.GetSetMediaItemInfo_String( firstItem, "P_NOTES","FDFFBFBAFBAFBA",true )
               -- _, _  = reaper.GetSetMediaItemInfo_String( item, "P_NOTES","FDFFBFBAFBAFBA",true )
          
 
          GUI.quit = true 
      
    
     end
  else
          items = {}
         -- reaper.ShowConsoleMsg("code missing")
          for i=0, selItemNum-1 do
              items[i+1] = reaper.GetSelectedMediaItem(0,i)
          end
          
          
          
          for i=1, #items do
              text = GUI.Val("Name")
              if #items > 1 then
                  if text ~= "" then
                      add = "_" .. string.format("%02d", tostring(i))    --add index
                                          
                    text = text..add
                  end
              end
              
              take = reaper.GetActiveTake(items[i])
              _, _ = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", text, true )
          end
                    
                  
          --put all the selected items in an array
          --name all the items
          --be aware of the numbers
  end
   
  
  reaper.Undo_EndBlock("Undo rename items", -1) 
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
 
end



--MAIN

item = reaper.GetSelectedMediaItem(0, 0)
if not item then return end
tk = reaper.GetActiveTake(item)
if tk then
    _, default_text = reaper.GetSetMediaItemTakeInfo_String( tk, "P_NAME" , "", false )
   
    
    if default_text ~= "" then 
            if string.sub(default_text,-3,-3) == "_" then      --check if there is an index, if so remove it
               default_text=default_text:sub(1,-4) .. ""
                      
            elseif string.sub(default_text,-4,-4) == "_" then
            default_text=default_text:sub(1,-5) .. ""
            end
                
    end
      
    
else
    selItemNum =  reaper.CountSelectedMediaItems()  --count number of items
    diff = false
    
   
    _, default_text = reaper.GetSetMediaItemInfo_String(item, "P_NOTES","",false )

    if default_text ~= "" then 
        if string.sub(default_text,-3,-3) == "_" then      --check if there is an index, if so remove it
           default_text=default_text:sub(1,-4) .. ""
                  
        elseif string.sub(default_text,-4,-4) == "_" then
        default_text=default_text:sub(1,-5) .. ""
       end
            
    end
end






-- Script generated by Lokasenna's GUI Builder


local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()




GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Window.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end



GUI.name = "Name Empty Items"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 600, 92
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
    
    txt.caret = string.len(default_text)
    
          
  
  txt.sel_s, txt.sel_e = nil, nil

    txt.char_h, txt.wnd_h, txt.wnd_w, txt.char_w = nil, nil, nil, nil

  txt.focus = false

  txt.blink = 0
  GUI.redraw_z[txt.z] = true

  setmetatable(txt, self)
  self.__index = self
  return txt

end





GUI.Main = function ()
    xpcall( function ()

        if GUI.Main_Update_State() == 0 then return end

        GUI.Main_Update_Elms()

        -- If the user gave us a function to run, check to see if it needs to be
        -- run again, and do so.
        if GUI.func then

            local new_time = reaper.time_precise()
            if new_time - GUI.last_time >= (GUI.freq or 1) then
                GUI.func()
                GUI.last_time = new_time

            end
        end
        
        -- Maintain a list of elms and zs in case any have been moved or deleted
        GUI.update_elms_list()
        local val = gfx.getchar(65536)
        if val == 7 then
            scriptFocus = true
        else
            scriptFocus = false
        end
        

        GUI.Main_Draw()

    end, GUI.crash)
end




--  See if the any of the given element's methods need to be called
GUI.Update = function (elm)

    local x, y = GUI.mouse.x, GUI.mouse.y
    local x_delta, y_delta = x-GUI.mouse.lx, y-GUI.mouse.ly
    local wheel = GUI.mouse.wheel
    local inside = GUI.IsInside(elm, x, y)

    local skip = elm:onupdate() or false

    if GUI.resized then elm:onresize() end

    if GUI.elm_updated then
        if elm.focus then
            elm.focus = false
            elm:lostfocus()
        end
        skip = true
    end
    
    if scriptFocus == false then
        if elm.focus then
              elm.focus = false
              elm:lostfocus()
        end
    end

    if skip then return end

    -- Left button
    if GUI.mouse.cap&1==1 then
          
        -- If it wasn't down already...
        if not GUI.mouse.last_down then


            -- Was a different element clicked?
            if not inside then
      
                if GUI.mouse_down_elm == elm then
                    -- Should already have been reset by the mouse-up, but safeguard...
                    GUI.mouse_down_elm = nil
                end
                if elm.focus then
                    elm.focus = false
                    elm:lostfocus()
                end
                return 0
            else
                if GUI.mouse_down_elm == nil then -- Prevent click-through

                    GUI.mouse_down_elm = elm

                    -- Double clicked?
                    if GUI.mouse.downtime
                    and reaper.time_precise() - GUI.mouse.downtime < 0.10
                    then

                        GUI.mouse.downtime = nil
                        GUI.mouse.dbl_clicked = true
                        elm:ondoubleclick()

                    elseif not GUI.mouse.dbl_clicked then

                        elm.focus = true
                        elm:onmousedown()

                    end

                    GUI.elm_updated = true
                end

                GUI.mouse.down = true
                GUI.mouse.ox, GUI.mouse.oy = x, y

                -- Where in the elm the mouse was clicked. For dragging stuff
                -- and keeping it in the place relative to the cursor.
                GUI.mouse.off_x, GUI.mouse.off_y = x - elm.x, y - elm.y

            end

        --     Dragging? Did the mouse start out in this element?
        elseif (x_delta ~= 0 or y_delta ~= 0)
        and     GUI.mouse_down_elm == elm then

            if elm.focus ~= false then

                GUI.elm_updated = true
                elm:ondrag(x_delta, y_delta)

            end
        end

    -- If it was originally clicked in this element and has been released
    elseif GUI.mouse.down and GUI.mouse_down_elm.name == elm.name then

            GUI.mouse_down_elm = nil

            if not GUI.mouse.dbl_clicked then elm:onmouseup() end

            GUI.elm_updated = true
            GUI.mouse.down = false
            GUI.mouse.dbl_clicked = false
            GUI.mouse.ox, GUI.mouse.oy = -1, -1
            GUI.mouse.off_x, GUI.mouse.off_y = -1, -1
            GUI.mouse.lx, GUI.mouse.ly = -1, -1
            GUI.mouse.downtime = reaper.time_precise()


    end


    -- Right button
    if GUI.mouse.cap&2==2 then

        -- If it wasn't down already...
        if not GUI.mouse.last_r_down then

            -- Was a different element clicked?
            if not inside then
                if GUI.rmouse_down_elm == elm then
                    -- Should have been reset by the mouse-up, but in case...
                    GUI.rmouse_down_elm = nil
                end
                --elm.focus = false
            else

                -- Prevent click-through
                if GUI.rmouse_down_elm == nil then

                    GUI.rmouse_down_elm = elm

                        -- Double clicked?
                    if GUI.mouse.r_downtime
                    and reaper.time_precise() - GUI.mouse.r_downtime < 0.20
                    then

                        GUI.mouse.r_downtime = nil
                        GUI.mouse.r_dbl_clicked = true
                        elm:onr_doubleclick()

                    elseif not GUI.mouse.r_dbl_clicked then

                        elm:onmouser_down()

                    end

                    GUI.elm_updated = true

                end

                GUI.mouse.r_down = true
                GUI.mouse.r_ox, GUI.mouse.r_oy = x, y
                -- Where in the elm the mouse was clicked. For dragging stuff
                -- and keeping it in the place relative to the cursor.
                GUI.mouse.r_off_x, GUI.mouse.r_off_y = x - elm.x, y - elm.y

            end


        --     Dragging? Did the mouse start out in this element?
        elseif (x_delta ~= 0 or y_delta ~= 0)
        and     GUI.rmouse_down_elm == elm then

            if elm.focus ~= false then

                elm:onr_drag(x_delta, y_delta)
                GUI.elm_updated = true

            end

        end

    -- If it was originally clicked in this element and has been released
    elseif GUI.mouse.r_down and GUI.rmouse_down_elm.name == elm.name then

        GUI.rmouse_down_elm = nil

        if not GUI.mouse.r_dbl_clicked then elm:onmouser_up() end

        GUI.elm_updated = true
        GUI.mouse.r_down = false
        GUI.mouse.r_dbl_clicked = false
        GUI.mouse.r_ox, GUI.mouse.r_oy = -1, -1
        GUI.mouse.r_off_x, GUI.mouse.r_off_y = -1, -1
        GUI.mouse.r_lx, GUI.mouse.r_ly = -1, -1
        GUI.mouse.r_downtime = reaper.time_precise()

    end



    -- Middle button
    if GUI.mouse.cap&64==64 then


        -- If it wasn't down already...
        if not GUI.mouse.last_m_down then


            -- Was a different element clicked?
            if not inside then
                if GUI.mmouse_down_elm == elm then
                    -- Should have been reset by the mouse-up, but in case...
                    GUI.mmouse_down_elm = nil
                end
            else
                -- Prevent click-through
                if GUI.mmouse_down_elm == nil then

                    GUI.mmouse_down_elm = elm

                    -- Double clicked?
                    if GUI.mouse.m_downtime
                    and reaper.time_precise() - GUI.mouse.m_downtime < 0.20
                    then

                        GUI.mouse.m_downtime = nil
                        GUI.mouse.m_dbl_clicked = true
                        elm:onm_doubleclick()

                    else

                        elm:onmousem_down()

                    end

                    GUI.elm_updated = true

              end

                GUI.mouse.m_down = true
                GUI.mouse.m_ox, GUI.mouse.m_oy = x, y
                GUI.mouse.m_off_x, GUI.mouse.m_off_y = x - elm.x, y - elm.y

            end



        --     Dragging? Did the mouse start out in this element?
        elseif (x_delta ~= 0 or y_delta ~= 0)
        and     GUI.mmouse_down_elm == elm then

            if elm.focus ~= false then

                elm:onm_drag(x_delta, y_delta)
                GUI.elm_updated = true

            end

        end

    -- If it was originally clicked in this element and has been released
    elseif GUI.mouse.m_down and GUI.mmouse_down_elm.name == elm.name then

        GUI.mmouse_down_elm = nil

        if not GUI.mouse.m_dbl_clicked then elm:onmousem_up() end

        GUI.elm_updated = true
        GUI.mouse.m_down = false
        GUI.mouse.m_dbl_clicked = false
        GUI.mouse.m_ox, GUI.mouse.m_oy = -1, -1
        GUI.mouse.m_off_x, GUI.mouse.m_off_y = -1, -1
        GUI.mouse.m_lx, GUI.mouse.m_ly = -1, -1
        GUI.mouse.m_downtime = reaper.time_precise()

    end



    -- If the mouse is hovering over the element
    if inside and not GUI.mouse.down and not GUI.mouse.r_down then
        elm:onmouseover()

        -- Initial mouseover an element
        if GUI.mouseover_elm ~= elm then
            GUI.mouseover_elm = elm
            GUI.mouseover_time = reaper.time_precise()

        -- Mouse was moved; reset the timer
        elseif x_delta > 0 or y_delta > 0 then

            GUI.mouseover_time = reaper.time_precise()

        -- Display a tooltip
        elseif (reaper.time_precise() - GUI.mouseover_time) >= GUI.tooltip_time then

            GUI.settooltip(elm.tooltip)

        end
        --elm.mouseover = true
    else
        --elm.mouseover = false

    end


    -- If the mousewheel's state has changed
    if inside and GUI.mouse.wheel ~= GUI.mouse.lwheel then

        GUI.mouse.inc = (GUI.mouse.wheel - GUI.mouse.lwheel) / 120

        elm:onwheel(GUI.mouse.inc)
        GUI.elm_updated = true
        GUI.mouse.lwheel = GUI.mouse.wheel

    end

    -- If the element is in focus and the user typed something
    if elm.focus and GUI.char ~= 0 then
        elm:ontype()
        GUI.elm_updated = true
    end

end


GUI.New("Name", "Textbox", {
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
    focus = true,
    pad = 4,
    undo_limit = 20,
    
    
})




GUI.New("Ok", "Button", {
    z = 11,
    x = 270,
    y = 48,
    w = 60,
    h = 30,
    caption = "Ok",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = rename,
   
})


GUI.Init()
GUI.Main()
GUI.elms.Name.focus = true
GUI.ReturnSubmit = rename 
-- pressing enter on the keyboard is the same as pressing ok on the GUI
-- to do so you need to add in the Lokasenna_GUI v2  Core.lua script the following code
-- in the function GUI.Main_Update_Sate under GUI.char = gfx.getchar() add
-- if GUI.char == 13 and GUI.ReturnSubmit then GUI.ReturnSubmit() end   ---ADDED
GUI.Val("Name", default_text)




