-- @description Auto folder itmes
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   auto folder items
reaper.ClearConsole()
-- USER VARIABLES ----------------------------------------------------------

  
  --selecting folder item selects all child items
  userChildrenSelection = true --defauklt true


r = reaper


---------------------------------------------------------------------------
function contains(parentItem, item)
--returns true is item is inside parentItem timewise

      local parentItem = parentItem
      local item = item
      
      local parentIn = reaper.GetMediaItemInfo_Value( parentItem,"D_POSITION") - 0.000000000001
      local parentOut = parentIn + reaper.GetMediaItemInfo_Value( parentItem,"D_LENGTH") + 0.000000000002
      local itemIn = reaper.GetMediaItemInfo_Value( item,"D_POSITION") 
      local itemOut = itemIn + reaper.GetMediaItemInfo_Value( item,"D_LENGTH")
      
       
      if parentIn<=itemIn and itemOut<=parentOut then
          return true
      else
          return false
      end 
end --functions

----------------------------------------------------------------------------

function emptyItemExists(currStart, currEnd, parentTrack )

 
    local currStart, currEnd, parentTrack = currStart, currEnd, parentTrack
    local i, item
    local returnValue = false
    
    
    local margin = 0.0000000000001
        
    for i=0, reaper.CountTrackMediaItems(parentTrack)-1 do
        item = r.GetTrackMediaItem(parentTrack, i)
        if item~=nil then
          --if item is empty
          if r.CountTakes(item)==0 then
              local itemStart = reaper.GetMediaItemInfo_Value( item,"D_POSITION")
              local itemEnd = itemStart + reaper.GetMediaItemInfo_Value( item,"D_LENGTH")
              if (currStart-margin<=itemStart) and (itemStart<=currStart+margin) and (currEnd-margin<=itemEnd) and (itemEnd<=currEnd+margin) then
                  AA = currStart
                  return true, item
              end --if
              
          end --if
        end --if item
    end --for 
    return false

end --function emptyItemExists

---------------------------------------------------------------------------

function selectChildrenItems(parentTrack, item)

    local parentTrack = parentTrack
    local parentItem = item
    local parentNum, track, m, item, i
    local depth
    
    parentNum = -1 + reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER")
    i = 1
    depth = 0
    
    track = reaper.GetTrack(0, parentNum+i)
    depth = 0 --we know that this parent has at least one child 
    while depth>=0 do  
     
        track = reaper.GetTrack(0, parentNum+i)
    if track ~= nil then
      --select  items on the track
      for m=0, reaper.CountTrackMediaItems(track)-1 do
         item = reaper.GetTrackMediaItem(track, m)
         
         if contains(parentItem, item) then
            reaper.SetMediaItemSelected(item, true)
         end 
         
      end --for
      
      --check depth
      depth = depth + reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
      i = i+1
        else 
      depth = -1
    end
    end --while 
    

end --function selectItems


-------------------------------------------------------------------------
function NoteInChildrenItems(parentTrack, item)

    local parentTrack = parentTrack
    local parentItem = item
    local parentNum, track, m, item, i
    local depth
    local foundText = false
    local textYes
    local itemsNoNote={}
    
    parentNum = -1 + reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER")
    i = 1
    depth = 0
    
    track = reaper.GetTrack(0, parentNum+i)
    depth = 0 --we know that this parent has at least one child 
    while depth>=0 do  
     
        track = reaper.GetTrack(0, parentNum+i)
    if track ~= nil then
      --select  items on the track
      for m=0, reaper.CountTrackMediaItems(track)-1 do
         item = reaper.GetTrackMediaItem(track, m)
         
         if contains(parentItem, item) then
            --reaper.SetMediaItemSelected(item, true)
            tk = reaper.GetActiveTake(item)
            if tk then
              _, text  = reaper.GetSetMediaItemInfo_String( item, "P_NOTES","",false )
              
              
              if text == "" then
                  if foundText then
                      reaper.GetSetMediaItemInfo_String( item, "P_NOTES",textYes,true )
                  else
                      itemsNoNote[#itemsNoNote+1]=item
                  end
                
              end
              
   
              
              if text ~= "" and foundText == false then
           
                  textYes = text
                  trackAbove =  reaper.GetTrack( 0, parentNum )
                  x = 1
                  j=0
                  while trackAbove do

                      folderDepth = reaper.GetMediaTrackInfo_Value( trackAbove, "I_FOLDERDEPTH"  )
                      --trackAbove =  reaper.GetTrack( 0, parentNum - x )
                      --x=x+1
                      if folderDepth ~= 1 then
                          break
                      else
                          trackAbove =  reaper.GetTrack( 0, parentNum - x )
 
                          x=x+1
                          j=j+1
                      end
                       
                  end

                  separator= string.format(" .SEP%01d. ",j-1)
                  nextSeparator= string.format(" .SEP%01d. ",j)
  
           
                  _, End = string.find(text, separator )
                  nextBegin, _ = string.find(text, nextSeparator )

                  if End and nextBegin then
                      text = string.sub(text,End+1,nextBegin-1)
                  elseif not nextBegin and End then
                      text = string.sub(text,End+1,nextBegin)
                  elseif not End then
                      text = ""
                  end
                    
                
                reaper.GetSetMediaItemInfo_String( parentItem, "P_NOTES",text,true )
                foundText = true
               -- for w=1,#itemsNoNote do ----add note to children items that don't have notes
                --    reaper.GetSetMediaItemInfo_String( itemsNoNote[w], "P_NOTES",textYes,true )
                     
               -- end
            end
            end
         end 
        
      end --for
      
      --check depth
      depth = depth + reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
      i = i+1
        else 
      depth = -1
    end
    end --while 
    

end --function selectItems
--------------------------------------------------------------------------

function doFolderItem(track)

    local parentTrack = track
    local track, itemStart, itemEnd, itemSel, minStart, maxEnd, emptyNum, trackGUID, prevMergedThis
    local parentNum =r.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER")-1
    local i, t =0,0    
    local haveFirstItem = false
    local itemsNum, item, parentName, emptyItem
    local checkedChildrenNum = 0
    local childNum = 0
    local childrenSelection = true
    local merged = {}
    local mPos
         
    
    --trackGUID = reaper.GetTrackGUID(parentTrack)
    
    --write into folders array
    --folders[trackGUID] = true
    
    --count children num
    i = 0    
    repeat
        childNum = childNum + 1
    if r.GetTrack(0,parentNum+childNum) ~= nil then
      i = i + r.GetMediaTrackInfo_Value(r.GetTrack(0, parentNum+childNum), "I_FOLDERDEPTH")
    else
      childNum = childNum -1
      i = -1
    end
    until i<0
    
  
    
    for t=1, childNum do
          track = r.GetTrack(0, parentNum+t)
          --if  reaper.GetMediaTrackInfo_Value( track, "B_MUTE") th
              --recursion for folders in folders
              if r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")==1 then  
                  --recursion returns how many tracks we have had look at inside it          
                  checkedChildrenNum = doFolderItem(track)          
              end --if
              
              t=t+checkedChildrenNum
              
              
              itemsNum =  reaper.CountTrackMediaItems( track )  
            
            
              --fill the array with the first track containing items
              if #merged==0 then
                for i=0, itemsNum-1 do
                    item = reaper.GetTrackMediaItem(track,i)   
                    
                    
                    itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                    
                    itemEnd = itemStart +  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                    itemSel =  reaper.IsMediaItemSelected( item )
                    table.insert(merged, {itemStart,itemEnd, itemSel})
                end --for i
              
              --or sort-merge the array with the next track
              else
                mPos = 1 --position in the merged array   
                for i=0, itemsNum-1 do    
                    item = reaper.GetTrackMediaItem(track,i)  
                    
           
                        itemStart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                        itemEnd = itemStart +  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                        itemSel = reaper.IsMediaItemSelected( item )
               
                          
                    --insert item        
                    while itemStart>merged[mPos][1] do
                        mPos = mPos + 1
                        if merged[mPos]==nil then break end
                    end        
                    table.insert(merged, mPos, {itemStart,itemEnd, itemSel})
                    
                    
                    
                end --for i
              end --if t

              --flatten the merged array
              if #merged>1 then
                  local changed = false
                  repeat
                    changed = false
                    for i=#merged, 2, -1 do --iterating backwards
                        currItemStart = merged[i][1]
                        prevItemEnd = merged[i-1][2]
                        if currItemStart<prevItemEnd then
                            merged[i-1][2] = math.max(merged[i][2],merged[i-1][2])
                            merged[i-1][3] = merged[i][3] and merged[i-1][3] --the value after sorting shows wheter all items under this folder itam are selected
                            table.remove(merged, i)
                            changed = true
                        end 
                     end --for
                  until changed==false
              end --if #merged

             -- prevMerged[trackGUID] = {true, merged}
              
            
    end --for   
    
 
    checkedChildrenNum = i
    
 
    
    --SET EMPTY ITEMs--------------------------------------------------------------
    reaper.PreventUIRefresh(1)
    

        local anySelected = false --any item selected on this track
        itemsNum = reaper.GetTrackNumMediaItems(parentTrack) 
       
        
        j=0
        x=0
        for i=itemsNum-1, 0, -1 do
            k=1
            item = r.GetTrackMediaItem(parentTrack, i)
            
            if item~=nil then
                --if item is empty
                if r.CountTakes(item)==0 then
                    --if item is not selected
                    if not reaper.IsMediaItemSelected( item ) then

                        r.DeleteTrackMediaItem(parentTrack, item)
                    else
                        --select all child items under this item
                        if childrenSelection and userChildrenSelection then
                             selectChildrenItems(parentTrack, item)            
                        end --if  
                    end
                end --if
            end --if item~+nil  
            k=k+1
        end --for

        --if we have any items in children
        if #merged>0 then
            --create new empty items
            _, parentName = reaper.GetSetMediaTrackInfo_String(parentTrack, "P_NAME", "", false)
            --local track_color =  reaper.GetTrackColor( parentTrack )
            for i=1, #merged do
                local currStart = merged[i][1]
               -- reaper.ShowConsoleMsg("after  ")
                --reaper.ShowConsoleMsg(i.."\n")
                
                local currEnd = merged[i][2]
                --create parent item
                if not emptyItemExists(currStart, currEnd, parentTrack) then
                  local emptyItem = reaper.AddMediaItemToTrack( parentTrack )

                  reaper.SetMediaItemInfo_Value(emptyItem, "D_POSITION",  merged[i][1])
                  reaper.SetMediaItemInfo_Value(emptyItem, "D_LENGTH", merged[i][2] -  merged[i][1])
                  NoteInChildrenItems(parentTrack, emptyItem)

                end --if not emptyItemExists         
            end

        
        end --if
    reaper.PreventUIRefresh(-1)
     
    return checkedChildrenNum 
  
end --function duFolderItem

------------------------------------------------------------------------

-----------------------------------------------------------------------

function exit()
    --nikolalkc edit
  --reaper.SNM_SetIntConfigVar("showpeaks",2067) --hide faint peaks in folders
  
  
    --clear empty items in folders
    for i=0, reaper.CountTracks()-1 do
        
          track = reaper.GetTrack(0,i)
          
          --unset free item positioning
          reaper.SetMediaTrackInfo_Value( track, "B_FREEMODE", 0 )
          
          --if folder
          if reaper.GetMediaTrackInfo_Value( track, "I_FOLDERDEPTH")>0 then            
                        
              --delete all empty itmes
              for m=r.CountTrackMediaItems( track )-1, 0, -1 do
                  item = r.GetTrackMediaItem( track, m )
                  if item then
                    if r.GetMediaItemNumTakes( item )==0 then
                        r.DeleteTrackMediaItem( track, item )
                    end
                  end --if item
              end --for
              
              
          end --if       
        
    end --for
    r.UpdateArrange()
    
    --set the action state OFF
    r.SetToggleCommandState( sectionID, cmdID, 0 ) -- Set OFF
    r.RefreshToolbar2( sectionID, cmdID ) 

end --function exit()

----------------------------------------------------------------------

function main()

    

    if prevState~=reaper.GetProjectStateChangeCount( 0 ) then

      --reaper.ShowConsoleMsg("dyuv")
        track = reaper.GetSelectedTrack(0,0)
        if track then
            if r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")==1 then
                doFolderItem(track)
            end
            
            parentTrack = reaper.GetParentTrack(track)
        
            while parentTrack do
                doFolderItem(parentTrack)
                parentTrack = reaper.GetParentTrack(parentTrack)
            end
        end
        
        prevState = reaper.GetProjectStateChangeCount( 0 )
     
        r.UpdateArrange()
        
    end --if 

   
   r.defer(main)
  
end --function main

-------------------------------------------------------------------------


--set ON the action state
_, _, sectionID, cmdID = r.get_action_context()
r.SetToggleCommandState( sectionID, cmdID, 1 ) -- Set ON
r.RefreshToolbar2( sectionID, cmdID )


prevMerged = {} --stores what empty items should be in the parent track, indexed by track guid
prevState = 0 --reaper.GetProjectStateChangeCount( 0 )
folders = {}

--reaper.SNM_SetIntConfigVar("showpeaks",2051)  --nikolalkc edit: show faint peaks in folders
main()
r.atexit(exit)

