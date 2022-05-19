-- @description Sub project sync
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   render the selected sub porjects from the master project

reaper.ClearConsole()
reaper.PreventUIRefresh(1)
--reaper.Undo_BeginBlock()

num= reaper.CountSelectedMediaItems()

items = {}

for i=0, num-1 do
   items[i+1]= reaper.GetSelectedMediaItem(0,i)
end

for i=1, #items do


--clear selection of items

    reaper.Main_OnCommand(40289,0)

    item = items[i]
    reaper.SetMediaItemSelected( item, true )
    
--open subproject
    reaper.Main_OnCommand(41816,0)

--render subproject
    reaper.Main_OnCommand(42332,0)

--close subproject
    reaper.Main_OnCommand(40860,0)
    
    
end

--reaper.Undo_EndBlock("Undo duplicate", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
