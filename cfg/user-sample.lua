--[[-- Copy required content from this file to `user.lua`

Configuration files are loaded in the following order

1. <application>\config.lua
2. cfg\user.lua
3. ~\.zbstudio\user.lua
4. -cfg commandline strings

--]]--

-- an example of how loaded configuration can be modified from this file
local G = ... -- this now points to the global environment in the script
local luaspec = G.ide.specs['lua']
luaspec.exts[#luaspec.exts+1] = "luaz"
luaspec.keywords[1] = luaspec.keywords[1] .. ' foo'

-- modify a key mapping; see the full list of IDs in src/editor/keymap.lua
local G = ...
keymap[G.ID_STARTDEBUG] = "Ctrl-Shift-D"

-- change font size to 12
editor.fontsize = 12 -- this is mapped to ide.config.editor.fontsize
editor.fontname = "Courier New"
filehistorylength = 20 -- this is mapped to ide.config.filehistorylength

-- specify full path to love2d *executable*; this is only needed
-- if the game folder and the executable are NOT in the same folder.
path.love2d = 'd:/lua/love/love'

-- specify full path to moai *executable* if it's not in one of PATH folders
path.moai = 'd:/lua/moai/moai'

-- specify full path to gideros *executable* if it's not in one of PATH folders
path.gideros = 'd:/Program Files/Gideros/GiderosPlayer.exe'

-- specify full path to corona *executable* if it's not in one of PATH folders
path.corona = 'd:/path/to/Corona SDK/Corona Simulator.exe'

-- specify full path to lua interpreter if you need to use your own version
path.lua = 'd:/lua/lua'

-- provide output filter for those engines that support redirecting
-- of "print" output to the IDE (like Corona SDK and Gideros)
debugger.outputfilter = function(m) return #m < 124 and m or m:sub(1,120).."...\n" end

-- fix an issue with 0d0d0a line endings in MOAI examples,
-- which may negatively affect breakpoints during debugging
editor.iofilter = "0d0d0aFix"

-- to have 4 spaces when TAB is used in the editor
editor.tabwidth = 4

-- to have TABs stored in the file (to allow mixing tabs and spaces)
editor.usetabs  = true

-- to disable wrapping of long lines in the editor
editor.usewrap = false

-- to turn dynamic words on and to start suggestions after 4 characters
acandtip.nodynwords = false
acandtip.startat = 4

-- to automatically open files requested during debugging
editor.autoactivate = true

-- specify a list of MOAI entrypoints
moai = { entrypoints = { "main.lua", "source/main.lua" } }

-- specify language to use in the IDE (requires a file in cfg/i18n folder)
language = "ru"

-- changing a background color (or other colors in the IDE);
-- see zbstudio/config.lua for example/details on what other colors to change
styles.text = {bg = {240,240,220}}
