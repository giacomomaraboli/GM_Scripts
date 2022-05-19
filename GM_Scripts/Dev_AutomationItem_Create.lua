-- @description Create automation item
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   create automation item under item (work best with mouse modifier double click)
reaper.ClearConsole()
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
--reaper.Main_OnCommand(41866,0)--select volume envelope
pos =  reaper.GetCursorPositionEx(0)

env =  reaper.GetSelectedEnvelope(0)
if not env then return end
numAut=  reaper.CountAutomationItems( env )
found = false

for i=0, numAut-1 do

    autStart = reaper.GetSetAutomationItemInfo( env, i, "D_POSITION" , 0, false )
    autEnd = autStart + reaper.GetSetAutomationItemInfo( env, i, "D_LENGTH" ,0 , false )
    
    if pos >= autStart and pos <= autEnd then
        found = true
        tr = reaper.GetSelectedTrack(0,0)
        reaper.Main_OnCommand(40421,0)--select all item in track
        num = reaper.CountSelectedMediaItems()
        
        for j=0, num -1 do
            it = reaper.GetSelectedMediaItem(0,j)
            itStart = reaper.GetMediaItemInfo_Value( it, "D_POSITION"  )
            itLenght = reaper.GetMediaItemInfo_Value( it, "D_LENGTH"  )
            itEnd = itStart + itLenght
            
            if pos >= itStart and pos <= itEnd then
                reaper.GetSetAutomationItemInfo( env, i, "D_LOOPSRC" ,0 , true )
            
                reaper.GetSetAutomationItemInfo( env, i, "D_POSITION" , itStart, true )
                reaper.GetSetAutomationItemInfo( env, i, "D_LENGTH" ,itLenght , true )
                
                reaper.GetSetAutomationItemInfo( env, i, "D_STARTOFFS" ,-(autStart-itStart) , true )
                reaper.GetSetAutomationItemInfo( env, i, "D_UISEL" ,1 , true )
                reaper.Main_OnCommand(42089,0)--glue automation item
                --reaper.GetSetAutomationItemInfo( env, i, "D_LOOPSRC" ,1 , true )
                
            end
        end
      
    end
end

if not found then

tr = reaper.GetSelectedTrack(0,0)
reaper.Main_OnCommand(40421,0)--select all item in track
num = reaper.CountSelectedMediaItems()

for i=0, num -1 do
    it = reaper.GetSelectedMediaItem(0,i)
    itStart = reaper.GetMediaItemInfo_Value( it, "D_POSITION"  )
    itEnd = itStart + reaper.GetMediaItemInfo_Value( it, "D_LENGTH"  )
    
    
    if pos >= itStart and pos <= itEnd then
        
        reaper.Main_OnCommand(40289,0)--clear selection of item
        reaper.SetMediaItemSelected( it, true )
        reaper.Main_OnCommand(40290,0)--set time selection to first selected item
        reaper.Main_OnCommand(42082,0)--insert automation item
        reaper.Main_OnCommand(40020,0)--clear time selection
        
        
        break
    end
end
end
reaper.Main_OnCommand(40289,0)--clear selection of item

reaper.Undo_EndBlock("Unndo create automation item", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
reaper.UpdateArrange()

