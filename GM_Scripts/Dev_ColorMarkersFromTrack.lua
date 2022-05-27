-- @description Color markers from closest item track
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--  Color markers from closest item track
 
 
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

 
-------------fill array with all the items
reaper.SelectAllMediaItems( 0, true )
items={}
num = reaper.CountSelectedMediaItems()
for i=0, num-1 do
    item = reaper.GetSelectedMediaItem(0,i)
    items[i+1] = item
end


--------------------------------------------



 
 
_, num_markers, num_regions = reaper.CountProjectMarkers( 0 )

for i=0, num_markers -1 do
    
    _, _, pos, _, _, idx, _ = reaper.EnumProjectMarkers3( 0, i )
 
    for j=1, #items do
        item = items[j]
        itemPos = reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
        track =  reaper.GetMediaItem_Track( item )
        color = reaper.GetMediaTrackInfo_Value( track, "I_CUSTOMCOLOR"  )
        
        if j == 1 then
            diff = math.abs(itemPos - pos)
            colorDef = color
        else
            if math.abs(itemPos - pos) < diff then
                diff = math.abs(itemPos - pos)
                colorDef = color
            end
        end
    end
    reaper.SetProjectMarker3( 0, idx, false, pos, pos, "", colorDef )
  
    
   
end

reaper.Undo_EndBlock("Undo marker color", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

