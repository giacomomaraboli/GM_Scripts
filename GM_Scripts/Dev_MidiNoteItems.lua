-- @description Create midi notes from selected items
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   create midi notes in new track from selected items


--settings---------------
defaultName = "Midi Track"


--------------------------
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()

num = reaper.CountSelectedMediaItems()
if num == 0 then return end

firstItem = reaper.GetSelectedMediaItem(0,0)
lastItem = reaper.GetSelectedMediaItem(0,num-1)

track =  reaper.GetMediaItem_Track( lastItem )
idx = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )

reaper.InsertTrackAtIndex( idx, true ) --insert new track
track = reaper.GetTrack( 0, idx )
_, _ = reaper.GetSetMediaTrackInfo_String( track, "P_NAME", defaultName, true )

--start and end of midi item
itStart =  reaper.GetMediaItemInfo_Value( firstItem, "D_POSITION" )
itEnd =  reaper.GetMediaItemInfo_Value( lastItem, "D_POSITION" ) +  reaper.GetMediaItemInfo_Value( lastItem, "D_LENGTH" )
miditem = reaper.CreateNewMIDIItemInProj( track, itStart, itEnd )
take = reaper.GetActiveTake( miditem )



for i=0, num-1 do
    

    item = reaper.GetSelectedMediaItem(0,i)



    noteStart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
    noteEnd =  noteStart +  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )




    local ppqSt = reaper.MIDI_GetPPQPosFromProjTime( take, noteStart )
    local ppqEn = reaper.MIDI_GetPPQPosFromProjTime( take, noteEnd )
    reaper.MIDI_InsertNote( take, false, false, ppqSt, ppqEn, 1, 48, 100)
end

  reaper.Undo_EndBlock("Unndo midi track", -1)
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
