-- @description OpenClose folder
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   open and close a folder - makes sense to use with double click or other mouse mothifiers

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

trackNum = reaper.CountSelectedTracks( 0 )
firstTrack = reaper.GetSelectedTrack(0,0)
folderDepth = reaper.GetMediaTrackInfo_Value( firstTrack, "I_FOLDERDEPTH"  )

  
if folderDepth ~= 1 then
      
    parent = reaper.GetParentTrack( firstTrack )
    if parent ~= null then
          command = reaper.NamedCommandLookup("_SWS_SELPARENTS")
          reaper.Main_OnCommand(command,0)
          firstTrack = parent
                
    end
end


status=  reaper.GetMediaTrackInfo_Value( firstTrack, "I_FOLDERCOMPACT"  )

if status == 2 then
    command = reaper.NamedCommandLookup("_SWS_UNCOLLAPSE")
    reaper.Main_OnCommand(command,0)
else
  -- command = reaper.NamedCommandLookup("_RSf76c9ab78c847260446342b097c13a0f3e18261d")
  -- reaper.Main_OnCommand(command,0)

    command = reaper.NamedCommandLookup("_SWS_COLLAPSE")
    reaper.Main_OnCommand(command,0)
end

reaper.Undo_EndBlock("", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

