-- @description Folder track list
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   open a list with all the folder track and then does something with the arrange window - I don't remember the idea behind this

reaper.ClearConsole()


local names = {}
local tracks = {}
local allTracks={}
local cur_pos = reaper.GetCursorPosition()
local idx = -1

------------------------------------fill the array with tracks that I want-----------
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()
 command = reaper.NamedCommandLookup("_SWSTL_SHOWALL") --show all tracks
   reaper.Main_OnCommand(command,0)

  reaper.Main_OnCommand(40297,0) -- clear track selection
  num =  reaper.GetNumTracks()
  for i=0, num-1 do
      x=0
      tr = reaper.GetTrack( 0, i )
      
     
      ----------------------------------experiment with spacing in the name for children-----
      parent = reaper.GetParentTrack( tr )
      folderDepth =  reaper.GetMediaTrackInfo_Value( tr, "I_FOLDERDEPTH" )
      if folderDepth == 1 or parent == null then
      --insert in array
          _, name = reaper.GetSetMediaTrackInfo_String( tr, "P_NAME" , "", false )
          
          while parent ~= null do
              x=x+1
              parent = reaper.GetParentTrack( parent )
          end
          for j=0, x-1 do
              name = "---"..name
          end
              
          if name == "" then 
              name = string.format("%d", tostring(reaper.GetMediaTrackInfo_Value( tr, "IP_TRACKNUMBER"  )))
              --name = tostring(#names+1) 
          end
          tracks[#tracks +1] = tr
          names[#names+1] =  name
          --reaper.ShowConsoleMsg("OK")
      end
   end   
   

---------------------------------------------------------------------------------------
local menu = "#FOLDER TRACKS|"
for m = 1, #names do
  local space = "                "
  space = space:sub( tostring(names[m].idx):len()*2 )
  menu = menu .. names[m] .."|"
end

local title = "hidden " .. reaper.genGuid()
gfx.init( title, 0, 0, 0, 0, 0 )
local hwnd = reaper.JS_Window_Find( title, true )
if hwnd then
  reaper.JS_Window_Show( hwnd, "HIDE" )
end
gfx.x, gfx.y = gfx.mouse_x-52, gfx.mouse_y-70
local selection = gfx.showmenu(menu)
gfx.quit()


if selection > 0 then
 
   tr = tracks[selection-1]
   reaper.SetOnlyTrackSelected( tr )
   command = reaper.NamedCommandLookup("_SWS_SELCHILDREN2") --select children
   reaper.Main_OnCommand(command,0)
   reaper.Main_OnCommand(40421,0) --select item in track
   it = reaper.GetSelectedMediaItem(0,0)
   itStart = reaper.GetMediaItemInfo_Value( it, "D_POSITION"  )
   parent = reaper.GetParentTrack( tr )
   while parent ~= null do
      reaper.SetTrackSelected( parent, true )      
      parent = reaper.GetParentTrack( parent )
    end
   
   --command = reaper.NamedCommandLookup("_SWS_SELPARENTS2") --select parent
   --reaper.Main_OnCommand(command,0)
   command = reaper.NamedCommandLookup("_SWSTL_HIDEUNSEL") --hide unselected
   reaper.Main_OnCommand(command,0)
   
   reaper.Main_OnCommand(40297,0) -- clear track selection 
   reaper.SetEditCurPos( itStart, true, false )
  reaper.Undo_EndBlock("Unndo", -1)
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
 
end


