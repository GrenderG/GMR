if not GMR then 
	GMR = {} 
end

GMR.TicketData = {}

function GMR.command_handle_account(data, mess_iter, com, str, message)
	if data and data[1] then
		GMR.AccessLevel = tonumber(data[1])
		GMR.CreateTitle("GMLevel", -200/2 + 60, -200/2 -50, GMR.TableFrame, "GMLevel: \124cff"..GMR.ITEM_QUALITY_COLORS[GMR.AccessLevel + 1]..GMR.AccessLevel.."\124r","RIGHT", "RIGHT")
		-- CUSTOM: Removed for being evil... GMR.Titles["EscalateTicket"]:SetText("Escalate to Rank "..min(4, (GMR.AccessLevel+1)))
		GMR.GetResult.account = nil
	end
end

function str_in_byte(str)
	for letter in string.gfind(str, "(.)") do	
		Printd(letter..": "..strbyte(letter))
	end
end

function GMR.command_handle_ticket(data, mess_iter, com, str, message)
	if data and getn(data) > 0 then
		if mess_iter == 1 then
			GMR.CurrentTicketInfo.text = {}
			GMR.CurrentTicketInfo.comment = ""
		end
		local _, _, test = string.find(str, "GM Comment: %[(.+)%]$")
		if test then
			GMR.CurrentTicketInfo.comment = test
		end
		for i = 1, getn(data) do
			GMR.CurrentTicketInfo.text[getn(GMR.CurrentTicketInfo.text)+1] = data[i]
		end

		SLib.CallStack.NewCall(GMR.LoadTicketInfo, 0.5)
	end
end

function GMR.command_handle_ticket_list(data, mess_iter, com, str, message)
	if data and getn(data) > 0 then
		if mess_iter == 2 then
			GMR.TicketData = {}
		end
		local num, creator, created, changed, assigned, level = data[1], data[2], data[3], data[4], data[5], data[6]
		GMR.TicketData[mess_iter - 1] = {
			num = num,
			creator = creator or "",
			created = created or "",
			changed = changed or "",
			assigned = assigned or "",
			level  = level or "",
		}
		SLib.CallStack.NewCall(GMR.UpdateTotalTickets, 0.5)
		if GMR.CheckButtons["Characters scan type"]:GetChecked() then 
			SLib.CallStack.NewCall(GMR.ScanTicketChars, 0.5)
		end
	end
end

GMR.command_handle_functions = {
	account = GMR.command_handle_account
}

function GMR.common_handle(data, mess_iter, com, str, message)
	if data and getn(data) > 0 then
		local pattern_index = mess_iter
		if not GMR.Patterns[com][pattern_index] then
			pattern_index = getn(GMR.Patterns[com])
		end
		GMR.AddElementToDataTable(mess_iter, data, GMR.Patterns[com][pattern_index][2], com, pattern_index, message)
		GMR.Tables._Update("Data")
	end
	--GMR.GetResult[com] = nil
end

--spec addon commands
function GMR.addon_handle(str)
	local _, _, num = string.find(str, "open ticket (%d+)")
	if num then
		local data_num
		for i = 1, getn(GMR.TicketData) do
			if GMR.TicketData[i] and  GMR.TicketData[i].num and  GMR.TicketData[i].num == num then
				data_num = i
				break
			end
		end
		if data_num then
			GMR.TicketFrame:Show()
			GMR.BlockTicketLoad = true
			GMR.LoadTicket(data_num)
		end
	end
end