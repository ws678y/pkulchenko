-- authors: Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------

local binpath = os.getenv("GLSLC_BIN_PATH")

return binpath and {
  fninit = function(frame,menuBar)
    binpath = ide.config.path.glslcbin or os.getenv("GLSLC_BIN_PATH")

    local myMenu = wx.wxMenu{
      { ID "glslc.compile.input", "&Custom Args\tCtrl-L", "when set a popup for custom compiler args will be envoked", wx.wxITEM_CHECK },
      { ID "glslc.compile.separable", "Separable", "when set separable programs are not used", wx.wxITEM_CHECK },
      { },
      { ID "glslc.compile.vertex", "Compile &Vertex\tCtrl-1", "Compile Vertex program" },
      { ID "glslc.compile.fragment", "Compile &Fragment\tCtrl-2", "Compile Fragment program" },
      { ID "glslc.compile.geometry", "Compile &Geometry\tCtrl-3", "Compile Geometry program" },
      { ID "glslc.compile.tessctrl", "Compile T.Ctrl\tCtrl-4", "Compile T.Ctrl program" },
      { ID "glslc.compile.tesseval", "Compile T.Eval\tCtrl-5", "Compile T.Eval program" },
      { ID "glslc.compile.compute", "Compile Compute\tCtrl-6", "Compile Compute program" },
      { },
      { ID "glslc.format.asm", "Annotate ASM", "indent and add comments to ASM output" },
    }
    menuBar:Append(myMenu, "&GLSL")

    local data = {}
    data.customarg = false
    data.separable = false
    data.custom = ""
    data.domains = {
      [ID "glslc.compile.vertex"]   = 1,
      [ID "glslc.compile.fragment"] = 2,
      [ID "glslc.compile.geometry"] = 3,
      [ID "glslc.compile.tessctrl"] = 4,
      [ID "glslc.compile.tesseval"] = 5,
      [ID "glslc.compile.compute"]  = 6,        
    }
    data.domainprofiles = {
      "vertex",
      "fragment",
      "geometry",
      "tesscontrol",
      "tessevaluation",
      "compute",        
    }
    data.domaindefs = {
      " -D_VERTEX_ ",
      " -D_FRAGMENT_ ",
      " -D_GEOMETRY_ ",
      " -D_TESS_CONTROL_ ",
      " -D_TESS_EVAL_ ",
      " -D_COMPUTE_ ",
    }

    local function beautifyAsm(tx)
      local newtx = ""
      local indent = 0
      local maxindent = 0
      local startindent = {
        ["IF"]=true,["REP"]=true,["ELSE"]=true,["LOOP"]=true,["BB"]=true,
      }
      local endindent = {
        ["ENDIF"]=true,["ENDREP"]=true,["ELSE"]=true,["ENDLOOP"]=true,["END"]=true,["RET"]=true,
      }

      local function checknesting(str,tab)
        local res
        local chk = str:match("%s*(BB)%d+.*:")
        chk = chk or str:match("%s*(%w+)")
        res = chk and tab[chk] and chk

        return res
      end

      local argregistry = {}
      local argbuffersfixed = false

      local registercc = 0
      local registermem = 0
      local registers = 0
      local instructions = 0

      local function fixargbuffers()
        if (argbuffersfixed) then return end

        local argnew = {}
        for i,v in pairs(argregistry) do
          local buf,bufstart = string.match(i,"buf(%d+)%[(%d+)%]")
          if (buf and bufstart) then
            bufstart = tonumber(bufstart)/16
            argnew["buf"..buf.."["..tostring(bufstart).."]"] = v
          else
            argnew[i] = v
          end
        end
        argregistry = argnew
        argbuffersfixed = true
      end

      local function checkregistry(w)
        local regsuccess = true

        local vtype,vname,sem,resource,pnum,pref = string.match(w,"#var ([_%w]+) ([%[%]%._%w]+) : ([^%:]*) : ([^%:]*) : ([^%:]*) : (%d*)")
        local funcname,subroutine = string.match(w,"#function %d+ ([_%w]+)%((%d+)%)")
        if (pref == "1") then
          local descriptor = vtype.." "..vname

          -- check if resource is array
          local resstart,rescnt = string.match(resource,"c%[(%d+)%], (%d+)")
          resstart = tonumber(resstart)
          rescnt = tonumber(rescnt)

          -- check if resource is buffer/buffer array
          local buf,bufstart,bufcnt = string.match(resource,"buffer%[(%d+)%]%[(%d+)%],? ?(%d*)")
          buf = tonumber(buf)
          bufstart = tonumber(bufstart)
          bufcnt = tonumber(bufcnt)

          -- check if texture
          local texnum = string.match(resource,"texunit (%d+)")

          local argnames = {}
          if (rescnt) then
            for i=0,(rescnt-1) do
              table.insert(argnames,"c["..tostring(resstart + i).."]")
            end
          elseif (texnum) then
            table.insert(argnames,"texture["..tostring(texnum).."]")
            table.insert(argnames,"texture"..tostring(texnum))
          elseif (buf) then
            table.insert(argnames,"buf"..tostring(buf).."["..tostring(bufstart).."]")
          else
            table.insert(argnames,resource)
          end

          for i,v in ipairs(argnames) do
            argregistry[v] = descriptor
          end
        elseif (funcname and subroutine) then
          argregistry["SUBROUTINENUM("..subroutine..")"] = "function "..funcname
        elseif string.find(w,"BUFFER4 ") then
          fixargbuffers()
        elseif string.find(w,"TEMP ") then
          --TEMP R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11;
          --TEMP RC, HC;
          --TEMP lmem[9];
          for i in string.gmatch(w,"C") do
            registercc = registercc + 1
          end
          for i in string.gmatch(w,"R%d+") do
            registers = registers + 1
          end
          registermem = tonumber(string.match(w,"lmem%[(%d+)%]"))
        elseif (string.find(w,"CBUFFER ") or string.find(w,"ATTRIB ") or string.find(w,"OPTION ") or 
                string.find(w,"OUTPUT ") or string.find(w,"PARAM ") or string.find(w,"!!NV")) then
          
        else
          regsuccess = false
        end

        return regsuccess
      end

      local function checkargs(str)
        local comment = "#"
        local declared = {}
        for i in string.gmatch(str,"([%[%]%(%)%w]+)") do
          local descr = argregistry[i]
          if (descr and not declared[i]) then
            comment = comment.." "..i.." = "..descr
            declared[i] = true
          end
        end

        return comment ~= "#" and comment
      end

      local registerlevels = {{}}
      local function checkregisters(str,indent)
        if (indent < 0) then return end
        local cur = registerlevels[indent+1]
        for i in string.gmatch(str,"R(%d+)") do
          cur[i] = true
        end
      end

      local function clearregisters(indent)
        registerlevels[math.max(0,indent)+1] = {}
      end

      local function outputregisters(indent)
        if (indent < 0) then return "" end
        local tab = registerlevels[indent+1]
        local out = {}
        for i,v in pairs(tab) do
          table.insert(out,i)
        end
        table.sort(out)
        local cnt = #out
        if (cnt < 1) then return "" end

        local str = string.rep(" ",indent).."# "..tostring(cnt).." R used: "
        for i,v in ipairs(out) do
          str = str..tostring(v)..((i==cnt) and "" or ", ")
        end
        return str.."\n"
      end

      -- check declarations
      local lastline = ""
      local addinstr = false
      for w in string.gmatch(tx, "[^\n]*\n") do
        if (not checkregistry(w)) then
          
          if (not w:match("%s*#")) then
            instructions = instructions + 1
          end

          if (checknesting(w,endindent)) then
            newtx = newtx..outputregisters(indent)
            if (indent == 0) then clearregisters(indent) end
            indent = math.max(0,indent - 1)
          end

          local firstchar = string.sub(w,1,1)
          local indentstr = (firstchar ~= " " and firstchar ~= "\t" and string.rep(" ",indent) or "")
          local linestr = indentstr..w
          local argcomment = (firstchar ~= "#") and checkargs(w)

          checkregisters(w,indent)

          newtx = newtx..(argcomment and (indentstr..argcomment.."\n") or "")
          newtx = newtx..linestr

          if (checknesting(w,startindent)) then
            indent = indent + 1
            maxindent = math.max(maxindent,indent)
            clearregisters(indent)
          end
        else
          newtx = newtx..w
        end
        lastline = w
      end

      local registers = tonumber(string.match(lastline, "(%d+) R%-regs")) or registers
      registermem = registermem or 0
      registercc = registercc or 0
      local stats = "# "..instructions.." instructions\n"
      stats = stats.."# "..registers.." R-regs\n"
      stats = stats.."# "..tostring(registercc).." C-regs, "..tostring(registermem).." L-regs\n"
      stats = stats.."# "..tostring(registercc + registermem + registers).." maximum registers\n"
      stats = stats.."# "..maxindent.." maximum nesting level\n"
      newtx = newtx..stats

      return newtx,stats
    end

    local function beautifyAsmFile(filePath)
      local file_text = ""
      local statlines = ""
      local handle = io.open(filePath, "rb")
      if handle then
        file_text = handle:read("*a")
        file_text,statlines = beautifyAsm(file_text)
        handle:close()
      end

      if (file_text == "") then return end

      local handle = io.open(filePath, "wb")
      if handle then
        handle:write(file_text)
        handle:close()
      end
      return statlines
    end

    -- Compile Arg
    frame:Connect(ID "glslc.compile.input",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.customarg = event:IsChecked()
      end)
    
    frame:Connect(ID "glslc.compile.separable",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.separable = event:IsChecked()
      end)
    

    -- Compile
    local function evCompile(event)
      local filename,info = GetEditorFileAndCurInfo()
      local editor = GetEditor()
      local glsl = true

      if (not (filename and binpath)) then
        DisplayOutput("Error: GLSL Compile: Insufficient parameters (nofile)\n")
        return
      end

      local domain = data.domains[event:GetId()]
      local profile = data.domainprofiles[domain]

      -- popup for custom input
      data.custom = data.customarg and wx.wxGetTextFromUser("Compiler Args","GLSLC",data.custom) or data.custom
      local args = data.customarg and data.custom or ""
      args = args:len() > 0 and args or nil

      local fullname  = filename:GetFullPath()
      local outname = fullname..".main^"
      outname = args and outname..args:gsub("%s*[%-%/]",";-")..";^" or outname
      outname = outname..profile..".glp"
      outname = '"'..outname..'"'

      local cmdline = "-profile "..profile.." "
      cmdline = args and cmdline..args.." " or cmdline
      cmdline = cmdline..(data.separable and "-separable " or "")
      cmdline = cmdline..data.domaindefs[domain].." "
      cmdline = cmdline.."-o "..outname.." "
      cmdline = cmdline..'"'..fullname..'"'
      cmdline = binpath.."/glslc.exe "..cmdline

      local function compilecallback(str)
        local postfunc
        -- check for errors, if none, launch nvperf
        -- and indentation
        if (string.find(str,"successfully compiled")) then
          postfunc = function()
            -- beautify asm
            if (true) then
              local statlines = beautifyAsmFile(outname:sub(2,-2))
              DisplayOutput(statlines)
            end
          end
        end

        return str,postfunc
      end

      -- run compiler process
      CommandLineRun(cmdline,nil,true,nil,compilecallback)

    end

    frame:Connect(ID "glslc.compile.vertex",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "glslc.compile.fragment",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "glslc.compile.geometry",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "glslc.compile.tessctrl",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "glslc.compile.tesseval",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "glslc.compile.compute",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)

    -- indent asm
    frame:Connect(ID "glslc.format.asm", wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        local curedit = GetEditor()
        local newtx = beautifyAsm( curedit:GetText() )

        curedit:SetText(newtx)
      end)
  end,
}
