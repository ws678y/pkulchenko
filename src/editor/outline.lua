-- Copyright 2014 Paul Kulchenko, ZeroBrane LLC

local ide = ide
ide.outline = {}

local image = { FILE = 0, FUNCTION = 1 }

do
  local getBitmap = (ide.app.createbitmap or wx.wxArtProvider.GetBitmap)
  local size = wx.wxSize(16,16)
  local imglist = wx.wxImageList(16,16)
  imglist:Add(getBitmap("FILE-NORMAL", "OTHER", size)) -- 0 = file known spec
  imglist:Add(getBitmap("VALUE-CALL", "OTHER", size)) -- 1 = stack call
  ide.outline.imglist = imglist
end

local q = EscapeMagic
local caches = {}

local function outlineCreateOutlineWindow()
  local width, height = 360, 200
  local ctrl = wx.wxTreeCtrl(ide.frame, wx.wxID_ANY,
    wx.wxDefaultPosition, wx.wxSize(width, height),
    wx.wxTR_LINES_AT_ROOT + wx.wxTR_HAS_BUTTONS + wx.wxTR_SINGLE
    + wx.wxTR_HIDE_ROOT)

  ide.outline.outlineCtrl = ctrl
  ide.outline.timer = wx.wxTimer(ctrl)

  local root = ctrl:AddRoot("Outline")
  ctrl:SetImageList(ide.outline.imglist)
  ctrl:SetFont(ide.font.fNormal)

  function ctrl:ActivateItem(item_id)
    ctrl:SelectItem(item_id, true)
    local data = ctrl:GetItemData(item_id)
    if ctrl:GetItemImage(item_id) == image.FILE then
      -- activate editor tab
      local editor = data:GetData()
      if editor then ide:GetDocument(editor):SetActive() end
    else
      -- activate tab and move cursor based on stored pos
      -- get file parent
      local parent = ctrl:GetItemParent(item_id)
      while parent:IsOk() and ctrl:GetItemImage(parent) == image.FUNCTION do
        parent = ctrl:GetItemParent(parent)
      end
      if not parent:IsOk() then return end
      -- activate editor tab
      local editor = ctrl:GetItemData(parent):GetData()
      local cache = caches[editor]
      if editor and cache then
        ide:GetDocument(editor):SetActive()
        -- move to position in the file
        editor:GotoPosEnforcePolicy(cache.funcs[data:GetData()].pos-1)
      end
    end
  end

  local function activateByPosition(event)
    -- only toggle if this is a folder and the click is on the item line
    -- (exclude the label as it's used for renaming and dragging)
    local mask = (wx.wxTREE_HITTEST_ONITEMINDENT + wx.wxTREE_HITTEST_ONITEMLABEL
      + wx.wxTREE_HITTEST_ONITEMICON + wx.wxTREE_HITTEST_ONITEMRIGHT)
    local item_id, flags = ctrl:HitTest(event:GetPosition())

    if item_id and bit.band(flags, mask) > 0 then
      ctrl:ActivateItem(item_id)
    else
      event:Skip()
    end
    return true
  end

  ctrl:Connect(wx.wxEVT_TIMER, function() OutlineRefresh(GetEditor()) end)
  ctrl:Connect(wx.wxEVT_LEFT_DOWN, activateByPosition)
  ctrl:Connect(wx.wxEVT_LEFT_DCLICK, activateByPosition)
  ctrl:Connect(wx.wxEVT_COMMAND_TREE_ITEM_ACTIVATED, function(event)
      ctrl:ActivateItem(event:GetItem())
    end)

  local layout = ide:GetSetting("/view", "uimgrlayout")
  if not layout or not layout:find("outlinepanel") then
    ide.frame.projnotebook:AddPage(ctrl, TR("Outline"), true)
    return
  end
  OutlineAddWindow()
  return ctrl
end

function OutlineAddWindow()
  return ide:AddPanel(ide.outline.outlineCtrl, "outlinepanel", TR("Outline"))
end

local function eachNode(eachFunc, root)
  local ctrl = ide.outline.outlineCtrl
  root = root or ctrl:GetRootItem()
  local item = ctrl:GetFirstChild(root)
  while true do
    if not item:IsOk() then break end
    if eachFunc and eachFunc(ctrl, item) then break end
    item = ctrl:GetNextSibling(item)
  end
end

local function setData(ctrl, item, value)
  if ide.wxver >= "2.9.5" then
    local data = wx.wxLuaTreeItemData()
    data:SetData(value)
    ctrl:SetItemData(item, data)
  end
end

function OutlineRefresh(editor)
  if not editor then return end
  local tokens = editor:GetTokenList()
  local text = editor:GetText()
  local sep = editor.spec.sep
  local varname = "([%w_][%w_"..q(sep:sub(1,1)).."]*)"
  local funcs = {}
  for _, token in ipairs(tokens) do
    if token[1] == 'Function' then
      local depth = token.context['function']
      local _, _, rname, params = text:find('([^%(]*)(%b())', token.fpos)
      if token.name and rname:find(token.name, 1, true) ~= 1 then
        token.name = rname:gsub("%s+$","")
      end
      local name, pos = token.name, token.fpos
      if not name then
        local s = editor:PositionFromLine(editor:LineFromPosition(pos))
        local rest
        rest, pos, name = text:sub(s, pos-1):match('%s*(.-)()'..varname..'%s*=%s*function%s*$')
        if rest then
          pos = s + pos - 1
          -- guard against "foo, bar = function() end" as it would get "bar"
          if #rest>0 and rest:find(',') then name = nil end
        end
      end
      funcs[#funcs+1] = {
        name = (name or '[anonymous]')..params,
        depth = depth,
        pos = name and pos or token.fpos}
    end
  end

  local ctrl = ide.outline.outlineCtrl
  local root = ctrl:GetRootItem()
  if not root or not root:IsOk() then return end

  local cache = caches[editor] or {}
  do -- check if any changes in the cached function list
    local prevfuncs = cache.funcs or {}
    local nochange = #funcs == #prevfuncs
    if nochange then
      for n, func in ipairs(funcs) do
        func.item = prevfuncs[n].item -- carry over cached items
        if func.depth ~= prevfuncs[n].depth then
          nochange = false
        elseif nochange and func.name ~= prevfuncs[n].name then
          ctrl:SetItemText(prevfuncs[n].item, func.name)
        end
      end
    end
    cache.funcs = funcs -- set new cache as positions may change
    if nochange then return end -- return if no visible changes
  end

  -- refresh the tree
  local filename = ide:GetDocument(editor):GetFileName()
  local fileitem = cache.fileitem
  if not fileitem then
    fileitem = ctrl:AppendItem(root, filename, image.FILE)
    setData(ctrl, fileitem, editor)
    ctrl:SetItemBold(fileitem, true)
    ctrl:SortChildren(root)
    cache.fileitem = fileitem
  end

  ctrl:Freeze()
  ctrl:DeleteChildren(fileitem)

  ctrl:SetItemHasChildren(fileitem, #funcs > 0)
  local stack = {fileitem}
  for n, func in ipairs(funcs) do
    local name, pos, depth = func.name, func.pos, func.depth
    local item = ctrl:AppendItem(stack[depth], name, image.FUNCTION)
    setData(ctrl, item, n)
    func.item = item
    stack[depth+1] = item
  end
  if not ctrl:IsExpanded(fileitem) then ctrl:ExpandAllChildren(fileitem) end

  ctrl:ScrollTo(fileitem)
  ctrl:Thaw()

  caches[editor] = cache
end

outlineCreateOutlineWindow()

ide.packages['core.outline'] = setmetatable({
    -- remove the editor from the list
    onEditorClose = function(self, editor)
      caches[editor] = nil -- remove from cache
      local doc = ide:GetDocument(editor)
      if not doc then return end
      local name = doc:GetFileName()
      eachNode(function(ctrl, item)
          if ctrl:GetItemText(item) == name then
            ctrl:Delete(item)
            return true
          end
        end)
    end,
    -- go over the editors
    onEditorFocusSet = function(self, editor)
      local doc = ide:GetDocument(editor)
      if not doc then return end
      local name = doc:GetFileName()
      eachNode(function(ctrl, item)
          local found = ctrl:GetItemText(item) == name
          ctrl:SetItemBold(item, found)
          if found then
            if not ctrl:IsExpanded(item) then ctrl:ExpandAllChildren(item) end
            ctrl:ScrollTo(item)
          end
        end)
    end,
  }, ide.proto.Plugin)
