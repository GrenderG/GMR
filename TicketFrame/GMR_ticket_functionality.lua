if not GMR then 
	GMR = {} 
end

GMR.CharacterBase = {}
GMR.TicketData = {}

function GMR.LoadTicket(id)
	GMR.CurrentTicketInfo = {
		num = GMR.TicketData[id].num,
		creator = GMR.TicketData[id].creator
	}
	GMR.Titles["CurrentTicketNum"]:SetText("Ticket num: "..GMR.CurrentTicketInfo.num)
	GMR.Titles["CurrentTicketCreator"]:SetText("Character:   "..GMR.CurrentTicketInfo.creator)
	GMR.SendCommandSafe(".ticket "..GMR.TicketData[id].num, "ticket", GMR.command_handle_ticket)
end

function GMR.LoadTicketInfo()
	if GMR.CurrCommand[1] == "ticket"  then
		GMR.CurrCommand = nil
	end
	GMR.EditScrollBoxes["TicketReportText"]:SetFocus()
	GMR.EditScrollBoxes_text["TicketReportText"] = {}
	for i = 1, getn(GMR.CurrentTicketInfo.text) do
		GMR.EditScrollBoxes_text["TicketReportText"][i] = GMR.CurrentTicketInfo.text[i]
	end
	GMR.EditScrollBoxes["TicketReportText"]:SetText(" ")

	GMR.EditScrollBoxes["TicketComment"]:SetText("")
	GMR.EditScrollBoxes["TicketComment"]:SetFocus()
	GMR.EditScrollBoxes["TicketComment"]:Insert(GMR.CurrentTicketInfo.comment)
	GMR.EditScrollBoxes["TicketComment"]:ClearFocus()
	GMR.BlockTicketLoad = false
end

function GMR.UpdateMaxTickets()
	GMR.SendCommandSafe(".ticket "..GMR.TicketScanType, "ticket "..GMR.TicketScanType, GMR.command_handle_ticket_list)
	--SLib.CallStack.NewCall(GMR.UpdateMaxTickets, 120) -- 2 minute ticket cycle
end

function GMR.UpdateTotalTickets(first)
	GMR.MAX_TICKETS = getn(GMR.TicketData)
	GMR.Titles["TotalTickets"]:SetText("Total Tickets: "..GMR.MAX_TICKETS)
	GMR.Tables._Update("Ticket", GMR.ScrollBars["TicketTableV"]:GetValue())
end

function GMR.GetTextTable(text, length)
	text = text or ""
	length = length or 255
	local text_array = {}
	local cur_pointer, prev_pointer, word, w, mymsg, curlength, first
	mymsg = ""
	cur_pointer = 1
	curlength, first, length_degree = 0, 0, 3
			for word in string.gfind(text, "([^ \n]+)") do
				if mymsg ~= "" and curlength + strlen(word) > length and curlength + length_degree >= length and first == 1 then
					text_array[getn(text_array)+1] = mymsg
					curlength = 0
					mymsg = ""
					first = 0
					cur_pointer = 1
				end
				while cur_pointer <= strlen(word) do
					prev_pointer = cur_pointer
					w, cur_pointer = SLib.extract_next_symbol(word, prev_pointer)
					if(curlength + (cur_pointer - prev_pointer) > length) then
						text_array[getn(text_array)+1] = mymsg
						curlength = 0
						mymsg = ""
						first = 0
					end
					mymsg = mymsg..w
					curlength = curlength + (cur_pointer - prev_pointer)
				end
				first = 1
				mymsg = mymsg.." "
				curlength = curlength + 1
				cur_pointer = 1
			end
	text_array[getn(text_array)+1] = mymsg
	return text_array
end


function GMR.CutTextBySize(str, pix_l, add_str)
	local word = ""
	if not add_str then
		add_str = ""
	end
	for letter in string.gfind(str, "(.)") do		
		if GMR.GetStringPixelLength(word..letter..add_str) > pix_l then
			break
		else
			word = word..letter
		end
	end
	if word ~= str then
		word = word..add_str
	end
	return word
end

function GMR.TicketTemplateButtonClick(button_text, template_name)
	local t = getglobal("GMR_"..template_name.."Text")
	local text = GMR.CutTextBySize(button_text, getglobal("GMR_"..GMR.CurrentTicketTemplate):GetWidth(), "...")
	t:SetText(text)
	GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate]:Hide()
	if GMR.EditScrollBoxes[template_name] then
		GMR.EditScrollBoxes_text[template_name] = button_text
		GMR.EditScrollBoxes[template_name]:SetText(button_text)
	end
end

function GMR.FindMaxTableLength(mas)
	local l = {0, nil}
	for i = 1, getn(mas) do
		if mas[i] then
			if l[1] < getn(mas[i]) then
				l = {getn(mas[i]), i}
			end
		end
	end
	return l
end

function GMR.CalculateTableElemLength(mas, font)
	if mas then
		if not font then font = "GameFontNormal" end
		if not separator then separator = " | " end
		if not fill_type_mas then fill_type_mas = {} end
		local print_mas = {}
		local max_l = 0
		local degree, add_elements
		mas.elem_length = {}
		

		l = GMR.FindMaxTableLength(mas)[2]
		local sum = 0
		if l then
			for j = 1, getn(mas[l]) do
				max_l = 0
				for i = 1, getn(mas) do
					if mas[i][j] then
						max_l = max(GMR.GetStringPixelLength(mas[i][j], nil, font), max_l)
					end
				end
				sum = sum + max_l
				mas.elem_length[j] = sum
			end
		end
	end
end

GMR.TicketButtonText = {}

function GMR.UpdateButtonsText(value)
	local elem_nums = GMR.Tables._Params["Ticket"].PrevSize
	local all = GMR.Tables._AllObjects["Ticket"]
	GMR.TicketButtonText = {}
	if elem_nums then elem_nums = min(getn(all), elem_nums) end
	local data
	if elem_nums and value - elem_nums + 1 > 0 and GMR.CurrentTicketTableElements[value - elem_nums + 1] and GMR.CurrentTicketTableElements[value] then
		for i = 1, elem_nums do		
			data = GMR.TicketData[GMR.CurrentTicketTableElements[value - elem_nums + i]]
			--DEFAULT_CHAT_FRAME:AddMessage("Value:"..value.." Elem_Nums: "..elem_nums.." i: "..i)
			local creator = "NONE"
			if data.creator ~= nil then
				creator = data.creator
			end
			local assigned = data.assigned
			local level = data.level or ""
			if creator == UnitName("player") then
				creator = "\124cff"..SLib.ColorTable["Tomato"]..creator.."\124r"
			else
				creator = "\124cff"..GMR.ITEM_QUALITY_COLORS[3]..creator.."\124r"
			end
			if assigned ~= "" then
				if assigned == UnitName("player") then
					assigned = "\124cff"..SLib.ColorTable["Tomato"].."<GM>"..assigned.."\124r"
				else
					assigned = "\124cff"..GMR.ITEM_QUALITY_COLORS[4].."<GM>"..assigned.."\124r"
				end
			end
			if level ~= "" then
				level = "\124cff"..GMR.ITEM_QUALITY_COLORS[tonumber(level)]..level.."\124r"
			end
			if data.num then
				GMR.TicketButtonText[i] = {"\124cff"..GMR.ITEM_QUALITY_COLORS[2]..(data.num).."\124r", creator, data.created, assigned, level}
			end
			local name = data.creator
			if GMR.CheckButtons["Characters scan type"]:GetChecked() and GMR.CharacterBase[name] then
				for k = 1, getn(GMR.CharacterBase[name]) do
					GMR.TicketButtonText[i][getn(GMR.TicketButtonText[i])+1] =  GMR.CharacterBase[name][k]
				end
			end
		end
	end
	GMR.CalculateTableElemLength(GMR.TicketButtonText)
	for i = 1, elem_nums do
		GMR.Tables._UpdateElement["Ticket"](all[i], value - elem_nums + i, GMR.TicketButtonText[i])
	end	
	local name = "Ticket"
	if GMR.ScrollBars[name.."Table".."H"] then
		local child             = GMR.Tables[name]:GetScrollChild()
		local child_cur_size 	= child:GetWidth()
		local child_must_size 	= max(GMR.Tables[name]:GetWidth(), GMR.ChildGetMaxWidth(child))
		if child_cur_size ~= child_must_size then
			GMR.Tables[name]:GetScrollChild():SetWidth(child_must_size)
			GMR.ScrollBars[name.."Table".."H"]:SetMinMaxValues(0, child_must_size - GMR.Tables[name]:GetWidth())
		end
	end

end