editor.caretline = true
editor.showfncall = true
editor.autotabs = false
editor.usetabs  = false
editor.tabwidth = 2
editor.usewrap = true
editor.calltipdelay = 500
editor.smartindent = true
editor.fold = true
editor.autoreload = true

local G = ... -- this now points to the global environment
local mac = G.ide.osname == 'Macintosh'
local win = G.ide.osname == "Windows"
if mac then
  local defaultsize = 11
  filetree.fontsize = defaultsize
  funclist.fontsize = defaultsize
  if G.ide.wxver >= "2.9.5" then
    editor.fontsize = defaultsize+1
    outputshell.fontsize = defaultsize
  end

  editor.fontname = "Monaco"
  outputshell.fontname = editor.fontname
else
  local defaultsize = 10
  editor.fontsize = defaultsize+1
  outputshell.fontsize = defaultsize

  local sysid, major, minor = G.wx.wxGetOsVersion()
  editor.fontname =
    win and (major == 5 and "Courier New" or "Consolas") or "Monospace"
  outputshell.fontname = editor.fontname
end

outputshell.usewrap = true
filehistorylength = 20

hidpi = mac -- support Retina displays by default (OSX)

singleinstance = not mac
singleinstanceport = 0xe493

acandtip.shorttip = true
acandtip.nodynwords = true

activateoutput = true
projectautoopen = true
autorecoverinactivity = 10
allowinteractivescript = true -- allow interaction in the output window

interpreter = "luadeb"
unhidewindow = { -- allow unhiding of GUI windows
  -- 1 - show if hidden, 0 - ignore, 2 -- hide if shown
  ConsoleWindowClass = 2,
  -- ignore the following windows when "showing all"
  IME = 0,
  ['MSCTFIME UI'] = 0,
  -- GLUT/opengl/SDL applications (for example, moai or love2d)
  GLUT = 1, FREEGLUT = 1, SDL_app = 1,
}
