-- @description group clusters of items and add empty item 
-- @author Giacomo Maraboli
-- @version 1.1.2
-- @about
--   group clusters of items and add empty item 

reaper.ClearConsole()
--USER SETTINGS--
color = true   --set to false to have all the cluster with the same random color


-----



function isTrackAvailable(trackIndex, emptyItemStart, emptyItemEnd)
  
    if trackIndex < 2 then return false      --if first track has an index below 2 it's impossible to have another track above
    else
        
        local tr = reaper.GetTrack(0, trackIndex-2)     --get track above first track
        local itemNum= reaper.CountTrackMediaItems(tr)    --get number of items in that track

        for i=0, itemNum-1 do                  --check if one of the items overlaps the empty item that we have to create 
    
      local it=reaper.GetTrackMediaItem( tr,i  )
            local itemStart =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
            local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")

            if (itemStart >= emptyItemStart and itemStart <= emptyItemEnd) or (itemEnd <= emptyItemEnd and itemEnd >= emptyItemStart)or (itemStart < emptyItemStart and itemEnd > emptyItemEnd) then

                local tk=reaper.GetActiveTake(it)      --if there is an item overlapping check if is an empty item - if so then we can use the track, otherwise we can't
        
                if not tk then return true
                else return false
                end
            end
        end
   
    return true
    end
end

function createTrack(trackIndex)

    reaper.InsertTrackAtIndex(trackIndex-1, true)
    folderTrack = reaper.GetTrack(0, trackIndex-1)
    return folderTrack
  
end


function createEmptyItem(folderTrack, emptyItemStart, emptyItemEnd)
    
    itemNum= reaper.CountTrackMediaItems(folderTrack)
    
    for  i=0,itemNum-1 do
        local it=reaper.GetTrackMediaItem( folderTrack,i  )
        if not it then break end
        local itemStart =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
        local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
        
        if (itemStart >= emptyItemStart and itemStart <= emptyItemEnd) or (itemEnd <= emptyItemEnd and itemEnd >= emptyItemStart)or (itemStart < emptyItemStart and itemEnd > emptyItemEnd) then
            local tk=reaper.GetActiveTake(it)
            if not tk then
               retvalue, textNotes = reaper.GetSetMediaItemInfo_String( it, "P_NOTES","",false )      --if there is an empty item with text saves the text and delete the item
               
                reaper.DeleteTrackMediaItem(folderTrack, it)
            end
        end
    end
        
    emptyItem = reaper.AddMediaItemToTrack(folderTrack)          --create empty item and set start and stop position
    reaper.SetMediaItemInfo_Value(emptyItem, "D_POSITION", emptyItemStart)
    reaper.SetMediaItemInfo_Value(emptyItem, "D_LENGTH", emptyItemEnd - emptyItemStart)
  
    if retvalue then
        retvalue, textNotes = reaper.GetSetMediaItemInfo_String( emptyItem, "P_NOTES",textNotes,true )    --if text was saved before, adds it to the new item
    end
  
    return emptyItem
end



--MAIN STARTS HERE

k=1
cluster = {}    --table to save clusters
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

item = reaper.GetSelectedMediaItem(0,0)

if item == nil then return end
tk = reaper.GetActiveTake(item) 
id=reaper.GetMediaItemInfo_Value( item, "I_GROUPID" )


if id > 0 and tk == nil then --check if item is in group
    reaper.Main_OnCommand( 40033, 0 )  
    reaper.Main_OnCommand( 40707,0)
else

    emptyItems = {}
    j=1
    selItemNum = reaper.CountSelectedMediaItems()      
    for i=0, selItemNum-1 do              --look for empty item in the selection and saves them into an array
  
        item = reaper.GetSelectedMediaItem(0, i)
    
        if item == nil then break end 
            take=reaper.GetActiveTake(item)
        if not take then  
            emptyItems[j] = item
            j= j+1
            --selItemNum = selItemNum -1                 
        end
    end
  
    j=1
    while emptyItems[j] ~= nil do      --deselect all the items in the array
        item = emptyItems[j]
        reaper.SetMediaItemSelected(item, false)
        j= j+1
    end
  
while true do
      
  selItemNum = reaper.CountSelectedMediaItems()    --count number of item selected
  
      
    item = reaper.GetSelectedMediaItem(0, 0)
    if item == nil then break end
      
    regStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    regEnd = regStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      
    track = reaper.GetMediaItemTrack(item)      --get first track and index
    trackIndex = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    checkId = trackIndex
     
    x=1
    cluster[k]={}
  found = true
  
    while found == true do
        found = false
         
        for i=0, selItemNum-1 do --loop to check if an item is overlapping current start and stop poin, if so adds it to the array and deselects it
               
            nextItem = reaper.GetSelectedMediaItem(0, i)
            if nextItem == nil then break end
            
            nextTrack = reaper.GetMediaItemTrack(nextItem)
            nextTrackId=  reaper.GetMediaTrackInfo_Value(nextTrack, "IP_TRACKNUMBER")
            
           
            
           
         
            nextItemStart =  reaper.GetMediaItemInfo_Value(nextItem, "D_POSITION")
            nextItemEnd = nextItemStart + reaper.GetMediaItemInfo_Value(nextItem, "D_LENGTH")
           
            if nextTrackId > checkId+1 then
                break
                
            end
                
            if (nextItemStart >= regStart and nextItemStart <= regEnd) or (nextItemEnd >= regStart and nextItemEnd <= regEnd) or (nextItemStart < regStart and nextItemEnd > regEnd) then
            
                if nextItemStart < regStart and nextItemEnd > regEnd then
                      
                      regStart = nextItemStart
                      regEnd = nextItemEnd
                      found = true
                      cluster[k][x] = nextItem
                      x=x+1
                      reaper.SetMediaItemSelected( nextItem, 0 )
                      if checkId < nextTrackId then
                                      checkId = nextTrackId
                      end
                                               
                elseif nextItemStart < regStart and nextItemEnd <= regEnd then
        
                    regStart = nextItemStart
                    found = true
                    cluster[k][x] = nextItem
                    x=x+1
                    reaper.SetMediaItemSelected( nextItem, 0 )
                    if checkId < nextTrackId then
                        checkId = nextTrackId
                    end
                                                       
                elseif nextItemEnd > regEnd and nextItemStart >= regStart then
        
                    regEnd = nextItemEnd
                    found = true  
                    cluster[k][x] = nextItem
                    x=x+1                 
                    reaper.SetMediaItemSelected( nextItem, 0 )
                    if checkId < nextTrackId then
                        checkId = nextTrackId
                    end
                                                  
          
                else  
        
                    found = true  
                    cluster[k][x] = nextItem
                    x=x+1
                    reaper.SetMediaItemSelected( nextItem, 0 )
                    if checkId < nextTrackId then
                        checkId = nextTrackId
                    end
                                                  
          
                end
            end  
        end         
    end
           
    if isTrackAvailable(trackIndex, regStart, regEnd)  then  --call function to check if we have a trac available for empty item, if not creates one 
             
    folderTrack = reaper.GetTrack(0, trackIndex-2)
    
    else
        
    folderTrack = createTrack(trackIndex)
        
  end
        
    emptyItem = createEmptyItem(folderTrack, regStart, regEnd)
    cluster[k][x] = emptyItem
  k=k+1 
  
end  


k=1
x=1
while cluster[k] ~= nil do

    while cluster[k][x]  ~= nil do
        item =cluster[k][x]
        reaper.SetMediaItemSelected(item, true)
        x= x+1
    end
  
    reaper.Main_OnCommand( 40032, 0 )   --group items    
    if color then reaper.Main_OnCommand( 40706, 0 ) end --assign random color 
    reaper.SelectAllMediaItems( 0, false )
    k=k+1
    x=1
end
k=1
x=1
while cluster[k] ~= nil do
    while cluster[k][x]  ~= nil do
        item =cluster[k][x]
        reaper.SetMediaItemSelected(item, true)
        x= x+1
    end
      
    if not color then reaper.Main_OnCommand( 40706, 0 ) end --assign random color    
    k=k+1
    x=1
end

reaper.Undo_EndBlock("Undo group items", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
    
end  
    
