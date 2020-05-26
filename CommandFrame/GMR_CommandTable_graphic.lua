if not GMR then 
	GMR = {} 
end

GMR.CommandDataOnClick = {}

--will store here all objects
GMR.CommandDataOnClick = {
--[[
	["current_command"] = "account"
	["exec_button"] = frame
	["result_box"] = frame
	["command1"] = {
		["stack"] = {"$password", "|", "[", "#number", "]", "otheroption"},
		["command_original"] = command_original
		["command_for_print"] = command_for_print	
		for each variable will store link information
		MarkMachine = {
			["name1"] = {mark1, mark2}
			["name2"] = {mark1, mark2}
			["name3"] - {mark1, mark2}
		}
	}
	["visible_objects"]
]]
}

function GMR.RebuildResult(ebox)
	local command = GMR.CommandDataOnClick["current_command"]
	local data = GMR.CommandDataOnClick[command]
	local result = ""
	local f
	result = result.."."..GMR.CommandDataOnClick["current_command"]
	local frames_result = {}
	for i = 1, getn(GMR.CommandDataOnClick["visible_objects"]) do
		f = GMR.CommandDataOnClick["visible_objects"][i]
		if f:GetObjectType() == "CheckButton" and f:GetChecked() then
			local _, _, name = string.find(f:GetName(), "(.+)parsed")
			frames_result[getn(frames_result)+1] = name
		elseif f:GetObjectType() == "EditBox" and not string.find(f:GetName(), "dupl") and f:GetName() ~= ebox:GetName() and f:GetText() ~= "" then
			frames_result[getn(frames_result)+1] = f:GetText()
		elseif f:GetObjectType() == "CheckButton" or (f:GetObjectType() == "EditBox" and not string.find(f:GetName(), "dupl") and f:GetName() ~= ebox:GetName()) then
			frames_result[getn(frames_result)+1] = ""
		end
	end
	local frames_result_iter = 1
	local var_type
	local quote_counter = 1			-- 1 if not open, 0 if open
	for i = 1, getn(data.stack) do
		var_type = GMR.GetStackType(data.stack[i][1])
		if var_type == "text" or var_type == "number" or var_type == "option" then
			if frames_result[frames_result_iter]~="" then
				result = result..strrep(" ", quote_counter)..frames_result[frames_result_iter]
			end
			frames_result_iter = frames_result_iter + 1
		elseif var_type == "quote" and ((quote_counter==1 and frames_result[frames_result_iter] and frames_result[frames_result_iter] ~= "") or (quote_counter==0 and frames_result[frames_result_iter-1] and frames_result[frames_result_iter-1] ~= "")) then
			result = result..strrep(" ", quote_counter)..data.stack[i][1]
			quote_counter = mod(quote_counter+1, 2)
		end
	end	
	ebox:SetText(result)
end

function GMR.MarkMachine(var_type)
	local t
	if not GMR.TempObjects["MarkMachine"] or var_type == "reset" then
		GMR.TempObjects["MarkMachine"] = {
			["ORmark"] = "1",
			["BracketMark"] = "0",
			["usedbracket"] = {0}
		}
	end
	local ORmark = GMR.TempObjects["MarkMachine"]["ORmark"]
	local BracketMark = GMR.TempObjects["MarkMachine"]["BracketMark"]
	if var_type == "OR" then
		ORmark = tostring(tonumber(ORmark)+1)
	elseif var_type == "open" then
		ORmark = ORmark.."1"
		local add_toBracketMark = tonumber(string.sub(BracketMark, strlen(BracketMark)-1)) + 1
		while GMR.FindInMas(add_toBracketMark, GMR.TempObjects["MarkMachine"]["usedbracket"]) do
			add_toBracketMark = add_toBracketMark + 1
		end
		BracketMark = BracketMark..tostring(add_toBracketMark)
	elseif var_type == "close" then
		ORmark = string.sub(ORmark, 1, strlen(ORmark)-1)
		if ORmark == "" then
			GMR.Print("Wrong bracket ballance, check it at Interface/Addons/GMR/GMR_command_data.lua")
		end
		ban_mark 	= tonumber(string.sub(BracketMark, strlen(BracketMark)-1))
		if not GMR.FindInMas(ban_mark, GMR.TempObjects["MarkMachine"]["usedbracket"]) then
			GMR.TempObjects["MarkMachine"]["usedbracket"][getn(GMR.TempObjects["MarkMachine"]["usedbracket"])+1] = ban_mark
		end
		BracketMark = string.sub(BracketMark, 1, strlen(BracketMark)-1)
	end
	GMR.TempObjects["MarkMachine"]["ORmark"] = ORmark
	GMR.TempObjects["MarkMachine"]["BracketMark"] = BracketMark
end

function GMR.SetMarkMachineScript(frame, t_type)
	
	if t_type == "CheckButton" then
		orig_script = frame:GetScript("OnClick")
		GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["Scripts"][frame:GetName()] = orig_script
		frame:SetScript("OnClick", 
			function()
				if this:GetChecked() then
					local mas = GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["TurnOff"][this:GetName()]
					
					for i = 1, getn(mas) do
						if mas[i] and mas[i]:GetObjectType() == "CheckButton" then
							if mas[i]:GetChecked() then
								mas[i]:SetChecked(false)
							end
						elseif mas[i] and mas[i]:GetObjectType() == "EditBox" then
							if mas[i]:GetText() and strlen(mas[i]:GetText()) > 0 then
								mas[i]:SetText("")
							end						
						end
					end
				end
				GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["Scripts"][this:GetName()]()
			end
		)
	elseif t_type == "EditBox" then
		orig_script = frame:GetScript("OnTextChanged")	
		GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["Scripts"][frame:GetName()] = orig_script
		frame:SetScript("OnTextChanged", 
			function()
				if this:GetText() and strlen(this:GetText()) > 0 then
					local mas = GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["TurnOff"][this:GetName()]
					if mas then	
						for i = 1, getn(mas) do
							if mas[i] and mas[i]:GetObjectType() == "CheckButton" then
								if mas[i]:GetChecked() then
									mas[i]:SetChecked(false)
								end
							elseif mas[i] and mas[i]:GetObjectType() == "EditBox" then
								if mas[i]:GetText() and strlen(mas[i]:GetText()) > 0 then
									mas[i]:SetText("")
								end						
							end
						end
					end
				end
				GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["Scripts"][this:GetName()]()
			end
		)
	end
end

function GMR.MakeLink(frame1, frame2, type1, type2)
	local mas = GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["TurnOff"][frame1:GetName()]
	if not mas then GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["TurnOff"][frame1:GetName()] = {} end
	mas = GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["TurnOff"][frame1:GetName()]
	if not GMR.FindInMas(frame2:GetName(), mas) then
		GMR.CommandDataOnClick[GMR.CommandDataOnClick["current_command"]]["TurnOff"][frame1:GetName()][getn(mas)+1] = frame2
	end
end

function GMR.LinkMarks()
	local f1, f2, t1, t2, m1_OR, m1_Bracket, m2_OR, m2_Bracket, m1l, m2l, minlen
	local command = GMR.CommandDataOnClick["current_command"]
	for i = 1, getn(GMR.CommandDataOnClick["visible_objects"]) do
		f1 = GMR.CommandDataOnClick["visible_objects"][i]
		t1 = f1:GetObjectType()
		if t1 == "CheckButton" or t1 == "EditBox" and f1 ~= GMR.CommandDataOnClick["result_box"] and not string.find(f1:GetName(), "dupl") then
			for j = 1, getn(GMR.CommandDataOnClick["visible_objects"]) do
				f2 = GMR.CommandDataOnClick["visible_objects"][j]
				t2 = f2:GetObjectType()	
				if t2 == "CheckButton" or t2 == "EditBox" and f2 ~= GMR.CommandDataOnClick["result_box"] and not string.find(f2:GetName(), "dupl") and f1:GetName() ~= f2:GetName() then
				m1_OR = GMR.CommandDataOnClick[command]["MarkMachine"][f1:GetName()][1]
				m1_Bracket = GMR.CommandDataOnClick[command]["MarkMachine"][f1:GetName()][2]
					m2_OR = GMR.CommandDataOnClick[command]["MarkMachine"][f2:GetName()][1]
					m2_Bracket = GMR.CommandDataOnClick[command]["MarkMachine"][f2:GetName()][2]
					minlen_OR = min(strlen(m1_OR), strlen(m2_OR))
					minlen_Bracket = min(strlen(m1_Bracket), strlen(m2_Bracket))
					m1_OR = string.sub(m1_OR, 1, minlen_OR)
					m2_OR = string.sub(m2_OR, 1, minlen_OR)
					m1_Bracket = string.sub(m1_Bracket, 1, minlen_Bracket)
					m2_Bracket = string.sub(m2_Bracket, 1, minlen_Bracket)
					bracket_OR1 = string.sub(m1_OR, 1, minlen_OR-1)
					bracket_OR2 = string.sub(m2_OR, 1, minlen_OR-1)
					if not ((m1_OR == m2_OR)or(m1_Bracket ~= m2_Bracket and bracket_OR1 == bracket_OR2 )) then
						GMR.MakeLink(f1, f2, t1, t2)
					end
				end
			end
			GMR.SetMarkMachineScript(f1, t1)
		end
	end
end

function GMR.CommandButtonOnClick_AddFrame(var, str_pix, word_offset_pix, word_length, dupl_iter)
	local f, f1, f2, obj_name, var_type, data, command
	local command = GMR.CommandDataOnClick["current_command"]
	local data = GMR.CommandDataOnClick[command]
	obj_name = var.."parsed"..command
	var_type = GMR.GetStackType(var)
	if var_type == "option" or var_type == "number" or var_type == "text" then
		if not data["name_repeats"][obj_name] then
			GMR.CommandDataOnClick[command]["name_repeats"][obj_name] = 1
		else
			GMR.CommandDataOnClick[command]["name_repeats"][obj_name] = data["name_repeats"][obj_name] + 1
			obj_name = obj_name.."_"..data["name_repeats"][obj_name]
		end
		if var_type == "option" then
			f = GMR.CreateCheckButton(obj_name, -str_pix/2 + word_offset_pix + word_length/2, 40, GMR.TableFrame, "CENTER", "TOP", "Set "..GMR.WordNormalize(var))
			f:SetScript("OnClick", 
			function()
				GMR.RebuildResult(GMR.EditBoxes["result"..command])
			end
		)
		elseif var_type == "number" then
			f  = GMR.CreateEditNumberBox(obj_name, -str_pix/2 + word_offset_pix + 2, 40, GMR.TableFrame, word_length-2, 25, "LEFT", "TOP", {"Set "..GMR.WordNormalize(var), "Number", "Tips: MouseWheel Enabled"})
			f1 = GMR.CreateEditNumberBox(obj_name.."dupl", 200, 100 + dupl_iter*35, GMR.TableFrame, 100, 25, "TOPLEFT", "TOPLEFT", {"Set "..GMR.WordNormalize(var), "Number", "Tips: MouseWheel Enabled"})
			f2 = GMR.CreateTitle(obj_name, -15, 0, f1, GMR.WordNormalize(var)..": ", "RIGHT", "LEFT")
			f:SetScript("OnTextChanged",
				function()
					local temp_t = this:GetText()
					temp_t = gsub(temp_t, "([^0-9%-%.a-fA-F]+)", "")
					this:SetText(temp_t)
					local _,_,name = string.find(this:GetName(), "(.+)EditNumBox")
					GMR.EditNumBoxes[name.."dupl"]:SetText(temp_t)
					GMR.RebuildResult(GMR.EditBoxes["result"..GMR.CommandDataOnClick["current_command"]])
				end
			)
			f1:SetScript("OnTextChanged",
				function()
					local temp_t = this:GetText()
					temp_t = gsub(temp_t, "([^0-9%-%.a-fA-F]+)", "")
					this:SetText(temp_t)
					local _,_,name = string.find(this:GetName(), "(.+)dupl")
					GMR.EditNumBoxes[name]:SetText(temp_t)
					GMR.RebuildResult(GMR.EditBoxes["result"..GMR.CommandDataOnClick["current_command"]])
				end
			)
			dupl_iter = dupl_iter + 1
		elseif var_type == "text" then
			f  = GMR.CreateEditBox(obj_name, -str_pix/2 + word_offset_pix + 2, 40, GMR.TableFrame, word_length-2, 25, "LEFT", "TOP", {"Set "..GMR.WordNormalize(var), "Tips: Text"})
			f1 = GMR.CreateEditBox(obj_name.."dupl", 200, 100 + dupl_iter*35, GMR.TableFrame, 100, 25, "TOPLEFT", "TOPLEFT", {"Set "..GMR.WordNormalize(var),"Tips: Text"})
			f2 = GMR.CreateTitle(obj_name, -15, 0, f1, GMR.WordNormalize(var)..": ", "RIGHT", "LEFT")
			f:SetScript("OnTextChanged",
				function()
					local temp_t = this:GetText()
					local _,_,name = string.find(this:GetName(), "(.+)EditBox")
					GMR.EditBoxes[name.."dupl"]:SetText(temp_t)
					GMR.RebuildResult(GMR.EditBoxes["result"..GMR.CommandDataOnClick["current_command"]])
				end
			)
			f1:SetScript("OnTextChanged",
				function()
					local temp_t = this:GetText()
					local _,_,name = string.find(this:GetName(), "(.+)dupl")
					GMR.EditBoxes[name]:SetText(temp_t)
					GMR.RebuildResult(GMR.EditBoxes["result"..GMR.CommandDataOnClick["current_command"]])
				end
			)
			dupl_iter = dupl_iter + 1
		end
		f:Show()
		if f1 then f1:Show() end
		if f2 then f2:Show() end
		GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = f
		if f1 then GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = f1 end
		if f2 then GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = f2 end
		GMR.CommandDataOnClick[command]["MarkMachine"][f:GetName()] = {GMR.TempObjects["MarkMachine"]["ORmark"], GMR.TempObjects["MarkMachine"]["BracketMark"]}
	else
		GMR.MarkMachine(var_type)
	end
	return dupl_iter
end

function GMR.SaveCommandTemplateCorrect(name, group, text, command)
	local f
	local iter = 1
	if GMR.CheckButtons["SaveOnlyTextboxes"] then
		text = {}
		for i = 1, getn(GMR.CommandDataOnClick["visible_objects"]) do
			f = GMR.CommandDataOnClick["visible_objects"][i]
			if f:GetObjectType() == "EditBox" and not string.find(f:GetName(), "dupl") and f:GetName() ~= GMR.EditBoxes["result"..GMR.CommandDataOnClick["current_command"]]:GetName() then
				text[iter] = f:GetText()
				iter = iter + 1
			end
		end
	end
	GMR.SaveCommandTemplate(name, group, text, command)
end

function GMR.LoadCommandTemplateCorrect(data)
	local f
	local iter = 1
	for i = 1, getn(GMR.CommandDataOnClick["visible_objects"]) do
		f = GMR.CommandDataOnClick["visible_objects"][i]
		if f:GetObjectType() == "EditBox" and not string.find(f:GetName(), "dupl") and f:GetName() ~= GMR.EditBoxes["result"..GMR.CommandDataOnClick["current_command"]]:GetName() and data[iter] then
			if data[iter] ~= "" then
				f:SetText(data[iter])
			end
			iter = iter + 1
		end
	end
end

function GMR.ScanTemplateName(parent)
	local f
	f = GMR.CreateEditBox("TemplateName", 0, 10, parent, 200, 25, "TOP", "BOTTOM", {"Write template name", "When you'll ready:\n click save button again\n or press Enter"})
	f:SetScript("OnEnterPressed", 
		function()
			if this:GetText() ~= "" then
				GMR.SaveCommandTemplateCorrect(this:GetText(), GMR.EditBoxes["TemplateGroup"]:GetText(), GMR.CommandDataOnClick["result_box"]:GetText(), GMR.CommandDataOnClick["current_command"])
				this:Hide()
				GMR.EditBoxes["TemplateGroup"]:Hide()
				GMR.CheckButtons["SaveOnlyTextboxes"]:Hide()
				GMR.Tables._Update("Template")
			end
		end
	)
	f:Show()
	f = GMR.CreateTitle("TemplateName", -15, 0, f, "Name: ", "RIGHT", "LEFT")
	f = GMR.CreateEditBox("TemplateGroup", 0, 40, parent, 200, 25, "TOP", "BOTTOM", {"Write template group", "(templates will be sorted by groups for every command)\n When you'll ready:\n click save button again\n or press Enter"})
	f:SetScript("OnEnterPressed", 
		function()
			if GMR.EditBoxes["TemplateName"]:GetText() ~= "" then
				GMR.SaveCommandTemplateCorrect(GMR.EditBoxes["TemplateName"]:GetText(), this:GetText(), GMR.CommandDataOnClick["result_box"]:GetText(), GMR.CommandDataOnClick["current_command"])
				this:Hide()
				GMR.EditBoxes["TemplateName"]:Hide()
				GMR.CheckButtons["SaveOnlyTextboxes"]:Hide()
				GMR.Tables._Update("Template")
			end
		end
	)
	f:Show()
	f = GMR.CreateTitle("TemplateGroup", -15, 0, f, "Group: ", "RIGHT", "LEFT")
	f:Show()
	f = GMR.CreateCheckButton("SaveOnlyTextboxes", -110, 28, parent, "TOP", "BOTTOM", "Save only textbox text.")
	f:Show()
	--f:SetFocus()
end

function GMR.CommandButtonOnClick()
	local f, fres
	local command = GMR.CommandDataOnClick["current_command"]
	local data = GMR.CommandDataOnClick[command]
	local dupl_iter = 0
			
	for i = 1, getn(GMR.CommandDataOnClick["visible_objects"]) do
		GMR.CommandDataOnClick["visible_objects"][i]:Hide()
		GMR.CommandDataOnClick["visible_objects"][i] = nil
	end
	GMR.CommandDataOnClick["visible_objects"] = {}

	f = GMR.CreateButton("SendTableResult", 0, 0, 100, 30, GMR.TableFrame, "CENTER", "CENTER", "Execute", "Push to send command in /say")
	f:Show()	
	GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = f
	GMR.CommandDataOnClick["exec_button"] = f

	f = GMR.CreateButton("SaveTemplate", 0, 10, 100, 30, GMR.Tables["Command"], "TOP", "BOTTOM", "Save", "Make template to run command with need args")
	f:Show()	
	GMR.Buttons["SaveTemplate"]:SetScript("OnClick", 
			function()
				if not GMR.EditBoxes["TemplateName"] or not GMR.EditBoxes["TemplateName"]:IsShown() then
					GMR.ScanTemplateName(this)
				elseif GMR.EditBoxes["TemplateName"]:GetText() ~= "" and GMR.EditBoxes["TemplateName"]:IsShown() then
					GMR.SaveCommandTemplateCorrect(GMR.EditBoxes["TemplateName"]:GetText(), GMR.EditBoxes["TemplateGroup"]:GetText(), GMR.CommandDataOnClick["result_box"]:GetText(), GMR.CommandDataOnClick["current_command"])
					GMR.EditBoxes["TemplateName"]:Hide()
					GMR.EditBoxes["TemplateGroup"]:Hide()
					GMR.CheckButtons["SaveOnlyTextboxes"]:Hide()
			       	GMR.Tables._Update("Template")
				end
			end
		)	
	GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = f
	GMR.CommandDataOnClick["exec_button"] = f
	
	f = GMR.CreateTitle("parsed"..command, 0, 20, GMR.TableFrame, data["command_for_print"], "CENTER", "TOP")
	fres  = GMR.CreateEditBox("result"..command, 0, 0, GMR.TableFrame, 400, 25, "LEFT", "TOP", {"Result"})
	f:Show()
	fres:Show()
	GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = f
	GMR.CommandDataOnClick["visible_objects"][getn(GMR.CommandDataOnClick["visible_objects"])+1] = fres
	GMR.CommandDataOnClick["result_box"] = fres
	local str_pix = GMR.GetStringPixelLength(data["command_original"], GMR.WordNormalize)
	for i = 1, getn(data.stack) do
		data.stack[i][2] = data.stack[i][2] + strlen("."..command.." ")   --because offsets were calculated for only for arg_block
	end
	local word_offset_pix, word_length = GMR.GetWordsOffset(data["command_original"], data["stack"], GMR.WordNormalize)		
	GMR.CommandDataOnClick[command]["name_repeats"] = {} -- add index for obj. names in same cases: .new_pass $old_pass $new_pass $new_pass
	GMR.MarkMachine("reset") --mechanism for reset data at objects, depending on | and brackets
	GMR.CommandDataOnClick[command]["MarkMachine"] = {}
	for i = 1, getn(data.stack) do
		dupl_iter = GMR.CommandButtonOnClick_AddFrame(data.stack[i][1], str_pix, word_offset_pix[i], word_length[i], dupl_iter)
	end
	fres:ClearAllPoints()
	fres:SetPoint("TOPLEFT", GMR.TableFrame, "TOPLEFT", 40, -100 - dupl_iter*35)	
	GMR.Buttons["SendTableResult"]:ClearAllPoints()
	GMR.Buttons["SendTableResult"]:SetPoint("CENTER", fres, "CENTER", 0, -35)
	GMR.Buttons["SendTableResult"]:SetScript("OnClick", 
			function()
				GMR.SendCommandSafe(GMR.CommandDataOnClick["result_box"]:GetText(), GMR.CommandDataOnClick["current_command"], GMR.common_handle)
			end
		)
	GMR.CommandDataOnClick[command]["TurnOff"] = {}
	GMR.CommandDataOnClick[command]["Scripts"] = {}
	GMR.LinkMarks()
	GMR.RebuildResult(fres)
end

function GMR.CommandTableClick()
	local name = this:GetName()
	if string.find(name, "accesssort") or string.find(name, "search in description") or string.find(name, "search in commands")  or string.find(name, "check acclevel") then
		GMR.Tables._Update("Command")
	elseif string.find(this:GetName(), "ButtonCommandTable") then
		local f = this:GetScript("OnEnter")(this)  --Update info because of stack
		local command = GMR.CommandDataOnEnter["command"]
		if command then
			GMR.CommandDataOnClick["current_command"] = command
			if not GMR.CommandDataOnClick[command] then GMR.CommandDataOnClick[command] = {} end
			GMR.CommandDataOnClick[command]["stack"] = GMR.CommandDataOnEnter["stack"]
			GMR.CommandDataOnClick[command]["command_original"] = GMR.CommandDataOnEnter["command_original"]
			GMR.CommandDataOnClick[command]["command_for_print"] = GMR.CommandDataOnEnter["command_for_print"]
			if not GMR.CommandDataOnClick["visible_objects"] then GMR.CommandDataOnClick["visible_objects"] = {} end
			GMR.CommandButtonOnClick()
		else
			GMR.Print("Something gone wrong, can't extract data from tooltip, check it syntax.")
		end
		GMR.BuildTemplateFrame()
	end
end

function GMR.CreateTableFrame()
	local f = CreateFrame("Frame", "CommandTable", UIParent)
	GMR.MakeMoovable(f)
	--f:SetFrameStrata("HIGH")
	f:SetWidth(1024)
	f:SetHeight(768)
	f:SetBackdrop( { 
  		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
  		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
  		tile = true, tileSize = 32, edgeSize = 32, 
  		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	f:SetPoint("CENTER", UIParent, "CENTER")
	GMR.AddCloseButton(f)
	f:Hide()
	return f
end

GMR.CurrentCommandTableElements = {}

function GMR.UpdateCommandTableElement(Button, value)
	local key = GMR.CurrentCommandTableElements[value]
	Button:SetText("\124cff"..GMR.ITEM_QUALITY_COLORS[tonumber(GMR_command_data[key][1]) + 1]..key.."\124r")
	Button:SetScript("OnEnter", 
		function()
		    local key = GMR.CurrentCommandTableElements[value]
		    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
			GameTooltip:AddLine(key)
		    local str
		    local tooltip = {}
		    local t_tooltip
		    for str in string.gfind(GMR_command_data[key][2], "(.-)\n") do
		   	if getn(tooltip) ~= 0 then
		   		t_tooltip = GMR.HandleTooltip(str)
		    	else
		    		t_tooltip = {str}
		    	end
		    	if str and str ~= "" then
		    		for i = 1, getn(t_tooltip) do
		    			tooltip[getn(tooltip) + 1] = t_tooltip[i]
		    		end
		    	end
		    end
		    _, _, str = string.find(GMR_command_data[key][2], ".+\n(.-)$")
		    if str and str ~= "" then
			    if getn(tooltip) ~= 0 then
			    	t_tooltip = GMR.HandleTooltip(str)
			    else
			    	t_tooltip = {str}
			    end
		    	if str ~= "" then
		    		for i = 1, getn(t_tooltip) do
		    			tooltip[getn(tooltip) + 1] = t_tooltip[i]
		    		end
		    	end			    	
		    end
		    tooltip = GMR.SearchDescriptionVars(tooltip, key)
		    if type(tooltip) == "table" then
		     	for i = 1, getn(tooltip) do
		       		GameTooltip:AddLine(tooltip[i]);
		      	end
		    else
		       	GameTooltip:AddLine(tooltip);
		    end
		GameTooltip:Show();
		end
	)
	if MouseIsOver(Button) then
		Button:GetScript("OnLeave")()
		Button:GetScript("OnEnter")()
	end
end

function GMR.CreateCommandTableElemets(number)
	local f, t
	local result = {}
	for i = 1, number do
		f = CreateFrame("Button", "ButtonCommandTable"..i, nil, "CommandButtonTemplate")
		--f:SetFrameStrata("HIGH")
		f:SetHeight(20)
		f:SetWidth(200)
		f:SetScript("OnClick", 
			function()
		       	GMR.CommandTableClick();
		    end
		)
		f:SetScript("OnLeave", 
			function()
		       GameTooltip:Hide();
		    end
		)		
		t = f:GetFontString()
		t:SetPoint("LEFT", f, "LEFT", 15, 0)
		GMR.Buttons["ButtonCommandTable"..i] = f
		result[getn(result)+1] = f
	end	
	return result
end

function GMR.SortTableCommand()
	local mas = GMR.CurrentCommandTableElements
	if mas then
		local access = GMR.CheckButtons["accesssortCommandTable"]:GetChecked()
		if not access then
			function sort_rule(a, b)
				return a < b
			end
		else
			function sort_rule(a, b)
				if tonumber(GMR_command_data[a][1]) == tonumber(GMR_command_data[b][1]) then
					return a < b
				else
					return (tonumber(GMR_command_data[a][1]) < tonumber(GMR_command_data[b][1]))
				end
			end
		end
		table.sort(mas, sort_rule)
	end
end

function GMR.FindInCommandTable(str)
	local command_option = GMR.CheckButtons["search in commandsCommandTable"]:GetChecked()
	local descript_option = GMR.CheckButtons["search in descriptionCommandTable"]:GetChecked()
	local check_accLevel =  GMR.CheckButtons["check acclevelCommandTable"]:GetChecked()
	if not command_option and not descript_option then
		command_option = true
	end
	local command_res, descript_res, add_flag

	GMR.CurrentCommandTableElements = {}
	local result = GMR.CurrentCommandTableElements
	for key in pairs(GMR_command_data) do 
		add_flag = false
		command_res = string.find(string.lower(key), str)
		descript_res = string.find(string.lower(GMR_command_data[key][2]), str)
		if command_option and not descript_option and command_res then
			add_flag = true
		end
		if command_option and descript_option and (descript_res or command_res) then
			add_flag = true	--this case to add empty commands with out description
		end
		if not command_option and descript_option and (descript_res and not command_res) then
			add_flag = true --command search not included - for spetial search
		end
		if check_accLevel and GMR.AccessLevel < tonumber(GMR_command_data[key][1]) then
			add_flag = false
		end
		if add_flag then
			result[getn(result)+1] = key
		end
	end
	return getn(GMR.CurrentCommandTableElements)
end

function GMR.BuildTableFrame()
	GMR.TableFrame = GMR.CreateTableFrame()

	local buttons_mas = GMR.CreateCommandTableElemets(10)
 	GMR.Tables._Init("Command", buttons_mas, GMR.UpdateCommandTableElement, GMR.FindInCommandTable, GMR.SortTableCommand)
 	GMR.Tables._CreateTable("Command", GMR.TableFrame, 20, 200, "RIGHT", "RIGHT", -40, 0, "Interface\\RaidFrame\\UI-RaidFrame-GroupBg.blp", true)	
	local cb1 = GMR.CreateCheckButton("check acclevelCommandTable", 0, -10, GMR.Tables["Command"], "BOTTOMRIGHT", "TOPRIGHT", "See commands with access <= my GMLevel")
	local cb2 =	GMR.CreateCheckButton("accesssortCommandTable", -20, -10, GMR.Tables["Command"], "BOTTOMRIGHT", "TOPRIGHT", "Use sort by access level")
				GMR.CreateCheckButton("search in descriptionCommandTable", -40, -10, GMR.Tables["Command"], "BOTTOMRIGHT", "TOPRIGHT", "Search at command description \n(that giant tooltips text)")
	local cb3 = GMR.CreateCheckButton("search in commandsCommandTable", -60, -10, GMR.Tables["Command"], "BOTTOMRIGHT", "TOPRIGHT", "Search at name of commands")
	local s = cb1:GetScript("OnClick")
	cb1:SetScript("OnClick", function() 	
		if this:GetChecked() then
			GMR.GetResult.account = GMR.command_handle_functions.account
			GMR.SendCommandSafe(".account", "account")
		end
		s()
	end)
	cb1:Click()
	cb2:Click()
	cb3:Click()
end