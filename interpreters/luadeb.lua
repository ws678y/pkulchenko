local exe

local function exePath()
  local mainpath = ide.editorFilename:gsub("[^/\\]+$","")
  local macExe = mainpath..'bin/lua.app/Contents/MacOS/lua'
  return ide.config.path.lua or
        (ide.osname == "Windows" and mainpath..[[bin\lua.exe]]
     or (ide.osname == "Unix" and mainpath..([[bin/linux/%s/lua]]):format(ide.osarch))
     or (wx.wxFileExists(macExe) and macExe or mainpath..[[bin/lua]]))
end

return {
  name = "Lua",
  description = "Lua interpreter with debugger",
  api = {"wxwidgets","baselib"},
  frun = function(self,wfilename,rundebug)
    exe = exe or exePath()
    local filepath = wfilename:GetFullPath()
    if rundebug then
      DebuggerAttachDefault({runstart = ide.config.debugger.runonstart == true})
    else
      -- if running on Windows and can't open the file, this may mean that
      -- the file path includes unicode characters that need special handling
      local fh = io.open(filepath, "r")
      if fh then fh:close() end
      if ide.osname == 'Windows' and pcall(require, "winapi")
      and wfilename:FileExists() and not fh then
        winapi.set_encoding(winapi.CP_UTF8)
        filepath = winapi.short_path(filepath)
      end
    end
    local code = rundebug
      and ([[-e "io.stdout:setvbuf('no'); %s"]]):format(rundebug)
       or ([[-e "io.stdout:setvbuf('no')" "%s"]]):format(filepath)
    local cmd = '"'..exe..'" '..code
    -- CommandLineRun(cmd,wdir,tooutput,nohide,stringcallback,uid,endcallback)
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,false,nil,nil,
      function() ide.debugger.pid = nil end)
  end,
  fprojdir = function(self,wfilename)
    return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
  end,
  fworkdir = function (self,wfilename)
    return ide.config.path.projectdir or wfilename:GetPath(wx.wxPATH_GET_VOLUME)
  end,
  hasdebugger = true,
  fattachdebug = function(self) DebuggerAttachDefault() end,
  scratchextloop = false,
  unhideanywindow = true,
}
