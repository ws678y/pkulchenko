-- Copyright 2011-14 Paul Kulchenko, ZeroBrane LLC
---------------------------------------------------------

local maxlines = 8
local row_height = 46
local row_width = 450
local win = ide.osname == 'Windows'

function CommandBarShow(onDone, onUpdate, onItem, onSelection, defaultText)
  local lines = {}
  local linesnow = #lines
  local linenow = 0

  local ed = ide:GetEditor()
  local pos = ed and ed:GetScreenPosition() or ide:GetEditorNotebook():GetScreenPosition()
  if pos then
    pos:SetX(pos:GetX()+ide:GetEditorNotebook():GetClientSize():GetWidth()-row_width-16)
    pos:SetY(pos:GetY()+2)
    if not win then pos = ide:GetMainFrame():ScreenToClient(pos) end
  else
    pos = wx.wxDefaultPosition
  end

  local frame = win and wx.wxFrame(ide:GetMainFrame(), wx.wxID_ANY, "Command Bar",
    pos, wx.wxDefaultSize,
    wx.wxFRAME_TOOL_WINDOW + wx.wxFRAME_FLOAT_ON_PARENT + wx.wxNO_BORDER)
  local panel = wx.wxPanel(frame or ide:GetMainFrame(), wx.wxID_ANY,
    win and wx.wxDefaultPosition or pos, wx.wxDefaultSize, wx.wxFULL_REPAINT_ON_RESIZE)
  local search = wx.wxTextCtrl(panel, wx.wxID_ANY, "\1",
    wx.wxDefaultPosition,
    -- make the text control a bit smaller on OSX
    wx.wxSize(row_width, ide.osname == 'Macintosh' and 20 or 24),
    wx.wxTE_PROCESS_ENTER + wx.wxTE_PROCESS_TAB + wx.wxNO_BORDER)
  local results = wx.wxScrolledWindow(panel, wx.wxID_ANY,
    wx.wxDefaultPosition, wx.wxSize(0, 0))

  if not frame then frame = panel end

  local style, styledef = ide.config.styles, StylesGetDefault()
  local textcolor = wx.wxColour(unpack(style.text.fg or styledef.text.fg))
  local backcolor = wx.wxColour(unpack(style.text.bg or styledef.text.bg))
  local selcolor = wx.wxColour(unpack(style.caretlinebg.bg or styledef.caretlinebg.bg))
  local pancolor = ide:GetUIManager():GetArtProvider():GetColor(wxaui.wxAUI_DOCKART_SASH_COLOUR)
  local borcolor = ide:GetUIManager():GetArtProvider():GetColor(wxaui.wxAUI_DOCKART_BORDER_COLOUR)

  search:SetBackgroundColour(backcolor)
  search:SetForegroundColour(textcolor)

  local nbrush = wx.wxBrush(backcolor, wx.wxSOLID)
  local sbrush = wx.wxBrush(selcolor, wx.wxSOLID)
  local bbrush = wx.wxBrush(pancolor, wx.wxSOLID)
  local lpen = wx.wxPen(borcolor, 1, wx.wxDOT)
  local bpen = wx.wxPen(borcolor, 1, wx.wxSOLID)

  local sash = ide:GetUIManager():GetArtProvider():GetMetric(wxaui.wxAUI_DOCKART_SASH_SIZE)
  local border = sash + 2
  local hoffset = 4
  local voffset = 4

  local topSizer = wx.wxFlexGridSizer(2, 1, -border*2, 0)
  topSizer:SetFlexibleDirection(wx.wxVERTICAL)
  topSizer:AddGrowableRow(1, 1)
  topSizer:Add(search, wx.wxSizerFlags(0):Expand():Border(wx.wxALL, border))
  topSizer:Add(results, wx.wxSizerFlags(1):Expand():Border(wx.wxALL, border))
  panel:SetSizer(topSizer)
  topSizer:Fit(frame) -- fit the frame/panel around the controls

  local minheight = frame:GetClientSize():GetHeight()

  local tfont = ide:GetProjectTree():GetFont()
  local ffont = (ide:GetEditor() or ide:CreateBareEditor()):GetFont()
  ffont:SetPointSize(ffont:GetPointSize()+2)
  local sfont = wx.wxFont(tfont)
  tfont:SetPointSize(tfont:GetPointSize()+2)
  search:SetFont(tfont)

  -- make a one-time callback;
  -- needed because KILL_FOCUS handler can be called after closing window
  local function onExit(index)
    onExit = function() end
    onDone(index and lines[index], index ~= nil, search:GetValue())
    frame:Close()
  end

  local function onPaint(event)
    -- adjust the scrollbar before working with the canvas
    local _, starty = results:GetViewStart()
    if #lines ~= linesnow then
      -- adjust the starting line when the current line is the last one
      if linenow > starty+maxlines then starty = starty + 1 end
      results:SetScrollbars(1, row_height, 1, #lines, 0, starty*row_height, false)
      linesnow = #lines
    end

    local dc = wx.wxMemoryDC(results)
    results:PrepareDC(dc)

    local size = results:GetVirtualSize()
    local w,h = size:GetWidth(),size:GetHeight()
    local bitmap = wx.wxBitmap(w,h)
    dc:SelectObject(bitmap)

    -- clear the background
    dc:SetBackground(nbrush)
    dc:Clear()

    dc:SetTextForeground(textcolor)
    dc:SetBrush(sbrush)
    for r = 1, #lines do
      if r == linenow then
        dc:SetPen(wx.wxTRANSPARENT_PEN)
        dc:DrawRectangle(0, row_height*(r-1), row_width, row_height+1)
      end
      dc:SetPen(lpen)
      dc:DrawLine(hoffset, row_height*(r-1), row_width-hoffset*2, row_height*(r-1))

      local fline, sline = onItem(lines[r])
      if fline then
        dc:SetFont(ffont)
        dc:DrawText(fline, hoffset, row_height*(r-1)+voffset)
      end
      if sline then
        dc:SetFont(sfont)
        dc:DrawText(sline, hoffset, row_height*(r-1)+row_height/2+voffset)
      end
    end

    dc:SetPen(wx.wxNullPen)
    dc:SetBrush(wx.wxNullBrush)
    dc:SelectObject(wx.wxNullBitmap)
    dc:delete()

    dc = wx.wxPaintDC(results)
    dc:DrawBitmap(bitmap, 0, 0, true)
    dc:delete()
  end

  local function onPanelPaint(event)
    local dc = wx.wxBufferedPaintDC(panel)
    dc:SetBrush(bbrush)
    dc:SetPen(bpen)

    local psize = panel:GetClientSize()
    dc:DrawRectangle(0, 0, psize:GetWidth(), psize:GetHeight())
    dc:DrawRectangle(sash+1, sash+1, psize:GetWidth()-2*(sash+1), psize:GetHeight()-2*(sash+1))

    dc:SetPen(wx.wxNullPen)
    dc:SetBrush(wx.wxNullBrush)
    dc:delete()
  end

  local linewas -- line that was reported when updated
  local function onTextUpdated(event)
    local text = search:GetValue()
    lines = onUpdate(text)
    linenow = #text > 0 and #lines > 0 and 1 or 0
    linewas = nil

    local size = frame:GetClientSize()
    local height = minheight + row_height*math.min(maxlines,#lines)
    if height ~= size:GetHeight() then
      results:SetScrollbars(1, 1, 1, 1, 0, 0, false)
      size:SetHeight(height)
      frame:SetClientSize(size)
    end

    results:Refresh()
  end

  local function onKeyDown(event)
    local keycode = event:GetKeyCode()
    if keycode == wx.WXK_UP then
      linenow = linenow - 1
      if linenow <= 0 then linenow = linesnow end
    elseif keycode == wx.WXK_DOWN then
      if linesnow > 0 then linenow = linenow % linesnow + 1 end
    elseif keycode == wx.WXK_ESCAPE then
      onExit()
      return
    else
      event:Skip()
      return
    end

    local _, starty = results:GetViewStart()
    if linenow < starty+1 then results:Scroll(-1, linenow-1)
    elseif linenow > starty+maxlines then results:Scroll(-1, linenow-maxlines) end
    results:Refresh()
  end

  local function onMouseLeftDown(event)
    local pos = event:GetPosition()
    local _, y = results:CalcUnscrolledPosition(pos.x, pos.y)
    onExit(math.floor(y / row_height)+1)
  end

  local function onIdle(event)
    if linewas == linenow then return end
    linewas = linenow
    if linenow == 0 then return end

    -- save the selection/insertion point as it's reset on Linux (wxwidgets 2.9.5)
    local ip = search:GetInsertionPoint()
    local f, t = search:GetSelection()

    -- this may set focus to a different object/tab,
    -- so disable the focus event and then set the focus back
    search:SetEvtHandlerEnabled(false)
    onSelection(lines[linenow])
    search:SetFocus()
    search:SetEvtHandlerEnabled(true)
    if ide.osname == 'Unix' then
      search:SetInsertionPoint(ip)
      search:SetSelection(f, t)
    end
  end

  frame:Connect(wx.wxEVT_CLOSE_WINDOW, function() frame:Destroy() end)

  panel:Connect(wx.wxEVT_PAINT, onPanelPaint)
  panel:Connect(wx.wxEVT_ERASE_BACKGROUND, function() end)
  panel:Connect(wx.wxEVT_IDLE, onIdle)

  results:Connect(wx.wxEVT_PAINT, onPaint)
  results:Connect(wx.wxEVT_LEFT_DOWN, onMouseLeftDown)
  results:Connect(wx.wxEVT_ERASE_BACKGROUND, function() end)

  search:SetFocus()
  search:Connect(wx.wxEVT_KEY_DOWN, onKeyDown)
  search:Connect(wx.wxEVT_COMMAND_TEXT_UPDATED, onTextUpdated)
  search:Connect(wx.wxEVT_COMMAND_TEXT_ENTER, function() onExit(linenow) end)
  search:Connect(wx.wxEVT_KILL_FOCUS, function() onExit() end)

  frame:Show(true)

  search:SetValue(defaultText or "")
  search:SetInsertionPointEnd()
end

local sep = "[/\\%-_ ]+"
local weights = {onegram = 0.1, digram = 0.4, trigram = 0.5}
local cache = {}
local missing = 3 -- penalty for missing symbols (1 missing == N matching)
local casemismatch = 0.9 -- score for case mismatch (%% of full match)
local function score(p, v)
  local function ngrams(str, num, low, needcache)
    local key = str..'\1'..num
    if cache[key] then return unpack(cache[key]) end

    local t, l, p = {}, {}, 0
    for i = 1, #str-num+1 do
      local pair = str:sub(i, i+num-1)
      p = p + (t[pair] and 0 or 1)
      if low and pair:find('%u') then l[pair:lower()] = casemismatch end
      t[pair] = 1
    end
    if needcache then cache[key] = {t, p, l} end
    return t, p, l
  end

  local function overlap(pattern, value, num)
    local ph, ps = ngrams(pattern, num, false, true)
    local vh, vs, vl = ngrams(value, num, true)
    if ps + vs == 0 then return 0 end

    local is = 0 -- intersection of two sets of ngrams
    for k in pairs(ph) do is = is + (vh[k] or vl[k:lower()] or 0) end
    return is / (ps + vs) - (num == 1 and missing * (ps - is) / (ps + vs) or 0)
  end

  local key = p..'\1'..v
  if not cache[key] then
    local score = weights.onegram * overlap(p, v, 1)
    p = ' '..(p:gsub(sep, ' '))
    v = ' '..(v:gsub(sep, ' '))
    score = score + weights.digram * overlap(p, v, 2)
    score = score + weights.trigram * overlap(' '..p, ' '..v, 3)
    cache[key] = 2 * 100 * score
  end
  return cache[key]
end

function CommandBarScoreFiles(t, pattern)
  local r, plen = {}, #pattern
  for _, v in ipairs(t) do
    if #v >= plen then table.insert(r, {v, score(pattern, v)}) end
  end
  table.sort(r, function(a, b) return a[2] > b[2] end)
  return r
end

ide:AddPackage('core.commandbar', {
    -- reset ngram cache when switching projects to conserve memory
    onProjectLoad = function() cache = {} end
  })
