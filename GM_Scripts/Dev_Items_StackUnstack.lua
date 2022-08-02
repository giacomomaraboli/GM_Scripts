-- @description Stack unstack items
-- @author Giacomo Maraboli
-- @version 1.1
-- @about
--   stack unstack items




offset = 0.5
spacing = 2
-----------------------------------
reaper.ClearConsole()
function stack()
    num = reaper.CountSelectedMediaItems()
    items={}
    for i=0, num-1 do
        item = reaper.GetSelectedMediaItem(0,i)
        take = reaper.GetActiveTake(item)
        if take then
            position =  reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
            _, _ = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", tostring(position), true )
            items[#items+1] = item
        else
            --reaper.DeleteTrackMediaItem( reaper.GetMediaItem_Track(item), item )   
        end
    end
    

    for i=0, #items-1 do
        if i==0 then
            position =  reaper.GetMediaItemInfo_Value( items[i+1], "D_POSITION"  )
        end
        reaper.InsertTrackAtIndex( idx+i, false )
        newTr =reaper.GetTrack( 0, idx+i )
        reaper.MoveMediaItemToTrack( items[i+1], newTr )
        reaper.SetMediaItemInfo_Value( items[i+1], "D_POSITION" , position )
        if i == #items-1 then
        
            reaper.SetMediaTrackInfo_Value( newTr, "I_FOLDERDEPTH" , depth1 )
        end
    end
    reaper.SetEditCurPos( position, true, false )
    reaper.Undo_EndBlock("Unndo", -1)
end

-------------------------------------------------------------------

function unstack()
    
    num = reaper.CountSelectedMediaItems()
    items={}
    points={}
    endPoints={}
    for i=0, num-1 do
        item = reaper.GetSelectedMediaItem(0,i)
        take = reaper.GetActiveTake(item)
        if take then
            --position =  reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
            _, point = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", "", false )
            endPoint = reaper.GetMediaItemInfo_Value( item, "D_LENGTH"  )
        --reaper.ShowConsoleMsg(chunk.."\n")
        
            items[#items+1] = item
            points[#points+1] = point
            endPoints[#endPoints+1] = endPoint
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
       
        
        
        

    end
    
    if remaining > 0 then
        
        reaper.SetMediaTrackInfo_Value( parent, "I_FOLDERDEPTH" , 1 )
        lastTrack =  reaper.GetTrack( 0, idx + remaining -2)
        reaper.SetMediaTrackInfo_Value( lastTrack, "I_FOLDERDEPTH" , -1 )
    else
       reaper.SetMediaTrackInfo_Value( parent, "I_FOLDERDEPTH" , depth2 )
    end
    
    num =  reaper.CountTrackMediaItems( parent )    
    for i=0, num-1 do
        item =  reaper.GetTrackMediaItem( parent, i )
        if not item then return end
        emptyStartPos =  reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
          emptyEndPos = emptyStartPos + reaper.GetMediaItemInfo_Value( item, "D_LENGTH"  )
        if emptyStartPos > tonumber(points[1])-offset and emptyStartPos < tonumber(points[#points]) + endPoints[#endPoints] + offset or emptyEndPos > tonumber(points[1])-offset and emptyEndPos < tonumber(points[#points]) + endPoints[#endPoints] + offset then
            
            tk = reaper.GetActiveTake(item)
            if not tk then
                
                reaper.DeleteTrackMediaItem( parent, item )
            end
        end
    end
    _, _ = reaper.GetSetMediaItemInfo_String( item, "P_EXT:xyz", "", true )
    reaper.SetEditCurPos( position, true, false )
    reaper.Undo_EndBlock("Undo", -1)
    
    
end
end

--------MAIN--------------
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
    nextTrackParent =  reaper.GetParentTrack( boundTrack )
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
    stack()
else

    num = reaper.CountSelectedMediaItems()
    
    boundTrack =  reaper.GetTrack( 0, idx + #items -1)
    parent = reaper.GetParentTrack( track )
    reaper.SetTrackSelected( parent, true )
    nextTrackParent =  reaper.GetParentTrack( boundTrack )
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

