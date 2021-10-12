return {
		name = "Luxinia",
		description = "Luxinia project",
		fcmdline = function(filepath) 
				local endstr = ide.config.path.projectdir and ide.config.path.projectdir:len()>0
							and " -p "..ide.config.path.projectdir or ""
				
				return ide.config.path.luxinia..'luxinia.exe --nologo'..endstr
			end,
		fworkdir = function() end, -- overriden by luxinia anyway
		capture = true,
		nohide  = true,
		fprojdir = function(fname)
				local path = GetPathWithSep(fname)
				fname = wx.wxFileName(path)
				
				while ((not wx.wxFileExists(path.."main.lua")) and (fname:GetDirCount() > 0)) do
					fname:RemoveDir(fname:GetDirCount()-1)
					path = GetPathWithSep(fname)
				end
				
				return path:sub(0,-2)
			end,
	}