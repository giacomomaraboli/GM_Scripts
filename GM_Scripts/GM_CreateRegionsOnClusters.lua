-- @description Create regions on clusters of items
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   create regions on clusters of items

reaper.ClearConsole()
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

i=0

lastItem = false

function checkItems (itemNumber, regStart, regEnd) do
      for i=0, itemNumber-1 do
          found = false
          nextItem = reaper.GetSelectedMediaItem(0, i)
          if nextItem == nil then break end
          
          nextItemStart =  reaper.GetMediaItemInfo_Value(nextItem, "D_POSITION")
          nextItemEnd = nextItemStart + reaper.GetMediaItemInfo_Value(nextItem, "D_LENGTH")
          if (nextItemStart >= regStart and nextItemStart <= regEnd) or (nextItemEnd >= regStart and nextItemEnd <= regEnd)then
                                     
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
                            
                 

while true do
      
      selItemNum = reaper.CountSelectedMediaItems()
      
      found = true
      item = reaper.GetSelectedMediaItem(0, 0)
      if item == nil then break end
      
      regionStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      regionEnd = regionStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
     
      
      
      while found == true do
          
          regionStart, regionEnd, found = checkItems(selItemNum, regionStart, regionEnd)
         
      end
          
        
      regionindex=reaper.AddProjectMarker2(0, true, regionStart, regionEnd, "", -1, 1)
      
      reaper.SetMediaItemSelected( item, 0 )
     
  
end  
reaper.Undo_EndBlock("Undo create regions", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

                
    
    
    
