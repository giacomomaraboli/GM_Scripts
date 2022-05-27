-- @description Sub project create
-- @author Giacomo Maraboli
-- @version 1.1
-- @about
--   create a sub project at the position of the cursor and add marker
reaper.ClearConsole()

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

cursor = reaper.GetCursorPosition()
endPoint = cursor + 5

--create time selection
reaper.GetSet_LoopTimeRange( true, false, cursor, endPoint, false )
--create subrpoject
reaper.Main_OnCommand(41049,0)

item = reaper.GetSelectedMediaItem(0,0)
if not item then return end
take = reaper.GetActiveTake(item)
_, name = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", "", false )

track =  reaper.GetMediaItem_Track( item )
color = reaper.GetMediaTrackInfo_Value( track, "I_CUSTOMCOLOR" )

reaper.SetMediaItemInfo_Value( item, "I_CUSTOMCOLOR", color )

reaper.AddProjectMarker2(0, false, cursor, endPoint, name, -1, color)

--clear time selection
reaper.Main_OnCommand(40020,0)

reaper.Main_OnCommand(40898,0) -- renumber markers


reaper.Undo_EndBlock("Unndo subproject", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
