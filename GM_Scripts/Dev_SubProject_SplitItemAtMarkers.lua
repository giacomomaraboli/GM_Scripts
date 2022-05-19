-- @description Sub project split item at markers
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   split the subproject item based on the markers in the subproject

reaper.ClearConsole()
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

function splitString(inputstr)
        --[[if sep == nil then
                sep = "%s"
        end]]
        local t={}
        for str in string.gmatch(inputstr, "([^".."%s".."]+)") do
                table.insert(t, str)
        end
        return t
end



item = reaper.GetSelectedMediaItem(0,0)
itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION"  )
tk = reaper.GetActiveTake(item)
 
pcm_source = reaper.GetMediaItemTake_Source(tk)
strings = {}
i=1
filename = reaper.GetMediaSourceFileName(pcm_source)
file = io.open(filename, r)
  

for line in file:lines() do
   
    if string.find(line, "MARKER") then
        strings[i] = line
        i=i+1
        
    end
end

io.close(file)
markers = {}

for i =1, #strings do
    t = splitString(strings[i])
    markers[i] = tonumber( t[3])
end

offset = markers[1] - itemStart
for i = 1, #markers do
    
    position = markers[i] - offset
    
    reaper.SetEditCurPos( position, false, false )
    
    reaper.Main_OnCommand(40759,0) --split item at cursor
    
end



 reaper.PreventUIRefresh(-1)
 reaper.Undo_EndBlock("Undo split items", -1)
 reaper.UpdateArrange()



 
 
 

