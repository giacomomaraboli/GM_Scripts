-- @description NextVariation
-- @author Giacomo Maraboli
-- @version 1.1.2
-- @about
--   move to next variation in item (needs other takemarker script)
reaper.ClearConsole()
takeMarkers = reaper.NamedCommandLookup("_RS73a0953fcac24d2edc635eb77323d25ab259ea5e") --nvk take markers in GM folder --TakeMarkers.lua -- change ID if necessary

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
command = reaper.NamedCommandLookup("_SWS_SAVEVIEW")
reaper.Main_OnCommand(command,0)

reaper.Main_OnCommand(takeMarkers,0)
--start_time, end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0 )

cursorPos = reaper.GetCursorPosition()
num = reaper.CountSelectedMediaItems()
if num == 0 then return end

items ={}
for i=0, num-1 do
  item = reaper.GetSelectedMediaItem(0,i)
  items[i+1] = item
end

for i=1, #items do
reaper.SelectAllMediaItems( 0, false )
item = items[i]

reaper.SetMediaItemSelected( item, true )
--move cursor at start of item and store position
reaper.Main_OnCommand(41173,0)
startPos = reaper.GetCursorPosition()

--move cursor at take marker position and store
reaper.Main_OnCommand(42394,0)
markerPos = reaper.GetCursorPosition()

--move cursor at end of item and store position

reaper.Main_OnCommand(41174,0)
endPos = reaper.GetCursorPosition()
--calculate offset from start position to marker and marker to end

startOffset = markerPos - startPos
endOffset = endPos - markerPos

--go to next marker + end offest and untrim item
reaper.SetEditCurPos( markerPos, false, false )
reaper.Main_OnCommand(42394,0)
nextMarkerPos = reaper.GetCursorPosition()
--reaper.ShowConsoleMsg(markerPos.."  "..nextMarkerPos)


if nextMarkerPos == markerPos then  --if there are no more markers return
    
    
    take = reaper.GetActiveTake(item)
    take_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
    take_rate = reaper.GetMediaItemTakeInfo_Value(take,"D_PLAYRATE")
    
    take_off_comp = take_offset * (1/take_rate)
    reaper.SetMediaItemInfo_Value( item, "D_POSITION", startPos + take_off_comp)
    
    reaper.Main_OnCommand(42229,0)--set item start to sourc start
    
    reaper.Main_OnCommand(41173,0)--set edit cursor to start of item
    reaper.Main_OnCommand(42394,0) --set cursor to next marker
    nextMarkerPos = reaper.GetCursorPosition()
    
    reaper.SetEditCurPos( nextMarkerPos - markerPos + startPos, false, false )
    reaper.Main_OnCommand(41305,0) --trim item left
    reaper.SetMediaItemInfo_Value( item, "D_POSITION", startPos)
    reaper.SetEditCurPos( endPos, false, false )
    reaper.Main_OnCommand(41311,0) -- trim item righ
   
    
else


reaper.SetEditCurPos( nextMarkerPos+endOffset, false, false )
reaper.Main_OnCommand(41311,0)
--go to next marker - start offste and trim left item
reaper.SetEditCurPos( nextMarkerPos-startOffset, false, false )
reaper.Main_OnCommand(41305,0)
--move new item to previous position

 reaper.SetMediaItemInfo_Value( item, "D_POSITION", startPos )
 
end 
end

for i = 1, #items do
    item = items[i]
    
    reaper.SetMediaItemSelected( item, true )
end
 reaper.SetEditCurPos( cursorPos, false, false )
 command = reaper.NamedCommandLookup("_SWS_RESTOREVIEW")
 reaper.Main_OnCommand(command,0) 
 reaper.Main_OnCommand(42387,0) --delete take markers
  
 reaper.PreventUIRefresh(-1)
 reaper.Undo_EndBlock("Undo next variation", -1)

 reaper.UpdateTimeline()
 
