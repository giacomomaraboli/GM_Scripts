-- @description seamless loop utility
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   seamless loop utility

reaper.ClearConsole()

it = reaper.GetSelectedMediaItem(0,0)
lenght = 0
numLoop = 1
fade = 8

origStart =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
origEnd = origStart + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
itLenght = origEnd - origStart

if lenght == 0 and numLoop == 1 then
    lenght = itLenght
end

numDivision = itLenght/numLoop

for i=1, numLoop -1 do
    splitPoint = origStart + (numDivision * i)
    reaper.SetEditCurPos(splitPoint, false, false)
    reaper.Main_OnCommand(40757, 0) --split item at cursor
    
end


loops={}
selNum = reaper.CountSelectedMediaItems()
for i=0, selNum -1 do
    item = reaper.GetSelectedMediaItem(0,i)
    loops[i+1]= item
end
reaper.SelectAllMediaItems( 0, false )
j=1
for i=0, #loops -1 do
    
    reposition = origStart + (lenght * (j-1))
    --reaper.ShowConsoleMsg("\n"..#loops)
    
    it = loops[j]
    reaper.SetMediaItemSelected( it, true )
    itStart =  reaper.GetMediaItemInfo_Value(it, "D_POSITION")
    itEnd = itStart + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
    itLenght = itEnd - itStart


    itMidPoint= itStart + (itLenght/2)


    reaper.SetEditCurPos(itMidPoint, false, false)

    reaper.Main_OnCommand(41995, 0) --move cursor to nearest zero crossing

    zPos = reaper.GetCursorPosition()

    reaper.Main_OnCommand(40757, 0) --split item at cursor

    reaper.SetEditCurPos(zPos-((lenght/2)+(fade/2)), false, false)
    reaper.Main_OnCommand(40511, 0) --trim left


    reaper.SetEditCurPos(zPos+((lenght/2)+(fade/2)), false, false)
    reaper.Main_OnCommand(40512, 0) --split item at cursor


    num=reaper.CountSelectedMediaItems()
    items= {}
    for i=0,num-1 do

    item = reaper.GetSelectedMediaItem(0,i)
    items[i+1] = item
    end


    reaper.SetMediaItemInfo_Value( items[2], "D_POSITION" , reposition )
    reaper.SetMediaItemInfo_Value( items[1], "D_POSITION" , reposition+((lenght/2)-(fade/2)) )

    reaper.Main_OnCommand(41059, 0) --crossfade items
    --reaper.Main_OnCommand(42432, 0) --glue items
    reaper.Main_OnCommand(40706, 0) --random color
    reaper.SelectAllMediaItems( 0, false )
    j=j+1
end
