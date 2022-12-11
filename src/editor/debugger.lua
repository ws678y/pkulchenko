-- Integration with MobDebug
-- Copyright Paul Kulchenko 2011
-- Original authors: Lomtik Software (J. Winwood & John Labenski)
--          Luxinia Dev (Eike Decker & Christoph Kubisch)

local copas  = require "copas"
local socket = require "socket"
local mobdebug = require "mobdebug"

local ide = ide
local debugger = ide.debugger
debugger.server     = nil    -- DebuggerServer object when debugging, else nil
debugger.running    = false  -- true when the debuggee is running
debugger.listening  = false  -- true when the debugger is listening for a client
debugger.portnumber = 8171   -- the port # to use for debugging
debugger.watchWindow      = nil    -- the watchWindow, nil when not created
debugger.watchListCtrl    = nil    -- the child listctrl in the watchWindow

local notebook = ide.frame.vsplitter.splitter.notebook

local function ActivateDocument(fileName, line)
	if not wx.wxIsAbsolutePath(fileName) then
		fileName = wx.wxGetCwd().."/"..fileName
	end

	if wx.__WXMSW__ then
		fileName = wx.wxUnix2DosFilename(fileName)
	end

	local fileFound = false
	for id, document in pairs(ide.openDocuments) do
		local editor   = document.editor
		-- for running in cygwin, use same type of separators
		filePath = string.gsub(document.filePath, "\\", "/")
		local fileName = string.gsub(fileName, "\\", "/")
		if string.upper(filePath) == string.upper(fileName) then
			local selection = document.index
			notebook:SetSelection(selection)
			SetEditorSelection(selection)
			editor:MarkerAdd(line-1, CURRENT_LINE_MARKER)
			editor:EnsureVisibleEnforcePolicy(line-1)
			fileFound = true
			break
		end
	end

	return fileFound
end

local function updateWatches()
	local watchListCtrl = debugger.watchListCtrl
	if watchListCtrl and debugger.server and not debugger.running then
		copas.addthread(function ()
			for idx = 0, watchListCtrl:GetItemCount() - 1 do
				local expression = watchListCtrl:GetItemText(idx)
				local value = debugger.evaluate(expression)
				watchListCtrl:SetItem(idx, 1, value)
			end
		end)
	end
end

debugger.shell = function(expression)
	if debugger.server and not debugger.running then
		copas.addthread(function ()
			local value, _, err = debugger.handle('eval ' .. expression)
			if err ~= nil then value, _, err = debugger.handle('exec ' .. expression) end
			if err then DisplayShellErr(err)
						 else DisplayShell(value)
			end
		end)
	end
end

debugger.listen = function() 
	local server = socket.bind("*", debugger.portnumber)
	DisplayOutput("Started debugger server; clients can connect to "..wx.wxGetHostName()..":"..debugger.portnumber..".\n")
	copas.autoclose = false
	copas.addserver(server, function (skt)
		debugger.server = copas.wrap(skt)
		SetAllEditorsReadOnly(true)
		local editor = GetEditor()
		local filePath = ide.openDocuments[editor:GetId()].filePath;
		debugger.basedir = string.gsub(wx.wxFileName(filePath):GetPath(wx.wxPATH_GET_VOLUME), "\\", "/")

		-- load the remote file into the debugger
		-- set basedir first, before loading to make sure that the path is correct
		debugger.handle("basedir " .. debugger.basedir)
		debugger.handle("load " .. filePath)

		-- remove all breakpoints that may still be present from the last session
		-- this only matters for those remote clients that reload scripts 
		-- without resetting their breakpoints
		debugger.handle("delallb")

		-- go over all windows and find all breakpoints
		for id, document in pairs(ide.openDocuments) do
			local editor   = document.editor
			local filePath = string.gsub(document.filePath, "\\", "/")
			line = editor:MarkerNext(0, BREAKPOINT_MARKER_VALUE)
			while line ~= -1 do
				debugger.handle("setb " .. filePath .. " " .. (line+1))
				line = editor:MarkerNext(line + 1, BREAKPOINT_MARKER_VALUE)
			end
		end
		
		local line = 1
		editor:MarkerAdd(line-1, CURRENT_LINE_MARKER)
		editor:EnsureVisibleEnforcePolicy(line-1)

		ShellSupportRemote(debugger.shell, 0)

		DisplayOutput("Started remote debugging session (base directory: " .. debugger.basedir .. "/).\n")
	end)
	debugger.listening = true
end

debugger.handle = function(line)
	local _G = _G
	local os = os
	os.exit = function () end
	_G.print = function () end

	debugger.running = true
	local file, line, err = mobdebug.handle(line, debugger.server)
	debugger.running = false

	return file, line, err
end

debugger.exec = function(command)
	if debugger.server and not debugger.running then
		copas.addthread(function ()
			while true do
				local file, line, err = debugger.handle(command)
				if line == nil then
					debugger.server = nil
					SetAllEditorsReadOnly(false)
					ShellSupportRemote(nil, 0)
					if err then DisplayOutput(err .. "\n") end
					DisplayOutput("Completed debugging session.\n")
					return
				else
					if debugger.basedir and not wx.wxIsAbsolutePath(file) then
						file = debugger.basedir .. "/" .. file
					end
					if ActivateDocument(file, line) then 
						updateWatches()
						return 
					else 
						command = "out" -- redo now trying to get out of this file
					end
				end 
			end
		end)
	end
end

debugger.updateBreakpoint = function(command)
  if debugger.server and not debugger.running then
    copas.addthread(function ()
      debugger.handle(command)
    end)
  end
end

debugger.update = function() copas.step(0) end
debugger.terminate = function() debugger.exec("exit") end
debugger.step = function() debugger.exec("step") end
debugger.over = function() debugger.exec("over") end
debugger.out = function() debugger.exec("out") end
debugger.run = function() debugger.exec("run") end
debugger.evaluate = function(expression) return debugger.handle('eval ' .. expression) end
debugger.breaknow = function() DisplayOutput("Not Yet Implemented\n") end
debugger.breakpoint = function(file, line, state)
  debugger.updateBreakpoint((state and "setb " or "delb ") .. file .. " " .. line)
end

----------------------------------------------
-- public api

function DebuggerDefaultAttach()
	debugger.listen()
end

function DebuggerCreateStackWindow()
	DisplayOutput("Not Yet Implemented\n")
end

function DebuggerCloseStackWindow()

end

function DebuggerCloseWatchWindow()
	if (debugger.watchWindow) then
		SettingsSaveFramePosition(debugger.watchWindow, "WatchWindow")
		debugger.watchListCtrl = nil
		debugger.watchWindow = nil
	end
end

function DebuggerCreateWatchWindow()
	local width = 200
	local watchWindow = wx.wxFrame(ide.frame, wx.wxID_ANY, 
			"Watch Window",
			wx.wxDefaultPosition, wx.wxSize(width, 160), 
			wx.wxDEFAULT_FRAME_STYLE + wx.wxFRAME_FLOAT_ON_PARENT)

	debugger.watchWindow = watchWindow

	local watchMenu = wx.wxMenu{
			{ ID_ADDWATCH,      "&Add Watch"        },
			{ ID_EDITWATCH,     "&Edit Watch\tF2"   },
			{ ID_REMOVEWATCH,   "&Remove Watch"     },
			{ ID_EVALUATEWATCH, "Evaluate &Watches" }}

	local watchMenuBar = wx.wxMenuBar()
	watchMenuBar:Append(watchMenu, "&Watches")
	watchWindow:SetMenuBar(watchMenuBar)

	local watchListCtrl = wx.wxListCtrl(watchWindow, ID_WATCH_LISTCTRL,
					  wx.wxDefaultPosition, wx.wxDefaultSize,
					  wx.wxLC_REPORT + wx.wxLC_EDIT_LABELS)
								  
	debugger.watchListCtrl = watchListCtrl

	local info = wx.wxListItem()
	info:SetMask(wx.wxLIST_MASK_TEXT + wx.wxLIST_MASK_WIDTH)
	info:SetText("Expression")
	info:SetWidth(width * 0.45)
	watchListCtrl:InsertColumn(0, info)

	info:SetText("Value")
	info:SetWidth(width * 0.45)
	watchListCtrl:InsertColumn(1, info)

	watchWindow:CentreOnParent()
	SettingsRestoreFramePosition(watchWindow, "WatchWindow")
	watchWindow:Show(true)

	local function findSelectedWatchItem()
		local count = watchListCtrl:GetSelectedItemCount()
		if count > 0 then
			for idx = 0, watchListCtrl:GetItemCount() - 1 do
				if watchListCtrl:GetItemState(idx, wx.wxLIST_STATE_FOCUSED) ~= 0 then
					return idx
				end
			end
		end
		return -1
	end

	watchWindow:Connect( wx.wxEVT_CLOSE_WINDOW,
			function (event)
				DebuggerCloseWatchWindow()
				watchWindow = nil
				watchListCtrl = nil
				event:Skip()
			end)

	watchWindow:Connect(ID_ADDWATCH, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local row = watchListCtrl:InsertItem(watchListCtrl:GetItemCount(), "Expr")
				watchListCtrl:SetItem(row, 0, "Expr")
				watchListCtrl:SetItem(row, 1, "Value")
				watchListCtrl:EditLabel(row)
			end)

	watchWindow:Connect(ID_EDITWATCH, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local row = findSelectedWatchItem()
				if row >= 0 then
					watchListCtrl:EditLabel(row)
				end
			end)
	watchWindow:Connect(ID_EDITWATCH, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(watchListCtrl:GetSelectedItemCount() > 0)
			end)

	watchWindow:Connect(ID_REMOVEWATCH, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local row = findSelectedWatchItem()
				if row >= 0 then
					watchListCtrl:DeleteItem(row)
				end
			end)
	watchWindow:Connect(ID_REMOVEWATCH, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(watchListCtrl:GetSelectedItemCount() > 0)
			end)

	watchWindow:Connect(ID_EVALUATEWATCH, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				updateWatches()
			end)
	watchWindow:Connect(ID_EVALUATEWATCH, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(watchListCtrl:GetItemCount() > 0)
			end)

	watchListCtrl:Connect(wx.wxEVT_COMMAND_LIST_END_LABEL_EDIT,
			function (event)
				watchListCtrl:SetItem(event:GetIndex(), 0, event:GetText())
				updateWatches()
				event:Skip()
			end)
end

function DebuggerMakeFileName(editor, filePath)
	if not filePath then
		filePath = "file"..tostring(editor)
	end
	return filePath
end

function DebuggerToggleBreakpoint(editor, line)
	local markers = editor:MarkerGet(line)
	if markers >= CURRENT_LINE_MARKER_VALUE then
		markers = markers - CURRENT_LINE_MARKER_VALUE
	end
	local id       = editor:GetId()
	local filePath = DebuggerMakeFileName(editor, ide.openDocuments[id].filePath)
	if markers >= BREAKPOINT_MARKER_VALUE then
		editor:MarkerDelete(line, BREAKPOINT_MARKER)
		if debugger.server then
			debugger.breakpoint(filePath, line+1, false)
		end
	else
		editor:MarkerAdd(line, BREAKPOINT_MARKER)
		if debugger.server then
			debugger.breakpoint(filePath, line+1, true)
		end
	end
end
