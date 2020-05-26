if not GMR then 
	GMR = {} 
end

GMR.CurrentTicketTemplate = nil  --whisper or postmessage

function GMR.DeleteTicketTemplate(name, group, template_type)
	if GMR.CurrentTicketTemplate then
		if GMRConfig.ticket_template_data[template_type]and GMRConfig.ticket_template_data[template_type][group] and GMRConfig.ticket_template_data[template_type][group][name] then
			GMRConfig.ticket_template_data[template_type][group][name] = nil
			if GMR.getn_keymas(GMRConfig.ticket_template_data[template_type][group]) == 0 then
				GMRConfig.ticket_template_data[template_type][group] = nil
			end
		end
	end
end

function GMR.SaveTicketTemplate(name, group, text_to_run, template_type)
	if GMR.CurrentTicketTemplate then
		if not GMRConfig.ticket_template_data[template_type]then 
			GMRConfig.ticket_template_data[template_type]= {}
		end
		if not GMRConfig.ticket_template_data[template_type][group] then
			GMRConfig.ticket_template_data[template_type][group] = {}
		end
		GMRConfig.ticket_template_data[template_type][group][name] = text_to_run
	end
end

GMR.ENUM_NAME 	= 0
GMR.ENUM_GROUP 	= 1
GMR.ENUM_TYPE 	= 2

GMR.CurrentTicketTemplateTableElements = {
--[0] = {ENUM, type, group, name}  hide_option vs name for ENUM_GROUP
}

function GMR.UpdateTicketTemplateTableElement(Button, value)

	Button:SetScript("OnClick", function() end)
	Button:SetScript("OnEnter", function() end)
	if GMR.CurrentTicketTemplate then
		local data = GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate][value]
		if data[1] == GMR.ENUM_TYPE then
			Button:SetText("\124cff"..SLib.ColorTable["Lime"]..data[2].."\124r")
		elseif data[1] == GMR.ENUM_GROUP then
			Button:SetText("\124cff"..SLib.ColorTable["Snow"]..data[3].."\124r")
			Button:SetScript("OnClick", 
				function()
					local _, _, name = string.find(this:GetName(), "(.+)ButtonTicketTemplate")
					GMR.CurrentTicketTemplate = name
					data[4] = not data[4] -- switch hide state
					GMR.Tables._Params["TicketTemplate"..GMR.CurrentTicketTemplate].CurrentSize = GMR.FindInTicketTemplateTable(GMR.EditBoxes["sortTicketTemplate"..GMR.CurrentTicketTemplate.."Table"]:GetText(), true) 
					GMR.SortTicketTableTemplate()
					GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate, GMR.ScrollBars["TicketTemplate"..GMR.CurrentTicketTemplate.."TableV"]:GetValue(), "Slider")
				end
			)
		else
			Button:SetText(data[4])
			Button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
			Button:SetScript("OnEnter", function()
				local _, _, name = string.find(Button:GetName(), "(.+)ButtonTicketTemplate")
				GMR.CurrentTicketTemplate = name
				local template_type = GMR.CurrentTicketTemplate
				local text_to_run
				if data[2] == "Custom" then
					text_to_run = GMRConfig.ticket_template_data[template_type][data[3]][data[4]]
				elseif data[2] == "Default" then
					text_to_run = GMR.ticket_template_data[template_type][data[3]][data[4]]
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
					local _, _, name = string.find(Button:GetName(), "(.+)ButtonTicketTemplate")
					GMR.CurrentTicketTemplate = name
				    local template_type = GMR.CurrentTicketTemplate
					local text_to_run
					if data[2] == "Custom" then
						text_to_run = GMRConfig.ticket_template_data[template_type][data[3]][data[4]]
					elseif data[2] == "Default" then
						text_to_run = GMR.ticket_template_data[template_type][data[3]][data[4]]
					end
				    if data[2] == "Custom" and arg1 == "RightButton" then
				    	GMR.DeleteTicketTemplate(data[4], data[3], template_type)
				    	GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
				    elseif arg1 == "LeftButton" then
				    	--GMR.SendCommandSafe(text_to_run, template_type, GMR.common_handle)
				    	GMR.TicketTemplateButtonClick(text_to_run, GMR.CurrentTicketTemplate)
				    end
				end
			)	
		end

		if MouseIsOver(Button) then
			Button:GetScript("OnLeave")()
			Button:GetScript("OnEnter")()
		end
	end
end

function GMR.CreateTicketTemplateTableElemets(number)
	local f, t
	local result = {}
	for i = 1, number do
		f = CreateFrame("Button", GMR.CurrentTicketTemplate.."ButtonTicketTemplateTable"..i, nil, "CommandButtonTemplate")
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
		GMR.Buttons["ButtonTicketTemplateTable"..i] = f
		result[getn(result)+1] = f
	end	
	return result
end
function GMR.SortTicketTableTemplate()
	if GMR.CurrentTicketTemplate then
		local mas = GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate]
		--mas[i] = {ENUM, type, group, name}
		if mas then
			local group_flag = GMR.CheckButtons["enable groupsTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
			local customdefault_flag = GMR.CheckButtons["enable castomdefaultTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
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
end

function GMR.FindTicketOpenGroups()
	local open_groups = {}
	for i = 1, getn(GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate]) do
		if GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate][i][1] == GMR.ENUM_GROUP and not GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate][i][4] then
			open_groups[GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate][i][3]] = true
		end
	end
	return open_groups
end

function GMR.FindInTicketTemplateTable(str, hide_refind)
	if GMR.CurrentTicketTemplate then
		local template_type = GMR.CurrentTicketTemplate
		local group_flag 				= GMR.CheckButtons["enable groupsTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
		local customdefault_flag 		= GMR.CheckButtons["enable castomdefaultTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
		searchindescription_flag 	= GMR.CheckButtons["search in descriptionTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
		local hide						= GMR.CheckButtons["hide namesTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
		local open_groups 
		if hide_refind then open_groups = GMR.FindTicketOpenGroups() end
		
		GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate] = {}
		local data = GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate]	--data[i] = {ENUM, type, group, name}	-- hide_option vs name fo ENUM_GROUP
		local include_group = false						--case find name then include group
		local include_name =  false						--case find group then include name
		local include_type = false						--case found something then include that common worlds
		if GMRConfig.ticket_template_data[GMR.CurrentTicketTemplate] and GMRConfig.ticket_template_data[template_type]then
			for group, templates in pairs(GMRConfig.ticket_template_data[template_type]) do
				include_group = false
				include_name =  false	
				if hide_refind and open_groups[group] then 
					hide = false
				else
					hide = GMR.CheckButtons["hide namesTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
				end
				if group_flag and string.find(string.lower(group), str) then
					include_name = true
				end
				if hide_refind and open_groups[group] then 
					hide = false
				else
					hide = GMR.CheckButtons["hide namesTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
				end
				for name in pairs(templates) do
					if include_name or string.find(string.lower(name), str) or (searchindescription_flag and string.find(string.lower(GMRConfig.ticket_template_data[template_type][group][name]), str)) then
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
		if include_type and customdefault_flag and GMRConfig.ticket_template_data[GMR.CurrentTicketTemplate] and GMRConfig.ticket_template_data[template_type]and GMR.getn_keymas(GMRConfig.ticket_template_data[template_type]) > 0 then
			data[getn(data)+1] = {GMR.ENUM_TYPE, "Custom"}
		end

		include_type = false
		if GMR.ticket_template_data[template_type]then
			for group, templates in pairs(GMR.ticket_template_data[template_type]) do
				include_group = false
				include_name =  false	
				if hide_refind and open_groups[group] then 
					hide = false
				else
					hide = GMR.CheckButtons["hide namesTicketTemplateTable"..GMR.CurrentTicketTemplate]:GetChecked()
				end
				if group_flag and string.find(string.lower(group), str) then
					include_name = true
				end
				for name in pairs(templates) do
					if include_name or string.find(string.lower(name), str) or (searchindescription_flag and string.find(string.lower(GMR.ticket_template_data[template_type][group][name]), str)) then
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
		if include_type and customdefault_flag and GMR.ticket_template_data[GMR.CurrentTicketTemplate] and GMR.ticket_template_data[template_type]and GMR.getn_keymas(GMR.ticket_template_data[template_type]) > 0 then
			data[getn(data)+1] = {GMR.ENUM_TYPE, "Default"}
		end
	end
	return getn(GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate])
end

function GMR.BuildTicketTemplateFrame(name)
	GMR.CurrentTicketTemplate = name
	if not GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate] then
		 GMR.CurrentTicketTemplateTableElements[GMR.CurrentTicketTemplate] = {}
	end
	if not GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate] then
		local s1, s2, s3, s4, s5
		local buttons_mas = GMR.CreateTicketTemplateTableElemets(10)
	 	GMR.Tables._Init("TicketTemplate"..GMR.CurrentTicketTemplate, buttons_mas, GMR.UpdateTicketTemplateTableElement, GMR.FindInTicketTemplateTable, GMR.SortTicketTableTemplate)
 		local t = GMR.Tables._CreateTable("TicketTemplate"..GMR.CurrentTicketTemplate, GMR.TicketFrame, 20, 200, "TOPLEFT", "TOPLEFT", -270, 0, "Interface\\RaidFrame\\UI-RaidFrame-GroupBg.blp", true)	
 		t:SetFrameStrata("FULLSCREEN")
		GMR.EditBoxes["sortTicketTemplate"..GMR.CurrentTicketTemplate.."Table"]:SetPoint("BOTTOMLEFT", t, "TOPLEFT", 5, 2)
		local cb1 = GMR.CreateCheckButton("enable groupsTicketTemplateTable"..GMR.CurrentTicketTemplate, 0, 0, GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate], "BOTTOMRIGHT", "TOPRIGHT", "Enable groups sort")
		local cb2 = GMR.CreateCheckButton("enable castomdefaultTicketTemplateTable"..GMR.CurrentTicketTemplate, -20, 0, GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate], "BOTTOMRIGHT", "TOPRIGHT", "Enable User/Default sort")
		local cb3 = GMR.CreateCheckButton("search in descriptionTicketTemplateTable"..GMR.CurrentTicketTemplate, -40, 0, GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate], "BOTTOMRIGHT", "TOPRIGHT", "Enable search in template text")
		local cb4 = GMR.CreateCheckButton("hide namesTicketTemplateTable"..GMR.CurrentTicketTemplate, -60, 0, GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate], "BOTTOMRIGHT", "TOPRIGHT", "Enable compact form, hide results in groups")
		s1 = cb1:GetScript("OnClick")
		cb1:SetScript("OnClick", function() 	
			GMR.CurrentTicketTemplate = name
			GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
			s1()
		end)
		s2 = cb2:GetScript("OnClick")
		cb2:SetScript("OnClick", function() 	
			_, _, GMR.CurrentTicketTemplate = string.find(this:GetName(), "enable castomdefaultTicketTemplateTable(.+)CheckButton")
			GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
			s2()
		end)
		s3 = cb3:GetScript("OnClick")
		cb3:SetScript("OnClick", function() 	
			GMR.CurrentTicketTemplate = name
			GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
			s3()
		end)
		s4 = cb4:GetScript("OnClick")
		cb4:SetScript("OnClick", function() 
			GMR.CurrentTicketTemplate = name			
			GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
			s4()
		end)
		s5 = GMR.EditBoxes["sortTicketTemplate"..GMR.CurrentTicketTemplate.."Table"]:GetScript("OnTextChanged")
		GMR.EditBoxes["sortTicketTemplate"..GMR.CurrentTicketTemplate.."Table"]:SetScript("OnTextChanged", function() 	
			GMR.CurrentTicketTemplate = name
			GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
			s5()
		end)
		cb1:SetChecked()
		cb2:Click()
		GMR.Tables["TicketTemplate"..GMR.CurrentTicketTemplate]:Hide()
	else
		GMR.Tables._Update("TicketTemplate"..GMR.CurrentTicketTemplate)
	end
end