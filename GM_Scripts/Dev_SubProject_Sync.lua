-- @description Sub project sync
-- @author Giacomo Maraboli
-- @version 1.1
-- @about
--   render the selected sub porjects from the master project

function getProjectTabIndex()
  local i, project = 0, reaper.EnumProjects(-1, '')
  
  while true do
    if reaper.EnumProjects(i, '') == project then
      return i
    else
     i = i + 1
    end
  end
end


reaper.ClearConsole()
reaper.PreventUIRefresh(1)
--reaper.Undo_BeginBlock()


tab = getProjectTabIndex() + 1
if tab == 1 then
    command = reaper.NamedCommandLookup("_SWS_FIRSTPROJTAB")
    --reaper.Main_OnCommand(command,0)
elseif tab > 1 then
    add = tostring(tab)
    command = reaper.NamedCommandLookup("_SWS_PROJTAB"..tab)
end


num= reaper.CountSelectedMediaItems()
masterProject = reaper.EnumProjects(-1, '') 
_, masterName = reaper.GetSetProjectInfo_String( masterProject, "PROJECT_NAME", "", false )
items = {}
open = {}
k=1
for i=0, num-1 do
   items[i+1]= reaper.GetSelectedMediaItem(0,i)
end

for i=1, #items do


--clear selection of items

    reaper.Main_OnCommand(40289,0)

    item = items[i]
    reaper.SetMediaItemSelected( item, true )
    
    take = reaper.GetActiveTake(item)
     _, name = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME" , "", false )
    
    
 
    open = false
    
    for j = 0, 128 do
    
         project = reaper.EnumProjects(j, '') 
         _, prjName = reaper.GetSetProjectInfo_String( project, "PROJECT_NAME", "", false )
         if prjName == name then
       
             --open[k] = item
            -- k=k+1
            open = true
             
             break
         end
    end
    
--open subproject
    reaper.Main_OnCommand(41816,0)

--render subproject
    reaper.Main_OnCommand(42332,0)

 
--close subproject
    if not open then
    
        reaper.Main_OnCommand(40860,0)
    else
        reaper.Main_OnCommand(command,0)
    end
    

end

reaper.Main_OnCommand(command,0)

reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
