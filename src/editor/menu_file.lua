-- authors: Lomtik Software (J. Winwood & John Labenski)
-- Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------
local ide = ide
local frame = ide.frame
local menuBar = frame.menuBar
local notebook = frame.notebook
local openDocuments = ide.openDocuments

local fileMenu = wx.wxMenu({
    { ID_NEW, TR("&New")..KSC(ID_NEW), TR("Create an empty document") },
    { ID_OPEN, TR("&Open...")..KSC(ID_OPEN), TR("Open an existing document") },
    { ID_CLOSE, TR("&Close Page")..KSC(ID_CLOSE), TR("Close the current editor window") },
    { },
    { ID_SAVE, TR("&Save")..KSC(ID_SAVE), TR("Save the current document") },
    { ID_SAVEAS, TR("Save &As...")..KSC(ID_SAVEAS), TR("Save the current document to a file with a new name") },
    { ID_SAVEALL, TR("Save A&ll")..KSC(ID_SAVEALL), TR("Save all open documents") },
    { },
    -- placeholder for ID_RECENTFILES
    { },
    { ID_EXIT, TR("E&xit")..KSC(ID_EXIT), TR("Exit program") }})
menuBar:Append(fileMenu, TR("&File"))

local filehistorymenu = wx.wxMenu({})
local filehistory = wx.wxMenuItem(fileMenu, ID_RECENTFILES,
  TR("Recent Files")..KSC(ID_RECENTFILES), TR("File history"), wx.wxITEM_NORMAL, filehistorymenu)
fileMenu:Insert(8,filehistory)

local function loadRecent(event)
  local item = filehistorymenu:FindItem(event:GetId())
  local filename = item:GetLabel()
  if not LoadFile(filename, nil, true) then
    wx.wxMessageBox(
      TR("File '%s' no longer exists."):format(filename),
      GetIDEString("editormessage"),
      wx.wxOK + wx.wxCENTRE, ide.frame)
    filehistorymenu:Delete(item)
  end
end

local function updateRecentFiles(list)
  local items = filehistorymenu:GetMenuItemCount()
  for i=1, #list do
    local file = list[i].filename
    local id = ID("file.recentfiles."..i)
    if i <= items then -- this is an existing item; update the label
      filehistorymenu:FindItem(id):SetItemLabel(file)
    else -- need to add an item
      local item = wx.wxMenuItem(filehistorymenu, id, file, "")
      filehistorymenu:Append(item)
      frame:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, loadRecent)
    end
  end
  for i=items, #list+1, -1 do -- delete the rest if the list got shorter
    filehistorymenu:Delete(filehistorymenu:FindItemByPosition(i-1))
  end
end

frame:Connect(ID_RECENTFILES, wx.wxEVT_UPDATE_UI,
  function (event) updateRecentFiles(GetFileHistory()) end)

frame:Connect(ID_NEW, wx.wxEVT_COMMAND_MENU_SELECTED, NewFile)
frame:Connect(ID_OPEN, wx.wxEVT_COMMAND_MENU_SELECTED, OpenFile)
frame:Connect(ID_SAVE, wx.wxEVT_COMMAND_MENU_SELECTED,
  function ()
    local editor = GetEditor()
    SaveFile(editor, openDocuments[editor:GetId()].filePath)
  end)
frame:Connect(ID_SAVE, wx.wxEVT_UPDATE_UI,
  function (event)
    event:Enable(EditorIsModified(GetEditor()))
  end)

frame:Connect(ID_SAVEAS, wx.wxEVT_COMMAND_MENU_SELECTED,
  function ()
    SaveFileAs(GetEditor())
  end)
frame:Connect(ID_SAVEAS, wx.wxEVT_UPDATE_UI,
  function (event)
    event:Enable(GetEditor() ~= nil)
  end)

frame:Connect(ID_SAVEALL, wx.wxEVT_COMMAND_MENU_SELECTED,
  function (event)
    SaveAll()
  end)
frame:Connect(ID_SAVEALL, wx.wxEVT_UPDATE_UI,
  function (event)
    local atLeastOneModifiedDocument = false
    for id, document in pairs(openDocuments) do
      if document.isModified or not document.filePath then
        atLeastOneModifiedDocument = true
        break
      end
    end
    event:Enable(atLeastOneModifiedDocument)
  end)

frame:Connect(ID_CLOSE, wx.wxEVT_COMMAND_MENU_SELECTED,
  function (event)
    ClosePage() -- this will find the current editor tab
  end)
frame:Connect(ID_CLOSE, wx.wxEVT_UPDATE_UI,
  function (event)
    event:Enable(GetEditor() ~= nil)
  end)

frame:Connect(ID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED,
  function (event)
    if not SaveOnExit(true) then return end
    frame:Close() -- this will trigger wxEVT_CLOSE_WINDOW
  end)
