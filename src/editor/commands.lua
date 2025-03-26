-- authors: Lomtik Software (J. Winwood & John Labenski)
-- Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------
local ide = ide
local frame = ide.frame
local notebook = frame.notebook
local openDocuments = ide.openDocuments
local uimgr = frame.uimgr

function NewFile(event)
  local editor = CreateEditor(ide.config.default.fullname)
  SetupKeywords(editor, "lua")
end

-- Find an editor page that hasn't been used at all, eg. an untouched NewFile()
local function findDocumentToReuse()
  local editor = nil
  for id, document in pairs(openDocuments) do
    if (document.editor:GetLength() == 0) and
    (not document.isModified) and (not document.filePath) and
    not (document.editor:GetReadOnly() == true) then
      editor = document.editor
      break
    end
  end
  return editor
end

function LoadFile(filePath, editor, file_must_exist)
  -- prevent files from being reopened again
  if (not editor) then
    local filePath = wx.wxFileName(filePath)
    for id, doc in pairs(openDocuments) do
      if doc.filePath and filePath:SameAs(wx.wxFileName(doc.filePath)) then
        notebook:SetSelection(doc.index)
        return doc.editor
      end
    end
  end
  filePath = wx.wxFileName(filePath):GetFullPath()

  -- if not opened yet, try open now
  local file_text = FileRead(filePath)
  if file_text then
    if GetConfigIOFilter("input") then
      file_text = GetConfigIOFilter("input")(filePath,file_text)
    end
  elseif file_must_exist then
    return nil
  end

  local current = editor and editor:GetCurrentPos()
  editor = editor
    or findDocumentToReuse()
    or CreateEditor(wx.wxFileName(filePath):GetFullName()
      or ide.config.default.fullname)

  editor:Clear()
  editor:ClearAll()
  SetupKeywords(editor, GetFileExt(filePath))
  editor:MarkerDeleteAll(BREAKPOINT_MARKER)
  editor:MarkerDeleteAll(CURRENT_LINE_MARKER)
  editor:AppendText(file_text)
  if current then editor:GotoPos(current) end
  if (ide.config.editor.autotabs) then
    local found = string.find(file_text,"\t") ~= nil
    editor:SetUseTabs(found)
  end

  editor:EmptyUndoBuffer()
  local id = editor:GetId()
  openDocuments[id].filePath = filePath
  openDocuments[id].fileName = wx.wxFileName(filePath):GetFullName()
  openDocuments[id].modTime = GetFileModTime(filePath)
  SetDocumentModified(id, false)
  editor:Colourise(0, -1)

  IndicateFunctions(editor)

  SettingsAppendFileToHistory(filePath)

  -- activate the editor; this is needed for those cases when the editor is
  -- created from some other element, for example, from a project tree.
  SetEditorSelection()

  return editor
end

local function getExtsString()
  local knownexts = ""
  for i,spec in pairs(ide.specs) do
    if (spec.exts) then
      for n,ext in ipairs(spec.exts) do
        knownexts = knownexts.."*."..ext..";"
      end
    end
  end
  knownexts = knownexts:len() > 0 and knownexts:sub(1,-2) or nil

  local exts = knownexts and "Known Files ("..knownexts..")|"..knownexts.."|" or ""
  exts = exts.."All files (*)|*"

  return exts
end

function OpenFile(event)

  local exts = getExtsString()

  local fileDialog = wx.wxFileDialog(ide.frame, "Open file",
    "",
    "",
    exts,
    wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST)
  if fileDialog:ShowModal() == wx.wxID_OK then
    if not LoadFile(fileDialog:GetPath(), nil, true) then
      wx.wxMessageBox("Unable to load file '"..fileDialog:GetPath().."'.",
        "Error",
        wx.wxOK + wx.wxCENTRE, ide.frame)
    end
  end
  fileDialog:Destroy()
end

-- save the file to filePath or if filePath is nil then call SaveFileAs
function SaveFile(editor, filePath)
  if not filePath then
    return SaveFileAs(editor)
  else
    if (ide.config.savebak) then FileRename(filePath, filePath..".bak") end

    local st = editor:GetText()
    if GetConfigIOFilter("output") then
      st = GetConfigIOFilter("output")(filePath,st)
    end

    local ok, err = FileWrite(filePath, st)
    if ok then
      editor:SetSavePoint()
      local id = editor:GetId()
      openDocuments[id].filePath = filePath
      openDocuments[id].fileName = wx.wxFileName(filePath):GetFullName()
      openDocuments[id].modTime = GetFileModTime(filePath)
      SetDocumentModified(id, false)
      return true
    else
      wx.wxMessageBox("Unable to save file '"..filePath.."': "..err,
        "Error",
        wx.wxICON_ERROR + wx.wxOK + wx.wxCENTRE, ide.frame)
    end
  end

  return false
end

function SaveFileAs(editor)
  local id = editor:GetId()
  local saved = false
  local filePath = openDocuments[id].filePath
  if (not filePath) then
    filePath = FileTreeGetDir()
    filePath = (filePath or "")..ide.config.default.name
  end

  local fn = wx.wxFileName(filePath)
  fn:Normalize() -- want absolute path for dialog

  local exts = getExtsString()

  local fileDialog = wx.wxFileDialog(ide.frame, "Save file as",
    fn:GetPath(wx.wxPATH_GET_VOLUME),
    fn:GetFullName(),
    exts,
    wx.wxFD_SAVE)

  if fileDialog:ShowModal() == wx.wxID_OK then
    local filePath = fileDialog:GetPath()

    if SaveFile(editor, filePath) then
      SetEditorSelection() -- update title of the editor
      FileTreeRefresh() -- refresh the tree to reflect the new file
      FileTreeMarkSelected(filePath)
      SetupKeywords(editor, GetFileExt(filePath))
      IndicateFunctions(editor)
      if MarkupStyle then MarkupStyle(editor) end
      saved = true
    end
  end

  fileDialog:Destroy()
  return saved
end

function SaveAll()
  for id, document in pairs(openDocuments) do
    local editor = document.editor
    local filePath = document.filePath

    if document.isModified then
      SaveFile(editor, filePath) -- will call SaveFileAs if necessary
    end
  end
end

local function removePage(index)
  local prevIndex = nil
  local nextIndex = nil
  
  -- try to preserve old selection
  local selectIndex = notebook:GetSelection()
  selectIndex = selectIndex ~= index and selectIndex

  local delid = nil
  for id, document in pairsSorted(openDocuments,
    function(a, b) -- sort by document index
      return openDocuments[a].index < openDocuments[b].index
    end) do
    local wasselected = document.index == selectIndex
    if document.index < index then
      prevIndex = document.index
    elseif document.index == index then
      delid = id
      document.editor:Destroy()
    elseif document.index > index then
      document.index = document.index - 1
      if nextIndex == nil then
        nextIndex = document.index
      end
    end
    if (wasselected) then
      selectIndex = document.index
    end
  end

  if (delid) then
    openDocuments[delid] = nil
  end

  notebook:RemovePage(index)
  
  if selectIndex then
    notebook:SetSelection(selectIndex)
  elseif nextIndex then
    notebook:SetSelection(nextIndex)
  elseif prevIndex then
    notebook:SetSelection(prevIndex)
  end

  SetEditorSelection() -- will use notebook GetSelection to update
end

function ClosePage(selection)
  local editor = GetEditor(selection)
  local id = editor:GetId()
  if SaveModifiedDialog(editor, true) ~= wx.wxID_CANCEL then
    DynamicWordsRemoveAll(editor)
    local debugger = ide.debugger
    -- check if the window with the scratchpad running is being closed
    if debugger and debugger.scratchpad and debugger.scratchpad.editor == editor then
      DebuggerScratchpadOff()
    end
    -- check if the debugger is running and is using the current window
    -- abort the debugger if the current marker is in the window being closed
    -- also abort the debugger if it is running, as we don't know what
    -- window will need to be activated when the debugger is paused
    if debugger and debugger.pid and
      (debugger.running or editor:MarkerNext(0, CURRENT_LINE_MARKER_VALUE) >= 0) then
      debugger.terminate()
    end
    removePage(ide.openDocuments[id].index)
  end
end

-- Show a dialog to save a file before closing editor.
-- returns wxID_YES, wxID_NO, or wxID_CANCEL if allow_cancel
function SaveModifiedDialog(editor, allow_cancel)
  local result = wx.wxID_NO
  local id = editor:GetId()
  local document = openDocuments[id]
  local filePath = document.filePath
  local fileName = document.fileName
  if document.isModified then
    local message = "Do you want to save the changes to '"
      ..(fileName or ide.config.default.name).."'?"
    local dlg_styles = wx.wxYES_NO + wx.wxCENTRE + wx.wxICON_QUESTION
    if allow_cancel then dlg_styles = dlg_styles + wx.wxCANCEL end
    local dialog = wx.wxMessageDialog(ide.frame, message,
      "Save Changes?",
      dlg_styles)
    result = dialog:ShowModal()
    dialog:Destroy()
    if result == wx.wxID_YES then
      if not SaveFile(editor, filePath) then
        return wx.wxID_CANCEL -- cancel if canceled save dialog
      end
    end
  end

  return result
end

function SaveOnExit(allow_cancel)
  for id, document in pairs(openDocuments) do
    if (SaveModifiedDialog(document.editor, allow_cancel) == wx.wxID_CANCEL) then
      return false
    end
  end

  -- if all documents have been saved or refused to save, then mark those that
  -- are still modified as not modified (they don't need to be saved)
  -- to keep their tab names correct
  for id, document in pairs(openDocuments) do
    if document.isModified then SetDocumentModified(id, false) end
  end

  return true
end

function FoldSome()
  local editor = GetEditor()
  editor:Colourise(0, -1) -- update doc's folding info
  local visible, baseFound, expanded, folded
  for ln = 2, editor.LineCount - 1 do
    local foldRaw = editor:GetFoldLevel(ln)
    local foldLvl = math.mod(foldRaw, 4096)
    local foldHdr = math.mod(math.floor(foldRaw / 8192), 2) == 1
    if not baseFound and (foldLvl == wxstc.wxSTC_FOLDLEVELBASE) then
      baseFound = true
      visible = editor:GetLineVisible(ln)
    end
    if foldHdr then
      if editor:GetFoldExpanded(ln) then
        expanded = true
      else
        folded = true
      end
    end
    if expanded and folded and baseFound then break end
  end
  local show = not visible or (not baseFound and expanded) or (expanded and folded)
  local hide = visible and folded

  if show then
    editor:ShowLines(1, editor.LineCount-1)
  end

  for ln = 1, editor.LineCount - 1 do
    local foldRaw = editor:GetFoldLevel(ln)
    local foldLvl = math.mod(foldRaw, 4096)
    local foldHdr = math.mod(math.floor(foldRaw / 8192), 2) == 1
    if show then
      if foldHdr then
        if not editor:GetFoldExpanded(ln) then editor:ToggleFold(ln) end
      end
    elseif hide and (foldLvl == wxstc.wxSTC_FOLDLEVELBASE) then
      if not foldHdr then
        editor:HideLines(ln, ln)
      end
    elseif foldHdr then
      if editor:GetFoldExpanded(ln) then
        editor:ToggleFold(ln)
      end
    end
  end
  editor:EnsureCaretVisible()
end

function EnsureRangeVisible(posStart, posEnd)
  local editor = GetEditor()
  if posStart > posEnd then
    posStart, posEnd = posEnd, posStart
  end

  local lineStart = editor:LineFromPosition(posStart)
  local lineEnd = editor:LineFromPosition(posEnd)
  for line = lineStart, lineEnd do
    editor:EnsureVisibleEnforcePolicy(line)
  end
end

function SetAllEditorsReadOnly(enable)
  for id, document in pairs(openDocuments) do
    local editor = document.editor
    editor:SetReadOnly(enable)
  end
end

-----------------
-- Debug related

function ClearAllCurrentLineMarkers()
  for id, document in pairs(openDocuments) do
    local editor = document.editor
    editor:MarkerDeleteAll(CURRENT_LINE_MARKER)
  end
end

function CompileProgram(editor, quiet)
  -- remove shebang line (#!) as it throws a compilation error as
  -- loadstring() doesn't allow it even though lua/loadfile accepts it.
  -- replace with a new line to keep the number of lines the same.
  local editorText = editor:GetText():gsub("^#!.-\n", "\n")
  local id = editor:GetId()
  local filePath = DebuggerMakeFileName(editor, openDocuments[id].filePath)
  local _, errMsg, line_num = wxlua.CompileLuaScript(editorText, filePath)

  if ide.frame.menuBar:IsChecked(ID_CLEAROUTPUT) then ClearOutput() end

  if line_num > -1 then
    DisplayOutput("Compilation error on line "..tostring(line_num)..":\n"..
      errMsg:gsub("Lua:.-\n", "").."\n")
    if not quiet then editor:GotoLine(line_num-1) end
  else
    if not quiet then DisplayOutput("Compilation successful.\n") end
  end

  return line_num == -1 -- return true if it compiled ok
end

------------------
-- Save & Close

function SaveIfModified(editor)
  local id = editor:GetId()
  if openDocuments[id].isModified then
    local saved = false
    if not openDocuments[id].filePath then
      local ret = wx.wxMessageBox("You must save the program before running it.\nPress cancel to abort running.",
        "Save file?", wx.wxOK + wx.wxCANCEL + wx.wxCENTRE, ide.frame)
      if ret == wx.wxOK then
        saved = SaveFileAs(editor)
      end
    else
      saved = SaveFile(editor, openDocuments[id].filePath)
    end

    if saved then
      openDocuments[id].isModified = false
    else
      return false -- not saved
    end
  end

  return true -- saved
end

function GetOpenFiles()
  local opendocs = {}
  for id, document in pairs(ide.openDocuments) do
    if (document.filePath) then
      local wxfname = wx.wxFileName(document.filePath)
      wxfname:Normalize()

      table.insert(opendocs,{fname=wxfname:GetFullPath(),id=document.index,
          cursorpos = document.editor:GetCurrentPos()})
    end
  end

  -- to keep tab order
  table.sort(opendocs,function(a,b) return (a.id < b.id) end)

  local openfiles = {}
  for i,doc in ipairs(opendocs) do
    table.insert(openfiles,{filename = doc.fname, cursorpos = doc.cursorpos} )
  end

  local id = GetEditor()
  id = id and id:GetId()

  return openfiles, id and openDocuments[id].index or 0
end

function SetOpenFiles(nametab,index)
  for i,doc in ipairs(nametab) do
    local editor = LoadFile(doc.filename,nil,true)
    if editor then
      editor:SetCurrentPos(doc.cursorpos or 0)
      editor:SetSelectionStart(doc.cursorpos or 0)
      editor:SetSelectionEnd(doc.cursorpos or 0)
      editor:EnsureCaretVisible()
    end
  end
  notebook:SetSelection(index or 0)
end

local beforeFullScreenPerspective
function ShowFullScreen(setFullScreen)
  if setFullScreen then
    beforeFullScreenPerspective = uimgr:SavePerspective()
    uimgr:GetPane("bottomnotebook"):Show(false)
    uimgr:GetPane("projpanel"):Show(false)
    SetEditorSelection() -- make sure the focus is on the editor
  elseif beforeFullScreenPerspective then
    uimgr:LoadPerspective(beforeFullScreenPerspective)
    beforeFullScreenPerspective = nil
  end

  uimgr:GetPane("toolBar"):Show(not setFullScreen)
  uimgr:Update()
  -- protect from systems that don't have ShowFullScreen (GTK on linux?)
  pcall(function() frame:ShowFullScreen(setFullScreen) end)
end

function CloseWindow(event)
  ide.exitingProgram = true -- don't handle focus events

  if not SaveOnExit(event:CanVeto()) then
    event:Veto()
    ide.exitingProgram = false
    return
  end

  ShowFullScreen(false)
  SettingsSaveProjectSession(FileTreeGetProjects())
  SettingsSaveFileSession(GetOpenFiles())
  SettingsSaveView()
  SettingsSaveFramePosition(ide.frame, "MainFrame")
  SettingsSaveEditorSettings()
  if DebuggerCloseWatchWindow then DebuggerCloseWatchWindow() end
  if DebuggerCloseStackWindow then DebuggerCloseStackWindow() end
  if DebuggerShutdown then DebuggerShutdown() end
  ide.settings:delete() -- always delete the config
  event:Skip()

  -- without explicit exit() the IDE crashes with SIGILL exception when closed
  -- on MacOS compiled under 64bit with wxwidgets 2.9.3
  if ide.osname == "Macintosh" then os.exit() end
end
frame:Connect(wx.wxEVT_CLOSE_WINDOW, CloseWindow)
