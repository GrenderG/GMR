if not GMR then 
	GMR = {} 
end

GMR.DataTable = {
--[[	[1] = {
		["command"] = "lookup creature"
		[1] = {
			{"name1", "id", "alaks"},
			{"label1", "label2", "label3"}
			{l1, l2, l3}
		}
		------------------	
	}]]--
}

GMR.CurrentDataTable = {}

function GMR.DataVizNormalize(str)
	if str then
		if str == "-" then
			str = "***"
		else
			str = gsub(str, "%-", "/")
		end
	end
	return str
end

function GMR.RecalcLength(i, j1, j2)
	local data = GMR.DataTable[i]
	local l_mas = {}
	for j = j2, j1, -1 do
		for k = 1, getn(data[j][2]) do
			if j == j2 then
				l_mas[k] = max(GMR.GetStringPixelLength(data[j][2][k]), GMR.GetStringPixelLength(data[j][1][k]))
			else
				local t = max(GMR.GetStringPixelLength(data[j][2][k]), GMR.GetStringPixelLength(data[j][1][k]))
				l_mas[k] = max(l_mas[k], t)
			end
		end
	end
	for j = j1, j2 do	
		for k = 1, getn(l_mas) do
			GMR.DataTable[i][j][3][k] = l_mas[k]
		end
	end
end

function GMR.IsElementGroupedWithPrev(i, j)
	local data = GMR.DataTable[i]
	local result = j
	if GMR.DataTable[i] and GMR.DataTable[i][j] and j > 1 then
		for iter = j-1, 1, -1 do
			if getn(data[iter][2]) ~= getn(data[iter+1][2]) then
				break
			else
				for k = 1, getn(data[iter][3]) do
					if data[iter][2][k] ~= data[iter+1][2][k] then
						break
					end
				end
			end
			result = iter
		end
	end
	return result
end

function GMR.DeleteTableBlock(index)
	for i = index, getn(GMR.DataTable)-1 do
		GMR.DataTable[i] = GMR.DataTable[i+1]
	end
	GMR.DataTable[getn(GMR.DataTable)] = nil
	GMR.Tables._Update("Data")
end

function GMR.AddElementToDataTable(iter, data, labels, block_key, pattern_index, message)
	if data and data[1] then
		GMR.DataTableFrame:Show()
		local join = false
		local index
		local i_start = 1
		index = getn(GMR.DataTable)
		local same_block_keys = false
		if GMR.DataTable[index] and GMR.DataTable[index].block_key and GMR.DataTable[index].block_key == block_key then
			same_block_keys = true
		end
		local same_block_key_time = SLib.GetTimer("AddElementToDataTable")
		local join_current_table = same_block_keys and same_block_key_time

		if not join_current_table then
			index = index + 1
		end
		
		if join_current_table and pattern_index > 1 and GMR.Patterns[block_key].join and GMR.FindInMas(pattern_index, GMR.Patterns[block_key].join) then
			join = true
		end

		if GMR.DataTable[index] then
			if join and join_current_table and pattern_index ~= 1 then
				iter = getn(GMR.DataTable[index])
				i_start = getn(GMR.DataTable[index][iter][1]) + 1
			else
				iter = getn(GMR.DataTable[index]) + 1
				GMR.DataTable[index][iter]= {
					[1] = {},
					[2] = {},
					[3] = {},
					[4] = {},
				}
			end
		else
			GMR.DataTable[index] = {}
			iter = 2
			GMR.DataTable[index][1]= {
				[1] = {},
				[2] = {},
				[3] = {},
				[4] = {},
			}
			GMR.DataTable[index][2]= {
				[1] = {},
				[2] = {},
				[3] = {},
				[4] = {},
			}
			if block_key then 
				GMR.DataTable[index].block_key = block_key
				GMR.DataTable[index].message = message
			end
		end

		for i = i_start, i_start + getn(data) - 1 do
			GMR.DataTable[index][iter][1][i] = GMR.DataVizNormalize(data[i - i_start + 1])
			if labels and labels[i - i_start + 1] then 
				GMR.DataTable[index][iter][2][i] = GMR.DataVizNormalize(labels[i - i_start + 1])
			else 
				GMR.DataTable[index][iter][2][i] = "" 
			end
			GMR.DataTable[index][iter][4][i] = {pattern_index, i - i_start + 1}
			if iter == 2 then
				GMR.DataTable[index][iter-1][1][i] = "\124cff"..SLib.ColorTable["Snow"]..GMR.DataTable[index][iter][2][i].."\124r"
				if labels and labels[i - i_start + 1] then 
					GMR.DataTable[index][iter-1][2][i] = GMR.DataTable[index][iter][2][i]
				else 
					GMR.DataTable[index][iter-1][2][i] = "" 
				end
				GMR.DataTable[index][iter-1][4][i] = {pattern_index, i - i_start + 1}
			end
		end
		local start = GMR.IsElementGroupedWithPrev(index, iter)
		GMR.RecalcLength(index, start, iter)

		SLib.NewTimer("AddElementToDataTable", 3*GMR.DELAY)
	end
end

function GMR.GetIndexes(value)
	local iter = 0
	for i = 1, getn(GMR.CurrentDataTableElements) do
		local k = GMR.CurrentDataTableElements[i][1]
		if not GMR.DataTable[k].Disable then
			iter = iter + 1
			if iter == value then
				return GMR.CurrentDataTableElements[i][1], GMR.CurrentDataTableElements[i][2]
			end
		end
	end
	return nil, nil
end

GMR.CurrentDataTableElements = {}

function GMR.SetWidthDataTableElement(Button, length)
	length = max(length, GMR.DATA_TABLE_WIDTH)
	Button:SetWidth(length)
	local t = Button:GetHighlightTexture()
	t:SetWidth(length)
end


function GMR.CreateDataTableStrButton(name, parent, width, height, offset, i, j, iter)
	local f, t
	local text = GMR.DataTable[i][j][1][iter]
	if GMR.DataTable[i][j].Select then
		offset = offset + 20
		text = GMR.DataTable[i][j][2][iter]
	end
	local block_key = GMR.DataTable[i].block_key
	if not GMR.Buttons[name] then
		GMR.Buttons[name] = CreateFrame("Button", name, parent)
		GMR.CreateTitle(name, offsets, 0, parent, "")
	end
	f = GMR.Buttons[name]
	t = GMR.Titles[name]
	f:SetWidth(width)
	f:SetHeight(height)
	--f:ClearAllPoints()
	--f:SetParent(parent)
	--t:ClearAllPoints()
	--t:SetParent(parent)
	t:SetPoint("LEFT", parent, "LEFT", offset, 0)
	t:SetText(text)
	f:SetPoint("LEFT", parent, "LEFT", offset, 0)
	f:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	f:SetScript("OnEnter", 
		function()
		    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
			GameTooltip:AddLine(GMR.DataTable[i][j][2][iter])
			GameTooltip:Show()
			this:GetParent():LockHighlight()
		end
	)
	f:SetScript("OnLeave", 
		function()
	       GameTooltip:Hide()
	       	this:GetParent():UnlockHighlight()
	    end
	)

	if GMR.DataTable[i][j].Select then
		offset = offset - 20

		f:SetScript("OnClick", 
			function()
				if arg1 == "RightButton" then
					if IsAltKeyDown() then
						GMR.DataTable[i][j].Select = not GMR.DataTable[i][j].Select
						GMR.Tables._Update("Data", GMR.ScrollBars["DataTableV"]:GetValue())
					end
				end
			end
		)
		local cb = GMR.CreateCheckButton(name, offset, 0, parent, "LEFT", "LEFT", "Enable "..iter.."column for \""..block_key.."\"")
		--cb:ClearAllPoints()
		--cb:SetParent(parent)
		cb:SetPoint("LEFT", parent, "LEFT", offset, 0)
		if not (block_key and GMRConfig.DataVizualization[block_key] and GMRConfig.DataVizualization[block_key][iter]) then
			cb:SetChecked()
		end
		local s = cb:GetScript("OnClick")
		cb:SetScript("OnClick", 
			function()
				if not GMRConfig.DataVizualization[block_key] then
					GMRConfig.DataVizualization[block_key] = {}
				end
				GMRConfig.DataVizualization[block_key][iter] = not this:GetChecked()
				s()
			end
		)
		cb:Show()
	else		
		f:SetScript("OnClick", 
			function()
				local command = GMR.DataTable[i].block_key
				local pattern_id = GMR.DataTable[i][j][4][iter][1]
				local real_iter = GMR.DataTable[i][j][4][iter][2]
				if arg1 == "RightButton" then
					if IsAltKeyDown() then
						GMR.DataTable[i][j].Select = not GMR.DataTable[i][j].Select
						GMR.Tables._Update("Data", GMR.ScrollBars["DataTableV"]:GetValue())
					else
						if GMR.Patterns[command][pattern_id][3] and GMR.Patterns[command][pattern_id][3][real_iter] then
							GMR.FindInMiniDataTable(GMR.Patterns[command][pattern_id][3][real_iter], GMR.DataTable[i][j][1][iter], command)
							local x, y = GetCursorPosition()
							x = x/UIParent:GetEffectiveScale()
							y = y/UIParent:GetEffectiveScale()
							GMR.Tables["MiniData"]:SetPoint("TOPLEFT", GMR.Tables["Data"], "TOPLEFT", (x-GMR.Tables["Data"]:GetLeft()), y - GMR.Tables["Data"]:GetTop())
							GMR.Tables["MiniData"]:Hide()
							GMR.Tables["MiniData"]:Show()
							GMR.Tables._Update("MiniData")
						end
					end
				elseif arg1 == "LeftButton" then
					if IsAltKeyDown() then
						local sort_type
						if GMR.Patterns[command][pattern_id][4] and GMR.Patterns[command][pattern_id][4][real_iter] then
							sort_type = GMR.Patterns[command][pattern_id][4][real_iter]
						else
							sort_type = "common"
						end
						local t = GMR.SortData.Use
						if t and t[1] == sort_type and t[2] == i and t[3] == iter then
							t[4] = not t[4]
						else
							GMR.SortData.Use = {sort_type, i, iter, _}
						end
						GMR.Tables._Update("Data", GMR.ScrollBars["DataTableV"]:GetValue())
					else
						local e = GMR.CreateEditBox("DataTableCopyBox", 0, 0, GMR.Tables["Ticket"], 50, 20, "CENTER", "CENTER", "Copy text")
						e:SetHeight(this:GetHeight())
						e:SetWidth(this:GetWidth())
						e:ClearAllPoints()
						e:SetParent(this)
						e:SetPoint("CENTER", 0, 0)
						e:Show()
						e:SetText(GMR.Titles[name]:GetText() or "")
						SLib.CallStack.NewCall(GMR.HideFrame, 7, GMR.EditBoxes["DataTableCopyBox"])
					end			
				end
			end
		)
	end
	t:Show()
	f:Show()
end

function GMR.CreateDataTableHistoryMode(index, name, parent, height)
		local cb = GMR.CreateCheckButton(name, 10, 0, parent, "LEFT", "LEFT", "Enable this block")
		cb:SetPoint("LEFT", parent, "LEFT", 10, 0)
		if not GMR.DataTable[index].Disable then
			cb:SetChecked()
		end
		local s = cb:GetScript("OnClick")
		cb:SetScript("OnClick", 
			function()
				if this:GetChecked() then
					GMR.DataTable[index].Disable = false
				else
					GMR.DataTable[index].Disable = true
				end
				s()
			end
		)
		cb:Show()

		local text = GMR.DataTable[index].message
		if not text then
			text = "Can't find command message"
		end
		if not GMR.Buttons[name] then
			GMR.Buttons[name] = CreateFrame("Button", name, parent)
			GMR.CreateTitle(name, 40, 0, parent, "")
		end
		t = GMR.Titles[name]
		t:SetPoint("LEFT", parent, "LEFT", 40, 0)
		t:SetText(text)

		f = GMR.Buttons[name]

		f:SetWidth(t:GetStringWidth())
		f:SetHeight(height)

		f:SetPoint("LEFT", parent, "LEFT", 40, 0)
		f:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		f:SetScript("OnEnter", 
			function()
			    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
				GameTooltip:AddLine("Delete block on rightclick")
				GameTooltip:Show()
				this:GetParent():LockHighlight()
			end
		)
		f:SetScript("OnLeave", 
			function()
		       GameTooltip:Hide()
		       this:GetParent():UnlockHighlight()
		    end
		)
		f:SetScript("OnClick", 
			function()
				if arg1 == "RightButton" then
					GMR.DeleteTableBlock(index)
				end
			end
		)
		f:Show()
		t:Show()
end

function GMR.UpdateDataTableElement(Button, value)
	local f, t, offset, width, minidata
	local all_obj = {Button:GetChildren()}
	for iter = 1,getn(all_obj) do
		all_obj[iter]:ClearAllPoints()
		all_obj[iter]:Hide()
		local tit = GMR.Titles[all_obj[iter]:GetName()]
		if tit then
			tit:ClearAllPoints()
			tit:Hide()
		end
	end
	if not GMR.DataTableHistoryMode then
		local i, j = GMR.GetIndexes(value)
		if i and j then
			offset = 10
			local block_key = GMR.DataTable[i].block_key
			for iter = 1, getn(GMR.DataTable[i][j][1]) do
				if GMR.DataTable[i][j].Select then
					width = GMR.DataTable[i][j][3][iter]
					GMR.CreateDataTableStrButton(Button:GetName().."_"..iter, Button, width, 10, offset, i, j, iter)
					offset = offset + GMR.DataTable[i][j][3][iter] + 10 + 20
				elseif not (block_key and GMRConfig.DataVizualization[block_key] and  GMRConfig.DataVizualization[block_key][iter]) then
					width = GMR.DataTable[i][j][3][iter]
					GMR.CreateDataTableStrButton(Button:GetName().."_"..iter, Button, width, 10, offset, i, j, iter)
					offset = offset + GMR.DataTable[i][j][3][iter] + 10
				end
			end
			GMR.SetWidthDataTableElement(Button, offset)
		end
	else
		local index = GMR.CurrentDataTableElements[value][1]
		if index and GMR.DataTable[index] then 
			GMR.CreateDataTableHistoryMode(index, Button:GetName().."_"..index, Button, 10)
		end
	end
end

function GMR.CreateDataTableElemets(number)
	local f, t, s
	local result = {}
	for i = 1, number do
		if not GMR.Buttons["ButtonDataTable"..i] then
			f = CreateFrame("Button", "ButtonDataTable"..i, nil, "DataButtonTemplate")
			f:SetFrameStrata("DIALOG")
			GMR.Buttons["ButtonDataTable"..i] = f
		end
		result[getn(result)+1] = GMR.Buttons["ButtonDataTable"..i]
	end	
	return result
end

function GMR.SortTableData()
	if not GMR.DataTableHistoryMode then
		local s = GMR.SortData.Use
		if s and GMR.SortData[s[1]] then
			GMR.SortData[s[1]](s[2], s[3], s[4])
		end
	end
end

function GMR.FindInDataTable(str)
	GMR.CurrentDataTableElements = {}
	local iter = 1
	if not GMR.DataTableHistoryMode then
		for i = 1, getn(GMR.DataTable) do
			if not GMR.DataTable[i].Disable then
				for j = 1, getn(GMR.DataTable[i]) do
					for k = 1, getn(GMR.DataTable[i][j][1]) do
						if string.find(string.lower(GMR.DataTable[i][j][1][k]), str) then
							GMR.CurrentDataTableElements[iter] = {i, j}
							iter = iter + 1
							break
						end				
					end
				end
			end
		end
	else
		for i = 1, getn(GMR.DataTable) do
			local message = GMR.DataTable[i].message
			if not message then message = "" end
			if string.find(string.lower(GMR.DataTable[i].message), str) then
				GMR.CurrentDataTableElements[iter] = {i, 1}
				iter = iter + 1
			end	
		end
	end
	return getn(GMR.CurrentDataTableElements)	
end

----------Commands to work with data-----------
GMR.MiniDataTableMas = {}

function GMR.UpdateMiniDataTableElement(Button, value)
	local str = string.format(GMR.MiniDataTableMas[value], GMR.MiniDataTableMas.text)
	Button:SetText(str)
	--Button:SetWidth(GMR.GetStringPixelLength(str))
	Button:SetScript("OnEnter", 
		function()
		    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
			GameTooltip:AddLine(this:GetText())
			GameTooltip:Show()
			SLib.CallStack.NewCall(GMR.HideFrame, 3, GMR.Tables["MiniData"])
		end
	)
	Button:SetScript("OnLeave", 
		function()
		    GameTooltip:Hide()
		end
	)
	Button:SetScript("OnClick", 
		function()
		    if string.sub(this:GetText(), 1, 2) == "." then
		    	GMR.SendCommandSafe(this:GetText(), GMR.MiniDataTableMas.command, GMR.common_handle)
		    else
		    	GMR.addon_handle(this:GetText())
		    end
		    SLib.CallStack.NewCall(GMR.HideFrame, 3, GMR.Tables["MiniData"])
		end
	)
end

function GMR.CreateMiniDataTableElements(number)
	local f, t, s
	local result = {}
	for i = 1, number do
		if not GMR.Buttons["ButtonMiniDataTable"..i] then
			f = CreateFrame("Button", "ButtonMiniDataTable"..i, nil, "CommandButtonTemplate")
			--f:SetFrameStrata("HIGH")
			f:SetHeight(20)
			f:SetWidth(GMR.MINI_DATA_TABLE_WIDTH)
			f:SetScript("OnLeave", 
				function()
			       GameTooltip:Hide();
			    end
			)		
			t = f:GetFontString()
			t:SetPoint("LEFT", f, "LEFT", 15, 0)
			GMR.Buttons["ButtonMiniDataTable"..i] = f
		end
		result[getn(result)+1] = GMR.Buttons["ButtonMiniDataTable"..i]
	end	
	return result	
end

function GMR.SortMiniTableData()
end

function GMR.FindInMiniDataTable(data, text, command)
	if text then
		GMR.MiniDataTableMas = {}
		for i = 1, getn(data) do
			GMR.MiniDataTableMas[i] = data[i]
		end
		GMR.MiniDataTableMas.text = text
		GMR.MiniDataTableMas.command = command
	end
	return getn(GMR.MiniDataTableMas)
end

GMR.DATA_TABLE_ELEMENTS = 20
GMR.DATA_TABLE_WIDTH = 1024
GMR.MINI_DATA_TABLE_WIDTH = 100

function GMR.SetDataTableSize(h, w, update)
	if update  then
		h = GMR.DataTableFrame:GetHeight()
		w = GMR.DataTableFrame:GetWidth()
	else
		GMR.DataTableFrame:SetWidth(w)
		GMR.DataTableFrame:SetHeight(h)
	end
	h = h - 100
	w = w - 100
	GMR.DATA_TABLE_ELEMENTS = floor(h/26)
	h = GMR.DATA_TABLE_ELEMENTS*26
	GMR.Tables["Data"]:SetWidth(w)
	GMR.Tables["Data"]:SetHeight(h)
	GMR.Tables["Data"]:GetScrollChild():SetHeight(h)
	GMR.EditBoxes["sort".."Data".."Table"]:SetWidth(w/2-10)
	GMR.ScrollBars["DataTableH"]:SetWidth(w)
	GMR.ScrollBars["DataTableV"]:SetHeight(h)
	local maxval = max(0, GMR.Tables["Data"]:GetScrollChild():GetWidth()-w)
	GMR.ScrollBars["DataTableH"]:SetMinMaxValues(0, maxval)
	GMR.DATA_TABLE_ELEMENTS = floor(h/26)
	local buttons_mas = GMR.CreateDataTableElemets(GMR.DATA_TABLE_ELEMENTS)
	GMR.Tables._Init("Data", buttons_mas, GMR.UpdateDataTableElement, GMR.FindInDataTable, GMR.SortTableData)
	GMR.Tables._Update("Data", GMR.ScrollBars["DataTableV"]:GetValue())
	if GMR.DataTableSizeUpdate then
		SLib.CallStack.NewCall(GMR.SetDataTableSize, 0.001, h, w, true)
	end
end

function GMR.CreateDataTableFrame()
	local f = CreateFrame("Frame", "DataTableFrame", UIParent)
	GMR.MakeMoovable(f)
	f:SetFrameStrata("DIALOG")
	f:SetWidth(GMR.DATA_TABLE_WIDTH + 100)
	f:SetHeight(GMR.DATA_TABLE_ELEMENTS*26 + 100)
	f:SetBackdrop( { 
  		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
  		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
  		tile = true, tileSize = 32, edgeSize = 32, 
  		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	f:SetPoint("CENTER", UIParent, "CENTER")
	GMR.AddCloseButton(f)
	f:Hide()
	f:SetScript("OnHide", function() GMR.BLOCK_SEND_COMMAND = false end)
	f:SetScript("OnShow", function() GMR.BLOCK_SEND_COMMAND = true end)
	f:SetResizable(true)
	f:SetMinResize(200, 200)
	local anchor_resize_point = {"BOTTOM", "BOTTOMRIGHT", "BOTTOMLEFT", "TOP", "TOPRIGHT", "TOPLEFT", "LEFT", "RIGHT"}
	local sizer
	for i = 1, getn(anchor_resize_point) do
		sizer = CreateFrame("Frame", nil, f)
		sizer:SetPoint(anchor_resize_point[i], 0, 0)
		sizer:SetWidth(25)
		sizer:SetHeight(25)
		sizer:EnableMouse()
		local point = anchor_resize_point[i]
		sizer:SetScript("OnMouseDown",
			function()
				this:GetParent():StartSizing(point)
				GMR.DataTableSizeUpdate = true
				GMR.SetDataTableSize(this:GetParent():GetHeight(), this:GetParent():GetWidth(), true)
			end
		)
		sizer:SetScript("OnMouseUp",
			function()
				this:GetParent():StopMovingOrSizing()
				GMR.DataTableSizeUpdate = false
				GMR.SetDataTableSize(this:GetParent():GetHeight(), this:GetParent():GetWidth(), true)
			end
		)
	end
	return f
end

function GMR.BuildDataFrame()
	GMR.DataTableFrame = GMR.CreateDataTableFrame()
	local buttons_mas = GMR.CreateDataTableElemets(GMR.DATA_TABLE_ELEMENTS)
 	GMR.Tables._Init("Data", buttons_mas, GMR.UpdateDataTableElement, GMR.FindInDataTable, GMR.SortTableData)
 	GMR.Tables._CreateTable("Data", GMR.DataTableFrame, 26, GMR.DATA_TABLE_WIDTH, "CENTER", "CENTER", 0, 0, "Interface\\RaidFrame\\UI-RaidFrame-GroupBg.blp", true, true)
 	local mini_buttons_mas = GMR.CreateMiniDataTableElements(5)
 	GMR.Tables._Init("MiniData", mini_buttons_mas, GMR.UpdateMiniDataTableElement, GMR.FindInMiniDataTable, GMR.SortMiniTableData)
 	GMR.Tables._CreateTable("MiniData", GMR.Tables["Data"], 20, GMR.MINI_DATA_TABLE_WIDTH, "TOPLEFT", "TOPLEFT", 0, 0, "Interface\\RaidFrame\\UI-RaidFrame-GroupBg.blp", false, false)
 	GMR.Tables["MiniData"]:Hide()
 	GMR.Tables["MiniData"]:SetScript("OnShow", function() SLib.CallStack.NewCall(GMR.HideFrame, 3, GMR.Tables["MiniData"]) end)

 	local cb1 = GMR.CreateCheckButton("History Mode", 0, -10, GMR.Tables["Data"], "BOTTOMRIGHT", "TOPRIGHT", "See History mode of table, visualization of command blocks")
	local s = cb1:GetScript("OnClick")
	cb1:SetScript("OnClick", function() 	
		GMR.DataTableHistoryMode = not GMR.DataTableHistoryMode
		GMR.Tables._Update("Data")
		s()
	end)
--[[	local cb1 = GMR.CreateCheckButton("check acclevelDataTable", 0, -10, GMR.Tables["Data"], "BOTTOMRIGHT", "TOPRIGHT", "See commands with access <= my GMLevel")
				GMR.CreateCheckButton("accesssortDataTable", -20, -10, GMR.Tables["Data"], "BOTTOMRIGHT", "TOPRIGHT", "Use sort by access level")
				GMR.CreateCheckButton("search in descriptionDataTable", -40, -10, GMR.Tables["Data"], "BOTTOMRIGHT", "TOPRIGHT", "Search at command description \n(that giant tooltips text)")
	local cb2 = GMR.CreateCheckButton("search in commandsDataTable", -60, -10, GMR.Tables["Data"], "BOTTOMRIGHT", "TOPRIGHT", "Search at name of commands")
	local s = cb1:GetScript("OnClick")
	cb1:SetScript("OnClick", function() 	
		if this:GetChecked() then
			GMR.GetResult.account = GMR.command_handle_functions.account
			GMR.SendCommandSafe(".account", "account")
		end
		s()
	end)
	cb1:Click()
	cb2:Click()]]--
end
