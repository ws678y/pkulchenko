-- This is a file that sets color scheme based on Tomorrow format.
-- Copyright 2011-12 Paul Kulchenko, ZeroBrane LLC

-- Tomorrow colors are from https://github.com/chriskempson/tomorrow-theme
-- Zenburn colors are from https://github.com/jnurmine/Zenburn/blob/master/colors/zenburn.vim (contributed by Srdjan Marković)

local theme = ...
local function h2d(n) return 0+('0x'..n) end
local H = function(c) return {h2d(c:sub(1,2), 16), h2d(c:sub(3,4), 16), h2d(c:sub(5,6), 16)} end
-- add more of the specified color (keeping all in 0-255 range)
local mixer = function(c, n, more)
  if not c or #c == 0 then return c end
  local c = {c[1], c[2], c[3]} -- create a copy, so it can be modified
  c[n] = c[n] + more
  local excess = c[n] - 255
  if excess > 0 then
    for clr = 1, 3 do
      c[clr] = n == clr and 255 or c[clr] > excess and c[clr] - excess or 0
    end
  end
  return c
end

local colors = {
  Tomorrow = {
    Background  = H'ffffff',
    CurrentLine = H'efefef',
    Selection   = H'd6d6d6',
    Foreground  = H'4d4d4c',
    Comment     = H'8e908c',
    Red         = H'c82829',
    Orange      = H'f5871f',
    Yellow      = H'eab700',
    Green       = H'718c00',
    Aqua        = H'3e999f',
    Blue        = H'4271ae',
    Purple      = H'8959a8',
  },
  TomorrowNight = {
    Background  = H'1d1f21',
    CurrentLine = H'282a2e',
    Selection   = H'373b41',
    Foreground  = H'c5c8c6',
    Comment     = H'969896',
    Red         = H'cc6666',
    Orange      = H'de935f',
    Yellow      = H'f0c674',
    Green       = H'b5bd68',
    Aqua        = H'8abeb7',
    Blue        = H'81a2be',
    Purple      = H'b294bb',
  },
  TomorrowNightEighties = {
    Background  = H'2d2d2d',
    CurrentLine = H'393939',
    Selection   = H'515151',
    Foreground  = H'cccccc',
    Comment     = H'999999',
    Red         = H'f2777a',
    Orange      = H'f99157',
    Yellow      = H'ffcc66',
    Green       = H'99cc99',
    Aqua        = H'66cccc',
    Blue        = H'6699cc',
    Purple      = H'cc99cc',
  },
  TomorrowNightBlue = {
    Background  = H'002451',
    CurrentLine = H'00346e',
    Selection   = H'003f8e',
    Foreground  = H'ffffff',
    Comment     = H'7285b7',
    Red         = H'ff9da4',
    Orange      = H'ffc58f',
    Yellow      = H'ffeead',
    Green       = H'd1f1a9',
    Aqua        = H'99ffff',
    Blue        = H'bbdaff',
    Purple      = H'ebbbff',
  },
  TomorrowNightBright = {
    Background  = H'000000',
    CurrentLine = H'2a2a2a',
    Selection   = H'424242',
    Foreground  = H'eaeaea',
    Comment     = H'969896',
    Red         = H'd54e53',
    Orange      = H'e78c45',
    Yellow      = H'e7c547',
    Green       = H'b9ca4a',
    Aqua        = H'70c0b1',
    Blue        = H'7aa6da',
    Purple      = H'c397d8',
  },
  Zenburn = {
    Background  = H'3f3f3f',
    CurrentLine = H'363636',
    Selection   = H'1f1f1f',
    Foreground  = H'dcdccc',
    Comment     = H'7f9f7f',
    Red         = H'8cd0d3',
    Orange      = H'dfaf8f',
    Yellow      = H'e3ceab',
    Green       = H'cc9393',
    Aqua        = H'dca3a3',
    Blue        = H'f0dfaf',
    Purple      = H'efef8f',
  },
}

local C = colors[theme] or colors.Tomorrow
return {
  -- wxstc.wxSTC_LUA_DEFAULT
  lexerdef = {fg = C.Foreground},
  -- wxstc.wxSTC_LUA_COMMENT, wxstc.wxSTC_LUA_COMMENTLINE, wxstc.wxSTC_LUA_COMMENTDOC
  comment = {fg = C.Comment, fill = true},
  -- wxstc.wxSTC_LUA_STRING, wxstc.wxSTC_LUA_CHARACTER, wxstc.wxSTC_LUA_LITERALSTRING
  stringtxt = {fg = C.Green},
  -- wxstc.wxSTC_LUA_STRINGEOL
  stringeol = {fg = C.Green, fill = true},
  -- wxstc.wxSTC_LUA_PREPROCESSOR
  preprocessor = {fg = C.Orange},
  -- wxstc.wxSTC_LUA_OPERATOR
  operator = {fg = C.Aqua},
  -- wxstc.wxSTC_LUA_NUMBER
  number = {fg = C.Red},

  -- wxstc.wxSTC_LUA_WORD, wxstc.wxSTC_LUA_WORD#
  keywords0 = {fg = C.Blue, b = true},
  keywords1 = {fg = C.Aqua, b = false},
  keywords2 = {fg = C.Aqua, b = true},
  keywords3 = {fg = C.Purple, b = true},
  keywords4 = {fg = C.Purple, b = true},
  keywords5 = {fg = C.Purple, b = true},
  keywords6 = {fg = C.Purple, b = true},
  keywords7 = {fg = C.Purple, b = true},

  -- common (inherit fg/bg from text)
  -- wxstc.wxSTC_LUA_IDENTIFIER
  text = {fg = C.Foreground, bg = C.Background},
  linenumber = {fg = C.Comment},
  bracematch = {fg = C.Orange, b = true},
  bracemiss = {fg = C.Red, b = true},
  ctrlchar = nil,
  indent = {fg = C.Foreground, bg = C.Background},
  calltip = nil,

  -- common special (need custom fg & bg)
  calltipbg = nil,
  sel = {bg = C.Selection},
  caret = {fg = C.Foreground},
  caretlinebg = {bg = C.CurrentLine},
  fold = {fg = C.Comment, bg = C.Background},
  whitespace = {fg = C.Comment, bg = C.Background},

  fncall = {fg = C.Purple, st = wxstc.wxSTC_INDIC_PLAIN},
  --[[ other possible values are:
    wxSTC_INDIC_PLAIN	 Single-line underline
    wxSTC_INDIC_SQUIGGLE Squiggly underline
    wxSTC_INDIC_TT	 Line of small T-shapes
    wxSTC_INDIC_DIAGONAL Diagonal hatching
    wxSTC_INDIC_STRIKE	 Strike-out
    wxSTC_INDIC_BOX      Box
    wxSTC_INDIC_ROUNDBOX Rounded Box (not suppored in the current version?)
  --]]

  -- markup
  ['['] = {hs = mixer(C.Comment, 3, 64)},
  ['|'] = {fg = mixer(mixer(C.Comment, 1, 64), 3, 64)},

  -- markers
  marker = {
    message = {bg = C.Selection},
    output = {bg = C.CurrentLine},
    prompt = {fg = C.Foreground, bg = C.Background},
    error = {bg = mixer(C.Background, 1, 32)},
  },
}
