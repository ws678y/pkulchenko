return {
  name = "Lua Debug",
  description = "Commandline Lua interpreter",
  api = {"wxwidgets","baselib"},
  frun = function(self,wfilename,rundebug)
    local mainpath = string.gsub(ide.editorFilename:gsub("[^/\\]+$",""),"\\","/")
    local filepath = string.gsub(wfilename:GetFullPath(), "\\","/")
    local script
    if rundebug then
      DebuggerAttachDefault()
      script = (""..
        "package.path=package.path..';"..mainpath.."lualibs/?/?.lua';"..
        "package.cpath=package.cpath..';"..mainpath.."bin/clibs/?.dll';"..
        "require 'mobdebug'; io.stdout:setvbuf('no'); mobdebug.loop('" .. wx.wxGetHostName().."',"..ide.debugger.portnumber..")")
    else
      script = ([[dofile '%s']]):format(filepath)
    end
    local code = ([[xpcall(function() %s end,function(err) print(debug.traceback(err)) end)]]):format(script)
    local cmd = '"'..mainpath..'bin/lua.exe" -e "'..code..'"'
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,false)
  end,
  fprojdir = function(self,wfilename)
    return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
  end,
  fworkdir = function (self,wfilename)
    return ide.config.path.projectdir
    or wfilename:GetPath(wx.wxPATH_GET_VOLUME)
  end,
  hasdebugger = true,
  fattachdebug = function(self)
    DebuggerAttachDefault()
  end,
}
