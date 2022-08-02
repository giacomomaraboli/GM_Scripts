-- @description Stack unstack items
-- @author Giacomo Maraboli
-- @version 1.2
-- @about
--   stack unstack items




offset = 0.5
spacing = 2
-----------------------------------
reaper.ClearConsole()
function stack()
    num = reaper.CountSelectedMediaItems()
    items={}
    itStarts={}
    itEnds={}
    for i=0, num-1 do
        item = reaper.GetSelectedMediaItem(0,i)
        take = reaper.GetActiveTake(item)
        if take then
            position =  reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
            _, _ = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", tostring(position), true )
            itPos = reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
            itEnd = itPos + reaper.GetMediaItemInfo_Value( item, "D_LENGTH"  )
            items[#items+1] = item
            itStarts[#itStarts+1] = itPos
            itEnds[#itEnds+1] = itEnd
            
        else
            --reaper.DeleteTrackMediaItem( reaper.GetMediaItem_Track(item), item )   
        end
    end
    
    j=0
    for i=0, #items-1 do
        if i==0 then
            position =  reaper.GetMediaItemInfo_Value( items[i+1], "D_POSITION"  )
        end
        
        if i>0 then
            prevPos = itStarts[i]
            prevEnd = itEnds[i]
            currPos = itStarts[i+1]
            currEnd = itEnds[i+1]
            newPrevPos = reaper.GetMediaItemInfo_Value( items[i], "D_POSITION"  )
  
          
            
            if currPos >= prevEnd then
               
                reaper.InsertTrackAtIndex( idx+j, false )
              
                newTr =reaper.GetTrack( 0, idx+j )
                reaper.MoveMediaItemToTrack( items[i+1], newTr )
                reaper.SetMediaItemInfo_Value( items[i+1], "D_POSITION" , position )
                
            else
                
                reaper.MoveMediaItemToTrack( items[i+1], newTr )
                reaper.SetMediaItemInfo_Value( items[i+1], "D_POSITION" , newPrevPos + (currPos - prevPos) )
               
                _, _ = reaper.GetSetMediaItemInfo_String( items[i+1], "P_EXT:xyz", tostring(prevPos), true )
                j=j-1
                                
            end
            
            if i == #items-1 then
        
                reaper.SetMediaTrackInfo_Value( newTr, "I_FOLDERDEPTH" , depth1 )
            end
        else
           
            reaper.InsertTrackAtIndex( idx+j, false )
            
            newTr =reaper.GetTrack( 0, idx+j )
            reaper.MoveMediaItemToTrack( items[i+1], newTr )
            reaper.SetMediaItemInfo_Value( items[i+1], "D_POSITION" , position )
        end
        j=j+1
    end
    reaper.SetEditCurPos( position, true, false )
    reaper.Undo_EndBlock("Undo", -1)
end

-------------------------------------------------------------------

function unstack()
    
    num = reaper.CountSelectedMediaItems()
    items={}
    points={}
    endPoints={}
    tempStart ={}
    ref = -1
    for i=0, num-1 do
        item = reaper.GetSelectedMediaItem(0,i)
        take = reaper.GetActiveTake(item)
        if take then
            position =  reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
            _, point = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", "", false )
            endPoint = reaper.GetMediaItemInfo_Value( item, "D_LENGTH"  )
        --reaper.ShowConsoleMsg(chunk.."\n")
            tr = reaper.GetMediaItem_Track(item)
            idx = reaper.GetMediaTrackInfo_Value( tr, "IP_TRACKNUMBER" )
            
        
            items[#items+1] = item
            tempStart[#tempStart+1] = position
            
            if idx == ref then
                points[#points+1] = point + (tempStart[#tempStart]-tempStart[#tempStart-1])
                endPoints[#endPoints+1] = endPoint + (tempStart[#tempStart]-tempStart[#tempStart-1])
            else
                points[#points+1] = point
                endPoints[#endPoints+1] = endPoint
                ref = idx
            end
            

        end
    end
    
    
    
    if points[1] == "" then
    
      --reaper.ShowConsoleMsg("insert code here")
      for i = 1, #items do
          reaper.MoveMediaItemToTrack( items[i], parent )    
           
          if i == 1 then
              startPos =  reaper.GetMediaItemInfo_Value( items[i], "D_POSITION"  )
              endPos = startPos +  reaper.GetMediaItemInfo_Value( items[i], "D_LENGTH"  )
                         
          else
                     
              reaper.SetMediaItemInfo_Value( items[i], "D_POSITION" , endPos + spacing )
              endPos = endPos + spacing + reaper.GetMediaItemInfo_Value( items[i], "D_LENGTH"  )
          end
    end
    
 
    
   else 
    
    
    for i = 1, #items do
        
                   
        tr =reaper.GetMediaItem_Track(items[i])
        
        reaper.MoveMediaItemToTrack( items[i], parent )
        itemsInTrack = reaper.CountTrackMediaItems( tr )
        
        if itemsInTrack == 0 then
            reaper.DeleteTrack( tr )
        else
            remaining = remaining + 1
        end
        
        reaper.SetMediaItemInfo_Value( items[i], "D_POSITION" , tonumber(points[i]) )
        _, _ = reaper.GetSetMediaItemInfo_String( items[i], "P_EXT:xyz", "", true )
       
        
        
        

    end
    

    _, _ = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", "", true )
    reaper.SetEditCurPos( position, true, false )
    reaper.Undo_EndBlock("Undo", -1)
    
    
end
end

--------MAIN--------------
--------------------------
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()

items={}


    num = reaper.CountSelectedMediaItems()
    
    for i=0, num-1 do
        item = reaper.GetSelectedMediaItem(0,i)
        take = reaper.GetActiveTake(item)
        if take then
            --position =  reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
           -- _, _ = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", tostring(position), true )
            items[#items+1] = item
        else
            --reaper.DeleteTrackMediaItem( reaper.GetMediaItem_Track(item), item )   
        end
    end
    
item = items[1]
if not item then return end
nextItem = items[2]
track = reaper.GetMediaItem_Track(item)
nextTrack = reaper.GetMediaItem_Track(nextItem)


idx = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )
nextIdx = reaper.GetMediaTrackInfo_Value( nextTrack, "IP_TRACKNUMBER" )

remaining = 0

--reaper.ShowConsoleMsg(idx.."  ")
--reaper.ShowConsoleMsg(nextIdx.."\n")


if idx == nextIdx then
        boundTrack =  reaper.GetTrack( 0, idx )
    
        parent = reaper.GetParentTrack( track )
        if boundTrack then
            nextTrackParent =  reaper.GetParentTrack( boundTrack )
        end
        depth1 = -1
        depth2 = -1
        reaper.SetTrackSelected( track, true )
        if parent and not nextTrackParent then 
            depth1 = -2
            depth2 = -2
        end
    
        if parent and nextTrackParent then
            depth2 =0
        end
    
        reaper.SetMediaTrackInfo_Value( track, "I_FOLDERDEPTH" , 1 )
        _, point = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", "", false )
        if point =="" then
            stack()
        else
            unstack()
        end
else
    
    num = reaper.CountSelectedMediaItems()
    
    boundTrack =  reaper.GetTrack( 0, idx + #items -1)
    parent = reaper.GetParentTrack( track )
    reaper.SetTrackSelected( parent, true )
    
    if boundTrack then
        nextTrackParent =  reaper.GetParentTrack( boundTrack )
    end
    depth1 = -1
    depth2 = -1
    
    if parent and not nextTrackParent then 
        depth1 = -2
        depth2 = -2
        
    
    end
    
    if parent and nextTrackParent then
        depth2 =0
        
    end
    unstack()
    
end
  reaper.Undo_EndBlock("Undo stack/unstack", -1)
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
