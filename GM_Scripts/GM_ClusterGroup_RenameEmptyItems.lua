-- @description rename empty items
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   rename empty items

reaper.ClearConsole()

--is there a way to have the textbox selected when script opens?

 

function rename()
   
   reaper.PreventUIRefresh(1)
   reaper.Undo_BeginBlock()
    text = GUI.Val("Name")
    if number > 1 then
      
        for i=0,number -1 do
            if text == "" then
                reaper.ULT_SetMediaItemNote(emptyItems[i+1],text)    
            else
              add = "_" .. string.format("%02d", tostring(i+1))    --add index
                reaper.ULT_SetMediaItemNote(emptyItems[i+1], text..add)
            end
        end
    else
    
        reaper.ULT_SetMediaItemNote(emptyItems[1], text)
    end
  GUI.quit = true  
  reaper.Undo_EndBlock("Undo rename items", -1) 
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
 
end



--MAIN

item = reaper.GetSelectedMediaItem(0, 0)
if not item then return end
tk = reaper.GetActiveTake(item)
if tk then return end


selItemNum =  reaper.CountSelectedMediaItems()  --count number of items
diff = false
emptyItems = {}
j=1

for i=0, selItemNum -1 do
    item = reaper.GetSelectedMediaItem(0, i)    --get item
    tk = reaper.GetActiveTake(item)             --check if item is empty
    if not tk then
        emptyItems[j]= item
   
        j=j+1
    end
end
number=#emptyItems

_, default_text = reaper.GetSetMediaItemInfo_String(emptyItems[1], "P_NOTES","",false )

if number > 1  and default_text ~= "" then 
    if string.sub(default_text,-3,-3) == "_" then      --check if there is an index, if so remove it
        default_text=default_text:sub(1,-4) .. ""
                  
    elseif string.sub(default_text,-4,-4) == "_" then
        default_text=default_text:sub(1,-5) .. ""
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
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 384, 92
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


GUI.New("Name", "Textbox", {
    z = 11,
    x = 64,
    y = 16,
    w = 257,
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
    x = 160,
    y = 48,
    w = 48,
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







