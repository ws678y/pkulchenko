-- authors: Lomtik Software (J. Winwood & John Labenski)
-- Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------
local ide = ide
local frame = ide.frame
local notebook = frame.notebook
local bottomnotebook = frame.bottomnotebook
local errorlog = bottomnotebook.errorlog

-------
-- setup errorlog
errorlog:Show(true)
errorlog:SetFont(ide.ofont)
errorlog:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, ide.ofont)
errorlog:StyleClearAll()
errorlog:SetMarginWidth(1, 16) -- marker margin
errorlog:SetMarginType(1, wxstc.wxSTC_MARGIN_SYMBOL);
errorlog:MarkerDefine(CURRENT_LINE_MARKER, wxstc.wxSTC_MARK_ARROWS, wx.wxBLACK, wx.wxWHITE)
errorlog:SetReadOnly(true)
StylesApplyToEditor(ide.config.stylesoutshell,errorlog,ide.ofont,ide.ofontItalic)

function ClearOutput()
  local current = errorlog:GetReadOnly()
  errorlog:SetReadOnly(false)
  errorlog:ClearAll()
  errorlog:SetReadOnly(current)
end

function DisplayOutputNoMarker(...)
  local message = ""
  local cnt = select('#',...)
  for i=1,cnt do
    local v = select(i,...)
    message = message..tostring(v)..(i<cnt and "\t" or "")
  end

  local current = errorlog:GetReadOnly()
  errorlog:SetReadOnly(false)
  errorlog:AppendText(message)
  errorlog:SetReadOnly(current)
  errorlog:GotoPos(errorlog:GetLength())
end
function DisplayOutput(...)
  errorlog:MarkerAdd(errorlog:GetLineCount()-1, CURRENT_LINE_MARKER)
  DisplayOutputNoMarker(...)
end

local streamins = {}
local streamerrs = {}
local streamouts = {}
local customprocs = {}
local textout = '' -- this is a buffer for any text sent to external scripts

function CommandLineRunning(uid)
  for pid,custom in pairs(customprocs) do
    if (custom.uid == uid and custom.proc and custom.proc.Exists(tonumber(tostring(pid))) )then
      return true
    end
  end

  return false
end

function CommandLineToShell(uid,state)
  for pid,custom in pairs(customprocs) do
    if ((pid == uid or custom.uid == uid) and custom.proc and custom.proc.Exists(tonumber(tostring(pid))) )then
      if (streamins[pid]) then streamins[pid].toshell = state end
      if (streamerrs[pid]) then streamerrs[pid].toshell = state end
      return true
    end
  end
end

-- logic to "unhide" wxwidget window using winapi
pcall(function () return require 'winapi' end)
local pid = nil
local function unHideWxWindow(pidAssign)
  -- skip if not configured to do anything
  if not ide.config.unhidewxwindow then return end
  if pidAssign then
    pid = pidAssign > 0 and pidAssign or nil
  end
  if pid and winapi then
    local win = winapi.find_window_ex(function(w)
      return w:get_process():get_pid() == pid
         and w:get_class_name() == 'wxWindowClassNR'
    end)
    if win and not win:is_visible() then
      win:show()
      notebook:SetFocus() -- set focus back to the IDE window
      pid = nil
    end
  end
end

local function nameTab(tab, name)
  local index = bottomnotebook:GetPageIndex(tab)
  if index then bottomnotebook:SetPageText(index, name) end
end

function CommandLineRun(cmd,wdir,tooutput,nohide,stringcallback,uid,endcallback)
  if (not cmd) then return end

  local exename = string.gsub(cmd, "\\", "/")
  exename = string.match(exename,'%/*([^%/]+%.%w+)') or exename
  exename = string.match(exename,'%/*([^%/]+%.%w+)[%s%"]') or exename

  uid = uid or exename

  if (CommandLineRunning(uid)) then
    DisplayOutput("Conflicting process still running: "..cmd.."\n")
    return
  end

  DisplayOutput("Running program: "..cmd.."\n")

  local proc = nil
  local customproc

  if (tooutput) then
    customproc = wx.wxProcess(errorlog)
    customproc:Redirect()

    proc = customproc
  end

  -- manipulate working directory
  local oldcwd
  if (wdir) then
    oldcwd = wx.wxFileName.GetCwd()
    oldcwd = wx.wxFileName.SetCwd(wdir) and oldcwd
  end

  -- launch process
  local pid = (proc
    and wx.wxExecute(cmd, wx.wxEXEC_ASYNC + (nohide and wx.wxEXEC_NOHIDE or 0),proc)
     or wx.wxExecute(cmd, wx.wxEXEC_ASYNC + (nohide and wx.wxEXEC_NOHIDE or 0)))

  if (oldcwd) then
    wx.wxFileName.SetCwd(oldcwd)
  end

  -- For asynchronous execution, he return value is the process id and
  -- zero value indicates that the command could not be executed.
  -- The return value of -1 in this case indicates that we didn't launch
  -- a new process, but connected to the running one (e.g. DDE under Windows).
  if not pid or pid == -1 or pid == 0 then
    DisplayOutput("Unable to run program: "..cmd.."\n")
    customproc = nil
    return
  else
    DisplayOutput(
      "Process: "..uid..", pid:"..tostring(pid)..
      ", started in '"..(wdir and wdir or wx.wxFileName.GetCwd()).."'\n")
    customprocs[pid] = {proc=customproc, uid=uid, endcallback=endcallback}
  end

  local streamin = proc and proc:GetInputStream()
  local streamerr = proc and proc:GetErrorStream()
  local streamout = proc and proc:GetOutputStream()
  if (streamin) then
    streamins[pid] = {stream=streamin, callback=stringcallback}
  end
  if (streamerr) then
    streamerrs[pid] = {stream=streamerr, callback=stringcallback}
  end
  if (streamout) then
    streamouts[pid] = {stream=streamout, callback=stringcallback, out=true}
  end

  unHideWxWindow(pid)
  nameTab(errorlog, "Output (running)")

  return pid
end

local function getStreams()
  local function readStream(tab)
    for _,v in pairs(tab) do
      while(v.stream:CanRead()) do
        local str = v.stream:Read(4096)
        local pfn
        if (v.callback) then
          str,pfn = v.callback(str)
        end
        if (v.toshell) then
          DisplayShell(str)
        else
          DisplayOutputNoMarker(str)
        end
        if str and ide.config.allowinteractivescript and errorlog:GetReadOnly() then
          ActivateOutput()
          errorlog:SetReadOnly(false)
          errorlog:SetFocus()
        end
        pfn = pfn and pfn()
      end
    end
  end
  local function sendStream(tab)
    local str = textout
    if not str then return end
    textout = nil
    str = str .. "\n"
    for _,v in pairs(tab) do
      local pfn
      if (v.callback) then
        str,pfn = v.callback(str)
      end
      v.stream:Write(str, #str)
      pfn = pfn and pfn()
    end
  end

  readStream(streamins)
  readStream(streamerrs)
  sendStream(streamouts)
end

errorlog:Connect(wx.wxEVT_END_PROCESS, function(event)
    local pid = event:GetPid()
    if (pid ~= -1) then
      getStreams()
      -- make errorlog readonly again if needed
      if not errorlog:GetReadOnly() then
        errorlog:SetReadOnly(true)
        GetEditor():SetFocus()
      end
      nameTab(errorlog, "Output")

      streamins[pid] = nil
      streamerrs[pid] = nil
      streamouts[pid] = nil
      if (customprocs[pid].endcallback) then
        customprocs[pid].endcallback()
      end
      customprocs[pid] = nil
      unHideWxWindow(0)
      DebuggerStop()
      DisplayOutput("Program finished (pid: "..pid..").\n")
    end
  end)

errorlog:Connect(wx.wxEVT_IDLE, function(event)
    if (#streamins or #streamerrs) then
      getStreams()
    end
    unHideWxWindow()
  end)

local jumptopatterns = {
  -- <filename>(line,linepos):
  "%s*([%w:/%\\_%-%.]+)%((%d+),(%d+)%)%s*:",
  -- <filename>(line):
  "%s*([%w:/%\\_%-%.]+)%((%d+).*%)%s*:",
  -- <filename>:line:
  "%s*([%w:/%\\_%-%.]+):(%d+)%s*:",
  --[string "<filename>"]:line:
  '.*%[string "([%w:/%\\_%-%.]+)"%]:(%d+)%s*:',
}

errorlog:Connect(wxstc.wxEVT_STC_DOUBLECLICK,
  function(event)
    local line = errorlog:GetCurrentLine()
    local linetx = errorlog:GetLine(line)
    -- try to detect a filename + line
    -- in linetx

    local fname
    local jumpline
    local jumplinepos

    for _,pattern in ipairs(jumptopatterns) do
      fname,jumpline,jumplinepos = linetx:match(pattern)
      if (fname and jumpline) then
        break
      end
    end

    if (fname and jumpline) then
      LoadFile(fname,nil,true)
      local editor = GetEditor()
      if (editor) then
        jumpline = tonumber(jumpline)
        jumplinepos = tonumber(jumplinepos)

        --editor:ScrollToLine(jumpline)
        editor:GotoPos(editor:PositionFromLine(math.max(0,jumpline-1)) + (jumplinepos and (math.max(0,jumplinepos-1)) or 0))
        editor:SetFocus()
      end
    end
  end)

local function getInputLine() return errorlog:GetLineCount()-1 end
local function getInputText()
  return errorlog:GetTextRange(
    errorlog:PositionFromLine(getInputLine()), errorlog:GetLength())
end
local function positionInLine(line)
  return errorlog:GetCurrentPos() - errorlog:PositionFromLine(line)
end
local function caretOnInputLine(disallowLeftmost)
  local inputLine = getInputLine()
  local boundary = disallowLeftmost and 0 or -1
  return (errorlog:GetCurrentLine() > inputLine
    or errorlog:GetCurrentLine() == inputLine
   and positionInLine(inputLine) > boundary)
end

errorlog:Connect(wx.wxEVT_KEY_DOWN,
  function (event)
    -- this loop is only needed to allow to get to the end of function easily
    -- "return" aborts the processing and ignores the key
    -- "break" aborts the processing and processes the key normally
    while true do
      -- no special processing if it's readonly
      if errorlog:GetReadOnly() then break end

      local key = event:GetKeyCode()
      if key == wx.WXK_UP or key == wx.WXK_NUMPAD_UP then
        return -- don't go up
      elseif key == wx.WXK_DOWN or key == wx.WXK_NUMPAD_DOWN then
        break -- can go down
      elseif key == wx.WXK_LEFT or key == wx.WXK_NUMPAD_LEFT then
        if not caretOnInputLine(true) then return end
      elseif key == wx.WXK_BACK then
        if not caretOnInputLine(true) then return end
      elseif key == wx.WXK_DELETE or key == wx.WXK_NUMPAD_DELETE then
        if not caretOnInputLine()
        or errorlog:LineFromPosition(errorlog:GetSelectionStart()) < getInputLine() then
          return
        end
      elseif key == wx.WXK_PAGEUP or key == wx.WXK_NUMPAD_PAGEUP
          or key == wx.WXK_PAGEDOWN or key == wx.WXK_NUMPAD_PAGEDOWN
          or key == wx.WXK_END or key == wx.WXK_NUMPAD_END
          or key == wx.WXK_HOME or key == wx.WXK_NUMPAD_HOME
          or key == wx.WXK_RIGHT or key == wx.WXK_NUMPAD_RIGHT
          or key == wx.WXK_SHIFT or key == wx.WXK_CONTROL
          or key == wx.WXK_ALT then
        break
      elseif key == wx.WXK_RETURN or key == wx.WXK_NUMPAD_ENTER then
        if not caretOnInputLine()
        or errorlog:LineFromPosition(errorlog:GetSelectionStart()) < getInputLine() then
          return
        end
        textout = (textout or '').. getInputText(-1)
        break -- don't need to do anything else with return
      else
        -- move cursor to end if not already there
        if not caretOnInputLine() then
          errorlog:GotoPos(errorlog:GetLength())
        -- check if the selection starts before the input line and reset it
        elseif errorlog:LineFromPosition(errorlog:GetSelectionStart()) < getInputLine(-1) then
          errorlog:GotoPos(errorlog:GetLength())
          errorlog:SetSelection(errorlog:GetSelectionEnd()+1,errorlog:GetSelectionEnd())
        end
      end
      break
    end
    event:Skip()
  end)
