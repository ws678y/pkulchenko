-- ---------------------------------------------------------------------------
-- Create the Debug menu and attach the callback functions


--debugger.server     = nil    -- wxLuaDebuggerServer object when debugging, else nil
--debugger.server_    = nil    -- temp wxLuaDebuggerServer object for deletion
--debugger.running    = false  -- true when the debuggee is running
--debugger.destroy    = 0      -- > 0 if the debugger is to be destroyed in wxEVT_IDLE
--debugger.pid        = 0      -- pid of the debuggee process
--debugger.portnumber = 1551   -- the port # to use for debugging

local frame    = ide.frame
local menuBar  = frame.menuBar
local vsplitter= frame.vsplitter
local sidenotebook = vsplitter.sidenotebook
local splitter = vsplitter.splitter
local errorlog = splitter.bottomnotebook.errorlog
local notebook = splitter.notebook

local openDocuments = ide.openDocuments
local debugger 		= ide.debugger
local filetree      = ide.filetree

--------------
-- Interpreters

local interpreters = {
	--[=[
	[] = {
		name = "",
		description = "",
		fcmdline = function(filepath) end,
		fpath = function(fname) end,
		capture = false,
		workdir = function (filepath) end,
	},
	]=]
	
	[ID "debug.interpreter.Lua"] = {
		name = "Lua",
		description = "Pure lua interpreter",
		fcmdline = function(filepath) 
				return '"lua" '..(filepath or "")
			end,
		fprojdir = function(fname) 
				return fname:GetPath(wx.wxPATH_GET_VOLUME)
			end,
		capture = false,
		fworkdir = function (filepath) return filepath and filepath:gsub("[\\/]+$","") end,
	},
	[ID "debug.interpreter.Luxinia"] = {
		name = "Luxinia",
		description = "Luxinia project",
		fcmdline = function(filepath) 
				local endstr = ide.config.path.projectdir and ide.config.path.projectdir:len()>0
							and " -p "..ide.config.path.projectdir or ""
				
				return ide.config.path.luxinia..'luxinia.exe --nologo'..endstr
			end,
		fworkdir = function() end, -- doesn't matter
		capture = true,
		fprojdir = function(fname)
				local path = GetPathWithSep(fname)
				fname = wx.wxFileName(path)
				
				while ((not wx.wxFileExists(path.."main.lua")) and (fname:GetDirCount() > 0)) do
					fname:RemoveDir(fname:GetDirCount()-1)
					path = GetPathWithSep(fname)
				end
				
				return path:sub(0,-2)
			end,
	},
	[ID "debug.interpreter.EstrelaEditor"] = {
		name = "Estrela Editor",
		description = "Estrela Editor as run target (IDE development)",
		fcmdline = function(filepath) 
				return editorFilename and '"'..ide.editorFilename..'" '..iff(menuBar:IsChecked(ID_USECONSOLE), " -c ", "")..(filepath or "") or nil
			end,
		fprojdir = function(fname)
				return fname:GetPath(wx.wxPATH_GET_VOLUME)
			end,
		fworkdir = function() end, -- better not
		capture = false,
	},
}

local debugMenu = wx.wxMenu{
		{ ID_TOGGLEBREAKPOINT, "Toggle &Breakpoint\tF9", "Toggle Breakpoint" },
		{ },
		{ ID_COMPILE,          "&Compile\tF7",           "Test compile the Lua program" },
		{ ID_RUN,              "&Run\tF6",               "Execute the current file" },
		{ ID_ATTACH_DEBUG,     "&Attach\tShift-F6",      "Allow a client to start a debugging session" },
		{ ID_START_DEBUG,      "&Start Debugging\tShift-F5", "Start a debugging session" },
		{ ID_USECONSOLE,       "Console",               "Use console when running",  wx.wxITEM_CHECK },
		{ },
		{ ID_STOP_DEBUG,       "S&top Debugging\tShift-F12", "Stop and end the debugging session" },
		{ ID_STEP,             "St&ep\tF11",             "Step into the next line" },
		{ ID_STEP_OVER,        "Step &Over\tShift-F11",  "Step over the next line" },
		{ ID_STEP_OUT,         "Step O&ut\tF8",          "Step out of the current function" },
		{ ID_CONTINUE,         "Co&ntinue\tF5",          "Run the program at full speed" },
		{ ID_BREAK,            "&Break\tF12",            "Stop execution of the program at the next executed line of code" },
		{ },
		{ ID_VIEWCALLSTACK,    "V&iew Call Stack",       "View the LUA call stack" },
		{ ID_VIEWWATCHWINDOW,  "View &Watches",          "View the Watch window" },
		{ },
		{ ID_SHOWFILETREE,     "View &FileTree Window",  "View or Hide the filetree window" },
		{ ID_SHOWHIDEWINDOW,   "View &Output Window\tF8", "View or Hide the output window" },
		{ ID_CLEAROUTPUT,      "C&lear Output Window",    "Clear the output window before compiling or debugging", wx.wxITEM_CHECK },
		{},
		--{ }, { ID_DEBUGGER_PORT,    "Set debugger socket port...", "Chose what port to use for debugger sockets." }
		}

local targetargs = {}
for id,inter in pairs(interpreters) do
	table.insert(targetargs,{id,inter.name,inter.description,wx.wxITEM_CHECK})
end
local target = wx.wxMenu{
		unpack(targetargs)
	}
	
local targetworkdir = wx.wxMenu{
		{ID "debug.projectdir.choose","Choose ..."},
		{ID "debug.projectdir.fromfile","From current filepath"},
		{},
		{ID "debug.projectdir.currentdir",""}
	}

debugMenu:Append(0,"Lua &interpreter",target,"Set the interpreter to be used")
debugMenu:Append(0,"Project directory",targetworkdir,"Set the project directory to be used")
menuBar:Append(debugMenu, "&Project")
menuBar:Check(ID_USECONSOLE, true)

function UpdateProjectDir(projdir)
	ide.config.path.projectdir = projdir
	menuBar:SetLabel(ID "debug.projectdir.currentdir",projdir)
	frame:SetStatusText(projdir)
	ide.filetree:UpdateProjectDir(projdir)
end
UpdateProjectDir(ide.config.path.projectdir)

-- interpreter setup
local curinterpreterid = 	IDget("debug.interpreter."..ide.config.interpreter)  or 
							ID "debug.interpreter.EstrelaEditor"
							
	menuBar:Check(curinterpreterid, true)
	
	local function selectInterpreter (id)
		for id,inter in pairs(interpreters) do
			menuBar:Check(id, false)
		end
		menuBar:Check(id, true)
		curinterpreterid = id
	end
	
	local function evSelectInterpreter (event)
		local chose = event:GetId()
		selectInterpreter(chose)
	end
	
	for id,inter in pairs(interpreters) do
		frame:Connect(id,wx.wxEVT_COMMAND_MENU_SELECTED,evSelectInterpreter)
	end

local function projChoose(event)
	local editor = GetEditor()
	local id       = editor:GetId()
	local saved    = false
	local fn       = wx.wxFileName(openDocuments[id].filePath or "")
	fn:Normalize() -- want absolute path for dialog
	
	local projectdir = ide.config.path.projectdir
	
	--filePicker:Show(true)
	--local diag = wx.wxDialog()
	--diag:ShowModal(true)
	local filePicker = wx.wxDirDialog(frame, "Chose a project directory", 
			projectdir~="" and projectdir or wx.wxGetCwd(),wx.wxFLP_USE_TEXTCTRL)
	local res = filePicker:ShowModal(true)
	--for i,v in pairs(wx) do if v == res then print(i) end end
	--print(res)
	if res == wx.wxID_OK then
		UpdateProjectDir(filePicker:GetPath())
	end
	--filePicker:Destroy()
	return true
end
	
frame:Connect(ID "debug.projectdir.choose", wx.wxEVT_COMMAND_MENU_SELECTED,
	projChoose)
frame:Connect(ID "debug.projectdir.choose", wx.wxEVT_COMMAND_BUTTON_CLICKED,
	projChoose)
		
local function projFromFile(event)
	local editor = GetEditor()
	if not editor then return end
	local id       = editor:GetId()
	local filepath = openDocuments[id].filePath	
	if not filepath then return end
	local fn       = wx.wxFileName(filepath)
	fn:Normalize() -- want absolute path for dialog
	
	UpdateProjectDir(interpreters[curinterpreterid].fprojdir(fn))
end
frame:Connect(ID "debug.projectdir.fromfile", wx.wxEVT_COMMAND_MENU_SELECTED,
	projFromFile)
	
frame:Connect(ID_TOGGLEBREAKPOINT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			local line = editor:LineFromPosition(editor:GetCurrentPos())
			ToggleDebugMarker(editor, line)
		end)
frame:Connect(ID_TOGGLEBREAKPOINT, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)


frame:Connect(ID_COMPILE, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			CompileProgram(editor)
		end)
frame:Connect(ID_COMPILE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)


frame:Connect(ID_RUN, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			-- SaveAll()

			local editor = GetEditor()
			
			-- test compile it before we run it, if successful then ask to save
			-- only compile if lua api
			if (editor.spec.apitype and editor.spec.apitype == "lua" and 
								not CompileProgram(editor)) then
				return
			end
			if not SaveIfModified(editor) then
				return
			end
			
			local id = editor:GetId();
			local filepath = openDocuments[id].filePath
			local interpreter = interpreters[curinterpreterid]
			local cmd = interpreter.fcmdline(filepath)
			if (not cmd) then
				return
			end
			
			local wdir = interpreter.fworkdir(filepath)
			local capture = interpreter.capture
			local projectdir = ide.config.path.projectdir
			DisplayOutput("Running program: "..cmd.." in "..projectdir.."\n")
			--local cwd = wx.wxGetCwd()
			--wx.wxFileName().SetCwd(projectdir)
			
			RunCommandLine(cmd,wdir,capture)
			--wx.wxFileName().SetCwd(cwd)

		end)
frame:Connect(ID_RUN, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server == nil) and (editor ~= nil))
		end)

frame:Connect(ID_ATTACH_DEBUG, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local ok = false
			debugger.server = wxlua.wxLuaDebuggerServer(debugger.portnumber)
			if debugger.server then
				ok = debugger.server:StartServer()
			end
			if ok then
				DisplayOutput("Waiting for client connect. Start client with wxLua -d"..wx.wxGetHostName()..":"..debugger.portnumber.."\n")
			else
				DisplayOutput("Unable to create debugger server.\n")
			end
			NextDebuggerPort()
		end)
frame:Connect(ID_ATTACH_DEBUG, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server == nil) and (editor ~= nil))
		end)

frame:Connect(wx.wxEVT_IDLE,
		function(event)

			if (debugger.destroy > 0) then
				debugger.destroy = debugger.destroy + 1
			end

			if (debugger.destroy == 5) then
				-- stop the server and let it end gracefully
				debugger.running = false
				debugger.server_:StopServer()
			end
			if (debugger.destroy == 10) then
				-- delete the server and let it die gracefully
				debugger.running = false
				debugger.server_:delete()
			end
			if (debugger.destroy > 15) then
				-- finally, kill the debugee process if it still exists
				debugger.destroy = 0;
				local ds = debugger.server_
				debugger.server_ = nil

				if (debugger.pid > 0) then
					if wx.wxProcess.Exists(debugger.pid) then
						local ret = wx.wxProcess.Kill(debugger.pid, wx.wxSIGKILL, wx.wxKILL_CHILDREN)
						if (ret ~= wx.wxKILL_OK) then
							DisplayOutput("Unable to kill debuggee process "..debugger.pid..", code "..tostring(ret)..".\n")
						else
							DisplayOutput("Killed debuggee process "..debugger.pid..".\n")
						end
					end
					debugger.pid = 0
				end
			end
			event:Skip()
		end)

frame:Connect(ID_START_DEBUG, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			-- test compile it before we run it
			if not CompileProgram(editor) then
				return
			end

			debugger.pid = 0
			debugger.server = CreateDebuggerServer()
			if debugger.server then
				debugger.pid = debugger.server:StartClient()
			end

			if debugger.server and (debugger.pid > 0) then
				SetAllEditorsReadOnly(true)
				DisplayOutput("Waiting for client connection, process "..tostring(debugger.pid)..".\n")
			else
				DisplayOutput("Unable to start debuggee process.\n")
				if debugger.server then
					DestroyDebuggerServer()
				end
			end

			NextDebuggerPort()
		end)
frame:Connect(ID_START_DEBUG, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server == nil) and (editor ~= nil))
		end)

frame:Connect(ID_STOP_DEBUG, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()

			if debugger.server then
				debugger.server:Reset();
				--DestroyDebuggerServer()
			end
			SetAllEditorsReadOnly(false)
			ignoredFilesList = {}
			debugger.running = false
			DisplayOutput("\nDebuggee client stopped.\n\n")
		end)
frame:Connect(ID_STOP_DEBUG, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server ~= nil) and (editor ~= nil))
		end)

frame:Connect(ID_STEP, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()

			if debugger.server then
				debugger.server:Step()
				debugger.running = true
			end
		end)
frame:Connect(ID_STEP, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server ~= nil) and (not debugger.running) and (editor ~= nil))
		end)

frame:Connect(ID_STEP_OVER, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()

			if debugger.server then
				debugger.server:StepOver()
				debugger.running = true
			end
		end)
frame:Connect(ID_STEP_OVER, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server ~= nil) and (not debugger.running) and (editor ~= nil))
		end)

frame:Connect(ID_STEP_OUT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()

			if debugger.server then
				debugger.server:StepOut()
				debugger.running = true
			end
		end)
frame:Connect(ID_STEP_OUT, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running))
		end)

frame:Connect(ID_CONTINUE, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()

			if debugger.server then
				debugger.server:Continue()
				debugger.running = true
			end
		end)
frame:Connect(ID_CONTINUE, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running))
		end)

frame:Connect(ID_BREAK, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if debugger.server then
				debugger.server:Break()
			end
		end)
frame:Connect(ID_BREAK, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and debugger.running)
		end)

frame:Connect(ID_VIEWCALLSTACK, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if debugger.server then
				debugger.server:DisplayStackDialog(frame)
			end
		end)
frame:Connect(ID_VIEWCALLSTACK, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running))
		end)

frame:Connect(ID_VIEWWATCHWINDOW, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if not debugger.watchWindow then
				CreateWatchWindow()
			end
		end)
frame:Connect(ID_VIEWWATCHWINDOW, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running))
		end)

frame:Connect(ID_SHOWHIDEWINDOW, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local w, h = frame:GetClientSizeWH()
			if splitter:IsSplit() then
				ide.config.view.splitterheight = h - splitter:GetSashPosition()
				splitter:Unsplit()
			else
				splitter:SplitHorizontally(notebook, splitter.bottomnotebook, h - ide.config.view.splitterheight)
			end
		end)
		
frame:Connect(ID_SHOWFILETREE, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if vsplitter:IsSplit() then
				ide.config.view.vsplitterpos = vsplitter:GetSashPosition()
				vsplitter:Unsplit(sidenotebook)
			else
				vsplitter:SplitVertically(sidenotebook,splitter,ide.config.view.vsplitterpos)
			end
		end)

frame:Connect(ID_DEBUGGER_PORT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event)
		end)
frame:Connect(ID_DEBUGGER_PORT, wx.wxEVT_UPDATE_UI,
		function(event)
			event:Enable(debugger.server == nil)
		end)
