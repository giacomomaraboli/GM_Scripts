-- @description Sub project new version
-- @author Giacomo Maraboli
-- @version 1.0
-- @about
--   create a new version of a sub project and insert it as a new take

reaper.ClearConsole()
reaper.PreventUIRefresh(1)

--open subproject
reaper.Main_OnCommand(41816,0)
--save as new version

reaper.Main_OnCommand(41895,0)


nameSub = reaper.GetProjectName( 0 )

--close subproject
reaper.Main_OnCommand(40860,0)

--duplicate active take
reaper.Main_OnCommand(40639,0)





item = reaper.GetSelectedMediaItem(0, 0)
take = reaper.GetActiveTake(item)
 _, origName = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME" , "", false )
 
 
 _,_ = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME" , nameSub, true )
source = reaper.GetMediaItemTake_Source(take)
file_path = reaper.GetMediaSourceFileName(source)

newPath = string.gsub(file_path, origName, nameSub)

--new = "C:\\Users\\giacomom\\Desktop\\script testing\\script testing\\Audio files\\Cinematics_1.rpp"


reaper.BR_SetTakeSourceFromFile( take,newPath , true )
--os.rename(file_path, new_file_path)

--open subproject
    reaper.Main_OnCommand(41816,0)

--render subproject
    reaper.Main_OnCommand(42332,0)

--close subproject
    reaper.Main_OnCommand(40860,0)
    



reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
