-- authors: Lomtik Software (J. Winwood & John Labenski)
--          Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------

-- Create the Search menu and attach the callback functions

local frame    = ide.frame
local menuBar  = frame.menuBar

local findReplace = ide.findReplace

local findMenu = wx.wxMenu{
		{ ID_FIND,       "&Find\tCtrl-F",            "Find the specified text" },
		{ ID_FINDNEXT,   "Find &Next\tF3",           "Find the next occurrence of the specified text" },
		{ ID_FINDPREV,   "Find &Previous\tShift-F3", "Repeat the search backwards in the file" },
		{ ID_REPLACE,    "&Replace\tCtrl-H",         "Replaces the specified text with different text" },
		{ },
		{ ID_FIND_IN_FILES, "Find &In Files\tCtrl-Shift-F",		" Find specified text in files"},
		{ ID_REPLACE_IN_FILES, "Re&place In Files\tCtrl-Shift-H",		" Replace specified text in files"},
		{ },
		{ ID_GOTOLINE,   "&Goto line\tCtrl-G",       "Go to a selected line" },
		{ },
		{ ID_SORT,       "&Sort",                    "Sort selected lines"}}
menuBar:Append(findMenu, "&Search")



frame:Connect(ID_FIND, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			findReplace:GetSelectedString()
			findReplace:Show(false)
		end)
frame:Connect(ID_FIND, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)

frame:Connect(ID_REPLACE, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			findReplace:GetSelectedString()
			findReplace:Show(true)
		end)
frame:Connect(ID_REPLACE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)

frame:Connect(ID_FIND_IN_FILES, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			findReplace:GetSelectedString()
			findReplace:Show(false,true)
		end)
frame:Connect(ID_FIND_IN_FILES, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)

frame:Connect(ID_REPLACE_IN_FILES, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			findReplace:GetSelectedString()
			findReplace:Show(true,true)
		end)
frame:Connect(ID_REPLACE_IN_FILES, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)

frame:Connect(ID_FINDNEXT, wx.wxEVT_COMMAND_MENU_SELECTED, function (event) findReplace:GetSelectedString() findReplace:FindString() end)
frame:Connect(ID_FINDNEXT, wx.wxEVT_UPDATE_UI, function (event) findReplace:HasText() end)

frame:Connect(ID_FINDPREV, wx.wxEVT_COMMAND_MENU_SELECTED, function (event) findReplace:GetSelectedString() findReplace:FindString(true) end)
frame:Connect(ID_FINDPREV, wx.wxEVT_UPDATE_UI, function (event) findReplace:HasText() end)

-------------------- Find replace end

frame:Connect(ID_GOTOLINE, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			local linecur = editor:LineFromPosition(editor:GetCurrentPos())
			local linemax = editor:LineFromPosition(editor:GetLength()) + 1
			local linenum = wx.wxGetNumberFromUser( "Enter line number",
													"1 .. "..tostring(linemax),
													"Goto Line",
													linecur, 1, linemax,
													frame)
			if linenum > 0 then
				editor:GotoLine(linenum-1)
			end
		end)
frame:Connect(ID_GOTOLINE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)

frame:Connect(ID_SORT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			local editor = GetEditor()
			local buf = {}
			for line in string.gmatch(editor:GetSelectedText()..'\n', "(.-)\r?\n") do
				table.insert(buf, line)
			end
			if #buf > 0 then
				table.sort(buf)
				editor:ReplaceSelection(table.concat(buf,"\n"))
			end
		end)
frame:Connect(ID_SORT, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
