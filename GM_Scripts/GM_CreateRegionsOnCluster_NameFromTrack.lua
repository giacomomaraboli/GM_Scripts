-- @description Create regions on clusters of items and name it after the first track
-- @author Giacomo Maraboli
-- @version 1.2
-- @about
--   create regions on clusters of items and name it after the first track

reaper.ClearConsole()
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

i=0
offset = 0.5

lastItem = false

function checkItems (itemNumber, regStart, regEnd) do
      for i=0, itemNumber-1 do
          found = false
          nextItem = reaper.GetSelectedMediaItem(0, i)
          if nextItem == nil then break end
          
          nextItemStart =  reaper.GetMediaItemInfo_Value(nextItem, "D_POSITION")
          nextItemEnd = nextItemStart + reaper.GetMediaItemInfo_Value(nextItem, "D_LENGTH")
          if (nextItemStart >= regStart - offset and nextItemStart <= regEnd + offset) or (nextItemEnd >= regStart - offset and nextItemEnd <= regEnd + offset)then
                                     
              if nextItemStart < regStart then
                 regStart = nextItemStart
                 found = true
                 reaper.SetMediaItemSelected( nextItem, 0 )
             
                 return regStart, regEnd, found
            
                        
              elseif nextItemEnd > regEnd then
                 regEnd = nextItemEnd
                 found = true  
                 reaper.SetMediaItemSelected( nextItem, 0 )
              
                 return regStart, regEnd, found
              
              else  
                  found = true  
                  reaper.SetMediaItemSelected( nextItem, 0 )
               
                  return regStart, regEnd, found
              end
              
          end
         
      end    
      
      return regStart, regEnd, found
end
end

j = 0  
k=1
 
while true do

      
      selItemNum = reaper.CountSelectedMediaItems()
      
      found = true
      item = reaper.GetSelectedMediaItem(0, 0)
      
      if item == nil and k == 2 then 

          reaper.DeleteProjectMarker( 0, regionindex, true )
          regionindex=reaper.AddProjectMarker2(0, true, oldStart, oldEnd, refName, -1, 1)
      
      end
      
      if item == nil then return end
      
      track =  reaper.GetMediaItemTrack( item )  
      retval, name = reaper.GetSetMediaTrackInfo_String( track, "P_NAME", "", false )
      
     
      
      regionStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      regionEnd = regionStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
     
      
      
      while found == true do
          
          regionStart, regionEnd, found = checkItems(selItemNum, regionStart, regionEnd)
         
      end
       
      if j == 0 then
          refName = name
          j=1
          oldStart = regionStart
          oldEnd = regionEnd
      end   
      if name ~= refName and k == 2 then
          reaper.DeleteProjectMarkerByIndex( 0, regionindex -1 )
          regionindex=reaper.AddProjectMarker2(0, true, oldStart, oldEnd, refName, -1, 1)
          
      end
      
      
      if name ~= refName then
          k = 1
          refName = name
          oldStart = regionStart
          oldEnd = regionEnd
      end
      
      
      add = "_" .. string.format("%02d", tostring(k))
      k=k+1
      regionindex=reaper.AddProjectMarker2(0, true, regionStart, regionEnd, name..add, -1, 1)
     
      
      reaper.SetMediaItemSelected( item, 0 )
     
  
end  
reaper.Undo_EndBlock("Undo create regions", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

                
    
    
    
