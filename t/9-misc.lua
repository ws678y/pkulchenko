for _, ln in ipairs({'cn', 'de', 'eo', 'pt-br', 'es', 'fr', 'it', 'ru'}) do
  local func = loadfile(("cfg/i18n/%s.lua"):format(ln))
  ok(type(func) == 'function' and func() ~= nil, ("Loaded '%s' language file."):format(ln))
end

local fixed, invalid = FixUTF8("+\128\129\130+\194\127+", "+")
is(fixed, "++++++\127+", "Invalid UTF8 is fixed (1/2).")
is(#invalid, 4, "Invalid UTF8 is fixed (2/2).")

local UTF8s = {
  "ABCDE", -- 1 byte codes
  "\194\160\194\161\194\162\194\163\194\164", -- 2 byte codes
  "\225\160\160\225\161\161\225\162\162\225\163\163\225\164\164", -- 3 byte codes
}

for n, code in ipairs(UTF8s) do
  is(FixUTF8(code), code, ("Valid UTF8 code is left unmodified (%d/%d)."):format(n, #UTF8s))
end


local editor = NewFile()

for _, tst in ipairs({
  "_ = .1 + 1. + 1.1 + 0xa",
  "_ = 1e1 + 0xa.ap1",
  "_ = 0xabcULL + 0x1LL + 1LL + 1ULL",
  "_ = .1e1i + 0x1.1p1i + 0xa.ap1i",
}) do
  ok(AnalyzeString(tst) ~= nil,
    ("Numeric expression '%s' can be checked with static analysis."):format(tst))

  editor:SetText(tst)
  editor:ResetTokenList()
  while IndicateAll(editor) do end
  local defonly = true
  for _, token in ipairs(GetEditor():GetTokenList()) do
    if token.name ~= '_' then defonly = false end
  end
  ok(defonly == true, ("Numeric expression '%s' can be checked with inline parser."):format(tst))
end

ide:GetDocument(editor):SetModified(false)
ClosePage()

local at = ide:GetAccelerators()
ok(next(at) ~= nil, "One or more accelerator is set in the accelerator table.")
for id in pairs(at) do ide:SetAccelerator(id, nil) end
at = ide:GetAccelerators()
ok(next(at) == nil, "No accelerators are present after removing all of them.")

ide:SetHotKey(ID.STARTDEBUG, "F1")
is(ide:FindMenuItem(ID.STARTDEBUG):GetText():match("\t(.*)"), "F1", "`SetHotKey` sets the requested hotkey.")
ok(ide:FindMenuItem(ID.ABOUT):GetText():match("\t(.*)") == nil, "`SetHotKey` removes conflicted hotkey (1/2).")

ide:SetHotKey(ID.STARTDEBUG, "Ctrl+N") -- this should resolve conflict with `Ctrl-N`
ok(ide:FindMenuItem(ID.NEW):GetText():match("\t(.*)") == nil, "`SetHotKey` removes conflicted hotkey (2/2).")
