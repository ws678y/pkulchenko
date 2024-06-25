--
-- MobDebug 0.463
-- Copyright Paul Kulchenko 2011-2012
-- Based on RemDebug 1.0 Copyright Kepler Project 2005
-- (http://www.keplerproject.org/remdebug)
--

local mobdebug = {
  _NAME = "mobdebug",
  _COPYRIGHT = "Paul Kulchenko",
  _DESCRIPTION = "Mobile Remote Debugger for the Lua programming language",
  _VERSION = "0.463"
}

local coroutine = coroutine
local error = error
local getfenv = getfenv
local loadstring = loadstring
local io = io
local os = os
local pairs = pairs
local require = require
local setmetatable = setmetatable
local string = string
local tonumber = tonumber
local mosync = mosync

-- this is a socket class that implements maConnect interface
local function socketMobileLua() 
  local self = {}
  self.select = function(readfrom) -- writeto and timeout parameters are ignored
    local canread = {}
    for _,s in ipairs(readfrom) do
      if s:receive(0) then canread[s] = true end
    end
    return canread
  end
  self.connect = coroutine.wrap(function(host, port)
    while true do
      local connection = mosync.maConnect("socket://" .. host .. ":" .. port)
  
      if connection > 0 then
        local event = mosync.SysEventCreate()
        while true do
          mosync.maWait(0)
          mosync.maGetEvent(event)
          local eventType = mosync.SysEventGetType(event)
          if (mosync.EVENT_TYPE_CONN == eventType and
            mosync.SysEventGetConnHandle(event) == connection and
            mosync.SysEventGetConnOpType(event) == mosync.CONNOP_CONNECT) then
              -- result > 0 ? success : error
              if not (mosync.SysEventGetConnResult(event) > 0) then connection = nil end
              break
          elseif mosync.EventMonitor and mosync.EventMonitor.HandleEvent then
            mosync.EventMonitor:HandleEvent(event)
          end
        end
        mosync.SysFree(event)
      end
  
      host, port = coroutine.yield(connection and (function ()
        local self = {}
        local outBuffer = mosync.SysAlloc(1000)
        local inBuffer = mosync.SysAlloc(1000)
        local event = mosync.SysEventCreate()
        local recvBuffer = ""
        function stringToBuffer(s, buffer)
          local i = 0
          for c in s:gmatch(".") do
            i = i + 1
            local b = s:byte(i)
            mosync.SysBufferSetByte(buffer, i - 1, b)
          end
          return i
        end
        function bufferToString(buffer, len)
          local s = ""
          for i = 0, len - 1 do
            local c = mosync.SysBufferGetByte(buffer, i)
            s = s .. string.char(c)
          end
          return s
        end
        self.send = coroutine.wrap(function(self, msg)
          while true do
            local numberOfBytes = stringToBuffer(msg, outBuffer)
            mosync.maConnWrite(connection, outBuffer, numberOfBytes)
            while true do
              mosync.maWait(0)
              mosync.maGetEvent(event)
              local eventType = mosync.SysEventGetType(event)
              if (mosync.EVENT_TYPE_CONN == eventType and
                  mosync.SysEventGetConnHandle(event) == connection and
                  mosync.SysEventGetConnOpType(event) == mosync.CONNOP_WRITE) then
                break
              elseif mosync.EventMonitor and mosync.EventMonitor.HandleEvent then
                mosync.EventMonitor:HandleEvent(event)
              end
            end
            self, msg = coroutine.yield()
          end
        end)
        self.receive = coroutine.wrap(function(self, len)
          while true do
            local line = recvBuffer
            while (len and string.len(line) < len)     -- either we need len bytes
               or (not len and not line:find("\n")) -- or one line (if no len specified)
               or (len == 0) do -- only check for new data (select-like)
              mosync.maConnRead(connection, inBuffer, 1000)
              while true do
                if len ~= 0 then mosync.maWait(0) end
                mosync.maGetEvent(event)
                local eventType = mosync.SysEventGetType(event)
                if (mosync.EVENT_TYPE_CONN == eventType and
                    mosync.SysEventGetConnHandle(event) == connection and
                    mosync.SysEventGetConnOpType(event) == mosync.CONNOP_READ) then
                  local result = mosync.SysEventGetConnResult(event)
                  if result > 0 then line = line .. bufferToString(inBuffer, result) end
                  if len == 0 then self, len = coroutine.yield("") end
                  break -- got the event we wanted; now check if we have all we need
                elseif len == 0 then
                  self, len = coroutine.yield(nil)
                elseif mosync.EventMonitor and mosync.EventMonitor.HandleEvent then
                  mosync.EventMonitor:HandleEvent(event)
                end
              end  
            end
    
            if not len then
              len = string.find(line, "\n") or string.len(line)
            end
    
            recvBuffer = string.sub(line, len+1)
            line = string.sub(line, 1, len)
    
            self, len = coroutine.yield(line)
          end
        end)
        self.close = coroutine.wrap(function(self) 
          while true do
            mosync.SysFree(inBuffer)
            mosync.SysFree(outBuffer)
            mosync.SysFree(event)
            mosync.maConnClose(connection)
            coroutine.yield(self)
          end
        end)
        return self
      end)())
    end
  end)

  return self
end

-- overwrite RunEventLoop in MobileLua as it conflicts with the event
-- loop that needs to run to process debugger events (socket read/write).
-- event loop functionality is implemented by calling HandleEvent
-- while waiting for debugger events.
if mosync and mosync.EventMonitor then
  mosync.EventMonitor.RunEventLoop = function(self) end
end

local socket = mosync and socketMobileLua() or (require "socket")

local debug = require "debug"
local coro_debugger
local events = { BREAK = 1, WATCH = 2, RESTART = 3, STACK = 4 }
local breakpoints = {}
local watches = {}
local lastsource
local lastfile
local watchescnt = 0
local abort -- default value is nil; this is used in start/loop distinction
local check_break = false
local skip
local skipcount = 0
local step_into = false
local step_over = false
local step_level = 0
local stack_level = 0
local server
local deferror = "execution aborted at default debugee"
local debugee = function () 
  local a = 1
  for _ = 1, 10 do a = a + 1 end
  error(deferror)
end

local serpent = (function() ---- include Serpent module for serialization
local n, v = "serpent", 0.15 -- (C) 2012 Paul Kulchenko; MIT License
local c, d = "Paul Kulchenko", "Serializer and pretty printer of Lua data types"
local snum = {[tostring(1/0)]='1/0 --[[math.huge]]',[tostring(-1/0)]='-1/0 --[[-math.huge]]',[tostring(0/0)]='0/0'}
local badtype = {thread = true, userdata = true}
local keyword, globals, G = {}, {}, (_G or _ENV)
for _,k in ipairs({'and', 'break', 'do', 'else', 'elseif', 'end', 'false',
  'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
  'return', 'then', 'true', 'until', 'while'}) do keyword[k] = true end
for k,v in pairs(G) do globals[v] = k end -- build func to name mapping
for _,g in ipairs({'coroutine', 'debug', 'io', 'math', 'string', 'table', 'os'}) do
  for k,v in pairs(G[g]) do globals[v] = g..'.'..k end end

local function s(t, opts)
  local name, indent, fatal = opts.name, opts.indent, opts.fatal
  local sparse, custom, huge = opts.sparse, opts.custom, not opts.nohuge
  local space, maxl = (opts.compact and '' or ' '), (opts.maxlevel or math.huge)
  local comm = opts.comment and (tonumber(opts.comment) or math.huge)
  local seen, sref, syms, symn = {}, {}, {}, 0
  local function gensym(val) return tostring(val):gsub("[^%w]",""):gsub("(%d%w+)",
    function(s) if not syms[s] then symn = symn+1; syms[s] = symn end return syms[s] end) end
  local function safestr(s) return type(s) == "number" and (huge and snum[tostring(s)] or s)
    or type(s) ~= "string" and tostring(s) -- escape NEWLINE/010 and EOF/026
    or ("%q"):format(s):gsub("\010","n"):gsub("\026","\\026") end
  local function comment(s,l) return comm and (l or 0) < comm and ' --[['..tostring(s)..']]' or '' end
  local function globerr(s,l) return globals[s] and globals[s]..comment(s,l) or not fatal
    and safestr(tostring(s))..comment('err',l) or error("Can't serialize "..tostring(s)) end
  local function safename(path, name) -- generates foo.bar, foo[3], or foo['b a r']
    local n = name == nil and '' or name
    local plain = type(n) == "string" and n:match("^[%l%u_][%w_]*$") and not keyword[n]
    local safe = plain and n or '['..safestr(n)..']'
    return (path or '')..(plain and path and '.' or '')..safe, safe end
  local alphanumsort = type(opts.sortkeys) == 'function' and opts.sortkeys or function(o, n)
    local maxn, to = tonumber(n) or 12, {number = 'a', string = 'b'}
    local function padnum(d) return ("%0"..maxn.."d"):format(d) end
    table.sort(o, function(a,b)
      return (o[a] and 0 or to[type(a)] or 'z')..(tostring(a):gsub("%d+",padnum))
           < (o[b] and 0 or to[type(b)] or 'z')..(tostring(b):gsub("%d+",padnum)) end) end
  local function val2str(t, name, indent, path, plainindex, level)
    local ttype, level = type(t), (level or 0)
    local spath, sname = safename(path, name)
    local tag = plainindex and
      ((type(name) == "number") and '' or name..space..'='..space) or
      (name ~= nil and sname..space..'='..space or '')
    if seen[t] then
      table.insert(sref, spath..space..'='..space..seen[t])
      return tag..'nil'..comment('ref', level)
    elseif badtype[ttype] then return tag..globerr(t, level)
    elseif ttype == 'function' then
      seen[t] = spath
      local ok, res = pcall(string.dump, t)
      local func = ok and ((opts.nocode and "function() end" or
        "loadstring("..safestr(res)..",'@serialized')")..comment(t, level))
      return tag..(func or globerr(t, level))
    elseif ttype == "table" then
      if level >= maxl then return tag..'{}'..comment('max', level) end
      seen[t] = spath
      if next(t) == nil then return tag..'{}'..comment(t, level) end -- table empty
      local maxn, o, out = #t, {}, {}
      for key = 1, maxn do table.insert(o, key) end
      for key in pairs(t) do if not o[key] then table.insert(o, key) end end
      if opts.sortkeys then alphanumsort(o, opts.sortkeys) end
      for n, key in ipairs(o) do
        local value, ktype, plainindex = t[key], type(key), n <= maxn and not sparse
        if opts.ignore and opts.ignore[value] -- skip ignored values; do nothing
        or sparse and value == nil then -- skipping nils; do nothing
        elseif ktype == 'table' or ktype == 'function' then
          if not seen[key] and not globals[key] then
            table.insert(sref, 'local '..val2str(key,gensym(key),indent)) end
          table.insert(sref, seen[t]..'['..(seen[key] or globals[key] or gensym(key))
            ..']'..space..'='..space..(seen[value] or val2str(value,nil,indent)))
        else
          if badtype[ktype] then plainindex, key = true, '['..globerr(key, level+1)..']' end
          table.insert(out,val2str(value,key,indent,spath,plainindex,level+1))
        end
      end
      local prefix = string.rep(indent or '', level)
      local head = indent and '{\n'..prefix..indent or '{'
      local body = table.concat(out, ','..(indent and '\n'..prefix..indent or space))
      local tail = indent and "\n"..prefix..'}' or '}'
      return (custom and custom(tag,head,body,tail) or tag..head..body..tail)..comment(t, level)
    else return tag..safestr(t) end -- handle all other types
  end
  local sepr = indent and "\n" or ";"..space
  local body = val2str(t, name, indent) -- this call also populates sref
  local tail = #sref>0 and table.concat(sref, sepr)..sepr or ''
  return not name and body or "do local "..body..sepr..tail.."return "..name..sepr.."end"
end

local function merge(a, b) if b then for k,v in pairs(b) do a[k] = v end end; return a; end
return { _NAME = n, _COPYRIGHT = c, _DESCRIPTION = d, _VERSION = v, serialize = s,
  dump = function(a, opts) return s(a, merge({name = '_', compact = true, sparse = true}, opts)) end,
  line = function(a, opts) return s(a, merge({sortkeys = true, comment = true}, opts)) end,
  block = function(a, opts) return s(a, merge({indent = '  ', sortkeys = true, comment = true}, opts)) end }
end)() ---- end of Serpent module

local function stack(start)
  local function vars(f)
    local func = debug.getinfo(f, "f").func
    local i = 1
    local locals = {}
    while true do
      local name, value = debug.getlocal(f, i)
      if not name then break end
      if string.sub(name, 1, 1) ~= '(' then locals[name] = {value, tostring(value)} end
      i = i + 1
    end
    i = 1
    local ups = {}
    while func and true do -- check for func as it may be nil for tail calls
      local name, value = debug.getupvalue(func, i)
      if not name then break end
      ups[name] = {value, tostring(value)}
      i = i + 1
    end
    return locals, ups
  end

  local stack = {}
  for i = (start or 0), 100 do
    local source = debug.getinfo(i, "Snl")
    if not source then break end
    table.insert(stack, {
      {source.name, source.source, source.linedefined,
       source.currentline, source.what, source.namewhat, source.short_src},
      vars(i+1)})
    if source.what == 'main' then break end
  end
  return stack
end

local function set_breakpoint(file, line)
  if file == '-' and lastfile then file = lastfile end
  if not breakpoints[file] then
    breakpoints[file] = {}
  end
  breakpoints[file][line] = true  
end

local function remove_breakpoint(file, line)
  if file == '-' and lastfile then file = lastfile end
  if breakpoints[file] then
    breakpoints[file][line] = nil
  end
end

local function has_breakpoint(file, line)
  return breakpoints[file] and breakpoints[file][line]
end

local function restore_vars(vars)
  if type(vars) ~= 'table' then return end
  local func = debug.getinfo(3, "f").func
  local i = 1
  local written_vars = {}
  while true do
    local name = debug.getlocal(3, i)
    if not name then break end
    if string.sub(name, 1, 1) ~= '(' then debug.setlocal(3, i, vars[name]) end
    written_vars[name] = true
    i = i + 1
  end
  i = 1
  while true do
    local name = debug.getupvalue(func, i)
    if not name then break end
    if not written_vars[name] then
      if string.sub(name, 1, 1) ~= '(' then debug.setupvalue(func, i, vars[name]) end
      written_vars[name] = true
    end
    i = i + 1
  end
end

local function capture_vars()
  local vars = {}
  local func = debug.getinfo(3, "f").func
  local i = 1
  while true do
    local name, value = debug.getupvalue(func, i)
    if not name then break end
    if string.sub(name, 1, 1) ~= '(' then vars[name] = value end
    i = i + 1
  end
  i = 1
  while true do
    local name, value = debug.getlocal(3, i)
    if not name then break end
    if string.sub(name, 1, 1) ~= '(' then vars[name] = value end
    i = i + 1
  end
  setmetatable(vars, { __index = getfenv(func), __newindex = getfenv(func) })
  return vars
end

local function stack_depth(start_depth)
  for i = start_depth, 0, -1 do
    if debug.getinfo(i, "l") then return i+1 end
  end
  return start_depth
end

local function is_safe(stack_level, conservative)
  -- the stack grows up: 0 is getinfo, 1 is is_safe, 2 is debug_hook, 3 is user function
  if stack_level == 3 then return true end
  local main = debug.getinfo(3, "S").source

  for i = 3, stack_level do
    -- return if it is not safe to abort
    local info = debug.getinfo(i, "S")
    if not info then return true end
    if conservative and info.source ~= main or info.what == "C" then return false end
  end
  return true
end

local function debug_hook(event, line)
  if abort and is_safe(stack_level) then error(abort) end

  if event == "call" then
    stack_level = stack_level + 1
  elseif event == "return" or event == "tail return" then
    stack_level = stack_level - 1
  elseif event == "line" then

    -- check if we need to skip some callbacks (to save time)
    if skip then
      skipcount = skipcount + 1
      if skipcount < skip or not is_safe(stack_level) then return end
      skipcount = 0
    end

    -- this is needed to check if the stack got shorter.
    -- this may happen when "pcall(load, '')" is called
    -- or when "error()" is called in a function.
    -- in either case there are more "call" than "return" events reported.
    -- this validation is done for every "line" event, but should be
    -- "cheap" as it only checks for the stack to get shorter
    stack_level = stack_depth(stack_level)
    local caller = debug.getinfo(2, "S")

    -- grab the filename and fix it if needed
    local file = lastfile
    if (lastsource ~= caller.source) then
      lastsource = caller.source
      file = lastsource
      if string.find(file, "@") == 1 then file = string.sub(file, 2) end
      -- remove references to the current folder (./ or .\)
      if string.find(file, "%.[/\\]") == 1 then file = string.sub(file, 3) end
      -- fix filenames for loaded strings that may contain scripts with newlines
      if string.find(file, "\n") then
        file = string.sub(string.gsub(file, "\n", ' '), 1, 32) -- limit to 32 chars
      end
      file = string.gsub(file, "\\", "/") -- convert slash
      lastfile = file
    end

    local vars
    if (watchescnt > 0) then
      vars = capture_vars()
      for index, value in pairs(watches) do
        setfenv(value, vars)
        local status, res = pcall(value)
        if status and res then
          coroutine.resume(coro_debugger, events.WATCH, vars, file, line, index)
        end
      end
    end

    if step_into
    or (step_over and stack_level <= step_level)
    or has_breakpoint(file, line)
    or check_break and (socket.select({server}, {}, 0))[server] then
      vars = vars or capture_vars()
      check_break = true -- this is only needed to avoid breaking too early when debugging is starting
      step_into = false
      step_over = false
      local status, res = coroutine.resume(coro_debugger, events.BREAK, vars, file, line)

      -- handle 'stack' command that provides stack() information to the debugger
      if status and res == 'stack' then
        while status and res == 'stack' do
          -- resume with the stack trace and variables
          status, res = coroutine.resume(coro_debugger, events.STACK, stack(3), file, line)
        end
      end

      -- need to recheck once more as resume after 'stack' command may
      -- return something else (for example, 'exit'), which needs to be handled
      if status and res and res ~= 'stack' then
        if abort == nil and res == "exit" then os.exit(1) end
        abort = res
        -- only abort if safe; if not, there is another (earlier) check inside
        -- debug_hook, which will abort execution at the first safe opportunity
        if is_safe(stack_level) then error(abort) end
      end -- abort execution if requested
    end
    if vars then restore_vars(vars) end
  end
end

local function stringify_results(status, ...)
  if not status then return status, ... end -- on error report as it

  local t = {...}
  for i,v in pairs(t) do -- stringify each of the returned values
    t[i] = serpent.line(v, {nocode = true, comment = 1})
  end
  -- stringify table with all returned values
  -- this is done to allow each returned value to be used (serialized or not)
  -- intependently and to preserve "original" comments
  return status, serpent.dump(t, {sparse = false})
end

local function debugger_loop(sfile, sline)
  local command
  local app
  local eval_env = {}
  local function emptyWatch () return false end
  local loaded = {}
  for k in pairs(package.loaded) do loaded[k] = true end

  while true do
    local line, err
    if wx and server.settimeout then server:settimeout(0.1) end
    while true do
      line, err = server:receive()
      if not line and err == "timeout" then
        -- yield for wx GUI applications if possible to avoid "busyness"
        app = app or (wx and wx.wxGetApp and wx.wxGetApp())
        if app then
          local win = app:GetTopWindow()
          if win then
            -- process messages in a regular way
            -- and exit as soon as the event loop is idle
            win:Connect(wx.wxEVT_IDLE, function()
              win:Disconnect(wx.wxID_ANY, wx.wxID_ANY, wx.wxEVT_IDLE)
              app:ExitMainLoop()
            end)
            app:MainLoop()
          end
        end
      else
        break
      end
    end
    if server.settimeout then server:settimeout() end -- back to blocking
    command = string.sub(line, string.find(line, "^[A-Z]+"))
    if command == "SETB" then
      local _, _, _, file, line = string.find(line, "^([A-Z]+)%s+([%w%p%s]+)%s+(%d+)%s*$")
      if file and line then
        set_breakpoint(file, tonumber(line))
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "DELB" then
      local _, _, _, file, line = string.find(line, "^([A-Z]+)%s+([%w%p%s]+)%s+(%d+)%s*$")
      if file and line then
        remove_breakpoint(file, tonumber(line))
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "EXEC" then
      local _, _, chunk = string.find(line, "^[A-Z]+%s+(.+)$")
      if chunk then 
        local func, res = loadstring(chunk)
        local status
        if func then
          setfenv(func, eval_env)
          status, res = stringify_results(pcall(func))
        end
        if status then
          server:send("200 OK " .. string.len(res) .. "\n") 
          server:send(res)
        else
          server:send("401 Error in Expression " .. string.len(res) .. "\n")
          server:send(res)
        end
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "LOAD" then
      local _, _, size, name = string.find(line, "^[A-Z]+%s+(%d+)%s+([%w%p%s]*[%w%p]+)%s*$")
      size = tonumber(size)

      if abort == nil then -- no LOAD/RELOAD allowed inside start()
        if size > 0 then server:receive(size) end
        if sfile and sline then
          server:send("201 Started " .. sfile .. " " .. sline .. "\n")
        else
          server:send("200 OK 0\n")
        end
      else
        -- reset environment to allow required modules to load again
        -- remove those packages that weren't loaded when debugger started
        for k in pairs(package.loaded) do
          if not loaded[k] then package.loaded[k] = nil end
        end

        if size == 0 then -- RELOAD the current script being debugged
          server:send("200 OK 0\n")
          coroutine.yield("load")
        else
          local chunk = server:receive(size)
          if chunk then -- LOAD a new script for debugging
            local func, res = loadstring(chunk, name)
            if func then
              server:send("200 OK 0\n")
              debugee = func
              coroutine.yield("load")
            else
              server:send("401 Error in Expression " .. string.len(res) .. "\n")
              server:send(res)
            end
          else
            server:send("400 Bad Request\n")
          end
        end
      end
    elseif command == "SETW" then
      local _, _, exp = string.find(line, "^[A-Z]+%s+(.+)%s*$")
      if exp then 
        local func = loadstring("return(" .. exp .. ")")
        if func then
          watchescnt = watchescnt + 1
          local newidx = #watches + 1
          watches[newidx] = func
          server:send("200 OK " .. newidx .. "\n") 
        else
          server:send("400 Bad Request\n")
        end
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "DELW" then
      local _, _, index = string.find(line, "^[A-Z]+%s+(%d+)%s*$")
      index = tonumber(index)
      if index > 0 and index <= #watches then
        watchescnt = watchescnt - (watches[index] ~= emptyWatch and 1 or 0)
        watches[index] = emptyWatch
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "RUN" then
      server:send("200 OK\n")

      local ev, vars, file, line, idx_watch = coroutine.yield()
      eval_env = vars
      if ev == events.BREAK then
        server:send("202 Paused " .. file .. " " .. line .. "\n")
      elseif ev == events.WATCH then
        server:send("203 Paused " .. file .. " " .. line .. " " .. idx_watch .. "\n")
      elseif ev == events.RESTART then
        -- nothing to do
      else
        server:send("401 Error in Execution " .. string.len(file) .. "\n")
        server:send(file)
      end
    elseif command == "STEP" then
      server:send("200 OK\n")
      step_into = true

      local ev, vars, file, line, idx_watch = coroutine.yield()
      eval_env = vars
      if ev == events.BREAK then
        server:send("202 Paused " .. file .. " " .. line .. "\n")
      elseif ev == events.WATCH then
        server:send("203 Paused " .. file .. " " .. line .. " " .. idx_watch .. "\n")
      elseif ev == events.RESTART then
        -- nothing to do
      else
        server:send("401 Error in Execution " .. string.len(file) .. "\n")
        server:send(file)
      end
    elseif command == "OVER" or command == "OUT" then
      server:send("200 OK\n")
      step_over = true
      
      -- OVER and OUT are very similar except for 
      -- the stack level value at which to stop
      if command == "OUT" then step_level = stack_level - 1
      else step_level = stack_level end

      local ev, vars, file, line, idx_watch = coroutine.yield()
      eval_env = vars
      if ev == events.BREAK then
        server:send("202 Paused " .. file .. " " .. line .. "\n")
      elseif ev == events.WATCH then
        server:send("203 Paused " .. file .. " " .. line .. " " .. idx_watch .. "\n")
      elseif ev == events.RESTART then
        -- nothing to do
      else
        server:send("401 Error in Execution " .. string.len(file) .. "\n")
        server:send(file)
      end
    elseif command == "SUSPEND" then
      -- do nothing; it already fulfilled its role
    elseif command == "STACK" then
      -- yield back to debug hook to get stack information
      local ev, vars = coroutine.yield("stack")
      if ev == events.STACK then
        server:send("200 OK " .. serpent.dump(vars,
          {nocode = true, sparse = false}) .. "\n")
      else
        server:send("401 Error in Expression 0\n")
      end
    elseif command == "EXIT" then
      server:send("200 OK\n")
      coroutine.yield("exit")
    else
      server:send("400 Bad Request\n")
    end
  end
end

local function connect(controller_host, controller_port)
  return socket.connect(controller_host, controller_port)
end

local function isrunning()
  return coro_debugger and coroutine.status(coro_debugger) == 'suspended'
end

-- Starts a debug session by connecting to a controller
local function start(controller_host, controller_port)
  -- only one debugging session can be run (as there is only one debug hook)
  if isrunning() then return end

  server = socket.connect(controller_host, controller_port)
  if server then
    local info = debug.getinfo(2, "Sl")
    local file = info.source
    if string.find(file, "@") == 1 then file = string.sub(file, 2) end
    if string.find(file, "%.[/\\]") == 1 then file = string.sub(file, 3) end

    -- correct stack depth which already has some calls on it
    -- so it doesn't go into negative when those calls return
    -- as this breaks subsequence checks in stack_depth().
    -- start from 16th frame, which is sufficiently large for this check.
    stack_level = stack_depth(16)

    debug.sethook(debug_hook, "lcr")
    coro_debugger = coroutine.create(debugger_loop)
    return coroutine.resume(coro_debugger, file, info.currentline)
  else
    print("Could not connect to " .. controller_host .. ":" .. controller_port)
  end
end

local function controller(controller_host, controller_port)
  -- only one debugging session can be run (as there is only one debug hook)
  if isrunning() then return end

  local exitonerror = not skip -- exit if not running a scratchpad
  server = socket.connect(controller_host, controller_port)
  if server then
    local function report(trace, err)
      local msg = err .. "\n" .. trace
      server:send("401 Error in Execution " .. string.len(msg) .. "\n")
      server:send(msg)
      return err
    end

    coro_debugger = coroutine.create(debugger_loop)

    while true do 
      step_into = true
      abort = false
      if skip then skipcount = skip end -- to force suspend right away

      local coro_debugee = coroutine.create(debugee)
      debug.sethook(coro_debugee, debug_hook, "lcr")
      local status, err = coroutine.resume(coro_debugee)

      -- was there an error or is the script done?
      -- 'abort' state is allowed here; ignore it
      if abort then
        if tostring(abort) == 'exit' then break end
      else
        if status then -- normal execution is done
          break
        elseif err and not tostring(err):find(deferror) then
          -- report the error back
          -- err is not necessarily a string, so convert to string to report
          report(debug.traceback(coro_debugee), tostring(err))
          if exitonerror then break end
          -- resume once more to clear the response the debugger wants to send
          local status, err = coroutine.resume(coro_debugger, events.RESTART)
          if status and err == "exit" then break end
        end
      end
    end
    server:close()
  else
    print("Could not connect to " .. controller_host .. ":" .. controller_port)
    return false
  end
  return true
end

local function scratchpad(controller_host, controller_port, frequency)
  skip = frequency or 100
  return controller(controller_host, controller_port)
end

local function loop(controller_host, controller_port)
  skip = nil -- just in case if loop() is called after scratchpad()
  return controller(controller_host, controller_port)
end

local basedir = ""

-- Handles server debugging commands 
local function handle(params, client)
  local _, _, command = string.find(params, "^([a-z]+)")
  local file, line, watch_idx
  if command == "run" or command == "step" or command == "out"
  or command == "over" or command == "exit" then
    client:send(string.upper(command) .. "\n")
    client:receive() -- this should consume the first '200 OK' response
    local breakpoint = client:receive()
    if not breakpoint then
      print("Program finished")
      os.exit()
      return -- use return here for those cases where os.exit() is not wanted
    end
    local _, _, status = string.find(breakpoint, "^(%d+)")
    if status == "200" then
      -- don't need to do anything
    elseif status == "202" then
      _, _, file, line = string.find(breakpoint, "^202 Paused%s+([%w%p%s]+)%s+(%d+)%s*$")
      if file and line then 
        print("Paused at file " .. file .. " line " .. line)
      end
    elseif status == "203" then
      _, _, file, line, watch_idx = string.find(breakpoint, "^203 Paused%s+([%w%p%s]+)%s+(%d+)%s+(%d+)%s*$")
      if file and line and watch_idx then
        print("Paused at file " .. file .. " line " .. line .. " (watch expression " .. watch_idx .. ": [" .. watches[watch_idx] .. "])")
      end
    elseif status == "401" then 
      local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)$")
      if size then
        local msg = client:receive(tonumber(size))
        print("Error in remote application: " .. msg)
        os.exit(1)
        return nil, nil, msg -- use return here for those cases where os.exit() is not wanted
      end
    else
      print("Unknown error")
      os.exit(1)
      -- use return here for those cases where os.exit() is not wanted
      return nil, nil, "Debugger error: unexpected response '" .. breakpoint .. "'"
    end
  elseif command == "setb" then
    _, _, _, file, line = string.find(params, "^([a-z]+)%s+([%w%p%s]+)%s+(%d+)%s*$")
    if file and line then
      file = string.gsub(file, "\\", "/") -- convert slash
      file = string.gsub(file, basedir, '') -- remove basedir
      if not breakpoints[file] then breakpoints[file] = {} end
      client:send("SETB " .. file .. " " .. line .. "\n")
      if client:receive() == "200 OK" then 
        breakpoints[file][line] = true
      else
        print("Error: breakpoint not inserted")
      end
    else
      print("Invalid command")
    end
  elseif command == "setw" then
    local _, _, exp = string.find(params, "^[a-z]+%s+(.+)$")
    if exp then
      client:send("SETW " .. exp .. "\n")
      local answer = client:receive()
      local _, _, watch_idx = string.find(answer, "^200 OK (%d+)%s*$")
      if watch_idx then
        watches[watch_idx] = exp
        print("Inserted watch exp no. " .. watch_idx)
      else
        print("Error: Watch expression not inserted")
      end
    else
      print("Invalid command")
    end
  elseif command == "delb" then
    _, _, _, file, line = string.find(params, "^([a-z]+)%s+([%w%p%s]+)%s+(%d+)%s*$")
    if file and line then
      file = string.gsub(file, "\\", "/") -- convert slash
      file = string.gsub(file, basedir, '') -- remove basedir
      if not breakpoints[file] then breakpoints[file] = {} end
      client:send("DELB " .. file .. " " .. line .. "\n")
      if client:receive() == "200 OK" then 
        breakpoints[file][line] = nil
      else
        print("Error: breakpoint not removed")
      end
    else
      print("Invalid command")
    end
  elseif command == "delallb" then
    for file, breaks in pairs(breakpoints) do
      for line, _ in pairs(breaks) do
        client:send("DELB " .. file .. " " .. line .. "\n")
        if client:receive() == "200 OK" then 
          breakpoints[file][line] = nil
        else
          print("Error: breakpoint at file " .. file .. " line " .. line .. " not removed")
        end
      end
    end
  elseif command == "delw" then
    local _, _, index = string.find(params, "^[a-z]+%s+(%d+)%s*$")
    if index then
      client:send("DELW " .. index .. "\n")
      if client:receive() == "200 OK" then 
        watches[index] = nil
      else
        print("Error: watch expression not removed")
      end
    else
      print("Invalid command")
    end
  elseif command == "delallw" then
    for index, exp in pairs(watches) do
      client:send("DELW " .. index .. "\n")
      if client:receive() == "200 OK" then 
        watches[index] = nil
      else
        print("Error: watch expression at index " .. index .. " [" .. exp .. "] not removed")
      end
    end    
  elseif command == "eval" or command == "exec" 
      or command == "load" or command == "loadstring"
      or command == "reload" then
    local _, _, exp = string.find(params, "^[a-z]+%s+(.+)$")
    if exp or (command == "reload") then 
      if command == "eval" or command == "exec" then
        exp = (exp:gsub("%-%-%[(=*)%[.-%]%1%]", "") -- remove comments
                  :gsub("%-%-.-\n", " ") -- remove line comments
                  :gsub("\n", " ")) -- convert new lines
        if command == "eval" then exp = "return " .. exp end
        client:send("EXEC " .. exp .. "\n")
      elseif command == "reload" then
        client:send("LOAD 0 -\n")
      elseif command == "loadstring" then
        local _, _, _, file, lines = string.find(exp, "^([\"'])(.-)%1%s+(.+)")
        if not file then
           _, _, file, lines = string.find(exp, "^(%S+)%s+(.+)")
        end
        client:send("LOAD " .. string.len(lines) .. " " .. file .. "\n")
        client:send(lines)
      else
        local file = io.open(exp, "r")
        if not file then print("Cannot open file " .. exp); return end
        local lines = file:read("*all")
        file:close()

        local file = string.gsub(exp, "\\", "/") -- convert slash
        file = string.gsub(file, basedir, '') -- remove basedir
        client:send("LOAD " .. string.len(lines) .. " " .. file .. "\n")
        client:send(lines)
      end
      local params = client:receive()
      if not params then
        return nil, nil, "Debugger error: missing response after EXEC/LOAD"
      end
      local _, _, status, len = string.find(params, "^(%d+)[%w%p%s]+%s+(%d+)%s*$")
      if status == "200" then
        len = tonumber(len)
        if len > 0 then 
          local status, res
          local str = client:receive(len)
          -- handle serialized table with results
          local func, err = loadstring(str)
          if func then
            status, res = pcall(func)
            if not status then err = res
            elseif type(res) ~= "table" then
              err = "received "..type(res).." instead of expected 'table'"
            end
          end
          if err then
            print("Error in processing results: " .. err)
            return nil, nil, "Error in processing results: " .. err
          end
          print((table.unpack or unpack)(res))
          return res[1], res
        end
      elseif status == "201" then
        _, _, file, line = string.find(params, "^201 Started%s+([%w%p%s]+)%s+(%d+)%s*$")
      elseif status == "202" or params == "200 OK" then
        -- do nothing; this only happens when RE/LOAD command gets the response
        -- that was for the original command that was aborted
      elseif status == "401" then
        len = tonumber(len)
        local res = client:receive(len)
        print("Error in expression: " .. res)
        return nil, nil, res
      else
        print("Unknown error")
        return nil, nil, "Debugger error: unexpected response after EXEC/LOAD '" .. params .. "'"
      end
    else
      print("Invalid command")
    end
  elseif command == "listb" then
    for k, v in pairs(breakpoints) do
      local b = k .. ": " -- get filename
      for k in pairs(v) do
        b = b .. k .. " " -- get line numbers
      end
      print(b)
    end
  elseif command == "listw" then
    for i, v in pairs(watches) do
      print("Watch exp. " .. i .. ": " .. v)
    end    
  elseif command == "suspend" then
    client:send("SUSPEND\n")
  elseif command == "stack" then
    client:send("STACK\n")
    local resp = client:receive()
    local _, _, status, res = string.find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")
    if status == "200" then
      local func, err = loadstring(res)
      if func == nil then
        print("Error in stack information: " .. err)
        return nil, nil, err
      end
      local stack = func()
      for _,frame in ipairs(stack) do
        -- remove basedir from short_src or source
        local src = string.gsub(frame[1][2], "\\", "/") -- convert slash
        if string.find(src, "@") == 1 then src = string.sub(src, 2) end
        if string.find(src, "%./") == 1 then src = string.sub(src, 3) end
        frame[1][2] = string.gsub(src, basedir, '') -- remove basedir
        print(serpent.line(frame[1], {comment = false}))
      end
      return stack
    elseif status == "401" then
      local res = "Error in stack result"
      print(res)
      return nil, nil, res
    else
      print("Unknown error")
      return nil, nil, "Debugger error: unexpected response after STACK"
    end
  elseif command == "basedir" then
    local _, _, dir = string.find(params, "^[a-z]+%s+(.+)$")
    if dir then
      dir = string.gsub(dir, "\\", "/") -- convert slash
      if not string.find(dir, "/$") then dir = dir .. "/" end
      basedir = dir
      print("New base directory is " .. basedir)
    else
      print(basedir)
    end
  elseif command == "help" then
    print("setb <file> <line>    -- sets a breakpoint")
    print("delb <file> <line>    -- removes a breakpoint")
    print("delallb               -- removes all breakpoints")
    print("setw <exp>            -- adds a new watch expression")
    print("delw <index>          -- removes the watch expression at index")
    print("delallw               -- removes all watch expressions")
    print("run                   -- runs until next breakpoint")
    print("step                  -- runs until next line, stepping into function calls")
    print("over                  -- runs until next line, stepping over function calls")
    print("out                   -- runs until line after returning from current function")
    print("listb                 -- lists breakpoints")
    print("listw                 -- lists watch expressions")
    print("eval <exp>            -- evaluates expression on the current context and returns its value")
    print("exec <stmt>           -- executes statement on the current context")
    print("load <file>           -- loads a local file for debugging")
    print("reload                -- restarts the current debugging session")
    print("stack                 -- reports stack trace")
    print("basedir [<path>]      -- sets the base path of the remote application, or shows the current one")
    print("exit                  -- exits debugger")
  else
    local _, _, spaces = string.find(params, "^(%s*)$")
    if not spaces then
      print("Invalid command")
      return nil, nil, "Invalid command"
    end
  end
  return file, line
end

-- Starts debugging server
local function listen(host, port)

  local socket = require "socket"

  print("Lua Remote Debugger")
  print("Run the program you wish to debug")

  local server = socket.bind(host, port)
  local client = server:accept()

  client:send("STEP\n")
  client:receive()

  local breakpoint = client:receive()
  local _, _, file, line = string.find(breakpoint, "^202 Paused%s+([%w%p%s]+)%s+(%d+)%s*$")
  if file and line then
    print("Paused at file " .. file )
    print("Type 'help' for commands")
  else
    local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)%s*$")
    if size then
      print("Error in remote application: ")
      print(client:receive(size))
    end
  end

  while true do
    io.write("> ")
    local line = io.read("*line")
    handle(line, client)
  end
end

-- make public functions available
mobdebug.listen = listen
mobdebug.loop = loop
mobdebug.scratchpad = scratchpad
mobdebug.handle = handle
mobdebug.connect = connect
mobdebug.start = start
mobdebug.line = serpent.line
mobdebug.dump = serpent.dump

-- this is needed to make "require 'modebug'" to work when mobdebug
-- module is loaded manually
package.loaded.mobdebug = mobdebug

return mobdebug
