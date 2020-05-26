function GMR.extract_mas(i, iter)
	local extract_mas = {}
	for mas_iter = 1, getn(GMR.CurrentDataTableElements) do
		if GMR.CurrentDataTableElements[mas_iter][1] == i and not string.find(GMR.DataTable[GMR.CurrentDataTableElements[mas_iter][1]][GMR.CurrentDataTableElements[mas_iter][2]][1][1], "\124cff"..SLib.ColorTable["Snow"]) then
			extract_mas[getn(extract_mas)+1] = GMR.CurrentDataTableElements[mas_iter][2]
		end
	end
	return extract_mas
end

function GMR.paste_mas(i, iter, extract_mas)
	local k = 1
	for mas_iter = 1, getn(GMR.CurrentDataTableElements) do
		if GMR.CurrentDataTableElements[mas_iter][1] == i and not string.find(GMR.DataTable[GMR.CurrentDataTableElements[mas_iter][1]][GMR.CurrentDataTableElements[mas_iter][2]][1][1], "\124cff"..SLib.ColorTable["Snow"]) then
			GMR.CurrentDataTableElements[mas_iter][2] = extract_mas[k]
			k = k+1
		end
	end	
end

function GMR.common_datasort(i, iter, descending)
	local extract_mas = GMR.extract_mas(i, iter)
	function sort_rule(j1, j2)		
		local text1 = GMR.DataTable[i][j1][1][iter]
		local text2 = GMR.DataTable[i][j2][1][iter]
		if descending then
			return text1 > text2
		else
			return text1 < text2
		end
	end
	table.sort(extract_mas, sort_rule)
	GMR.paste_mas(i, iter, extract_mas)
end

function GMR.number_datasort(i, iter, descending)
	local extract_mas = GMR.extract_mas(i, iter)
	function sort_rule(j1, j2)		
		local n1 = GMR.DataTable[i][j1][1][iter]
		local n2 = GMR.DataTable[i][j2][1][iter]
		if not string.find(n1, "[%d%.%-]+") then
			n1 = "1000000000000000000000000000000000"
		end
		if not string.find(n2, "[%d%.%-]+") then
			n2 = "1000000000000000000000000000000000"
		end
		n1 = tonumber(n1)
		n2 = tonumber(n2)
		if descending then
			return n1 > n2
		else
			return n1 < n2
		end
	end
	table.sort(extract_mas, sort_rule)
	GMR.paste_mas(i, iter, extract_mas)
end

function GMR.Normalize_money(str)
	local mas = {
		gold = 0,
		silver = 0,
		copper = 0
	}
	if string.find(str, "(%d+)c") then
		_, _, mas.copper = string.find(str, "(%d+)c")
		mas.silver = mas.silver + floor(mas.copper/100)
		mas.copper = mas.copper - 100*floor(mas.copper/100)
	end
	if string.find(str, "(%d+)g") then
		_, _, mas.gold = string.find(str, "(%d+)g")
	end
	if string.find(str, "(%d+)s") then
		local _, _, silver = string.find(str, "(%d+)s")
		mas.silver = mas.silver + silver
	end
	mas.gold = mas.gold + floor(mas.silver/100)
	mas.silver = mas.silver - 100*floor(mas.silver/100)
	return mas
end

function GMR.money_datasort(i, iter, descending)
	local extract_mas = GMR.extract_mas(i, iter)
	function sort_rule(j1, j2)		
		local n1 = GMR.Normalize_money(GMR.DataTable[i][j1][1][iter])
		local n2 = GMR.Normalize_money(GMR.DataTable[i][j2][1][iter])
		local num1 = n1.gold*100*100 + n1.silver*100 + n1.copper
		local num2 = n2.gold*100*100 + n2.silver*100 + n2.copper

		if descending then
			return num1 > num2
		else
			return num1 < num2
		end
	end
	table.sort(extract_mas, sort_rule)
	GMR.paste_mas(i, iter, extract_mas)
end

function GMR.Normalize_IP(str)
	local result = 0
	local num
	for num in string.gfind(str, "(%d+)") do
		result = result*1000 + num
	end
	return result
end

function GMR.IP_datasort(i, iter, descending)
	local extract_mas = GMR.extract_mas(i, iter)
	function sort_rule(j1, j2)		
		local n1 = GMR.Normalize_IP(GMR.DataTable[i][j1][1][iter])
		local n2 = GMR.Normalize_IP(GMR.DataTable[i][j2][1][iter])

		if descending then
			return n1 > n2
		else
			return n1 < n2
		end
	end
	table.sort(extract_mas, sort_rule)
	GMR.paste_mas(i, iter, extract_mas)
end

function GMR.Normalize_time(str)
	local SyntaxInfo = {
		["separator"] = {
			[" "] = 1,
			[":"] = "HOUR_OR_MINUTE",
			["s"] = "SECOND",
			["m"] = "MINUTE",
			["h"] = "HOUR",
			["d"] = "DAY",
			["M"] = "MONTH",
			["y"] = "YEAR",
			["-"] = "YEAR_OR_MONTH_OR_DAY",
			["/"] = "YEAR_OR_MONTH_OR_DAY"
		},
		["ignore"] = {}
	}
	local stack = {}
	local word = ""
	local read_process = true
	local pos_pointer = 0
	for letter in string.gfind(str, "(.)") do
		if SyntaxInfo["separator"][letter] then
			if word ~= "" then
				stack[getn(stack) + 1] = {word}
				word = ""
				read_process = false
			end
			if letter ~= " " then
				local temp = stack[getn(stack)]
				stack[getn(stack)][2] = SyntaxInfo["separator"][letter]
			end
		elseif not SyntaxInfo["ignore"][letter] then
			word = word..letter
			read_process = true
		end
		pos_pointer = pos_pointer + 1
	end
	if read_process and word ~= "" then
		stack[getn(stack)+1] = {word}
	end

	local hour_or_minute = 1
	local year_or_month_or_day = 1
	for i = getn(stack), 1, -1 do
		if not stack[i][2] and stack[i-1] and stack[i-1][2] then
			stack[i][2] = stack[i-1][2]
		end
		if stack[i][2] == "HOUR_OR_MINUTE" then
			if hour_or_minute == 1 then
				stack[i][2] = "SECOND"
				hour_or_minute = 2
			elseif hour_or_minute == 2 then
				stack[i][2] = "MINUTE"
				hour_or_minute = 3
			elseif hour_or_minute == 3 then
				stack[i][2] = "HOUR"
				hour_or_minute = 4
			end
		elseif stack[i][2] == "YEAR_OR_MONTH_OR_DAY" then
			if year_or_month_or_day == 1 then
				stack[i][2] = "DAY"
				year_or_month_or_day = 2
			elseif year_or_month_or_day == 2 then
				stack[i][2] = "MONTH"
				year_or_month_or_day = 3
			elseif year_or_month_or_day == 3 then
				stack[i][2] = "YEAR"
				year_or_month_or_day = 4
			end
		end				
	end

	local month_time = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	local TimeInfo = {
		["SECOND"] 	= 1,
		["MINUTE"]	= 60,
		["HOUR"]	= 60*60,
		["DAY"]		= 60*60*24,
	}	

	local result = 0
	for i = getn(stack), 1, -1 do
		local t = tonumber(stack[i][1])
		local d = stack[i][2]
		if d and TimeInfo[d] then
			result = result + t * TimeInfo[d]
		elseif d and d == "MONTH" then
			result = result + month_time[t]*TimeInfo["DAY"]
		elseif d and d == "YEAR" then
			result = result + 365*TimeInfo["DAY"]
			if mod(t, 4) == 0 then
				result = result + TimeInfo["DAY"]
			end
		end
	end
	return result
end



function GMR.time_datasort(i, iter, descending)
	local extract_mas = GMR.extract_mas(i, iter)
	function sort_rule(j1, j2)		
		local n1 = GMR.Normalize_time(GMR.DataTable[i][j1][1][iter])
		local n2 = GMR.Normalize_time(GMR.DataTable[i][j2][1][iter])

		if descending then
			return n1 > n2
		else
			return n1 < n2
		end
	end
	table.sort(extract_mas, sort_rule)
	GMR.paste_mas(i, iter, extract_mas)
end

GMR.SortData = {
	common 	= GMR.common_datasort,
	num 	= GMR.number_datasort,
	money   = GMR.money_datasort,
	ip 		= GMR.IP_datasort,
	time 	= GMR.time_datasort
}