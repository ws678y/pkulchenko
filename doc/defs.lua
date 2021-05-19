-- About
-- ----------------------------------------------------
-- This file contains lua table definitons used by
-- automatic loaded files, not part of the 
-- editor source.
--
-- /cfg/config.lua
-- /cfg/user.lua
-- /spec/*.lua
-- /tools/*.lua
-- /api/*<apitype>/*.lua


-- style definition
-- ----------------------------------------------------
-- all entries are optiona
stattr = {
	fg = {r,g,b}, -- foreground color 0-255
	bg = {r,g,b}, -- background color
	i = false,	  -- italic
	b = false,	  -- bold
	u = false,	  -- underline
	fill = true,  -- fill to lineend
}

style = {
	-- lexer specific (inherit fg/bg from text)
	lexerdef	 	= stattr,
	comment 		= stattr,
	stringtxt 		= stattr,
	stringeol 		= stattr,
	preprocessor	= stattr,
	operator 		= stattr,
	number 			= stattr,
	
	keywords0		= stattr,
	keywords1		= stattr,
	keywords2		= stattr,
	keywords3		= stattr,
	keywords4		= stattr,
	keywords5		= stattr,
	keywords6		= stattr,
	keywords7		= stattr,
	
	-- common (inherit fg/bg from text)
	text 			= stattr,
	linenumber 		= stattr,
	bracematch 		= stattr,
	bracemiss 		= stattr,
	escapechar 		= stattr,
	indent 			= stattr,
	calltip 		= stattr,
	
	-- common special (need custom fg & bg )
	calltipbg		= nil,
	sel				= nil,
	caret			= nil,
	caretlinebg		= nil,
	fold			= nil,
	whitespace 		= nil,
	
}

-- config definition
-- ----------------------------------------------------
-- tables must exist
-- content is optional
-- config is loaded into existing config table
config = {
	path = {
		-- path for tools/interpreters
		luxinia = "C:/luxbin/",
			-- path to luxinia exe
			
		projectdir = "",
			-- the project directory, used by 
			-- some tools/interpreters
	}, 
	editor = {
		fontname = "Courier New",
			-- default font 
			
		caretline = true,
			-- show active line
	},
	
	styles = {},
		-- styles table as above for editor
		
	stylesoutshell = {},
		-- styles for output/shell
		
	interpreter = "EstrelaEditor",
		-- the default "project" lua interpreter
		-- EstrelaEditor, Luxinia, Lua
		
	autocomplete = true,
		-- whether autocomplete is on by default
		
	savebak = false,
		-- if bak files are created on save
		
	filehistorylength = 20,
		-- historylength for files
		
	projecthistorylength = 15,
		-- historylength for project directories

	singleinstance = true,
		-- if true creates a UDP server to exchange messages
		-- for loading commandline passed files
		
	singleinstanceport = 0xe493,
		-- UDP port for single instance communication
}




-- api definition
-- ----------------------------------------------------

-- TODO



-- spec definition
-- ----------------------------------------------------
-- all entries are optional
spec = {
	exts = {"ext","ext2",..},   
		-- compatible extensions
		
	lexer = wxstc.wxSTC_LEX_LUA,
		-- scintilla lexer
		
	lexerstyleconvert = {
		-- table mapping each styles to
		-- appropriate lexer id
		stringeol 	= {wxstc.wxSTC_LUA_STRINGEOL,},
		-- ...
	}
		
	linecomment = "//",			
		-- string for linecomments
		
	apitype = "api",			
		-- which sub directory of "api" is relevant
		-- api files handle autocomplete and tooltips
		-- api won't affect syntax coloring
		
	keywords = {
		-- up to 8 strings containing space separated keywords
		-- used by the lexer for coloring (NOT for autocomplete).
		-- however each lexer supports varying amount 
		-- of keyword types
		
		"foo bar word",
		"more words",
	}
}

-- tool definition
-- ----------------------------------------------------
-- main entries are optional
tool = {
	fninit = function(frame,menubar) end,	
		-- guarantees that ide is initialized
		-- can be used for init
		-- and adding custom menu
	
	exec = {
		-- quick exec action, listed under "Tools" menu
		name = "",
		description = "",
		fn = function(wxfilename,projectdir) end,
	}
}