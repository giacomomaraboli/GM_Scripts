-- @description Duplicate everything in the time selection
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   duplicate (almost) everything in the time selection

reaper.ClearConsole()
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
item = reaper.GetSelectedMediaItem(0,0)

--set time selection to items
reaper.Main_OnCommand(40290,0)

--select all items in time selection
reaper.Main_OnCommand(40717,0)

timeStart, timeEnd = reaper.GetSet_LoopTimeRange( false, 0, 0, 0, false )


--select all automation item in time selection
trackNum = reaper.CountTracks(0)
for i=0,trackNum-1 do
    
    track = reaper.GetTrack( 0, i)
    envNum =  reaper.CountTrackEnvelopes( track )
    if envNum > 0 then
        for j=0, envNum-1 do
        
            env =  reaper.GetTrackEnvelope( track, j )
            
            autoNum =  reaper.CountAutomationItems( env )
            --try with setcursorcontext to see if it's possible to select all envelope tracks
            --reaper.SetCursorContext( 2, env )
            --reaper.Main_OnCommand(40330,0)
            --after copiing all item need to go bakc and copy all envelopes
            
            for w=0, autoNum-1 do
                autoStart =  reaper.GetSetAutomationItemInfo( env, w, "D_POSITION" , 0, false )
                if autoStart>= timeStart and autoStart<=timeEnd then
                    reaper.GetSetAutomationItemInfo( env, w, "D_UISEL", 1, true )
                end
            end--for
        end--for
    end--if
end--for

--select all tracks
--reaper.Main_OnCommand(40296,0)


--copy everything in time selection
reaper.Main_OnCommand(40057,0)
reaper.SetEditCurPos( timeEnd, false, false )

--move edit cursor the next measure
reaper.Main_OnCommand(40837,0)
reaper.Main_OnCommand(40837,0)
reaper.Main_OnCommand(40837,0)
--paste 
reaper.Main_OnCommand(42398,0)

--clear time selection
reaper.Main_OnCommand(40020,00)
--clear items selection
--reaper.Main_OnCommand(40289,00)

reaper.Undo_EndBlock("Undo duplicate", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()


