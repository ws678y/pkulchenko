-- authors: Lomtik Software (J. Winwood & John Labenski)
--          Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------
local ide = ide
-- Create the Debug menu and attach the callback functions

local frame    = ide.frame
local menuBar  = frame.menuBar
local vsplitter= frame.vsplitter
local sidenotebook = vsplitter.sidenotebook
local splitter = vsplitter.splitter
local errorlog = splitter.bottomnotebook.errorlog
local notebook = splitter.notebook

local openDocuments = ide.openDocuments
local debugger      = ide.debugger
local filetree      = ide.filetree

--------------
-- Interpreters
local interpreters = {}
local lastinterpreter
for i,v in pairs(ide.interpreters) do
	interpreters[ID ("debug.interpreter."..i)] = v
	v.fname = i
	lastinterpreter = v.name
end
assert(lastinterpreter,"no interpreters defined")

local debugMenu = wx.wxMenu{
		{ ID_RUN,              "&Run or Continue\tF6",   "Execute the current project/file or Continue during debug" },
		{ ID_COMPILE,          "&Compile File\tF7",      "Test compile the Lua file" },
		{ },
		{ ID_START_DEBUG,      "&Debug\tF5",              "Run the program with debugger" },
		{ ID_STOP_DEBUG,       "S&top Debugging\tShift-F12", "Stop and end the debugging session" },
		{ ID_STEP,             "St&ep\tF11",             "Step into the next line" },
		{ ID_STEP_OVER,        "Step &Over\tF10",        "Step over the next line" },
		{ ID_STEP_OUT,         "Step O&ut\tF8",          "Step out of the current function" },
		{ ID_BREAK,            "&Break\tF12",            "Stop execution of the program at the next executed line of code" },
		{ },
		{ ID_TOGGLEBREAKPOINT, "Toggle &Breakpoint\tF9", "Toggle Breakpoint" },
		{ },
--		{ ID "view.debug.callstack","V&iew Call Stack",  "View the LUA call stack" },
		{ ID "view.debug.watches",  "View &Watches",     "View the Watch window" },
		{ },
		{ ID_CLEAROUTPUT,      "C&lear Output Window",   "Clear the output window before compiling or debugging", wx.wxITEM_CHECK },
		{ },
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

function ProjectUpdateProjectDir(projdir,skiptree)
	ide.config.path.projectdir = projdir
	menuBar:SetLabel(ID "debug.projectdir.currentdir",projdir)
	frame:SetStatusText(projdir)
	if (not skiptree) then
		ide.filetree:updateProjectDir(projdir)
	end
end
ProjectUpdateProjectDir(ide.config.path.projectdir)

-- interpreter setup
local function selectInterpreter (id)
	for i,inter in pairs(interpreters) do
		menuBar:Check(i, false)
	end
	menuBar:Check(id, true)
	local interpreter   = interpreters[id]
	ide.interpreter     = interpreter
	ide.debugger.server = interpreter.debugger
	ReloadLuaAPI()
end

function ProjectSetInterpreter(name)
	local id = IDget("debug.interpreter."..name)
	if (not interpreters[id]) then return end
	selectInterpreter(id)
end

do
	local defaultid = 	IDget("debug.interpreter."..ide.config.interpreter)  or 
							ID ("debug.interpreter."..lastinterpreter)
	menuBar:Check(defaultid, true)

	local function evSelectInterpreter (event)
		local chose = event:GetId()
		selectInterpreter(chose)
	end
	
	for id,inter in pairs(interpreters) do
		frame:Connect(id,wx.wxEVT_COMMAND_MENU_SELECTED,evSelectInterpreter)
	end
end



local function projChoose(event)
	local editor = GetEditor()
	local id       = editor:GetId()
	local saved    = false
	local fn       = wx.wxFileName(openDocuments[id].filePath or "")
	fn:Normalize() -- want absolute path for dialog
	
	local projectdir = ide.config.path.projectdir
	
	local filePicker = wx.wxDirDialog(frame, "Chose a project directory", 
			projectdir~="" and projectdir or wx.wxGetCwd(),wx.wxFLP_USE_TEXTCTRL)
	local res = filePicker:ShowModal(true)
	if res == wx.wxID_OK then
		ProjectUpdateProjectDir(filePicker:GetPath())
	end
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
	
	ProjectUpdateProjectDir(ide.interpreter:fprojdir(fn))
end
frame:Connect(ID "debug.projectdir.fromfile", wx.wxEVT_COMMAND_MENU_SELECTED,
	projFromFile)

frame:Connect(ID_TOGGLEBREAKPOINT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			local line = editor:LineFromPosition(editor:GetCurrentPos())
			DebuggerToggleBreakpoint(editor, line)
		end)
frame:Connect(ID_TOGGLEBREAKPOINT, wx.wxEVT_UPDATE_UI,
	function(event)
		local editor = GetEditor()
		event:Enable((editor ~= nil) and (ide.interpreter.hasdebugger))
	end)


frame:Connect(ID_COMPILE, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			CompileProgram(editor)
		end)
frame:Connect(ID_COMPILE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)

local function runInterpreter(withdebugger)
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
	local wfilename = wx.wxFileName(openDocuments[id].filePath)
	local server = ide.interpreter:frun(wfilename,withdebugger)
	if (withdebugger and server) then
		DebuggerStart(server)
	end
end

frame:Connect(ID_RUN, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if (debugger.server) then
				assert(not debugger.running)
				ClearAllCurrentLineMarkers()
				DebuggerAction("run")
			else
				runInterpreter()
			end
		end)
frame:Connect(ID_RUN, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((editor ~= nil) and (not debugger.server or (debugger.server and not debugger.running)))
		end)

frame:Connect(ID_START_DEBUG, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			runInterpreter(true)
		end)

frame:Connect(ID_START_DEBUG, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((ide.interpreter.hasdebugger) and (debugger.server == nil) and (editor ~= nil))
		end)

frame:Connect(ID_STOP_DEBUG, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()
			DebuggerAction("exit")
		end)

frame:Connect(ID_STOP_DEBUG, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server ~= nil) and (editor ~= nil))
		end)

frame:Connect(ID_STEP, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()
			DebuggerAction("step")
		end)
frame:Connect(ID_STEP, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server ~= nil) and (not debugger.running) and (editor ~= nil))
		end)

frame:Connect(ID_STEP_OVER, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()
			DebuggerAction("over")
		end)
frame:Connect(ID_STEP_OVER, wx.wxEVT_UPDATE_UI,
		function (event)
			local editor = GetEditor()
			event:Enable((debugger.server ~= nil) and (not debugger.running) and (editor ~= nil))
		end)

frame:Connect(ID_STEP_OUT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()
			DebuggerAction("out")
		end)
frame:Connect(ID_STEP_OUT, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running) and (editor ~= nil))
		end)

frame:Connect(ID_BREAK, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			ClearAllCurrentLineMarkers()
			DebuggerAction("breaknow")
		end)
frame:Connect(ID_BREAK, wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and debugger.running)
		end)


--[[ NYI
frame:Connect(ID "view.debug.callstack", wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if not debugger.callstackWindow then
				DebuggerCreateCallStackWindow()
			end
		end)
frame:Connect(ID "view.debug.callstack", wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running))
		end)
]]
frame:Connect(ID "view.debug.watches", wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			if not debugger.watchWindow then
				DebuggerCreateWatchWindow()
			end
		end)
frame:Connect(ID "view.debug.watches", wx.wxEVT_UPDATE_UI,
		function (event)
			event:Enable((debugger.server ~= nil) and (not debugger.running))
		end)

