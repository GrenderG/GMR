if not GMR then 
	GMR = {} 
end

GMR.ITEM_QUALITY_COLORS = {
	"9d9d9d",
	"ffffff",
	"1eff00",
	"0070dd",
	"a335ee",
	"ff8000",
	"e6cc80",
	"00ccff",
	"ff0000"
}

GMR.ITEM_QUALITY_COLORS[256] = SLib.ColorTable["Gold"]

function GMR.GetStringPixelLength(str, normalize, font)
	if not str then str = "" end
	if not font then font = "GameFontNormal" end
	if not GMR.TempObjects["getlength"] then
		local f = CreateFrame("Frame", nil , UIParent)
		GMR.TempObjects["getlength"] = f:CreateFontString("temp_font_string", "BACKGROUND",font)
	end
	GMR.TempObjects["getlength"]:SetFontObject(font)
	if normalize then str = normalize(str) end
	GMR.TempObjects["getlength"]:SetText(str)
	return GMR.TempObjects["getlength"]:GetStringWidth()
end

function GMR.GetWordsOffset(str, stack, normalize)
	--str: ---word1---word2---word3---word4---word1---word5---
	--stack:{word1, pos_at_str1}, {word2, pos_at_str2}, {word3, pos_at_str3}
	local word_offset_pix = {}
	local word_length = {}
	local temp_str
	for i = 1, getn(stack) do
		word_length[i] = GMR.GetStringPixelLength(stack[i][1], normalize)
		temp_str = string.sub(str, 1, stack[i][2])
		word_offset_pix[i] = GMR.GetStringPixelLength(temp_str, normalize)
	end
	return word_offset_pix, word_length
end

GMR.SyntaxInfo = {
	["separator"] = {
		[" "] = 1,
		["/"] = 1,
		["["] = 1,
		["]"] = 1,
		["("] = 1,
		[")"] = 1,
		["|"] = 1,
		["."] = 1,
		["\""] = 2,
	},
	["ignore"] = {
		[":"] = 1
	}
}

function GMR.GetStackType(var)
	local t_type = ""
	if not var or type(var) ~= "string" then
		return t_type
	end
	if string.find(var, "^(%$)") then
		t_type = "text"
	elseif string.find(var, "^(#)") then
		t_type = "number"
	elseif GMR.SyntaxInfo["separator"][var] then
		if var == "|" or var == "/" then
			t_type = "OR"
		elseif var == "[" or var == "(" then 
			t_type = "open"
		elseif var == "]" or var == ")" then
			t_type = "close"
		elseif var == "\"" then
			t_type = "quote"
		end
	else
		t_type = "option"
	end
	return t_type
end

function GMR.ParsingNormalize(str)
	
	local temp_str = str 
	 --bug with color, because | = \124 and |horde will be looks like start of color - so add space
	local cur_pointer = 0
	local prev_letter = " "
	local mask 					--catch case when word |= from debug command
	for letter in string.gfind(str, "(.)") do
		mask = (letter == "|" and gsub(str, cur_pointer+1, cur_pointer+2) == "=")
		if GMR.SyntaxInfo["separator"][letter] and prev_letter ~= " " and letter ~= " " and not mask then
			if letter == "|" then
				letter = "\124"
			end
			temp_str = string.sub(temp_str, 1, cur_pointer).." "..string.sub(temp_str, cur_pointer+1)
			cur_pointer = cur_pointer + 1
		elseif not GMR.SyntaxInfo["separator"][letter] and GMR.SyntaxInfo["separator"][prev_letter] and prev_letter ~= " " and prev_letter ~= "." then
			temp_str = string.sub(temp_str, 1, cur_pointer).." "..string.sub(temp_str, cur_pointer+1)
			cur_pointer = cur_pointer + 1
		end
		prev_letter = letter
		cur_pointer = cur_pointer + 1
	end	 
	--temp_str = gsub(temp_str, "(%-)", "_")			         --it's another fun bug of string.find, it's can't to work with - .  As example I have data from Tooltip "Multi-Shot" and from spellbook "Multi-Shot"; --I should change - to %- like gsub(spell_tooltip, "(%-)", "%%%-")
	return temp_str
end

function GMR.WordNormalize(word)
	local temp_word = word
	temp_word = gsub(temp_word, "(%$)", "")
	temp_word = gsub(temp_word, "(#)", "")	
	return temp_word
end

function GMR.ParseCommandBlock(arg_block)
	local stack = {}
	local word = ""
	local group_iter = 0
	local current_group = 0
	local read_process = true
	local pos_pointer = 0
	for letter in string.gfind(arg_block, "(.)") do
		if GMR.SyntaxInfo["separator"][letter] then
			if word ~= "" then
				stack[getn(stack) + 1] = {word, pos_pointer-strlen(word)}
				word = ""
				read_process = false
			end
			if letter == "|" and gsub(arg_block, pos_pointer+1, pos_pointer+2) == "=" and word == "" then
				word = "|"
			elseif letter ~= " " then
				stack[getn(stack) + 1] = {letter, pos_pointer}
			end
		elseif not GMR.SyntaxInfo["ignore"][letter] then
			word = word..letter
			read_process = true
		end
		pos_pointer = pos_pointer + 1
	end
	if read_process and word ~= "" then
		stack[getn(stack)+1] = {word, pos_pointer-strlen(word)}
	end
	return stack
end

function GMR.replace_func(a, word, b)
	--this func will make variables colored
	--give stack to gsub, all founded items will send here prev_letter, arg_stack[i], next_letter
	--colorlevel for level of brackets like ( [ () ] ) each level of itself color
	if (strlen(a)==0 or GMR.SyntaxInfo["separator"][a] or GMR.SyntaxInfo["ignore"][a]) and (strlen(b)==0 or GMR.SyntaxInfo["separator"][b] or GMR.SyntaxInfo["ignore"][b]) then
		if GMR.SyntaxInfo["separator"][word] then
			if word == "[" then 
				GMR.TempObjects["vartype"] = "optional" 
			elseif word == "]" then 
				GMR.TempObjects["vartype"]  = "musthave" 
			end
		else
			word = GMR.WordNormalize(word)
			if GMR.TempObjects["vartype"] and GMR.TempObjects["vartype"] == "optional" then
				color = SLib.ColorTable["Peru"]
			else
				color = SLib.ColorTable["Wheat"]
			end
			word = "\124cff"..color..word.."\124r"
		end
	end
	return a..word..b 
end

function GMR.ColorMarks(str, stack)
	local color
	local opt = false
	local cur_group = 0
	local color_groups = {}
	local t_type, var, var_l
	local space_isert = "" --for bugged cases as
	for i = getn(stack), 1, -1 do
		space_isert = ""
		if string.sub(str, stack[i][2]-1, stack[i][2]-1) == "\124" then
			space_isert = " "
		end
		var = stack[i][1]
		t_type = GMR.GetStackType(var)
		var_l = strlen(var)
		if t_type == "close" then
			cur_group = cur_group + 1
			--if not color_groups[cur_group] then
				color_groups[cur_group] = SLib.GetRandomColor()
			--end
			str = string.sub(str, 1, stack[i][2]-1)..space_isert..color_groups[cur_group]..var.."\124r"..string.sub(str, stack[i][2]+var_l+1)
			if var == "]" then opt = true end
		elseif t_type == "open" then
			if not color_groups[cur_group] then
				GMR.Print("Wrong bracket ballance: check syntax of the command end")
				GMR.Print([[Command args end when find first \n in string]])
				GMR.Print("Find command at Interface/Addons/GMR/GMR_command_data.lua")
				return str
			end
			str = string.sub(str, 1, stack[i][2]-1)..space_isert..color_groups[cur_group]..var.."\124r"..string.sub(str, stack[i][2]+var_l+1)
			cur_group = cur_group - 1
			if var == "[" then opt = false end
		elseif t_type == "text" or t_type == "number" or t_type == "option" then
			var = GMR.WordNormalize(var)
			if opt then 
				color = "\124cff"..SLib.ColorTable["Peru"]
			else 
				color = "\124cff"..SLib.ColorTable["Wheat"] 
			end
			str = string.sub(str, 1, stack[i][2])..color..var.."\124r"..string.sub(str, stack[i][2]+var_l+1)
		end
	end
	return str
end

GMR.CommandDataOnEnter = {
--[[
		examples:
		["command"] = ".account",
		["stack"] = {"$password", "|", "[", "#number", "]", "otheroption"},
		["tooltip"] = {"tooltip_colored_line1", "tooltip_colored_line2", "tooltip_colored_line3"},
		["command_original"]  = ".server idlerestart #delay" --not colored
		["command_for_print"] = ".server idlerestart delay"  --colored
]]
}

function GMR.SearchDescriptionVars(tooltip, command)
	if not command then
		GMR.Print("Something gone wrong, can't find command")
		return 1
	end
	local arg_block = ""
	if tooltip[1] then
		_, _, arg_block = string.find(tooltip[1], command.."(.+)" )
	end
	if not arg_block then
		arg_block = ""
	end
	arg_block = GMR.ParsingNormalize(arg_block)
	arg_block = gsub(arg_block, "(or Select a %w+)", "") --spec case for [$creature_id or Select a Creature]
	local args_stack = GMR.ParseCommandBlock(arg_block)
	local command_for_print
	command_for_print = "\124cff"..GMR.ITEM_QUALITY_COLORS[GMR_command_data[command][1]+1].."."..command.."\124r"
	command_for_print = command_for_print.." "..GMR.ColorMarks(arg_block, args_stack)

	for i = 1, getn(tooltip) do
		tooltip[i] = GMR.ParsingNormalize(tooltip[i])
		tooltip[i] = gsub(tooltip[i], "(%."..command..")", "\124cff"..GMR.ITEM_QUALITY_COLORS[GMR_command_data[command][1]+1].."."..command.."\124r")
		for j = 1, getn(args_stack) do
			local t_arg = args_stack[j][1]
			if GMR.SyntaxInfo["separator"][t_arg] then
				t_arg = "%"..t_arg
			end
			tooltip[i] = gsub(tooltip[i], "(.?)("..t_arg..")(.?)", GMR.replace_func)
		end
	end

	

	for key in pairs(GMR.CommandDataOnEnter) do
		GMR.CommandDataOnEnter[key] = nil
	end
	GMR.CommandDataOnEnter = {
		["command"] = command,
		["stack"] = args_stack,
		["tooltip"] = tooltip,
		["command_original"] = "."..command.." "..arg_block,
		["command_for_print"] = command_for_print
	}

	return tooltip
end

function GMR.HandleTooltip(tooltip)
	if type(tooltip) == "string" then
		local total_length = strlen(tooltip)
		local t_tooltip = {}
		local word, mymsg, curlength, flag, maxlength	
			mymsg = ""
			cur_pointer = 1
			curlength, flag, maxlength = 0, false, 100
			maxlength = total_length / (max(ceil(total_length/maxlength), 1))
			for word in string.gfind(tooltip, "([^%s]+)") do
				if curlength > maxlength then
					t_tooltip[getn(t_tooltip)+1] = mymsg
					curlength = 0
					mymsg = ""
					flag = false
				end
				curlength = curlength + strlen(word)
				mymsg = mymsg..word.." "
				flag = true
			end
		if flag then
			t_tooltip[getn(t_tooltip)+1] = mymsg
		end
		tooltip = t_tooltip
	end
	return tooltip
end