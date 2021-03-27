-- Equivalent to C's "cond ? a : b", all terms will be evaluated
function iff(cond, a, b) if cond then return a else return b end end

-- Does the num have all the bits in value
function HasBit(value, num)
	for n = 32, 0, -1 do
		local b = 2^n
		local num_b = num - b
		local value_b = value - b
		if num_b >= 0 then
			num = num_b
		else
			return true -- already tested bits in num
		end
		if value_b >= 0 then
			value = value_b
		end
		if (num_b >= 0) and (value_b < 0) then
			return false
		end
	end

	return true
end

-- ASCII values for common chars
char_CR  = string.byte("\r")
char_LF  = string.byte("\n")
char_Tab = string.byte("\t")
char_Sp  = string.byte(" ")

-- ----------------------------------------------------------------------------
-- Get file modification time, returns a wxDateTime (check IsValid) or nil if
--   the file doesn't exist
function GetFileModTime(filePath)
	if filePath and (string.len(filePath) > 0) then
		local fn = wx.wxFileName(filePath)
		if fn:FileExists() then
			return fn:GetModificationTime()
		end
	end

	return nil
end

function GetFileExt(filePath)
	local match = filePath and filePath:match("%.([a-zA-Z_0-9]+)$")
	return match and (string.lower(match))
end

function IsLuaFile(filePath)
	return filePath and (string.len(filePath) > 4) and
		   (string.lower(string.sub(filePath, -4)) == ".lua")
end

function GetPathWithSep(wxfn)
	return wxfn:GetPath(bit.bor(wx.wxPATH_GET_VOLUME, wx.wxPATH_GET_SEPARATOR))
end

function FileSysGet(dir,spec)
	local content = {}
	local browse = wx.wxFileSystem()
	local f = browse:FindFirst(dir,spec)
	while #f>0 do
		table.insert(content,f)
		f = browse:FindNext()
	end
	return content
end