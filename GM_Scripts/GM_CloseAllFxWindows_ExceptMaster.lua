-- @description Close all fx windows except Master
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   Close all fx windows except Master

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
num=reaper.CountSelectedTracks( 0 )
if num > 0 then
    selTrack={}
    for i=0, num-1 do
        selTrack[i+1] = reaper.GetSelectedTrack( 0, i )
    end
end
    
reaper.Main_OnCommand(40296,0)
command = reaper.NamedCommandLookup("_S&M_WNCLS5")
reaper.Main_OnCommand(command,0)
reaper.Main_OnCommand(40297,0)
j=1
if num>0 then
    while selTrack[j] ~= nil do
        reaper.SetTrackSelected( selTrack[j], true )
        j=j+1
    end
end

reaper.Undo_EndBlock("Unndo close FX Windows", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
