local G = ... -- this now points to the global environment in the script

local env = {}
G.setmetatable(env, {__index = G})

local ide = G.ide
local postinit = ide.app.postinit
ide.app.postinit = function()
  if postinit then postinit() end

  -- load test module in the environment for tests
  local function testwell(report)
    local tw = require "testwell"
    if report then tw.report() end
  end
  setfenv(testwell, env)
  testwell()

  -- add a test function to detect loops
  function limit (limit, func)
    debug.sethook(function() error("exceeded") end, "", limit)
    local ok, res = pcall(func)
    debug.sethook()
    return ok, res
  end

  -- find all test files and load them
  local files = FileSysGetRecursive("t", true, "*.lua")
  for k, v in ipairs(files) do
    if v:find("[/\\]test%.lua$") then files[k] = nil end
  end
  table.sort(files)

  for _,file in ipairs(files) do
    local testfn, err = loadfile(file)
    if not testfn then
      print(("Error loading test file '%s': '%s'."):format(file, err))
    else
      setfenv(testfn, env)
      local ok, err = pcall(testfn)
      if not ok then
        print(("Error executing test file '%s': '%s'."):format(file, err))
      end
    end
  end

  testwell(true)
end

G.setfenv(ide.app.postinit, env)
