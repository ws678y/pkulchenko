
ide.iofilters["GermanUtf8Ascii"] = {

-- this function converts some utf8 character output. It's a hack.
-- Since luxinia is not utf8 prepared, this is still necessary.
-- if you wish to turn this off, edit user.lua and set this filefunction to nil
output = function (fpath, content)
	local utf8escape = ("string").char(195)
	-- only simple cases are handled (umlauts)
	local chr = ("string").char
	local charconv = {
		[chr(164)] = chr(132), -- �
		[chr(182)] = chr(148), -- �
		[chr(188)] = chr(129), -- �
		[chr(132)] = chr(142), -- �
		[chr(150)] = chr(153), -- �
		[chr(156)] = chr(154), -- �
		[chr(159)] = chr(225), -- �
	}
	return content : gsub (utf8escape.."(.)",charconv)
end,


-- this function is another hack to read an ANSI encoded 
-- file and converts the umlauts to utf8 chars
input = function (fpath, content)
	local utf8escape = ("string").char(195)
	local chr = ("string").char
	local charconv = {
		[chr(132)] = utf8escape..chr(164), -- �
		[chr(148)] = utf8escape..chr(182), -- �
		[chr(129)] = utf8escape..chr(188), -- �
		[chr(142)] = utf8escape..chr(132), -- �
		[chr(153)] = utf8escape..chr(150), -- �
		[chr(154)] = utf8escape..chr(156), -- �
		[chr(225)] = utf8escape..chr(159), -- �
	}
	local lst = "["
	for k in pairs(charconv) do lst = lst .. k end
	lst = "]"
	
	return content:gsub(lst,charconv)
end,

}

--���

for i,filter in pairs(ide.iofilters) do
	assert(filter.output("",filter.input("","�������"),"�������","UTF8-ANSI conversion failed: "..(i))
end

-- which: "input" or "output"
function GetConfigIOFilter(which)
	local filtername = ide.config.editor.iofilter
	return (filtername and ide.iofilters[filtername] and ide.iofilters[filtername][which])
end

