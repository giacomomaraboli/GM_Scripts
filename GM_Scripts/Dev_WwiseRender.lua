-- @description Wwise Render
-- @author Giacomo Maraboli
-- @version 1.2
-- @about
--   Render for folder item workflow wiht Wwise integration


--------------

userChannels = "stereo" -- "quad" --"5.1"--"mono"
user2ndpass = false
userTailLenght = 0
userSingleFile = false
userImport = false
subproj = true
defaultRenderPath = "Renders"

---------------------------------------------------------------------------------------------------------------
function setRenderOptions()  --set general render option from GUI

    reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock()
    
    renderItems = {}
    emptyItems ={}
    itemTrackIdx = {}
    alreadyThere = false
    
    

    
    buf = reaper.GetProjectName( 0 ) --check name of the project for handling subproject rendering
    
    
    opts = GUI.Val("Checklist1") --tail or 2nd pass render
    if opts == 2 then 
        loop = 2048
        tail=0
    else 
        loop = 0
        tailLenght = tonumber(GUI.Val("TextboxTail")) --get tail length from gui
        if tailLenght == 0 then
            tail = 0
        else
            tail = 8
            tailLenght = tailLenght * 1000
            reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , tailLenght, true )  --set render tail lenght in ms
        end
    end
    
    optChan = GUI.Val("Channels")  --get channel configuration from gui
    if optChan == 1 then channel = 1
    elseif optChan == 2 then channel = 2
    elseif optChan == 3 then channel = 4
    elseif optChan == 4 then channel = 6
    end
    
    reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , "wave", true ) --set wav format
    reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" , (8|loop), true ) --set 2nd pass render
    _, _ = reaper.GetSetProjectInfo_String( 0, "RENDER_FILE" , "", true )
    

    if GUI.Val("TimeSel") == true then --check if time selection is checked on gui
    
        timeSel()
        return
    end
    
    reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,3, true ) --render project regions
    reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" , tail, true ) --set tail 
    reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , channel, true ) --set numebr of channels

    
    num = reaper.CountSelectedMediaItems()
    
 ---------------------------Get index of tracks that have empty items selected   
    j=1
    for i=0, num-1 do
        alreadyThere = false
        item = reaper.GetSelectedMediaItem(0,i)
        
        tk = reaper.GetActiveTake(item)
        
        if not tk then --it means is an empty item
        
            emptyItems[#emptyItems+1] = item
            track =  reaper.GetMediaItem_Track( item )
            trackIdx =  reaper.GetMediaTrackInfo_Value( track , "IP_TRACKNUMBER"  )
            
            for j=0, #itemTrackIdx do --check that the index of the track is not already in the array
                if trackIdx == itemTrackIdx[j+1] then
                    alreadyThere = true
                end
            end
            if not alreadyThere then --if the index is not already in the array then add it
                itemTrackIdx[#itemTrackIdx+1]=trackIdx
            end
        end
    end
    
        ------------------PER OGNI EMPTY ITEMS VERIFICARE::
        --------------------SE NON HA PARENT VA INCLUSA
    for i=1,#emptyItems do
    
        alreadyThere = false
        track =  reaper.GetMediaItem_Track( emptyItems[i] )
        parent = reaper.GetParentTrack(track)
        
        if not parent then
            renderItems[#renderItems+1] = emptyItems[i]
        else
            trackIdx =  reaper.GetMediaTrackInfo_Value( parent , "IP_TRACKNUMBER"  )
            for j=0, #itemTrackIdx do
                if trackIdx == itemTrackIdx[j+1] then
                    alreadyThere = true
                end
            end
                if not alreadyThere then
                    renderItems[#renderItems+1] = emptyItems[i]
                end
        end
    end
  
    
    if GUI.Val("Single") == true then --check if single file is selected in gui
       
        singleFile(renderItems)
    else
        clusterGroupPrep(renderItems)
    end
   
   
end
 
----------------------------------------------------------------------------------------------------------------------
function timeSel()

    
    name = GUI.Val("TextboxName")
    reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,0|loop, true )
    reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,2, true ) --set render time selection
  
    if GUI.Val("Subpr") == true then
        name = buf.."\\"..name
    end
    
    reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,name, true )

    if tail == 8 then
        reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" , 4, true ) --set tail 
    end
    
    
    reaper.Main_OnCommand( 41824, 0 ) --render with windows open
    

    
    --original render settings
    resetProjSettings()
    

    reaper.Undo_EndBlock("Render", -1) 
    reaper.PreventUIRefresh(-1)
    reaper.UpdateArrange()
    
end

-------------------------------------------------------------------------------------------------

function clusterGroupPrep(renderItems)

num=reaper.CountSelectedMediaItems()

j=1
local emptyItems= renderItems --put all empty items in array

j=1
k=1
renderGroup={}
renderGroup[j]={}

for i=1, #emptyItems do   
--for each empty item check if overlaps with other empty items and populate a table with the different render groups - one render group for all non overlapping items

    item = emptyItems[i]
    itemStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
   
     
    if i==1 then  --first time in the loop - insert first item in table 
        renderGroup[j][k] = item
    else
     
    j=1
    k=1
    done = false
    while renderGroup[j] ~= nil do  --check the next empty item start and end with all the empty items already in the table
        
        overlap = false
        
        while renderGroup[j][k] ~= nil do
            
            
            it = renderGroup[j][k]
            if it ~= item then  
            
                st = reaper.GetMediaItemInfo_Value(it, "D_POSITION")
                en = st + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
            
                if (itemStart>=st and itemStart <= en) or ( itemEnd >= st and itemEnd <= en) then
                    
                    overlap = true
                    break
                end
            end
                
            k=k+1
            
        end
        
        if overlap == false then  --not overlapping, insert item in the same array
                     
            renderGroup[j][k] = item
            done = true
            break
        end
        if done then break end
        
        j=j+1
        
        k=1
    end 
    
    if done == false then --overlapping creating the next array and put in the first element
      
      k=1
      renderGroup[j] ={}
       
      renderGroup[j][k] = item
    end
  end
end
  render()
 --reaper.ShowConsoleMsg(#renderGroup)


end   
    
-----------------------------------------------------------------------------------------------------------------------    
function render() --render region clusters
    ----------------------------------VERIFICARE SE EMPTY ITEMS SONO SOVRAPPOSTE E METTERLE IN ARRAY DIVERSI
   regions ={}
      j=1
      k=1
      i=1
      lenght = #renderGroup
      
      while renderGroup[j] ~= nil do
         
          --reaper.SelectAllMediaItems( 0, false )
          while renderGroup[j][k] ~= nil do
          --goes trough every array in the table and render them separately
              
              item = renderGroup[j][k]
              track =  reaper.GetMediaItemTrack( item )
              reaper.SetMediaTrackInfo_Value( track, "I_SOLO" , 1 )
           -- reaper.SetMediaItemSelected(item, true)
           -- reaper.Main_OnCommand(40034,0)  --select all items in group
            
              itemStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
              itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
              _, itemText = reaper.GetSetMediaItemInfo_String(item , "P_NOTES","",false )
              nName = GUI.Val("TextboxName")
              wwiseItemText =""
              if string.find(itemText, "\n") then
                  t={}
                  for tx in string.gmatch(itemText, "([^".."\n".."]+)") do
                      t[#t+1] = tx
                      
                  end
                  itemText = t[1]
                
                  if #t>1 then-------------------------------------------------save wwise structure for individual item
                      
                      wwiseItemText = t[2]
                  end
                  
              end
  
            
              if default_text  == "" then
            
                  if string.find(nName,"@") == nil then
                      add = "_" .. string.format("%02d", tostring(i))
                      i=i+1
                      regionName = nName..add
                  else
                      regionName = string.gsub(nName, "@", itemText)
            
                  end
              elseif default_text == "@" then
            
                  regionName = string.gsub(nName, default_text, itemText)
      
              end
            
              regIdx = reaper.AddProjectMarker2(0, true, itemStart, itemEnd, regionName, -1, 1)   --create regions
              
              
              if importWwise then
                  wwiseName[#wwiseName+1]=regionName
                  wwisePreText[#wwiseName] = wwiseItemText
              end
              
              regions[k] = regIdx 
              reaper.SetRegionRenderMatrix( 0, regIdx, reaper.GetMasterTrack( 0 ) , 1 ) --load region in render matrix
              k=k+1
            
          end
        
     -- reaper.Main_OnCommand( 41561, 0 )  --solo exlclusive
            if GUI.Val("Subpr") == true then
                name = buf.."\\".."$region"
            else
                name = "$region"
            end
      
      if importWwise then ----------------------------------set the render path
    
          
          reaper.GetSetProjectInfo_String(0, 'RENDER_FILE', sfxPath, true)
      end
      
      reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,name, true )
          if not importWwise then
              if j == lenght then
                reaper.Main_OnCommand( 41824, 0 ) --render with windows open
              else
                  reaper.Main_OnCommand( 42230, 0 ) --render with windows auto close
              end
          else
              reaper.Main_OnCommand( 42230, 0 )
          end
      j=j+1
      k=1
      
          
      
      while regions[k]~= nil do  --delete all regions
         
         reaper.DeleteProjectMarker( 0, regions[k], true )
          k=k+1
      end
      reaper.Main_OnCommand(40340,0)--unsolo all tracks
     
      k=1
      end
      
      if importWwise then
          wwiseImport()
      end

      
      --reset original render settings
    resetProjSettings()

      
reaper.Undo_EndBlock("Render", -1) 
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
 
end

---------------------------------------------------------------------------------------------------------------
function singleFile(renderItems)
    local renderItems = renderItems
    -------------vedi se ci sono tracce in solo
    
    
    -------------METTI IN SOLO LE TRACCE DELLE EMTPY ITEMS
    -----------------SE QUALCOSA è GIà IN SOLO?????????????
    for i=1, #renderItems do
        track =  reaper.GetMediaItem_Track( renderItems[i] )
        reaper.SetMediaTrackInfo_Value( track, "I_SOLO" , 1 )
        
        -------------TROVA LO START E END COMPLESSIVI
        itemStart = reaper.GetMediaItemInfo_Value( renderItems[i], "D_POSITION"  )
        itemEnd = itemStart + reaper.GetMediaItemInfo_Value( renderItems[i], "D_LENGTH"  )
        if i == 1 then
            renderStart = itemStart
            renderEnd = itemEnd
            _, itemText = reaper.GetSetMediaItemInfo_String(renderItems[i], "P_NOTES","",false )
        else
            if itemStart < renderStart then
                renderStart = itemStart
            end
            if itemEnd > renderEnd then
                renderEnd = itemEnd
            end
        end
        
    end

    -------------set render name
    name = GUI.Val("TextboxName")
    
    if string.find(name,"@") == nil then
                        
          regionName = name
    else
        regionName = string.gsub(name, "@", itemText)
        
        if string.sub(regionName,-3,-3) == "_" then      --check if there is an index, if so remove it
            regionName=regionName:sub(1,-4) .. ""
                      
        elseif string.sub(regionName,-4,-4) == "_" then
            regionName=regionName:sub(1,-5) .. ""
        end 
            
    end
    regIdx=reaper.AddProjectMarker2(0, true, renderStart, renderEnd, regionName, -1, 1)      --create regions
    reaper.SetRegionRenderMatrix( 0, regIdx, reaper.GetMasterTrack( 0 ) , 1 )
    if GUI.Val("Subpr") == true then
            regionName = buf.."\\"..regionName
    end
    reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,regionName, true ) --set name of rendering
    reaper.Main_OnCommand( 41824, 0 ) --render with windows open
    reaper.DeleteProjectMarker( 0, regIdx, true )
    
    for i=1, #renderItems do
           track =  reaper.GetMediaItem_Track( renderItems[i] )
           reaper.SetMediaTrackInfo_Value( track, "I_SOLO" , 0 )
    end
    
    resetProjSettings()


    reaper.Undo_EndBlock("Render", -1) 
    reaper.PreventUIRefresh(-1)
    reaper.UpdateArrange()
end

-------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------
function wwiseImport()
    multiples = false
    for i=1, #wwiseName do  
        if string.sub(wwiseName[1],-3,-3) == "_" then      --check if there is an index, if so remove it
            containerName=wwiseName[i]:sub(1,-4) .. ""
               
        elseif string.sub(wwiseName[1],-4,-4) == "_" then
            containerName=wwiseName[1]:sub(1,-5) .. ""
        else
            containerName = wwiseName[1]
        end  

        if i == 1 then  
            checkName = containerName
        end
        
        if containerName ~= checkName then
            multiples = true
            break
        end
    end
    
            
    if wwiseStruct ~= "" then
        commonStruct = ""   
        
            
        for str in string.gmatch(wwiseStruct, "([^".."-".."]+)") do
           
            if #str <= 2 then
        
                for subStr in string.gmatch(str, "([^"..".".."]+)") do
            
                    if subStr == "r" or subStr == "R" then
                        add = "<Random Container>"
                
                    elseif subStr == "b" or subStr == "B" then
                        add = "<Blend Container>"
                
                    elseif subStr == "sw" or subStr == "SW" or subStr == "Sw"then
                        add = "<Switch Container>"
                
                    elseif subStr == "sq" or subStr == "SQ" or subStr == "Sq"then
                        add = "<Switch Container>"
                
                    elseif subStr == "a" or subStr == "A" then
                        add = "<ActorMixer>"
                
                    elseif subStr == "v" or subStr == "V" then
                        add = "<Virtual Folder>"
                    end
                
                    newStr = "\\"
                    if not multiples then
                        newStr = newStr..add..containerName
                    else  
                        tmpText = add:sub(2, -2)  
                        newStr = newStr..add..tmpText
                    end
                    commonStruct = commonStruct..newStr
                    
                    originalCommonStruct = add:sub(2, -2)
                    --reaper.ShowConsoleMsg(originalCommonStruct)
                    
                    
                end
            else
    
                for subStr in string.gmatch(str, "([^"..".".."]+)") do
      
                
                    if subStr == "r" or subStr == "R" then
                        add = "<Random Container>"
                
                    elseif subStr == "b" or subStr == "B" then
                        add = "<Blend Container>"
                
                    elseif subStr == "sw" or subStr == "SW" or subStr == "Sw"then
                        add = "<Switch Container>"
                
                    elseif subStr == "sq" or subStr == "SQ" or subStr == "Sq"then
                        add = "<Switch Container>"
                
                    elseif subStr == "a" or subStr == "A" then
                        add = "<ActorMixer>"
                
                    elseif subStr == "v" or subStr == "V" then
                        add = "<Virtual Folder>"
                    else
                        stName = subStr
                  
                    end
        
                    newStr = "\\"
                    newStr = newStr ..add..subStr
                    originalCommonStruct = subStr
                    --reaper.ShowConsoleMsg(originalCommonStruct)
            
                end
    
                commonStruct = commonStruct..newStr
            end
        end
    else
        commonStruct = ""   
    end
    --reaper.ShowConsoleMsg(commonStruct.."\n")
    


    for i=1, #wwiseName do
        if string.sub(wwiseName[i],-3,-3) == "_" then      --check if there is an index, if so remove it
            containerName=wwiseName[i]:sub(1,-4) .. ""
               
        elseif string.sub(wwiseName[i],-4,-4) == "_" then
            containerName=wwiseName[i]:sub(1,-5) .. ""
        else
            containerName = wwiseName[i]
        end
        --reaper.ShowConsoleMsg(wwiseStruct.."\n")
    
        --[[if wwiseStruct ~= "" then
            newWwiseStruct = wwiseStruct.."-"..wwisePreText[i]
        else
            newWwiseStruct = wwisePreText[i]
        end]]
        newWwiseStruct = wwisePreText[i]
        
        finalStructure = ""
        originalsStructure = ""
   
        if newWwiseStruct ~= "" then
           
            
            for str in string.gmatch(newWwiseStruct, "([^".."-".."]+)") do
               
                if #str <= 2 then
            
                    for subStr in string.gmatch(str, "([^"..".".."]+)") do
                
                        if subStr == "r" or subStr == "R" then
                            add = "<Random Container>"
                    
                        elseif subStr == "b" or subStr == "B" then
                            add = "<Blend Container>"
                    
                        elseif subStr == "sw" or subStr == "SW" or subStr == "Sw"then
                            add = "<Switch Container>"
                    
                        elseif subStr == "sq" or subStr == "SQ" or subStr == "Sq"then
                            add = "<Switch Container>"
                    
                        elseif subStr == "a" or subStr == "A" then
                            add = "<ActorMixer>"
                    
                        elseif subStr == "v" or subStr == "V" then
                            add = "<Virtual Folder>"
                        end
                    
                        newStr = "\\"
                        newStr = newStr ..add..containerName
                        finalStructure = finalStructure..newStr
                        
                        originalsStructure = originalsStructure.."\\"..containerName
                    end
                else
        
                    for subStr in string.gmatch(str, "([^"..".".."]+)") do
          
                    
                        if subStr == "r" or subStr == "R" then
                            add = "<Random Container>"
                    
                        elseif subStr == "b" or subStr == "B" then
                            add = "<Blend Container>"
                    
                        elseif subStr == "sw" or subStr == "SW" or subStr == "Sw"then
                            add = "<Switch Container>"
                    
                        elseif subStr == "sq" or subStr == "SQ" or subStr == "Sq"then
                            add = "<Switch Container>"
                    
                        elseif subStr == "a" or subStr == "A" then
                            add = "<ActorMixer>"
                    
                        elseif subStr == "v" or subStr == "V" then
                            add = "<Virtual Folder>"
                        else
                            stName = subStr
                            originalsStructure = originalsStructure.."\\"..stName
                        end
            
                        newStr = "\\"
                        newStr = newStr ..add..subStr
                    
                
                    end
        
                    finalStructure = finalStructure..newStr
                end
            end
        else
            finalStructure = ""
            originalsStructure = ""
        end

        wwiseStructArray[i] = commonStruct..finalStructure
        origStructArray[i] = originalCommonStruct..originalsStructure

    end
    --reaper.ShowConsoleMsg(#wwiseStructArray)
    
    
    
    
    local info = debug.getinfo(1,'S');
    local path = info.source:match[[^@?(.*[\/])[^\/]-$]]
    --local fileName = "ReaperWwiseImport\\transfer.txt"
    local fileName = "ReaperWwiseImport\\transfer.txt"
    
    local file = io.open(path..fileName, "w")

    if GUI.Val("Subpr") == true then
        sfxPath = sfxPath.."\\"..buf
    end
    
    file:write(#wwiseName.."\n")
    
    for i = 1, #wwiseName do
        file:write(wwiseStructArray[i].."\\<Sound>"..wwiseName[i].."\n")
        file:write(sfxPath.."\\"..wwiseName[i]..".wav\n")
        file:write(origStructArray[i].."\n")
      
        
    end
    
    file:close()
    
    pyPath = path.."ReaperWwiseImport\\ReaperWwiseImport.exe"
    
    os.execute(pyPath)
    
    os.remove(path..fileName)
   
    
end
------------------------------------------------------------
function saved()

    _, prjPath = reaper.EnumProjects( -1 )
    sep = "\\"
           
    if prjPath ~= "" then
            
        prjPath = prjPath:match("(.*"..sep..")")
        sfxPath = prjPath..defaultRenderPath
        
        return true
    else
        display = reaper.ShowMessageBox("You need to save the project to execute this script.", "File Export", 1)
             --return
        if display == 1 then
         
            reaper.Main_OnCommand(40022, 0) -- SAVE AS PROJECT
            
        return saved()
        end
    end
    
end

function wwiseSetup()

    importWwise = true
    --GUI.Val("Subpr", {false} )
    

   
    originalCommonStruct = ""
    wwiseStruct = GUI.Val("Structure")
    wwisePreText={}
    wwiseName = {}
    wwiseStructArray ={}
    origStructArray={}
    stName = ""

    if saved() then
    
        setRenderOptions() 
    else
        return
    end
    
    
end
--------------------------------------------------------------------------------------------------------------------------------

function resetProjSettings()

    reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , origTailLenght, true )
    reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,origRenderSetting, true ) --set 2nd pass render
    reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG" ,origTailFlag, true ) --set tail active
    reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , origNmChannel, true ) --set numebr of channels
    reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,origRanderName, true )
    reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,origBounds, true ) 
    reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , origRenderFormat, true )
    reaper.GetSetProjectInfo_String( 0, "RENDER_FILE" , origPath, true )
    reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", origImport, true )
end



--MAIN
reaper.ClearConsole()


item = reaper.GetSelectedMediaItem(0, 0)
importWwise = false
if item then 
    tk = reaper.GetActiveTake(item)
    if tk then 

        default_text = ""

    else    
    
      
        _, text = reaper.GetSetMediaItemInfo_String( item, "P_NOTES","",false )
        
        if text == "" then
        
            default_text = ""
        else
            default_text = "@"
        end
   
    end
end




--save render existing render settings

origTailLenght = reaper.GetSetProjectInfo( 0, "RENDER_TAILMS" , 0, false )
origRenderSetting = reaper.GetSetProjectInfo( 0, "RENDER_SETTINGS" ,0, false ) --set 2nd pass render
origBounds = reaper.GetSetProjectInfo( 0, "RENDER_BOUNDSFLAG" ,0, false )
origTailFlag = reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG " ,0, false ) --set tail active
origNmChannel = reaper.GetSetProjectInfo( 0, "RENDER_CHANNELS" , 0, false ) --set numebr of channels
_,origRanderName = reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN" ,"", false )
_, origRenderFormat = reaper.GetSetProjectInfo_String( 0, "RENDER_FORMAT" , "", false )
origImport = reaper.GetSetProjectInfo( 0, "RENDER_ADDTOPROJ", 0, false )
_,origPath = reaper.GetSetProjectInfo_String( 0, "RENDER_FILE", 0, false )


-- Script generated by Lokasenna's GUI Builder
local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

loadfile(lib_path .. "Core.lua")()



GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Button.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "Render Groups"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 600, 200
GUI.anchor, GUI.corner = "screen", "C"


--GUI first part END
--Start script code


--override of function in core.lua
GUI.Main_Update_State = function()

    -- Update mouse and keyboard state, window dimensions
    if GUI.mouse.x ~= gfx.mouse_x or GUI.mouse.y ~= gfx.mouse_y then

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y
        GUI.mouse.x, GUI.mouse.y = gfx.mouse_x, gfx.mouse_y

        -- Hook for user code
        if GUI.onmousemove then GUI.onmousemove() end

    else

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y

    end
    GUI.mouse.wheel = gfx.mouse_wheel
    GUI.mouse.cap = gfx.mouse_cap
    GUI.char = gfx.getchar()
  
  if GUI.char == 13 and GUI.ReturnSubmit then GUI.ReturnSubmit() end   ---ADDED
  

    if GUI.cur_w ~= gfx.w or GUI.cur_h ~= gfx.h then
        GUI.cur_w, GUI.cur_h = gfx.w, gfx.h

        GUI.resized = true

        -- Hook for user code
        if GUI.onresize then GUI.onresize() end

    else
        GUI.resized = false
    end

    --  (Escape key)  (Window closed)    (User function says to close)
    --if GUI.char == 27 or GUI.char == -1 or GUI.quit == true then
    if (GUI.char == 27 and not (  GUI.mouse.cap & 4 == 4
                                or   GUI.mouse.cap & 8 == 8
                                or   GUI.mouse.cap & 16 == 16
                                or  GUI.escape_bypass))
            or GUI.char == -1
            or GUI.quit == true then

        GUI.cleartooltip()
        return 0
    else
        if GUI.char == 27 and GUI.escape_bypass then GUI.escape_bypass = "close" end
        reaper.defer(GUI.Main)
    end

end

--override of function in textbox.class
function GUI.Textbox:new(name, z, x, y, w, h, caption, pad)

  local txt = (not x and type(z) == "table") and z or {}

  txt.name = name
  txt.type = "Textbox"

  txt.z = txt.z or z

  txt.x = txt.x or x
    txt.y = txt.y or y
    txt.w = txt.w or w
    txt.h = txt.h or h

    txt.retval = txt.retval or ""

  txt.caption = txt.caption or caption or ""
  txt.pad = txt.pad or pad or 4

    if txt.shadow == nil then
        txt.shadow = true
    end
  txt.bg = txt.bg or "wnd_bg"
  txt.color = txt.color or "txt"

  txt.font_a = txt.font_a or 3

  txt.font_b = txt.font_b or "monospace"

    txt.cap_pos = txt.cap_pos or "left"

    txt.undo_limit = txt.undo_limit or 20

    txt.undo_states = {}
    txt.redo_states = {}

    txt.wnd_pos = 0
    if group == true then
          txt.caret = string.len(default_text)
    else
          txt.caret = 0
    end
  txt.sel_s, txt.sel_e = nil, nil

    txt.char_h, txt.wnd_h, txt.wnd_w, txt.char_w = nil, nil, nil, nil

  txt.focus = false

  txt.blink = 0
  GUI.redraw_z[txt.z] = true

  setmetatable(txt, self)
  self.__index = self
  return txt

end

GUI.Main = function ()
    xpcall( function ()

        if GUI.Main_Update_State() == 0 then return end

        GUI.Main_Update_Elms()

        -- If the user gave us a function to run, check to see if it needs to be
        -- run again, and do so.
        if GUI.func then

            local new_time = reaper.time_precise()
            if new_time - GUI.last_time >= (GUI.freq or 1) then
                GUI.func()
                GUI.last_time = new_time

            end
        end
        
        -- Maintain a list of elms and zs in case any have been moved or deleted
        GUI.update_elms_list()
        local val = gfx.getchar(65536)
        if val == 7 then
            scriptFocus = true
        else
            scriptFocus = false
        end
        

        GUI.Main_Draw()

    end, GUI.crash)
end


GUI.IsInside = function (elm, x, y)

    if not elm then return false end

    local x, y = x or GUI.mouse.x, y or GUI.mouse.y

    return  (  x >= (elm.x or 0) and x < ((elm.x or 0) + (elm.w or 0)) and
                y >= (elm.y or 0) and y < ((elm.y or 0) + (elm.h or 0))  )

end



--  See if the any of the given element's methods need to be called
GUI.Update = function (elm)

    local x, y = GUI.mouse.x, GUI.mouse.y
    local x_delta, y_delta = x-GUI.mouse.lx, y-GUI.mouse.ly
    local wheel = GUI.mouse.wheel
    local inside = GUI.IsInside(elm, x, y)

    local skip = elm:onupdate() or false

    if GUI.resized then elm:onresize() end

    if GUI.elm_updated then
        if elm.focus then
            elm.focus = false
            elm:lostfocus()
        end
        skip = true
    end
    
    if scriptFocus == false then
        if elm.focus then
              elm.focus = false
              elm:lostfocus()
        end
    end

    if skip then return end

    -- Left button
    if GUI.mouse.cap&1==1 then
          
        -- If it wasn't down already...
        if not GUI.mouse.last_down then


            -- Was a different element clicked?
            if not inside then
      
                if GUI.mouse_down_elm == elm then
                    -- Should already have been reset by the mouse-up, but safeguard...
                    GUI.mouse_down_elm = nil
                end
                if elm.focus then
                    elm.focus = false
                    elm:lostfocus()
                end
                return 0
            else
                if GUI.mouse_down_elm == nil then -- Prevent click-through
                    
                    GUI.mouse_down_elm = elm

                    -- Double clicked?
                    if GUI.mouse.downtime
                    and reaper.time_precise() - GUI.mouse.downtime < 0.10
                    then

                        GUI.mouse.downtime = nil
                        GUI.mouse.dbl_clicked = true
                        elm:ondoubleclick()

                    elseif not GUI.mouse.dbl_clicked then

                        elm.focus = true
                        elm:onmousedown()

                    end

                    GUI.elm_updated = true
                end

                GUI.mouse.down = true
                GUI.mouse.ox, GUI.mouse.oy = x, y

                -- Where in the elm the mouse was clicked. For dragging stuff
                -- and keeping it in the place relative to the cursor.
                GUI.mouse.off_x, GUI.mouse.off_y = x - elm.x, y - elm.y

            end

        --     Dragging? Did the mouse start out in this element?
        elseif (x_delta ~= 0 or y_delta ~= 0)
        and     GUI.mouse_down_elm == elm then

            if elm.focus ~= false then

                GUI.elm_updated = true
                elm:ondrag(x_delta, y_delta)

            end
        end

    -- If it was originally clicked in this element and has been released
    elseif GUI.mouse.down and GUI.mouse_down_elm.name == elm.name then

            GUI.mouse_down_elm = nil

            if not GUI.mouse.dbl_clicked then elm:onmouseup() end

            GUI.elm_updated = true
            GUI.mouse.down = false
            GUI.mouse.dbl_clicked = false
            GUI.mouse.ox, GUI.mouse.oy = -1, -1
            GUI.mouse.off_x, GUI.mouse.off_y = -1, -1
            GUI.mouse.lx, GUI.mouse.ly = -1, -1
            GUI.mouse.downtime = reaper.time_precise()


    end


    -- Right button
    if GUI.mouse.cap&2==2 then

        -- If it wasn't down already...
        if not GUI.mouse.last_r_down then

            -- Was a different element clicked?
            if not inside then
                if GUI.rmouse_down_elm == elm then
                    -- Should have been reset by the mouse-up, but in case...
                    GUI.rmouse_down_elm = nil
                end
                --elm.focus = false
            else

                -- Prevent click-through
                if GUI.rmouse_down_elm == nil then

                    GUI.rmouse_down_elm = elm

                        -- Double clicked?
                    if GUI.mouse.r_downtime
                    and reaper.time_precise() - GUI.mouse.r_downtime < 0.20
                    then

                        GUI.mouse.r_downtime = nil
                        GUI.mouse.r_dbl_clicked = true
                        elm:onr_doubleclick()

                    elseif not GUI.mouse.r_dbl_clicked then

                        elm:onmouser_down()

                    end

                    GUI.elm_updated = true

                end

                GUI.mouse.r_down = true
                GUI.mouse.r_ox, GUI.mouse.r_oy = x, y
                -- Where in the elm the mouse was clicked. For dragging stuff
                -- and keeping it in the place relative to the cursor.
                GUI.mouse.r_off_x, GUI.mouse.r_off_y = x - elm.x, y - elm.y

            end


        --     Dragging? Did the mouse start out in this element?
        elseif (x_delta ~= 0 or y_delta ~= 0)
        and     GUI.rmouse_down_elm == elm then

            if elm.focus ~= false then

                elm:onr_drag(x_delta, y_delta)
                GUI.elm_updated = true

            end

        end

    -- If it was originally clicked in this element and has been released
    elseif GUI.mouse.r_down and GUI.rmouse_down_elm.name == elm.name then

        GUI.rmouse_down_elm = nil

        if not GUI.mouse.r_dbl_clicked then elm:onmouser_up() end

        GUI.elm_updated = true
        GUI.mouse.r_down = false
        GUI.mouse.r_dbl_clicked = false
        GUI.mouse.r_ox, GUI.mouse.r_oy = -1, -1
        GUI.mouse.r_off_x, GUI.mouse.r_off_y = -1, -1
        GUI.mouse.r_lx, GUI.mouse.r_ly = -1, -1
        GUI.mouse.r_downtime = reaper.time_precise()

    end



    -- Middle button
    if GUI.mouse.cap&64==64 then


        -- If it wasn't down already...
        if not GUI.mouse.last_m_down then


            -- Was a different element clicked?
            if not inside then
                if GUI.mmouse_down_elm == elm then
                    -- Should have been reset by the mouse-up, but in case...
                    GUI.mmouse_down_elm = nil
                end
            else
                -- Prevent click-through
                if GUI.mmouse_down_elm == nil then

                    GUI.mmouse_down_elm = elm

                    -- Double clicked?
                    if GUI.mouse.m_downtime
                    and reaper.time_precise() - GUI.mouse.m_downtime < 0.20
                    then

                        GUI.mouse.m_downtime = nil
                        GUI.mouse.m_dbl_clicked = true
                        elm:onm_doubleclick()

                    else

                        elm:onmousem_down()

                    end

                    GUI.elm_updated = true

              end

                GUI.mouse.m_down = true
                GUI.mouse.m_ox, GUI.mouse.m_oy = x, y
                GUI.mouse.m_off_x, GUI.mouse.m_off_y = x - elm.x, y - elm.y

            end



        --     Dragging? Did the mouse start out in this element?
        elseif (x_delta ~= 0 or y_delta ~= 0)
        and     GUI.mmouse_down_elm == elm then

            if elm.focus ~= false then

                elm:onm_drag(x_delta, y_delta)
                GUI.elm_updated = true

            end

        end

    -- If it was originally clicked in this element and has been released
    elseif GUI.mouse.m_down and GUI.mmouse_down_elm.name == elm.name then

        GUI.mmouse_down_elm = nil

        if not GUI.mouse.m_dbl_clicked then elm:onmousem_up() end

        GUI.elm_updated = true
        GUI.mouse.m_down = false
        GUI.mouse.m_dbl_clicked = false
        GUI.mouse.m_ox, GUI.mouse.m_oy = -1, -1
        GUI.mouse.m_off_x, GUI.mouse.m_off_y = -1, -1
        GUI.mouse.m_lx, GUI.mouse.m_ly = -1, -1
        GUI.mouse.m_downtime = reaper.time_precise()

    end



    -- If the mouse is hovering over the element
    if inside and not GUI.mouse.down and not GUI.mouse.r_down then
        elm:onmouseover()

        -- Initial mouseover an element
        if GUI.mouseover_elm ~= elm then
            GUI.mouseover_elm = elm
            GUI.mouseover_time = reaper.time_precise()

        -- Mouse was moved; reset the timer
        elseif x_delta > 0 or y_delta > 0 then

            GUI.mouseover_time = reaper.time_precise()

        -- Display a tooltip
        elseif (reaper.time_precise() - GUI.mouseover_time) >= GUI.tooltip_time then

            GUI.settooltip(elm.tooltip)

        end
        --elm.mouseover = true
    else
        --elm.mouseover = false

    end


    -- If the mousewheel's state has changed
    if inside and GUI.mouse.wheel ~= GUI.mouse.lwheel then

        GUI.mouse.inc = (GUI.mouse.wheel - GUI.mouse.lwheel) / 120

        elm:onwheel(GUI.mouse.inc)
        GUI.elm_updated = true
        GUI.mouse.lwheel = GUI.mouse.wheel

    end

    -- If the element is in focus and the user typed something
    if elm.focus and GUI.char ~= 0 then
        elm:ontype()
        GUI.elm_updated = true
    end

end




--Start GUI second part

GUI.New("Single", "Checklist", {
    z = 11,
    x = 495,
    y = 100,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Single file"},
    dir = "v",
    pad = 1,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = true,
    opt_size = 20
})

GUI.New("Subpr", "Checklist", {
    z = 11,
    x = 495,
    y = 122,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"SubPrj"},
    dir = "v",
    pad = 1,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = true,
    opt_size = 20
})

GUI.New("TimeSel", "Checklist", {
    z = 11,
    x = 495,
    y = 78,
    w = 70,
    h = 20,
    caption = "",
    optarray = {"Time Selection"},
    dir = "v",
    pad = 1,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = true,
    opt_size = 20
    
})



GUI.New("Checklist1", "Radio", {
    z = 11,
    x = 144,
    y = 78,
    w = 65,
    h = 45,
    caption = "",
    optarray = {"Tail", "2nd pass"},
    dir = "v",
    pad = 0,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = true,
    swap = nil,
    opt_size = 20
})

GUI.New("Render", "Button", {
    z = 11,
    x = 150,
    y = 130,
    w = 128,
    h = 30,
    caption = "Render",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = setRenderOptions
    
})

GUI.New("Transfer", "Button", {
    z = 11,
    x = 300,
    y = 130,
    w = 128,
    h = 30,
    caption = "Transfer in Wwise",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = wwiseSetup
    
})

GUI.New("Channels", "Menubox", {
    z = 11,
    x = 64,
    y = 78,
    w = 65,
    h = 20,
    caption = "Channels",
    optarray = {"Mono", "Stereo", "Quad", "5.1"},
    retval = 2,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_cap = "txt",
    bg = "wnd_bg",
    pad = 4,
    noarrow = false,
    align = 0
})

GUI.New("TextboxTail", "Textbox", {
    z = 11,
    x = 210,
    y = 78,
    w = 50,
    h = 20,
    caption = "Lenght (s)",
    cap_pos = "right",
    font_a = 4,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    
    pad = 4,
    undo_limit = 20
})

GUI.New("TextboxName", "Textbox", {
    
    z = 11,
    x = 64,
    y = 46,
    w = 500,
    h = 20,
    caption = "Name",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    
    
})

GUI.New("Structure", "Textbox", {
    
    z = 11,
    x = 64,
    y = 16,
    w = 500,
    h = 20,
    caption = "Wwise",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    
    
})

GUI.Init()
GUI.Main()

GUI.Val("TextboxTail", userTailLenght)
GUI.elms.TextboxName.focus = true
if user2ndpass == true then
    GUI.Val("Checklist1", 2)
else  
    GUI.Val("Checklist1", 1)
end


GUI.Val("Subpr", {subproj} )


GUI.Val("Single", {userSingleFile})
GUI.Val("Import", {userImport})
if userChannels == "stereo" then
    GUI.Val("Channels", 2)
elseif userChannels == "mono" then
    GUI.Val("Channels", 1)
elseif userChannels == "5.1" then
    GUI.Val("Channels", 4)
elseif userChannels == "quad" then
    GUI.Val("Channels", 3)
end


GUI.Val("TextboxName",default_text)
GUI.ReturnSubmit = setRenderOptions

if default_text ~= nil then
GUI.elms.TextboxName.focus = true
GUI.elms.TextboxName.sel_s = 0
GUI.elms.TextboxName.sel_e = string.len(default_text)
GUI.elms.TextboxName.caret = string.len(default_text)
end
      
      
      
      
