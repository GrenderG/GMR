if not GMR then 
	GMR = {} 
end

function GMR.DeleteCommandTemplate(name, group, command)
	if GMRConfig.Templates[command] and GMRConfig.Templates[command][group] and GMRConfig.Templates[command][group][name] then
		GMRConfig.Templates[command][group][name] = nil
		if GMR.getn_keymas(GMRConfig.Templates[command][group]) == 0 then
			GMRConfig.Templates[command][group] = nil
		end
	end
end

function GMR.SaveCommandTemplate(name, group, text_to_run, command)
	if not GMRConfig.Templates[command] then 
		GMRConfig.Templates[command] = {}
	end
	if not GMRConfig.Templates[command][group] then
		GMRConfig.Templates[command][group] = {}
	end
	GMRConfig.Templates[command][group][name] = text_to_run
end

GMR.ENUM_NAME 	= 0
GMR.ENUM_GROUP 	= 1
GMR.ENUM_TYPE 	= 2

GMR.CurrentTemplateTableElements = {
--[0] = {ENUM, type, group, name}  hide_option vs name for ENUM_GROUP
}

function GMR.UpdateTemplateTableElement(Button, value)

	Button:SetScript("OnClick", function() end)
	Button:SetScript("OnEnter", function() end)
	local data = GMR.CurrentTemplateTableElements[value]
	if data[1] == GMR.ENUM_TYPE then
		Button:SetText("\124cff"..SLib.ColorTable["Lime"]..data[2].."\124r")
	elseif data[1] == GMR.ENUM_GROUP then
		Button:SetText("\124cff"..SLib.ColorTable["Snow"]..data[3].."\124r")
		Button:SetScript("OnClick", 
			function()
				data[4] = not data[4] -- switch hide state
				GMR.Tables._Params["Template"].CurrentSize = GMR.FindInTemplateTable(GMR.EditBoxes["sortTemplateTable"]:GetText(), true) 
				GMR.SortTableTemplate()
				GMR.Tables._Update("Template", GMR.ScrollBars["TemplateTableV"]:GetValue(), "Slider")
			end
		)
	else
		Button:SetText(data[4])
		Button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		Button:SetScript("OnEnter", function()
			local command = GMR.CommandDataOnClick["current_command"]
			local text_to_run
			if data[2] == "Custom" then
				text_to_run = GMRConfig.Templates[command][data[3]][data[4]]
			elseif data[2] == "Default" then
				text_to_run = GMR.template_data[command][data[3]][data[4]]
			end
			local res = {}
			if type(text_to_run) == "table" then
				for i = 1, getn(text_to_run) do
					res[i] = "textbox_"..i.." = "..text_to_run[i]
				end
				text_to_run = res
			end
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
			GameTooltip:AddLine(data[4])
			local tooltip = GMR.HandleTooltip(text_to_run)
				if type(tooltip) == "table" then
				   	for i = 1, getn(tooltip) do
				   		GameTooltip:AddLine(tooltip[i]);
				   	end
				else
				   	GameTooltip:AddLine(tooltip);
				end
				if data[2] == "Custom" then 
					GameTooltip:AddLine("Delete OnRightClick")
				end
				GameTooltip:Show();
			end
		)
		Button:SetScript("OnClick", 
			function()
			    local command = GMR.CommandDataOnClick["current_command"]
				local text_to_run
				if data[2] == "Custom" then
					text_to_run = GMRConfig.Templates[command][data[3]][data[4]]
				elseif data[2] == "Default" then
					text_to_run = GMR.template_data[command][data[3]][data[4]]
				end
			    if data[2] == "Custom" and arg1 == "RightButton" then
			    	GMR.DeleteCommandTemplate(data[4], data[3], command)
			    	GMR.Tables._Update("Template")
			    elseif arg1 == "LeftButton" then
			    	if type(text_to_run) == "string" then
			    		GMR.SendCommandSafe(text_to_run, command, GMR.common_handle)
			    	else
			    		GMR.LoadCommandTemplateCorrect(text_to_run)
			    	end
			    end
			end
		)	
	end

	if MouseIsOver(Button) then
		Button:GetScript("OnLeave")()
		Button:GetScript("OnEnter")()
	end
end

function GMR.CreateTemplateTableElemets(number)
	local f, t
	local result = {}
	for i = 1, number do
		f = CreateFrame("Button", "ButtonTemplateTable"..i, nil, "CommandButtonTemplate")
		f:SetFrameStrata("HIGH")
		f:SetHeight(20)
		f:SetWidth(200)
		f:SetScript("OnLeave", 
			function()
		       GameTooltip:Hide();
		    end
		)
		t = f:GetFontString()
		t:SetPoint("LEFT", f, "LEFT", 15, 0)
		GMR.Buttons["ButtonTemplateTable"..i] = f
		result[getn(result)+1] = f
	end	
	return result
end
function GMR.SortTableTemplate()
	local mas = GMR.CurrentTemplateTableElements
	--mas[i] = {ENUM, type, group, name}
	if mas then
		local group_flag = GMR.CheckButtons["enable groupsTemplateTable"]:GetChecked()
		local customdefault_flag = GMR.CheckButtons["enable castomdefaultTemplateTable"]:GetChecked()
		local sort_rule
		if not group_flag then
			function sort_rule(a, b)		
				return a[4] < b[4]
			end
		else
			function sort_rule(a, b)
				if a[3] ~= b[3] then
					return a[3] < b[3]
				else
					if a[1] == GMR.ENUM_GROUP and b[1] == GMR.ENUM_GROUP then
						return false   --very strange specific case, it can compare element with itself, and in case true table.sort switch this element with next, and we get wrong result
					elseif a[1] == GMR.ENUM_GROUP then
						return true
					elseif b[1] == GMR.ENUM_GROUP then
						return false
					else
						return a[4] < b[4]
					end
				end
			end
		end
		if customdefault_flag and not group_flag then
			function sort_rule(a, b)
				if a[2] ~= b[2] then	
					return a[2] < b[2]
				elseif a[1] == GMR.ENUM_TYPE then
					return true
				elseif b[1] == GMR.ENUM_TYPE then
					return false
				else
					return a[4] < b[4]
				end		
			end
		end
		if customdefault_flag and group_flag then
			function sort_rule(a, b)
				if a[2] ~= b[2] then	
					return a[2] < b[2]
				elseif a[1] == GMR.ENUM_TYPE then
					return true
				elseif b[1] == GMR.ENUM_TYPE then
					return false
				elseif a[3] ~= b[3] then	
					return a[3] < b[3]
				elseif a[1] == GMR.ENUM_GROUP and b[1] == GMR.ENUM_GROUP then
					return false   --very strange specific case, it can compare element with itself, and in case true table.sort switch this element with next, and we get wrong result
				elseif a[1] == GMR.ENUM_GROUP then
					return true
				elseif b[1] == GMR.ENUM_GROUP then
					return false
				else
					return a[4] < b[4]
				end		
			end
		end
		table.sort(mas, sort_rule)
	end
end

function GMR.FindOpenGroups()
	local open_groups = {}
	for i = 1, getn(GMR.CurrentTemplateTableElements) do
		if GMR.CurrentTemplateTableElements[i][1] == GMR.ENUM_GROUP and not GMR.CurrentTemplateTableElements[i][4] then
			open_groups[GMR.CurrentTemplateTableElements[i][3]] = true
		end
	end
	return open_groups
end

function GMR.FindInTemplateTable(str, hide_refind)
	local command 					= GMR.CommandDataOnClick["current_command"]
	local group_flag 				= GMR.CheckButtons["enable groupsTemplateTable"]:GetChecked()
	local customdefault_flag 		= GMR.CheckButtons["enable castomdefaultTemplateTable"]:GetChecked()
	local searchindescription_flag 	= GMR.CheckButtons["search in descriptionTemplateTable"]:GetChecked()
	local hide						= GMR.CheckButtons["hide namesTemplateTable"]:GetChecked()
	local open_groups 
	if hide_refind then open_groups = GMR.FindOpenGroups() end
	
	GMR.CurrentTemplateTableElements = {}
	local data = GMR.CurrentTemplateTableElements	--data[i] = {ENUM, type, group, name}	-- hide_option vs name fo ENUM_GROUP
	local include_group = false						--case find name then include group
	local include_name =  false						--case find group then include name
	local include_type = false						--case found something then include that common worlds

	if GMRConfig.Templates and GMRConfig.Templates[command] then
		for group, templates in pairs(GMRConfig.Templates[command]) do
			include_group = false
			include_name =  false	
			if hide_refind and open_groups[group] then 
				hide = false
			else
				hide = GMR.CheckButtons["hide namesTemplateTable"]:GetChecked()
			end
			if group_flag and string.find(string.lower(group), str) then
				include_name = true
			end
			if hide_refind and open_groups[group] then 
				hide = false
			else
				hide = GMR.CheckButtons["hide namesTemplateTable"]:GetChecked()
			end
			for name in pairs(templates) do
				if include_name or string.find(string.lower(name), str) or (searchindescription_flag and string.find(string.lower(GMRConfig.Templates[command][group][name]), str)) then
					if not hide then data[getn(data)+1] = {GMR.ENUM_NAME, "Custom", group, name} end
					include_group = true	
					include_type = true
				end
			end
			if group_flag and (include_name or include_group) then
				data[getn(data)+1] = {GMR.ENUM_GROUP, "Custom", group, hide}
			end
		end	
	end
	if include_type and customdefault_flag and GMRConfig.Templates and GMRConfig.Templates[command] and GMR.getn_keymas(GMRConfig.Templates[command]) > 0 then
		data[getn(data)+1] = {GMR.ENUM_TYPE, "Custom"}
	end

	include_type = false
	if GMR.template_data[command] then
		for group, templates in pairs(GMR.template_data[command]) do
			include_group = false
			include_name =  false	
			if hide_refind and open_groups[group] then 
				hide = false
			else
				hide = GMR.CheckButtons["hide namesTemplateTable"]:GetChecked()
			end
			if group_flag and string.find(string.lower(group), str) then
				include_name = true
			end
			for name in pairs(templates) do
				if include_name or string.find(string.lower(name), str) or (searchindescription_flag and string.find(string.lower(GMR.template_data[command][group][name]), str)) then
					if not hide then data[getn(data)+1] = {GMR.ENUM_NAME, "Default", group, name} end
					include_group = true
					include_type = true	
				end
			end
			if group_flag and (include_name or include_group) then
				data[getn(data)+1] = {GMR.ENUM_GROUP, "Default", group, hide}
			end
		end	
	end	
	if include_type and customdefault_flag and GMR.template_data and GMR.template_data[command] and GMR.getn_keymas(GMR.template_data[command]) > 0 then
		data[getn(data)+1] = {GMR.ENUM_TYPE, "Default"}
	end
	return getn(data)
end

function GMR.BuildTemplateFrame(name)
	if not GMR.Tables["Template"] then
		local buttons_mas = GMR.CreateTemplateTableElemets(10)
	 	GMR.Tables._Init("Template", buttons_mas, GMR.UpdateTemplateTableElement, GMR.FindInTemplateTable, GMR.SortTableTemplate)
 		GMR.Tables._CreateTable("Template", GMR.TableFrame, 20, 200, "RIGHT", "RIGHT", -270, 0, "Interface\\RaidFrame\\UI-RaidFrame-GroupBg.blp", true)	
		local cb1 = GMR.CreateCheckButton("enable groupsTemplateTable", 0, -10, GMR.Tables["Template"], "BOTTOMRIGHT", "TOPRIGHT", "Enable groups sort")
		local cb2 = GMR.CreateCheckButton("enable castomdefaultTemplateTable", -20, -10, GMR.Tables["Template"], "BOTTOMRIGHT", "TOPRIGHT", "Enable User/Default sort")
		local cb3 = GMR.CreateCheckButton("search in descriptionTemplateTable", -40, -10, GMR.Tables["Template"], "BOTTOMRIGHT", "TOPRIGHT", "Enable search in sending command")
		local cb4 = GMR.CreateCheckButton("hide namesTemplateTable", -60, -10, GMR.Tables["Template"], "BOTTOMRIGHT", "TOPRIGHT", "Enable compact form, hide results in groups")
		local s = cb1:GetScript("OnClick")
		cb1:SetScript("OnClick", function() 	
			GMR.Tables._Update("Template")
			s()
		end)
		local s = cb2:GetScript("OnClick")
		cb2:SetScript("OnClick", function() 	
			GMR.Tables._Update("Template")
			s()
		end)
		local s = cb3:GetScript("OnClick")
		cb3:SetScript("OnClick", function() 	
			GMR.Tables._Update("Template")
			s()
		end)
		local s = cb4:GetScript("OnClick")
		cb4:SetScript("OnClick", function() 	
			GMR.Tables._Update("Template")
			s()
		end)
		cb1:SetChecked()
		cb2:Click()
	else
		GMR.Tables._Update("Template")
	end
end