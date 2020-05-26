--during some years of playing at Valkyrie server I had written a lot of interesting and fun stuff
--so this file contains some of that functions and mechanism, that current project need

if not SLib then 
	SLib = {}
end

SLib.ColorTable={
	["Aliceblue"]="F0F8FF",
	["Antiquewhite"]="FAEBD7",
	["Aqua"]="00FFFF",
	["Aquamarine"]="7FFFD4",
	["Azure"]="F0FFFF",
	["Beige"]="F5F5DC",
	["Bisque"]="FFE4C4",
	["Black"]="000000",
	["Blanchedalmond"]="FFEBCD",
	["Bluev"]="0000FF",
	["Blueviolet"]="8A2BE2",
	["Brown"]="A52A2A",
	["Burlywood"]="DEB887",
	["Cadetblue"]="5F9EA0",
	["Chartreuse"]="7FFF00",
	["Chocolate"]="D2691E",
	["Coral"]="FF7F50",
	["Cornflowerblue"]="6495ED",
	["Cornsilk"]="FFF8DC",
	["Crimson"]="DC143C",
	["Cyan"]="00FFFF",
	["Darkblue"]="00008B",
	["Darkcyan"]="008B8B",
	["Darkgoldenrod"]="B8860B",
	["Darkgray"]="A9A9A9",
	["Darkgreen"]="006400",
	["Darkkhaki"]="BDB76B",
	["Darkmagenta"]="8B008B",
	["Darkolivegreen"]="556B2F",
	["Darkorange"]="FF8C00",
	["Darkorchid"]="9932CC",
	["Darkred"]="8B0000",
	["Darksalmon"]="E9967A",
	["Darkseagreen"]="8FBC8F",
	["Darkslateblue"]="483D8B",
	["Darkslategray"]="2F4F4F",
	["Darkturquoise"]="00CED1",
	["Darkviolet"]="9400D3",
	["Deeppink"]="FF1493",
	["Deepskyblue"]="00BFFF",
	["Dimgray"]="696969",
	["Dodgerblue"]="1E90FF",
	["Firebrick"]="B22222",
	["Floralwhite"]="FFFAF0",
	["Forestgreen"]="228B22",
	["Fuchsia"]="FF00FF",
	["Gainsboro"]="DCDCDC",
	["Ghostwhite"]="F8F8FF",
	["Gold"]="FFD700",
	["Goldenrod"]="DAA520",
	["Gray"]="808080",
	["Green"]="008000",
	["Greenyellow"]="ADFF2F",
	["Honeydew"]="F0FFF0",
	["Hotpink"]="FF69B4",
	["Indianred"]="CD5C5C",
	["Indigo"]="4B0082",
	["Ivory"]="FFFFF0",
	["Khaki"]="F0E68C",
	["Lavendar"]="E6E6FA",
	["Lavenderblush"]="FFF0F5",
	["Lawngreen"]="7CFC00",
	["Lemonchiffon"]="FFFACD",
	["Lightblue"]="ADD8E6",
	["Lightcoral"]="F08080",
	["Lightcyan"]="E0FFFF",
	["Lightgoldenrodyellow"]="FAFAD2",
	["Lightgreen"]="90EE90",
	["Lightgrey"]="D3D3D3",
	["Lightpink"]="FFB6C1",
	["Lightsalmon"]="FFA07A",
	["Lightseagreen"]="20B2AA",
	["Lightskyblue"]="87CEFA",
	["Lightslategray"]="778899",
	["Lightsteelblue"]="B0C4DE",
	["Lightyellow"]="FFFFE0",
	["Lime"]="00FF00",
	["Limegreen"]="32CD32",
	["Linen"]="FAF0E6",
	["Magenta"]="FF00FF",
	["Maroon"]="800000",
	["Mediumauqamarine"]="66CDAA",
	["Mediumblue"]="0000CD",
	["Mediumorchid"]="BA55D3",
	["Mediumpurple"]="9370D8",
	["Mediumseagreen"]="3CB371",
	["Mediumslateblue"]="7B68EE",
	["Mediumspringgreen"]="00FA9A",
	["Mediumturquoise"]="48D1CC",
	["Mediumvioletred"]="C71585",
	["Midnightblue"]="191970",
	["Mintcream"]="F5FFFA",
	["Mistyrose"]="FFE4E1",
	["Moccasin"]="FFE4B5",
	["Navajowhite"]="FFDEAD",
	["Navy"]="000080",
	["Oldlace"]="FDF5E6",
	["Olive"]="808000",
	["Olivedrab"]="688E23",
	["Orange"]="FFA500",
	["Orangered"]="FF4500",
	["Orchid"]="DA70D6",
	["Palegoldenrod"]="EEE8AA",
	["Palegreen"]="98FB98",
	["Paleturquoise"]="AFEEEE",
	["Palevioletred"]="D87093",
	["Papayawhip"]="FFEFD5",
	["Peachpuff"]="FFDAB9",
	["Peru"]="CD853F",
	["Pink"]="FFC0CB",
	["Plum"]="DDA0DD",
	["Powderblue"]="B0E0E6",
	["Purple"]="800080",
	["Red"]="FF0000",
	["Rosybrown"]="BC8F8F",
	["Royalblue"]="4169E1",
	["Saddlebrown"]="8B4513",
	["Salmon"]="FA8072",
	["Sandybrown"]="F4A460",
	["Seagreen"]="2E8B57",
	["Seashell"]="FFF5EE",
	["Sienna"]="A0522D",
	["Silver"]="C0C0C0",
	["Skyblue"]="87CEEB",
	["Slateblue"]="6A5ACD",
	["Slategray"]="708090",
	["Snow"]="FFFAFA",
	["Springgreen"]="00FF7F",
	["Steelblue"]="4682B4",
	["Tan"]="D2B48C",
	["Teal"]="008080",
	["Thistle"]="D8BFD8",
	["Tomato"]="FF6347",
	["Turquoise"]="40E0D0",
	["Violet"]="EE82EE",
	["Wheat"]="F5DEB3",
	["White"]="FFFFFF",
	["Whitesmoke"]="F5F5F5",
	["Yellow"]="FFFF00",
	["YellowGreen"]="9ACD32"
}

function SLib.GetRandomColor()
	local random_color
	local return_value = "\124cff"
	local Hex = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	for i = 1, 6 do
		random_color = random(1, 16)
		return_value = return_value..Hex[random_color]
	end
	return return_value
end

function SLib.Message(msg, chat, lang)
	if not lang then 
		lang = SLib.Language
	end
	if not chat then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	else
		local j, fg = 1, 0
		local chat_type={"SAY", "EMOTE", "YELL", "PARTY", "GUILD", "OFFICER", "RAID", "RAID_WARNING", "BATTLEGROUND"}
		for j=1, getn(chat_type) do
			if chat==chat_type[j] then
				fg = 1
				SendChatMessage(msg, chat, lang)
				break
			end
		end
		if fg==0 then
			SendChatMessage(msg, "WHISPER", lang, chat)
		end
	end
end

function SLib.PrintColors(chat)
	local key, value, i, msg
	i = 0
	msg = ""
	for key,value in pairs(SLib.ColorTable) do
		if i<3 then
			msg = msg.."\124cff"..value..key.."\124r,    "
			i=i+1
		else
			SLib.Message(msg, chat)
			msg = "\124cff"..value..key.."\124r"..",    "
			i = 1
		end
	end
end

function SLib.chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

function SLib.extract_next_symbol(str, cur_pointer)
	local new_pointer = cur_pointer
	local length = SLib.chsize(strbyte(strsub(str, cur_pointer, cur_pointer)))
	new_pointer = cur_pointer + length
	local char = strsub(str, cur_pointer, new_pointer - 1)
	return char, new_pointer
end

function SLib.FindLength(str)
	local cur_pointer, prev_pointer, w, length, prev_w, color_now, color_counter
	local spetialmas = 
	{
		f = 1,
		l = 1,
		i = 1,
		j = 1,
		m = 3,
		r = 1,
		t = 1,
		w = 3,
		["."] = 1,
		[" "] = 1,
		["\19"] = 1,
		["%"] = 3,
		[":"] = 1,
		["/"] = 1
	}
	cur_pointer = 1
	length = 0
	prev_w = ""
	color_now = 0
	color_counter = 9
	while cur_pointer <= strlen(str) do
		prev_pointer = cur_pointer
		w, cur_pointer = SLib.extract_next_symbol(str, prev_pointer)
		if w == "r" and prev_w == "\124" then
			color_now = 0
			color_counter = 9
		elseif w == "\124" then
			color_now = 1
		elseif spetialmas[w] then
			if color_now==1 and color_counter >= 1 then
				color_counter = color_counter - 1
			else
				length = length + spetialmas[w]
			end
		else
			if color_now==1 and color_counter >= 1 then
				color_counter = color_counter - 1
			else
				length = length + 2
			end
		end
		prev_w = w
	end
	return length
end

function SLib.FindSeparators(str)
	local cur_pointer, prev_pointer, w, length
	cur_pointer = 1
	separator = 0
	while cur_pointer <= strlen(str) do
		prev_pointer = cur_pointer
		w, cur_pointer = SLib.extract_next_symbol(str, prev_pointer)
		if w == strchar(19) then
			separator = separator+1
		end
	end
	return separator
end

function SLib.ReplaceSeparator(str, replace)
	local cur_pointer, prev_pointer, w, length, mystr
	mystr = ""
	cur_pointer = 1
	while cur_pointer <= strlen(str) do
		prev_pointer = cur_pointer
		w, cur_pointer = SLib.extract_next_symbol(str, prev_pointer)
		if w == strchar(19) then
			mystr = mystr.." "
		else
			mystr = mystr..w
		end
	end
	return mystr
end

function SLib.ReplaceSpaces(str)
	local cur_pointer, prev_pointer, w, length, mystr
	mystr = ""
	cur_pointer = 1
	while cur_pointer <= strlen(str) do
		prev_pointer = cur_pointer
		w, cur_pointer = SLib.extract_next_symbol(str, prev_pointer)
		if w == " " then
			mystr = mystr..strchar(19).." "
		else
			mystr = mystr..w
		end
	end
	return mystr
end

function SLib.TableCeil(tab, iter_num)
	local i	 	
	if iter_num == 1 then
		curstr = nil
	end
	if type(tab) == "table" then
		for i = 1, getn(tab) do
			if type(tab[i]) == "table" then
				if curstr then
					curstr = curstr..strchar(19)..SLib.PrintTable(tab[i], iter_num + 1)
				else
					curstr = SLib.PrintTable(tab[i], iter_num + 1)
				end
			else
				if curstr then
					curstr = curstr..strchar(19)..tab[i]
				else 
					curstr = tab[i]
				end
			end
		end
	else
		if curstr then
			curstr = curstr..strchar(19)..tab
		else 
			curstr = tab
		end
	end
	return curstr
end

function SLib.PrintTable(tab, mes)
	local i, max_size
	local size_of_cols = {}
	max_size = 0
	for i = 1, getn(tab) do
		if getn(tab[i]) > max_size then
			max_size = getn(tab[i])
		end
	end
	for i = 1, max_size do
		size_of_cols[i] = 0
	end
	for i = 1, getn(tab) do
		for j = 1, getn(tab[i]) do
			if size_of_cols[j] < SLib.FindLength(SLib.TableCeil(tab[i][j], 1)) then
				size_of_cols[j] = SLib.FindLength(SLib.TableCeil(tab[i][j], 1))
			end
		end
	end
	for i = 1, getn(tab) do
		str = ""
		for j = 1, getn(tab[i]) do
			separators = SLib.FindSeparators(SLib.TableCeil(tab[i][j], 1))
			length = SLib.FindLength(SLib.TableCeil(tab[i][j], 1))
			spaces = size_of_cols[j] - length
			left_part = 0
			right_part = 0
			if spaces ~= 0 then
				right_part = ceil(spaces/2)
				left_part = spaces - right_part
			end
			left_spaces = ""
			right_spaces = ""
			for i = 1, left_part do
				left_spaces = left_spaces.." "
			end
			for i = 1, right_part do
				right_spaces = right_spaces.." "
			end
			l_str = SLib.ReplaceSeparator(SLib.TableCeil(tab[i][j], 1), " ")
			str = str..left_spaces..l_str..right_spaces.."   "
			str = SLib.ReplaceSpaces(str)
		end
		SLib.Message(str, mes)
	end	
end

function SLib.FillString(str, fill, length, font, fill_type, prev_str, prev_str_l)
	if not prev_str then prev_str = "" prev_str_l = 0 end
	if not fill_type then fill_type = "LEFT" end
	local filler_length = GMR.GetStringPixelLength(fill, nil, font)
	local degree = length+prev_str_l - GMR.GetStringPixelLength(prev_str..str, nil, font)
	local add_elements = floor(degree/filler_length + 0.5)
	if fill_type == "CENTER" then add_elements = floor(add_elements/2 + 0.5) end
	local add_str = "" --"\124cff"
	for i = 1, add_elements do
		add_str = add_str..fill
	end
	if fill_type == "LEFT" then
		str = str..add_str
	elseif fill_type == "RIGHT" then
		str = add_str..str
	elseif fill_type == "CENTER" then
		str = add_str..str..add_str
	end
	degree = length+prev_str_l - GMR.GetStringPixelLength(prev_str..str, nil, font)
	add_elements = floor(degree/filler_length)
	for i = 1, add_elements do
		str = str..fill
	end

	return str
end

function SLib.PrintTable2(mas, fill, font, fill_type_mas, separator)
	local str_mas = {}
	local copy_mas = {}
	--PrintTable(mas)
	for i = 1, getn(mas) do
		for j = 1, getn(mas[i]) do
			if not copy_mas[i] then
				copy_mas[i] = {}
			end
			copy_mas[i][j] = mas[i][j]
		end
	end
	--PrintTable(copy_mas)
	if copy_mas and copy_mas[1] then
		if not font then font = "GameFontNormal" end
		if not separator then separator = " | " end
		if not fill_type_mas then fill_type_mas = {} end
		local print_mas = {}
		local max_l = 0
		local degree, add_elements
		for j = 1, getn(copy_mas[1]) do
			max_l = 0
			for i = 1, getn(copy_mas) do
				if copy_mas[i][j] then
					max_l = max(GMR.GetStringPixelLength(copy_mas[i][j], nil, font), max_l)
				end
			end
			print_mas[j] = max_l
		end
		if not fill then fill = " " end
		local total_str = ""
		local total_str_l = 0
		local filler_length = GMR.GetStringPixelLength(fill, nil, font)
		for i= 1, getn(copy_mas) do
			total_str = ""
			total_str_l = 0
			for j = 1, getn(copy_mas[i]) do
				local l = print_mas[j]
				if not l then
					l = 0
				end
				copy_mas[i][j] = GMR.FillString(copy_mas[i][j], fill, l, font, fill_type_mas[j], total_str, total_str_l)
				total_str = total_str..copy_mas[i][j]
				total_str_l = total_str_l + print_mas[j]
			end
		end	

		for i= 1, getn(copy_mas) do
			total_str = ""
			for j = 1, getn(copy_mas[i]) do
				total_str = total_str..separator..copy_mas[i][j]
			end
			str_mas[i] = total_str
		end
	end
	return str_mas
end


SLib.Timers={}

function SLib.NewTimer(slib_pack_timer, slib_pack_time)
	SLib.Timers[slib_pack_timer] = {[1]=GetTime(), [2]=slib_pack_time}
end

function SLib.GetTimer(slib_pack_timer)
	local return_value
	if not SLib.Timers[slib_pack_timer] then 
		return_value = nil
	else
		return_value = SLib.Timers[slib_pack_timer][2] - (GetTime() - SLib.Timers[slib_pack_timer][1])
		if return_value<0 then 
			return_value = nil
			tremove(SLib.Timers[slib_pack_timer])
			tremove(SLib.Timers[slib_pack_timer])
			SLib.Timers[slib_pack_timer] = nil
		end
	end
	return return_value
end

function SLib.PrintTimers()
	for key, value in pairs(SLib.Timers) do
		if SLib.GetTimer(key) then
			DEFAULT_CHAT_FRAME:AddMessage(key..": "..SLib.GetTimer(key))
		end
	end
end


SLib.Stopwatchs = {}

function SLib.Stopwatch(stopwatch, start_or_stop)
	if start_or_stop and start_or_stop == "start" then
		if not SLib.Stopwatchs[stopwatch] then 
			SLib.Stopwatchs[stopwatch] = {[1] = 0, [2] = GetTime(), [3] = 1}
		else
			if SLib.Stopwatchs[stopwatch][3] == 0 then
				SLib.Stopwatchs[stopwatch][2] = GetTime()
				SLib.Stopwatchs[stopwatch][3] = 1
			end
		end
	elseif start_or_stop and start_or_stop == "stop" then
		if SLib.Stopwatchs[stopwatch] then
			SLib.Stopwatchs[stopwatch][1] = SLib.Stopwatchs[stopwatch][1] + SLib.Stopwatchs[stopwatch][3]*(GetTime() - SLib.Stopwatchs[stopwatch][2])
			SLib.Stopwatchs[stopwatch][3] = 0
		end
	end
end

function SLib.GetStopwatch(stopwatch)
	local return_value
	if not SLib.Stopwatchs[stopwatch] then 
		return_value = nil
	else
		return_value = SLib.Stopwatchs[stopwatch][1] + SLib.Stopwatchs[stopwatch][3]*(GetTime() - SLib.Stopwatchs[stopwatch][2])
	end
	return return_value
end

function SLib.DelStopwatch(stopwatch)
	if SLib.Stopwatchs[stopwatch] then
		SLib.Stopwatchs[stopwatch][1] = nil
		SLib.Stopwatchs[stopwatch][2] = nil
		SLib.Stopwatchs[stopwatch][3] = nil
		SLib.Stopwatchs[stopwatch] = nil
	end
end

function SLib.PrintStopwatchs()
	for key, value in pairs(SLib.Stopwatchs) do
		if SLib.GetStopwatch(key) then
			DEFAULT_CHAT_FRAME:AddMessage(key..": "..SLib.GetStopwatch(key))
		end
	end
end

SLib.CallStack = {}
SLib.CallStack.Init = function()
	if type(SLib.CallStack.Funcs) ~= "table" then
		SLib.CallStack.Funcs = {}
	end
	if type(SLib.CallStack.Params) ~= "table" then
		SLib.CallStack.Params = {}
	end
	if type(SLib.CallStack.Stopwatches) ~= "table" then
		SLib.CallStack.Stopwatches = {}
	end
	SLib.CallStack.Work = true
end

SLib.CallStack.NewCall = function(func, time, ...)
	SLib.CallStack.Funcs[func] = time
	if SLib.CallStack.Params[func] and type(SLib.CallStack.Params[func]) == "table" then
		for i = 0, getn(SLib.CallStack.Params[func]) do
			SLib.CallStack.Params[func][i] = nil
		end
	end
	if getn(arg) > 0 then
		SLib.CallStack.Params[func] = nil
		SLib.CallStack.Params[func] = {}
		for i = 1, getn(arg) do
			SLib.CallStack.Params[func][i] = arg[i]
		end
	end
	SLib.NewTimer(func, time)
end

SLib.CallStack.Call = function()
	if SLib.CallStack.Work then
		for key in pairs(SLib.CallStack.Funcs) do
			if not SLib.GetTimer(key) then
				if SLib.CallStack.Params[key] then
					SLib.CallStack.Funcs[key] = nil
					key(unpack(SLib.CallStack.Params[key]))
				else
					SLib.CallStack.Funcs[key] = nil
					key()
				end
				break
			end
		end
	end
end

function SLib.Scan(chat)	
	SLib.LockInspect = true
	local check_flag = false
	local prev_tar, cur_tar, word_cur_tar, word_prev_tar
	local prev_tar = UnitName("target")
	local word_prev_tar, word_cur_tar
	if prev_tar then
		word_prev_tar = string.find(prev_tar, "(%a)")
	end
	TargetByName(string.char(SLib.ScanI))
	cur_tar = UnitName("target")
	if cur_target then 
		_, _, word_cur_tar = string.find(cur_tar, "(%a)")
	end
	if prev_tar and (not cur_tar or prev_tar~=cur_tar) then
		TargetLastTarget()
	end
	if cur_tar and ( (cur_tar ~= prev_tar) or string.char(SLib.ScanI) == word_prev_tar) then           
			TargetByName(string.char(SLib.ScanI, SLib.ScanJ))
			cur_tar = UnitName("target")
			local faction = UnitFactionGroup("target")
			local _, tar_class = UnitClass("target")
			if cur_tar and cur_tar ~= "Unknown" then
				local _, _, a, b = string.find(cur_tar, "(%a)(%a)")
				if cur_tar ~= UnitName("player") and UnitIsPlayer("target") and UnitIsFriend("target", "player") and CheckInteractDistance("target", 1) then
					SLib.LockInspect = false
					SLib.CallStack.NewCall(SLib.Scan, 0.3)
					check_flag = true
				end
--[[				if SLib.ScanJ < string.byte(b) then
					SLib.ScanJ = string.byte(b) - 1
				end--]]
			end
		SLib.ScanJ = SLib.ScanJ + 1
		if SLib.ScanJ == 123 then
			SLib.ScanJ = 97
			SLib.ScanI = SLib.ScanI + 1
		end
		if SLib.ScanI == 91 then
			SLib.ScanI = 65
		end
	else
		SLib.ScanI = SLib.ScanI + 1
		if SLib.ScanI == 91 then
			SLib.ScanI = 65
		end
	end
	if SLib.StartScan and not check_flag then
		SLib.CallStack.NewCall(SLib.Scan, SLib.ScanSpeed)
	end
end