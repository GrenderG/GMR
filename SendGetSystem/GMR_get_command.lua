if not GMR then 
	GMR = {} 
end

--other global variables
 --command, that was send by addon - null after parsing command, I want to pars only addon commands
GMR.SysMessageIter = nil --many messages may come on one command
GMR.GetResult = {} 	 --Set here function to catch result like "account set" = func1

GMR.commandstack = {}

function GMR.ExecCommandStack()
	local time_left = SLib.GetTimer("DelayOnSendGetCommand")
	if getn(GMR.commandstack) > 0 and not time_left and not GMR.BLOCK_SEND_COMMAND then
		--Printd("Execute: "..GMR.commandstack[getn(GMR.commandstack)][1])
		GMR.SendCommandSafe(unpack(GMR.commandstack[getn(GMR.commandstack)]))
		GMR.commandstack[getn(GMR.commandstack)] = nil
	end
end

function GMR.SendCommandSafe(message, command, func)
	if message and command and GMR.Patterns[command] then
		if not SLib.GetTimer("DelayOnSendGetCommand") and not GMR.BLOCK_SEND_COMMAND then
			GMR.BLOCK_SEND_COMMAND = true
			GMR.SysMessageIter = 1
			GMR.CurrCommand = {command, message}
			SendChatMessage(message,"GUILD")
			if func then
				GMR.GetResult[command] = func
			end
		else
			--Printd("Push this to exec stack: "..message)
			GMR.commandstack[getn(GMR.commandstack)+1] = {message, command, func}
		end
	elseif command then
		SendChatMessage(message,"GUILD")
	end
end

function GMR.ParseNormalize(str)
	str = gsub(str, "(\124cff......)", "")
	str = gsub(str, "(\124r", "")
	--str = gsub(str, "%-", "%-")
	str = gsub(str, "\124Hplayer.-\124h", "")
	str = gsub(str, "]\124h", "]")
	return str
end

function GMR.CancelNormalize(str)
	str = gsub(str, "%%%-", "%-")
	return str
end

--you may add construction to pattern <or1>some pattern1<\or1><or2>some pattern2<\or2> then it will check this patterns to, concuted to first

function GMR.GetPatternBlocks(pattern)
	pattern = pattern or ""
	local pat_blocks = {}
	local p_start, p_end, p_base_pat_block, index, p_or_pat_block, num, label_num
	local i = 0
	while string.find(pattern, "<or(.-)>") do
		p_start, p_end, p_base_pat_block, index, p_or_pat_block = string.find(pattern, "(.-)<or(.-)>(.-)<\or.->")
		if p_base_pat_block and p_or_pat_block and index then
			i = i + 1
			if p_base_pat_block ~= "" then	
				pat_blocks[getn(pat_blocks) + 1] = {
					value = p_base_pat_block,
					block_type = "base"
				}
			end
			if p_or_pat_block ~= "" then	
				_, _, num, label_num = string.find(index, "(%d+)_(%d+)")
				pat_blocks[getn(pat_blocks) + 1] = {
					value = p_or_pat_block,
					block_type = "or",
					label_num  = label_num,
					iter = i
				}
			end				
			pattern = string.sub(pattern, p_end+1)
		elseif p_end then
			pat_blocks[getn(pat_blocks) + 1] = {
				value = string.sub(pattern, 1, p_end),
				block_type = "base"
			}
			pattern = string.sub(pattern, p_end+1)
		end
	end
	if pattern ~= "" then
		pat_blocks[getn(pat_blocks) + 1] = {
			value = pattern,
			block_type = "base"
		}
	end
	return pat_blocks, i
end

function GMR.ImproovPatternMatching(str, pattern, labels)
	local add_patterns = {}
	local data = {}
	local add_data = {}

	local pat_blocks, or_num = GMR.GetPatternBlocks(pattern)

	local res_pattern
	local fail_patterns = {}
	local ins_empty = {}
	local empty_iter = 1
	for i = 0, or_num do
		res_pattern = ""
		cur_pattern = nil
		for j = 1, getn(pat_blocks) do
			if pat_blocks[j].block_type == "base" then
				res_pattern = res_pattern..pat_blocks[j].value
			elseif pat_blocks[j].block_type == "or" then
				if pat_blocks[j].iter <= i and not GMR.FindInMas(j, fail_patterns) then
					res_pattern = res_pattern..pat_blocks[j].value
					if pat_blocks[j].iter == i then
						cur_pattern = j
					end
				end
			end
		end
		add_data = {string.find(str,res_pattern)}
		if add_data and getn(add_data) > 1 then
			data = add_data
		elseif cur_pattern then
			fail_patterns[getn(fail_patterns)+1] = cur_pattern
			if labels and pat_blocks[cur_pattern].label_num then
				ins_empty[empty_iter] = tonumber(pat_blocks[cur_pattern].label_num) + 2
				empty_iter = empty_iter + 1
			end
		end
	end
	if getn(ins_empty) > 0 then
		for i = 1, getn(ins_empty) do
			table.insert(data, ins_empty[i], "")
		end
	end
	return data
end

function GMR.ParseCommand(str)
	local com = GMR.CurrCommand[1]
	local pattern, labels
	local data = {}
	local mess_iter = GMR.SysMessageIter
	GMR.BLOCK_SEND_COMMAND = false
	if GMR.Patterns[com] and getn(GMR.Patterns[com]) > 0 then
			--I gues that serv send all type mess by 1 time and last type will send many types - like a table - else this must be rewrited - try to find data, applying all patterns
			local pattern_index = mess_iter

			if not GMR.Patterns[com][mess_iter] then
				pattern_index = getn(GMR.Patterns[com])
			end

			if not GMR.Patterns[com][pattern_index].cancel_normalize then
				str = GMR.ParseNormalize(str)
			end
			
			pattern = GMR.Patterns[com][pattern_index][1]
			labels = GMR.Patterns[com][pattern_index][2]

			data = GMR.ImproovPatternMatching(str, pattern, labels)
			if data[1] then table.remove(data, 1) end	--first 2 value are pointers where pattern was founded  
			if data[1] then table.remove(data, 1) end
			--PrintTable(data)
			if not data then 
				GMR.Print("Can't parse this command with that pattern"..com)
			else
				GMR.SysMessageIter = GMR.SysMessageIter + 1
				if not GMR.Patterns[com].table_type and mess_iter == getn(GMR.Patterns[com]) then
					SLib.NewTimer("DelayOnSendGetCommand", -1)
				else
					SLib.NewTimer("DelayOnSendGetCommand", GMR.DELAY)
				end
			end
	else 
		--GMR.Print("Havn't data how parse string from"..com)
	end
	if GMR.GetResult[com] then
		GMR.GetResult[com](data, mess_iter, com, str, GMR.CurrCommand[2])
	end
end