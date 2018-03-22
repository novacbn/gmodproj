local optlex = require "optlex"
local optparser = require "optparser"
local llex = require "llex"
local lparser = require "lparser"

local option = {
	["opt-locals"] = true;
	["opt-comments"] = true;
	["opt-entropy"] = true;
	["opt-whitespace"] = true;
	["opt-emptylines"] = true;
	["opt-eols"] = true;
	["opt-strings"] = true;
	["opt-numbers"] = true;
	}

function minify_string(dat)
	llex.init(dat)
	llex.llex()
	local toklist, seminfolist, toklnlist
	= llex.tok, llex.seminfo, llex.tokln
	if option["opt-locals"] then
		optparser.print = print  -- hack
		lparser.init(toklist, seminfolist, toklnlist)
		local globalinfo, localinfo = lparser.parser()
		optparser.optimize(option, toklist, seminfolist, globalinfo, localinfo)
	end
	optlex.print = print  -- hack
	toklist, seminfolist, toklnlist
		= optlex.optimize(option, toklist, seminfolist, toklnlist)
	local dat = table.concat(seminfolist)
	-- depending on options selected, embedded EOLs in long strings and
	-- long comments may not have been translated to \n, tack a warning
	if string.find(dat, "\r\n", 1, 1) or
		string.find(dat, "\n\r", 1, 1) then
		optlex.warn.mixedeol = true
	end
	return dat;
end

return {
	minify_string = minify_string
}