--
-- filetree, treectrl for drive & project
--

ide.filetree = {
	dirdriveText = "",
	dirdriveTextArray = {},
	
	projdirText = "",
	projdirTextArray = {},
	
	dirdata  = {
		root_id = nil,
		rootdir = "",
		},
		
	projdata = {
		root_id = nil, 
		rootdir = "",
		}, 
	imglist,
	
	newfiledir,
}
local filetree = ide.filetree
local frame = ide.frame
local sidenotebook = ide.frame.vsplitter.sidenotebook


-- generic tree 
-- ------------

do
	filetree.imglist = wx.wxImageList(16,16)
	-- 0 = directory
	filetree.imglist:Add(wx.wxArtProvider.GetIcon(wx.wxART_FOLDER,wx.wxART_TOOLBAR, wx.wxSize(16, 16)))
	-- 1 = file
	filetree.imglist:Add(wx.wxArtProvider.GetIcon(wx.wxART_NORMAL_FILE,wx.wxART_TOOLBAR, wx.wxSize(16, 16)))
end



local function treeAddDir(tree,parent_id,rootdir)
	tree:DeleteChildren(parent_id)
	local search = rootdir..string_Pathsep.."*.*"
	local dirs = FileSysGet(search,wx.wxDIR)
	-- append directories
	for i,dir in ipairs(dirs) do
		local dir_id = tree:AppendItem(parent_id, dir:match("(%"..string_Pathsep..stringset_File.."+)$"),0)
		
		tree:SetItemHasChildren(dir_id,FileSysHasContent(dir))
	end
	-- then append files
	local files = FileSysGet(search,wx.wxFILE)
	for i,file in ipairs(files) do
		tree:AppendItem(parent_id, file:match("%"..string_Pathsep.."("..stringset_File.."+)$"),1)
	end
end

local function treeGetItemFullName(tree,treedata,item_id,isfile)
	local str = isfile and string_Pathsep or ""
	str = str..tree:GetItemText(item_id)
	local cur = str
	
	local stop = 4
	while (#cur > 0) do
		item_id = tree:GetItemParent(item_id)
		cur = tree:GetItemText(item_id)
		str = cur..str
	end
	
	return str
end

local function treeSetRoot(tree,treedata,rootdir)
	tree:DeleteAllItems()
	
	if (not wx.wxDirExists(rootdir)) then 
		treedata.root_id = nil
		tree:AddRoot("Invalid")
		return
	end
	
	local root_id = tree:AddRoot(rootdir,0)
	treedata.root_id = root_id
	treedata.rootdir = rootdir
	
	treeAddDir(tree,root_id,rootdir)
	
	filetree.newfiledir = rootdir
	
	tree:Expand(root_id)
end

local function treeSetConnectorsAndIcons(tree,treedata)
	tree:SetImageList(filetree.imglist)

	-- connect to some events from the wxTreeCtrl
	tree:Connect( wx.wxEVT_COMMAND_TREE_ITEM_EXPANDING,
		function( event )
			local item_id = event:GetItem()
			local dir = treeGetItemFullName(tree,treedata,item_id)
			--DisplayOutput(dir.."\n")
			treeAddDir(tree,item_id,dir)
			
			return true
		end )
	tree:Connect( wx.wxEVT_COMMAND_TREE_ITEM_COLLAPSED,
		function( event )
			local item_id = event:GetItem()
			tree:DeleteChildren(item_id)
			
			-- directories must stay expandable if they have content
			local dir = treeGetItemFullName(tree,treedata,item_id)
			tree:SetItemHasChildren(item_id,FileSysHasContent(dir))
			
			return true
		end )
	tree:Connect( wx.wxEVT_COMMAND_TREE_ITEM_ACTIVATED,
		function( event )
			local item_id = event:GetItem()
			
			if (tree:GetItemImage(item_id) == 0) then return end
			-- openfile
			local name = treeGetItemFullName(tree,treedata,item_id,true)
			LoadFile(name,nil,true)
			
		end )
	tree:Connect( wx.wxEVT_COMMAND_TREE_SEL_CHANGED,
		function( event )
			local item_id = event:GetItem()
			
			-- set "newfile-path"
			local isfile = tree:GetItemImage(item_id) ~= 0
			filetree.newfiledir = treeGetItemFullName(tree,treedata,item_id,isfile)
			
			if (isfile) then
				-- remove file
				filetree.newfiledir = wx.wxFileName(filetree.newfiledir):GetPath(wx.wxPATH_GET_VOLUME)
			end
		end )
end

-- project
-- panel 
--	( combobox, button)
--	( treectrl)

local projpanel = wx.wxPanel(sidenotebook,wx.wxID_ANY)
local projcombobox = wx.wxComboBox(projpanel, ID "filetree.proj.drivecb", 
		filetree.projdirText,  
		wx.wxDefaultPosition, wx.wxDefaultSize,  
		filetree.projdirTextArray, wx.wxTE_PROCESS_ENTER)
		

local projbutton = wx.wxButton(projpanel, ID "debug.projectdir.choose", "...",wx.wxDefaultPosition, wx.wxSize(26,20))



local projtree = wx.wxTreeCtrl(projpanel, ID "filetree.projtree",
						wx.wxDefaultPosition, wx.wxDefaultSize,
						wx.wxTR_LINES_AT_ROOT + wx.wxTR_HAS_BUTTONS + wx.wxTR_SINGLE)
						
local projTopSizer = wx.wxBoxSizer( wx.wxHORIZONTAL );
projTopSizer:Add(projcombobox,	1, wx.wxALL + wx.wxALIGN_LEFT + wx.wxGROW, 0)
projTopSizer:Add(projbutton,	0, wx.wxALL + wx.wxALIGN_RIGHT + wx.wxADJUST_MINSIZE, 0)

local projSizer = wx.wxBoxSizer( wx.wxVERTICAL );
projSizer:Add(projTopSizer, 0, wx.wxALL + wx.wxALIGN_CENTER_HORIZONTAL + wx.wxGROW, 0)
projSizer:Add(projtree, 1, wx.wxALL + wx.wxALIGN_LEFT + wx.wxGROW, 0)

projpanel:SetSizer(projSizer)

-- proj connectors
-- ---------------

local function projcomboboxUpdate(event)
	local cur = projcombobox:GetValue()
	local fn = wx.wxFileName(cur)
	fn:Normalize()
	
	filetree:UpdateProjectDir(fn:GetFullPath(), event:GetEventType() == wx.wxEVT_COMMAND_COMBOBOX_SELECTED)
end

projpanel:Connect(ID "filetree.proj.drivecb", wx.wxEVT_COMMAND_COMBOBOX_SELECTED, projcomboboxUpdate)
projpanel:Connect(ID "filetree.proj.drivecb", wx.wxEVT_COMMAND_TEXT_ENTER, projcomboboxUpdate)	


treeSetConnectorsAndIcons(projtree,filetree.projdata)

-- proj functions
-- ---------------



function filetree:UpdateProjectDir(newdir, cboxsel)
	if (newdir and newdir:sub(-3,-2) == string_Pathsep) then
		newdir = newdir:sub(0,-2)
	end

	if ((not newdir) or filetree.projdirText == newdir or not wx.wxDirExists(newdir)) then return end
	filetree.projdirText = newdir
	
	--if (not cboxsel) then
		PrependStringToArray(filetree.projdirTextArray,newdir)
		projcombobox:Clear()
		projcombobox:Append(filetree.projdirTextArray)
		if (not cboxsel) then
			projcombobox:SetValue(newdir)
			--projcombobox:SetValue(newdir)
		else
			projcombobox:Select(0)
		end
	--end
	
	treeSetRoot(projtree,filetree.projdata,newdir)
end


projpanel.projbutton = projbutton
projpanel.projcombobox = projcombobox
projpanel.projtree = projtree
sidenotebook.projpanel = projpanel

sidenotebook:AddPage(projpanel, "Project",true)

function GetFileTreeDir()
	-- atm only projtree
	return filetree.newfiledir
end

function SetProjects(tab)
	filetree.projdirTextArray = tab
	if (tab and tab[1]) then
		filetree:UpdateProjectDir(tab[1])
	end
end

function GetProjects()
	return filetree.projdirTextArray
end